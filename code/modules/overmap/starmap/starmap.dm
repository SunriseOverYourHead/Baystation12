// In-round bluespace jump target graph. See code/modules/overmap/sector_jump.dm for the jump sequence itself,
// and code/modules/overmap/ships/computers/starmap.dm for the console that drives it.

/// How long a system's content z-levels need to sit with nobody living on them before we consider the
/// system "cached" (evict ghosts, flip bookkeeping). The actual processing pause (see SSpresence.population_group()
/// and its uses in processing.dm/machines.dm) already kicks in immediately once population hits 0 - this delay
/// is purely so a brief lull in presence doesn't boot ghosts or flicker the console's status.
#define STARMAP_CACHE_DELAY (5 MINUTES)

GLOBAL_LIST_EMPTY(star_systems)

/datum/star_system
	/// Catalog-style display name, e.g. "HD 342" - rolled once at round start via the existing generate_system_name() helper.
	var/name
	/// Other /datum/star_system this one has a direct bluespace route to. Populated symmetrically via connect().
	var/list/datum/star_system/connections = list()
	/// Whether this system's content (star + planets) has actually been built yet. Deferred until first visit, except the hub.
	var/generated = FALSE
	/// This system's OWN overmap grid z-level - a real "in system" local map, not shared with any other system.
	/// The hub reuses GLOB.using_map.overmap_z (built once by vanilla build_overmap() at world init); every leaf
	/// gets a freshly-allocated one on first visit, via SSstarmap.build_system_overmap().
	var/overmap_z
	/// The z-levels of this system's *landable* content (planets) - what population/caching bookkeeping cares about.
	/// Deliberately excludes the star's own token, which sits on this system's own overmap_z and is never "populated".
	var/list/map_z = list()
	var/obj/overmap/visitable/star/star_obj
	var/list/obj/overmap/visitable/sector/exoplanet/planets = list()
	/// Bookkeeping only - the actual processing pause is automatic and immediate once population hits 0.
	var/cached = FALSE
	/// world.time this system's map_z last had a living player on it. Null while generated == FALSE.
	var/last_populated_time

/datum/star_system/New(_name)
	name = _name
	GLOB.star_systems += src

/datum/star_system/proc/connect(datum/star_system/other)
	if (!other || other == src || (other in connections))
		return
	connections += other
	other.connections += src

/datum/star_system/proc/is_adjacent(datum/star_system/other)
	return (other in connections)

/// Sum of living players across every generated planet z-level in this system. 0 for an ungenerated system.
/datum/star_system/proc/get_population()
	. = 0
	for (var/z in map_z)
		. += SSpresence.population(z)

/**
 * Builds this system's own overmap grid, star, and planets the first time it's visited. Safe to call repeatedly -
 * no-ops once generated. Each system gets a genuinely separate z-level for its local space (Approach B from the
 * grid-architecture discussion) rather than sharing one grid with every other system tagged by a "which system"
 * var - isolation between systems is structural (BYOND's view()/range()/get_dist()/etc. simply can't see across
 * z-levels), not something every future overmap feature has to remember to filter for.
 */
/datum/star_system/proc/ensure_generated()
	if (generated)
		return
	generated = TRUE
	last_populated_time = world.time

	SSstarmap.build_system_overmap(src)

	var/centre = ceil(GLOB.using_map.overmap_size / 2)
	star_obj = new /obj/overmap/visitable/star(locate(centre, centre, overmap_z))
	star_obj.name = name
	star_obj.desc = "A star, designated \"[name]\"."
	GLOB.map_stars += star_obj

	var/planet_count = rand(1, 3)
	for (var/i in 1 to planet_count)
		var/obj/overmap/visitable/sector/exoplanet/planet = new(null, null, null, overmap_z)
		planets += planet
		map_z |= planet.map_z

	// Same mechanism, and same density, as the home system's own hazards at round start (see
	// code/controllers/subsystems/event.dm) - GLOB.using_map.overmap_event_areas (34 on Torch). create_events()
	// avoids overlapping the star/planets placed above (it filters out turfs already holding an
	// /obj/overmap/visitable), so this has to run after them.
	overmap_event_handler.create_events(overmap_z, GLOB.using_map.overmap_size, GLOB.using_map.overmap_event_areas)

