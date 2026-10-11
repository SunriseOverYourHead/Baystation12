/singleton/species/mantid

	name =                   SPECIES_MANTID_ALATE
	name_plural =            "Kharmaan Alates"
	show_ssd =               "quiescent"
	hidden_from_codex =      FALSE

	description = "When human explorers finally arrived at the outer reaches of Skrellian space, they hoped to find \
	new frontiers and new planets to exploit. They were largely not expecting to have entire expeditions lost \
	amid reports of highly advanced, astonishingly violent mantid-cephlapodean sentients with particle cannons."

	preview_icon =            'icons/mob/human_races/species/ascent/alate/preview.dmi'
	icobase =                 'icons/mob/human_races/species/ascent/alate/body.dmi'
	deform =                  'icons/mob/human_races/species/ascent/alate/body.dmi'
	damage_overlays =         'icons/mob/human_races/species/ascent/alate/damage_mask.dmi'
	blood_mask =              'icons/mob/human_races/species/ascent/alate/blood_mask.dmi'
	organs_icon =             'icons/mob/human_races/species/ascent/organs.dmi'

	blood_color =             "#660066"
	flesh_color =             "#009999"
	hud_type =                /datum/hud_data/mantid
	move_trail =              /obj/decal/cleanable/blood/tracks/snake

	speech_chance = 100
	speech_sounds = list(
		'sound/voice/ascent1.ogg',
		'sound/voice/ascent2.ogg',
		'sound/voice/ascent3.ogg',
		'sound/voice/ascent4.ogg',
		'sound/voice/ascent5.ogg',
		'sound/voice/ascent6.ogg'
	)

	siemens_coefficient =   0.2 // Crystalline body.
	oxy_mod =               0.8 // Don't need as much breathable gas as humans.
	toxins_mod =            0.4 // Not as biologically fragile as meatboys.
	radiation_mod =         0.4 // Not as biologically fragile as meatboys.
	flash_mod =               2 // Highly photosensitive.
	brute_mod =             1.5 // Incredibly fragile.

	min_age =                18
	max_age =                38
	// Same human-equivalent scaling as Gyne (default "linear") -- "quadruple" (GAS's rate) was tried and
	// rejected: it puts an 18-year-old (the youngest playable) Alate at human-equivalent 72, clearly wrong.
	slowdown =               0.5
	rarity_value =            3
	gluttonous =              2
	siemens_coefficient =     0
	body_temperature =        null

	breath_type =             GAS_METHYL_BROMIDE
	exhale_type =             GAS_METHANE
	poison_types =            list(GAS_PHORON)

	force_male_sheath_mode =  "Slit"
	default_genital_color =  "#FFE400"

	genders =                 list(MALE)

	appearance_flags =        0
	species_flags =           SPECIES_FLAG_NO_SCAN  | SPECIES_FLAG_NO_SLIP        | SPECIES_FLAG_NO_MINOR_CUT
	spawn_flags =             SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN

	heat_discomfort_strings = list(
		"You feel brittle and overheated.",
		"Your overheated carapace flexes uneasily.",
		"Overheated ichor trickles from your eyes."
		)
	cold_discomfort_strings = list(
		"Frost forms along your carapace.",
		"You hear a faint crackle of ice as you shift your freezing body.",
		"Your movements become sluggish under the weight of the chilly conditions."
		)
	unarmed_types = list(
		/datum/unarmed_attack/claws/strong/gloves,
		/datum/unarmed_attack/bite/sharp
	)

	// BP_GROIN moved after the legs -- see species.dm's has_limbs comment.
	has_limbs = list(
		BP_CHEST =  list("path" = /obj/item/organ/external/chest/insectoid/mantid),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/insectoid),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/insectoid),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/insectoid),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/insectoid),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/insectoid),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/insectoid),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/insectoid),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/insectoid/mantid),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/insectoid),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/insectoid)
	)

	has_organ = list(
		BP_HEART =             /obj/item/organ/internal/heart/insectoid,
		BP_STOMACH =           /obj/item/organ/internal/stomach/insectoid,
		BP_LUNGS =             /obj/item/organ/internal/lungs/insectoid,
		BP_LIVER =             /obj/item/organ/internal/liver/insectoid,
		BP_KIDNEYS =           /obj/item/organ/internal/kidneys/insectoid,
		BP_BRAIN =             /obj/item/organ/internal/brain/insectoid,
		BP_EYES =              /obj/item/organ/internal/eyes/insectoid,
		BP_SYSTEM_CONTROLLER = /obj/item/organ/internal/controller,
		BP_BREASTS =           /obj/item/organ/internal/mutant/breasts,
		BP_PENIS =             /obj/item/organ/internal/mutant/penis,
		BP_TESTICLES =         /obj/item/organ/internal/mutant/testicles,
		BP_PUSSY =             /obj/item/organ/internal/mutant/vagina,
		BP_ANUS =              /obj/item/organ/internal/mutant/anus
	)

	force_cultural_info = list(
		TAG_CULTURE =   CULTURE_ASCENT,
		TAG_HOMEWORLD = HOME_SYSTEM_KHARMAANI,
		TAG_FACTION =   FACTION_ASCENT_ALATE,
		TAG_RELIGION =  RELIGION_KHARMAANI
	)

	descriptors = list(
		/datum/mob_descriptor/height = -1,
		/datum/mob_descriptor/body_length = -2
		)

	pain_emotes_with_pain_level = list(
			list(/singleton/emote/visible/ascent_shine, /singleton/emote/visible/ascent_dazzle) = 80,
			list(/singleton/emote/visible/ascent_glimmer, /singleton/emote/visible/ascent_pulse) = 50,
			list(/singleton/emote/visible/ascent_flicker, /singleton/emote/visible/ascent_glint) = 20,
		)

