/obj/item/gun/projectile/pistol/m22f
	name = "M22 military pistol"
	desc = "A Hephaestus Industries M22F. A 10mm pistol issued as an SCG service weapon."
	caliber = PROJECTILE_PISTOL_BIG
	ammo_type = /obj/item/ammo_casing/pistol/big
	magazine_type = /obj/item/ammo_magazine/m22f
	allowed_magazines = /obj/item/ammo_magazine/m22f
	icon = 'code/modules/projectiles/guns/projectile/pistol/m22f/m22f.dmi'
	icon_state = "m22f"
	item_state = "m22f"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 2)
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/pistol/m22f/m22f.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/pistol/m22f/m22f.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "m22f-wielded-r",
		slot_l_hand_str = "m22f-wielded-l"
	)
	fire_delay = 3
	empty_icon = TRUE
	ammo_indicator = FALSE

/obj/item/gun/projectile/pistol/m22f/empty
	starts_loaded = FALSE

/obj/item/gun/projectile/pistol/m22f/icarus
	name = "rusty military pistol"
	desc = "A Hephaestus Industries M22F. A large pistol issued as an SCGDF service weapon. This one has seen better days, and has the name \"Alex\" engraved into it."
