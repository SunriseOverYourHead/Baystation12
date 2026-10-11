#define PIPE_STRAIGHT 1
#define PIPE_BENT     9
#define PIPE_CAP      1

// Regular/Supply/Scrubber/Fuel pipes now only offer ONE fitting each ("straight" - though it no longer builds a
// literal straight pipe; see /obj/machinery/atmospherics/pipe/smart in pipes.dm): a single auto-shaping pipe
// whose sprite is computed from its actual connections at render time, matching NovaSector's design. The old
// discrete bent/manifold/manifold4w/cap recipe entries are gone; those DM classes (pipe/manifold, pipe/
// manifold4w, pipe/cap) are untouched in pipes.dm and keep working for whatever's already on existing maps -
// only this catalog stopped offering them as something new to build. Heat Exchange pipes are a Baystation-only
// concept with no NovaSector equivalent, so that category is untouched and keeps its discrete shapes.
/datum/pipe/pipe_dispenser/simple
	category = "Regular Pipes"
	colorable = TRUE
	connect_types = CONNECT_TYPE_REGULAR
	pipe_color = PIPE_COLOR_GREY
	constructed_path = /obj/machinery/atmospherics/pipe/smart
	pipe_class = PIPE_CLASS_QUATERNARY


/datum/pipe/pipe_dispenser/simple/straight
	name = "a pipe fitting"
	desc = "a regular pipe segment - its shape follows whatever it ends up connected to."
	build_path = /obj/item/pipe
	rotate_class = PIPE_ROTATE_TWODIR
	placement_mode = PIPE_PLACEMENT_ORTHOGONAL

/datum/pipe/pipe_dispenser/simple/up
	name = "upward pipe fitting"
	desc = "an upward pipe."
	build_path = /obj/item/pipe
	build_icon = 'icons/obj/structures/structures.dmi'
	build_icon_state = "up"
	dir = PIPE_CAP
	pipe_class = PIPE_CLASS_UNARY
	constructed_path = /obj/machinery/atmospherics/pipe/zpipe/up
	placement_mode = PIPE_PLACEMENT_ORTHOGONAL

/datum/pipe/pipe_dispenser/simple/down
	name = "downward pipe fitting"
	desc = "a downward pipe."
	build_path = /obj/item/pipe
	build_icon = 'icons/obj/structures/structures.dmi'
	build_icon_state = "down"
	dir = PIPE_CAP
	pipe_class = PIPE_CLASS_UNARY
	constructed_path = /obj/machinery/atmospherics/pipe/zpipe/down
	placement_mode = PIPE_PLACEMENT_ORTHOGONAL

/datum/pipe/pipe_dispenser/simple/autoshutoff
	name = "automatic shutoff valve"
	desc = "a valve that can automatically shut itself off"
	build_path = /obj/item/pipe
	build_icon_state = "svalve"
	colorable = FALSE
	pipe_color = PIPE_COLOR_WHITE
	constructed_path = /obj/machinery/atmospherics/valve/shutoff
	pipe_class = PIPE_CLASS_BINARY
	rotate_class = PIPE_ROTATE_TWODIR

// Colors and layers now independently separate pipes (see check_connect_types() in atmospherics.dm), so a color
// adapter/layer adapter is needed to deliberately bridge two otherwise-incompatible networks - ported from
// NovaSector's color_adapter.dm/layermanifold.dm. Painting a pipe "omni" also bridges a color mismatch on its
// own (no adapter needed); there's no layer equivalent of omni, only the dedicated adapter.
/datum/pipe/pipe_dispenser/simple/color_adapter
	name = "color adapter"
	desc = "a pipe fitting that connects to pipes of any color."
	build_path = /obj/item/pipe
	build_icon_state = "svalve"
	colorable = FALSE
	pipe_color = PIPE_COLOR_OMNI
	pipe_color_bridge = TRUE
	constructed_path = /obj/machinery/atmospherics/pipe/color_adapter
	pipe_class = PIPE_CLASS_BINARY
	rotate_class = PIPE_ROTATE_TWODIR
	placement_mode = PIPE_PLACEMENT_ORTHOGONAL

/datum/pipe/pipe_dispenser/simple/layer_adapter
	name = "layer adapter"
	desc = "a pipe fitting that connects to pipes on any layer."
	build_path = /obj/item/pipe
	build_icon_state = "svalve"
	pipe_layer_bridge = TRUE
	constructed_path = /obj/machinery/atmospherics/pipe/layer_adapter
	pipe_class = PIPE_CLASS_BINARY
	rotate_class = PIPE_ROTATE_TWODIR
	placement_mode = PIPE_PLACEMENT_ORTHOGONAL

/datum/pipe/pipe_dispenser/he
	category = "Heat Exchange Pipes"
	colorable = FALSE
	connect_types = CONNECT_TYPE_HE
	constructed_path = /obj/machinery/atmospherics/pipe/simple/heat_exchanging
	pipe_class = PIPE_CLASS_BINARY

/datum/pipe/pipe_dispenser/he/straight
	name = "heat exchanger pipe fitting"
	desc = "a heat exchanger pipe segment"
	build_path = /obj/item/pipe
	build_icon_state = "he"
	rotate_class = PIPE_ROTATE_TWODIR

/datum/pipe/pipe_dispenser/he/bent
	name = "bent heat exchanger pipe fitting"
	desc = "a bent heat exchanger pipe segment"
	build_path = /obj/item/pipe
	connect_types = CONNECT_TYPE_HE
	rotate_class = PIPE_ROTATE_TWODIR
	build_icon_state = "he"
	dir = PIPE_BENT
	placement_mode = PIPE_PLACEMENT_DIAGONAL

/datum/pipe/pipe_dispenser/he/junction
	name = "heat exchanger junction"
	desc = "a heat exchanger junction"
	build_path = /obj/item/pipe
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_HE
	build_icon_state = "junction"
	constructed_path = /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction

/datum/pipe/pipe_dispenser/he/exchanger
	name = "heat exchanger"
	desc = "a heat exchanger"
	build_path = /obj/item/pipe
	connect_types = CONNECT_TYPE_REGULAR
	build_icon_state = "heunary"
	constructed_path = /obj/machinery/atmospherics/unary/heat_exchanger
	pipe_class = PIPE_CLASS_UNARY

//Cleanup
#undef PIPE_STRAIGHT
#undef PIPE_BENT
