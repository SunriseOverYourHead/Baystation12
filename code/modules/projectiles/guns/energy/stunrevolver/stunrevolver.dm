/obj/item/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "An A&M X6 Zeus. Designed by al-Maliki & Mosley, but produced under the wing of the Free Trade Union. Industry spies have been trying to get a hold of the blueprints for half a decade."
	icon = 'code/modules/projectiles/guns/energy/stunrevolver/stunrevolver.dmi'
	icon_state = "stunrevolver"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/stunrevolver/stunrevolver.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/stunrevolver/stunrevolver.dmi',
	)
	colocated_sprites = TRUE
	item_state = "stunrevolver"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_POWER = 2)
	projectile_type = /obj/item/projectile/energy/electrode
	max_shots = 6
	combustion = 0

/obj/item/gun/energy/stunrevolver/rifle
	name = "stun rifle"
	desc = "An A&M X10 Thor. A vastly oversized variant of the A&M X6 Zeus. Fires overcharged electrodes to obliterate pain receptors without harming them too much."
	icon = 'code/modules/projectiles/guns/energy/stunrevolver/stunrifle.dmi'
	icon_state = "stunrifle"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/stunrevolver/stunrifle.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/stunrevolver/stunrifle.dmi',
	)
	colocated_sprites = TRUE
	item_state = "stunrifle"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	one_hand_penalty = 6
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	force = 10
	max_shots = 10
	accuracy = 1
	projectile_type = /obj/item/projectile/energy/electrode/stunshot
	wielded_item_state = "stunrifle-wielded"
