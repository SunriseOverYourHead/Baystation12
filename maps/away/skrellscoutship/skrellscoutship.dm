#define WEBHOOK_SUBMAP_LOADED_SKRELL "webhook_submap_skrell"

#include "skrellscoutship_areas.dm"
#include "skrellscoutship_shuttles.dm"
#include "skrellscoutship_radio.dm"

/datum/map_template/ruin/away_site/skrellscoutship
	name = "Skrellian Scout Ship"
	id = "awaysite_skrell_scout"
	description = "A Skrellian SDTF scouting vessel. This one seems to be a heavier model."
	suffixes = list("skrellscoutship/skrellscoutship_revamp.dmm")
	spawn_cost = 0.5
	player_cost = 4
	shuttles_to_initialise = list(/datum/shuttle/autodock/overmap/skrellscoutship, /datum/shuttle/autodock/overmap/skrellscoutshuttle)
	apc_test_exempt_areas = list(
		/area/ship/skrellscoutship/externalwing/port = NO_SCRUBBER|NO_VENT|NO_APC,
		/area/ship/skrellscoutship/externalwing/starboard = NO_SCRUBBER|NO_VENT|NO_APC
	)
	spawn_weight = 0.67

/obj/overmap/visitable/sector/skrellscoutspace
	name = "Empty Sector"
	desc = "Slight traces of a cloaking device are present. Unable to determine exact location."
	icon_state = "event"
	hide_from_reports = TRUE
	sensor_visibility = 10

/obj/submap_landmark/joinable_submap/skrellscoutship
	name = "Xilvuxix"
	archetype = /singleton/submap_archetype/skrellscoutship

/obj/submap_landmark/spawnpoint/skrellscoutship
	name = "Qrri-Zuumqix"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/skrellscoutship/leader
	name = "Qrri-Vuxix"

/singleton/webhook/submap_loaded/skrell
	id = WEBHOOK_SUBMAP_LOADED_SKRELL

/singleton/submap_archetype/skrellscoutship
	descriptor = "Skrellian Scout Ship"
	map = "Xilvuxix"
	crew_jobs = list(
		/datum/job/submap/skrellscoutship_crew,
		/datum/job/submap/skrellscoutship_crew/leader
	)
	call_webhook = WEBHOOK_SUBMAP_LOADED_SKRELL

/obj/item/card/id/skrellscoutship
	color = COLOR_GRAY40
	detail_color = "#7331c4"
	access = list(access_skrellscoutship)

/datum/job/submap/skrellscoutship_crew/leader
	title = "Qrri-Vuxix"
	supervisors = "your SDTF"
	total_positions = 1
	outfit_type = /singleton/hierarchy/outfit/job/skrellscoutship/leader
	allowed_ranks = list(/datum/mil_rank/skrell_fleet/vuxix)
	info = "Your vessel is scouting through unknown space, working to map out any potential dangers, as well as potential allies."
	is_semi_antagonist = TRUE
	min_skill = list(SKILL_EVA = SKILL_TRAINED,
					SKILL_PILOT = SKILL_TRAINED,
					SKILL_HAULING = SKILL_TRAINED,
					SKILL_COMBAT = SKILL_TRAINED,
					SKILL_WEAPONS = SKILL_TRAINED,
					SKILL_MEDICAL = SKILL_BASIC)

/datum/job/submap/skrellscoutship_crew
	title = "Qrri-Zuumqix"
	supervisors = "your Qrri-Vuxix"
	total_positions = 5
	whitelisted_species = list("Skrell")
	branch = /datum/mil_branch/skrell_fleet
	rank = /datum/mil_rank/skrell_fleet
	allowed_branches = list(/datum/mil_branch/skrell_fleet)
	allowed_ranks = list(/datum/mil_rank/skrell_fleet/zuumqix)
	outfit_type = /singleton/hierarchy/outfit/job/skrellscoutship
	info = "Your vessel is scouting through unknown space, working to map out any potential dangers, as well as potential allies."
	skill_points = 30
	is_semi_antagonist = TRUE
	min_skill = list(SKILL_EVA = SKILL_TRAINED,
					SKILL_HAULING = SKILL_TRAINED,
					SKILL_COMBAT = SKILL_TRAINED,
					SKILL_WEAPONS = SKILL_TRAINED,
					SKILL_MEDICAL = SKILL_BASIC)

