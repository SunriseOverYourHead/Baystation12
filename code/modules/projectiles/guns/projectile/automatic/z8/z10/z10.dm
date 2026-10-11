/obj/item/gun/projectile/automatic/z8/z10
	name = "Z10-A 'Rottweiler' assault rifle"
	desc = "The Hephaestus Industries Z10-A 'Rottweiler' is an assault rifle in service with the SCG. Chambered in 8.6x43mm cartridges, it's an alternative firearm offered to riflemen of the SCG defense forces."
	icon = 'code/modules/projectiles/guns/projectile/automatic/z8/z10/z10.dmi'
	icon_state = "z10a"
	item_state = "z10a"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z10/z10.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z10/z10.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z10/z10.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z10/z10.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z10a-wielded-r",
		slot_l_hand_str = "z10a-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag20"
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_BIG
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/big
	magazine_type = /obj/item/ammo_magazine/z10
	allowed_magazines = /obj/item/ammo_magazine/z10
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
