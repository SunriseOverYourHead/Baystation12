// The in-round, non-terminal counterpart to /datum/universal_state/bluespace_jump (code/game/gamemodes/endgame/bluespace_jump/bluespace_jump.dm).
// This borrows that jump's crew-facing flavor almost verbatim (chat lines, screen effect, ghost visibility, the
// bluegoast mirror-echo, including its blueswitch() escalation - unlike an earlier draft of this file, that's now
// fully live: repeated jumps really can permanently kill and replace a crew member who moves around too much
// during one) and its straggler handling (/area/space stragglers get left behind rather than following the ship,
// and take burn/radiation damage the whole time they're exposed), reimplemented via the same OnTouchMapEdge()
// hook the endgame version uses, but scoped to just the mobs actually caught outside instead of qdel()'ing
// anyone who touches a map edge on the ship's z-levels.
//
// What's NOT ported: OnEnter()'s ship_jump()/accessible_z_levels-wide relocation of the ship itself - this jump
// never moves the Torch's own z-levels, only its overmap token, so there's nothing to relocate stragglers away
// from. Instead, anyone caught in space when the jump starts (or who steps outside partway through - see
// scan_for_stragglers() below) gets physically driven off the ship's own map edge and stranded on an empty
// z-level exactly like the endgame version's stragglers. begin_bluespace_transit()/end_bluespace_transit() below
// are shared with Return to Port (code/controllers/evacuation/evacuation_pods.dm), which used to reuse the full
// endgame state directly - see begin_bluespace_transit()'s own doc comment for why that was actively harmful.

// Two distinct phases, each with its own announcement: drive spool-up (ship stays put, can still be interrupted
// by loss of drive/power same as before), then the actual transit (ship enters its private "bluespace tunnel"
// overmap - see enter_transit() - and any overmap hazard field it was sitting in is cleared at that exact moment).
#define SECTOR_JUMP_SPOOLUP_DURATION (5 MINUTES)
#define SECTOR_JUMP_TRANSIT_DURATION (2 MINUTES)
#define STARMAP_JUMP_COOLDOWN (15 MINUTES)
#define STRAGGLER_THROW_INTERVAL (2 SECONDS)
#define STRAGGLER_THROW_RANGE 8
#define STRAGGLER_MAX_ATTEMPTS 40 // safety valve - about 80 seconds of nudging before we just strand them directly
#define JUMP_MONITOR_INTERVAL (2 SECONDS) // how often we re-check the drive is still present and powered mid-jump
// Applied every STRAGGLER_THROW_INTERVAL to anyone still exposed to space during a transit - deliberately brutal,
// this is "you got caught outside during an FTL jump", not routine vacuum exposure.
#define BLUESPACE_EXPOSURE_BURN_DAMAGE 15
#define BLUESPACE_EXPOSURE_RADIATION_DAMAGE 40

/datum/controller/subsystem/starmap/var/jumping = FALSE
/datum/controller/subsystem/starmap/var/last_jump_time = 0
/// Whether the current jump has moved past drive spool-up into the actual bluespace transit. Also what
/// distinguishes which phase jump_completes_at refers to.
/datum/controller/subsystem/starmap/var/in_transit = FALSE
/// world.time the current phase (spool-up, then transit) finishes at. Polled by monitor_jump() rather than
/// driven by a fixed one-shot timer specifically so the admin debug panel (starmap/admin_debug.dm) can nudge it
/// forward/back while a jump is already in progress.
/datum/controller/subsystem/starmap/var/jump_completes_at = 0
/datum/controller/subsystem/starmap/var/list/bluespaced_crew = list()
/// weakref(client) -> the /obj/screen/fullscreen/bluespace_overlay shown to it. Tracked separately from
/// bluespaced_crew (which holds mob references) because a mob's own client can go null out from under it - e.g.
/// dying and ghosting mid-transit - at which point clear_fullscreen() on the stale mob reference silently no-ops
/// and the overlay is stranded on whatever the client is looking through now. Clients don't get replaced the way
/// mobs do, so resolving through this instead guarantees the overlay actually comes off.
/datum/controller/subsystem/starmap/var/list/bluespaced_screens = list()
/datum/controller/subsystem/starmap/var/list/active_bluegoasts = list()
/// Set for the length of ANY bluespace transit - the in-round console jump's (in_transit) or Return to Port's
/// (evacuation_controller's own EVAC_IN_TRANSIT) - see begin_bluespace_transit()/end_bluespace_transit(). Governs
/// the shared crew-facing effects (bluespaced overlay, straggler ejection/exposure damage, jump_state) so both
/// flavors of "a bluespace jump" behave identically from the crew's perspective, and so try_end_jump_state()
/// knows not to revert jump_state out from under whichever one is actually still running.
/datum/controller/subsystem/starmap/var/transit_active = FALSE
/datum/controller/subsystem/starmap/var/datum/universal_state/sector_jump/jump_state
/// The destination of whichever jump is currently in progress, if any - tracked as a var (rather than only
/// threaded through the monitor_jump()/begin_transit()/complete_jump() callback chain's arguments) so the
/// console UI can show it, and so cancel_jump() doesn't need a target passed in to know what it's cancelling.
/datum/controller/subsystem/starmap/var/datum/star_system/current_jump_target

