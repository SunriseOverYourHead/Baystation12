"""Parses code/modules/clothing/_leg_shape_remap.dm's hand-authored pixel-remap tables into a plain Python dict,
so other tooling (the bulk sprite generator) doesn't need a second, separately-maintained copy of this data --
the .dm file stays the single source of truth.

Structure returned by parse():
    {category_name: {shape_key: {dir_name: [(sx, sy, dx, dy), ...]}}}
e.g. tables["SUIT"]["gas"]["SOUTH"] -> list of (src_x, src_y, dst_x, dst_y) BYOND-coordinate tuples.

Only understands the exact generation format this whole pipeline has used all along: consecutive
    if(category == CLOTHING_LEG_CATEGORY_X)
        if(shape_key == "Y")
            switch(dir)
                if(SOUTH)
                    return list(
                    list(a,b,c,d), list(a,b,c,d), ...
                    )
                if(NORTH)
                    return null
...blocks. If someone hand-edits the file into a different shape, this will likely just fail to find the
expected markers -- re-run against a known-good version and diff rather than trying to make this parser more
lenient.
"""
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
REMAP_FILE = REPO_ROOT / "code/modules/clothing/_leg_shape_remap.dm"

CATEGORY_RE = re.compile(r'if\(category == CLOTHING_LEG_CATEGORY_(\w+)\)')
SHAPE_RE = re.compile(r'if\(shape_key == "(\w+)"\)')
DIR_RE = re.compile(r'if\((SOUTH|NORTH|EAST|WEST)\)')
ENTRY_RE = re.compile(r'list\((\d+),(\d+),(\d+),(\d+)\)')


def parse(remap_file=REMAP_FILE):
    text = Path(remap_file).read_text()

    # Split on category boundaries across the whole file (categories are now spread across multiple
    # get_leg_remap_pixels_* sub-procedures, but that doesn't matter -- category markers are still unique
    # anchors we can split on regardless of which proc they're in).
    cat_matches = list(CATEGORY_RE.finditer(text))
    tables = {}
    for i, m in enumerate(cat_matches):
        cat_name = m.group(1)
        block_start = m.end()
        block_end = cat_matches[i + 1].start() if i + 1 < len(cat_matches) else len(text)
        block = text[block_start:block_end]

        shape_matches = list(SHAPE_RE.finditer(block))
        shapes = {}
        for j, sm in enumerate(shape_matches):
            shape_key = sm.group(1)
            shape_block_start = sm.end()
            shape_block_end = shape_matches[j + 1].start() if j + 1 < len(shape_matches) else len(block)
            shape_block = block[shape_block_start:shape_block_end]

            dir_matches = list(DIR_RE.finditer(shape_block))
            dirs = {}
            for k, dm in enumerate(dir_matches):
                dir_name = dm.group(1)
                dir_block_start = dm.end()
                dir_block_end = dir_matches[k + 1].start() if k + 1 < len(dir_matches) else len(shape_block)
                dir_block = shape_block[dir_block_start:dir_block_end]
                entries = [tuple(int(v) for v in e) for e in ENTRY_RE.findall(dir_block)]
                dirs[dir_name] = entries  # empty list means "return null" (or malformed -- same effective result)

            shapes[shape_key] = dirs
        tables[cat_name] = shapes

    return tables


if __name__ == "__main__":
    import json
    import sys

    tables = parse()
    total_entries = sum(
        len(entries)
        for shapes in tables.values()
        for dirs in shapes.values()
        for entries in dirs.values()
    )
    print(f"Parsed {len(tables)} categories, {total_entries} total pixel entries.", file=sys.stderr)
    for cat, shapes in sorted(tables.items()):
        shape_summary = ", ".join(f"{sk}({sum(len(v) for v in dv.values())}px)" for sk, dv in shapes.items())
        print(f"  {cat}: {shape_summary}", file=sys.stderr)
    print(json.dumps(tables))
