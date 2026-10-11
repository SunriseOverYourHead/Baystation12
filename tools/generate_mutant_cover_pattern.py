#!/usr/bin/env python3
"""
Generates icons/effects/mutant_cover_pattern.dmi -- the department-colored weave that gets laid over external
organs/limbs sticking out of a themed space-proof suit or helmet (see apply_mutant_cover_pattern() in
_accessory_mutant.dm, and get_cover_theme() in _external_icons.dm).

The texture itself is PORTED ART, not generated: it's NovaSector's (originally Skyrat-tg's) MODsuit "hardlight"
mask, MOD_mask.dmi, which is what this feature is modeled on in the first place. The states are re-emitted under
this codebase's own department theme names so the DM side doesn't have to know Nova's naming, and each 1-dir
source tile is duplicated across 4 dirs to match how every organ/onmob icon here is structured.

Note the source art is deliberately semi-transparent (alpha 0/143/196) -- it's meant to be overlaid ON TOP of the
limb's natural sprite so the body reads through the weave, which is how apply_mutant_cover_pattern() composites
it. Don't "fix" the alpha to opaque; that's the look.

Source: NovaSector, modular_nova/modules/customization/modules/mob/living/carbon/human/MOD_sprite_accessories/
icons/MOD_mask.dmi (same file exists in Bubberstation under modular_skyrat/...). Upstream tg-lineage assets are
CC-BY-SA 3.0.

Run from the repo root: python3 tools/generate_mutant_cover_pattern.py [path/to/MOD_mask.dmi]
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from dmi_tool import load_dmi, save_dmi

DEFAULT_SOURCE = (
    "/home/vhbr/Projects/SS13/NovaSector/modular_nova/modules/customization/modules/mob/"
    "living/carbon/human/MOD_sprite_accessories/icons/MOD_mask.dmi"
)

# This codebase's department theme -> the Nova hardlight state whose art it borrows.
# Security/engineering follow Nova's own department mapping (and match how this feature was originally described:
# security orange, engineering teal). Supply and command are pointed at otherwise-unused states so every
# department stays visually distinct -- Nova reuses standard_blue for both medical and mining, which would make
# those two indistinguishable here.
THEME_SOURCES = {
    "generic": "standard_blue",       # Nova's own default hardlight_theme
    "security": "alert_amber",
    "medical": "standard_blue",
    "engineering": "extrashield_green",
    "science": "royal_purple",
    "supply": "hazard_orange",
    "command": "cosmic_blue",
}


def main():
    source_path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_SOURCE
    out_path = str(Path(__file__).parent.parent / "icons" / "effects" / "mutant_cover_pattern.dmi")

    width, height, src_states, sheet = load_dmi(source_path)
    by_name = {}
    for index, state in enumerate(src_states):
        offset = sum(src_states[i]["dirs"] * src_states[i]["frames"] for i in range(index))
        columns = sheet.width // width
        col, row = offset % columns, offset // columns
        by_name[state["name"]] = sheet.crop(
            (col * width, row * height, col * width + width, row * height + height)
        )

    missing = [src for src in THEME_SOURCES.values() if src not in by_name]
    if missing:
        raise SystemExit(f"Source DMI is missing expected states: {sorted(set(missing))}")

    states, tiles_per_state = [], []
    for theme, source_state in THEME_SOURCES.items():
        tile = by_name[source_state]
        states.append({
            "name": theme,
            "dirs": 4,
            "frames": 1,
            "delays": None,
            "rewind": 0,
            "loop": 0,
            "movement": 0,
        })
        # Same tile for all 4 dirs -- the weave has no directionality of its own, it just needs to Blend() 1:1
        # against whichever dir of the organ icon is being drawn.
        tiles_per_state.append([tile] * 4)

    save_dmi(out_path, width, height, states, tiles_per_state)
    print(f"Wrote {len(states)} states ({width}x{height}) to {out_path}")
    for theme, source_state in THEME_SOURCES.items():
        print(f"  {theme:<12} <- {source_state}")


if __name__ == "__main__":
    main()
