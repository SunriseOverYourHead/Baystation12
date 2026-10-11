// Xenodorsal (dorsal back-spines) ported from NovaSector (modular_nova sprite_accessory/xeno_parts.dmi --
// identical to Bubberstation's own copy of the same file, confirmed by diff). BODY_ZONE_HEAD-parented in the
// source (despite the "dorsal" name), so it slots directly into the existing head-organ rendering loop with no
// new code, same as horns/frills/spines/ears. Xenohead is a separate category, in accessory_mutant_xenohead.dm.
/datum/sprite_accessory/mutant/xenodorsal/anthro
	icon = 'icons/mob/species/anthro/xenodorsal.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	draw_order = 45
	// See accessory_mutant_tail_anthro.dm -- ported greyscale art needs ICON_MULTIPLY, not the base class's
	// ICON_ADD default.
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/xenodorsal/anthro/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/mutant/xenodorsal/anthro/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/mutant/xenodorsal/anthro/down
	name = "Dorsal Down"
	icon_state = "down"
