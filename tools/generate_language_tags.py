#!/usr/bin/env python3
"""
Generates icons/language_tags.dmi -- the little coloured badges shown beside speech in chat to indicate which
language was spoken. See /datum/language/proc/get_chat_tag() (code/modules/mob/language/language.dm).

These are deliberately drawn in the same style as the existing icons/chattags.dmi badges (OOC / LOOC / DEAD /
etc): 32x10, rounded corners, flat colour fill, chunky pixel lettering. The text is each language's own
`shorthand`, which is what chat already printed before icons existed -- so a badge and its text fallback always
say the same thing.

The generated badges are only a placeholder for languages nobody has drawn art for yet. This script is
ADDITIVE: it never touches a state that already exists in the .dmi, so hand-drawn art -- a real country flag for
a human language, a custom emblem for an alien one -- survives re-runs. To regenerate a badge, delete that state
first. The DM side only ever looks up a state name, so what the art actually is doesn't matter to it.

Adding a flag by hand:
  1. Draw a 32x10 state in icons/language_tags.dmi, named however you like.
  2. Set `tag_icon = "<that state>"` on the /datum/language subtype.
That's the whole process -- get_chat_tag() picks it up, and languages without one keep showing text.

Run from the repo root: python3 tools/generate_language_tags.py
"""
import hashlib
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from dmi_tool import load_dmi, save_dmi
from PIL import Image

WIDTH, HEIGHT = 32, 10

# 3x5 pixel font. Small enough that a 5-character shorthand still fits inside 32px with margins, chunky enough
# to stay legible at native zoom. Each glyph is 5 rows of 3 columns.
GLYPHS = {
    "A": ["010", "101", "111", "101", "101"],
    "B": ["110", "101", "110", "101", "110"],
    "C": ["011", "100", "100", "100", "011"],
    "D": ["110", "101", "101", "101", "110"],
    "E": ["111", "100", "110", "100", "111"],
    "F": ["111", "100", "110", "100", "100"],
    "G": ["011", "100", "101", "101", "011"],
    "H": ["101", "101", "111", "101", "101"],
    "I": ["111", "010", "010", "010", "111"],
    "J": ["001", "001", "001", "101", "010"],
    "K": ["101", "110", "100", "110", "101"],
    "L": ["100", "100", "100", "100", "111"],
    "M": ["101", "111", "111", "101", "101"],
    "N": ["101", "111", "111", "111", "101"],
    "O": ["010", "101", "101", "101", "010"],
    "P": ["110", "101", "110", "100", "100"],
    "Q": ["010", "101", "101", "111", "011"],
    "R": ["110", "101", "110", "101", "101"],
    "S": ["011", "100", "010", "001", "110"],
    "T": ["111", "010", "010", "010", "010"],
    "U": ["101", "101", "101", "101", "111"],
    # Tapers a row earlier than U does -- at 3px wide the two are otherwise near-identical and "VOX" reads "UOX".
    "V": ["101", "101", "101", "010", "010"],
    "W": ["101", "101", "111", "111", "101"],
    "X": ["101", "101", "010", "101", "101"],
    "Y": ["101", "101", "010", "010", "010"],
    "Z": ["111", "001", "010", "100", "111"],
    "0": ["111", "101", "101", "101", "111"],
    "1": ["010", "110", "010", "010", "111"],
    "2": ["110", "001", "010", "100", "111"],
    "3": ["110", "001", "010", "001", "110"],
    "4": ["101", "101", "111", "001", "001"],
    "5": ["111", "100", "110", "001", "110"],
    "6": ["011", "100", "111", "101", "111"],
    "7": ["111", "001", "010", "010", "010"],
    "8": ["111", "101", "111", "101", "111"],
    "9": ["111", "101", "111", "001", "110"],
    "'": ["010", "010", "000", "000", "000"],
    "-": ["000", "000", "111", "000", "000"],
    " ": ["000", "000", "000", "000", "000"],
}

GLYPH_W, GLYPH_H, GLYPH_GAP = 3, 5, 1


def badge_color(key):
    """Stable, readable fill colour derived from the shorthand, so a language always gets the same badge."""
    digest = hashlib.md5(key.encode("utf-8")).digest()
    hue = digest[0] / 255.0
    # Fixed saturation/value keeps every badge dark enough for white lettering to stay legible.
    import colorsys
    r, g, b = colorsys.hsv_to_rgb(hue, 0.62, 0.58)
    return (int(r * 255), int(g * 255), int(b * 255), 255)