/datum/job/submap/skrellscoutship_crew/equip(var/mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch, var/datum/mil_rank/grade)
	. = ..(H, alt_title, branch, grade)
	var/skrellscoutcastes = list(
		"Malish-Katish" = list(
			"Mero'ta-Ketish",
			"Toglo'i-Ketish",
			"Keloa-Ketish"
		),
		"Kanin-Katish" = list(
			"Xiqarr-Ketish",
			"Mero'tol-Ketish",
			"Goxo'i-Ketish"
		),
		"Raskinta-Katish" = list(
			"Me'kerr-Ketish",
			"Qi'kerr-Ketish",
			"Me'xoal-Ketish"
		)
	)

	var/skrellcaste = input(H, "What is your Skrell's Caste?", "SDTF Rank") as null|anything in skrellscoutcastes
	if(skrellcaste)
		var/skrellsubcaste = input(H, "What is your Skrell's Subcaste?", "SDTF Rank") as null|anything in skrellscoutcastes[skrellcaste]
		var/obj/item/card/id/C = H.wear_id
		if(istype(C))
			C.assignment = skrellsubcaste

/obj/item/clothing/gloves/thick/swat/skrell
	name = "black gloves"
	desc = "A pair of black, reinforced gloves. The tag on the inner stitching appears to be written in some form of Skrellian."

/obj/item/clothing/under/skrelljumpsuit
	name = "black bodysuit"
	desc = "A sleek, skin-tight bodysuit designed to not wick moisture away from the body. The inner stitching appears to contain something written in Skrellian."
	icon_state = "skrell_suit"
	item_state = "skrell_suit"
	worn_state = "skrell_suit"

/obj/item/reagent_containers/food/condiment/psilocybin
	starting_reagents = list(/datum/reagent/drugs/psilocybin = 50)

/obj/item/reagent_containers/food/condiment/mindbreaker
	starting_reagents = list(/datum/reagent/drugs/mindbreaker = 50)

/obj/item/reagent_containers/food/condiment/hextro
	starting_reagents = list(/datum/reagent/drugs/hextro = 50)

/singleton/hierarchy/outfit/job/skrellscoutship
	name = "Xilvuxix Crew"
	uniform = /obj/item/clothing/under/skrelljumpsuit
	shoes = /obj/item/clothing/shoes/dutyboots
	gloves = /obj/item/clothing/gloves/thick/swat/skrell
	pda_type = /obj/item/modular_computer/pda
	pda_slot = slot_l_store
	l_ear = /obj/item/device/radio/headset/map_preset/skrellscoutship
	id_types = list(/obj/item/card/id/skrellscoutship)
	l_pocket = /obj/item/clothing/accessory/badge/tags/skrell

/singleton/hierarchy/outfit/job/skrellscoutship/leader
	name = "Xilvuxix Vuxix"
	r_pocket = /obj/item/clothing/accessory/skrellian/rank/SDTF/QVX

/obj/item/clothing/accessory/skrellian/rank/SDTF/QZQX
	name = "SDTF Qrri-Zuumqix rank pin"
	desc = "A rank insignia pin identifying the wearer as a Qrri-Zuumqix of the Skrellian Defense Task Force."

/obj/item/clothing/accessory/skrellian/rank/SDTF/QVX
	name = "SDTF Qrri-Vuxix rank pin"
	desc = "A rank insignia pin identifying the wearer as a Qrri-Vuxix of the Skrellian Defense Task Force."

/datum/mil_branch/skrell_fleet
	name = "Skrellian Defense Task Force"
	name_short = "SDTF"
	email_domain = "sdtf.qb"
	rank_types = list(
		/datum/mil_rank/skrell_fleet/zuumqix,
		/datum/mil_rank/skrell_fleet/vuxix
	)
	spawn_rank_types = list(
		/datum/mil_rank/skrell_fleet/zuumqix,
		/datum/mil_rank/skrell_fleet/vuxix
	)

/datum/mil_rank/skrell_fleet/zuumqix
	name = "Qrii-Zuumqix"
	name_short = "QZQX"
	accessory = list(/obj/item/clothing/accessory/skrellian/rank/SDTF/QZQX)

/datum/mil_rank/skrell_fleet/vuxix
	name = "Qrii-Vuxix"
	name_short = "QVX"
	accessory = list(/obj/item/clothing/accessory/skrellian/rank/SDTF/QVX)

