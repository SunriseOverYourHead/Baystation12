// Vox-specific body markings ported from Bubberstation (modular_skyrat body_markings/vox_secondary.dmi +
// vox_tertiary.dmi). Unlike akula/synthliz, Vox IS an existing BS12SOYH species, so these are restricted
// to it (matching the source's own recommended_species) rather than added to the free anthro pool.
/datum/sprite_accessory/marking/anthro/vox
	icon = 'icons/mob/species/anthro/markings_vox_sec.dmi'
	species_allowed = list(SPECIES_VOX)
	draw_order = 55


/datum/sprite_accessory/marking/anthro/vox/vox
	name = "Vox Talon"
	icon_state = "vox"
	body_parts = list(BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/vox)

/datum/sprite_accessory/marking/anthro/vox/tertiary
	icon = 'icons/mob/species/anthro/markings_vox_ter.dmi'


/datum/sprite_accessory/marking/anthro/vox/tertiary/voxheart
	name = "Vox Heart Tattoo"
	icon_state = "voxheart"
	body_parts = list(BP_R_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/tertiary/voxheart)

/datum/sprite_accessory/marking/anthro/vox/tertiary/voxhive
	name = "Vox Hive Tattoo"
	icon_state = "voxhive"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/tertiary/voxhive)

/datum/sprite_accessory/marking/anthro/vox/tertiary/voxnightling
	name = "Vox Nightling Tattoo"
	icon_state = "voxnightling"
	body_parts = list(BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/tertiary/voxnightling)

/datum/sprite_accessory/marking/anthro/vox/tertiary/voxtiger
	name = "Vox Tiger Tattoo"
	icon_state = "voxtiger"
	body_parts = list(BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/tertiary/voxtiger)

// Vox Primalis clan/role markings, ported from NovaSector's "Better Vox" module (modular_nova/modules/
// better_vox/icons/accessories/vox_bodymarkings.dmi).
/datum/sprite_accessory/marking/anthro/vox/body
	icon = 'icons/mob/species/anthro/markings_vox_body.dmi'

/datum/sprite_accessory/marking/anthro/vox/body/leader
	name = "Vox Leader Marking"
	icon_state = "leader"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/body/leader)

/datum/sprite_accessory/marking/anthro/vox/body/drone
	name = "Vox Drone Marking"
	icon_state = "drone"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/body/drone)

/datum/sprite_accessory/marking/anthro/vox/body/reaver
	name = "Vox Reaver Marking"
	icon_state = "reaver"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/body/reaver)

/datum/sprite_accessory/marking/anthro/vox/body/raider
	name = "Vox Raider Marking"
	icon_state = "raider"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/body/raider)

/datum/sprite_accessory/marking/anthro/vox/body/larva
	name = "Vox Larva Marking"
	icon_state = "larva"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/body/larva)

/datum/sprite_accessory/marking/anthro/vox/body/scavenger
	name = "Vox Scavenger Marking"
	icon_state = "scavenger"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/body/scavenger)

/datum/sprite_accessory/marking/anthro/vox/body/servirtor
	name = "Vox Servirtor Marking"
	icon_state = "servirtor"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/vox/body/servirtor)