/// Finds the bluespace drive aboard, requiring it to actually be on one of `z_levels` - a drive sitting
/// somewhere else entirely (a different vessel, an away site) doesn't count. Other FTL-capable vessels will
/// each pass their own connected z-levels here once they exist; for now every call site passes the Torch's.
/datum/controller/subsystem/starmap/proc/get_drive(list/z_levels)
	RETURN_TYPE(/obj/machinery/bluespacedrive)
	for (var/obj/machinery/bluespacedrive/drive in SSmachines.machinery)
		if (drive.z in z_levels)
			return drive
	return null

/// Best-effort check that none of the Torch's own auxiliary craft are off exploring the departing system.
/datum/controller/subsystem/starmap/proc/all_shuttles_docked()
	var/obj/overmap/visitable/ship/torch/torch = SSshuttle.ship_by_type(/obj/overmap/visitable/ship/torch)
	if (!torch)
		return TRUE
	for (var/shuttle_type in torch.known_ships)
		var/obj/overmap/visitable/ship/landable/shuttle = SSshuttle.ship_by_type(shuttle_type)
		if (shuttle && get_dist(shuttle, torch) > 0)
			return FALSE
	return TRUE

/// Deciseconds until the drive is ready again. 0 (or negative) means ready.
/datum/controller/subsystem/starmap/proc/cooldown_remaining()
	return max(0, STARMAP_JUMP_COOLDOWN - (world.time - last_jump_time))

/datum/controller/subsystem/starmap/proc/cooldown_total()
	return STARMAP_JUMP_COOLDOWN

/// How long the phase currently in progress takes in total - lets the console UI show a meaningful progress bar
/// without needing the SECTOR_JUMP_*_DURATION defines themselves, which are #undef'd at the end of this file.
/datum/controller/subsystem/starmap/proc/current_phase_duration()
	return in_transit ? SECTOR_JUMP_TRANSIT_DURATION : SECTOR_JUMP_SPOOLUP_DURATION

