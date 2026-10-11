/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/
/obj/machinery/atmospherics
	anchored = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON

	var/nodealert = 0
	var/power_rating //the maximum amount of power the machine can use to do work, affects how powerful the machine is, in Watts

	layer = EXPOSED_PIPE_LAYER
	var/hidden_layer = PIPE_LAYER

	var/connect_types = CONNECT_TYPE_REGULAR
	var/connect_dir_type = SOUTH // Assume your dir is SOUTH. What dirs should you connect to?
	var/icon_connect_type = "" //"-supply" or "-scrubbers"

	// Independent of connect_types - two pipes with the SAME connect_types can now coexist on the same
	// tile/direction as long as they're on different layers. Defaults to the middle layer so pre-existing/mapped
	// pipes (which never set this) only ever match other default-layer pipes.
	var/piping_layer = PIPING_LAYER_DEFAULT

	var/initialize_directions = 0
	var/pipe_color

	var/static/datum/pipe_icon_manager/icon_manager
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

	var/atmos_initalized = FALSE
	var/build_icon = 'icons/obj/atmospherics/pipe-item.dmi'
	var/build_icon_state = "buildpipe"
	var/colorable = FALSE

	var/pipe_class = PIPE_CLASS_OTHER //If somehow something isn't set properly, handle it as something with zero connections. This will prevent runtimes.
	var/rotate_class = PIPE_ROTATE_STANDARD

	// FALSE for most pipe types: their sprite is a single fixed icon_state, so a same-connect_types pipe on a
	// different layer needs a runtime pixel_x/pixel_y nudge to look distinguishable. TRUE for the bitmask "smart"
	// pipe (pipe/smart): its icon_state is "[bitfield]_[piping_layer]" - the pipes_bitmask.dmi spritesheet already
	// contains a separately-drawn, already-shifted tile per layer (confirmed by inspecting the sheet: the "3_1"
	// through "3_5" states step by exactly PIPING_LAYER_P_X=5px each). Applying a runtime shift on top of that
	// double-offsets it, so this flag lets apply_piping_layer_offset() skip the pixel_x/pixel_y part for it.
	var/piping_layer_pixel_shift = TRUE

	// TRUE on vent_scrubber/vent_pump: they should render centered on a proper tiled floor regardless of layer
	// (matching NovaSector) - the pixel nudge only kicks in once the tile's covering is removed, exposing bare
	// plating, at which point stacked same-type devices on different layers need to be visually distinguishable.
	// apply_piping_layer_offset() checks the current turf's is_plating() when this is set. hide() (below) already
	// calls apply_piping_layer_offset() on every floor-tile add/remove via turf/levelupdate(), so this re-evaluates
	// automatically as the tile is covered/exposed - no extra call site needed.
	var/piping_layer_pixel_shift_needs_exposed_tile = FALSE

	// Which cardinal directions this device is willing to connect on - narrows get_initialze_directions() on types
	// that consult it (currently only pipe/smart, reprogrammable via the RPD's keypad). Unused by other pipe
	// classes, but declared here (not just on pipe/smart) so construction.dm's use_tool() can set it generically
	// on any newly-built machine without an istype check.
	var/p_init_dir = NORTH|SOUTH|EAST|WEST

	// TRUE lets this device connect to a neighbor regardless of pipe_color mismatch / piping_layer mismatch
	// respectively, bypassing the color/layer gates in check_connect_types() below - set on the dedicated color
	// adapter / layer adapter pipe types (pipes.dm), which exist specifically to bridge two otherwise-incompatible
	// networks. A plain pipe painted PIPE_COLOR_OMNI gets the same color bypass without needing this flag - see
	// check_connect_types().
	var/pipe_color_bridge = FALSE
	var/pipe_layer_bridge = FALSE

	// TRUE on vent_scrubber/vent_pump - construction.dm's use_tool() blocks building a second one of either kind
	// on the same tile regardless of layer/color (matching NovaSector), since they're always forced onto their own
	// fixed layer anyway and the layer system's "different layers can share a tile" rule was never meant to apply
	// to room-fixture endpoint devices, only to pipe segments passing under the floor.
	var/atmos_single_device_per_tile = FALSE

