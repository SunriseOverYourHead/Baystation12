// Ported from Bubberstation (icons/mob/human/species/lizard/lizard_spines.dmi).
/datum/sprite_accessory/mutant/spines/anthro
	icon = 'icons/mob/species/anthro/spines.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	// See accessory_mutant_tail_anthro.dm -- ported greyscale art needs ICON_MULTIPLY, not the base class's
	// ICON_ADD default, matching Unathi's own native spines (accessory_unathi.dm).
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/spines/anthro/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/mutant/spines/anthro/short_membrane
	name = "Short + Membrane"
	icon_state = "short_membrane"

/datum/sprite_accessory/mutant/spines/anthro/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/mutant/spines/anthro/long_membrane
	name = "Long + Membrane"
	icon_state = "long_membrane"

/datum/sprite_accessory/mutant/spines/anthro/aquatic
	name = "Aquatic"
	icon_state = "aquatic"
