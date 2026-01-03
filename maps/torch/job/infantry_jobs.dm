/datum/job/squadlead
	title = "Squad Leader"
	department = "Infantry"
	department_flag = INF
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Platoon Officer"
	selection_color = "#509429"
	minimal_player_age = 1
	economic_power = 10
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 35
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/infantry/squadlead
	allowed_branches = list(/datum/mil_branch/marine_corps)
	allowed_ranks = list(
		/datum/mil_rank/marine_corps/e5,
		/datum/mil_rank/marine_corps/e6,
		/datum/mil_rank/marine_corps/e7,
	)
	skill_points = 28
	min_skill = list( // 9 points
		SKILL_BUREAUCRACY = SKILL_BASIC, // 1 point
		SKILL_EVA = SKILL_TRAINED, // 2 points
		SKILL_SCIENCE = SKILL_TRAINED, // 4 points
		SKILL_PILOT = SKILL_BASIC // 2 points
	)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX,
	                    SKILL_COMBAT      = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS     = SKILL_EXPERIENCED)

	access = list(
		access_pathfinder, access_explorer, access_eva, access_maint_tunnels, access_bridge, access_emergency_storage,
		access_guppy_helm, access_solgov_crew, access_expedition_shuttle, access_expedition_shuttle_helm,
		access_guppy, access_hangar, access_petrov, access_petrov_helm, access_petrov_analysis, access_petrov_phoron,
		access_petrov_toxins, access_petrov_chemistry, access_petrov_maint, access_tox, access_tox_storage, access_research,
		access_xenobiology, access_xenoarch, access_torch_fax, access_radio_comm,
		access_radio_exp, access_radio_sci, access_research_storage, access_radio_sup
	)

	software_on_spawn = list(/datum/computer_file/program/deck_management,
							 /datum/computer_file/program/reports)

/datum/job/squadlead/get_description_blurb()
	return "You are the Squad Leader. You are the Platoon Officer's right-hand man: Their eyes and ears in the A-O. Coordinate the marine complement onboard to accomplish your objectives. Ensure that SOP and regulations are being followed. Above all, ensure that all operations outside are carried out with utmost efficiency. Semper fi, Marine."

/datum/job/firelead
	title = "Fireteam Leader"
	department = "Infantry"
	department_flag = INF
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Squad Leader"
	selection_color = "#509429"
	minimal_player_age = 1
	economic_power = 10
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 35
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/infantry/firelead
	allowed_branches = list(/datum/mil_branch/marine_corps)
	allowed_ranks = list(
		/datum/mil_rank/marine_corps/e3,
		/datum/mil_rank/marine_corps/e4,
		/datum/mil_rank/marine_corps/e5,
	)
	skill_points = 28
	min_skill = list( // 9 points
		SKILL_BUREAUCRACY = SKILL_BASIC, // 1 point
		SKILL_EVA = SKILL_TRAINED, // 2 points
		SKILL_SCIENCE = SKILL_TRAINED, // 4 points
		SKILL_PILOT = SKILL_BASIC // 2 points
	)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX,
	                    SKILL_COMBAT      = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS     = SKILL_EXPERIENCED)

	access = list(
		access_pathfinder, access_explorer, access_eva, access_maint_tunnels, access_bridge, access_emergency_storage,
		access_guppy_helm, access_solgov_crew, access_expedition_shuttle, access_expedition_shuttle_helm,
		access_guppy, access_hangar, access_petrov, access_petrov_helm, access_petrov_analysis, access_petrov_phoron,
		access_petrov_toxins, access_petrov_chemistry, access_petrov_maint, access_tox, access_tox_storage, access_research,
		access_xenobiology, access_xenoarch, access_torch_fax, access_radio_comm,
		access_radio_exp, access_radio_sci, access_research_storage, access_radio_sup
	)

	software_on_spawn = list(/datum/computer_file/program/deck_management,
							 /datum/computer_file/program/reports)

/datum/job/firelead/get_description_blurb()
	return "You are the Squad Leader. You are the Platoon Officer's right-hand man: Their eyes and ears in the A-O. Coordinate the marine complement onboard to accomplish your objectives. Ensure that SOP and regulations are being followed. Above all, ensure that all operations outside are carried out with utmost efficiency. Semper fi, Marine."


