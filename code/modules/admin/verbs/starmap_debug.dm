// Admin-only testing aid for the in-round bluespace jump / round-end feature set (code/modules/overmap/sector_jump.dm,
// code/controllers/evacuation/, code/game/machinery/nuclear_bomb.dm). Lets staff skip the tedious parts (waiting out
// real timers, physically arming self-destruct inserters) while testing those systems. Nothing here is available to
// non-admins - gated the same way as every other Debug-category admin verb, via the admin_verbs_debug allowlist.

var/global/datum/starmap_debug_panel/starmap_debug_panel_instance

/client/proc/starmap_debug_panel()
	set category = "Debug"
	set name = "Starmap Debug Panel"

	if (!check_rights(R_DEBUG))
		return
	if (!starmap_debug_panel_instance)
		starmap_debug_panel_instance = new()
	starmap_debug_panel_instance.ui_interact(mob)

/// Bypasses the normal 6-inserter physical arming requirement (see nuclearbomb/station/start_bomb() in
/// nuclear_bomb.dm) - this is purely a testing shortcut, so it skips straight to the armed, counting-down state
/// start_bomb() would otherwise leave the bomb in.
/obj/machinery/nuclearbomb/station/proc/debug_force_arm(seconds)
	timeleft = world.time + max(1, seconds) * 10
	timing = 1
	safety = FALSE
	bomb_set++
	var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
	original_level = security_state.current_security_level
	security_state.set_security_level(security_state.severe_security_level, TRUE)
	update_icon()

/// Unlike secure_device(), this ignores the self_destruct_cutoff "no take-backs" window - a testing tool
/// shouldn't be stuck honoring the same in-character point-of-no-return a normal disarm attempt would.
/obj/machinery/nuclearbomb/station/proc/debug_force_disarm()
	timing = 0
	update_icon()

/datum/starmap_debug_panel/ui_state(mob/user)
	return GLOB.tgui_holder_state

/datum/starmap_debug_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "StarmapDebugPanel", "Starmap Debug Panel", ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/datum/starmap_debug_panel/ui_data(mob/user)
	var/list/data = list()

	data["jump_cooldown_remaining"] = round(SSstarmap.cooldown_remaining() / 10)
	data["jumping"] = SSstarmap.jumping
	data["jump_remaining"] = SSstarmap.jumping ? round(max(0, SSstarmap.jump_completes_at - world.time) / 10) : 0

	var/obj/machinery/nuclearbomb/station/nuke = locate(/obj/machinery/nuclearbomb/station) in world
	data["nuke_found"] = !!nuke
	data["nuke_timing"] = nuke ? nuke.timing : 0
	data["nuke_remaining"] = (nuke && nuke.timing > 0) ? round(max(0, nuke.timeleft - world.time) / 10) : 0

	data["evac_found"] = !!evacuation_controller
	data["evac_state"] = evacuation_controller ? evacuation_controller.state : 0 // 0 is EVAC_IDLE - not visible outside code/controllers/evacuation/, see ~evac.dm
	data["evac_emergency"] = evacuation_controller ? !!evacuation_controller.emergency_evacuation : FALSE
	data["evac_remaining"] = evacuation_controller ? round(max(0, get_evac_next_time(evacuation_controller) - world.time) / 10) : 0

	return data

/datum/starmap_debug_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	if (!check_rights(R_DEBUG))
		return TRUE

	var/mob/user = ui.user
	var/seconds = text2num(params["value"])

	switch (action)
		if ("set_jump_cooldown")
			if (isnull(seconds))
				return TRUE
			SSstarmap.last_jump_time = world.time - (SSstarmap.cooldown_total() - max(0, seconds) * 10)
			log_and_message_admins("set the bluespace jump cooldown to [seconds]s via the starmap debug panel.", user)
			return TRUE

		if ("set_jump_remaining")
			if (isnull(seconds) || !SSstarmap.jumping)
				return TRUE
			SSstarmap.jump_completes_at = world.time + max(0, seconds) * 10
			log_and_message_admins("set the in-progress bluespace jump's remaining time to [seconds]s via the starmap debug panel.", user)
			return TRUE

		if ("force_arm_nuke")
			var/obj/machinery/nuclearbomb/station/nuke = locate(/obj/machinery/nuclearbomb/station) in world
			if (!nuke || isnull(seconds))
				return TRUE
			nuke.debug_force_arm(seconds)
			log_and_message_admins("force-armed the self-destruct with a [seconds]s timer via the starmap debug panel.", user)
			return TRUE

		if ("set_nuke_remaining")
			var/obj/machinery/nuclearbomb/station/nuke = locate(/obj/machinery/nuclearbomb/station) in world
			if (!nuke || !nuke.timing || isnull(seconds))
				return TRUE
			nuke.timeleft = world.time + max(0, seconds) * 10
			log_and_message_admins("set the self-destruct's remaining time to [seconds]s via the starmap debug panel.", user)
			return TRUE

		if ("force_disarm_nuke")
			var/obj/machinery/nuclearbomb/station/nuke = locate(/obj/machinery/nuclearbomb/station) in world
			if (!nuke)
				return TRUE
			nuke.debug_force_disarm()
			log_and_message_admins("force-disarmed the self-destruct via the starmap debug panel.", user)
			return TRUE

		if ("start_evac")
			if (!evacuation_controller || isnull(seconds))
				return TRUE
			if (evacuation_controller.call_evacuation(user, TRUE, forced = TRUE))
				set_evac_next_time(evacuation_controller, world.time + max(0, seconds) * 10)
				log_and_message_admins("force-started an emergency evac sequence with a [seconds]s timer via the starmap debug panel.", user)
			return TRUE

		if ("return_to_port")
			if (!evacuation_controller)
				return TRUE
			if (evacuation_controller.call_evacuation(user, FALSE, forced = TRUE))
				log_and_message_admins("force-initiated the return to port via the starmap debug panel.", user)
			return TRUE

		if ("set_evac_remaining")
			if (!evacuation_controller || evacuation_controller.is_idle() || isnull(seconds))
				return TRUE
			set_evac_next_time(evacuation_controller, world.time + max(0, seconds) * 10)
			log_and_message_admins("set the evac sequence's remaining time to [seconds]s via the starmap debug panel.", user)
			return TRUE

		if ("cancel_evac")
			if (evacuation_controller?.cancel_evacuation())
				log_and_message_admins("force-cancelled the evac sequence via the starmap debug panel.", user)
			return TRUE
