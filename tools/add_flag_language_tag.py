#!/usr/bin/env python3
"""
Copies a flag out of icons/flags.dmi into icons/language_tags.dmi, fitted to the chat-tag format so it sits on a
line of speech at the same height as every other language tag.

icons/flags.dmi is a 32x32 sheet of 245 ISO-coded country flags (vendored from CM13). The artwork inside each
tile is 32x22 with transparent padding; chat tags are 32x10. So the flag is cropped to its real bounds, scaled to
10px tall preserving aspect (landing around 15px wide), and centred in a 32x10 tile with transparent padding.

Name the target state after the language's `shorthand`, lowercased with non-alphanumerics stripped -- that's the
same name generate_language_tags.py derives, so the two tools agree and the text-badge generator will leave a
hand-placed flag alone instead of generating a placeholder beside it.

    python3 tools/add_flag_language_tag.py eng GB
    python3 tools/add_flag_language_tag.py esp ES

Then set `tag_icon = "eng"` on the /datum/language subtype.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from dmi_tool import load_dmi, save_dmi
from PIL import Image

TAG_W, TAG_H = 32, 10


def load_states(path):
    """Returns (width, height, [state dicts], {name: [frames]})."""
    w, h, states, sheet = load_dmi(str(path))
    cols = sheet.width // w
    tiles = {}
    for index, state in enumerate(states):
        offset = sum(s["dirs"] * s["frames"] for s in states[:index])
        frames = []
        for k in range(state["dirs"] * state["frames"]):
            n = offset + k
            col, row = n % cols, n // cols
            frames.append(sheet.crop((col * w, row * h, col * w + w, row * h + h)))
        tiles[state["name"]] = frames
    return w, h, states, tiles


def fit_flag(tile):
    """Crop a flag tile to its artwork and scale it into a 32x10 chat tag."""
    bounds = tile.getbbox()
    if not bounds:
        raise SystemExit("That flag state is empty.")
    art = tile.crop(bounds)
    height = TAG_H
    width = max(1, round(art.width * height / art.height))
    if width > TAG_W:  # a hypothetical very wide flag gets clamped rather than overflowing the tile
        width, height = TAG_W, max(1, round(art.height * TAG_W / art.width))
    small = art.resize((width, height), Image.LANCZOS)
    canvas = Image.new("RGBA", (TAG_W, TAG_H), (0, 0, 0, 0))
    canvas.paste(small, ((TAG_W - width) // 2, (TAG_H - height) // 2))
    return canvas


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: add_flag_language_tag.py <tag_state_name> <FLAG_CODE>")
    target_name, flag_code = sys.argv[1], sys.argv[2]

    repo_root = Path(__file__).parent.parent
    flags_path = repo_root / "icons" / "flags.dmi"
    tags_path = repo_root / "icons" / "language_tags.dmi"

    _, _, _, flag_tiles = load_states(flags_path)
    if flag_code not in flag_tiles:
        raise SystemExit(f"{flags_path} has no state {flag_code!r}. It is keyed by ISO country code, e.g. GB, ES, CN.")

    tag_w, tag_h, tag_states, tag_tiles = load_states(tags_path)
    if (tag_w, tag_h) != (TAG_W, TAG_H):
        raise SystemExit(f"{tags_path} is {tag_w}x{tag_h}, expected {TAG_W}x{TAG_H}.")

    fitted = fit_flag(flag_tiles[flag_code][0])
    replaced = target_name in tag_tiles

    states, tiles = [], []
    for state in tag_states:
        states.append(state)
        tiles.append([fitted] if state["name"] == target_name else tag_tiles[state["name"]])
    if not replaced:
        states.append({"name": target_name, "dirs": 1, "frames": 1,
                       "delays": None, "rewind": 0, "loop": 0, "movement": 0})
        tiles.append([fitted])

    save_dmi(str(tags_path), TAG_W, TAG_H, states, tiles)
    verb = "Replaced" if replaced else "Added"
    print(f"{verb} state {target_name!r} in {tags_path} from flag {flag_code!r}")


if __name__ == "__main__":
    main()