/obj/machinery/atmospherics/Initialize()
	if(!icon_manager)
		icon_manager = new()

	if(!pipe_color)
		pipe_color = color
	color = null

	if(!pipe_color_check(pipe_color))
		pipe_color = null

	set_dir(dir) // Does full dir init.
	// Must happen before apply_piping_layer_offset() below, and specifically here in Initialize() rather than
	// atmos_init() - see the comment on pre_atmos_migrate() for why. pre_atmos_migrate() can return
	// INITIALIZE_HINT_QDEL (it replaced itself with a different object - see migrate_legacy_exclusive_network()) -
	// when it does, stop immediately rather than keep initializing an object that's about to be discarded.
	if(pre_atmos_migrate() == INITIALIZE_HINT_QDEL)
		// Returning here skips the ..() call below, so /atom/Initialize() never runs and never sets
		// ATOM_FLAG_INITIALIZED - matching the documented contract (code/game/atoms.dm:68, "should call parent
		// or set the flag"; see the IsAbstract() branch a few lines below there for the same pattern), this has
		// to set it directly, or the qdel() that InitAtom() performs on the INITIALIZE_HINT_QDEL hint (code/
		// controllers/subsystems/atoms.dm) trips /atom/movable/Destroy()'s "deleted before initalization" crash
		// diagnostic - spamming it for every legacy hidden supply/scrubbers pipe on the map, since this self-
		// replacement (a real pipe/smart already exists in its place by the time this returns) is expected, not
		// a bug.
		atom_flags |= ATOM_FLAG_INITIALIZED
		return INITIALIZE_HINT_QDEL
	apply_piping_layer_offset()
	. = ..()

// Per-layer pixel nudge (perpendicular to the pipe's own direction) plus a tiny z-order nudge, so multiple
// same-connect_types pipes stacked on different layers of the same tile are visually distinguishable without
// needing new art - copied from NovaSector's PIPING_LAYER_SHIFT macro and pipe/update_layer() (code/__DEFINES/
// atmospherics/atmos_helpers.dm, code/modules/atmospherics/machinery/pipes/pipes.dm there). Layer 3 (the default
// every pre-existing pipe uses) gets zero offset, so nothing already on the map shifts.
/obj/machinery/atmospherics/proc/apply_piping_layer_offset()
	var/layer_step = clamp(piping_layer, PIPING_LAYER_MIN, PIPING_LAYER_MAX) - PIPING_LAYER_DEFAULT
	var/do_shift = piping_layer_pixel_shift
	if(do_shift && piping_layer_pixel_shift_needs_exposed_tile)
		var/turf/T = get_turf(src)
		do_shift = T && T.is_plating()
	if(do_shift)
		// Relative to initial(pixel_x/y), not an absolute overwrite - some atmospherics machines (the fission
		// reactor, code/modules/power/reactor/reactor_core.dm) declare their own non-zero pixel_x/pixel_y for
		// unrelated reasons (centering a multi-tile sprite footprint on their turf) - overwriting that outright at
		// layer_step=0 (the common default-layer case) would silently wipe their own offset back to 0, visibly
		// shifting them. This way, an object with no reason of its own to set pixel_x/y (initial value 0) behaves
		// exactly as before, and one that does keeps its own offset with the layer nudge added on top of it.
		pixel_x = initial(pixel_x) + ((dir & (NORTH|SOUTH)) ? layer_step * PIPING_LAYER_P_X : 0)
		pixel_y = initial(pixel_y) + ((dir & (EAST|WEST)) ? layer_step * PIPING_LAYER_P_Y : 0)
	else
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)
	layer = initial(layer) + layer_step * PIPING_LAYER_LCHANGE

/obj/machinery/atmospherics/proc/atmos_init()
	atmos_initalized = TRUE

