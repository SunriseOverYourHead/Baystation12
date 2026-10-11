#!/usr/bin/env python3
"""
update_gun_dm_files.py

For each gun .dm file whose DMI now has co-located on-mob sprites (added by
migrate_gun_sprites.py), update the .dm file to:

  1. Add/update item_icons pointing to the gun's own DMI for the appropriate slots
  2. Set colocated_sprites = TRUE
  3. Leave wielded_item_state and item_state unchanged (still used by legacy subtypes)

Guns that already have item_icons are skipped (they manage their own setup).

Run from the repository root:
    python tools/update_gun_dm_files.py [--dry-run]
"""

import re
import sys
import struct
import zlib
from pathlib import Path
from typing import Optional, List

ROOT = Path(__file__).resolve().parent.parent
GUNS_ROOT = ROOT / "code/modules/projectiles/guns"

DRY_RUN = "--dry-run" in sys.argv

# ---------------------------------------------------------------------------
# Minimal DMI state reader (no Pillow needed)
# ---------------------------------------------------------------------------

def get_dmi_state_names(path: Path) -> List[str]:
    raw = path.read_bytes()
    pos = 8
    while pos + 8 <= len(raw):
        length = struct.unpack(">I", raw[pos:pos+4])[0]
        ct = raw[pos+4:pos+8]
        data = raw[pos+8:pos+8+length]
        pos += 12 + length
        if ct == b"zTXt":
            ni = data.index(b"\x00")
            if data[:ni] == b"Description":
                meta = zlib.decompress(data[ni+2:]).decode("utf-8")
                return [l.strip()[8:].strip('"') for l in meta.splitlines() if l.strip().startswith("state = ")]
        elif ct == b"tEXt":
            ni = data.index(b"\x00")
            if data[:ni] == b"Description":
                meta = data[ni+1:].decode("utf-8")
                return [l.strip()[8:].strip('"') for l in meta.splitlines() if l.strip().startswith("state = ")]
    return []


# ---------------------------------------------------------------------------
# Parse gun .dm file
# ---------------------------------------------------------------------------

def _first(pattern: str, text: str, default: str = "") -> str:
    m = re.search(pattern, text)
    return m.group(1) if m else default


def parse_gun_dm(dm_path: Path):
    text = dm_path.read_text(encoding="utf-8", errors="replace")
    if not re.search(r"^/obj/item/gun[^\n]*\n", text, re.MULTILINE):
        return None

    icon_state = _first(r'\bicon_state\s*=\s*"([^"]+)"', text)
    if not icon_state or icon_state.startswith("["):
        return None

    # Find co-located DMI (prefer matching stem)
    dmi_path: Optional[Path] = None
    for c in dm_path.parent.glob("*.dmi"):
        if c.stem == dm_path.stem:
            dmi_path = c
            break
    if dmi_path is None:
        dmis = list(dm_path.parent.glob("*.dmi"))
        if dmis:
            dmi_path = dmis[0]
    if dmi_path is None:
        return None

    has_item_icons = bool(re.search(r"\bitem_icons\s*=\s*list\s*\(", text))
    has_colocated = bool(re.search(r"\bcolocated_sprites\s*=\s*TRUE\b", text))
    has_slot_back = bool(re.search(r"\bSLOT_BACK\b", text))

    return {
        "dm_path": dm_path,
        "dmi_path": dmi_path,
        "icon_state": icon_state,
        "has_item_icons": has_item_icons,
        "has_colocated": has_colocated,
        "has_slot_back": has_slot_back,
        "text": text,
    }


# ---------------------------------------------------------------------------
# Build the item_icons / colocated_sprites block to insert
# ---------------------------------------------------------------------------

def build_insertion(gun: dict, dmi_states: List[str], dmi_rel: str) -> str:
    prefix = gun["icon_state"]
    has_l = f"{prefix}_l" in dmi_states
    has_r = f"{prefix}_r" in dmi_states
    has_back = f"{prefix}_back" in dmi_states and gun["has_slot_back"]

    if not (has_l or has_r):
        return ""  # Nothing to add

    # Build item_icons list
    lines = ["\titem_icons = list("]
    if has_l:
        lines.append(f"\t\tslot_l_hand_str = '{dmi_rel}',")
    if has_r:
        lines.append(f"\t\tslot_r_hand_str = '{dmi_rel}',")
    if has_back:
        lines.append(f"\t\tslot_back_str = '{dmi_rel}',")
    lines.append("\t)")
    lines.append("\tcolocated_sprites = TRUE")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Inject the block into the .dm file text
