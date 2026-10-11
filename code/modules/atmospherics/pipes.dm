#define SOUND_ID "pipe_leakage"

/obj/machinery/atmospherics/pipe

	health_max = 200

	var/datum/gas_mixture/air_temporary // used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	var/leaking = 0		// Do not set directly, use set_leaking(TRUE/FALSE)
	use_power = POWER_USE_OFF
	uncreated_component_parts = null // No apc connection

	var/maximum_pressure = 210 * ONE_ATMOSPHERE
	var/fatigue_pressure = 170 * ONE_ATMOSPHERE
	var/alert_pressure = 170 * ONE_ATMOSPHERE
	var/in_stasis = 0
		//minimum pressure before check_pressure(...) should be called
	var/obj/machinery/clamp/clamp // Linked stasis clamp

	can_buckle = TRUE
	buckle_require_restraints = TRUE
	var/datum/sound_token/sound_token
	build_icon_state = "simple"
	build_icon = 'icons/obj/atmospherics/pipe-item.dmi'
	pipe_class = PIPE_CLASS_BINARY
	atom_flags = ATOM_FLAG_CAN_BE_PAINTED

/obj/machinery/atmospherics/pipe/drain_power()
	return -1

/obj/machinery/atmospherics/pipe/Initialize()
	. = ..()
	if(istype(get_turf(src), /turf/simulated/wall) || istype(get_turf(src), /turf/simulated/shuttle/wall) || istype(get_turf(src), /turf/unsimulated/wall))
		level = ATOM_LEVEL_UNDER_TILE

/obj/machinery/atmospherics/pipe/hides_under_flooring()
	return level != ATOM_LEVEL_OVER_TILE

// Must match the parent signature (code/game/atoms.dm's /atom/proc/fire_act) - callers use named arguments
// (code/game/objects/effects/fire/fire.dm's /obj/turf_fire/Process()/Crossed() call
// fire_act(exposed_temperature = ..., exposed_volume = ...)), and DM resolves those against whatever override
// actually runs. This override previously declared zero parameters, which crashed with "bad arg name
// 'exposed_temperature'" the moment a real fire ever touched a pipe - a pre-existing engine bug, not something
// introduced by the reactor work.
/obj/machinery/atmospherics/pipe/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return FALSE

/obj/machinery/atmospherics/pipe/on_death()
	burst()

/obj/machinery/atmospherics/pipe/proc/set_leaking(new_leaking)
	if(new_leaking && !leaking)
		START_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		leaking = TRUE
		if(parent)
			parent.leaks |= src
			if(parent.network)
				parent.network.leaks |= src
	else if (!new_leaking && leaking)
		update_sound(0)
		STOP_PROCESSING_MACHINE(src, MACHINERY_PROCESS_SELF)
		leaking = FALSE
		if(parent)
			parent.leaks -= src
			if(parent.network)
				parent.network.leaks -= src

/obj/machinery/atmospherics/pipe/proc/update_sound(playing)
	if(playing && !sound_token)
		sound_token = GLOB.sound_player.PlayLoopingSound(src, SOUND_ID, "sound/machines/pipeleak.ogg", volume = 8, range = 3, falloff = 1, prefer_mute = TRUE)
	else if(!playing && sound_token)
		QDEL_NULL(sound_token)

/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: qdel(src) will by default return null

	return 1

/obj/machinery/atmospherics/pipe/return_air()
	if(!parent && !QDELING(src))
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent?.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent && !QDELING(src))
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent?.return_network()

/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent && !QDELING(src))
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent?.network_expand(new_network, reference)

/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent && !QDELING(src))
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent?.return_network(reference)

/obj/machinery/atmospherics/pipe/Destroy()
	QDEL_NULL(parent)
	QDEL_NULL(sound_token)
	if (clamp)
		clamp.detach()
	if(air_temporary)
		loc.assume_air(air_temporary)

	. = ..()