def draw_text(img, text, color=(255, 255, 255, 255)):
    glyphs = [GLYPHS[c] for c in text if c in GLYPHS]
    if not glyphs:
        return
    text_w = len(glyphs) * GLYPH_W + (len(glyphs) - 1) * GLYPH_GAP
    x0 = (WIDTH - text_w) // 2
    y0 = (HEIGHT - GLYPH_H) // 2
    px = img.load()
    for gi, glyph in enumerate(glyphs):
        gx = x0 + gi * (GLYPH_W + GLYPH_GAP)
        for row in range(GLYPH_H):
            for col in range(GLYPH_W):
                if glyph[row][col] == "1":
                    x, y = gx + col, y0 + row
                    if 0 <= x < WIDTH and 0 <= y < HEIGHT:
                        px[x, y] = color


def build_badge(shorthand):
    img = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    fill = badge_color(shorthand)
    px = img.load()
    for y in range(HEIGHT):
        for x in range(WIDTH):
            # Clip the four corner pixels for the same softened-rectangle look the existing chat tags have.
            corner = (x in (0, WIDTH - 1)) and (y in (0, HEIGHT - 1))
            if not corner:
                px[x, y] = fill
    draw_text(img, shorthand.upper())
    return img


def collect_languages(repo_root):
    """Pair each /datum/language subtype's shorthand with its state name. Mirrors the DM side's tag_icon values."""
    defines = {}
    defines_path = repo_root / "code" / "__defines" / "languages.dm"
    for m in re.finditer(r'#define\s+(LANGUAGE_\w+)\s+"([^"]+)"', defines_path.read_text(errors="replace")):
        defines[m.group(1)] = m.group(2)

    found = {}
    for path in (repo_root / "code" / "modules" / "mob" / "language").rglob("*.dm"):
        src = path.read_text(errors="replace")
        for block in re.split(r"(?m)^(?=/datum/language)", src):
            if not block.startswith("/datum/language"):
                continue
            sh = re.search(r'(?m)^\s*shorthand\s*=\s*"([^"]+)"', block)
            if not sh or sh.group(1) in ("???", "N/A"):
                continue
            found[sh.group(1)] = True
    return sorted(found)


def main():
    repo_root = Path(__file__).parent.parent
    out = repo_root / "icons" / "language_tags.dmi"
    shorthands = collect_languages(repo_root)

    # Existing states are preserved verbatim, and only missing ones get a generated text badge. Hand-drawn art --
    # a real country flag for a human language, a custom emblem for an alien one -- is the whole point of this
    # sheet; regenerating must never clobber it. Delete a state (or the file) to have it regenerated.
    existing_states, existing_tiles = [], []
    if out.exists():
        src_w, src_h, src_states, sheet = load_dmi(str(out))
        if (src_w, src_h) != (WIDTH, HEIGHT):
            raise SystemExit(
                f"{out} is {src_w}x{src_h}, expected {WIDTH}x{HEIGHT}. Refusing to rewrite it at a different size."
            )
        cols = sheet.width // src_w
        for index, state in enumerate(src_states):
            offset = sum(s["dirs"] * s["frames"] for s in src_states[:index])
            frames = []
            for k in range(state["dirs"] * state["frames"]):
                n = offset + k
                col, row = n % cols, n // cols
                frames.append(sheet.crop((col * src_w, row * src_h, col * src_w + src_w, row * src_h + src_h)))
            existing_states.append(state)
            existing_tiles.append(frames)

    have = {s["name"] for s in existing_states}
    states, tiles = list(existing_states), list(existing_tiles)
    added = []
    for sh in shorthands:
        name = state_name(sh)
        if name in have:
            continue
        states.append({
            "name": name,
            "dirs": 1, "frames": 1, "delays": None, "rewind": 0, "loop": 0, "movement": 0,
        })
        tiles.append([build_badge(sh)])
        added.append((name, sh))

    if not added:
        print(f"{out}: all {len(shorthands)} language tags already present, nothing to generate.")
        return

    save_dmi(str(out), WIDTH, HEIGHT, states, tiles)
    print(f"Wrote {out} -- {len(added)} generated, {len(existing_states)} kept as-is ({WIDTH}x{HEIGHT})")
    for name, sh in added:
        print(f"  + {name:<10} <- shorthand {sh!r}")


def state_name(shorthand):
    """Icon state names are lowercased shorthands with non-alphanumerics stripped, so they're safe DM strings."""
    return re.sub(r"[^a-z0-9]", "", shorthand.lower())


if __name__ == "__main__":
    main()
