/obj/machinery/computer/fusion/gyrotron
	name = "gyrotron control console"
	icon_keyboard = "med_key"
	icon_screen = "gyrotron_screen"
	light_color = COLOR_BLUE

/obj/machinery/computer/fusion/gyrotron/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "FusionGyrotronControl", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/fusion/gyrotron/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	var/obj/machinery/power/emitter/gyrotron/G = locate(params["machine"])
	if(!istype(G))
		return
	var/datum/local_network/lan = get_local_network()
	var/list/gyrotrons = lan ? lan.get_devices(/obj/machinery/power/emitter/gyrotron) : null
	if(!lan || !gyrotrons || !gyrotrons[G])
		return
	if(action == "modifypower")
		var/new_val = text2num(params["value"])
		if(!new_val)
			to_chat(usr, SPAN_WARNING("That's not a valid number."))
			return
		G.mega_energy = clamp(new_val, 1, 50)
		G.change_power_consumption(G.mega_energy * 1500, POWER_USE_ACTIVE)
		. = TRUE
	else if(action == "modifyrate")
		var/new_val = text2num(params["value"])
		if(!new_val)
			to_chat(usr, SPAN_WARNING("That's not a valid number."))
			return
		G.rate = clamp(new_val, 2, 10)
		. = TRUE
	else if(action == "toggle")
		G.activate(usr)
		. = TRUE

/obj/machinery/computer/fusion/gyrotron/build_ui_data()
	. = ..()
	var/datum/extension/local_network_member/fusion = get_extension(src, /datum/extension/local_network_member)
	var/datum/local_network/lan = fusion.get_local_network()
	var/list/gyrotrons = list()
	if(lan && gyrotrons)
		var/list/lan_gyrotrons = lan.get_devices(/obj/machinery/power/emitter/gyrotron)
		for(var/i = 1 to LAZYLEN(lan_gyrotrons))
			var/list/gyrotron = list()
			var/obj/machinery/power/emitter/gyrotron/G = lan_gyrotrons[i]
			gyrotron["id"] =        "#[i]"
			gyrotron["ref"] =       "\ref[G]"
			gyrotron["active"] =    G.active
			gyrotron["firedelay"] = G.rate
			gyrotron["energy"] = G.mega_energy
			gyrotrons += list(gyrotron)
	.["gyrotrons"] = gyrotrons