// Hook for forcing color/layer/connect_types BEFORE anyone's atmos_init() neighbor search runs. Called from
// Initialize() (which always runs synchronously, per-object, at creation time - mapload, construction, or a
// dynamically-loaded ruin arriving mid-round), not from atmos_init() itself. This matters because atmos_init() is
// invoked as a separate, LATER batch pass across many machines at once (see setup_atmos_machinery(), code/
// controllers/subsystems/machines.dm) - if the forcing happened there instead, a machine whose atmos_init() runs
// EARLY in that batch could search for a neighbor whose OWN atmos_init() (and thus its color/layer force) hasn't
// run yet, see a piping_layer/pipe_color mismatch against that neighbor's still-default values, and permanently
// miss the connection - rendering as disconnected until manually re-wrenched forces a fresh search. Doing the
// forcing in Initialize() means every machine's color/layer are already final by the time ANY atmos_init() batch
// begins, regardless of where or when that batch runs. Default implementation is migrate_legacy_exclusive_network()
// below; vent_scrubber/vent_pump override this with their own unconditional forcing (their connect_types combines
// REGULAR with the exclusive bit, so the exact-match switch below wouldn't catch them) - and additionally call it
// again from their own atmos_init(), since construction.dm's use_tool() sets pipe_color/piping_layer from the RPD
// AFTER Initialize() has already run, so their choice needs to be overridden a second time for player-built ones.
/obj/machinery/atmospherics/proc/pre_atmos_migrate()
	return migrate_legacy_exclusive_network()

// TRUE on the 4 legacy pipe SEGMENT shape classes (pipe/simple, pipe/manifold, pipe/manifold4w, pipe/cap in
// pipes.dm) - these have a direct real replacement (pipe/smart, which auto-shapes to whatever it's actually
// connected to) so migrate_legacy_exclusive_network() below fully converts them: spawns a real pipe/smart in
// their place and deletes the original, rather than just leaving the old object color/layer-compatible. FALSE
// (the default) for everything else migrate_legacy_exclusive_network() also touches - zpipe (no pipe/smart
// equivalent, it's a vertical Z-connector) and the 3 valve/shutoff/{scrubbers,supply,fuel} variants (no
// "smart valve" equivalent either) - those stay as their own class, just forced color/layer-compatible.
/obj/machinery/atmospherics/var/convert_to_smart_pipe_on_migrate = FALSE

