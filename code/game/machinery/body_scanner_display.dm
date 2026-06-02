/obj/machinery/body_scan_display
	name = "body scan display"
	desc = "A wall-mounted display linked to a body scanner."
	icon = 'icons/obj/machines/modular_telescreen.dmi'
	icon_state = "operating"
	var/icon_state_unpowered = "telescreen"
	anchored = TRUE
	density = FALSE
	idle_power_usage = 75
	active_power_usage = 300
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0
	w_class = ITEM_SIZE_HUGE

	machine_name = "body scanner display"
	machine_desc = "Receives body scans from a linked body scanner and allows them to be viewed remotely."

	var/list/bodyscans = list()
	var/selected = 0

/obj/machinery/body_scan_display/proc/add_new_scan(list/scan)
	bodyscans += list(scan.Copy())
	updateUsrDialog()

/obj/machinery/body_scan_display/interface_interact(user)
	ui_interact(user)
	return TRUE

/obj/machinery/body_scan_display/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "BodyScannerDisplay", "Body Scan Display Console", ui)

/obj/machinery/body_scan_display/ui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/body_scan_display/ui_data(mob/user)
	var/list/data = list()
	var/list/scan_list = list()
	for(var/list/scan in bodyscans)
		scan_list += list(list(
			"name" = scan["name"] || "Unknown",
			"time" = scan["time"] || ""
		))
	data["scans"] = scan_list
	data["selected"] = selected
	if(selected > 0)
		data["scan_header"] = display_medical_data_header(bodyscans[selected], user.get_skill_value(SKILL_MEDICAL))
		data["scan_health"] = display_medical_data_health(bodyscans[selected], user.get_skill_value(SKILL_MEDICAL))
		data["scan_body"] = display_medical_data_body(bodyscans[selected], user.get_skill_value(SKILL_MEDICAL))
	else
		data["scan_header"] = ""
		data["scan_health"] = ""
		data["scan_body"] = ""
	return data

/obj/machinery/body_scan_display/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("view")
			var/selection = text2num(params["view"])
			if(is_valid_index(selection, bodyscans))
				selected = selection
				return TRUE
		if("delete")
			var/selection = text2num(params["delete"])
			if(!is_valid_index(selection, bodyscans))
				return FALSE
			if(selected == selection)
				selected = 0
			else if(selected > selection)
				selected--
			bodyscans -= list(bodyscans[selection])
			return TRUE
	return FALSE
