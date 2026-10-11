"""Extracts leg_remap pixel tables from hand-painted species states in reference.dmi.

Companion to generate_species_sprites.py (see tools/species_remap/README.md and the header comment in
icons/mob/human_races/species/human/reference.dmi for the full authoring workflow). Each `reference-<category>`
baseline state has every opaque real-content pixel perturbed to a globally-unique-but-nearby color (see
color_key() below); the artist then hand-paints `<species>-<category>` states by repositioning/recoloring those
same unique-colored pixels to fit that species' silhouette. This script reverses the perturbation: for every
opaque pixel in a painted state, it looks up which (direction, real_x, real_y) in the ORIGINAL game sprite that
exact color came from, and emits a (src_x, src_y, dst_x, dst_y) BYOND-coordinate entry -- the same format
_leg_shape_remap.dm's get_leg_remap_pixels_*() tables already use.

Direction priority (2026-09-04 fix): a painted pixel's color is matched against its OWN direction's reference
first, and only falls back to the other 3 directions if that direction's reference doesn't contain the color at
all. This matters because reference-<category> baselines are NOT always globally unique across all 4 directions
-- reference-uniform's EAST and WEST reference tiles turned out to share their *entire* color palette (121/121
colors identical both ways -- likely a perturbation-script quirk from whenever that particular baseline was
built, unlike reference-helmet/reference-suit which really are globally unique). A single merged {color: (dir,x,
y)} lookup silently lets whichever direction is processed last (WEST) win for every shared color, even when the
pixel being scanned is EAST's own reference-correct content -- this was confirmed directly: every opaque pixel in
gas-uniform's painted EAST tile has a valid match in EAST's OWN reference tile (zero cross-direction fallback
actually needed), yet the merged-lookup approach was resolving ~84% of them to WEST's positions instead, and
~40% of NORTH's to SOUTH's. Building one lookup PER direction and checking own-direction first eliminates this
regardless of how much cross-direction color overlap a given baseline happens to have.

Mirror handling (2026-09-04): artists commonly paint the EAST direction, then mirror it horizontally to produce
WEST (a standard sprite-authoring shortcut) rather than painting WEST fresh against its own reference. The
mirrored pixels keep their EAST-perturbation colors, so when a painted pixel has NO match in its own direction's
reference, the fallback check applies a mirror-correction if the match is found in the horizontally-opposite
direction (EAST found while scanning WEST, or vice versa) -- mirroring the source x-coordinate before emitting
the entry, since the mirrored pixel visually represents EAST content flipped, not WEST content at that raw
position. Any other cross-direction fallback match (not the mirror pair) passes through unchanged, trusting it
as literally painted -- matching this system's established "artists sample colors from whichever reference
direction is convenient" allowance, now correctly used only as an actual fallback instead of the default path.
"""
import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import dmi_tool as dt

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
REFERENCE_PATH = REPO_ROOT / "icons/mob/human_races/species/human/reference.dmi"

# dt._state_tiles() returns frames in the order BYOND stores them for a 4-dir state: SOUTH, NORTH, EAST, WEST.
DIR_NAMES = ["SOUTH", "NORTH", "EAST", "WEST"]
MIRROR_PAIR = {"EAST": "WEST", "WEST": "EAST"}

REAL_W = 32  # every reference-<category> baseline is built from a 32x32 real game sprite (see its own header).


def byond_from_pil(px, py, height):
    """PIL (0-indexed, y-down) -> BYOND (1-indexed, y-up) using the given canvas/content height."""
    return px + 1, height - py


