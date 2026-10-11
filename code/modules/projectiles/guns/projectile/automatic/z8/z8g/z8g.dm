/obj/item/gun/projectile/automatic/z8/shotgun
	name = "Z8-G automatic shotgun"
	desc = "The Hephaestus Industries Z8-G 'Fenrir' is a bullpup, automatic shotgun utilizing the Z8 platform in service with the SCG. It takes 12 gauge shells."
	icon = 'code/modules/projectiles/guns/projectile/automatic/z8/z8g/z8g.dmi'
	icon_state = "z8g"
	item_state = "z8g"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8g/z8g.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8g/z8g.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8g/z8g.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8g/z8g.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z8g-wielded-r",
		slot_l_hand_str = "z8g-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag12"
	caliber = PROJECTILE_SHOTGUN
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	magazine_type = /obj/item/ammo_magazine/z8g
	allowed_magazines = /obj/item/ammo_magazine/z8g
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	wielded_item_state = "z10ar-wielded"
	firemodes = list(
		list(
			"mode_name" = "2-round bursts",
			"burst" = 2,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.5,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)
