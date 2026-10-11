/obj/item/gun/projectile/revolver/p20
	name = "P20 military handcannon"
	desc = "A Novaya Zemlya Arms P20 Triumph. A massive revolver chambered in 20mm shells. Occasionally seen in service by the Confederation Naval Infantry."
	icon = 'packs/factions/iccgn/guns/p20/p20.dmi'
	icon_state = "hornet"
	item_icons = list(
		slot_l_hand_str = 'packs/factions/iccgn/guns/p20/p20.dmi',
		slot_r_hand_str = 'packs/factions/iccgn/guns/p20/p20.dmi',
	)
	item_state_slots = list(
		slot_l_hand_str = "lefthand",
		slot_r_hand_str = "righthand",
	)
	colocated_sprites = FALSE
	w_class = ITEM_SIZE_LARGE
	caliber = PROJECTILE_PISTOL_CANNON
	ammo_type = /obj/item/ammo_casing/pistol/cannon
	max_shells = 3
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_ESOTERIC = 4)
	fire_delay = 4
