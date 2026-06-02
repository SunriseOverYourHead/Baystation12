//base type for controllers of two-door systems
/obj/machinery/embedded_controller/radio/airlock
	// Setup parameters only
	radio_filter = RADIO_AIRLOCK
	program = /datum/computer/file/embedded_program/airlock
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	var/tag_airlock_mech_sensor
	var/tag_shuttle_mech_sensor
	var/tag_secure = 0
	var/tag_air_alarm
	var/list/dummy_terminals = list()
	var/cycle_to_external_air = 0
	var/scrubber_assist = 0

/obj/machinery/embedded_controller/radio/airlock/Destroy()
	for(var/thing in dummy_terminals)
		var/obj/machinery/dummy_airlock_controller/dummy = thing
		dummy.master_controller = null
	dummy_terminals.Cut()
	return ..()

/obj/machinery/embedded_controller/radio/airlock/CanUseTopic(mob/user)
	if(!allowed(user))
		return min(STATUS_UPDATE, ..())
	else
		return ..()

//Advanced airlock controller for when you want a more versatile airlock controller - useful for turning simple access control rooms into airlocks
/obj/machinery/embedded_controller/radio/airlock/advanced_airlock_controller
	name = "advanced airlock controller"

/obj/machinery/embedded_controller/radio/airlock/advanced_airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "AdvancedAirlockConsole", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/embedded_controller/radio/airlock/advanced_airlock_controller/ui_data(mob/user)
	return list(
		"chamber_pressure" = round(program.memory["chamber_sensor_pressure"]),
		"external_pressure" = round(program.memory["external_sensor_pressure"]),
		"internal_pressure" = round(program.memory["internal_sensor_pressure"]),
		"processing" = program.memory["processing"],
		"purge" = program.memory["purge"],
		"secure" = program.memory["secure"]
	)

/obj/machinery/embedded_controller/radio/airlock/advanced_airlock_controller/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if (.)
		return
	if (action in list("cycle_ext", "cycle_int", "force_ext", "force_int", "purge", "secure", "abort"))
		program.receive_user_command(action)
		. = TRUE

//Airlock controller for airlock control - most airlocks on the station use this
/obj/machinery/embedded_controller/radio/airlock/airlock_controller
	name = "airlock controller"
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "SimpleAirlockConsole", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/ui_data(mob/user)
	return list(
		"chamber_pressure" = round(program.memory["chamber_sensor_pressure"]),
		"exterior_status" = program.memory["exterior_status"],
		"interior_status" = program.memory["interior_status"],
		"processing" = program.memory["processing"]
	)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if (.)
		return
	if (action in list("cycle_ext", "cycle_int", "force_ext", "force_int", "abort"))
		program.receive_user_command(action)
		. = TRUE

//Access controller for door control - used in virology and the like
/obj/machinery/embedded_controller/radio/airlock/access_controller
	icon = 'icons/obj/doors/airlock_machines.dmi'
	name = "access controller"
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/access_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "DoorAccessConsole", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/embedded_controller/radio/airlock/access_controller/ui_data(mob/user)
	return list(
		"exterior_status" = program.memory["exterior_status"],
		"interior_status" = program.memory["interior_status"],
		"processing" = program.memory["processing"]
	)

/obj/machinery/embedded_controller/radio/airlock/access_controller/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if (.)
		return
	if (action in list("cycle_ext_door", "cycle_int_door", "force_ext", "force_int"))
		program.receive_user_command(action)
		. = TRUE
