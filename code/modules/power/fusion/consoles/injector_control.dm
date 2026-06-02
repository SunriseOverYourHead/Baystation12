/obj/machinery/computer/fusion/fuel_control
	name = "fuel injection control computer"
	icon_keyboard = "rd_key"
	icon_screen = "fuel_screen"

/obj/machinery/computer/fusion/fuel_control/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "FusionFuelControl", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/fusion/fuel_control/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	var/datum/local_network/lan = get_local_network()
	var/list/fuel_injectors = lan ? lan.get_devices(/obj/machinery/fusion_fuel_injector) : null
	if(action == "global_toggle")
		if(!lan || !fuel_injectors)
			return
		for(var/obj/machinery/fusion_fuel_injector/F in fuel_injectors)
			if(F.injecting)
				F.StopInjecting()
			else
				F.BeginInjecting()
		. = TRUE
	else if(action == "global_rate")
		if(!lan || !fuel_injectors)
			return
		var/new_rate = text2num(params["value"])
		if(!new_rate)
			return
		var/clamped = clamp(new_rate, 1, 100) / 100
		for(var/obj/machinery/fusion_fuel_injector/F as anything in fuel_injectors)
			F.injection_rate = clamped
		. = TRUE
	else if(action == "toggle_injecting")
		var/obj/machinery/fusion_fuel_injector/I = locate(params["toggle_injecting"])
		if(!istype(I) || !lan || !fuel_injectors || !fuel_injectors[I])
			return
		if(I.injecting)
			I.StopInjecting()
		else
			I.BeginInjecting()
		. = TRUE
	else if(action == "injection_rate")
		var/obj/machinery/fusion_fuel_injector/I = locate(params["machine"])
		if(!istype(I) || !lan || !fuel_injectors || !fuel_injectors[I])
			return
		var/new_rate = text2num(params["value"])
		if(!new_rate)
			return
		I.injection_rate = clamp(new_rate, 1, 100) / 100
		. = TRUE

/obj/machinery/computer/fusion/fuel_control/build_ui_data()
	. = ..()
	var/datum/extension/local_network_member/fusion = get_extension(src, /datum/extension/local_network_member)
	var/datum/local_network/lan = fusion.get_local_network()
	var/list/injectors = list()
	if(lan)
		var/list/fuel_injectors = lan.get_devices(/obj/machinery/fusion_fuel_injector)
		for(var/i = 1 to LAZYLEN(fuel_injectors))
			var/list/injector = list()
			var/obj/machinery/fusion_fuel_injector/I = fuel_injectors[i]
			injector["id"] =       "#[i]"
			injector["ref"] =       "\ref[I]"
			injector["injecting"] =  I.injecting
			injector["fueltype"] =  "[I.cur_assembly ? I.cur_assembly.fuel_type : "No Fuel Inserted"]"
			injector["depletion"] = "[I.cur_assembly ? (I.cur_assembly.percent_depleted * 100) : 100]%"
			injector["injection_rate"] = "[I.injection_rate * 100]%"
			injectors += list(injector)
	.["injectors"] = injectors
