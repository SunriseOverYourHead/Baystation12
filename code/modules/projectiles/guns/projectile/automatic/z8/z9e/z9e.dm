/obj/item/gun/projectile/automatic/z8/z9e
	name = "Z9-E SOCOM bullpup rifle"
	desc = "The Hephaestus Industries Z9-E SOCOM is a conversion of the Z9-C 'Pitbull'. It uses a modified upper receiver which allows it to take the formidable 11.6x57mm cartridge."
	icon = 'code/modules/projectiles/guns/projectile/automatic/z8/z9e/z9e.dmi'
	icon_state = "z9e"
	item_state = "z9e"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9e/z9e.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9e/z9e.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9e/z9e.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z9e/z9e.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z9e-wielded-r",
		slot_l_hand_str = "z9e-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag15"
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_HUGE
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/huge
	magazine_type = /obj/item/ammo_magazine/z9e
	allowed_magazines = /obj/item/ammo_magazine/z9e
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
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
