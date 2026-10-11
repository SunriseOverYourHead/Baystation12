"""Bulk species-sprite generator. Reads a manifest (from dm_manifest_export.dm's JSON dump) and the hand-authored
pixel-remap tables (via parse_remap_tables.py), and for every clothing item that:
  - has a leg_remap_category matching an already-extracted category, AND
  - does NOT already have a sprite_sheets entry for the target species (inherited or own -- if one exists at
    all, the existing runtime remap fallback already handles any gaps in it; this tool only fills total gaps), AND
  - a pixel table exists for (category, target species)
...generates a remapped on-mob sprite and bakes it into a NEW, generated-only .dmi (icons/mob/generated/), kept
strictly separate from hand-drawn art. Also emits a small DM snippet (GLOBAL_LIST_AS) wiring the generated
files in as a centralized fallback -- see code/modules/clothing/_generated_sprite_sheets.dm and the
get_mob_overlay() hook in items.dm. This deliberately avoids touching any individual item's own .dm file: with
~500 items in the first GAS pass alone, per-item edits would be both enormous and risky to review.

Usage:
    python3 generate_species_sprites.py --species gas --manifest /path/to/remap_manifest.json

The manifest is NOT included in this repo (it's a snapshot of runtime introspection, regenerate via
dm_manifest_export.dm whenever the clothing catalog changes) -- pass its path explicitly.
"""
import argparse
import json
import sys
from pathlib import Path
from collections import defaultdict

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import dmi_tool as dt
from PIL import Image

from parse_remap_tables import parse as parse_remap_tables

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
GENERATED_DIR = REPO_ROOT / "icons/mob/generated"

DIRS = ["SOUTH", "NORTH", "EAST", "WEST"]
REAL_TH = 32

# Species constant -> "shape_key" string used in the pixel tables (see get_body_shape_key() in update_icons.dm).
SPECIES_SHAPE_KEY = {
    "gas": "gas",
    "teshari": "teshari",
    "unathi": "unathi",
    "vox": "vox",
    "msq": "msq",
    "anthro": "digitigrade",  # only meaningful for leg-shape categories; matches get_body_shape_key()'s handling
}

# Species constant string (as used in DM's SPECIES_* defines / sprite_sheets keys) -> the get_bodytype() string
# used as the sprite_sheets list key. get_bodytype() returns species.name by default, and every species here sets
# name = SPECIES_X directly EXCEPT Nabber -- SPECIES_NABBER is #defined as "Giant Armoured Serpentid" (its actual
# in-fiction species name), not "Nabber" or "GAS", both of which are just this codebase's/this conversation's
# shorthand for it. Double check against `name = SPECIES_X` in the species' own .dm file before adding a new one
# here -- this bit everyone once already (2026-09-04).
SPECIES_BODYTYPE = {
    "gas": "Giant Armoured Serpentid",
    "teshari": "Teshari",
    "unathi": "Unathi",
    "vox": "Vox",
}


def byond_to_pil(x, y, real_th=REAL_TH):
    return (x - 1, real_th - y)


def load_source_tiles(icon_path, icon_state):
    """icon_path from the manifest is a DM resource path string like 'icons/mob/onmob/onmob_suit.dmi'."""
    full = REPO_ROOT / icon_path
    w, h, states, img = dt.load_dmi(str(full))
    by_name = {s["name"]: i for i, s in enumerate(states)}
    if icon_state not in by_name:
        return None
    return dt._state_tiles(img, w, h, states, by_name[icon_state])


def remap_tile(source_tiles, dir_index, entries, canvas_h=32):
    """Replicates get_leg_remapped_icon()'s per-direction Crop+Blend exactly: entries is a list of
    (sx, sy, dx, dy) BYOND-coordinate tuples. Falls back to the unmodified source tile if entries is empty,
    matching the engine's own "no rule for this direction" behavior. canvas_h lets the canvas grow taller than
    the standard 32px (see canvas_height_for() below) without shifting anything already at y=1..32 -- same
    bottom-anchored-headroom convention as the DM engine's own Crop(1,1,32,canvas_height)."""
    src = source_tiles[dir_index]
    if not entries:
        if canvas_h == 32:
            return src.copy()
        canvas = Image.new("RGBA", (32, canvas_h), (0, 0, 0, 0))
        canvas.paste(src, (0, canvas_h - 32))
        return canvas
    canvas = Image.new("RGBA", (32, canvas_h), (0, 0, 0, 0))
    src_px = src.load()
    dst_px = canvas.load()
    for sx, sy, dx, dy in entries:
        spx, spy = byond_to_pil(sx, sy, real_th=32)
        dpx, dpy = byond_to_pil(dx, dy, real_th=canvas_h)
        if not (0 <= spx < 32 and 0 <= spy < 32 and 0 <= dpx < 32 and 0 <= dpy < canvas_h):
            continue
        color = src_px[spx, spy]
        if color[3] == 0:
            continue
        dst_px[dpx, dpy] = color
    return canvas


