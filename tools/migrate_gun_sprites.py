#!/usr/bin/env python3
"""
migrate_gun_sprites.py

For each gun DMI in code/modules/projectiles/guns/:
  1. Parse the gun's .dm file to get icon_state, item_state, wielded_item_state, slot_flags
  2. Extract matching on-mob sprites from the global lefthand/righthand/back DMI files
  3. Merge them into the gun's own .dmi under the standardised naming convention:
       <icon_state>_l            left hand (not wielded)
       <icon_state>_r            right hand (not wielded)
       <icon_state>_l_wielded    left hand wielded
       <icon_state>_r_wielded    right hand wielded
       <icon_state>_back         back / shoulder slot
  4. Print a per-gun report listing what was found and what was missing.

Run from the repository root:
    python tools/migrate_gun_sprites.py [--dry-run]
"""

import math
import os
import re
import struct
import sys
import zlib
from dataclasses import dataclass, field
from io import BytesIO
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from PIL import Image

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

ROOT = Path(__file__).resolve().parent.parent
GUNS_ROOT = ROOT / "code/modules/projectiles/guns"

GLOBAL_LEFT  = ROOT / "icons/mob/onmob/items/lefthand_guns.dmi"
GLOBAL_RIGHT = ROOT / "icons/mob/onmob/items/righthand_guns.dmi"
GLOBAL_BACK  = ROOT / "icons/mob/onmob/onmob_back.dmi"

DRY_RUN = "--dry-run" in sys.argv

# ---------------------------------------------------------------------------
# DMI data classes
# ---------------------------------------------------------------------------

@dataclass
class DMIState:
    name: str
    dirs: int = 1
    frames: int = 1
    delay: List[float] = field(default_factory=list)
    loop: Optional[int] = None
    rewind: Optional[int] = None
    hotspot: Optional[str] = None
    images: List[Image.Image] = field(default_factory=list)

    @property
    def cell_count(self) -> int:
        return self.dirs * self.frames


