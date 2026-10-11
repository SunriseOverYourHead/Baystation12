// Teshari -- ported from NovaSector as a new playable species. Body/eyes/husk art extracted from NovaSector's
// own greyscale bodypart sheets (see icons/mob/human_races/species/teshari/); hair, facial hair, and the
// ears/tail/fluff mutant-organ cosmetics were already ported into this codebase by an earlier session (see
// the Teshari-named entries in accessory_hair_anthro.dm, accessory_facial_hair_anthro.dm,
// accessory_mutant_ears_anthro.dm, accessory_mutant_tail_anthro.dm, accessory_mutant_fluff_anthro.dm) and are
// widened to SPECIES_TESHARI alongside this file. Digitigrade legs are baked directly into icobase (Teshari has
// no plantigrade option, unlike Anthro's toggleable leg_type), matching Unathi's own precedent.
//
// Backstory/lore/places-of-origin content is intentionally left as TODO placeholders -- real content wasn't
// asked for in this pass, see cultures_teshari.dm/factions_teshari.dm/locations_teshari.dm/religions_teshari.dm.
/singleton/species/teshari
	name = SPECIES_TESHARI
	name_plural = "Teshari"
	icobase =   'icons/mob/human_races/species/teshari/body.dmi'
	husk_icon = 'icons/mob/human_races/species/teshari/husk.dmi'
	// A placeholder (copy of Human's) until a real one is uploaded -- see icons/mob/human_races/species/
	// teshari/preview.dmi.
	preview_icon = 'icons/mob/human_races/species/teshari/preview.dmi'
	// deform/damage_overlays/damage_mask/blood_mask intentionally left unset -- no source art for these exists
	// in NovaSector's Teshari content, so they fall back to species.dm's own human defaults (matches Anthro's
	// precedent of not overriding art it has no unique source for).

	description = "TODO"
	codex_description = "TODO"
	ooc_codex_information = "TODO"
	hidden_from_codex = FALSE

	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite)
	min_age = 18
	max_age = 100
	human_equivalent_age_formula = "identity"

	// Teshari's own sheath alias (accessory_mutant_penis_anthro.dm) -- same art as "Slit", named to match their
	// canon anatomy. No default_genital_color specified for this species -- falls back to skin tone.
	force_male_sheath_mode = "Cloaca"

	spawn_flags = SPECIES_CAN_JOIN
	// Free-form skin/fur colour swatch over icobase's neutral greyscale mask, matching how Anthro's own
	// greyscale body art is tinted.
	appearance_flags = SPECIES_APPEARANCE_HAS_SKIN_COLOR | SPECIES_APPEARANCE_HAS_HAIR_COLOR | SPECIES_APPEARANCE_HAS_EYE_COLOR
	limb_blend = ICON_MULTIPLY

	flesh_color = "#c9a887"
	base_color = "#c9a887"

	// Full replacement of the base has_organ list (list vars don't merge on override in DM) -- standard organs
	// repeated explicitly, teshari/-specific eyes, plus the already-ported ears/tail/fluff mutant organs.
	has_organ = list(
		BP_HEART =    /obj/item/organ/internal/heart,
		BP_STOMACH =  /obj/item/organ/internal/stomach,
		BP_LUNGS =    /obj/item/organ/internal/lungs,
		BP_LIVER =    /obj/item/organ/internal/liver,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain,
		BP_APPENDIX = /obj/item/organ/internal/appendix,
		BP_EYES =     /obj/item/organ/internal/eyes/teshari,
		BP_EARS =     /obj/item/organ/internal/mutant/ears/teshari,
		BP_TAIL =     /obj/item/organ/internal/mutant/tail/teshari,
		BP_FLUFF =    /obj/item/organ/internal/mutant/fluff/teshari,
		BP_BREASTS =  /obj/item/organ/internal/mutant/breasts,
		BP_PENIS =    /obj/item/organ/internal/mutant/penis,
		BP_TESTICLES = /obj/item/organ/internal/mutant/testicles,
		BP_PUSSY =    /obj/item/organ/internal/mutant/vagina,
		BP_ANUS =              /obj/item/organ/internal/mutant/anus
		)

	// Teshari doesn't otherwise need a has_limbs replacement -- this just swaps in the chest/groin subtypes that
	// carry Breasts/Penis/Testicles/Vagina's pixel-offset correction for Teshari's own body proportions (see
	// code/modules/organs/external/species/teshari.dm).
	override_limb_types = list(
		BP_CHEST = /obj/item/organ/external/chest/teshari,
		BP_GROIN = /obj/item/organ/external/groin/teshari
		)

	exertion_effect_chance = 10
	exertion_hydration_scale = 1
	exertion_charge_scale = 1
	exertion_reagent_scale = 5
	exertion_reagent_path = /datum/reagent/lactate
	exertion_emotes_biological = list(
		/singleton/emote/exertion/biological,
		/singleton/emote/exertion/biological/breath,
		/singleton/emote/exertion/biological/pant
	)
	exertion_emotes_synthetic = list(
		/singleton/emote/exertion/synthetic,
		/singleton/emote/exertion/synthetic/creak
	)

	available_cultural_info = list(
		TAG_CULTURE =   list(CULTURE_TESHARI),
		TAG_HOMEWORLD = list(HOME_SYSTEM_TESHARI),
		TAG_FACTION =   list(FACTION_TESHARI),
		TAG_RELIGION =  list(RELIGION_TESHARI)
	)
