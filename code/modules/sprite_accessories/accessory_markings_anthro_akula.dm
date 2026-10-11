// Akula (shark-person) body markings ported from Bubberstation (modular_skyrat body_markings/akula_markings.dmi).
// No matching species exists in BS12SOYH's roster, kept in the free anthro pool like everything else this session.
/datum/sprite_accessory/marking/anthro/akula
	icon = 'icons/mob/species/anthro/markings_akula.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	draw_order = 55


/datum/sprite_accessory/marking/anthro/akula/akula
	name = "Akula"
	icon_state = "akula"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM, BP_R_HAND, BP_L_HAND)
	disallows = list(/datum/sprite_accessory/marking/anthro/akula/akula)

/datum/sprite_accessory/marking/anthro/akula/akula_highlight
	name = "Akula Highlight"
	icon_state = "akula_highlight"
	body_parts = list(BP_HEAD, BP_CHEST, BP_R_ARM, BP_L_ARM)
	disallows = list(/datum/sprite_accessory/marking/anthro/akula/akula_highlight)