def build_reference_lookup(canvas_w, canvas_h, states, img, baseline_name):
    """{dir_name: {color: (real_x, real_y)}}, real_x/real_y 0-indexed in the 32x32 real-content grid. One
    independent lookup per direction -- NOT merged -- so a color that happens to also appear in another
    direction's reference can never shadow this direction's own (correct) match. See module docstring."""
    by_name = {s["name"]: i for i, s in enumerate(states)}
    idx = by_name[baseline_name]
    tiles = dt._state_tiles(img, canvas_w, canvas_h, states, idx)
    y_offset = canvas_h - REAL_W  # real content sits at (x, y+y_offset); matches replace_suit_helmet_reference.py
    per_dir = {}
    for dir_name, tile in zip(DIR_NAMES, tiles):
        px = tile.load()
        lookup = {}
        for ry in range(REAL_W):
            for rx in range(REAL_W):
                r, g, b, a = px[rx, ry + y_offset]
                if a == 0:
                    continue
                lookup[(r, g, b)] = (rx, ry)
        per_dir[dir_name] = lookup
    return per_dir


def extract_painted_state(canvas_w, canvas_h, states, img, state_name, per_dir_lookup):
    """Returns {dir_name: [(sx,sy,dx,dy), ...]} for one painted <species>-<category> state. per_dir_lookup is
    build_reference_lookup()'s per-direction dict-of-dicts (own-direction checked first, see module docstring)."""
    by_name = {s["name"]: i for i, s in enumerate(states)}
    idx = by_name[state_name]
    tiles = dt._state_tiles(img, canvas_w, canvas_h, states, idx)

    out = {d: [] for d in DIR_NAMES}
    unmatched = 0
    mirrored_count = 0
    cross_matched = 0
    for dir_name, tile in zip(DIR_NAMES, tiles):
        px = tile.load()
        for cy in range(canvas_h):
            for cx in range(canvas_w):
                r, g, b, a = px[cx, cy]
                if a == 0:
                    continue
                color = (r, g, b)
                own = per_dir_lookup[dir_name].get(color)
                if own:
                    rx, ry = own
                else:
                    fallback_dir = None
                    for other_dir in DIR_NAMES:
                        if other_dir == dir_name:
                            continue
                        if color in per_dir_lookup[other_dir]:
                            fallback_dir = other_dir
                            break
                    if not fallback_dir:
                        unmatched += 1
                        continue
                    rx, ry = per_dir_lookup[fallback_dir][color]
                    if MIRROR_PAIR.get(fallback_dir) == dir_name:
                        rx = (REAL_W - 1) - rx
                        mirrored_count += 1
                    cross_matched += 1
                sx, sy = byond_from_pil(rx, ry, REAL_W)
                dx, dy = byond_from_pil(cx, cy, canvas_h)
                out[dir_name].append((sx, sy, dx, dy))
    return out, unmatched, mirrored_count, cross_matched


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--baseline", required=True, help="reference-<category> state name, eg reference-helmet")
    ap.add_argument("--states", required=True, nargs="+", help="painted <species>-<category> state name(s)")
    ap.add_argument("--out-json", type=Path, help="write {state: {dir: [[sx,sy,dx,dy],...]}} here")
    args = ap.parse_args()

    canvas_w, canvas_h, states, img = dt.load_dmi(str(REFERENCE_PATH))
    per_dir_lookup = build_reference_lookup(canvas_w, canvas_h, states, img, args.baseline)
    counts_str = ", ".join(f"{d}={len(per_dir_lookup[d])}" for d in DIR_NAMES)
    print(f"reference lookup (per-direction) from '{args.baseline}': {counts_str}", file=sys.stderr)

    result = {}
    for state_name in args.states:
        out, unmatched, mirrored_count, cross_matched = extract_painted_state(
            canvas_w, canvas_h, states, img, state_name, per_dir_lookup)
        counts = {d: len(v) for d, v in out.items()}
        print(f"[{state_name}] {counts} unmatched={unmatched} cross-direction-fallback={cross_matched} "
              f"(of which mirror-corrected={mirrored_count})", file=sys.stderr)
        result[state_name] = out

    if args.out_json:
        json.dump(result, args.out_json.open("w"), indent=1)
        print(f"wrote {args.out_json}", file=sys.stderr)


if __name__ == "__main__":
    main()
