// Base type, do not use.
/obj/structure/lift
	name = "turbolift control component"
	icon = 'icons/obj/structures/turbolift.dmi'
	anchored = TRUE
	density = FALSE
	layer = ABOVE_OBJ_LAYER

	var/datum/turbolift/lift

/obj/structure/lift/set_dir(newdir)
	. = ..()
	pixel_x = 0
	pixel_y = 0
	if(dir & NORTH)
		pixel_y = -32
	else if(dir & SOUTH)
		pixel_y = 32
	else if(dir & EAST)
		pixel_x = -32
	else if(dir & WEST)
		pixel_x = 32

/obj/structure/lift/proc/pressed(mob/user)
	if(!istype(user, /mob/living/silicon))
		if(user.a_intent == I_HURT)
			user.visible_message(SPAN_DANGER("\The [user] hammers on the lift button!"))
		else
			user.visible_message(SPAN_NOTICE("\The [user] presses the lift button."))


/obj/structure/lift/New(newloc, datum/turbolift/_lift)
	lift = _lift
	return ..(newloc)

/obj/structure/lift/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/lift/attack_generic(mob/user)
	attack_hand(user)

/obj/structure/lift/attack_hand(mob/user)
	return interact(user)

/obj/structure/lift/interact(mob/user)
	if(!lift.is_functional())
		return 0
	return 1
// End base.

// Button. No HTML interface, just calls the associated lift to its floor.
/obj/structure/lift/button
	name = "elevator button"
	desc = "A call button for an elevator. Be sure to hit it three hundred times."
	icon_state = "button"
	var/light_up = FALSE
	var/datum/turbolift_floor/floor
	mouse_opacity = 2 //No more eyestrain aiming at tiny pixels

/obj/structure/lift/button/Destroy()
	if(floor && floor.ext_panel == src)
		floor.ext_panel = null
	floor = null
	return ..()

/obj/structure/lift/button/proc/reset()
	light_up = FALSE
	update_icon()

/obj/structure/lift/button/interact(mob/user)
	if(!..())
		return
	light_up()
	pressed(user)
	if(floor == lift.current_floor)
		lift.open_doors()
		spawn(3)
			reset()
		return
	lift.queue_move_to(floor)

/obj/structure/lift/button/proc/light_up()
	light_up = TRUE
	update_icon()

/obj/structure/lift/button/on_update_icon()
	if(light_up)
		icon_state = "button_lit"
	else
		icon_state = initial(icon_state)

// End button.

// Panel. Lists floors (HTML), moves with the elevator, schedules a move to a given floor.
/obj/structure/lift/panel
	name = "elevator control panel"
	icon_state = "panel"
	mouse_opacity = 2 //No more eyestrain aiming at tiny pixels


/obj/structure/lift/panel/attack_ghost(mob/user)
	return interact(user)

/obj/structure/lift/panel/interact(mob/user)
	if(!..())
		return
	ui_interact(user)

/obj/structure/lift/panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "TurboliftPanel", src.name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/structure/lift/panel/ui_data(mob/user)
	var/list/floor_list = list()
	// floors stored low-to-high; display high-to-low so upper floors appear at top
	for(var/i = length(lift.floors) to 1 step -1)
		var/datum/turbolift_floor/floor = lift.floors[i]
		floor_list += list(list(
			"index" = i,
			"label" = floor.label ? floor.label : "Level #[i]",
			"name" = floor.name ? floor.name : "",
			"queued" = (floor in lift.queued_floors),
			"current" = (floor == lift.current_floor),
		))
	return list(
		"floors" = floor_list,
		"doors_open" = lift.doors_are_open(),
	)

/obj/structure/lift/panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!lift.is_functional())
		return
	switch(action)
		if("move_to_floor")
			var/idx = text2num(params["index"])
			if(!isnum(idx) || idx < 1 || idx > length(lift.floors))
				return
			lift.queue_move_to(lift.floors[idx])
			pressed(ui.user)
			. = TRUE
		if("open_doors")
			lift.open_doors()
			. = TRUE
		if("close_doors")
			lift.close_doors()
			. = TRUE
		if("emergency_stop")
			lift.emergency_stop()
			. = TRUE

// End panel.