/obj/machinery/atmospherics/pipe/use_tool(obj/item/W, mob/living/user, list/click_params)
	if (istype(W, /obj/item/pipe))
		user.unEquip(W, loc)
		return TRUE

	if (!isWrench(W))
		return ..()

	var/turf/T = src.loc
	if (level==ATOM_LEVEL_UNDER_TILE && isturf(T) && !T.is_plating())
		to_chat(user, SPAN_WARNING("You must remove the plating first."))
		return TRUE
	if (clamp)
		to_chat(user, SPAN_WARNING("You must remove \the [clamp] first."))
		return TRUE

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()

	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		to_chat(user, SPAN_WARNING("You cannot unwrench \the [src], it is too exerted due to internal pressure."))
		return TRUE

	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You begin to unfasten \the [src]..."))

	if (!do_after(user, (W.toolspeed * 4) SECONDS, src, DO_REPAIR_CONSTRUCT))
		return TRUE

	if (clamp)
		to_chat(user, SPAN_WARNING("You must remove \the [clamp] first."))
		return TRUE

	user.visible_message(
		SPAN_NOTICE("\The [user] unfastens \the [src]."),
		SPAN_NOTICE("You have unfastened \the [src]."),
		"You hear a ratchet.")

	new /obj/item/pipe(loc, src)
	for (var/obj/machinery/meter/meter in T)
		if (meter.target == src)
			meter.dismantle()
	qdel(src)
	return TRUE

/obj/machinery/atmospherics/get_color()
	return pipe_color

/obj/machinery/atmospherics/set_color(new_color)
	pipe_color = new_color
	update_icon()

/obj/machinery/atmospherics/pipe/color_cache_name(obj/machinery/atmospherics/node)
	if(istype(src, /obj/machinery/atmospherics/unary/tank))
		return ..()

	if(istype(node, /obj/machinery/atmospherics/pipe/manifold) || istype(node, /obj/machinery/atmospherics/pipe/manifold4w))
		if(pipe_color == node.pipe_color)
			return node.pipe_color
		else
			return null
	else if(istype(node, /obj/machinery/atmospherics/pipe/simple))
		return node.pipe_color
	else
		return pipe_color

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/atmos/pipes.dmi'
	icon_state = ""
	var/pipe_icon = "" //what kind of pipe it is and from which dmi is the icon manager getting its icons, "" for simple pipes, "hepipe" for HE pipes, "hejunction" for HE junctions
	name = "pipe"
	desc = "A one meter section of regular pipe."

	// piping_layer_pixel_shift is left at its default (TRUE) here, unlike vent_scrubber/vent_pump - those are
	// standalone room-fixture endpoint devices (nothing else to align with), but this class (and manifold/
	// manifold4w/cap below) either gets fully replaced by a real pipe/smart before ever rendering at a shifted
	// layer (see convert_to_smart_pipe_on_migrate below - the exclusive-network scrubber/supply/fuel subtypes),
	// or - for the leaf types that DON'T get replaced (color_adapter/layer_adapter subclass this; so do the
	// universal adapter and pipe sparker recipes) - sits inline with a real layer-shifted pipe/smart segment and
	// needs the matching runtime shift to visually land on top of it, exactly like the shutoff valve/zpipe fix.
	convert_to_smart_pipe_on_migrate = TRUE

	volume = ATMOS_DEFAULT_VOLUME_PIPE

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	level = ATOM_LEVEL_UNDER_TILE

	rotate_class = PIPE_ROTATE_TWODIR
	connect_dir_type = SOUTH | NORTH // Overridden if dir is not a cardinal for bent pipes. For straight pipes this is correct.

/obj/machinery/atmospherics/pipe/simple/Initialize()
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	// Pipe colors and icon states are handled by an image cache - so color and icon should
	//  be null. For mapping purposes color is defined in the object definitions.
	icon = null
	alpha = 255

/obj/machinery/atmospherics/pipe/simple/hide(i)
	if(istype(loc, /turf/simulated))
		set_invisibility(i ? INVISIBILITY_ABSTRACT : 0)
	update_icon()

/obj/machinery/atmospherics/pipe/simple/Process()
	if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		..()
	else if(leaking)
		parent.mingle_with_turf(loc, volume)
		var/air = parent.air && parent.air.return_pressure()
		if(!sound_token && air)
			update_sound(1)
		else if(sound_token && !air)
			update_sound(0)
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	// Don't ask me, it happened somehow.
	if (!isturf(loc))
		return 1

	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	if(pressure_difference > maximum_pressure)
		burst()

	else if(pressure_difference > fatigue_pressure)
		//TODO: leak to turf, doing pfshhhhh
		if(prob(5))
			burst()

	else return 1

/obj/machinery/atmospherics/pipe/proc/burst()
	parent?.temporarily_store_air()
	visible_message(SPAN_DANGER("\The [src] bursts!"))
	playsound(loc, 'sound/effects/bang.ogg', 25, TRUE)
	var/datum/effect/smoke_spread/smoke = new
	smoke.set_up(1, 0, loc, 0)
	smoke.start()
	qdel(src)

