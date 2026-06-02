/*
	Ghost HUD
	Provides 4 clickable screen buttons at the bottom of the screen for ghost players:
	Follow, Teleport, HUD Cycler, Ghost Roles.
*/

/mob/observer/ghost
	hud_type = /datum/hud/ghost

/datum/hud/ghost/FinalizeInstantiation(ui_style, ui_color, ui_alpha)
	adding = list()

	var/obj/screen/ghost_button/B

	B = new /obj/screen/ghost_button/follow()
	adding += B

	B = new /obj/screen/ghost_button/teleport()
	adding += B

	B = new /obj/screen/ghost_button/hud_cycler()
	adding += B

	B = new /obj/screen/ghost_button/ghost_roles()
	adding += B

	B = new /obj/screen/ghost_button/reenter_corpse()
	adding += B

	if(mymob.client)
		mymob.client.screen += adding

// -----------------------------------------------
// Base ghost button — uses Nova's screen_ghost.dmi
// -----------------------------------------------

/obj/screen/ghost_button
	icon = 'icons/mob/screen/ghost.dmi'
	plane = HUD_PLANE
	layer = HUD_BASE_LAYER
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | NO_CLIENT_COLOR
	mouse_opacity = 1

/obj/screen/ghost_button/MouseEntered(location, control, params)
	. = ..()
	flick(icon_state + "_anim", src)

// -----------------------------------------------
// Follow Mob button  (orbit icon)
// -----------------------------------------------

/obj/screen/ghost_button/follow
	name = "Follow Mob"
	icon_state = "orbit"
	screen_loc = "CENTER-2:16,SOUTH:5"

/obj/screen/ghost_button/follow/Click()
	if(!isghost(usr))
		return
	var/mob/observer/ghost/G = usr
	G.open_follow_ui()

// -----------------------------------------------
// Teleport button  (teleport icon)
// -----------------------------------------------

/obj/screen/ghost_button/teleport
	name = "Teleport"
	icon_state = "teleport"
	screen_loc = "CENTER-1:16,SOUTH:5"

/obj/screen/ghost_button/teleport/Click()
	if(!isghost(usr))
		return
	var/mob/observer/ghost/G = usr
	G.open_teleport_ui()

// -----------------------------------------------
// HUD Cycler button  (settings icon)
// -----------------------------------------------

/obj/screen/ghost_button/hud_cycler
	name = "HUD Cycler"
	icon_state = "settings"
	screen_loc = "CENTER:16,SOUTH:5"

/obj/screen/ghost_button/hud_cycler/Click()
	if(!isghost(usr))
		return
	var/mob/observer/ghost/G = usr
	G.open_hud_cycler_ui()

// -----------------------------------------------
// Ghost Roles button  (spawners icon)
// -----------------------------------------------

/obj/screen/ghost_button/ghost_roles
	name = "Ghost Roles"
	icon_state = "spawners"
	screen_loc = "CENTER+1:16,SOUTH:5"

/obj/screen/ghost_button/ghost_roles/Click()
	if(!isghost(usr))
		return
	var/mob/observer/ghost/G = usr
	G.open_ghost_roles_ui()

// -----------------------------------------------
// Re-enter Corpse button
// -----------------------------------------------

/obj/screen/ghost_button/reenter_corpse
	name = "Re-enter Corpse"
	icon_state = "reenter_corpse"
	screen_loc = "CENTER+2:16,SOUTH:5"

/obj/screen/ghost_button/reenter_corpse/Click()
	if(!isghost(usr))
		return
	var/mob/observer/ghost/G = usr
	G.reenter_corpse()