/datum/controller/subsystem/starmap/proc/can_jump(datum/star_system/target, mob/user)
	if (jumping)
		to_chat(user, SPAN_WARNING("A bluespace jump is already in progress."))
		return FALSE
	if (cooldown_remaining() > 0)
		to_chat(user, SPAN_WARNING("The bluespace drive hasn't recharged yet. [round(cooldown_remaining() / 600, 0.1)] minutes remain."))
		return FALSE
	if (!target || target == current)
		to_chat(user, SPAN_WARNING("Invalid jump target."))
		return FALSE
	if (!current.is_adjacent(target))
		to_chat(user, SPAN_WARNING("No direct bluespace route to that system from here."))
		return FALSE
	var/obj/machinery/bluespacedrive/drive = get_drive(GLOB.using_map.station_levels)
	if (!drive)
		to_chat(user, SPAN_WARNING("No bluespace drive detected aboard."))
		return FALSE
	if (HAS_FLAGS(drive.state, drive.STATE_BROKEN))
		to_chat(user, SPAN_WARNING("The bluespace drive is too damaged to safely jump."))
		return FALSE
	if (!drive.powered())
		to_chat(user, SPAN_WARNING("The bluespace drive has no power."))
		return FALSE
	if (!all_shuttles_docked())
		to_chat(user, SPAN_WARNING("Not all auxiliary craft are docked. Recall them before jumping."))
		return FALSE
	if (GLOB.universe.type != /datum/universal_state)
		to_chat(user, SPAN_WARNING("Something else has seized control - the drive refuses to engage."))
		return FALSE
	var/obj/machinery/nuclearbomb/station/self_destruct = locate(/obj/machinery/nuclearbomb/station) in world
	if (self_destruct?.timing > 0)
		to_chat(user, SPAN_WARNING("The self-destruct sequence is active. The drive refuses to engage until it's resolved."))
		return FALSE
	if (evacuation_controller && !evacuation_controller.is_idle())
		to_chat(user, SPAN_WARNING("An evacuation is already underway. The drive refuses to engage until it's resolved."))
		return FALSE
	return TRUE

/datum/controller/subsystem/starmap/proc/initiate_jump(datum/star_system/target, mob/user)
	if (!can_jump(target, user))
		return FALSE
	jumping = TRUE
	in_transit = FALSE
	last_jump_time = world.time
	current_jump_target = target

	command_announcement.Announce("\The [get_drive(GLOB.using_map.station_levels)] is spooling up for a bluespace jump to \the [target.name]. All hands brace for transit.", "Bluespace Jump", zlevels = GLOB.using_map.station_levels)

	// Crew are only actually bluespaced - visual effects, straggler ejection, the works - once the transit
	// itself begins (see begin_transit()). The ship, and everyone on it, stays completely normal for the whole
	// spool-up; nothing physically happens until the drive actually engages.
	jump_completes_at = world.time + SECTOR_JUMP_SPOOLUP_DURATION
	addtimer(new Callback(src, PROC_REF(monitor_jump), target), JUMP_MONITOR_INTERVAL)
	return TRUE

/// Moves a vessel's overmap blip onto its own private transit grid - see get_transit_overmap_z() in starmap.dm.
/datum/controller/subsystem/starmap/proc/enter_transit(obj/overmap/visitable/ship/vessel)
	var/z = get_transit_overmap_z(vessel)
	var/centre = ceil(GLOB.using_map.overmap_size / 2)
	var/turf/T = locate(centre, centre, z)
	if (T)
		vessel.forceMove(T)
		refresh_overmap_viewers(vessel)

/// Puts a vessel's blip near a system's star, on that system's own grid - used both for arriving (complete_jump())
/// and for reverting to where it started after an aborted jump (abort_jump()).
/datum/controller/subsystem/starmap/proc/position_near_star(obj/overmap/visitable/ship/vessel, datum/star_system/system)
	if (!vessel || !system?.star_obj)
		return
	var/map_low = OVERMAP_EDGE
	var/map_high = GLOB.using_map.overmap_size - OVERMAP_EDGE
	var/turf/destination = CircularRandomTurfAround(system.star_obj, 5, map_low, map_low, map_high, map_high)
	if (destination)
		vessel.forceMove(destination)
		refresh_overmap_viewers(vessel)

/// Forces anyone currently viewing the overmap through this vessel's sensor console(s) (ship.dm's look()/
/// navigation_viewers) to re-run reset_view() - the actual fix for the black-sector-map bug lives in
/// reset_view() itself (code/modules/mob/mob.dm), which now also rebuilds the client's skybox; this just makes
/// sure that happens again for anyone already watching when the vessel's own z changes mid-jump, since nothing
/// about the vessel moving involves *their* mob moving (the one thing that otherwise would have re-triggered it).
/datum/controller/subsystem/starmap/proc/refresh_overmap_viewers(obj/overmap/visitable/ship/vessel)
	if (!vessel?.navigation_viewers)
		return
	for (var/weakref/W as anything in vessel.navigation_viewers)
		var/mob/M = W.resolve()
		if (M?.client)
			M.reset_view(vessel)

