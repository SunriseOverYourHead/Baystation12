#define NODE1_CLOSED 1
#define NODE2_CLOSED 2

/obj/machinery/atmospherics/valve/shutoff
	icon = 'icons/atmos/clamp.dmi'
	icon_state = "map_vclamp0"

	name = "automatic shutoff valve"
	desc = "An automatic valve with control circuitry and pipe integrity sensor, capable of automatically isolating damaged segments of the pipe network."
	clicksound = 'sound/machines/buttonbeep.ogg'
	clickvol = 20
	var/close_on_leaks = TRUE	// If false it will be always open
	var/shutoff_state = 0
	connect_types = CONNECT_TYPE_REGULAR
	build_icon_state = "svalve"
	level = ATOM_LEVEL_UNDER_TILE

/obj/machinery/atmospherics/valve/shutoff/on_update_icon()
	// Deliberately NOT using "vclamp[icon_connect_type]"/"closed1[icon_connect_type]"/etc here, even though
	// scrubbers/supply set icon_connect_type to "-scrubbers"/"-supply" - those icon_state variants in
	// icons/atmos/clamp.dmi are drawn with their own baked-in artist offset (measured: centroid x=19.0 for
	// "vclamp-scrubbers" and x=12.0 for "vclamp-supply", vs x=15.0 - tile center - for the plain "vclamp"), meant
	// to visually distinguish the two from each other back when they were fixed, un-layered networks. That baked
	// offset now fights apply_piping_layer_offset()'s runtime pixel_x shift (partially cancelling it, since it's
	// in the opposite direction from where the layer shift needs to move the valve) - exactly what caused these
	// two specifically (not fuel, which never set icon_connect_type and already used the centered plain icon) to
	// look "not offset enough" at layer 2/4. Using the plain, correctly-centered icon_state for all of them and
	// tinting with pipe_color keeps the scrubbers/supply/fuel valves visually distinct by color instead.
	icon_state = "vclamp"
	color = pipe_color
	ClearOverlays()
	if (!close_on_leaks)
		AddOverlays(image('icons/atmos/clamp.dmi', "override"))
		return
	if (shutoff_state & NODE1_CLOSED)
		AddOverlays(image('icons/atmos/clamp.dmi', "closed1"))
	if (shutoff_state & NODE2_CLOSED)
		AddOverlays(image('icons/atmos/clamp.dmi', "closed2"))

/obj/machinery/atmospherics/valve/shutoff/examine(mob/user)
	. = ..()
	to_chat(user, "The automatic shutoff circuit is [close_on_leaks ? "enabled" : "disabled"].")

/obj/machinery/atmospherics/valve/shutoff/Initialize()
	. = ..()
	open()

/obj/machinery/atmospherics/valve/atmos_init()
	. = ..()
	var/turf/T = loc
	hide(hides_under_flooring() && !T.is_plating())

/obj/machinery/atmospherics/valve/shutoff/interface_interact(mob/user)
	if(CanInteract(user, DefaultTopicState()))
		close_on_leaks = !close_on_leaks
		update_icon()
		to_chat(user, SPAN_NOTICE("You [close_on_leaks ? "enable" : "disable"] the automatic shutoff circuit."))
		CouldUseTopic(user)
		return TRUE

/obj/machinery/atmospherics/valve/shutoff/physical_attack_hand(mob/user)
	return FALSE

/obj/machinery/atmospherics/valve/shutoff/hide(do_hide)
	if(istype(loc, /turf/simulated))
		set_invisibility(do_hide ? INVISIBILITY_ABSTRACT : 0)
	update_underlays()

/obj/machinery/atmospherics/valve/shutoff/Process()
	..()

	var/new_shutoff_state = 0
	if (close_on_leaks)
		if (!network_node1 || length(network_node1.leaks))
			new_shutoff_state |= NODE1_CLOSED
		if (!network_node2 || length(network_node2.leaks))
			new_shutoff_state |= NODE2_CLOSED

	if (shutoff_state == new_shutoff_state)
		return

	shutoff_state = new_shutoff_state

	if (shutoff_state > 0)
		if (open)
			close()
	else if (!open)
		open()

	update_icon()

// These 3 variants were exclusively tied to one former exclusive network each - forced onto the same fixed
// color/layer as the device that network now means (vent_scrubber/vent_pump/the fuel convention), so existing
// map-placed ones keep connecting to their loop instead of silently stranding on default layer 3 once real
// scrubber/supply/fuel pipes move to layer 2/4/1. See vent_scrubber/atmos_init()'s comment for why atmos_init()
// is the right hook. connect_types also gains the REGULAR bit here (on top of its own exclusive bit) so these
// still-exclusive-mapped valves can bridge with a newly RPD-built plain regular pipe painted/layered to match -
// without it, connect_types alone (still e.g. SCRUBBER-only vs. a new pipe's REGULAR-only) would block the
// connection even once color and layer agree. Unlike vent_scrubber/vent_pump, these keep the default
// piping_layer_pixel_shift (TRUE): a shutoff valve sits INLINE in a pipe run, not as an endpoint room fixture, so
// it needs to visually track the same per-layer nudge as the pipe passing through it - pipe/smart's own sprite
// already bakes that nudge into its art (see pipe/smart's comment), so a valve spliced into one needs a matching
// runtime pixel shift of the same magnitude (PIPING_LAYER_P_X/Y) to land on top of it instead of appearing to
// float off to the side.
/obj/machinery/atmospherics/valve/shutoff/scrubbers
	name = "scrubber shutoff valve"
	icon_state = "map_vclamp0-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"

/obj/machinery/atmospherics/valve/shutoff/scrubbers/atmos_init()
	connect_types |= CONNECT_TYPE_REGULAR
	pipe_color = PIPE_COLOR_RED
	piping_layer = 2
	apply_piping_layer_offset()
	..()

/obj/machinery/atmospherics/valve/shutoff/supply
	name = "supply shutoff valve"
	icon_state = "map_vclamp0-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"

/obj/machinery/atmospherics/valve/shutoff/supply/atmos_init()
	connect_types |= CONNECT_TYPE_REGULAR
	pipe_color = PIPE_COLOR_BLUE
	piping_layer = 4
	apply_piping_layer_offset()
	..()

/obj/machinery/atmospherics/valve/shutoff/fuel
	name = "fuel shutoff valve"
	connect_types = CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/valve/shutoff/fuel/atmos_init()
	connect_types |= CONNECT_TYPE_REGULAR
	pipe_color = PIPE_COLOR_ORANGE
	piping_layer = 1
	apply_piping_layer_offset()
	..()

#undef NODE1_CLOSED
#undef NODE2_CLOSED
