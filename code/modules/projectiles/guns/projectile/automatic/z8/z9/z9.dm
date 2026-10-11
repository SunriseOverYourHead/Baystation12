/obj/item/gun/projectile/automatic/z8/z9
	name = "Z9-C bullpup carbine"
	desc = "The standard-issue rifle of the SCG. The Hephaestus Industries Z9-C 'Pitbull' is the modern answer to violence's question. It has been given a blued finish with a Sol yellow stripe for easy identification of its owner."
	icon = 'code/modules/projectiles/guns/projectile/automatic/z8/z9/z9.dmi'
	icon_state = "z9c"
	item_state = "z9c"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9/z9.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9/z9.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9/z9.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9/z9.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z9c-wielded-r",
		slot_l_hand_str = "z9c-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag35"
	magazine_type = /obj/item/ammo_magazine/z9
	allowed_magazines = /obj/item/ammo_magazine/z9
	burst_delay = 1.5
	one_hand_penalty = 6
	bulk = GUN_BULK_LIGHT_RIFLE
	has_launcher = FALSE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
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
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)