/// Explicit backstop for clearing any overmap hazard (meteor field, ion storm, etc; see
/// code/modules/overmap/events/event.dm) currently affecting a vessel - forceMove() already triggers the
/// generic Entered()/Exited() turf hooks that mechanism relies on, so this should rarely have anything to do,
/// but "the ship must obviously be cleared of the hazard field" on jumping is exactly the kind of thing not
/// worth leaving to an indirect event chain alone.
/datum/controller/subsystem/starmap/proc/clear_overmap_hazards(obj/overmap/visitable/ship/vessel)
	if (!vessel || !overmap_event_handler.ship_events[vessel])
		return
	for (var/datum/event/E as anything in overmap_event_handler.ship_events[vessel].Copy())
		E.kill()
		LAZYREMOVE(overmap_event_handler.ship_events[vessel], E)

/**
 * Re-checked every JUMP_MONITOR_INTERVAL for the length of the sequence: if the drive gets destroyed, hauled out
 * of the connected z-levels, or loses power at any point (spool-up or transit alike), the jump aborts instead
 * of completing.
 */
/datum/controller/subsystem/starmap/proc/monitor_jump(datum/star_system/target)
	if (!jumping)
		return // already completed or aborted
	var/obj/machinery/bluespacedrive/drive = get_drive(GLOB.using_map.station_levels)
	if (!drive)
		abort_jump(target, "the drive is no longer aboard")
		return
	if (!drive.powered())
		abort_jump(target, "the drive lost power")
		return
	if (world.time >= jump_completes_at)
		if (!in_transit)
			begin_transit(target)
		else
			complete_jump(target)
		return
	addtimer(new Callback(src, PROC_REF(monitor_jump), target), JUMP_MONITOR_INTERVAL)

/// The z-levels that should show the "cascade" transit skybox for a given vessel's jump - its own interior
/// decks plus whichever private transit grid it's using (see get_transit_overmap_z() in starmap.dm). Shared by
/// begin_transit()/complete_jump()/abort_jump() below so the set can't drift between when it's applied and when
/// it's cleared.
/datum/controller/subsystem/starmap/proc/jump_affected_zlevels(obj/overmap/visitable/ship/vessel)
	return GLOB.using_map.station_levels + list(get_transit_overmap_z(vessel))

/**
 * Shared crew-facing "a bluespace transit has begun" setup - the bluespaced screen overlay/confusion, ghost
 * visibility, and the scoped sector_jump universal state that drives ongoing straggler ejection and space-
 * exposure damage (see scan_for_stragglers()). Called by both the in-round console jump's begin_transit() below
 * and Return to Port's launch_evacuation() (code/controllers/evacuation/evacuation_pods.dm) - previously that
 * second flow reused the full endgame /datum/universal_state/bluespace_jump instead, which deletes the ship's
 * own overmap object (OnEnter() -> GLOB.using_map.ship_jump()) and pulls its z-levels out of
 * accessible_z_levels - both correct for the original round-ending-only design, both actively harmful now that
 * crew keep playing through a several-minute transit (consoles losing their link to a now-deleted ship and
 * never being able to resync, the sector map having nothing left to show).
 */
/datum/controller/subsystem/starmap/proc/begin_bluespace_transit()
	transit_active = TRUE

	for (var/z in GLOB.using_map.station_levels)
		for (var/mob/living/crew in SSmobs.mob_list)
			if (crew.z == z)
				apply_bluespaced(crew)

	for (var/mob/goast in GLOB.ghost_mobs)
		goast.mouse_opacity = 0	//can't let you click that Dave
		goast.set_invisibility(SEE_INVISIBLE_LIVING)
		goast.alpha = 255

	SetUniversalState(/datum/universal_state/sector_jump)
	jump_state = GLOB.universe
	scan_for_stragglers()

/// Reverts begin_bluespace_transit() - safe to call even if that was never actually reached (e.g. an abort during
/// spool-up, before any transit began), since clear_bluespaced()/try_end_jump_state() are already no-ops then.
/datum/controller/subsystem/starmap/proc/end_bluespace_transit()
	transit_active = FALSE
	clear_bluespaced()
	try_end_jump_state()