# ---------------------------------------------------------------------------

def insert_into_dm(text: str, block: str, gun: dict) -> str:
    """Insert item_icons + colocated_sprites after the icon_state line of the
    primary type definition."""
    # Find the primary type header line
    header_match = re.search(r"^(/obj/item/gun[^\n]*)\n", text, re.MULTILINE)
    if not header_match:
        return text

    # Find the icon_state line within the type block
    # Look for icon_state = "..." that appears after the type header
    header_end = header_match.end()
    rest = text[header_end:]

    # Find the last occurrence of icon_state in the primary block
    # (before another type definition or a proc definition)
    block_end_match = re.search(r"^\n(?=/|\t*\w.*\()", rest, re.MULTILINE)
    if block_end_match:
        primary_block = rest[:block_end_match.start()]
    else:
        primary_block = rest

    icon_state_match = re.search(r"(\bicon_state\s*=\s*\"[^\"]+\")", primary_block)
    if not icon_state_match:
        return text

    insert_pos = header_end + icon_state_match.end()
    return text[:insert_pos] + "\n" + block + text[insert_pos:]


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print(f"{'DRY RUN — ' if DRY_RUN else ''}Updating gun .dm files with item_icons + colocated_sprites")
    print()

    dm_files = sorted(
        p for p in GUNS_ROOT.rglob("*.dm")
        if p.parent != GUNS_ROOT
    )

    updated = []
    skipped_existing = []
    skipped_no_sprites = []
    errors = []

    for dm_path in dm_files:
        gun = parse_gun_dm(dm_path)
        if gun is None:
            continue

        rel = str(gun["dm_path"].relative_to(ROOT))

        if gun["has_item_icons"]:
            skipped_existing.append(rel)
            continue

        if gun["has_colocated"]:
            skipped_existing.append(f"{rel} (already has colocated_sprites)")
            continue

        # Check which new-convention states actually exist in the DMI
        dmi_states = get_dmi_state_names(gun["dmi_path"])
        prefix = gun["icon_state"]

        has_l = f"{prefix}_l" in dmi_states
        has_r = f"{prefix}_r" in dmi_states

        if not (has_l or has_r):
            skipped_no_sprites.append(f"{rel} (no co-located hand sprites found)")
            continue

        # Build the relative path for the DMI as it appears in DM code
        dmi_rel = str(gun["dmi_path"].relative_to(ROOT)).replace("\\", "/")

        block = build_insertion(gun, dmi_states, dmi_rel)
        if not block:
            skipped_no_sprites.append(f"{rel} (nothing to insert)")
            continue

        try:
            new_text = insert_into_dm(gun["text"], block, gun)
            if new_text == gun["text"]:
                errors.append(f"{rel}: insertion point not found")
                continue

            if not DRY_RUN:
                gun["dm_path"].write_text(new_text, encoding="utf-8")

            has_back = f"{prefix}_back" in dmi_states and gun["has_slot_back"]
            updated.append(f"{rel}  [{prefix}_l/r{'  +back' if has_back else ''}]")
        except Exception as e:
            errors.append(f"{rel}: {e}")

    print(f"{'=' * 70}")
    print(f"UPDATED ({len(updated)})")
    print(f"{'=' * 70}")
    for r in updated:
        print(f"  {r}")

    print()
    print(f"{'=' * 70}")
    print(f"SKIPPED — already set up ({len(skipped_existing)})")
    print(f"{'=' * 70}")
    for r in skipped_existing:
        print(f"  {r}")

    print()
    print(f"{'=' * 70}")
    print(f"SKIPPED — no co-located sprites ({len(skipped_no_sprites)})")
    print(f"{'=' * 70}")
    for r in skipped_no_sprites:
        print(f"  {r}")

    if errors:
        print()
        print(f"{'=' * 70}")
        print(f"ERRORS ({len(errors)})")
        print(f"{'=' * 70}")
        for r in errors:
            print(f"  {r}")


if __name__ == "__main__":
    main()
