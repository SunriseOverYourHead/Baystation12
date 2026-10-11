// A handful of tattoo designs from Bubberstation (modular_skyrat body_markings/tattoo_markings.dmi)
// that BS12SOYH's own native tattoo catalog (accessory_tattoo.dm) doesn't already have -- that catalog
// turned out to share the same source lineage (hive/nightling/campbell/tiger designs match by name),
// so only the genuinely new designs were pulled here. "Silverburgh" was dropped entirely: its only
// source art is on the legs, which this whole markings-porting pass excludes (see
// accessory_markings_anthro.dm's header comment for why).
/datum/sprite_accessory/marking/anthro/tattoo
	icon = 'icons/mob/species/anthro/markings_tattoo.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	draw_order = 60

/datum/sprite_accessory/marking/anthro/tattoo/butterfly
	name = "Tattoo - Butterfly"
	icon_state = "tat_butterfly"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tattoo/butterfly)

/datum/sprite_accessory/marking/anthro/tattoo/heart
	name = "Tattoo - Heart"
	icon_state = "tat_heart"
	body_parts = list(BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/tattoo/heart)

/datum/sprite_accessory/marking/anthro/tattoo/heart_groin
	name = "Tattoo - Heart (Groin)"
	icon_state = "tat_heart_groin"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tattoo/heart_groin)

/datum/sprite_accessory/marking/anthro/tattoo/infinity
	name = "Tattoo - Infinity"
	icon_state = "tat_infinity"
	body_parts = list(BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/tattoo/infinity)

/datum/sprite_accessory/marking/anthro/tattoo/tiger_groin
	name = "Tattoo - Tiger (Groin)"
	icon_state = "tat_tiger_groin"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tattoo/tiger_groin)

