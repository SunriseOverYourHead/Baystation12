/obj/machinery/computer/fusion/core_control
	name = "\improper R-UST Mk. 8 core control"

/obj/machinery/computer/fusion/core_control/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "FusionCoreControl", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/fusion/core_control/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	var/obj/machinery/power/fusion_core/C = locate(params["machine"])
	if(!istype(C))
		return
	var/datum/local_network/lan = get_local_network()
	if(!lan || !lan.is_connected(C))
		return
	if(!C.check_core_status())
		return
	if(action == "toggle_active")
		if(!C.Startup())
			if(!C.owned_field.is_shutdown_safe())
				if(alert(usr, "Shutting down this fusion core without proper safety procedures will cause serious damage, do you wish to continue?", "Shut Down?", "Yes", "No") == "No")
					return
			C.Shutdown()
		. = TRUE
	else if(action == "str")
		var/val = text2num(params["str"])
		if(val)
			C.set_strength(C.field_strength + val)
			. = TRUE
	else if(action == "set_strength")
		var/val = text2num(params["value"])
		if(val)
			C.set_strength(val)
			. = TRUE

/obj/machinery/computer/fusion/core_control/build_ui_data()
	. = ..()
	var/datum/extension/local_network_member/fusion = get_extension(src, /datum/extension/local_network_member)
	var/datum/local_network/lan = fusion.get_local_network()
	var/list/cores = list()
	if(lan)
		var/list/fusion_cores = lan.get_devices(/obj/machinery/power/fusion_core)
		for(var/i = 1 to LAZYLEN(fusion_cores))
			var/list/core = list()
			var/obj/machinery/power/fusion_core/C = fusion_cores[i]
			core["id"] =          "#[i]"
			core["ref"] =         "\ref[C]"
			core["field"] =       !isnull(C.owned_field)
			core["power"] =       "[C.field_strength/10.0] tesla"
			core["size"] =        C.owned_field ? "[C.owned_field.size] meter\s" : "Field offline."
			core["instability"] = C.owned_field ? "[C.owned_field.percent_unstable * 100]%" : "Field offline."
			core["temperature"] = C.owned_field ? "[C.owned_field.plasma_temperature + 295]K" : "Field offline."
			core["powerstatus"] = "[C.avail()]/[C.active_power_usage] W"
			var/list/fuel_list = list()
			if(C.owned_field && LAZYLEN(C.owned_field.reactants))
				for(var/reactant in C.owned_field.reactants)
					fuel_list += list(list("name" = reactant, "amount" = C.owned_field.reactants[reactant]))
			core["fuel"] = fuel_list

			cores += list(core)
	.["cores"] = cores