/// Spool-up finished - the drive engages, the ship actually leaves (clearing any overmap hazard and entering its
/// private transit grid), and the transit phase's own timer starts. This is also the moment crew actually become
/// "bluespaced" - see initiate_jump() above, which deliberately does none of this at spool-up start.
/datum/controller/subsystem/starmap/proc/begin_transit(datum/star_system/target)
	in_transit = TRUE
	jump_completes_at = world.time + SECTOR_JUMP_TRANSIT_DURATION

	command_announcement.Announce("\The [get_drive(GLOB.using_map.station_levels)] engages. The ship vanishes into the bluespace tunnel - exiting in [SECTOR_JUMP_TRANSIT_DURATION / 600] minutes.", "Bluespace Jump", zlevels = GLOB.using_map.station_levels)

	begin_bluespace_transit()

	var/obj/overmap/visitable/ship/torch/torch = SSshuttle.ship_by_type(/obj/overmap/visitable/ship/torch)
	if (torch)
		clear_overmap_hazards(torch)
		enter_transit(torch)
		SSskybox.set_zlevel_override(jump_affected_zlevels(torch), "cascade")

	addtimer(new Callback(src, PROC_REF(monitor_jump), target), JUMP_MONITOR_INTERVAL)

/**
 * Ends an in-progress jump early, repositioning the ship back near its current star. `user_cancelled` is what
 * distinguishes a deliberate crew decision (see cancel_jump() below) from a genuine system failure (drive lost/
 * unpowered, checked by monitor_jump()): a cancellation resets last_jump_time so it costs no cooldown at all -
 * the crew simply changed their mind, nothing actually broke - while a failure-triggered abort keeps the normal
 * cooldown penalty as a real consequence of the drive/power problem that caused it.
 */
/datum/controller/subsystem/starmap/proc/abort_jump(datum/star_system/target, reason = "the drive failed", user_cancelled = FALSE)
	if (!jumping)
		return
	jumping = FALSE
	in_transit = FALSE
	current_jump_target = null

	if (user_cancelled)
		command_announcement.Announce("Bluespace jump sequence cancelled by crew order. The drive powers down; local position reasserted.", "Bluespace Jump", zlevels = GLOB.using_map.station_levels)
		last_jump_time = 0
	else
		command_announcement.Announce("Bluespace jump aborted - [reason] mid-sequence. Reasserting local position.", "Bluespace Jump", zlevels = GLOB.using_map.station_levels)

	var/obj/overmap/visitable/ship/torch/torch = SSshuttle.ship_by_type(/obj/overmap/visitable/ship/torch)
	if (torch)
		SSskybox.clear_zlevel_override(jump_affected_zlevels(torch))
	position_near_star(torch, current)

	end_bluespace_transit()

/**
 * User-triggered cancel from the console (see ui_act() "cancel_jump" in ships/computers/starmap.dm). Only
 * available during spool-up - once the ship has actually entered the bluespace tunnel (in_transit), the jump
 * can no longer be called off, same as the drive/power failure checks in monitor_jump().
 */
/datum/controller/subsystem/starmap/proc/cancel_jump(mob/user)
	if (!jumping)
		to_chat(user, SPAN_WARNING("No bluespace jump is in progress."))
		return FALSE
	if (in_transit)
		to_chat(user, SPAN_WARNING("The ship has already entered bluespace - the jump can't be called off now."))
		return FALSE
	abort_jump(current_jump_target, user_cancelled = TRUE)
	return TRUE

/datum/controller/subsystem/starmap/proc/apply_bluespaced(mob/living/crew)
	bluespaced_crew += crew
	if (crew.client)
		to_chat(crew, SPAN_NOTICE("You feel oddly light, and somewhat disoriented as everything around you shimmers and warps ever so slightly."))
		var/obj/screen/fullscreen/screen = crew.overlay_fullscreen("bluespace", /obj/screen/fullscreen/bluespace_overlay)
		if (screen)
			bluespaced_screens[weakref(crew.client)] = screen
	crew.set_confused(20)
	active_bluegoasts += new /obj/bluegoast(get_turf(crew), crew)

