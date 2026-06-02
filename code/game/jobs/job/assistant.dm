/datum/job/assistant
	title = "Crewman"
	department = "Civilian"
	department_flag = CIV

	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	economic_power = 1
	access = list()
	alt_titles = list("Ship Hand","Recruit","Technician Apprentice","Visitor")
	outfit_type = /singleton/hierarchy/outfit/job/assistant

/datum/job/assistant/get_access()
	return list()
