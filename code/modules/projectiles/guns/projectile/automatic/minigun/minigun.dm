/obj/item/gun/projectile/automatic/minigun
	name = "minigun"
	desc = "A man-portable minigun lacking any branding on it. It fires small 7mm projectiles at an obscene rate of fire. Six barrels of fun."
	icon = 'code/modules/projectiles/guns/projectile/automatic/minigun/minigun.dmi'
	icon_state = "minigun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/minigun/minigun.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/minigun/minigun.dmi',
	)
	colocated_sprites = TRUE
	item_state = "l6closedmag" /// Onmob is WIP sprite
	w_class = ITEM_SIZE_HUGE
	force = 15
	caliber = PROJECTILE_PISTOL_SMALL
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 4, TECH_ESOTERIC = 8)
	slot_flags = 0
	load_method = MAGAZINE
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	magazine_type = /obj/item/ammo_magazine/box/minigun
	allowed_magazines = /obj/item/ammo_magazine/box/minigun
	accuracy = 1
	one_hand_penalty = 20
	mag_insert_sound = 'sound/weapons/guns/interaction/lmg_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/lmg_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/minigun.ogg'
	can_special_reload = FALSE

	firemodes = list(
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.4,
			"move_delay" = 1,
			"burst_accuracy" = list(0, -1, -2, -3, -4, -4, -4, -4, -4),
			"dispersion" = list(1.0, 1.0, 2.0, 2.0, 2.5),
			"burst_delay" = 1
		),
		list(
			"mode_name" = "long bursts",
			"can_autofire" = 0,
			"burst" = 10,
			"fire_delay" = 0.2,
			"burst_accuracy" = list(0, -1, -2, -3, -4, -8, -8, -16, -16),
			"dispersion" = list(1.0, 2.0, 3.0, 3.0, 4.0),
			"burst_delay" = 1
		)
	)

/obj/item/gun/projectile/automatic/minigun/mounted
	name = "mounted minigun"
	accuracy = 0 /// Less accurate than a full-sized minigun and only fires in bursts, but has no one-hand penalty.
	one_hand_penalty = 0
	has_safety = FALSE
	auto_eject = TRUE
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'

	firemodes = list(
		list(
			"mode_name" = "long bursts",
			"can_autofire" = 0,
			"burst" = 5,
			"fire_delay" = 0.2,
			"burst_accuracy" = list(0, -1, -2, -3, -4, -4, -4, -4, -4),
			"dispersion" = list(1.0, 1.0, 2.0, 2.0, 2.5),
			"burst_delay" = 1
		),
		list(
			"mode_name" = "longer bursts",
			"can_autofire" = 0,
			"burst" = 10,
			"fire_delay" = 0.2,
			"burst_accuracy" = list(0, -1, -2, -3, -4, -8, -8, -16, -16),
			"dispersion" = list(1.0, 2.0, 3.0, 3.0, 4.0),
			"burst_delay" = 1
		)
	)

/obj/item/gun/projectile/automatic/minigun/mounted/load_ammo(obj/item/A, mob/user)
	var/obj/item/rig/rig = get_rig()
	if (istype(rig))
		if (!rig.offline && rig.suit_is_deployed())
			user.visible_message(SPAN_NOTICE("\The [user] begins the slow process of re-arming \The [src]."), range = 4)
			do_after(user, 10 SECONDS, src, DO_PUBLIC_UNIQUE | DO_BAR_OVER_USER)
			..()
		else
			to_chat(user, SPAN_DANGER("You can't reload your minigun without deploying your hardsuit!"))
			return

/obj/item/gun/projectile/automatic/minigun/mounted/unload_ammo(mob/user, allow_dump=0)
	var/obj/item/rig/rig = get_rig()
	if (istype(rig))
		if (!rig.offline && rig.suit_is_deployed())
			user.visible_message(SPAN_NOTICE("\The [user] begins ejecting the magazine from \The [src]."), range = 4)
			do_after(user, 2 SECONDS, src, DO_PUBLIC_UNIQUE | DO_BAR_OVER_USER)
			..()
		else
			to_chat(user, SPAN_DANGER("You can't unload your minigun without deploying your hardsuit!"))
			return