/datum/controller/subsystem/starmap/proc/clear_bluespaced()
	for (var/mob/living/crew as anything in bluespaced_crew)
		if (!QDELETED(crew) && crew.client)
			to_chat(crew, SPAN_NOTICE("You feel rooted in material world again."))
			crew.clear_fullscreen("bluespace")
	bluespaced_crew.Cut()

	// Backstop for exactly the case above's clear_fullscreen() can't handle: crew.client went null (they died and
	// ghosted, etc) sometime mid-transit. Resolve straight through the client - who it's currently looking
	// through doesn't matter, this only cares about getting the specific overlay object off their screen.
	for (var/weakref/W as anything in bluespaced_screens)
		var/client/C = W.resolve()
		var/obj/screen/fullscreen/screen = bluespaced_screens[W]
		if (C && screen)
			C.screen -= screen
		qdel(screen)
	bluespaced_screens.Cut()

	for (var/mob/goast in GLOB.ghost_mobs)
		goast.mouse_opacity = initial(goast.mouse_opacity)
		goast.set_invisibility(initial(goast.invisibility))
		goast.alpha = initial(goast.alpha)

	for (var/obj/bluegoast/echo as anything in active_bluegoasts)
		qdel(echo)
	active_bluegoasts.Cut()

/// A turf that would leave anyone standing on it exposed to hard vacuum during a transit - checked by both turf
/// type and area type (istype(A, /area/space) alone was missing genuine space turfs that aren't themselves
/// inside an /area/space, e.g. a hull breach out into open space still mapped under a named interior area).
/datum/controller/subsystem/starmap/proc/is_exposed_to_space(mob/living/M)
	var/turf/T = get_turf(M)
	if (!T)
		return FALSE
	if (istype(T, /turf/space))
		return TRUE
	return istype(get_area(M), /area/space)

/// Re-run every STRAGGLER_THROW_INTERVAL for as long as transit_active is set (see begin_bluespace_transit()) -
/// not a one-shot snapshot, so someone who steps outside partway through a multi-minute transit still gets
/// caught, not just whoever happened to already be exposed the instant the transit began.
/datum/controller/subsystem/starmap/proc/scan_for_stragglers()
	if (!transit_active || !jump_state)
		return
	for (var/z in GLOB.using_map.station_levels)
		for (var/mob/living/M in SSmobs.mob_list)
			if (M.z != z || M in jump_state.ejecting)
				continue
			if (!is_exposed_to_space(M))
				continue
			jump_state.ejecting += M
			if (M.client)
				to_chat(M, SPAN_DANGER("The deck lurches away from you - you're not going to make it back inside before the jump!"))
			throw_straggler(M, 0)
	addtimer(new Callback(src, PROC_REF(scan_for_stragglers)), STRAGGLER_THROW_INTERVAL)

/// Exposure to space during a bluespace transit is punishing, not incidental - a "you got left outside during
/// FTL" consequence, applied on top of (not instead of) the physical throw toward the map edge below.
/datum/controller/subsystem/starmap/proc/apply_exposure_damage(mob/living/M)
	M.apply_damage(BLUESPACE_EXPOSURE_BURN_DAMAGE, DAMAGE_BURN)
	M.apply_damage(BLUESPACE_EXPOSURE_RADIATION_DAMAGE, DAMAGE_RADIATION)

/datum/controller/subsystem/starmap/proc/throw_straggler(mob/living/M, attempts)
	if (!jump_state || !(M in jump_state.ejecting) || QDELETED(M))
		return
	if (attempts >= STRAGGLER_MAX_ATTEMPTS)
		strand_straggler(M)
		return
	if (!is_exposed_to_space(M))
		jump_state.ejecting -= M // made it back inside under their own power
		try_end_jump_state()
		return
	apply_exposure_damage(M)
	var/turf/aim = get_border_throw_target(get_turf(M))
	if (aim)
		M.throw_at(aim, STRAGGLER_THROW_RANGE, 2)
	addtimer(new Callback(src, PROC_REF(throw_straggler), M, attempts + 1), STRAGGLER_THROW_INTERVAL)

