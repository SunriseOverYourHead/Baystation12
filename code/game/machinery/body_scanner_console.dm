/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/stored_scan_subject
	name = "body scanner console"
	desc = "A small terminal used to operate an adjacent body scanner, view the results of a scan, and send those results to connected medical displays."
	icon = 'icons/obj/machines/medical/bodyscanner.dmi'
	icon_state = "body_scanner_console"
	density = FALSE
	anchored = TRUE
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0

	machine_name = "body scanner console"
	machine_desc = "A small touchscreen terminal, used to operate an adjacent body scanner, as well as viewing and manipulating its readouts."

	var/list/connected_displays = list()
	var/list/data = list()
	var/scan_data

/obj/machinery/body_scanconsole/Initialize()
	. = ..()
	FindScanner()
	update_icon()

/obj/machinery/body_scanconsole/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if(!connected?.inoperable())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")

/obj/machinery/body_scanconsole/ex_act(severity)

	switch(severity)
		if(EX_ACT_DEVASTATING)
			qdel(src)
		if(EX_ACT_HEAVY)
			if (prob(50))
				qdel(src)

/obj/machinery/body_scanconsole/proc/FindScanner()
	for(var/D in GLOB.cardinal)
		connected = locate(/obj/machinery/bodyscanner, get_step(src, D))
		if(connected)
			break
		GLOB.destroyed_event.register(connected, src, PROC_REF(unlink_scanner))
	update_icon()

/obj/machinery/body_scanconsole/proc/unlink_scanner(obj/machinery/bodyscanner/scanner)
	GLOB.destroyed_event.unregister(scanner, src, PROC_REF(unlink_scanner))
	connected = null
	update_icon()

/obj/machinery/body_scanconsole/proc/FindDisplays()
	for(var/obj/machinery/body_scan_display/D in SSmachines.machinery)
		if (AreConnectedZLevels(D.z, z))
			connected_displays += D
			GLOB.destroyed_event.register(D, src, PROC_REF(remove_display))
	return !!length(connected_displays)

/obj/machinery/body_scanconsole/attack_hand(mob/user)
	if(!connected || connected.inoperable())
		to_chat(user, SPAN_WARNING("This console is not connected to a functioning body scanner."))
		return TRUE
	return ..()

/obj/machinery/body_scanconsole/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/body_scanconsole/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "BodyScanner", "Body Scanner", ui)

/obj/machinery/body_scanconsole/ui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/body_scanconsole/ui_data(mob/user)
	var/list/d = list()
	d["scanEnabled"] = !!(connected && connected.occupant)
	d["isCompatible"] = !!(connected && connected.occupant && ishuman(connected.occupant))
	d["printEnabled"] = !!data["scan"]
	d["eraseEnabled"] = !!data["scan"]
	d["pushEnabled"] = !!data["scan"]
	if(!data["scan"])
		d["html_scan_header"] = ""
		d["html_scan_health"] = ""
		d["html_scan_body"] = ""
	else
		d["html_scan_header"] = display_medical_data_header(data["scan"], user.get_skill_value(SKILL_MEDICAL))
		d["html_scan_health"] = display_medical_data_health(data["scan"], user.get_skill_value(SKILL_MEDICAL))
		d["html_scan_body"] = display_medical_data_body(data["scan"], user.get_skill_value(SKILL_MEDICAL))
	return d

/obj/machinery/body_scanconsole/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("scan")
			if(!connected || !connected.occupant)
				to_chat(usr, SPAN_WARNING("[icon2html(src, usr)]The body scanner is empty."))
				return TRUE
			if(!ishuman(connected.occupant))
				to_chat(usr, SPAN_WARNING("[icon2html(src, usr)]The body scanner cannot scan that lifeform."))
				return TRUE
			data["scan"] = connected.occupant.get_raw_medical_data(TRUE, connected.scan_for_present_mutations)
			stored_scan_subject = connected.occupant
			usr.visible_message(
				SPAN_NOTICE("\The [usr] performs a scan of \the [connected.occupant] using \the [initial(connected.name)]."),
				SPAN_NOTICE("You run a full-body diagnostic of \the [connected.occupant] using \the [initial(connected.name)]."),
				SPAN_ITALIC("You hear a series of beeps, followed by a deep humming sound.")
			)
			playsound(connected.loc, 'sound/machines/medbayscanner.ogg', 50)
			return TRUE
		if("print")
			if(!data["scan"])
				to_chat(usr, SPAN_WARNING("[icon2html(src, usr)]Error: No scan stored."))
				return TRUE
			var/list/scan = data["scan"]
			new /obj/item/paper/bodyscan(loc, "Printout error.", "Body scan report - [stored_scan_subject]", scan.Copy())
			return TRUE
		if("push")
			if(!length(connected_displays) && !FindDisplays())
				to_chat(usr, SPAN_WARNING("[icon2html(src, usr)]Error: No configured displays detected."))
				return TRUE
			for(var/obj/machinery/body_scan_display/D in connected_displays)
				D.add_new_scan(data["scan"])
			usr.visible_message(
				SPAN_NOTICE("\The [usr] keys a command into \the [src]."),
				SPAN_NOTICE("The console beeps, confirming it has successfully sent the scan to the connected displays."),
				SPAN_ITALIC("You hear someone typing on a terminal, then a beep.")
			)
			return TRUE
		if("erase")
			data["scan"] = null
			stored_scan_subject = null
			return TRUE
	return FALSE

/obj/machinery/body_scanconsole/state_transition(singleton/machine_construction/default/new_state)
	. = ..()
	if(istype(new_state))
		updateUsrDialog()

/obj/machinery/body_scanconsole/proc/remove_display(obj/machinery/body_scan_display/display)
	connected_displays -= display
	GLOB.destroyed_event.unregister(display, src, PROC_REF(remove_display))

/obj/machinery/body_scanconsole/Destroy()
	. = ..()
	for(var/D in connected_displays)
		remove_display(D)
	unlink_scanner(connected)
