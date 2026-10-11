// Vagina, ported from Bubberstation (modular_skyrat/master_files/icons/mob/sprite_accessory/genitals/
// vagina_onmob.dmi). All 9 shape variants from the source ported (no size range for this category). Note: every
// shape in this source file only draws a single facing (SOUTH for all of them except Taur, which is NORTH-only)
// -- the extraction script falls back to that one real facing for the other 3 directions so the organ doesn't
// visually disappear when the mob turns, rather than reproducing the source's "only visible from one facing"
// behavior BS12SOYH's rendering has no equivalent concept for. See [[baystation12soyh_genitals_port_plan]] for
// the bbox-scan finding this was based on.
//
// Each shape has a second "variant" (0/1) in the source -- checked via pixel hash across all 9, and 7 of them are
// byte-identical between variants (porting both would be a wasted duplicate entry). Only 2 genuinely differ:
// Tentacle's variant 1 has real multi-directional art (variant 0 is a near-invisible dot) so it replaced variant 0
// outright as a quality fix, not a new entry; Dentata's variant 1 is a genuinely different look, ported below as
// its own style rather than replacing anything.
//
// species_allowed on each individual style below implements the canon genital matrix (per-species requirements,
// this session) -- see accessory_mutant_penis_anthro.dm's header for the mechanism (get_mutant_styles(),
// species.dm, already filters by this; Allow Non-Canon Bodyparts bypasses it).
/datum/sprite_accessory/mutant/vagina/anthro
	icon = 'icons/mob/species/anthro/vagina.dmi'
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/vagina/anthro/human
	name = "Human"
	icon_state = "human"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/gaping
	name = "Gaping"
	icon_state = "gaping"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/tentacle
	name = "Tentacle"
	icon_state = "tentacle"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/dentata
	name = "Dentata"
	icon_state = "dentata"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/dentata_alt
	name = "Dentata Alt"
	icon_state = "dentata_alt"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/hairy
	name = "Hairy"
	icon_state = "hairy"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/furred
	name = "Furred"
	icon_state = "furred"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/spade
	name = "Spade"
	icon_state = "spade"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/cloaca
	name = "Cloaca"
	icon_state = "cloaca"
	species_allowed = list(SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_YEOSA, SPECIES_NABBER, SPECIES_VOX, SPECIES_MANTID_GYNE, SPECIES_TESHARI, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/vagina/anthro/taur
	name = "Taur"
	icon_state = "taur"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)