def canvas_height_for(shape_tables):
    """Same sizing rule as the DM engine: 32 unless some direction's table needs more headroom."""
    height = 32
    for entries in shape_tables.values():
        for _sx, _sy, _dx, dy in entries:
            if dy > height:
                height = dy
    return height


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--species", required=True, help="shape_key / manifest species tag, e.g. gas")
    ap.add_argument("--manifest", required=True, type=Path)
    ap.add_argument("--dry-run", action="store_true", help="report what would be generated without writing files")
    args = ap.parse_args()

    species = args.species
    shape_key = SPECIES_SHAPE_KEY.get(species, species)
    bodytype = SPECIES_BODYTYPE.get(species)
    if not bodytype:
        print(f"error: no known bodytype for species '{species}' -- add it to SPECIES_BODYTYPE", file=sys.stderr)
        sys.exit(1)

    manifest = json.loads(args.manifest.read_text())
    tables = parse_remap_tables()

    GENERATED_DIR.mkdir(parents=True, exist_ok=True)

    dm_snippet_lines = []
    total_generated_items = 0
    total_generated_states = 0

    for category, items in sorted(manifest["manifest"].items()):
        cat_upper = category.upper()
        cat_tables = tables.get(cat_upper, {})
        shape_tables = cat_tables.get(shape_key)
        if not shape_tables:
            print(f"[{category}] no '{shape_key}' pixel table -- skipping ({len(items)} items)", file=sys.stderr)
            continue

        # Only items with NO existing coverage for THIS species -- see module docstring. existing_species is the
        # full list of bodytype strings (sprite_sheets' own keys) the manifest found on each item, so this check
        # is correct for any target species, not just the one the manifest happened to be exported for.
        candidates = [it for it in items if bodytype not in it["existing_species"]]
        if not candidates:
            print(f"[{category}] all {len(items)} items already have {species} coverage -- skipping", file=sys.stderr)
            continue

        # Dedupe by (real_icon, real_icon_state): many items share the same underlying sprite.
        unique_sources = {}
        for it in candidates:
            key = (it["real_icon"], it["real_icon_state"])
            unique_sources.setdefault(key, []).append(it["type"])

        canvas_h = canvas_height_for(shape_tables)
        if canvas_h > 32:
            print(f"[{category}] '{shape_key}' needs a taller canvas (up to {canvas_h}px) -- headroom above "
                  f"the standard 32px, bottom-anchored", file=sys.stderr)

        out_states = []
        out_tiles_per_state = []
        skipped_missing_source = []
        for (icon_path, icon_state), item_types in sorted(unique_sources.items()):
            source_tiles = load_source_tiles(icon_path, icon_state)
            if source_tiles is None:
                skipped_missing_source.append((icon_path, icon_state, item_types))
                continue
            tiles = []
            for i, dname in enumerate(DIRS):
                entries = shape_tables.get(dname, [])
                tiles.append(remap_tile(source_tiles, i, entries, canvas_h))
            out_states.append({"name": icon_state, "dirs": 4, "frames": 1, "delays": None,
                                "rewind": 0, "loop": 0, "movement": 0})
            out_tiles_per_state.append(tiles)

        if skipped_missing_source:
            for icon_path, icon_state, item_types in skipped_missing_source:
                print(f"[{category}] WARNING: source state not found: {icon_path}:{icon_state} "
                      f"(affects {len(item_types)} item type(s)) -- skipped", file=sys.stderr)

        if not out_states:
            continue

        out_path = GENERATED_DIR / f"onmob_{category}_{species}.dmi"
        rel_path = out_path.relative_to(REPO_ROOT)
        if not args.dry_run:
            dt.save_dmi(str(out_path), 32, canvas_h, out_states, out_tiles_per_state)

        total_generated_items += len(candidates)
        total_generated_states += len(out_states)
        print(f"[{category}] generated {len(out_states)} unique state(s) covering {len(candidates)} item "
              f"type(s) -> {rel_path}", file=sys.stderr)

        species_define = "SPECIES_NABBER" if species == "gas" else f"SPECIES_{species.upper()}"
        dm_snippet_lines.append(
            f"\tCLOTHING_LEG_CATEGORY_{cat_upper} = list({species_define} = '{rel_path.as_posix()}'),"
        )

    print(f"\nTotal: {total_generated_states} generated states covering {total_generated_items} item types "
          f"across {len(dm_snippet_lines)} categories.", file=sys.stderr)

    if dm_snippet_lines and not args.dry_run:
        print("\n--- Merge this into code/modules/clothing/_generated_sprite_sheets.dm's GLOBAL_LIST_AS ---")
        print("\n".join(dm_snippet_lines))


if __name__ == "__main__":
    main()
