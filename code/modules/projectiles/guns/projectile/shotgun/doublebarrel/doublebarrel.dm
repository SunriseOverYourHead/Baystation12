/obj/item/gun/projectile/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A classic double-barreled shotgun. In production for centuries, it has proliferated across human space, earning a sizable reputation for being simple and effective. Produced by Novaya Zemlya Arms."
	icon = 'code/modules/projectiles/guns/projectile/shotgun/doublebarrel/doublebarrel.dmi'
	icon_state = "dshotgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/shotgun/doublebarrel/doublebarrel.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/shotgun/doublebarrel/doublebarrel.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/shotgun/doublebarrel/doublebarrel.dmi',
	)
	colocated_sprites = TRUE
	item_state = "dshotgun"
	wielded_item_state = "dshotgun-wielded"
	//SPEEDLOADER because rapid unloading.
	//In principle someone could make a speedloader for it, so it makes sense.
	load_method = SINGLE_CASING|SPEEDLOADER
	handle_casings = CYCLE_CASINGS
	max_shells = 2
	w_class = ITEM_SIZE_HUGE
	force = 10
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	caliber = PROJECTILE_SHOTGUN
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 1)
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	one_hand_penalty = 8
	wielded_item_state = "gun_wielded"

	burst_delay = 0
	firemodes = list(
		list(
			"mode_name" = "fire one barrel at a time",
			"burst" = 1
		),
		list(
			"mode_name" = "fire both barrels at once",
			"burst" = 2
		)
	)

/obj/item/gun/projectile/shotgun/doublebarrel/pellet
	ammo_type = /obj/item/ammo_casing/shotgun/pellet

/obj/item/gun/projectile/shotgun/doublebarrel/flare
	name = "signal shotgun"
	desc = "A double-barreled shotgun meant to fire signal flash shells."
	ammo_type = /obj/item/ammo_casing/shotgun/flash

/obj/item/gun/projectile/shotgun/doublebarrel/unload_ammo(user, allow_dump)
	..(user, allow_dump=1)


//this is largely hacky and bad :(	-Pete
/obj/item/gun/projectile/shotgun/doublebarrel/use_tool(obj/item/tool, mob/user, list/click_params)
	// Circular saw, energy sword, plasmacutter - Shorten barrel
	if (is_type_in_list(tool, list(/obj/item/circular_saw, /obj/item/melee/energy, /obj/item/gun/energy/plasmacutter)))
		if (w_class <= 3)
			USE_FEEDBACK_FAILURE("\The [src]'s barrel can't be shortened any further.")
			return TRUE
		if (!user.canUnEquip(src))
			FEEDBACK_UNEQUIP_FAILURE(user, src)
			return TRUE
		if (istype(tool, /obj/item/melee/energy))
			var/obj/item/melee/energy/energy = tool
			if (!energy.active)
				USE_FEEDBACK_FAILURE("\The [tool] needs to be active to cut \the [src]'s barrel.")
				return TRUE
		if (istype(tool, /obj/item/gun/energy/plasmacutter))
			var/obj/item/gun/energy/plasmacutter/plasmacutter = tool
			if (!plasmacutter.slice(user))
				return TRUE
		user.visible_message(
			SPAN_NOTICE("\The [user] starts shortening \a [src]'s barrel with \a [tool]."),
			SPAN_NOTICE("You start shortening \the [src]'s barrel with \the [tool].")
		)
		if (length(loaded))
			for (var/i in 1 to max_shells)
				Fire(user, user)
			visible_message(
				SPAN_DANGER("\The [src] goes off!"),
				SPAN_DANGER("You hear a gunshot!")
			)
			return TRUE
		if (!user.do_skilled(3 SECONDS, SKILL_CONSTRUCTION, src) || !user.use_sanity_check(src, tool, SANITY_CHECK_TARGET_UNEQUIP))
			return TRUE
		if (istype(tool, /obj/item/melee/energy))
			var/obj/item/melee/energy/energy = tool
			if (!energy.active)
				USE_FEEDBACK_FAILURE("\The [tool] needs to be active to cut \the [src]'s barrel.")
				return TRUE
		if (istype(tool, /obj/item/gun/energy/plasmacutter))
			var/obj/item/gun/energy/plasmacutter/plasmacutter = tool
			if (!plasmacutter.slice(user))
				return TRUE
		user.unEquip(src)
		var/obj/item/gun/projectile/shotgun/doublebarrel/sawn/empty/new_gun = new(get_turf(src))
		transfer_fingerprints_to(new_gun)
		new_gun.add_fingerprint(user, tool = tool)
		user.visible_message(
			SPAN_NOTICE("\The [user] shortens \a [src]'s barrel with \a [tool]."),
			SPAN_NOTICE("You shorten \the [src]'s barrel with \the [tool].")
		)
		qdel_self()
		return TRUE

	return ..()


/obj/item/gun/projectile/shotgun/doublebarrel/sawn
	name = "sawn-off shotgun"
	desc = "A ubiquitous weapon, commonplace in almost every settlement and slum. It is one of many basic firearms for those who want to be able to defend themselves with as little fuss as possible. Produced by Novaya Zemlya Arms."
	icon_state = "sawnshotgun"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/shotgun/doublebarrel/doublebarrel.dmi',
	)
	colocated_sprites = FALSE
	item_state = "sawnshotgun"
	wielded_item_state = "sawnshotgun-wielded"
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	w_class = ITEM_SIZE_NORMAL
	force = 5
	one_hand_penalty = 4
	bulk = 2

/obj/item/gun/projectile/shotgun/doublebarrel/sawn/empty
	starts_loaded = FALSE
