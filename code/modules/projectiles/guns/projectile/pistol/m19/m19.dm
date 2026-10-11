/obj/item/gun/projectile/pistol/m19
	name = "M19 military pistol"
	desc = "A Hephaestus Industries M19. A 9mm pistol issued as an SCG service weapon."
	magazine_type = /obj/item/ammo_magazine/m19
	allowed_magazines = /obj/item/ammo_magazine/m19
	icon = 'code/modules/projectiles/guns/projectile/pistol/m19/m19.dmi'
	icon_state = "m19"
	item_state = "m19"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/pistol/m19/m19.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/pistol/m19/m19.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "m19-wielded-r",
		slot_l_hand_str = "m19-wielded-l"
	)
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	empty_icon = TRUE
	fire_delay = 2

/obj/item/gun/projectile/pistol/m19/empty
	starts_loaded = FALSE
