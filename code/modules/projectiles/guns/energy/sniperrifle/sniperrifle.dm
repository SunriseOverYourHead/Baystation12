/obj/item/gun/energy/sniperrifle
	name = "marksman energy rifle"
	desc = "The HI DMR 9E is an older design of Hephaestus Industries. A designated marksman rifle capable of shooting powerful ionized beams, this is a weapon to kill from a distance."
	icon = 'code/modules/projectiles/guns/energy/sniperrifle/sniperrifle.dmi'
	icon_state = "sniper"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/sniperrifle/sniperrifle.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/sniperrifle/sniperrifle.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/sniperrifle/sniperrifle.dmi',
	)
	colocated_sprites = TRUE
	item_state = "laser"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 5, TECH_POWER = 4)
	projectile_type = /obj/item/projectile/beam/sniper
	one_hand_penalty = 8 // The weapon itself is heavy, and the long barrel makes it hard to hold steady with just one hand.
	slot_flags = SLOT_BACK
	charge_cost = 40
	max_shots = 8
	fire_delay = 30
	force = 10
	w_class = ITEM_SIZE_HUGE
	accuracy = -4 //shooting at the hip
	scoped_accuracy = 9
	scope_zoom = 2
	wielded_item_state = "gun_wielded"

/obj/item/gun/energy/sniperrifle/on_update_icon()
	..()
	item_state_slots[slot_back_str] = "[icon_state]_back"
