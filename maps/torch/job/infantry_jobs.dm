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
	ideal_character_age = 22
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
		access_radio_inf, access_rifleman, access_comtech, access_squadlead, access_ftlead,
		access_solgov_crew, access_expedition_shuttle, access_guppy, access_hangar
	)

	software_on_spawn = list(/datum/computer_file/program/deck_management,
							 /datum/computer_file/program/reports)

/datum/job/squadlead/get_description_blurb()
	return "You are the Squad Leader. You are the Platoon Officer's right-hand man: Their eyes and ears in the A-O. Coordinate the marine complement onboard to accomplish your objectives. Ensure that SOP and regulations are being followed. Above all, ensure that all operations outside are carried out with utmost efficiency. Semper fi, Marine."

/datum/job/firelead
	title = "Fireteam Leader"
	department = "Infantry"
	department_flag = INF
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Squad Leader"
	selection_color = "#509429"
	minimal_player_age = 1
	economic_power = 10
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 20
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
		access_radio_inf, access_rifleman, access_comtech, access_ftlead,
		access_solgov_crew, access_expedition_shuttle, access_guppy, access_hangar
	)

/datum/job/firelead/get_description_blurb()
	return "You are a Fireteam Leader. You take orders directly from the Squad Lead and help manage a smaller group of marines on the field. Coordinate with your SL, relay orders, broadcast information, lead your Riflemen to victory."


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
		access_expedition_shuttle, access_expedition_shuttle_helm, access_guppy, access_hangar,
		access_pilot, access_solgov_crew, access_eva,
		access_radio_inf, access_radio_sup, access_maint_tunnels, access_emergency_storage
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

/datum/job/comtech
	title = "Combat Technician"
	department = "Infantry"
	department_flag = INF
	total_positions = 4
	spawn_positions = 4
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
		access_radio_inf, access_rifleman, access_comtech, access_solgov_crew, access_expedition_shuttle, access_guppy, access_hangar
	)

/datum/job/comtech/get_description_blurb()
	return "You are a Combat Technician. Your job is to clear up debris and open up new paths for marines to take advantage of. You can also do a limited amount of repairwork. You are not an Engineer."

/datum/job/rifleman
	title = "Rifleman"
	department = "Infantry"
	department_flag = INF
	total_positions = 100
	spawn_positions = 100
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
		access_radio_inf, access_rifleman, access_solgov_crew, access_expedition_shuttle, access_guppy, access_hangar
	)

/datum/job/rifleman/get_description_blurb()
	return "You are a Rifleman. Semper Fidelis."
