//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/priority_air_alarms = list()
var/global/list/minor_air_alarms = list()


/obj/machinery/computer/atmos_alert
	name = "atmospheric alert computer"
	desc = "Used to access the atmospheric sensors."
	icon_keyboard = "atmos_key"
	icon_screen = "alert:0"
	light_color = "#e6ffff"
	machine_name = "atmospheric alert console"
	machine_desc = "A hub for local air sensor systems, displaying a list of atmospheric alarms in the region."

/obj/machinery/computer/atmos_alert/Initialize()
	. = ..()
	GLOB.atmosphere_alarm.register_alarm(src, TYPE_PROC_REF(/atom, update_icon))

/obj/machinery/computer/atmos_alert/Destroy()
	GLOB.atmosphere_alarm.unregister_alarm(src)
	. = ..()

/obj/machinery/computer/atmos_alert/interface_interact(user)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "AtmosAlert", src.name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/atmos_alert/ui_data(mob/user)
	var/list/data = list()
	var/list/major_alarms = list()
	var/list/minor_alarms = list()

	for(var/datum/alarm/alarm in GLOB.atmosphere_alarm.major_alarms(get_z(src)))
		major_alarms[LIST_PRE_INC(major_alarms)] = list("name" = sanitize(alarm.alarm_name()), "ref" = "\ref[alarm]")

	for(var/datum/alarm/alarm in GLOB.atmosphere_alarm.minor_alarms(get_z(src)))
		minor_alarms[LIST_PRE_INC(minor_alarms)] = list("name" = sanitize(alarm.alarm_name()), "ref" = "\ref[alarm]")

	data["priority_alarms"] = major_alarms
	data["minor_alarms"] = minor_alarms
	return data

/obj/machinery/computer/atmos_alert/on_update_icon()
	if(operable())
		if(GLOB.atmosphere_alarm.has_major_alarms(get_z(src)))
			icon_screen = "alert:2"
		else if (GLOB.atmosphere_alarm.has_minor_alarms(get_z(src)))
			icon_screen = "alert:1"
		else
			icon_screen = initial(icon_screen)
	..()

/obj/machinery/computer/atmos_alert/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(action == "clear_alarm")
		var/datum/alarm/alarm = locate(params["clear_alarm"]) in GLOB.atmosphere_alarm.alarms
		if(alarm)
			for(var/datum/alarm_source/alarm_source in alarm.sources)
				var/obj/machinery/alarm/air_alarm = alarm_source.source
				if(istype(air_alarm))
					air_alarm.reset_alarm()

	return TRUE
