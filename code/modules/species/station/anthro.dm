// New species built as the dedicated home for this session's ported anthro-pool content (tails, horns, frills,
// spines, ears, xenodorsal, xenohead, wings, and the ~250 body-marking fur patterns) -- previously all of this
// was gated behind Unathi purely as a matter of engineering convenience while it was being built. Modeled on
// NovaSector/Bubberstation's own "Anthromorph" species (id SPECIES_MAMMAL there), which turned out to have no
// unique body art of its own either -- confirmed by reading its source directly: no icobase/deform/husk_icon/
// preview_icon anywhere in its datum, it reuses the same body silhouette as every other mammal-shaped species
// and gets its distinct look purely from default accessory picks + a randomized fur palette. This species used
// to do the same thing here (reusing Human's own body.dmi wholesale), but that shared file was reverted back to
// Human's original art -- Anthro now points icobase at its own body_greyscale.dmi (same folder, same 16-state
// layout) so it can carry a true neutral-mask body while Human keeps its native sprites. Built as a base class
// specifically so subspecies can be added later the same way SPECIES_GRAVWORLDER/SPACER/VATGROWN/TRITONIAN
// subclass human in human_subspecies.dm -- plain DM inheritance, no separate "subspecies system" to opt into.
/singleton/species/anthro
	name = SPECIES_ANTHRO
	name_plural = "Anthros"
	primitive_form = "Monkey"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite)
	description = "A broad, catch-all designation for uplifted and heavily gene-modded people whose forms draw \
	on countless different animal ancestries -- no two are quite alike. What they share is a body plan close \
	enough to baseline human stock that the same equipment, medicine, and quarters serve them all, alongside a \
	wide array of inheritable mutant features: tails, horns, frills, spines, ears, and more besides."
	assisted_langs = list(LANGUAGE_NABBER)
	min_age = 18
	max_age = 100
	human_equivalent_age_formula = "identity"
	hidden_from_codex = FALSE
	bandages_icon = 'icons/mob/bandage.dmi'
	default_genital_color = "#A84040"

	spawn_flags = SPECIES_CAN_JOIN
	// Free-form skin_color swatch, explicitly requested over Human's discrete preset tones -- lets Anthros
	// actually look distinct (blue fur, purple skin, etc) via ICON_MULTIPLY (below) over icobase's neutral mask.
	appearance_flags = SPECIES_APPEARANCE_HAS_HAIR_COLOR | SPECIES_APPEARANCE_HAS_SKIN_COLOR | SPECIES_APPEARANCE_HAS_LIPS | SPECIES_APPEARANCE_HAS_UNDERWEAR | SPECIES_APPEARANCE_HAS_EYE_COLOR | SPECIES_APPEARANCE_HAS_LEG_TYPE
	limb_blend = ICON_MULTIPLY
	icobase = 'icons/mob/human_races/species/human/body_greyscale.dmi'
	// A placeholder (copy of Human's) until a real one is uploaded -- see icons/mob/human_races/species/
	// anthro/preview.dmi.
	preview_icon = 'icons/mob/human_races/species/anthro/preview.dmi'

	flesh_color = "#c9a887"
	base_color = "#c9a887"

	sexybits_location = BP_GROIN

	inherent_verbs = list(/mob/living/carbon/human/proc/tie_hair)

	// NOTE: has_organ is a full REPLACEMENT of the base /singleton/species default (list vars don't merge on
	// override in DM), so the normal vital organs have to be repeated here explicitly alongside the new mutant
	// ones -- omitting them would spawn Anthro characters with no heart/lungs/brain/etc. Matches the base
	// class's own default set (species.dm) plus every mutant-organ category this species has access to.
	has_organ = list(
		BP_HEART =    /obj/item/organ/internal/heart,
		BP_STOMACH =  /obj/item/organ/internal/stomach,
		BP_LUNGS =    /obj/item/organ/internal/lungs,
		BP_LIVER =    /obj/item/organ/internal/liver,
		BP_KIDNEYS =  /obj/item/organ/internal/kidneys,
		BP_BRAIN =    /obj/item/organ/internal/brain,
		BP_APPENDIX = /obj/item/organ/internal/appendix,
		BP_EYES =     /obj/item/organ/internal/eyes,
		BP_TAIL =       /obj/item/organ/internal/mutant/tail,
		BP_HORNS =      /obj/item/organ/internal/mutant/horns,
		BP_FRILLS =     /obj/item/organ/internal/mutant/frills,
		BP_SPINES =     /obj/item/organ/internal/mutant/spines,
		BP_EARS =       /obj/item/organ/internal/mutant/ears,
		BP_XENODORSAL = /obj/item/organ/internal/mutant/xenodorsal,
		BP_XENOHEAD =   /obj/item/organ/internal/mutant/xenohead,
		BP_WINGS =      /obj/item/organ/internal/mutant/wings,
		BP_SNOUT =            /obj/item/organ/internal/mutant/snout,
		BP_MOTH_ANTENNAE =    /obj/item/organ/internal/mutant/moth_antennae,
		BP_FLUFF =            /obj/item/organ/internal/mutant/fluff,
		BP_BREASTS =          /obj/item/organ/internal/mutant/breasts,
		BP_PENIS =            /obj/item/organ/internal/mutant/penis,
		BP_TESTICLES =        /obj/item/organ/internal/mutant/testicles,
		BP_PUSSY =            /obj/item/organ/internal/mutant/vagina,
		BP_ANUS =              /obj/item/organ/internal/mutant/anus
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

	show_age_to_other_species = TRUE

/singleton/species/anthro/get_bodytype(mob/living/carbon/human/H)
	return SPECIES_ANTHRO