class DMIFile:
    """Parse, edit, and write BYOND .dmi files."""

    def __init__(self, width: int = 32, height: int = 32):
        self.width = width
        self.height = height
        self.states: List[DMIState] = []

    # ------------------------------------------------------------------
    # Reading
    # ------------------------------------------------------------------

    @classmethod
    def from_path(cls, path: Path) -> "DMIFile":
        raw = path.read_bytes()
        img = Image.open(BytesIO(raw)).convert("RGBA")
        meta = cls._extract_meta(raw)
        dmi = cls._parse_meta(meta)
        dmi._unpack_sprites(img)
        return dmi

    @staticmethod
    def _extract_meta(raw: bytes) -> str:
        pos = 8
        while pos + 8 <= len(raw):
            length = struct.unpack(">I", raw[pos:pos+4])[0]
            ctype = raw[pos+4:pos+8].decode("ascii", errors="replace")
            data = raw[pos+8:pos+8+length]
            pos += 12 + length
            if ctype == "zTXt":
                ni = data.index(b"\x00")
                if data[:ni] == b"Description":
                    return zlib.decompress(data[ni+2:]).decode("utf-8")
            elif ctype == "tEXt":
                ni = data.index(b"\x00")
                if data[:ni] == b"Description":
                    return data[ni+1:].decode("utf-8")
            elif ctype == "IEND":
                break
        return ""

    @classmethod
    def _parse_meta(cls, meta: str) -> "DMIFile":
        dmi = cls()
        current: Optional[DMIState] = None
        for raw_line in meta.splitlines():
            line = raw_line.strip()
            if not line or line in ("# BEGIN DMI", "# END DMI"):
                continue
            m = re.match(r"version\s*=", line)
            if m:
                continue
            m = re.match(r"width\s*=\s*(\d+)", line)
            if m:
                dmi.width = int(m.group(1)); continue
            m = re.match(r"height\s*=\s*(\d+)", line)
            if m:
                dmi.height = int(m.group(1)); continue
            m = re.match(r'state\s*=\s*"(.*)"', line)
            if m:
                current = DMIState(name=m.group(1))
                dmi.states.append(current); continue
            if current is None:
                continue
            m = re.match(r"dirs\s*=\s*(\d+)", line)
            if m:
                current.dirs = int(m.group(1)); continue
            m = re.match(r"frames\s*=\s*(\d+)", line)
            if m:
                current.frames = int(m.group(1)); continue
            m = re.match(r"delay\s*=\s*(.+)", line)
            if m:
                current.delay = [float(x) for x in m.group(1).split(",")]; continue
            m = re.match(r"loop\s*=\s*(\d+)", line)
            if m:
                current.loop = int(m.group(1)); continue
            m = re.match(r"rewind\s*=\s*(\d+)", line)
            if m:
                current.rewind = int(m.group(1)); continue
            m = re.match(r"hotspot\s*=\s*(.+)", line)
            if m:
                current.hotspot = m.group(1); continue
        return dmi

    def _unpack_sprites(self, img: Image.Image):
        cpr = img.width // self.width
        idx = 0
        for st in self.states:
            st.images = []
            for _ in range(st.cell_count):
                row, col = divmod(idx, cpr)
                x, y = col * self.width, row * self.height
                st.images.append(img.crop((x, y, x + self.width, y + self.height)))
                idx += 1

    # ------------------------------------------------------------------
    # State access
    # ------------------------------------------------------------------

    def get_state(self, name: str) -> Optional[DMIState]:
        for s in self.states:
            if s.name == name:
                return s
        return None

    def has_state(self, name: str) -> bool:
        return self.get_state(name) is not None

    def state_names(self) -> List[str]:
        return [s.name for s in self.states]

    def add_state(self, state: DMIState):
        """Append state, replacing any existing state with the same name."""
        old = self.get_state(state.name)
        if old:
            self.states.remove(old)
        self.states.append(state)

    def clone_state(self, source: DMIState, new_name: str) -> DMIState:
        """Return a copy of source with a different name."""
        return DMIState(
            name=new_name,
            dirs=source.dirs,
            frames=source.frames,
            delay=list(source.delay),
            loop=source.loop,
            rewind=source.rewind,
            hotspot=source.hotspot,
            images=list(source.images),
        )

    # ------------------------------------------------------------------
    # Writing
    # ------------------------------------------------------------------

    def save(self, path: Path):
        total_cells = sum(s.cell_count for s in self.states)
        if total_cells == 0:
            total_cells = 1
        cols = min(total_cells, 10)
        rows = math.ceil(total_cells / cols)
        img = Image.new("RGBA", (cols * self.width, rows * self.height), (0, 0, 0, 0))

        idx = 0
        for st in self.states:
            for frame in st.images:
                row, col = divmod(idx, cols)
                img.paste(frame.convert("RGBA"), (col * self.width, row * self.height))
                idx += 1

        png_bytes = self._to_png_bytes(img, self._build_meta())
        if not DRY_RUN:
            path.write_bytes(png_bytes)

    def _build_meta(self) -> str:
        lines = ["# BEGIN DMI", "version = 4.0",
                 f"\twidth = {self.width}", f"\theight = {self.height}"]
        for st in self.states:
            lines.append(f'state = "{st.name}"')
            lines.append(f"\tdirs = {st.dirs}")
            lines.append(f"\tframes = {st.frames}")
            if st.delay:
                lines.append(f"\tdelay = {','.join(str(d) for d in st.delay)}")
            if st.loop is not None:
                lines.append(f"\tloop = {st.loop}")
            if st.rewind is not None:
                lines.append(f"\trewind = {st.rewind}")
            if st.hotspot is not None:
                lines.append(f"\thotspot = {st.hotspot}")
        lines.append("# END DMI")
        return "\n".join(lines)

    @staticmethod
    def _to_png_bytes(img: Image.Image, meta: str) -> bytes:
        buf = BytesIO()
        img.save(buf, format="PNG", optimize=False)
        raw = buf.getvalue()

        result = bytearray(raw[:8])
        pos = 8
        injected = False

        while pos + 8 <= len(raw):
            length = struct.unpack(">I", raw[pos:pos+4])[0]
            ctype = raw[pos+4:pos+8]
            data = raw[pos+8:pos+8+length]
            pos += 12 + length
            ct = ctype.decode("ascii", errors="replace")

            # Drop any existing Description chunk
            if ct in ("zTXt", "tEXt"):
                ni = data.find(b"\x00")
                if ni >= 0 and data[:ni] == b"Description":
                    continue

            # Inject our metadata before the first IDAT
            if ct == "IDAT" and not injected:
                meta_bytes = meta.encode("utf-8")
                compressed = zlib.compress(meta_bytes, level=9)
                payload = b"Description\x00\x00" + compressed
                chunk_len = struct.pack(">I", len(payload))
                crc = struct.pack(">I", zlib.crc32(b"zTXt" + payload) & 0xFFFFFFFF)
                result += chunk_len + b"zTXt" + payload + crc
                injected = True

            # Re-emit the chunk, recalculating CRC (Pillow's CRC is correct, but we
            # may have reconstructed the buffer so always recompute to be safe)
            crc_val = struct.pack(">I", zlib.crc32(ctype + data) & 0xFFFFFFFF)
            result += struct.pack(">I", length) + ctype + data + crc_val

        return bytes(result)


