/obj/machinery/ntnet_relay
	name = "\improper NTNet quantum relay"
	desc = "A very complex router and transmitter capable of connecting electronic devices together. Looks fragile."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "relay"
	use_power = POWER_USE_ACTIVE
	active_power_usage = 20000 //20kW, apropriate for machine that keeps massive cross-Zlevel wireless network operational.
	idle_power_usage = 100
	icon_state = "relay"
	anchored = TRUE
	density = TRUE
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0
	machine_name = "\improper NTNet quantum relay"
	machine_desc = "Maintains a copy of proprietary software used to provide NTNet service to all valid devices in the region. Essentially a huge router."

	/// Set to FALSE if the relay was turned off
	var/enabled = TRUE

	/// Set to TRUE if the relay failed due to (D)DoS attack
	var/dos_failure = FALSE

	/// List of backwards reference for qdel() stuff
	var/list/dos_sources = list()

	/// Amount of DoS "packets" in this relay's buffer.
	var/dos_overload = 0

	/// Amount of DoS "packets" in buffer required to crash the relay.
	var/dos_capacity = 500

	/// Amount of DoS "packets" dissipated over time.
	var/dos_dissipate = 1

	var/relay_id


/obj/machinery/ntnet_relay/Destroy()
	if (ntnet_global)
		ntnet_global.relays -= src
		ntnet_global.add_log("Quantum Relay ([relay_id]) connection severed. Current amount of linked relays: [length(ntnet_global.relays)]")
	for (var/datum/computer_file/program/ntnet_dos/D in dos_sources)
		D.target = null
		D.error = "Connection to quantum relay severed"
	LAZYCLEARLIST(dos_sources)
	return ..()


/obj/machinery/ntnet_relay/Initialize()
	. = ..()
	relay_id = random_id("netnet_relay", 1, 999)
	if (ntnet_global)
		ntnet_global.relays += src
		ntnet_global.add_log("New Quantum Relay ([relay_id]) activated. Current amount of linked relays: [length(ntnet_global.relays)]")
	update_icon()


/obj/machinery/ntnet_relay/operable()
	if (!enabled)
		return FALSE
	if (dos_failure)
		return FALSE
	if (inoperable(MACHINE_STAT_EMPED))
		return FALSE
	return TRUE


/obj/machinery/ntnet_relay/on_update_icon()
	ClearOverlays()
	if (operable())
		AddOverlays(list(
			"relay_lights_working",
			emissive_appearance(icon, "relay_lights_working")
		))
	if (panel_open)
		AddOverlays("relay_panel")


/obj/machinery/ntnet_relay/Process()
	if (dos_overload)
		dos_overload = max(0, dos_overload - dos_dissipate)
	if (dos_failure)
		if (!dos_overload)
			dos_failure = FALSE
			ntnet_global.add_log("Quantum relay ([relay_id]) switched from overload recovery mode to normal operation mode.")
	else if (dos_overload > dos_capacity)
		dos_failure = TRUE
		ntnet_global.add_log("Quantum relay ([relay_id]) switched from normal operation mode to overload recovery mode.")
	if (operable())
		update_use_power(POWER_USE_ACTIVE)
	else
		update_use_power(POWER_USE_IDLE)
	update_icon()


/obj/machinery/ntnet_relay/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "NtnetRelay", "NTNet Quantum Relay", ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/ntnet_relay/ui_data(mob/user)
	return list(
		"enabled" = enabled,
		"dos_capacity" = dos_capacity,
		"dos_overload" = dos_overload,
		"dos_crashed" = dos_failure
	)

/obj/machinery/ntnet_relay/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/ntnet_relay/interface_interact(mob/living/user)
	ui_interact(user)
	return TRUE

/obj/machinery/ntnet_relay/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle")
			enabled = !enabled
			ntnet_global.add_log("Quantum relay ([relay_id]) manually [enabled ? "enabled" : "disabled"].")
			update_icon()
			return TRUE
		if("restart")
			dos_overload = 0
			dos_failure = FALSE
			update_icon()
			ntnet_global.add_log("Quantum relay ([relay_id]) manually restarted from overload recovery mode to normal operation mode.")
			return TRUE
	return FALSE
