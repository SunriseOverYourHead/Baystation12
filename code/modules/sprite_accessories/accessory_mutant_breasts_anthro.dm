// Breasts, ported from Bubberstation (modular_skyrat/master_files/icons/mob/sprite_accessory/genitals/breasts_onmob.dmi).
// All 3 shapes from the source ported (Pair/Quad/Sextuple); size is driven by the "Breasts size" slider
// (size_breasts in preferences_tgui.dm/species_features.tsx), not separate named styles -- build_colored_icon()
// appends the chosen size directly to icon_state ("pair" + size 4 -> "pair4_s"). Quad/Sextuple only have real
// source art for sizes 0-5 (vs Pair's full 0-16) -- sizes 6-16 are padded with a copy of size 5's art so the
// shared size slider always resolves to a valid state for every shape (that shape's visible growth just caps out
// there, an honest reflection of the source's limited content for these two, not a bug).
//
// species_allowed: per this session's canon matrix, breasts are Human/Anthro/Machine-only -- every other species
// explicitly has "no breasts" as its first canon rule (Kharmaan included), overriding the general "both genital
// sets choosable for they/them or it/its gender" rule for this one category specifically.
/datum/sprite_accessory/mutant/breasts/anthro
	icon = 'icons/mob/species/anthro/breasts.dmi'
	// Ported art is a greyscale mask (see accessory_mutant_tail_anthro.dm/accessory_unathi.dm precedent) -- needs
	// ICON_MULTIPLY to tint toward skin_color, not the base class's ICON_ADD default.
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/breasts/anthro/pair
	name = "Pair"
	icon_state = "pair"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/breasts/anthro/quad
	name = "Quad"
	icon_state = "quad"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/breasts/anthro/sextuple
	name = "Sextuple"
	icon_state = "sextuple"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)
