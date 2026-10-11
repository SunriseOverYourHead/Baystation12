// Xenohead (carapace head plating) ported from NovaSector + S.P.L.U.R.T-Station-13, merged
// into one file. No overlap between the two sources for this category.
/datum/sprite_accessory/mutant/xenohead/anthro
	icon = 'icons/mob/species/anthro/xenohead.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	draw_order = 80
	// See accessory_mutant_tail_anthro.dm -- ported greyscale art needs ICON_MULTIPLY, not the base class's
	// ICON_ADD default.
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/xenohead/anthro/standard
	name = "Standard"
	icon_state = "standard"

/datum/sprite_accessory/mutant/xenohead/anthro/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/mutant/xenohead/anthro/net
	name = "Nethead"
	icon_state = "net"

/datum/sprite_accessory/mutant/xenohead/anthro/warrior
	name = "Warrior"
	icon_state = "warrior"

/datum/sprite_accessory/mutant/xenohead/anthro/hollywood
	name = "Hollywood"
	icon_state = "hollywood"

