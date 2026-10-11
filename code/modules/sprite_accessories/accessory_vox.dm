// The 4 quill styles below don't fit Better Vox's new head shape (see body.dmi, ported into
// icons/mob/human_races/species/vox/body.dmi) -- species_allowed on each points at a sentinel no real species
// ever matches, so they're excluded from every species' style picker (see the `S.species_allowed && !(...)`
// filter in preferences_tgui.dm) without deleting the datums outright, which would corrupt any savefile that
// already has one selected (see the warning at the top of _accessory.dm). Every entry below needs its own
// explicit species_allowed override rather than relying on the shared parent, since the 12 newer entries further
// down are also subtypes of this same parent and must stay selectable.
/datum/sprite_accessory/mutant/horns/vox
	name = "Long Vox Quills"
	icon = 'icons/mob/human_races/species/vox/hair.dmi'
	icon_state = "vox_longquills"
	species_allowed = list("_deprecated_no_species_")

/datum/sprite_accessory/mutant/horns/vox/short
	name = "Short Vox Quills"
	icon_state = "vox_shortquills"
	species_allowed = list("_deprecated_no_species_")

/datum/sprite_accessory/mutant/horns/vox/mohawk
	name = "Vox Mohawk"
	icon_state = "vox_mohawk"
	species_allowed = list("_deprecated_no_species_")

/datum/sprite_accessory/mutant/horns/vox/stubble
	name = "Vox Stubble"
	icon_state = "vox_stubble"
	species_allowed = list("_deprecated_no_species_")

// Ported from NovaSector's "Better Vox" module (modular_nova/modules/better_vox/icons/accessories/vox_hair.dmi)
// -- "vox_shortquills_s" duplicates the existing Short Vox Quills entry above and was skipped. These fit the new
// head shape, so each needs its own explicit species_allowed (the shared parent above is now deprecated).
/datum/sprite_accessory/mutant/horns/vox/razor
	name = "Vox Razor Quills"
	icon_state = "vox_razor"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/kingly
	name = "Vox Kingly Quills"
	icon_state = "vox_kingly"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/punk
	name = "Vox Punk Quills"
	icon_state = "vox_punk"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/bayonet
	name = "Vox Bayonet Quills"
	icon_state = "vox_bayonet"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/rome
	name = "Vox Roman Quills"
	icon_state = "vox_rome"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/kinglyq
	name = "Vox Kingly Quills (Long)"
	icon_state = "vox_kinglyq"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/whip
	name = "Vox Whip Quills"
	icon_state = "vox_whip"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/long
	name = "Vox Long Quills (Alt)"
	icon_state = "vox_long"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/classic
	name = "Vox Classic Quills"
	icon_state = "vox_classic"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/dreads
	name = "Vox Quill Dreads"
	icon_state = "vox_dreads"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/long_dreads
	name = "Vox Quill Dreads (Long)"
	icon_state = "vox_long_dreads"
	species_allowed = list(SPECIES_VOX)

/datum/sprite_accessory/mutant/horns/vox/kingly_dreads
	name = "Vox Kingly Quill Dreads"
	icon_state = "vox_kingly_dreads"
	species_allowed = list(SPECIES_VOX)