/// Reuses the sun star build_overmap() already creates for the home system, instead of generating a duplicate -
/// solar power / day-night code (see get_solar_angle() in code/modules/overmap/_defines.dm) already keys off GLOB.map_stars.
/datum/star_system/proc/adopt_existing_star(obj/overmap/visitable/star/existing)
	generated = TRUE
	last_populated_time = world.time
	overmap_z = GLOB.using_map.overmap_z
	star_obj = existing
	if (existing)
		existing.name = name
		existing.desc = "A star, designated \"[name]\"."


SUBSYSTEM_DEF(starmap)
	name = "Starmap"
	init_order = SS_INIT_STARMAP
	priority = SS_PRIORITY_STARMAP
	flags = SS_BACKGROUND
	wait = 30 SECONDS

	var/datum/star_system/hub
	var/datum/star_system/current

/datum/controller/subsystem/starmap/Initialize(start_uptime)
	build_graph()
	. = ..()

/// Hub-and-spoke: one starting system (where the star build_overmap() already made for the home sun lives),
/// nine leaves each connected only to the hub. Connections are stored as a plain adjacency list on each
/// /datum/star_system so a richer graph shape can be layered on later without touching this proc's callers.
/datum/controller/subsystem/starmap/proc/build_graph()
	hub = new /datum/star_system(generate_system_name())
	var/obj/overmap/visitable/star/home_star = GLOB.map_stars[1]
	hub.adopt_existing_star(home_star)
	current = hub

	for (var/i in 1 to 9)
		var/datum/star_system/leaf = new /datum/star_system(generate_system_name())
		hub.connect(leaf)

/**
 * Allocates and paints a fresh, independent overmap grid - the same turf/area setup vanilla build_overmap()
 * (code/modules/overmap/sectors.dm) does for the shared hub grid, just targeting a new z instead of
 * GLOB.using_map.overmap_z. Border edges still wrap via the existing /obj/overmap/proc/handle_wraparound()
 * (overmap_object.dm) - that already resolves against the mover's own current z rather than a global, so
 * wrapping stays confined to whichever grid it's built for. Shared by build_system_overmap() (one per star
 * system), get_transit_overmap_z() (one per FTL-capable vessel), and get_home_port_z() (the static HD 66161
 * grid, home_port.dm) - all three just need "a fresh isolated grid," optionally smaller than the main overmap.
 *
 * ChangeArea() is called BEFORE ChangeTurf() here, not after - this order actually matters. A freshly
 * incremented z defaults to /turf/space in /area/space (dynamic_lighting: turf=0, area=1, so
 * TURF_IS_DYNAMICALLY_LIT_UNSAFE reads FALSE). If ChangeTurf() runs first (while the turf is still in the old,
 * dynamically-lit area), the new turf type's own dynamic_lighting defaults back to TRUE (unset on
 * /turf/unsimulated/map, inherited from base /turf), so ChangeTurf()'s own before/after comparison reads
 * FALSE -> TRUE and dutifully builds a real, dark lighting_overlay mid-round (SSlighting.initialized is TRUE
 * by then, unlike at world init) - and ChangeArea() has no lighting bookkeeping of its own to ever clear that
 * stale overlay back out once the turf lands in this (dynamic_lighting=0) area a moment later. Putting
 * ChangeArea() first means the area is already dynamic_lighting=0 by the time ChangeTurf() does its
 * before/after comparison, so that comparison reads FALSE -> FALSE and never builds an overlay to begin with.
 */
/datum/controller/subsystem/starmap/proc/build_overmap_grid(size = GLOB.using_map.overmap_size)
	INCREMENT_WORLD_Z_SIZE
	var/new_z = world.maxz

	var/area/overmap/A = new
	for (var/square in block(locate(1, 1, new_z), locate(size, size, new_z)))
		var/turf/T = square
		ChangeArea(T, A)
		if (T.x == 1 || T.y == 1 || T.x == size || T.y == size)
			T = T.ChangeTurf(/turf/unsimulated/map/edge)
		else
			T = T.ChangeTurf(/turf/unsimulated/map)

	GLOB.using_map.sealed_levels |= new_z
	return new_z

