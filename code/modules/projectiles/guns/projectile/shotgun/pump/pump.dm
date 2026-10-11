/obj/item/gun/projectile/shotgun/pump
	name = "shotgun"
	desc = "A mass-produced shotgun by Mars Security Industries. The rugged MSI-870 'Crawford' is a common sight across much of settled space. Useful for sweeping alleys or ship corridors."
	icon = 'code/modules/projectiles/guns/projectile/shotgun/pump/pump.dmi'
	icon_state = "shotgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/shotgun/pump/pump.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/shotgun/pump/pump.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/shotgun/pump/pump.dmi',
	)
	colocated_sprites = TRUE
	item_state = "shotgun"
	max_shells = 4
	w_class = ITEM_SIZE_HUGE
	force = 10
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	caliber = PROJECTILE_SHOTGUN
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	load_method = SINGLE_CASING
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	handle_casings = HOLD_CASINGS
	one_hand_penalty = 8
	bulk = 6
	var/recentpump = 0 // to prevent spammage
	wielded_item_state = "shotgun-wielded"
	load_sound = 'sound/weapons/guns/interaction/shotgun_instert.ogg'

/obj/item/gun/projectile/shotgun/pump/on_update_icon()
	..()
	if(chambered)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-empty"

/obj/item/gun/projectile/shotgun/pump/consume_next_projectile()
	if(chambered)
		return chambered.BB
	return null

/obj/item/gun/projectile/shotgun/pump/attack_self(mob/living/user as mob)
	if(world.time >= recentpump + 10)
		if(!is_held_twohanded(user))
			var/fail_chance = user.skill_fail_chance(SKILL_WEAPONS, 90, SKILL_EXPERIENCED, 0.25)
			var/drop_chance = user.skill_fail_chance(SKILL_WEAPONS, 50, SKILL_EXPERIENCED, 0.5)

			if (!fail_chance)
				user.visible_message(
					SPAN_NOTICE("\The [user] racks \the [src] with one hand."),
					SPAN_NOTICE("You manage to rack \the [src] with one hand.")
				)
				pump(user)
			else if (prob(fail_chance))
				if (prob(drop_chance) && user.unEquip(src, user.loc))
					user.visible_message(
						SPAN_WARNING("\The [user] attempts to rack \the [src], but it falls out of their hands!"),
						SPAN_WARNING("You attempt to rack \the [src], but it falls out of your hands!")
					)
				else
					user.visible_message(
						SPAN_WARNING("\The [user] fails to rack \the [src]!"),
						SPAN_WARNING("You fail to rack \the [src]!")
					)
			else
				user.visible_message(
					SPAN_NOTICE("\The [user] manages to akwardly rack \the [src] with one hand."),
					SPAN_NOTICE("You manage to awkwardly rack \the [src] with one hand.")
				)
				pump(user)

		else
			pump(user)

		recentpump = world.time

/obj/item/gun/projectile/shotgun/pump/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)

	if(chambered)//We have a shell in the chamber
		chambered.dropInto(loc)//Eject casing
		if(LAZYLEN(chambered.fall_sounds))
			playsound(loc, pick(chambered.fall_sounds), 50, 1)
		chambered = null

	if(length(loaded))
		var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
		loaded -= AC //Remove casing from loaded list.
		chambered = AC

	update_icon()


