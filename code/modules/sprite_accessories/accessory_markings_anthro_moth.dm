// Moth wing/body markings ported from Bubberstation (skyrat master_files) + NovaSector, merged into one
// file. Source states are per-limb (head/chest/arms/legs, same shape as this file's own convention),
// on a 45x34 source canvas rather than the standard 32x32 -- verified by compositing directly onto
// BS12SOYH's own body.dmi that a plain top-left 32x32 crop (no offset) aligns correctly against every
// limb's actual silhouette before extracting anything. Source art is pre-colored per pattern (moth wing
// patterns each have natural coloring), not a tintable mask -- this system's own existing default
// (#000000 initial color + inherited blend = ICON_ADD) is already a no-op/identity for that, so no
// special-casing was needed here unlike Fluff's mutant-organ equivalent.
/datum/sprite_accessory/marking/anthro/moth
	icon = 'icons/mob/species/anthro/markings_moth.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	draw_order = 56

/datum/sprite_accessory/marking/anthro/moth/burnt_off
	name = "Burnt"
	icon_state = "burnt_off"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/deathhead
	name = "Deathhead"
	icon_state = "deathhead"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/firewatch
	name = "Firewatch"
	icon_state = "firewatch"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/gothic
	name = "Gothic"
	icon_state = "gothic"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/jungle
	name = "Jungle"
	icon_state = "jungle"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/lightbearer
	name = "Lightbearer"
	icon_state = "lightbearer"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/lovers
	name = "Lovers"
	icon_state = "lovers"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/moonfly
	name = "Moonfly"
	icon_state = "moonfly"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/oakworm
	name = "Oakworm"
	icon_state = "oakworm"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/poison
	name = "Poison"
	icon_state = "poison"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/ragged
	name = "Ragged"
	icon_state = "ragged"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/reddish
	name = "Reddish"
	icon_state = "reddish"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/royal
	name = "Royal"
	icon_state = "royal"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/whitefly
	name = "Whitefly"
	icon_state = "whitefly"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/sprite_accessory/marking/anthro/moth/witchwing
	name = "Witchwing"
	icon_state = "witchwing"
	body_parts = list(BP_HEAD, BP_CHEST, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)
