// Centralized fallback for bulk-generated species sprites (tools/species_remap/generate_species_sprites.py).
// Keyed exactly like an item's own sprite_sheets var (bodytype -> icon file), but one level up by
// leg_remap_category, since one generated file covers every item in a category rather than needing an edit per
// item. get_mob_overlay() (items.dm) and the accessory override (_accessory.dm) both consult this AFTER their
// own per-item/inherited sprite_sheets check comes up empty, and only for a bodytype+category combo that's
// actually been generated -- items with their own (even partial) sprite_sheets entry are untouched, since the
// existing "does this sheet actually have this state" fallback (see get_mob_overlay()'s own comment) already
// covers gaps in those. Regenerate/extend this list by re-running the generator script; it prints the exact
// snippet to merge in.
GLOBAL_LIST_AS(generated_sprite_sheets, list(
	CLOTHING_LEG_CATEGORY_BACKPACK = list(SPECIES_TESHARI = 'icons/mob/generated/onmob_backpack_teshari.dmi'),
	CLOTHING_LEG_CATEGORY_BOOTS = list(SPECIES_TESHARI = 'icons/mob/generated/onmob_boots_teshari.dmi'),
	CLOTHING_LEG_CATEGORY_DUFFLEBAG = list(SPECIES_TESHARI = 'icons/mob/generated/onmob_dufflebag_teshari.dmi'),
	CLOTHING_LEG_CATEGORY_HELMET = list(
		SPECIES_NABBER = 'icons/mob/generated/onmob_helmet_gas.dmi',
		SPECIES_TESHARI = 'icons/mob/generated/onmob_helmet_teshari.dmi',
	),
	CLOTHING_LEG_CATEGORY_MESSENGERBAG = list(SPECIES_TESHARI = 'icons/mob/generated/onmob_messengerbag_teshari.dmi'),
	CLOTHING_LEG_CATEGORY_PANTS = list(
		SPECIES_NABBER = 'icons/mob/generated/onmob_pants_gas.dmi',
		SPECIES_TESHARI = 'icons/mob/generated/onmob_pants_teshari.dmi',
	),
	CLOTHING_LEG_CATEGORY_POCKETBOOK = list(SPECIES_TESHARI = 'icons/mob/generated/onmob_pocketbook_teshari.dmi'),
	CLOTHING_LEG_CATEGORY_RUCKSACK = list(SPECIES_TESHARI = 'icons/mob/generated/onmob_rucksack_teshari.dmi'),
	CLOTHING_LEG_CATEGORY_SATCHEL = list(SPECIES_TESHARI = 'icons/mob/generated/onmob_satchel_teshari.dmi'),
	CLOTHING_LEG_CATEGORY_SKIRT = list(
		SPECIES_NABBER = 'icons/mob/generated/onmob_skirt_gas.dmi',
		SPECIES_TESHARI = 'icons/mob/generated/onmob_skirt_teshari.dmi',
	),
	CLOTHING_LEG_CATEGORY_SUIT = list(
		SPECIES_NABBER = 'icons/mob/generated/onmob_suit_gas.dmi',
		SPECIES_TESHARI = 'icons/mob/generated/onmob_suit_teshari.dmi',
	),
))