# ---------------------------------------------------------------------------
# Parse gun .dm files
# ---------------------------------------------------------------------------

@dataclass
class GunInfo:
    dm_path: Path
    dmi_path: Path          # primary DMI (co-located)
    icon_state: str         # world sprite state (our naming prefix)
    item_state: str         # key into global lefthand/righthand DMIs
    wielded_state: str      # key for wielded sprites (may equal item_state + "-wielded")
    has_slot_back: bool
    already_has_item_icons: bool


def _first_match(pattern: str, text: str, default: str = "") -> str:
    m = re.search(pattern, text)
    return m.group(1) if m else default


def parse_gun_dm(dm_path: Path) -> Optional[GunInfo]:
    """Extract the primary gun type's sprite fields from a .dm file."""
    text = dm_path.read_text(encoding="utf-8", errors="replace")

    # Must define a gun type
    if not re.search(r"^/obj/item/gun[^\n]*\n", text, re.MULTILINE):
        return None

    # First icon_state and item_state in the file (belonging to the primary type)
    icon_state = _first_match(r'\bicon_state\s*=\s*"([^"]+)"', text)
    if not icon_state or icon_state.startswith("["):
        return None  # dynamic – skip

    item_state = _first_match(r'\bitem_state\s*=\s*"([^"]+)"', text, icon_state)
    if item_state.startswith("["):
        item_state = icon_state

    wielded = _first_match(r'\bwielded_item_state\s*=\s*"([^"]+)"', text)
    if not wielded:
        wielded = f"{item_state}-wielded"

    # Find the co-located DMI
    dmi_path: Optional[Path] = None
    for candidate in dm_path.parent.glob("*.dmi"):
        # Prefer a DMI whose stem matches the .dm file stem
        if candidate.stem == dm_path.stem:
            dmi_path = candidate
            break
    if dmi_path is None:
        # Fall back to any DMI in the folder
        dmis = list(dm_path.parent.glob("*.dmi"))
        if dmis:
            dmi_path = dmis[0]
    if dmi_path is None:
        return None

    has_slot_back = bool(re.search(r"\bSLOT_BACK\b", text))
    has_item_icons = bool(re.search(r"\bitem_icons\s*=\s*list\s*\(", text))

    return GunInfo(
        dm_path=dm_path,
        dmi_path=dmi_path,
        icon_state=icon_state,
        item_state=item_state,
        wielded_state=wielded,
        has_slot_back=has_slot_back,
        already_has_item_icons=has_item_icons,
    )


# ---------------------------------------------------------------------------
# Load all global DMIs once
# ---------------------------------------------------------------------------

def load_global_dmis() -> Dict[str, DMIFile]:
    return {
        "left":  DMIFile.from_path(GLOBAL_LEFT),
        "right": DMIFile.from_path(GLOBAL_RIGHT),
        "back":  DMIFile.from_path(GLOBAL_BACK),
    }


# ---------------------------------------------------------------------------
# Core migration logic for one gun
# ---------------------------------------------------------------------------

SUFFIX_MAP = [
    # (slot_key, source_dmi_key, global_state_fn,           new_suffix)
    ("l",         "left",  lambda i, w: i,                  "_l"),
    ("r",         "right", lambda i, w: i,                  "_r"),
    ("l_wielded", "left",  lambda i, w: w,                  "_l_wielded"),
    ("r_wielded", "right", lambda i, w: w,                  "_r_wielded"),
    ("back",      "back",  lambda i, w: i,                  "_back"),
]