/singleton/species/mantid/handle_sleeping(mob/living/carbon/human/H)
	return

/singleton/species/mantid/get_blood_name()
	return "hemolymph"

/singleton/species/mantid/post_organ_rejuvenate(obj/item/organ/org, mob/living/carbon/human/H)
	org.status |= ORGAN_CRYSTAL

/singleton/species/mantid/equip_survival_gear(mob/living/carbon/human/H, extendedtank = 1)
	return

/singleton/species/mantid/gyne

	name =                    SPECIES_MANTID_GYNE
	name_plural =             "Kharmaan Gynes"
	hidden_from_codex =       FALSE
	spawn_flags =             SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN

	genders =                 list(FEMALE)
	preview_icon =            'icons/mob/human_races/species/ascent/gyne/preview.dmi'
	icobase =                 'icons/mob/human_races/species/ascent/gyne/body.dmi'
	deform =                  'icons/mob/human_races/species/ascent/gyne/body.dmi'
	icon_template =           'icons/mob/human_races/species/ascent/gyne/template.dmi'
	damage_overlays =         'icons/mob/human_races/species/ascent/gyne/damage_mask.dmi'
	blood_mask =              'icons/mob/human_races/species/ascent/gyne/blood_mask.dmi'

	gluttonous =              3
	slowdown =                2
	rarity_value =           10
	min_age =                18
	max_age =               500
	// Closer to Unathi than to Alate -- explicit user direction (overrides Alate's own "quadruple" back to the
	// default linear stretch, since a plain proc override can't express "fall back to grandparent behavior").
	human_equivalent_age_formula = "linear"
	blood_volume =         1200
	spawns_with_stack =       0

	pixel_offset_x =        -4
	antaghud_offset_y =      18
	antaghud_offset_x =      4

	bump_flag =               HEAVY
	push_flags =              ALLMOBS
	swap_flags =              ALLMOBS

	override_limb_types = list(
		BP_HEAD = /obj/item/organ/external/head/insectoid/mantid,
		BP_CHEST = /obj/item/organ/external/chest/insectoid/mantid/gyne,
		BP_GROIN = /obj/item/organ/external/groin/insectoid/mantid/gyne
	)

	descriptors = list(
		/datum/mob_descriptor/height = 5,
		/datum/mob_descriptor/body_length = 2
	)

	force_cultural_info = list(
		TAG_CULTURE =   CULTURE_ASCENT,
		TAG_HOMEWORLD = HOME_SYSTEM_KHARMAANI,
		TAG_FACTION =   FACTION_ASCENT_GYNE,
		TAG_RELIGION =  RELIGION_KHARMAANI
	)

