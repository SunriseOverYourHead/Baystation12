/obj/item/gun/projectile/shotgun/magshot
	name = "auto shotgun"
	desc = "A remnant of a bygone era, the NZ CSG-242 was formerly standard issue for Confederate Naval Forces for ship defense during hostile boarding actions. With a change in doctrine after the losses at Gaia, and with more focus on a multi-role weapons platform, the weapon is slowly being phased out of service."
	icon = 'code/modules/projectiles/guns/projectile/shotgun/magshot/magshot.dmi'
	icon_state = "magshot"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/shotgun/magshot/magshot.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/shotgun/magshot/magshot.dmi',
	)
	colocated_sprites = TRUE
	item_state = "magshot"
	wielded_item_state = "magshot-wielded"
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/shotgunmag
	allowed_magazines = /obj/item/ammo_magazine/shotgunmag
	w_class = ITEM_SIZE_HUGE
	force = 10
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	caliber = PROJECTILE_SHOTGUN
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 1)
	auto_eject = TRUE
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	one_hand_penalty = 8
	bulk = GUN_BULK_RIFLE
	burst_delay = 2
	accuracy = -1
	jam_chance = 0.5
	safety_icon = "safety"

	firemodes = list(
		list(
			"mode_name" = "semi-auto",
			"burst" = 1,
			"fire_delay" = 2,
			"move_delay" = 3,
			"one_hand_penalty" = 7,
			"burst_accuracy" = null,
			"dispersion" = list(1.5)
		),
		list(
			"mode_name" = "3 shell burst",
			"burst" = 3,
			"fire_delay" = 1.5,
			"move_delay" = 6,
			"one_hand_penalty" = 9,
			"burst_accuracy" = list(-1, -1, -2),
			"dispersion" = list(2, 2, 4)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = TRUE,
			"burst" = 1,
			"fire_delay" = 1,
			"move_delay" = 6,
			"one_hand_penalty" = 15,
			"burst_accuracy" = list(-1, -2, -2, -3, -3, -3, -4, -4),
			"dispersion" = list(2, 4, 4, 6, 6, 8)
		)
	)

/obj/item/gun/projectile/shotgun/magshot/on_update_icon()
	..()

	if(ammo_magazine)
		icon_state = initial(icon_state)
		wielded_item_state = initial(wielded_item_state)

		if(LAZYLEN(ammo_magazine.stored_ammo) == ammo_magazine.max_ammo)
			AddOverlays(image(icon, "ammo100"))
		else if(LAZYLEN(ammo_magazine.stored_ammo) <= 0.75 * ammo_magazine.max_ammo)
			AddOverlays(image(icon, "ammo75"))
		else if(LAZYLEN(ammo_magazine.stored_ammo) <= 0.5 * ammo_magazine.max_ammo)
			AddOverlays(image(icon, "ammo50"))
		else
			AddOverlays(image(icon, "ammo25"))

	else
		icon_state = "[initial(icon_state)]-empty"
		wielded_item_state = "[initial(wielded_item_state)]-empty"
