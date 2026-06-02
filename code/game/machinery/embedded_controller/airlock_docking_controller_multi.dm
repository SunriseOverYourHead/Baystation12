//a controller for a docking port with multiple independent airlocks
//this is the master controller, that things will try to dock with.
/obj/machinery/embedded_controller/radio/docking_port_multi
	name = "docking port controller"
	program = /datum/computer/file/embedded_program/docking/multi
	var/child_tags_txt
	var/child_names_txt
	var/list/child_names = list()

/obj/machinery/embedded_controller/radio/docking_port_multi/Initialize()
	. = ..()
	var/list/names = splittext(child_names_txt, ";")
	var/list/tags = splittext(child_tags_txt, ";")
	if (length(names) == length(tags))
		for (var/i = 1; i <= length(tags); i++)
			child_names[tags[i]] = names[i]

/obj/machinery/embedded_controller/radio/docking_port_multi/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "MultiDockingConsole", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/embedded_controller/radio/docking_port_multi/ui_data(mob/user)
	var/datum/computer/file/embedded_program/docking/multi/docking_program = program
	var/list/airlocks = list()
	for (var/child_tag in child_names)
		airlocks += list(list("name" = child_names[child_tag], "override_enabled" = (docking_program.children_override[child_tag] == "enabled")))
	return list(
		"docking_status" = docking_program.get_docking_status(),
		"airlocks" = airlocks
	)

/obj/machinery/embedded_controller/radio/docking_port_multi/Topic(href, href_list)
	return 1 // Apparently we swallow all input (this is corrected legacy code)



//a docking port based on an airlock
/obj/machinery/embedded_controller/radio/airlock/docking_port_multi
	name = "docking port controller"
	program = /datum/computer/file/embedded_program/airlock/multi_docking
	var/master_tag	//for mapping
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "DockingAirlockConsole", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/ui_data(mob/user)
	var/datum/computer/file/embedded_program/airlock/multi_docking/airlock_program = program
	return list(
		"chamber_pressure" = round(airlock_program.memory["chamber_sensor_pressure"]),
		"exterior_status" = airlock_program.memory["exterior_status"],
		"interior_status" = airlock_program.memory["interior_status"],
		"processing" = airlock_program.memory["processing"],
		"docking_status" = airlock_program.master_status,
		"airlock_disabled" = (airlock_program.docking_enabled && !airlock_program.override_enabled),
		"override_enabled" = airlock_program.override_enabled
	)

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if (.)
		return
	if (action in list("cycle_ext", "cycle_int", "force_ext", "force_int", "abort", "toggle_override"))
		program.receive_user_command(action)
		. = TRUE
