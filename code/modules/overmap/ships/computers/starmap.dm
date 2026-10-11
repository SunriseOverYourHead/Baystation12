#define RETURN_TO_PORT_BUTTON_COOLDOWN (5 MINUTES)
#define RETURN_TO_PORT_MINIMUM_ROUND_TIME (30 MINUTES)

/obj/machinery/computer/ship/galaxymap
	name = "galaxy map console"
	desc = "Displays charted star systems and drives the ship's bluespace jump sequencer."
	icon_keyboard = "teleport_key"
	icon_screen = "teleport"
	light_color = "#77fff8"
	machine_name = "galaxy map console"
	machine_desc = "Charts nearby star systems and, paired with an operational bluespace drive, lets the crew jump between them."
	health_max = 100

	/// world.time of the last Return to Port / Cancel Return to Port press from THIS console specifically - a
	/// simple, predictable anti-spam throttle independent of (and in addition to) whatever cooldown the
	/// evacuation controller itself might already be running (see evac_cooldown_time in evacuation.dm, which
	/// scales with how long a prior attempt had been running before being cancelled - not something this UI
	/// tries to explain moment-to-moment, since it's a separate, coarser mechanic).
	var/last_return_to_port_press = 0

/obj/machinery/computer/ship/galaxymap/proc/return_to_port_cooldown_remaining()
	return max(0, RETURN_TO_PORT_BUTTON_COOLDOWN - (world.time - last_return_to_port_press))

/// Return to Port additionally requires the round to have been running for at least 30 minutes, on top of
/// whatever the bluespace drive's own jump cooldown is currently doing - stops it being used as a loophole
/// around that cooldown, and stops it being called literally at round start. Independent of
/// return_to_port_cooldown_remaining()'s own per-button anti-spam throttle above.
/obj/machinery/computer/ship/galaxymap/proc/return_to_port_locked_remaining()
	. = max(0, RETURN_TO_PORT_MINIMUM_ROUND_TIME - round_duration_in_ticks)
	. = max(., SSstarmap.cooldown_remaining())

/obj/machinery/computer/ship/galaxymap/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "Starmap", "Galaxy Map", ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/ship/galaxymap/ui_data(mob/user)
	var/list/data = list()
	var/obj/machinery/bluespacedrive/drive = SSstarmap.get_drive(GLOB.using_map.station_levels)
	if (!drive)
		data["drive_status"] = "NOT DETECTED"
	else if (HAS_FLAGS(drive.state, drive.STATE_BROKEN))
		data["drive_status"] = "DAMAGED"
	else if (!drive.powered())
		data["drive_status"] = "NO POWER"
	else
		data["drive_status"] = "READY"

	data["jumping"] = SSstarmap.jumping
	data["in_transit"] = SSstarmap.in_transit
	data["current_ref"] = "\ref[SSstarmap.current]"
	data["cooldown_remaining"] = round(SSstarmap.cooldown_remaining() / 10)
	data["cooldown_total"] = round(SSstarmap.cooldown_total() / 10)
	data["jump_target_name"] = SSstarmap.current_jump_target?.name
	data["jump_time_remaining"] = SSstarmap.jumping ? round(max(0, SSstarmap.jump_completes_at - world.time) / 10) : 0
	data["jump_phase_total"] = round(SSstarmap.current_phase_duration() / 10)

	var/list/systems = list()
	for (var/datum/star_system/system as anything in GLOB.star_systems)
		var/list/connections = list()
		for (var/datum/star_system/other as anything in system.connections)
			connections += "\ref[other]"
		systems.Add(list(list(
			"ref" = "\ref[system]",
			"name" = system.name,
			"is_current" = (system == SSstarmap.current),
			"adjacent" = system.is_adjacent(SSstarmap.current),
			"explored" = system.generated,
			"cached" = system.cached,
			"connections" = connections,
		)))
	data["systems"] = systems

	if (!evacuation_controller)
		data["return_to_port_state"] = "unavailable"
	else if (evacuation_controller.is_idle())
		data["return_to_port_state"] = "idle"
	else if (evacuation_controller.is_on_cooldown())
		data["return_to_port_state"] = "controller_cooldown"
	else if (evacuation_controller.emergency_evacuation)
		data["return_to_port_state"] = "emergency_active"
	else if (evacuation_controller.can_cancel())
		data["return_to_port_state"] = "can_cancel"
	else
		data["return_to_port_state"] = "in_progress"
	data["return_to_port_button_cooldown_remaining"] = round(return_to_port_cooldown_remaining() / 10)
	data["return_to_port_button_cooldown_total"] = round(RETURN_TO_PORT_BUTTON_COOLDOWN / 10)
	data["return_to_port_locked_remaining"] = round(return_to_port_locked_remaining() / 10)

	return data

/obj/machinery/computer/ship/galaxymap/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/mob/user = ui.user

	switch (action)
		if ("jump")
			var/datum/star_system/target = locate(params["target"])
			if (!istype(target))
				return TRUE
			if (SSstarmap.initiate_jump(target, user))
				log_and_message_admins("initiated a bluespace jump to [target.name] via [src].", user)
			return TRUE
		if ("cancel_jump")
			if (SSstarmap.cancel_jump(user))
				log_and_message_admins("cancelled the in-progress bluespace jump via [src].", user)
			return TRUE
		if ("return_to_port")
			if (return_to_port_cooldown_remaining() > 0 || return_to_port_locked_remaining() > 0 || !evacuation_controller?.is_idle())
				return TRUE
			for (var/datum/evacuation_option/EO in evacuation_controller.available_evac_options())
				if (istype(EO, /datum/evacuation_option/bluespace_jump))
					evacuation_controller.handle_evac_option(EO.option_target, user)
					last_return_to_port_press = world.time
					log_and_message_admins("initiated the return to port via [src].", user)
					break
			return TRUE
		if ("cancel_return_to_port")
			if (return_to_port_cooldown_remaining() > 0 || !evacuation_controller?.can_cancel())
				return TRUE
			for (var/datum/evacuation_option/EO in evacuation_controller.available_evac_options())
				if (istype(EO, /datum/evacuation_option/cancel_bluespace_jump))
					evacuation_controller.handle_evac_option(EO.option_target, user)
					last_return_to_port_press = world.time
					log_and_message_admins("cancelled the return to port via [src].", user)
					break
			return TRUE

#undef RETURN_TO_PORT_BUTTON_COOLDOWN
#undef RETURN_TO_PORT_MINIMUM_ROUND_TIME
