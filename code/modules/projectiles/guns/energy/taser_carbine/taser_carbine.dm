/obj/item/gun/energy/taser/carbine
	name = "electrolaser carbine"
	desc = "The NT Mk44 NL is a high capacity gun used for non-lethal takedowns. It can switch between high and low intensity stun shots."
	icon = 'code/modules/projectiles/guns/energy/taser_carbine/taser_carbine.dmi'
	icon_state = "tasercarbine"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/taser_carbine/taser_carbine.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/taser_carbine/taser_carbine.dmi',
	)
	colocated_sprites = TRUE
	w_class = ITEM_SIZE_LARGE
	slot_flags = SLOT_BELT|SLOT_BACK
	one_hand_penalty = 3
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	force = 8
	max_shots = 12
	accuracy = 1
	projectile_type = /obj/item/projectile/beam/stun/heavy
	wielded_item_state = "tasercarbine-wielded"

	firemodes = list(
		list(
			"mode_name" = "stun",
			"projectile_type" = /obj/item/projectile/beam/stun/heavy
		),
		list(
			"mode_name" = "shock",
			"projectile_type" = /obj/item/projectile/beam/stun/shock/heavy
		)
	)