// Forces pipe_color/piping_layer to match where the old exclusive supply/scrubber/fuel pipe networks moved to
// (red/layer2, blue/layer4, orange/layer1), for any pipe segment whose connect_types is EXACTLY one of those
// exclusive bits with nothing else mixed in - i.e. the old pipe/simple/manifold/manifold4w/cap/zpipe/valve
// "scrubbers"/"supply"/"fuel" subtypes already placed on existing maps, back when those were separate buildable
// networks. This is what lets those maps keep working without a remap now that real scrubber/supply/fuel pipes
// are just regular pipes on a fixed color+layer.
//
// For the 4 pipe shape classes (convert_to_smart_pipe_on_migrate = TRUE), this does a full conversion - deletes
// the legacy object and spawns a real pipe/smart in its place, matching its direction and connectable directions
// exactly (p_init_dir = initialize_directions, computed from the original's dir + connect_dir_type at set_dir()
// time, before this runs) - not just leaving it color/layer-compatible. This is safe to do unconditionally at
// Initialize() time: it always runs before setup_atmos_machinery()'s atmos_init()/build_network() passes (see the
// comment on pre_atmos_migrate()), so there is no gas/pipe-network state to preserve yet - the whole network gets
// built from scratch afterward regardless of whether this pipe converted.
//
// For everything else (zpipe, the 3 shutoff valve variants), no real replacement exists, so this instead ORs in
// CONNECT_TYPE_REGULAR (these segments' connect_types was exclusively SCRUBBER/SUPPLY/FUEL before, no REGULAR
// bit, so even after color+layer agree a newly RPD-built plain regular pipe painted/layered to match still
// couldn't bridge to one without this - connect_types is checked first and independently of color/layer in
// check_connect_types()) and forces color/layer directly on the existing object.
/obj/machinery/atmospherics/proc/migrate_legacy_exclusive_network()
	var/new_color
	var/new_layer
	switch(connect_types)
		if(CONNECT_TYPE_SCRUBBER)
			new_color = PIPE_COLOR_RED
			new_layer = 2
		if(CONNECT_TYPE_SUPPLY)
			new_color = PIPE_COLOR_BLUE
			new_layer = 4
		if(CONNECT_TYPE_FUEL)
			new_color = PIPE_COLOR_ORANGE
			new_layer = 1
		else
			return

	if(convert_to_smart_pipe_on_migrate)
		var/turf/T = get_turf(src)
		var/obj/machinery/atmospherics/pipe/smart/replacement = new(T)
		replacement.p_init_dir = initialize_directions
		replacement.set_dir(dir)
		replacement.pipe_color = new_color
		replacement.piping_layer = new_layer
		replacement.apply_piping_layer_offset()
		// NOT set_initial_level() - that recomputes level from whether the turf is CURRENTLY bare plating, which
		// is right for brand-new RPD construction (the player is standing there deciding hidden-vs-exposed based
		// on what's underfoot right now) but wrong here: this pipe was already correctly under an existing floor
		// tile (or deliberately exposed - pipe/simple/visible/* sets level = ATOM_LEVEL_OVER_TILE on purpose), and
		// set_initial_level() would see the existing floor tile and force it to ATOM_LEVEL_OVER_TILE regardless,
		// making it render exposed on top of the tile instead of hidden under it. Just copy the original's already-
		// correct level. atmos_init() (called later, in the batch pass) checks level == ATOM_LEVEL_UNDER_TILE
		// against the turf and calls hide(1) itself, so nothing else needs to happen here for it to take effect.
		replacement.level = level
		// Returning the hint instead of qdel-ing src directly here: this runs from inside src's own Initialize()
		// call chain (via pre_atmos_migrate()), which is still executing above us on the stack - qdel-ing src now
		// would leave that caller's remaining Initialize() code (apply_piping_layer_offset(), base /obj/machinery/
		// Initialize()'s SSmachines.machinery += src, any subclass's post-..() lines) running on a deleted object.
		// INITIALIZE_HINT_QDEL is this codebase's established convention for exactly this - the object stays alive
		// until Initialize() fully unwinds, and whatever invoked Initialize() does the actual qdel afterward.
		return INITIALIZE_HINT_QDEL

	connect_types |= CONNECT_TYPE_REGULAR
	pipe_color = new_color
	piping_layer = new_layer
	apply_piping_layer_offset()

/obj/machinery/atmospherics/hide(do_hide)
	// Always reset+reapply first, THEN override to hidden_layer if actually hiding (so that override wins over
	// apply_piping_layer_offset()'s own layer computation) - turf/levelupdate() calls hide() on every obj whenever
	// a floor tile is placed or removed on that turf, so this is what keeps the piping-layer z-order nudge (and,
	// for piping_layer_pixel_shift_needs_exposed_tile devices like vent_scrubber/vent_pump, the pixel_x/pixel_y
	// nudge itself) correctly re-evaluated on every floor change in either direction - not just when going from
	// hidden to exposed. Without calling this in the do_hide branch too, a device that picked up a pixel offset
	// while its tile was exposed would keep that stale offset after a floor tile got placed back on top of it,
	// instead of re-centering.
	reset_plane_and_layer()
	apply_piping_layer_offset()
	if(do_hide && level == ATOM_LEVEL_UNDER_TILE)
		layer = hidden_layer

/obj/machinery/atmospherics/proc/add_underlay(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type)
	if(node)
		if(!T.is_plating() && node.level == ATOM_LEVEL_UNDER_TILE && istype(node, /obj/machinery/atmospherics/pipe))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "exposed" + icon_connect_type)

/obj/machinery/atmospherics/proc/update_underlays()
	if(check_icon_cache())
		return 1
	else
		return 0

