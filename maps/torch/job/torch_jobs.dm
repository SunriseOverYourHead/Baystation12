/datum/map/torch
	// Every species can ready up for every Torch role except Captain (explicit user decision, 2026-09-02) --
	// Captain stays Human-only via job_to_species_whitelist below instead of a per-species blacklist, so it
	// applies uniformly and automatically covers any species added later too, without needing its own entry here.
	species_to_job_whitelist = list()
	species_to_job_blacklist = list()

	job_to_species_whitelist = list(
		/datum/job/captain = list(/singleton/species/human)
	)

	allowed_jobs = list(
		/datum/job/captain, /datum/job/hop, /datum/job/bridgeofficer, /datum/job/representative, /datum/job/sea,
		/datum/job/cmo, /datum/job/scientist, /datum/job/senior_doctor, /datum/job/psychiatrist, /datum/job/junior_doctor, /datum/job/doctor,
		/datum/job/chief_engineer, /datum/job/senior_engineer, /datum/job/engineer, /datum/job/roboticist, /datum/job/engineer_trainee,
		/datum/job/hos, /datum/job/officer, /datum/job/warden, /datum/job/detective,
		/datum/job/qm, /datum/job/cargo_tech,
		/datum/job/chief_steward, /datum/job/chef, /datum/job/janitor, /datum/job/chaplain, /datum/job/crew,
		/datum/job/po, /datum/job/nt_pilot, /datum/job/squadlead, /datum/job/firelead, /datum/job/comtech, /datum/job/rifleman
	)

	access_modify_region = alist(
		ACCESS_REGION_SECURITY = list(access_change_ids),
		ACCESS_REGION_MEDBAY = list(access_change_ids),
		ACCESS_REGION_RESEARCH = list(access_change_ids),
		ACCESS_REGION_ENGINEERING = list(access_change_ids),
		ACCESS_REGION_COMMAND = list(access_change_ids),
		ACCESS_REGION_GENERAL = list(access_change_ids),
		ACCESS_REGION_SUPPLY = list(access_change_ids),
		ACCESS_REGION_SERVICE = list(access_change_ids)
	)

// Some jobs for nabber grades defined here due to map-specific job datums.
/singleton/cultural_info/culture/nabber/New()
	LAZYADD(valid_jobs, /datum/job/scientist_assistant)
	..()

/singleton/cultural_info/culture/nabber/b/New()
	LAZYADD(valid_jobs, /datum/job/cargo_tech)
	..()

/singleton/cultural_info/culture/nabber/a/New()
	LAZYADD(valid_jobs, /datum/job/engineer)
	..()

/singleton/cultural_info/culture/nabber/a/plus/New()
	LAZYADD(valid_jobs, /datum/job/doctor)
	..()

/datum/job
	allowed_branches = list(
		/datum/mil_branch/civilian
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/civ
	)
	required_language = LANGUAGE_HUMAN_EURO

/datum/map/torch
	default_assistant_title = "Passenger"