/// Safety valve for a straggler that can't reach open space on their own (e.g. boxed in) - strand them directly.
/datum/controller/subsystem/starmap/proc/strand_straggler(mob/living/M)
	if (!jump_state)
		return
	jump_state.ejecting -= M
	if (!QDELETED(M))
		var/space_zlevel = GLOB.using_map.get_empty_zlevel()
		var/turf/T = locate(M.x, M.y, space_zlevel)
		if (T)
			M.forceMove(T)
		if (M.client)
			to_chat(M, SPAN_WARNING("The ship's bluespace field sweeps past without you - you're adrift, and completely alone."))
	try_end_jump_state()

/datum/controller/subsystem/starmap/proc/get_border_throw_target(turf/T)
	if (!T)
		return null
	var/dist_west = T.x
	var/dist_east = world.maxx - T.x
	var/dist_south = T.y
	var/dist_north = world.maxy - T.y
	var/closest = min(dist_west, dist_east, dist_south, dist_north)
	if (closest == dist_west)
		return locate(1, T.y, T.z)
	if (closest == dist_east)
		return locate(world.maxx, T.y, T.z)
	if (closest == dist_south)
		return locate(T.x, 1, T.z)
	return locate(T.x, world.maxy, T.z)

/// Reverts GLOB.universe once every straggler has either crossed the edge, been safety-valved, or made it back
/// inside, AND the transit itself has finished - whichever of those happens last. Checks transit_active rather
/// than jumping specifically so this can't get pulled out from under Return to Port's transit, which drives
/// transit_active through its own state machine rather than SSstarmap's.
/datum/controller/subsystem/starmap/proc/try_end_jump_state()
	if (!jump_state || transit_active || length(jump_state.ejecting))
		return
	SetUniversalState(/datum/universal_state)
	jump_state = null

/datum/controller/subsystem/starmap/proc/complete_jump(datum/star_system/target)
	if (!jumping)
		return // aborted before this timer fired - monitor_jump()/abort_jump() already handled everything

	target.ensure_generated()

	var/obj/overmap/visitable/ship/torch/torch = SSshuttle.ship_by_type(/obj/overmap/visitable/ship/torch)
	if (torch)
		SSskybox.clear_zlevel_override(jump_affected_zlevels(torch))
	position_near_star(torch, target)

	current = target
	target.last_populated_time = world.time
	uncache_system(target)
	GLOB.using_map.system_name = target.name

	command_announcement.Announce("Bluespace jump complete. Sensors confirm arrival at \the [target.name].", "Bluespace Jump", zlevels = GLOB.using_map.station_levels)

	jumping = FALSE
	in_transit = FALSE
	current_jump_target = null
	end_bluespace_transit()

/**
 * Scoped counterpart to /datum/universal_state/bluespace_jump - rather than affecting every atom on a fixed list
 * of z-levels for the sequence's entire duration, this only intercepts mobs starmap.dm has explicitly flagged as
 * being actively ejected (see scan_for_stragglers()); everything else defers to the default (TRUE), so unrelated
 * EVA/overmap travel elsewhere in the round isn't affected while this is active.
 */
/datum/universal_state/sector_jump
	var/list/mob/living/ejecting = list()

/datum/universal_state/sector_jump/OnTouchMapEdge(atom/A)
	if (!ismob(A) || !(A in ejecting))
		return TRUE
	SSstarmap.strand_straggler(A)
	return FALSE

#undef SECTOR_JUMP_SPOOLUP_DURATION
#undef SECTOR_JUMP_TRANSIT_DURATION
#undef STARMAP_JUMP_COOLDOWN
#undef STRAGGLER_THROW_INTERVAL
#undef STRAGGLER_THROW_RANGE
#undef STRAGGLER_MAX_ATTEMPTS
#undef JUMP_MONITOR_INTERVAL
#undef BLUESPACE_EXPOSURE_BURN_DAMAGE
#undef BLUESPACE_EXPOSURE_RADIATION_DAMAGE