/singleton/species/mantid/gyne/attempt_grab(mob/living/carbon/human/grabber, atom/movable/target, grab_type)
	if(grabber != target)
		grabber.unEquip(grabber.l_hand)
		grabber.unEquip(grabber.r_hand)
		to_chat(grabber, SPAN_WARNING("You drop everything as you seize \the [target]!"))
		playsound(grabber.loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
	. = ..(grabber, target, GRAB_NAB)

/singleton/species/mantid/gyne/New()
	equip_adjust = list(
		slot_l_hand_str = list(
			"[NORTH]" = list("x" = -4, "y" = 12),
			"[EAST]" = list("x" =  -4, "y" = 12),
			"[SOUTH]" = list("x" = -4, "y" = 12),
			"[WEST]" = list("x" =  -4, "y" = 12)
		)
	)
	..()

/datum/hud_data/mantid
	gear = list(
		"i_clothing" =   list("loc" = ui_iclothing, "name" = "Uniform",      "slot" = slot_w_uniform, "state" = "center", "toggle" = 1),
		"o_clothing" =   list("loc" = ui_oclothing, "name" = "Suit",         "slot" = slot_wear_suit, "state" = "suit",   "toggle" = 1),
		"mask" =         list("loc" = ui_mask,      "name" = "Mask",         "slot" = slot_wear_mask, "state" = "mask",   "toggle" = 1),
		"gloves" =       list("loc" = ui_gloves,    "name" = "Gloves",       "slot" = slot_gloves,    "state" = "gloves", "toggle" = 1),
		"eyes" =         list("loc" = ui_glasses,   "name" = "Glasses",      "slot" = slot_glasses,   "state" = "glasses","toggle" = 1),
		"l_ear" =        list("loc" = ui_l_ear,     "name" = "Left Ear",     "slot" = slot_l_ear,     "state" = "ears",   "toggle" = 1),
		"r_ear" =        list("loc" = ui_r_ear,     "name" = "Right Ear",    "slot" = slot_r_ear,     "state" = "ears",   "toggle" = 1),
		"head" =         list("loc" = ui_head,      "name" = "Hat",          "slot" = slot_head,      "state" = "hair",   "toggle" = 1),
		"shoes" =        list("loc" = ui_shoes,     "name" = "Shoes",        "slot" = slot_shoes,     "state" = "shoes",  "toggle" = 1),
		"suit storage" = list("loc" = ui_sstore1,   "name" = "Suit Storage", "slot" = slot_s_store,   "state" = "suitstore"),
		"back" =         list("loc" = ui_back,      "name" = "Back",         "slot" = slot_back,      "state" = "back"),
		"id" =           list("loc" = ui_id,        "name" = "ID",           "slot" = slot_wear_id,   "state" = "id"),
		"storage1" =     list("loc" = ui_storage1,  "name" = "Left Pocket",  "slot" = slot_l_store,   "state" = "pocket"),
		"storage2" =     list("loc" = ui_storage2,  "name" = "Right Pocket", "slot" = slot_r_store,   "state" = "pocket"),
		"belt" =         list("loc" = ui_belt,      "name" = "Belt",         "slot" = slot_belt,      "state" = "belt")
		)

/singleton/species/nabber/monarch
	name = SPECIES_MONARCH_WORKER
	name_plural = "Monarch Serpentid Workers"
	hidden_from_codex = FALSE
	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN
	icobase = 'icons/mob/human_races/species/nabber/body_msw.dmi'
	deform = 'icons/mob/human_races/species/nabber/body_msw.dmi'
	// Previously inherited plain GAS's preview_icon (nabber/preview.dmi) -- split out to its own file (a
	// placeholder copy of it, for now) so uploading a dedicated Monarch Worker preview doesn't also change GAS's.
	preview_icon = 'icons/mob/human_races/species/nabber/preview_msw.dmi'
	// Only the Grey base skin fits Monarch Worker's art -- explicit user decision.
	base_skin_colours = list("Grey" = "")
	// Inherits Kharmaan Gyne's aging (range + "linear" formula) rather than plain GAS's ("quadruple") -- explicit
	// user direction; Monarch Queen (below) inherits this in turn, having no age override of its own.
	min_age = 18
	max_age = 500
	human_equivalent_age_formula = "linear"
	has_organ = list(
		BP_BRAIN =             /obj/item/organ/internal/brain/insectoid/nabber,
		BP_EYES =              /obj/item/organ/internal/eyes/insectoid/nabber,
		BP_TRACH =             /obj/item/organ/internal/lungs/insectoid/nabber,
		BP_HEART =             /obj/item/organ/internal/heart/open,
		BP_LIVER =             /obj/item/organ/internal/liver/insectoid/nabber,
		BP_STOMACH =           /obj/item/organ/internal/stomach/insectoid,
		BP_SYSTEM_CONTROLLER = /obj/item/organ/internal/controller,
		// Monarch Worker redeclares has_organ wholesale (a full replacement, not a merge) so it never picked up
		// the genital organs added to base /singleton/species/nabber in an earlier pass -- flagged at the time as
		// a subspecies needing its own follow-up, done now alongside the pixel-offset work.
		BP_BREASTS =           /obj/item/organ/internal/mutant/breasts,
		BP_PENIS =             /obj/item/organ/internal/mutant/penis,
		BP_TESTICLES =         /obj/item/organ/internal/mutant/testicles,
		BP_PUSSY =             /obj/item/organ/internal/mutant/vagina,
		BP_ANUS =              /obj/item/organ/internal/mutant/anus
	)

	force_cultural_info = list(
		TAG_CULTURE =   CULTURE_ASCENT,
		TAG_HOMEWORLD = HOME_SYSTEM_KHARMAANI,
		TAG_FACTION =   FACTION_ASCENT_SERPENTID,
		TAG_RELIGION =  RELIGION_KHARMAANI
	)

/singleton/species/nabber/monarch/get_bodytype(mob/living/carbon/human/H)
	return SPECIES_NABBER

/singleton/species/nabber/monarch/queen
	name = SPECIES_MONARCH_QUEEN
	name_plural = "Monarch Serpentid Queens"
	hidden_from_codex = FALSE
	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN
	preview_icon = 'icons/mob/human_races/species/nabber/msq/preview.dmi'
	icobase = 'icons/mob/human_races/species/nabber/msq/body.dmi'
	deform = 'icons/mob/human_races/species/nabber/msq/body.dmi'
	// MSQ's body art (nabber/msq/body.dmi) is a standard 32x32-tile sprite, unlike Worker/base GAS's 32x40 --
	// without this override it silently inherits Worker's icon_template = template_tall.dmi (32x40), a real
	// canvas/art mismatch found while deriving MSQ's mutant-organ pixel offsets (see nabber_camo.dm/
	// nabber_threat.dm's monarch_queen subclasses + baystation12soyh_genitals_port_plan memory).
	icon_template = 'icons/mob/human_races/species/template.dmi'
	// Only the Grey base skin fits Monarch Queen's art -- explicit user decision.
	base_skin_colours = list("Grey" = "")
	// Without this override, Queen inherits Worker's has_organ list wholesale, which points BP_EYES at the
	// shared Nabber/GAS eye organ (eyes/insectoid/nabber) instead of the dedicated eyes/insectoid/msq type
	// that already exists in nabber.dm -- same dormant-since-2020 pattern as the earlier icobase/deform bug.
	has_organ = list(
		BP_BRAIN =             /obj/item/organ/internal/brain/insectoid/nabber,
		BP_EYES =              /obj/item/organ/internal/eyes/insectoid/msq,
		BP_TRACH =             /obj/item/organ/internal/lungs/insectoid/nabber,
		BP_HEART =             /obj/item/organ/internal/heart/open,
		BP_LIVER =             /obj/item/organ/internal/liver/insectoid/nabber,
		BP_STOMACH =           /obj/item/organ/internal/stomach/insectoid,
		BP_SYSTEM_CONTROLLER = /obj/item/organ/internal/controller,
		BP_BREASTS =           /obj/item/organ/internal/mutant/breasts,
		BP_PENIS =             /obj/item/organ/internal/mutant/penis,
		BP_TESTICLES =         /obj/item/organ/internal/mutant/testicles,
		BP_PUSSY =             /obj/item/organ/internal/mutant/vagina,
		BP_ANUS =              /obj/item/organ/internal/mutant/anus
	)
	override_limb_types = list(
		BP_CHEST = /obj/item/organ/external/chest/insectoid/nabber/monarch_queen,
		BP_GROIN = /obj/item/organ/external/groin/insectoid/nabber/monarch_queen
	)
