# Species sprite remap pipeline

Bulk-generates species-specific on-mob clothing sprites from the hand-authored pixel-remap tables in
`code/modules/clothing/_leg_shape_remap.dm`, for species/categories that don't have (or don't fully cover) a
hand-drawn `sprite_sheets` entry. Built 2026-09-04 for a GAS (Nabber) first pass; designed to extend to other
species and to non-clothing categories (gloves, radios, other accessories) later.

## Why

Painting a full `sprite_sheets`-style spritesheet by hand for every clothing item, per species, doesn't scale.
The existing pixel-remap system (`leg_remap_category` + `get_leg_remap_pixels()`) already solves this at
*runtime* by cropping the human baseline sprite pixel-by-pixel into a species-appropriate shape, using tables
extracted from hand-painted reference art (`icons/mob/human_races/species/human/reference.dmi`) -- see that
file's own header comment for the authoring workflow. This pipeline reuses those exact same tables to
*pre-bake* the same transform once per item as a real spritesheet, wired in as a fallback, instead of paying the
Crop+Blend cost on every render. It does NOT replace the runtime remap system -- items with no generated (or
hand-drawn) coverage still fall through to it exactly as before.

## Pipeline

1. **`dm_manifest_export.dm`** (run inside the game, NOT part of the normal build -- see its own header for how
   to temporarily wire it in). Introspects every clothing/backpack item with a `leg_remap_category` set: its real
   on-mob icon+state (as a plain SPECIES_HUMAN mob would render it, before any spritesheet/remap), and whether it
   already has *any* `sprite_sheets` entry for the target species. Dumps `data/logs/remap_manifest.json`.

2. **`extract_reference_pixels.py --baseline reference-<category> --states <species>-<category> [...] --out-json
   <path>`**: reverses the color perturbation described in reference.dmi's own header comment, turning a painted
   `<species>-<category>` state into `{dir: [(sx,sy,dx,dy), ...]}` entries -- this is what actually produces the
   pixel tables that get hand-merged into `_leg_shape_remap.dm`'s `get_leg_remap_pixels_*()` procs. Handles the
   EAST/WEST mirror shortcut automatically (see its own module docstring): painting WEST by mirroring a finished
   EAST canvas keeps EAST's perturbation colors, so a match found in the opposite horizontal direction gets its
   source x-coordinate mirrored before being emitted, rather than pointing at EAST's un-mirrored source position
   (2026-09-04 fix -- this had silently broken every WEST table built via that shortcut, HELMET/SUIT included,
   until it was found and fixed). Only trustworthy against a `reference-<category>` baseline whose 4 directions
   have zero color collisions between each other -- check with a quick script before trusting a new baseline (the
   much older `reference-uniform`/`reference-jackboot`/`reference-skirt` do NOT satisfy this and need a different,
   not-yet-built approach; every other baseline as of 2026-09-04 does).

3. **`parse_remap_tables.py`**: parses `_leg_shape_remap.dm`'s `get_leg_remap_pixels_*` procs into a plain
   `{category: {shape_key: {dir: [(sx,sy,dx,dy), ...]}}}` dict, so the generator doesn't need a second,
   separately-maintained copy of the pixel data. Run standalone (`python3 parse_remap_tables.py`) to sanity-check
   what it currently sees.

4. **`generate_species_sprites.py --species <name> --manifest <path to remap_manifest.json>`**: for every
   category with both manifest entries AND a pixel table for that species, generates one `.dmi` per category
   under `icons/mob/generated/` (kept deliberately separate from hand-drawn art), covering every item that has NO
   existing species coverage at all. Items that already have *some* `sprite_sheets` entry for the species are
   skipped outright, even if that sheet doesn't cover every one of their states -- the runtime remap's own
   "does this sheet actually have this state" fallback (see `get_mob_overlay()`'s comment in `items.dm`) already
   handles those gaps; this tool only fills total blanks. Run with `--dry-run` first to preview without writing.

   Prints a DM snippet at the end -- merge it into `code/modules/clothing/_generated_sprite_sheets.dm`'s
   `GLOBAL_LIST_AS(generated_sprite_sheets, ...)` list. That's the only wiring step; no individual item's own
   `.dm` file needs editing, regardless of how many hundred items got covered.

## Adding a new species

1. Add its shape_key and bodytype (the exact string `get_bodytype()` returns for it -- usually `species.name`,
   but check the species' own `.dm` file; SPECIES_NABBER is a landmine here, see `SPECIES_BODYTYPE`'s comment in
   `generate_species_sprites.py`) to `SPECIES_SHAPE_KEY` / `SPECIES_BODYTYPE` in `generate_species_sprites.py`.
2. Make sure `_leg_shape_remap.dm` actually has pixel tables for that shape_key in the categories you care about
   (paint reference.dmi + extract, same as always, if not).
3. Re-run the manifest export if the clothing catalog has changed since the last export, then run the generator.

## Adding a new category (gloves, radios, other accessories, ...)

`dm_manifest_export.dm`'s `category_slots` list currently only covers items rendered via the plain
`/obj/item/proc/get_mob_overlay()` path (uniforms, boots, skirts, suits, helmets, back-slot bags). Accessories
(ties, insignia, rank, and future gloves-as-accessory-adjacent items) render via a DIFFERENT override in
`_accessory.dm` that requires a parent garment (`loc`) to behave correctly -- the manifest exporter doesn't
handle that yet. Add the category to `category_slots` with its correct onmob slot constant, and for accessory
categories specifically, extend the exporter to attach a temporary parent garment before calling
`get_mob_overlay()`, matching how they're actually worn.

## Known gaps from the first (GAS) pass

A handful of items (~19, logged as warnings during generation) use unusual dynamic state naming the manifest
exporter's plain-Human snapshot didn't resolve to a real state (eg gender-suffix edge cases, PT/exercise gear).
These were skipped, not guessed at -- check the generator's stderr output for `WARNING: source state not found`
lines if revisiting.