/obj/machinery/atmospherics/pipe/simple/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null
	if(node2)
		node2.disconnect(src)
		node2 = null
	. = ..()

/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/simple/set_color(new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()

/obj/machinery/atmospherics/pipe/simple/on_update_icon(safety = 0)
	if(!atmos_initalized)
		return
	if(!check_icon_cache())
		return

	alpha = 255

	ClearOverlays()

	if(node1 && node2)
		AddOverlays(icon_manager.get_atmos_icon("pipe", , pipe_color, "[pipe_icon]intact[icon_connect_type]"))
	else
		AddOverlays(icon_manager.get_atmos_icon("pipe", , pipe_color, "[pipe_icon]exposed[node1?1:0][node2?1:0][icon_connect_type]"))
	//Leaking is no longer tied to "not fully connected" - a pipe missing a neighbor (freshly placed, or
	//peacefully disconnected via unwrench) is simply capped/inert, not leaking. Only violent destruction
	//(burst()/on_death()) represents an actual breach, and those already do their own instant, one-time gas
	//release (see burst() below) rather than going through this continuous-leak mechanism.
	set_leaking(FALSE)

/obj/machinery/atmospherics/pipe/simple/update_underlays()
	return

/obj/machinery/atmospherics/pipe/simple/atmos_init()
	migrate_legacy_exclusive_network()
	..()
	var/node1_dir
	var/node2_dir

	for(var/direction in GLOB.cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction
			else if (!node2_dir)
				node2_dir = direction

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
		if(target.initialize_directions & get_dir(target,src))
			if (check_connect_types(target,src))
				node1 = target
				break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
		if(target.initialize_directions & get_dir(target,src))
			if (check_connect_types(target,src))
				node2 = target
				break

	//No longer self-deletes when unconnected - pipes should be placeable standalone (matches how cap/vent, the
	//other pipe types in this file, already behaved; this just brings simple/manifold/manifold4w/he pipes in
	//line with them instead of being the odd ones out).
	var/turf/T = loc
	if(level == ATOM_LEVEL_UNDER_TILE && !T.is_plating()) hide(1)
	update_icon()

/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null

	update_icon()

	return null

/obj/machinery/atmospherics/pipe/simple/visible
	icon_state = "intact"
	level = ATOM_LEVEL_OVER_TILE

/obj/machinery/atmospherics/pipe/simple/visible/scrubbers
	name = "Scrubbers pipe"
	desc = "A one meter section of scrubbers pipe."
	icon_state = "intact-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/simple/visible/supply
	name = "Air supply pipe"
	desc = "A one meter section of supply pipe."
	icon_state = "intact-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/simple/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/simple/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/simple/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/visible/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/simple/visible/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/visible/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/visible/fuel
	name = "Fuel pipe"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/simple/hidden
	icon_state = "intact"
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	name = "Scrubbers pipe"
	desc = "A one meter section of scrubbers pipe."
	icon_state = "intact-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/simple/hidden/supply
	name = "Air supply pipe"
	desc = "A one meter section of supply pipe."
	icon_state = "intact-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/simple/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/simple/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/simple/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/hidden/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/simple/hidden/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/hidden/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/hidden/fuel
	name = "Fuel pipe"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

// The ONE regular-pipe fitting the RPD builds now (per connect_types category - regular/supply/scrubber/fuel/
// HE) - matches NovaSector's actual design: a single quaternary (up to 4 connections) pipe whose shape is
// computed at render time from which directions are actually connected, rather than the player picking a
// discrete shape (straight/bent/manifold/manifold4w/cap) up front. Ported from NovaSector's
// code/modules/atmospherics/machinery/pipes/{pipes,smart}.dm - connectable directions default to all 4
// cardinals and stay reprogrammable via the RPD's Reprogram mode (unchanged from the old binary version).
// The old discrete pipe/manifold, pipe/manifold4w and pipe/cap classes are untouched and keep working for
// whatever's already placed on existing maps - only the *catalog* (pipe_datums.dm) stops offering them.
/obj/machinery/atmospherics/pipe/smart
	name = "pipe"
	desc = "A one meter section of regular pipe. Its shape follows its connections, and its connectable directions can be reprogrammed with an RPD in Reprogram mode."
	icon = 'icons/atmos/pipes_bitmask.dmi'
	icon_state = ""
	pipe_class = PIPE_CLASS_QUATERNARY
	alpha = 255
	// pipes_bitmask.dmi already draws a distinct, shifted tile per piping_layer - see the comment on the var
	// declaration in atmospherics.dm.
	piping_layer_pixel_shift = FALSE

	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4
	/// Bitmask of directions this pipe is currently connected on - recomputed by on_update_icon(), not authoritative (node1-4 are).
	var/connections = 0
	// p_init_dir (which directions this pipe is allowed to connect on) is declared on the base
	// /obj/machinery/atmospherics class now, not here - construction.dm's use_tool() needs to set it generically
	// on any newly-built machine. Default there is already NORTH|SOUTH|EAST|WEST, same as before.

/obj/machinery/atmospherics/pipe/smart/get_initialze_directions()
	return p_init_dir

/obj/machinery/atmospherics/pipe/smart/atmos_init()
	..()
	var/connect_directions = initialize_directions

	for(var/direction in GLOB.cardinal)
		if(direction & connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if((target.initialize_directions & get_dir(target,src)) && check_connect_types(target,src))
					node1 = target
					connect_directions &= ~direction
					break
			if(node1)
				break

	for(var/direction in GLOB.cardinal)
		if(direction & connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if((target.initialize_directions & get_dir(target,src)) && check_connect_types(target,src))
					node2 = target
					connect_directions &= ~direction
					break
			if(node2)
				break

	for(var/direction in GLOB.cardinal)
		if(direction & connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if((target.initialize_directions & get_dir(target,src)) && check_connect_types(target,src))
					node3 = target
					connect_directions &= ~direction
					break
			if(node3)
				break

	for(var/direction in GLOB.cardinal)
		if(direction & connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if((target.initialize_directions & get_dir(target,src)) && check_connect_types(target,src))
					node4 = target
					connect_directions &= ~direction
					break
			if(node4)
				break

	var/turf/T = loc
	if(level == ATOM_LEVEL_UNDER_TILE && !T.is_plating()) hide(1)
	update_icon()

/obj/machinery/atmospherics/pipe/smart/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null
	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null
	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node3 = null
	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node4 = null
	update_icon()

/obj/machinery/atmospherics/pipe/smart/pipeline_expansion()
	return list(node1, node2, node3, node4)

/obj/machinery/atmospherics/pipe/smart/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null
	if(node2)
		node2.disconnect(src)
		node2 = null
	if(node3)
		node3.disconnect(src)
		node3 = null
	if(node4)
		node4.disconnect(src)
		node4 = null
	. = ..()

/obj/machinery/atmospherics/pipe/smart/on_update_icon(safety = 0)
	if(!atmos_initalized)
		return
	if(!check_icon_cache())
		return

	connections = 0
	if(node1)
		connections |= get_dir(src, node1)
	if(node2)
		connections |= get_dir(src, node2)
	if(node3)
		connections |= get_dir(src, node3)
	if(node4)
		connections |= get_dir(src, node4)

	//dir is purely a rendering hint here (get_initialze_directions() ignores it entirely) - lines the sprite up
	//with its actual connections, same as NovaSector's own update_pipe_icon().
	switch(connections)
		if(EAST|WEST)
			dir = EAST
		if(SOUTH|NORTH)
			dir = SOUTH
		else
			if(connections)
				dir = connections

	var/bitfield = CARDINAL_TO_FULLPIPES(connections)
	if(ISSTUB(connections))
		//pad out a dangling 0-or-1-connection pipe with "short" (capped) stub bits, pulling from whichever
		//directions are still allowed (initialize_directions) until it's no longer a stub - there's no sprite
		//for a single-direction pipe. Stops as soon as it's not a stub anymore, rather than capping every
		//allowed direction, to avoid clutter.
		var/bits_to_add = 0
		if(connections != 0)
			bits_to_add |= REVERSE_DIR(connections) & initialize_directions
		var/candidate = 0
		var/shift = 0
		while(ISSTUB(connections | bits_to_add) && (initialize_directions >> shift) != 0)
			candidate = initialize_directions & (1 << shift)
			if(!(candidate & connections))
				bits_to_add |= candidate
			shift += 1
		bitfield |= CARDINAL_TO_SHORTPIPES(bits_to_add)

	color = pipe_color
	icon_state = "[bitfield]_[piping_layer]"
	//Leaking is no longer tied to "not fully connected" - see the matching comment on pipe/simple/on_update_icon().
	set_leaking(FALSE)

// Color adapter and layer adapter - straight, binary (2-node) bridge segments, subclassing pipe/simple rather
// than pipe/smart since they're not shape-adaptive; they just sit at one tile and connect otherwise-incompatible
// neighbors. Ported from NovaSector's code/modules/atmospherics/machinery/pipes/color_adapter.dm and
// layermanifold.dm, adapted to this engine's simpler single-icon_state (no per-node overlay compositing) and
// node1/node2 (not nodes[]) architecture - the actual bridging logic lives entirely in check_connect_types()
// (atmospherics.dm), gated by the pipe_color_bridge/pipe_layer_bridge flags these two set; pipe/simple's existing
// atmos_init() already calls check_connect_types() for its neighbor search, so no atmos_init() override is needed
// for connectivity. on_update_icon() calls ..() to draw the normal intact/exposed pipe body (pipe/simple's own
// icon_manager-driven overlay, correctly reflecting actual node1/node2 state) then adds a small coupling-fixture
// overlay on top from the adapter's own copied sprite sheet, purely to visually flag "this segment is special" -
// earlier versions used a single static full-body sprite per adapter instead, which looked permanently "fully
// connected on both sides" (the layer adapter's "manifoldlayer" state in particular always shows all 5 layers
// converging) regardless of actual connections; this fixes that.
/obj/machinery/atmospherics/pipe/color_adapter
	name = "color adapter"
	desc = "A one meter section of regular pipe used to connect pipes of different colors together."
	pipe_color_bridge = TRUE

/obj/machinery/atmospherics/pipe/color_adapter/on_update_icon(safety = 0)
	// Same guards as pipe/simple/on_update_icon() (called via ..() below) - without them, an update_icon() call
	// that fires before atmos_init() has run would skip the body (..() returns early) while still adding the
	// coupling overlay below, leaving it orphaned/duplicated on later calls since ClearOverlays() never ran.
	if(!atmos_initalized)
		return
	if(!check_icon_cache())
		return
	..()
	AddOverlays(image('icons/atmos/color_adapter.dmi', icon_state = "adapter_center", dir = dir))

/obj/machinery/atmospherics/pipe/layer_adapter
	name = "layer adapter"
	desc = "A one meter section of regular pipe used to connect pipes on different layers together."
	pipe_layer_bridge = TRUE

/obj/machinery/atmospherics/pipe/layer_adapter/on_update_icon(safety = 0)
	if(!atmos_initalized)
		return
	if(!check_icon_cache())
		return
	..()
	AddOverlays(image('icons/atmos/layer_adapter.dmi', icon_state = "manifoldlayer_center", dir = dir))

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/atmos/manifold.dmi'
	icon_state = ""
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."
	volume = ATMOS_DEFAULT_VOLUME_PIPE * 1.5
	// See the comment on pipe/simple's declaration.
	convert_to_smart_pipe_on_migrate = TRUE

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	var/obj/machinery/atmospherics/node3
	build_icon_state = "manifold"
	level = ATOM_LEVEL_UNDER_TILE

	pipe_class = PIPE_CLASS_TRINARY
	connect_dir_type = NORTH | EAST | WEST

/obj/machinery/atmospherics/pipe/manifold/Initialize()
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	alpha = 255
	icon = null

/obj/machinery/atmospherics/pipe/manifold/hide(i)
	if(istype(loc, /turf/simulated))
		set_invisibility(i ? INVISIBILITY_ABSTRACT : 0)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)

/obj/machinery/atmospherics/pipe/manifold/Process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/manifold/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null
	if(node2)
		node2.disconnect(src)
		node2 = null
	if(node3)
		node3.disconnect(src)
		node3 = null

	. = ..()

/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node3 = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/manifold/set_color(new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()
	if(node3)
		node3.update_underlays()

/obj/machinery/atmospherics/pipe/manifold/on_update_icon(safety = 0)
	if(!atmos_initalized)
		return
	if(!check_icon_cache())
		return

	//Leaking is no longer tied to "not fully connected" - see the matching comment on pipe/simple/on_update_icon().
	set_leaking(FALSE)
	alpha = 255

	ClearOverlays()
	AddOverlays(icon_manager.get_atmos_icon("manifold", , pipe_color, "core" + icon_connect_type))
	AddOverlays(icon_manager.get_atmos_icon("manifold", , , "clamps" + icon_connect_type))
	underlays.Cut()

	var/turf/T = get_turf(src)
	var/list/directions = list(NORTH, SOUTH, EAST, WEST)
	var/node1_direction = get_dir(src, node1)
	var/node2_direction = get_dir(src, node2)
	var/node3_direction = get_dir(src, node3)

	directions -= dir

	directions -= add_underlay(T,node1,node1_direction,icon_connect_type)
	directions -= add_underlay(T,node2,node2_direction,icon_connect_type)
	directions -= add_underlay(T,node3,node3_direction,icon_connect_type)

	for(var/D in directions)
		add_underlay(T,,D,icon_connect_type)


/obj/machinery/atmospherics/pipe/manifold/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/atmos_init()
	migrate_legacy_exclusive_network()
	..()
	var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

	for(var/direction in GLOB.cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					if (check_connect_types(target,src))
						node1 = target
						connect_directions &= ~direction
						break
			if (node1)
				break


	for(var/direction in GLOB.cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					if (check_connect_types(target,src))
						node2 = target
						connect_directions &= ~direction
						break
			if (node2)
				break


	for(var/direction in GLOB.cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					if (check_connect_types(target,src))
						node3 = target
						connect_directions &= ~direction
						break
			if (node3)
				break

	var/turf/T = get_turf(src)
	if(level == ATOM_LEVEL_UNDER_TILE && !T.is_plating()) hide(1)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/visible
	icon_state = "map"
	level = ATOM_LEVEL_OVER_TILE

/obj/machinery/atmospherics/pipe/manifold/visible/scrubbers
	name="Scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes."
	icon_state = "map-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/manifold/visible/supply
	name="Air supply pipe manifold"
	desc = "A manifold composed of supply pipes."
	icon_state = "map-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/manifold/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold/visible/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/manifold/visible/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold/visible/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold/visible/fuel
	name = "Fuel pipe manifold"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/manifold/hidden
	icon_state = "map"
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers
	name="Scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes."
	icon_state = "map-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/manifold/hidden/supply
	name="Air supply pipe manifold"
	desc = "A manifold composed of supply pipes."
	icon_state = "map-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/manifold/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold/hidden/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/manifold/hidden/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold/hidden/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold/hidden/fuel
	name = "Fuel pipe manifold"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/atmos/manifold.dmi'
	icon_state = ""
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes."
	volume = ATMOS_DEFAULT_VOLUME_PIPE * 2
	// See the comment on pipe/simple's declaration.
	convert_to_smart_pipe_on_migrate = TRUE

	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST

	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4
	build_icon_state = "manifold4w"
	level = ATOM_LEVEL_UNDER_TILE

	pipe_class = PIPE_CLASS_QUATERNARY
	rotate_class = PIPE_ROTATE_ONEDIR
	connect_dir_type = NORTH | SOUTH | EAST | WEST

/obj/machinery/atmospherics/pipe/manifold4w/Initialize()
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	alpha = 255
	icon = null

/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)

/obj/machinery/atmospherics/pipe/manifold4w/Process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/manifold4w/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null
	if(node2)
		node2.disconnect(src)
		node2 = null
	if(node3)
		node3.disconnect(src)
		node3 = null
	if(node4)
		node4.disconnect(src)
		node4 = null

	. = ..()

/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node3 = null

	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node4 = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/manifold4w/set_color(new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()
	if(node3)
		node3.update_underlays()
	if(node4)
		node4.update_underlays()

/obj/machinery/atmospherics/pipe/manifold4w/on_update_icon(safety = 0)
	if(!atmos_initalized)
		return
	if(!check_icon_cache())
		return

	//Leaking is no longer tied to "not fully connected" - see the matching comment on pipe/simple/on_update_icon().
	set_leaking(FALSE)
	alpha = 255

	ClearOverlays()
	AddOverlays(icon_manager.get_atmos_icon("manifold", , pipe_color, "4way" + icon_connect_type))
	AddOverlays(icon_manager.get_atmos_icon("manifold", , , "clamps_4way" + icon_connect_type))
	underlays.Cut()

	var/turf/T = get_turf(src)
	var/list/directions = list(NORTH, SOUTH, EAST, WEST)
	var/node1_direction = get_dir(src, node1)
	var/node2_direction = get_dir(src, node2)
	var/node3_direction = get_dir(src, node3)
	var/node4_direction = get_dir(src, node4)

	directions -= dir

	directions -= add_underlay(T,node1,node1_direction,icon_connect_type)
	directions -= add_underlay(T,node2,node2_direction,icon_connect_type)
	directions -= add_underlay(T,node3,node3_direction,icon_connect_type)
	directions -= add_underlay(T,node4,node4_direction,icon_connect_type)

	for(var/D in directions)
		add_underlay(T,,D,icon_connect_type)


/obj/machinery/atmospherics/pipe/manifold4w/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/hide(i)
	if(istype(loc, /turf/simulated))
		set_invisibility(i ? INVISIBILITY_ABSTRACT : 0)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/atmos_init()
	migrate_legacy_exclusive_network()
	..()
	for(var/obj/machinery/atmospherics/target in get_step(src,1))
		if(target.initialize_directions & 2)
			if (check_connect_types(target,src))
				node1 = target
				break

	for(var/obj/machinery/atmospherics/target in get_step(src,2))
		if(target.initialize_directions & 1)
			if (check_connect_types(target,src))
				node2 = target
				break

	for(var/obj/machinery/atmospherics/target in get_step(src,4))
		if(target.initialize_directions & 8)
			if (check_connect_types(target,src))
				node3 = target
				break

	for(var/obj/machinery/atmospherics/target in get_step(src,8))
		if(target.initialize_directions & 4)
			if (check_connect_types(target,src))
				node4 = target
				break

	var/turf/T = get_turf(src)
	if(level == ATOM_LEVEL_UNDER_TILE && !T.is_plating()) hide(1)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/visible
	icon_state = "map_4way"
	level = ATOM_LEVEL_OVER_TILE

/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes."
	icon_state = "map_4way-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/visible/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes."
	icon_state = "map_4way-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/visible/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/manifold4w/visible/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/visible/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/visible/fuel
	name = "4-way fuel pipe manifold"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/manifold4w/hidden
	icon_state = "map_4way"
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes."
	icon_state = "map_4way-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes."
	icon_state = "map_4way-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/manifold4w/hidden/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/hidden/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/hidden/fuel
	name = "4-way fuel pipe manifold"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/cap
	name = "pipe endcap"
	desc = "An endcap for pipes."
	icon = 'icons/atmos/pipes.dmi'
	icon_state = ""
	volume = 35
	// See the comment on pipe/simple's declaration.
	convert_to_smart_pipe_on_migrate = TRUE

	pipe_class = PIPE_CLASS_UNARY
	dir = SOUTH
	initialize_directions = SOUTH
	build_icon_state = "cap"

	var/obj/machinery/atmospherics/node

/obj/machinery/atmospherics/pipe/cap/hide(i)
	if(istype(loc, /turf/simulated))
		set_invisibility(i ? INVISIBILITY_ABSTRACT : 0)
	update_icon()

/obj/machinery/atmospherics/pipe/cap/pipeline_expansion()
	return list(node)

/obj/machinery/atmospherics/pipe/cap/Process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL
/obj/machinery/atmospherics/pipe/cap/Destroy()
	if(node)
		node.disconnect(src)

	. = ..()

/obj/machinery/atmospherics/pipe/cap/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node)
		if(istype(node, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/cap/set_color(new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node)
		node.update_underlays()

/obj/machinery/atmospherics/pipe/cap/on_update_icon(safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	ClearOverlays()
	AddOverlays(icon_manager.get_atmos_icon("pipe", , pipe_color, icon_state))

/obj/machinery/atmospherics/pipe/cap/atmos_init()
	migrate_legacy_exclusive_network()
	..()
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			if (check_connect_types(target,src))
				node = target
				break

	var/turf/T = src.loc			// hide if turf is not intact
	if(level == ATOM_LEVEL_UNDER_TILE && !T.is_plating()) hide(1)
	update_icon()

/obj/machinery/atmospherics/pipe/cap/visible
	icon_state = "cap"

/obj/machinery/atmospherics/pipe/cap/visible/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes."
	icon_state = "cap-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/cap/visible/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes."
	icon_state = "cap-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/cap/visible/fuel
	name = "fuel pipe endcap"
	desc = "An endcap for fuel pipes."
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/cap/hidden
	level = ATOM_LEVEL_UNDER_TILE
	icon_state = "cap"
	alpha = 128

/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes."
	icon_state = "cap-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = EXPOSED_SCRUBBERS_LAYER
	hidden_layer = SCRUBBERS_LAYER

/obj/machinery/atmospherics/pipe/cap/hidden/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes."
	icon_state = "cap-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = EXPOSED_SUPPLY_LAYER
	hidden_layer = SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/cap/hidden/fuel
	name = "fuel pipe endcap"
	desc = "An endcap for fuel pipes."
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "intact"

	name = "Vent"
	desc = "A large air vent."

	level = ATOM_LEVEL_UNDER_TILE

	volume = 250

	dir = SOUTH
	initialize_directions = SOUTH

	var/build_killswitch = 1
	build_icon_state = "uvent"

/obj/machinery/atmospherics/pipe/vent/high_volume
	name = "Larger vent"
	volume = 1000

/obj/machinery/atmospherics/pipe/vent/Process()
	if(!parent)
		if(build_killswitch <= 0)
			. = PROCESS_KILL
		else
			build_killswitch--
		..()
		return
	else
		parent.mingle_with_turf(loc, volume)

/obj/machinery/atmospherics/pipe/vent/Destroy()
	if(node1)
		node1.disconnect(src)

	. = ..()

/obj/machinery/atmospherics/pipe/vent/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/vent/on_update_icon()
	if(node1)
		icon_state = "intact"

		set_dir(get_dir(src, node1))

	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/vent/atmos_init()
	..()
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			if (check_connect_types(target,src))
				node1 = target
				break

	update_icon()

/obj/machinery/atmospherics/pipe/vent/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	update_icon()

	return null

/obj/machinery/atmospherics/pipe/vent/hide(i) //to make the little pipe section invisible, the icon changes.
	if(node1)
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		set_dir(get_dir(src, node1))
	else
		icon_state = "exposed"


/obj/machinery/atmospherics/pipe/simple/visible/universal
	name="Universal pipe adapter"
	desc = "An adapter for regular, supply, scrubbers, and fuel pipes."
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY|CONNECT_TYPE_SCRUBBER|CONNECT_TYPE_FUEL|CONNECT_TYPE_HE
	icon_state = "map_universal"
	build_icon_state = "universal"

/obj/machinery/atmospherics/pipe/simple/visible/universal/on_update_icon(safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	ClearOverlays()
	AddOverlays(icon_manager.get_atmos_icon("pipe", , pipe_color, "universal"))
	underlays.Cut()

	if (node1)
		universal_underlays(node1)
		if(node2)
			universal_underlays(node2)
		else
			var/node1_dir = get_dir(node1,src)
			universal_underlays(,node1_dir)
	else if (node2)
		universal_underlays(node2)
	else
		universal_underlays(,dir)
		universal_underlays(null, turn(dir, 180))

/obj/machinery/atmospherics/pipe/simple/visible/universal/update_underlays()
	..()
	update_icon()



/obj/machinery/atmospherics/pipe/simple/hidden/universal
	name="Universal pipe adapter"
	desc = "An adapter for regular, supply and scrubbers pipes."
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY|CONNECT_TYPE_SCRUBBER|CONNECT_TYPE_FUEL|CONNECT_TYPE_HE
	icon_state = "map_universal"

/obj/machinery/atmospherics/pipe/simple/hidden/universal/on_update_icon(safety = 0)
	if(!check_icon_cache())
		return

	alpha = 255

	ClearOverlays()
	AddOverlays(icon_manager.get_atmos_icon("pipe", , pipe_color, "universal"))
	underlays.Cut()

	if (node1)
		universal_underlays(node1)
		if(node2)
			universal_underlays(node2)
		else
			var/node2_dir = turn(get_dir(src,node1),-180)
			universal_underlays(,node2_dir)
	else if (node2)
		universal_underlays(node2)
		var/node1_dir = turn(get_dir(src,node2),-180)
		universal_underlays(,node1_dir)
	else
		universal_underlays(,dir)
		universal_underlays(,turn(dir, -180))

/obj/machinery/atmospherics/pipe/simple/hidden/universal/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/proc/universal_underlays(obj/machinery/atmospherics/node, direction)
	var/turf/T = loc
	if(node)
		var/node_dir = get_dir(src,node)
		if(node.icon_connect_type == "-supply")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, node, node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
		else if (node.icon_connect_type == "-scrubbers")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, node, node_dir, "-scrubbers")
		else
			add_underlay_adapter(T, node, node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
	else
		add_underlay_adapter(T, , direction, "-supply")
		add_underlay_adapter(T, , direction, "-scrubbers")
		add_underlay_adapter(T, , direction, "")

/obj/machinery/atmospherics/proc/add_underlay_adapter(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type) //modified from add_underlay, does not make exposed underlays
	if(node)
		if(!T.is_plating() && node.level == ATOM_LEVEL_UNDER_TILE && istype(node, /obj/machinery/atmospherics/pipe))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "retracted" + icon_connect_type)

#undef SOUND_ID