/datum/job/nt_pilot
	title = "Dropship Pilot"
	supervisors = "the Platoon Officer, the Deck Chief"
	department = "Infantry"
	department_flag = INF
	total_positions = 1
	spawn_positions = 1
	selection_color = "#509429"
	economic_power = 8
	minimal_player_age = 0
	minimum_character_age = list(SPECIES_HUMAN = 24)
	ideal_character_age = 25
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/exploration/pilot/fleet
	allowed_branches = list(
		/datum/mil_branch/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o1,
		/datum/mil_rank/fleet/o2
	)

	access = list(
		access_mining_office, access_petrov, access_petrov_helm, access_petrov_maint, access_mining_station,
		access_expedition_shuttle, access_expedition_shuttle_helm, access_guppy, access_hangar, access_guppy_helm,
		access_mining, access_pilot, access_solgov_crew, access_eva, access_explorer, access_research,
		access_radio_exp, access_radio_sci, access_radio_sup, access_maint_tunnels, access_emergency_storage
	)
	min_skill = list( // 5 points
		SKILL_EVA = SKILL_BASIC, // 1 point
		SKILL_PILOT = SKILL_TRAINED // 4 points
	)

	max_skill = list(
		SKILL_PILOT = SKILL_MAX,
		SKILL_SCIENCE = SKILL_MAX
	)

/datum/job/nt_pilot/get_description_blurb()
	return "You are the Dropship Pilot. Your job is to navigate the shuttles onboard the ship to provide safe and reliable transport for the marine complement. You take orders from the Platoon Officer, but the Deck Chief has positional authority over you."

/datum/job/corpsman/get_description_blurb()
	return "You are a Rifleman. Semper Fidelis."

/datum/job/comtech
	title = "Combat Technician"
	department = "Infantry"
	department_flag = INF
	total_positions = 30
	spawn_positions = 30
	supervisors = "the Fireteam leader, the Squad leader"
	selection_color = "#509429"
	minimum_character_age = list(SPECIES_HUMAN = 18)
	ideal_character_age = 20
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/infantry/comtech
	allowed_branches = list(/datum/mil_branch/marine_corps)

	allowed_ranks = list(
		/datum/mil_rank/marine_corps/e2,
		/datum/mil_rank/marine_corps/e3,
		/datum/mil_rank/marine_corps/e4,
	)
	min_skill = list( // 1 point
		SKILL_EVA = SKILL_BASIC // 1 point
	)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX,
	                    SKILL_COMBAT      = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS     = SKILL_EXPERIENCED)

	access = list(
		access_explorer, access_maint_tunnels, access_eva, access_emergency_storage,
		access_guppy_helm, access_solgov_crew, access_expedition_shuttle, access_guppy, access_hangar,
		access_petrov, access_petrov_maint, access_research, access_radio_exp
	)

	software_on_spawn = list(/datum/computer_file/program/deck_management)

/datum/job/comtech/get_description_blurb()
	return "You are a Rifleman. Semper Fidelis."

/datum/job/rifleman
	title = "Rifleman"
	department = "Infantry"
	department_flag = INF
	total_positions = 30
	spawn_positions = 30
	supervisors = "the Fireteam leader, the Squad leader"
	selection_color = "#509429"
	minimum_character_age = list(SPECIES_HUMAN = 18)
	ideal_character_age = 20
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/infantry
	allowed_branches = list(/datum/mil_branch/marine_corps)

	allowed_ranks = list(
		/datum/mil_rank/marine_corps/e1,
		/datum/mil_rank/marine_corps/e2,
		/datum/mil_rank/marine_corps/e3,
	)
	min_skill = list( // 1 point
		SKILL_EVA = SKILL_BASIC // 1 point
	)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX,
	                    SKILL_COMBAT      = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS     = SKILL_EXPERIENCED)

	access = list(
		access_explorer, access_maint_tunnels, access_eva, access_emergency_storage,
		access_guppy_helm, access_solgov_crew, access_expedition_shuttle, access_guppy, access_hangar,
		access_petrov, access_petrov_maint, access_research, access_radio_exp
	)

	software_on_spawn = list(/datum/computer_file/program/deck_management)

/datum/job/rifleman/get_description_blurb()
	return "You are a Rifleman. Semper Fidelis."
