/obj/item/gun/projectile/automatic/z8/d
	name = "Z8-D marksman rifle"
	desc = "The Hephaestus Industries Z8-D 'Barghest' is a bullpup marksman rifle in service with the SCG. It takes the longer 6.5x59mm cartridge."
	icon = 'code/modules/projectiles/guns/projectile/automatic/z8/z8d/z8d.dmi'
	icon_state = "z8dmr"
	item_state = "z8dmr"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8d/z8d.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8d/z8d.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8d/z8d.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8d/z8d.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z8dmr-wielded-r",
		slot_l_hand_str = "z8dmr-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag20"
	caliber = PROJECTILE_RIFLE_FULL_SMALL
	ammo_type = /obj/item/ammo_casing/rifle/full/small
	magazine_type = /obj/item/ammo_magazine/z8d
	allowed_magazines = /obj/item/ammo_magazine/z8d
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