def migrate_gun(gun: GunInfo, globals_: Dict[str, DMIFile]) -> Dict[str, str]:
    """
    Add on-mob sprites to the gun's own DMI.
    Returns a dict of {slot: 'found'|'missing'|'skipped'}.
    """
    target = DMIFile.from_path(gun.dmi_path)
    prefix = gun.icon_state
    report = {}

    for slot_key, src_key, state_fn, suffix in SUFFIX_MAP:
        new_name = f"{prefix}{suffix}"

        # Already present — don't overwrite
        if target.has_state(new_name):
            report[slot_key] = "already_present"
            continue

        src_dmi = globals_[src_key]
        global_state_name = state_fn(gun.item_state, gun.wielded_state)
        src_state = src_dmi.get_state(global_state_name)

        if src_state is None:
            # Try falling back to icon_state directly
            src_state = src_dmi.get_state(gun.icon_state)

        if src_state is None:
            report[slot_key] = f"missing ({global_state_name!r})"
            continue

        # Skip back sprite if the gun can't go on back
        if slot_key == "back" and not gun.has_slot_back:
            report[slot_key] = "skipped_no_back_slot"
            continue

        cloned = target.clone_state(src_state, new_name)
        target.add_state(cloned)
        report[slot_key] = "found"

    any_added = any(v == "found" for v in report.values())
    if any_added:
        target.save(gun.dmi_path)

    return report


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print(f"{'DRY RUN — ' if DRY_RUN else ''}Migrating on-mob gun sprites")
    print(f"Root: {ROOT}")
    print()

    globals_ = load_global_dmis()
    print(f"Loaded global DMIs:")
    print(f"  lefthand_guns  : {len(globals_['left'].states)} states")
    print(f"  righthand_guns : {len(globals_['right'].states)} states")
    print(f"  onmob_back     : {len(globals_['back'].states)} states")
    print()

    # Collect all gun .dm files (skip top-level energy.dm / projectile.dm / launcher.dm)
    dm_files = sorted(
        p for p in GUNS_ROOT.rglob("*.dm")
        if p.parent != GUNS_ROOT  # skip the base category files
    )

    skipped_existing = []
    processed = []
    failed = []

    for dm_path in dm_files:
        gun = parse_gun_dm(dm_path)
        if gun is None:
            continue

        rel = str(gun.dm_path.relative_to(ROOT))

        if gun.already_has_item_icons:
            skipped_existing.append(rel)
            continue

        try:
            report = migrate_gun(gun, globals_)
            processed.append((rel, gun, report))
        except Exception as exc:
            failed.append((rel, str(exc)))

    # ------------------------------------------------------------------
    # Print report
    # ------------------------------------------------------------------

    print("=" * 72)
    print(f"PROCESSED ({len(processed)} guns)")
    print("=" * 72)
    for rel, gun, report in processed:
        found    = [k for k, v in report.items() if v == "found"]
        missing  = [(k, v) for k, v in report.items() if "missing" in v]
        skipped  = [k for k, v in report.items() if v.startswith("skipped")]
        present  = [k for k, v in report.items() if v == "already_present"]

        status = "OK" if found and not missing else ("PARTIAL" if found else "NOTHING")
        print(f"  [{status}] {rel}")
        print(f"         icon_state={gun.icon_state!r}  item_state={gun.item_state!r}  wielded={gun.wielded_state!r}")
        if found:
            print(f"         added   : {', '.join(found)}")
        if present:
            print(f"         present : {', '.join(present)}")
        if missing:
            for k, v in missing:
                print(f"         MISSING : {k} ({v})")
        if skipped:
            print(f"         skipped : {', '.join(skipped)}")
        print()

    if skipped_existing:
        print("=" * 72)
        print(f"SKIPPED — already have item_icons ({len(skipped_existing)})")
        print("=" * 72)
        for rel in skipped_existing:
            print(f"  {rel}")
        print()

    if failed:
        print("=" * 72)
        print(f"ERRORS ({len(failed)})")
        print("=" * 72)
        for rel, err in failed:
            print(f"  {rel}: {err}")
        print()

    print("=" * 72)
    total_found   = sum(sum(1 for v in r.items() if v[1] == "found") for _, _, r in processed)
    total_missing = sum(sum(1 for v in r.items() if "missing" in v[1]) for _, _, r in processed)
    print(f"Summary: {len(processed)} guns processed, {total_found} sprites added, "
          f"{total_missing} missing slots, {len(skipped_existing)} skipped (existing item_icons)")


if __name__ == "__main__":
    main()
