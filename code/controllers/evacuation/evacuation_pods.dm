#define EVAC_OPT_ABANDON_SHIP "abandon_ship"
#define EVAC_OPT_BLUESPACE_JUMP "bluespace_jump"
#define EVAC_OPT_CANCEL_ABANDON_SHIP "cancel_abandon_ship"
#define EVAC_OPT_CANCEL_BLUESPACE_JUMP "cancel_bluespace_jump"

// Apparently, emergency_evacuation --> "abandon ship" and !emergency_evacuation --> "bluespace jump"
// That stuff should be moved to the evacuation option datums but someone can do that later
/datum/evacuation_controller/starship
	name = "escape pod controller"

	evac_prep_delay    = 5 MINUTES
	evac_launch_delay  = 3 MINUTES
	evac_transit_delay = 2 MINUTES

	// Only meaningful for the emergency (abandon ship) path - see call_evacuation() below, which bypasses this
	// class's stacked prep-delay math entirely for the calm Return to Port jump in favour of a flat five minutes.
	emergency_prep_additional_delay    = 0 MINUTES

	evacuation_options = list(
		EVAC_OPT_ABANDON_SHIP = new /datum/evacuation_option/abandon_ship(),
		EVAC_OPT_BLUESPACE_JUMP = new /datum/evacuation_option/bluespace_jump(),
		EVAC_OPT_CANCEL_ABANDON_SHIP = new /datum/evacuation_option/cancel_abandon_ship(),
		EVAC_OPT_CANCEL_BLUESPACE_JUMP = new /datum/evacuation_option/cancel_bluespace_jump()
	)

/datum/evacuation_controller/starship/can_evacuate(mob/user, forced)
	if(SSstarmap.jumping)
		to_chat(user, SPAN_WARNING("The ship's systems are consumed by an active bluespace jump. Evacuation cannot be called until it resolves."))
		return FALSE
	return ..()

// Return to Port (calm, round-ending bluespace jump home): flat five-minute spool-up instead of stacking
// evac_launch_delay and transfer_prep_additional_delay/autotransfer_prep_additional_delay on top of
// evac_prep_delay (previously ~20-25 minutes total), with a single merged "spooling up" announcement (sent
// here) instead of separate call/prep-complete messages - mirrors the in-round galaxy console jump's own
// pacing (SECTOR_JUMP_SPOOLUP_DURATION/TRANSIT_DURATION in code/modules/overmap/sector_jump.dm). Emergency
// (abandon ship) calls are untouched, falling straight through to the base implementation.
/datum/evacuation_controller/starship/call_evacuation(mob/user, _emergency_evac, forced, skip_announce, autotransfer)
	. = ..(user, _emergency_evac, forced, TRUE, autotransfer)
	if(!. || _emergency_evac)
		return .

	evac_ready_time =   evac_called_at + 5 MINUTES
	evac_no_return =    evac_called_at + round(5 MINUTES / 2)
	evac_launch_time =  evac_ready_time
	evac_arrival_time = evac_launch_time + evac_transit_delay

	var/evac_range = round((evac_launch_time - evac_called_at)/3)
	auto_recall_time = rand(evac_called_at + evac_range, evac_launch_time - evac_range)

	if(!skip_announce)
		priority_announcement.Announce(replacetext(replacetext(GLOB.using_map.shuttle_called_message, "%dock_name%", "[GLOB.using_map.dock_name]"),  "%ETA%", "[round(get_eta()/60,0.5)] minute\s"))

	return .

/datum/evacuation_controller/starship/finish_preparing_evac()
	if(!emergency_evacuation)
		// The "jump preparation complete" announcement the base implementation would send here has been merged
		// into the single spooling-up message sent from call_evacuation() above - there's no separate launching
		// phase to wait through, so go straight to transit instead of leaving it to process() to notice
		// evac_launch_time elapsed on some later tick (which, among other things, wouldn't stay in sync with
		// evac_ready_time if something - e.g. the starmap debug panel - adjusts one but not the other).
		launch_evacuation()
		return

	. = ..()
	// Arm the escape pods.
	for (var/datum/shuttle/autodock/ferry/escape_pod/pod in escape_pods)
		if (pod.arming_controller)
			pod.arming_controller.arm()

/datum/evacuation_controller/starship/launch_evacuation()

	state = EVAC_IN_TRANSIT

	if (emergency_evacuation)
		// Abondon Ship
		for (var/datum/shuttle/autodock/ferry/escape_pod/pod in escape_pods) // Launch the pods!
			if (!pod.arming_controller || pod.arming_controller.armed)
				pod.move_time = (evac_transit_delay/10)
				pod.launch(src)

		priority_announcement.Announce(replacetext(replacetext(GLOB.using_map.emergency_shuttle_leaving_dock, "%dock_name%", "[GLOB.using_map.dock_name]"),  "%ETA%", "[round(get_eta()/60,0.5)] minute\s"))
	else
		// Bluespace Jump - the transit phase starts now (after prep/spool-up), so this is also where any overmap
		// hazard field the Torch is currently sitting in gets cleared, same as the in-round galaxy console jump's
		// begin_transit() (code/modules/overmap/sector_jump.dm) - any bluespace jump clears hazards the instant
		// the actual jump begins, not just the console-driven one.
		var/obj/overmap/visitable/ship/torch/torch = SSshuttle.ship_by_type(/obj/overmap/visitable/ship/torch)
		if (torch)
			SSstarmap.clear_overmap_hazards(torch)
			// Same "cascade" transit skybox the in-round galaxy console jump shows (see begin_transit() in
			// sector_jump.dm) - this flavor never moves the Torch to a private transit grid, so just its own
			// interior decks need it, not jump_affected_zlevels()'s transit-z addition.
			SSskybox.set_zlevel_override(GLOB.using_map.station_levels, "cascade")
		priority_announcement.Announce(replacetext(replacetext(GLOB.using_map.shuttle_leaving_dock, "%dock_name%", "[GLOB.using_map.dock_name]"),  "%ETA%", "[round(get_eta()/60,0.5)] minute\s"))
		// NOT /datum/universal_state/bluespace_jump - its OnEnter() deletes the Torch's own overmap object
		// (GLOB.using_map.ship_jump()) and pulls its z-levels out of accessible_z_levels, both fine for the
		// original round-ending-only design but actively broken now that crew keep playing for several more
		// minutes: every console linked to the ship loses its connection permanently, since there's no longer a
		// ship object for sync_linked() to ever find again. begin_bluespace_transit() is the same shared setup
		// the in-round console jump uses (see sector_jump.dm) - bluespaced crew, ghost visibility, ongoing
		// straggler ejection/exposure damage - without touching the ship or its accessibility at all.
		SSstarmap.begin_bluespace_transit()