/obj/machinery/power/smes/buildable/preset/skrell
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/advanced = 2
	)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/power/apc/debug/skrell
	cell_type = /obj/item/cell/infinite
	req_access = list(access_skrellscoutship)

#undef WEBHOOK_SUBMAP_LOADED_SKRELL

/obj/item/reagent_containers/food/drinks/bottle/skwine
	name = "Qokk-Hrona"
	desc = "A bottle of skrellian wine made from refined Qokk-loa, featuring an ornate cap. Not recommended for human consumption."
	icon_state = "qokk"
	center_of_mass = "x=16;y=4"

/obj/item/reagent_containers/food/drinks/bottle/skwine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/ethanol/qokkhrona, 100)

/obj/item/storage/belt/holster/skrell
	name = "skrellian holster belt"
	desc = "Can hold security gear like handcuffs and flashes. This one has a convenient holster especially designed to accomodate the XV-5."
	icon_state = "securitybelt"
	item_state = "security"
	storage_slots = 8
	overlay_flags = BELT_OVERLAY_ITEMS|BELT_OVERLAY_HOLSTER
	contents_allowed = list(
		/obj/item/crowbar,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/handcuffs,
		/obj/item/device/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_magazine,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/melee/baton,
		/obj/item/melee/telebaton,
		/obj/item/flame/lighter,
		/obj/item/device/flashlight,
		/obj/item/modular_computer/pda,
		/obj/item/device/radio/headset,
		/obj/item/device/hailer,
		/obj/item/device/megaphone,
		/obj/item/melee,
		/obj/item/taperoll,
		/obj/item/device/holowarrant,
		/obj/item/magnetic_ammo,
		/obj/item/device/binoculars,
		/obj/item/clothing/gloves,
		/obj/item/gun/energy/gun/skrell
		)

/obj/machinery/computer/ship/sensors/skrell
	base_type = /obj/machinery/computer/ship/sensors
	print_language = LANGUAGE_SKRELLIAN

/obj/machinery/power/skrell_reactor
	name = "skrellian advanced fusion core"
	desc = "A tall, gleaming assemblage of advanced alien machinery. It hums and crackles with restrained power."
	icon = 'icons/obj/machines/power/fusion_core.dmi'
	icon_state = "core1"
	color = COLOR_CYAN
	var/on = TRUE
	var/output_power = 45 MEGAWATTS
	var/image/field_image

/obj/machinery/power/skrell_reactor/attack_hand(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.name != SPECIES_SKRELL)
			to_chat(H, SPAN_WARNING("You have no idea how to use \the [src]."))
			return
	user.visible_message(SPAN_NOTICE("\The [user] switches \the [src] [on ? "off" : "on"]."))
	on = !on
	update_icon()

/obj/machinery/power/skrell_reactor/on_update_icon()
	if(!field_image)
		field_image = image(icon = 'icons/obj/machines/power/fusion_field.dmi', icon_state = "emfield_s1")
		field_image.color = COLOR_CYAN
		field_image.alpha = 50
		field_image.layer = SINGULARITY_LAYER
		field_image.appearance_flags |= RESET_COLOR
		field_image.SetTransform(scale = 3)
	if(on)
		AddOverlays(field_image)
		set_light(6, 0.8, l_color = COLOR_CYAN)
		icon_state = "core1"
	else
		CutOverlays(field_image)
		set_light(0)
		icon_state = "core0"

/obj/machinery/power/skrell_reactor/Initialize()
	. = ..()
	update_icon()

/obj/machinery/power/skrell_reactor/Process()
	if(on)
		add_avail(output_power)

/obj/item/shield/energy/skrell
	name = "skrellian combat shield"
	icon_state = "skrellshield0"
	desc = "An alien shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."

/obj/item/shield/energy/skrell/on_update_icon()
	icon_state = "skrellshield[active]"
	if(active)
		set_light(0.4, 0.1, 1, 2, "#006aff")
	else
		set_light(0)

/obj/item/melee/energy/machete/vesta
	active_force = 30
	active_throwforce = 20


/obj/item/ammo_magazine/skrell_shotgun
	name = "QX-2 flechette magazine"
	desc = "A magazine containing flechette slugs for the QX-2 miniaturized railgun."
	icon_state = "skrellflechettemag"
	mag_type = MAGAZINE
	caliber = CALIBER_SKRELL_SHOTGUN
	ammo_type = /obj/item/ammo_casing/skrell_shotgun
	max_ammo = 8
