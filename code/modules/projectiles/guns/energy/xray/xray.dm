/obj/item/gun/energy/xray
	name = "x-ray laser carbine"
	desc = "A high-power laser gun capable of emitting concentrated x-ray blasts, that are able to penetrate laser-resistant armor much more readily than standard photonic beams."
	icon = 'code/modules/projectiles/guns/energy/xray/xray.dmi'
	icon_state = "xray"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/xray/xray.dmi',
	)
	colocated_sprites = FALSE
	item_state = "xray"
	item_state_slots = list(
		slot_l_hand_str = "xray",
		slot_r_hand_str = "xray",
	)
	slot_flags = SLOT_BELT|SLOT_BACK
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 3, TECH_MAGNET = 2, TECH_ESOTERIC = 2)
	projectile_type = /obj/item/projectile/beam/xray/midlaser
	one_hand_penalty = 2
	w_class = ITEM_SIZE_LARGE
	charge_cost = 15
	max_shots = 10
	combustion = 0

/obj/item/gun/energy/xray/pistol
	name = "x-ray laser gun"
	icon = 'code/modules/projectiles/guns/energy/xray/xray_pistol.dmi'
	icon_state = "oldxray"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
	)
	item_state_slots = list(
		slot_l_hand_str = "xray",
		slot_r_hand_str = "xray",
	)
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_MAGNET = 2, TECH_ESOTERIC = 2)
	projectile_type = /obj/item/projectile/beam/xray
	one_hand_penalty = 1
	w_class = ITEM_SIZE_NORMAL
	fire_delay = 10