/datum/evacuation_controller/starship/finish_evacuation()
	..()
	if(!emergency_evacuation) //bluespace jump
		var/obj/overmap/visitable/ship/torch/torch = SSshuttle.ship_by_type(/obj/overmap/visitable/ship/torch)
		if (torch)
			SSskybox.clear_zlevel_override(GLOB.using_map.station_levels)
			SSstarmap.arrive_at_home_port(torch)
		SSstarmap.end_bluespace_transit() //clears bluespaced crew effects and the scoped jump state - see begin_bluespace_transit()

/datum/evacuation_controller/starship/available_evac_options()
	if (is_on_cooldown())
		return list()
	if (is_idle())
		return list(evacuation_options[EVAC_OPT_BLUESPACE_JUMP], evacuation_options[EVAC_OPT_ABANDON_SHIP])
	if (is_evacuating())
		if (emergency_evacuation)
			return list(evacuation_options[EVAC_OPT_CANCEL_ABANDON_SHIP])
		else
			return list(evacuation_options[EVAC_OPT_CANCEL_BLUESPACE_JUMP])

/datum/evacuation_option/abandon_ship
	option_text = "Abandon spacecraft"
	option_desc = "abandon the spacecraft"
	option_target = EVAC_OPT_ABANDON_SHIP
	needs_syscontrol = TRUE
	silicon_allowed = TRUE
	abandon_ship = TRUE

/datum/evacuation_option/abandon_ship/execute(mob/user)
	if (!evacuation_controller)
		return
	if (evacuation_controller.deny)
		to_chat(user, "Unable to initiate escape procedures.")
		return
	if (evacuation_controller.is_on_cooldown())
		to_chat(user, evacuation_controller.get_cooldown_message())
		return
	if (evacuation_controller.is_evacuating())
		to_chat(user, "Escape procedures already in progress.")
		return
	if (evacuation_controller.call_evacuation(user, 1))
		log_and_message_admins("has initiated abandonment of the spacecraft.", user)

// This is the calm, orderly "good ending" - round-ending, but the ship and crew make it home intact - as opposed
// to abandon_ship above (panic, escape pods, "bad ending"). It's what the automatic autotransfer vote already
// uses (see init_autotransfer() in code/modules/modular_computers/file_system/programs/command/comm.dm) and what
// the Return to Port button on the galaxy map console (code/modules/overmap/ships/computers/starmap.dm) triggers
// manually - not available from the keycard authentication device, which only exposes emergency abandon-ship.
// Entirely separate from that same console's in-round jump (code/modules/overmap/sector_jump.dm), which does not
// touch the evacuation controller at all and never ends the round.
/datum/evacuation_option/bluespace_jump
	option_text = "Initiate Return to Port"
	option_desc = "initiate the return to port"
	option_target = EVAC_OPT_BLUESPACE_JUMP
	needs_syscontrol = TRUE
	silicon_allowed = TRUE

/datum/evacuation_option/bluespace_jump/execute(mob/user)
	if (!evacuation_controller)
		return
	if (evacuation_controller.deny)
		to_chat(user, "Unable to initiate jump preparation.")
		return
	if (evacuation_controller.is_on_cooldown())
		to_chat(user, evacuation_controller.get_cooldown_message())
		return
	if (evacuation_controller.is_evacuating())
		to_chat(user, "Jump preparation already in progress.")
		return
	if (evacuation_controller.call_evacuation(user, 0))
		log_and_message_admins("has initiated the return to port.", user)

/datum/evacuation_option/cancel_abandon_ship
	option_text = "Cancel abandonment"
	option_desc = "cancel abandonment of the spacecraft"
	option_target = EVAC_OPT_CANCEL_ABANDON_SHIP
	needs_syscontrol = TRUE
	silicon_allowed = FALSE

/datum/evacuation_option/cancel_abandon_ship/execute(mob/user)
	if (evacuation_controller && evacuation_controller.cancel_evacuation())
		log_and_message_admins("has cancelled abandonment of the spacecraft.", user)

/datum/evacuation_option/cancel_bluespace_jump
	option_text = "Cancel Return to Port"
	option_desc = "cancel the return to port"
	option_target = EVAC_OPT_CANCEL_BLUESPACE_JUMP
	needs_syscontrol = TRUE
	silicon_allowed = FALSE

/datum/evacuation_option/cancel_bluespace_jump/execute(mob/user)
	if (evacuation_controller && evacuation_controller.cancel_evacuation())
		log_and_message_admins("has cancelled the return to port.", user)

#undef EVAC_OPT_ABANDON_SHIP
#undef EVAC_OPT_BLUESPACE_JUMP
#undef EVAC_OPT_CANCEL_ABANDON_SHIP
#undef EVAC_OPT_CANCEL_BLUESPACE_JUMP
