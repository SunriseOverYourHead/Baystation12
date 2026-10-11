/obj/item/gun/projectile/heavysniper/z12
	name = "Z12-A anti-materiel rifle"
	desc = "The Hephaestus Industries Z12-A 'Coyote' is an anti-materiel rifle in service with the SCG. It takes the 11.6x101mm cartridge."
	icon = 'code/modules/projectiles/guns/projectile/sniper/heavysniper/z12/z12.dmi'
	icon_state = "z12a"
	item_state = "z12a"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/sniper/heavysniper/z12/z12.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/sniper/heavysniper/z12/z12.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/sniper/heavysniper/z12/z12.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/sniper/heavysniper/z12/z12.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z12a-wielded-r",
		slot_l_hand_str = "z12a-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
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
