// Vox tail, ported from NovaSector's "Better Vox" module (modular_nova/modules/better_vox/icons/accessories/
// vox_tail.dmi). Vox had no tail organ at all before this -- only BP_HORNS (quills) was in its has_organ list.
// Flat pre-colored art (5 fixed variants), matching how the existing Vox quill entries (accessory_vox.dm) are
// already flat-colored rather than using color_regions.
/datum/sprite_accessory/mutant/tail/vox
	icon_animation = 'icons/mob/human_races/species/vox/tail.dmi'
	species_allowed = list(SPECIES_VOX)
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/tail/vox/base
	name = "Vox Primalis Tail"
	icon_state = "vox"

/datum/sprite_accessory/mutant/tail/vox/albino
	name = "Vox Primalis Tail (Albino)"
	icon_state = "vox_albino"

/datum/sprite_accessory/mutant/tail/vox/brown
	name = "Vox Primalis Tail (Brown)"
	icon_state = "vox_brown"

/datum/sprite_accessory/mutant/tail/vox/darkteal
	name = "Vox Primalis Tail (Darkteal)"
	icon_state = "vox_darkteal"

/datum/sprite_accessory/mutant/tail/vox/yellow
	name = "Vox Primalis Tail (Yellow)"
	icon_state = "vox_yellow"
