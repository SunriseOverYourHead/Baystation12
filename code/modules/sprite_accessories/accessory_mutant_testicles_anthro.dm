// Testicles, ported from Bubberstation. "Pair" (base source) and "Pair (Alt)"/"Sheathed Pair" (modular_zubbers
// addon, genuinely different art) all share the "Testicles size" slider (size_testicles), 0-8 -- extended from the
// base source's native 0-6 since the zubbers shapes have real art up to size 8; "Pair"'s own sizes 7-8 are padded
// with a copy of its size 6 (its visible growth caps out there, an honest reflection of the base source's more
// limited range, not a bug). "Internal" is a real source choice (icon_state "none" even in Bubberstation itself)
// meaning testicles exist but aren't externally visible -- correctly renders as fully blank, not missing content.
//
// species_allowed: "Internal only" species (this session's canon matrix) simply have no species_allowed entry on
// the 3 externally-visible shapes below, leaving Internal as their only pickable option -- no separate placement
// var needed, matching how every other shape-based restriction in this matrix works (get_mutant_styles(),
// species.dm). Kharmaan wasn't given an explicit testicle rule in that matrix; defaulted to internal-only to match
// every other non-Human, non-Anthro/Machine species' own explicit rule, flagged in the session summary as an
// inference rather than a stated requirement.
/datum/sprite_accessory/mutant/testicles/anthro
	icon = 'icons/mob/species/anthro/testicles.dmi'
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/testicles/anthro/pair
	name = "Pair"
	icon_state = "pair"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/testicles/anthro/internal
	name = "Internal"
	icon_state = "internal"
	species_allowed = list(SPECIES_HUMAN, SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_YEOSA, SPECIES_NABBER, SPECIES_VOX, SPECIES_TESHARI, SPECIES_MANTID_ALATE, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/testicles/anthro/pair_alt
	name = "Pair (Alt)"
	icon_state = "pairalt"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/testicles/anthro/sheath
	name = "Sheathed Pair"
	icon_state = "sheathpair"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)
