/obj/item/gun/projectile/revolver/m55
	name = "M55 military revolver"
	desc = "The Hephaestus Industries M55. A hard-hitting .44 revolver issued as an SCG service weapon."
	caliber = PROJECTILE_PISTOL_HUGE
	ammo_type = /obj/item/ammo_casing/pistol/huge
	icon = 'code/modules/projectiles/guns/projectile/revolver/m55/m55.dmi'
	icon_state = "m55"
	item_state = "m55"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/revolver/m55/m55.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/revolver/m55/m55.dmi',
	)
	colocated_sprites = FALSE
	item_state_slots = list(
		slot_r_hand_str = "m55-wielded-r",
		slot_l_hand_str = "m55-wielded-l"
	)
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	accuracy = 1
	bulk = 0
	fire_delay = 3

/obj/item/gun/projectile/revolver/m55/empty
	starts_loaded = FALSE