// Layer and color both independently separate pipes now, same as connect_types - a pipe_color_bridge/
// pipe_layer_bridge device (the color adapter / layer adapter, pipes.dm) or a plain pipe painted PIPE_COLOR_OMNI
// bypasses the color check specifically; only a dedicated bridge device bypasses the layer check (no "omni layer").
// A null pipe_color (color was purely cosmetic before this, so most existing devices/pipes on existing maps have
// never had one set) is treated as a wildcard on either side - otherwise every uncolored valve/tank/omni device
// etc. across every existing map would stop connecting to any explicitly-colored pipe next to it.
/obj/machinery/atmospherics/proc/check_connect_types(obj/machinery/atmospherics/atmos1, obj/machinery/atmospherics/atmos2)
	if(!(atmos1.connect_types & atmos2.connect_types))
		return FALSE
	var/layer_ok = (atmos1.piping_layer == atmos2.piping_layer) || atmos1.pipe_layer_bridge || atmos2.pipe_layer_bridge
	var/color_ok = !atmos1.pipe_color || !atmos2.pipe_color || (atmos1.pipe_color == atmos2.pipe_color) \
		|| atmos1.pipe_color_bridge || atmos2.pipe_color_bridge \
		|| atmos1.pipe_color == PIPE_COLOR_OMNI || atmos2.pipe_color == PIPE_COLOR_OMNI
	return layer_ok && color_ok

/obj/machinery/atmospherics/proc/check_connect_types_construction(obj/machinery/atmospherics/atmos1, obj/item/pipe/pipe2)
	if(!(atmos1.connect_types & pipe2.connect_types))
		return FALSE
	var/layer_ok = (atmos1.piping_layer == pipe2.piping_layer) || atmos1.pipe_layer_bridge || pipe2.pipe_layer_bridge
	var/color_ok = !atmos1.pipe_color || !pipe2.color || (atmos1.pipe_color == pipe2.color) \
		|| atmos1.pipe_color_bridge || pipe2.pipe_color_bridge \
		|| atmos1.pipe_color == PIPE_COLOR_OMNI || pipe2.color == PIPE_COLOR_OMNI
	return layer_ok && color_ok

/obj/machinery/atmospherics/proc/check_icon_cache(safety = 0)
	if(!istype(icon_manager))
		if(!safety) //to prevent infinite loops
			icon_manager = new()
			check_icon_cache(1)
		return 0

	return 1

/obj/machinery/atmospherics/proc/color_cache_name(obj/machinery/atmospherics/node)
	//Don't use this for standard pipes
	if(!istype(node))
		return null

	return node.pipe_color

/obj/machinery/atmospherics/Process()
	last_flow_rate = 0
	last_power_draw = 0

	build_network()

/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node

	return null

/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	// Used when two pipe_networks are combining

/obj/machinery/atmospherics/proc/return_network_air(datum/pipe_network/reference)
	// Return a list of gas_mixture(s) in the object
	//		associated with reference pipe_network for use in rebuilding the networks gases list
	// Is permitted to return null

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)

/obj/machinery/atmospherics/on_update_icon()
	return null

// returns all pipe's endpoints. You can override, but you may then need to use a custom /item/pipe constructor.
/obj/machinery/atmospherics/proc/get_initialze_directions()
	return base_pipe_initialize_directions(dir, connect_dir_type)

/proc/base_pipe_initialize_directions(dir, connect_dir_type)
	if(!dir)
		return 0
	if(!(dir in GLOB.cardinal))
		return dir // You're on your own. Used for bent pipes.
	. = 0

	if(connect_dir_type & SOUTH)
		. |= dir
	if(connect_dir_type & NORTH)
		. |= turn(dir, 180)
	if(connect_dir_type & WEST)
		. |= turn(dir, -90)
	if(connect_dir_type & EAST)
		. |= turn(dir, 90)

/obj/machinery/atmospherics/set_dir(new_dir)
	. = ..()
	initialize_directions = get_initialze_directions()

/// Used by constructors. Shouldn't generally be called from elsewhere.
/obj/machinery/proc/set_initial_level()
	var/turf/T = get_turf(src)
	if(T)
		level = (!T.is_plating() ? ATOM_LEVEL_OVER_TILE : ATOM_LEVEL_UNDER_TILE)
