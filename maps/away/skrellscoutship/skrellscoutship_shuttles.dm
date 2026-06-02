/obj/machinery/computer/shuttle_control/explore/skrellscoutship
	name = "SSV control console"
	req_access = list(access_skrellscoutship)
	shuttle_tag = "Skrellian Scout"

/obj/machinery/computer/shuttle_control/explore/skrellscoutshuttle
	name = "SSV Shuttle control console"
	req_access = list(access_skrellscoutship)
	shuttle_tag = "Skrellian Shuttle"

/obj/overmap/visitable/ship/landable/skrellscoutship
	name = "light skrellian vessel"
	shuttle = "Skrellian Scout"
	desc = "A small vessel of skrellian design. Sensors detect residual bluespace signatures and cloaking particulates on the vessel's surface."
	multiz = 1
	icon_state = "ship"
	fore_dir = WEST
	color = "#ff00ff"
	vessel_mass = 10000
	vessel_size = SHIP_SIZE_SMALL
	initial_restricted_waypoints = list(
		"Skrellian Shuttle" = list("nav_skrellscoutsh_dock")
	)

/obj/overmap/visitable/ship/landable/skrellscoutship/New()
	name = "SSV [pick("Xilvuxix", "Zuuvixix", "Quizuu", "Vulzxixvuu","Krixxmuzoox","Qerr-Gliqrixx", "Qarr-Kon")]"
	..()

// Same fix as ascent_seedship: find_z_levels() creates new empty space z-levels, but the
// ship interior lives on the DMM z-levels. Register those so get_owning_sector_recursive()
// can find this ship from consoles (sync_linked relies on map_sectors[console.z] != null).
/obj/overmap/visitable/ship/landable/skrellscoutship/register_z_levels()
	..()
	for(var/interior_z in GetConnectedZlevels(z))
		if(!(interior_z in map_z))
			map_sectors["[interior_z]"] = src

/obj/overmap/visitable/ship/landable/skrellscoutshuttle
	name = "SSV-S"
	shuttle = "Skrellian Shuttle"
	desc = "Sensors detect a skrellian shuttle with a very small radar cross-section."
	fore_dir = EAST
	color = "#880088"
	vessel_mass = 750
	vessel_size = SHIP_SIZE_TINY

/datum/shuttle/autodock/overmap/skrellscoutship
	name = "Skrellian Scout"
	warmup_time = 5
	range = 1
	current_location = "nav_skrellscout_start"
	shuttle_area = list(
		/area/ship/skrellscoutship/command/bridge, /area/ship/skrellscoutship/command/vuxix, /area/ship/skrellscoutship/command/brig, /area/ship/skrellscoutship/wings/port, /area/ship/skrellscoutship/wings/starboard,
		/area/ship/skrellscoutship/crew/fit, /area/ship/skrellscoutship/forestorage,
		/area/ship/skrellscoutship/corridor, /area/ship/skrellscoutship/hangar,
		/area/ship/skrellscoutship/crew/dormitories, /area/ship/skrellscoutship/crew/toilets, /area/ship/skrellscoutship/crew/medbay, /area/ship/skrellscoutship/crew/kitchen,
		/area/ship/skrellscoutship/maintenance/power, /area/ship/skrellscoutship/command/armory,
		/area/ship/skrellscoutship/dock, /area/ship/skrellscoutship/maintenance/atmos,
		/area/ship/skrellscoutship/crew/rec
		)
	defer_initialisation = TRUE
	knockdown = FALSE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_UNSKILLED
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/skrell

/obj/shuttle_landmark/skrellscoutship/start
	name = "Uncharted Space"
	landmark_tag = "nav_skrellscout_start"

/datum/shuttle/autodock/overmap/skrellscoutshuttle
	name = "Skrellian Shuttle"
	warmup_time = 5
	current_location = "nav_skrellscoutsh_dock"
	range = 2
	shuttle_area = /area/ship/skrellscoutshuttle
	defer_initialisation = TRUE
	flags = SHUTTLE_FLAGS_PROCESS
	skill_needed = SKILL_UNSKILLED
	ceiling_type = /turf/simulated/floor/shuttle_ceiling/skrell
	mothershuttle = "Skrellian Scout"

/obj/shuttle_landmark/skrellscoutshuttle/start
	name = "Dock"
	landmark_tag = "nav_skrellscoutsh_dock"
	base_area = /area/ship/skrellscoutship/hangar
	base_turf = /turf/simulated/floor/tiled/skrell
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/shuttle_landmark/skrellscout/dock
	name = "Skrellian Scout Docking Port"
	landmark_tag = "nav_skrellscout_dock"

/obj/shuttle_landmark/skrellscoutshuttle/altdock
	name = "Docking Port"
	landmark_tag = "nav_skrellscoutsh_altdock"

/turf/simulated/floor/shuttle_ceiling/skrell
	color = COLOR_SOL

/turf/simulated/floor/shuttle_ceiling/skrell/air
	initial_gas = list(GAS_OXYGEN = MOLES_O2STANDARD, GAS_NITROGEN = MOLES_N2STANDARD)
