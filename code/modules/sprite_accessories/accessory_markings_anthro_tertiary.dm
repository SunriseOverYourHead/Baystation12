// A second, complementary detail-layer set of fur/pattern body markings from Bubberstation +
// NovaSector, merged into one file. Meant to be stacked on top of the base pattern set
// (e.g. Wolf + Wolf Spot) -- self-disallows only, doesn't disallow the base counterpart.
/datum/sprite_accessory/marking/anthro/tertiary
	icon = 'icons/mob/species/anthro/markings_tertiary.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	draw_order = 55

/datum/sprite_accessory/marking/anthro/tertiary/bat
	name = "Bat Mark"
	icon_state = "bat"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/bat)

/datum/sprite_accessory/marking/anthro/tertiary/bovine
	name = "Bovine Spot"
	icon_state = "bovine"
	body_parts = list(BP_HEAD)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/bovine)

/datum/sprite_accessory/marking/anthro/tertiary/dog
	name = "Dog Spot"
	icon_state = "dog"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/dog)

/datum/sprite_accessory/marking/anthro/tertiary/dtiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/dtiger)

/datum/sprite_accessory/marking/anthro/tertiary/eyeliner
	name = "Eyeliner"
	icon_state = "eyeliner"
	body_parts = list(BP_HEAD)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/eyeliner)

/datum/sprite_accessory/marking/anthro/tertiary/floofer
	name = "Floofer Sock"
	icon_state = "floofer"
	body_parts = list(BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/floofer)

/datum/sprite_accessory/marking/anthro/tertiary/fox
	name = "Fox Sock"
	icon_state = "fox"
	body_parts = list(BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/fox)

/datum/sprite_accessory/marking/anthro/tertiary/goat
	name = "Goat Hoof"
	icon_state = "goat"
	body_parts = list(BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/goat)

/datum/sprite_accessory/marking/anthro/tertiary/guilmon
	name = "Toraxen Mark"
	icon_state = "guilmon"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/guilmon)

/datum/sprite_accessory/marking/anthro/tertiary/hyena
	name = "Hyena Side"
	icon_state = "hyena"
	body_parts = list(BP_HEAD, BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/hyena)

/datum/sprite_accessory/marking/anthro/tertiary/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/lbelly)

/datum/sprite_accessory/marking/anthro/tertiary/ltiger
	name = "Light Tiger Body"
	icon_state = "ltiger"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/ltiger)

/datum/sprite_accessory/marking/anthro/tertiary/otie
	name = "Otie Spot"
	icon_state = "otie"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/otie)

/datum/sprite_accessory/marking/anthro/tertiary/otter
	name = "Otter Head"
	icon_state = "otter"
	body_parts = list(BP_HEAD)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/otter)

/datum/sprite_accessory/marking/anthro/tertiary/possum
	name = "Possum Sock"
	icon_state = "possum"
	body_parts = list(BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/possum)

/datum/sprite_accessory/marking/anthro/tertiary/raccoon
	name = "Raccoon Spot"
	icon_state = "raccoon"
	body_parts = list(BP_HEAD)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/raccoon)

/datum/sprite_accessory/marking/anthro/tertiary/rat
	name = "Rat Spot"
	icon_state = "rat"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/rat)

/datum/sprite_accessory/marking/anthro/tertiary/redpanda
	name = "Red Panda Head"
	icon_state = "redpanda"
	body_parts = list(BP_HEAD)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/redpanda)

/datum/sprite_accessory/marking/anthro/tertiary/scolipede
	name = "Scolipede Spikes"
	icon_state = "scolipede"
	body_parts = list(BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/scolipede)

/datum/sprite_accessory/marking/anthro/tertiary/shepherd
	name = "Shepherd Spot"
	icon_state = "shepherd"
	body_parts = list(BP_HEAD, BP_CHEST)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/shepherd)

/datum/sprite_accessory/marking/anthro/tertiary/sloth
	name = "Sloth Head"
	icon_state = "sloth"
	body_parts = list(BP_HEAD)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/sloth)

/datum/sprite_accessory/marking/anthro/tertiary/tiger
	name = "Tiger Stripe"
	icon_state = "tiger"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/tiger)

/datum/sprite_accessory/marking/anthro/tertiary/wolf
	name = "Wolf Spot"
	icon_state = "wolf"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/wolf)

/datum/sprite_accessory/marking/anthro/tertiary/xeno
	name = "Xeno Head"
	icon_state = "xeno"
	body_parts = list(BP_HEAD)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/xeno)

/datum/sprite_accessory/marking/anthro/tertiary/chem_light
	name = "Chem Light"
	icon_state = "chem_light"
	body_parts = list(BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/chem_light)

/datum/sprite_accessory/marking/anthro/tertiary/insect_trim
	name = "Insect Trim"
	icon_state = "insect_trim"
	body_parts = list(BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/tertiary/insect_trim)