/obj/item/gun/projectile/shotgun/pump/use_tool(obj/item/tool, mob/user, list/click_params)
	if (type != /obj/item/gun/projectile/shotgun/pump)
		return ..() // ugly hack for now, /pump needs abstracting

	// Circular saw, energy sword, plasma cutter - Saw off stock
	if (is_type_in_list(tool, list(/obj/item/circular_saw, /obj/item/melee/energy, /obj/item/gun/energy/plasmacutter)))
		if (!user.canUnEquip(src))
			FEEDBACK_UNEQUIP_FAILURE(user, src)
			return TRUE
		if (istype(tool, /obj/item/melee/energy))
			var/obj/item/melee/energy/energy = tool
			if (!energy.active)
				USE_FEEDBACK_FAILURE("\The [tool] needs to be active to cut \the [src]'s stock.")
				return TRUE
		if (istype(tool, /obj/item/gun/energy/plasmacutter))
			var/obj/item/gun/energy/plasmacutter/plasmacutter = tool
			if (!plasmacutter.slice(user))
				return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] starts sawing \a [src]'s stock off with \a [tool]."),
			SPAN_NOTICE("You start sawing \the [src]'s stock off with \the [tool].")
		)
		if (!user.do_skilled(5 SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, tool, SANITY_CHECK_TARGET_UNEQUIP))
			return TRUE
		user.unEquip(src)
		var/obj/item/gun/projectile/shotgun/pump/sawn/sawn = new (get_turf(src))
		transfer_fingerprints_to(sawn)
		sawn.add_fingerprint(user, tool = tool)
		user.visible_message(
			SPAN_NOTICE("\The [user] saws \a [src]'s stock off with \a [tool]."),
			SPAN_NOTICE("You saw \the [src]'s stock off with \the [tool].")
		)
		qdel_self()
		return TRUE

	return ..()

/obj/item/gun/projectile/shotgun/pump/DrawChamber()
	var/chamberlist = ""
	if (chambered)
		if (chambered.BB)
			chamberlist += "◉|"
		else
			chamberlist += "◎|"
	else
		chamberlist += "🌣|"
	if (length(loaded) > 0)
		var/obj/item/ammo_casing/casinglist = loaded
		if (casinglist[1].BB)
			chamberlist += "◉"
		else
			chamberlist += "◎"
	else
		chamberlist += "🌣"
	return chamberlist

/obj/item/gun/projectile/shotgun/pump/empty
	starts_loaded = FALSE

/obj/item/gun/projectile/shotgun/pump/sawn
	name = "riot shotgun"
	desc = "A mass-produced shotgun by Mars Security Industries. The rugged MSI-870 is a common sight across much of settled space. MSI sells its own 'riot' configuration as the 870 'Bateman'."
	icon_state = "rshotgun"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/shotgun/pump/pump.dmi',
	)
	colocated_sprites = FALSE
	item_state = "rshotgun"
	max_shells = 4
	w_class = ITEM_SIZE_LARGE
	force = 10
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT|SLOT_BACK
	caliber = PROJECTILE_SHOTGUN
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	load_method = SINGLE_CASING
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	handle_casings = HOLD_CASINGS
	one_hand_penalty = 4
	bulk = 4
	wielded_item_state = "rshotgun-wielded"
	load_sound = 'sound/weapons/guns/interaction/shotgun_instert.ogg'


/obj/item/gun/projectile/shotgun/pump/combat
	name = "combat shotgun"
	desc = "Built for close quarters combat, the Hephaestus Industries KS-40 is widely regarded as a weapon of choice for repelling boarders."
	icon_state = "cshotgun"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/shotgun/pump/pump.dmi',
	)
	colocated_sprites = FALSE
	item_state = "cshotgun"
	item_state_slots = list(slot_back_str = "shotgun_back")
	wielded_item_state = "cshotgun-wielded"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	max_shells = 7 //match the ammo box capacity, also it can hold a round in the chamber anyways, for a total of 8.
	ammo_type = /obj/item/ammo_casing/shotgun
	one_hand_penalty = 8

/obj/item/gun/projectile/shotgun/pump/combat/on_update_icon()
	..()
	if(length(loaded) > 3)
		for(var/i = 0 to length(loaded) - 4)
			var/image/I = image(icon, "shell")
			I.pixel_x = i * 2
			AddOverlays(I)

/obj/item/gun/projectile/shotgun/pump/combat/empty
	starts_loaded = FALSE