/// No-ops if the system already has a grid.
/datum/controller/subsystem/starmap/proc/build_system_overmap(datum/star_system/system)
	if (!system.overmap_z)
		system.overmap_z = build_overmap_grid()
	return system.overmap_z

/// Lazily allocates (once per vessel, cached thereafter on the vessel itself) a private grid for it to sit on
/// while a bluespace jump is in progress - see enter_transit()/complete_jump()/abort_jump() in sector_jump.dm.
/// Filled edge-to-edge with the purely decorative "bluespace tunnel" hazard (event.dm) exactly once, at
/// creation - it's a private, permanently-reused grid, so there's no need to refill it on every subsequent jump.
/datum/controller/subsystem/starmap/proc/get_transit_overmap_z(obj/overmap/visitable/ship/vessel)
	if (!vessel.transit_overmap_z)
		vessel.transit_overmap_z = build_overmap_grid()
		var/size = GLOB.using_map.overmap_size
		for (var/turf/T in block(locate(1, 1, vessel.transit_overmap_z), locate(size, size, vessel.transit_overmap_z)))
			new /obj/overmap/event/bluespace_tunnel(T)
	return vessel.transit_overmap_z

/**
 * Runs every wait (30s) against every generated system regardless of its current cached state, so presence
 * returning by ANY route - the Torch jumping back in (complete_jump() also calls uncache_system() directly for
 * an instant response), a ghost using an away-site spawn point, or (once other FTL-capable vessels exist) one
 * of them arriving independently - always gets picked up and un-cached within one tick of this subsystem firing,
 * instead of requiring every possible arrival path to remember to clear the flag itself.
 */
/datum/controller/subsystem/starmap/fire(resumed, no_mc_tick)
	for (var/datum/star_system/system as anything in GLOB.star_systems)
		// Nothing generated, or (e.g. the hub, which reuses the pre-existing home star and never gets its own
		// planets) has no content z-levels at all - nothing to cache either way.
		if (!system.generated || !length(system.map_z))
			continue
		if (system.get_population())
			system.last_populated_time = world.time
			if (system.cached)
				uncache_system(system)
			continue
		if (system.cached)
			continue // already cached and still empty - nothing to do until someone shows up
		if (world.time - system.last_populated_time < STARMAP_CACHE_DELAY)
			continue
		cache_system(system)

/datum/controller/subsystem/starmap/proc/cache_system(datum/star_system/system)
	system.cached = TRUE
	for (var/mob/observer/ghost/ghost as anything in GLOB.ghost_mobs)
		if (!(ghost.z in system.map_z))
			continue
		var/turf/safe_turf = get_ghost_eviction_turf()
		if (safe_turf)
			ghost.forceMove(safe_turf)
		to_chat(ghost, SPAN_NOTICE("\The [system.name] has gone quiet - with no one there, it's been cached to keep the sector running smoothly. You've been returned to \the [GLOB.using_map.station_name || "ship"]."))

/datum/controller/subsystem/starmap/proc/uncache_system(datum/star_system/system)
	system.cached = FALSE

/**
 * Where an evicted ghost lands. Deliberately not "wherever the Torch's overmap token currently sits" - that's a
 * tile on the overmap grid itself, not anywhere inside the ship, and would only ever make sense for one specific
 * vessel anyway. This picks a safe turf on the Torch's own home decks (GLOB.using_map.station_levels), which will
 * keep being valid regardless of how many other FTL-capable vessels get added later; revisit once those vessels
 * have their own tracked positions if ghosts should instead land on whichever ship is nearest them.
 */
/datum/controller/subsystem/starmap/proc/get_ghost_eviction_turf()
	RETURN_TYPE(/turf)
	if (!length(GLOB.using_map.station_levels))
		return null
	return pick_area_turf_in_connected_z_levels(
		list(GLOBAL_PROC_REF(is_not_space_area)),
		list(GLOBAL_PROC_REF(not_turf_contains_dense_objects), GLOBAL_PROC_REF(IsTurfAtmosSafe)),
		GLOB.using_map.station_levels[1])

#undef STARMAP_CACHE_DELAY
