/obj/item/gun/projectile/pistol/m25
	name = "M25 military pistol"
	desc = "A Hephaestus Industries M25. A hulking, formidable pistol chambered in .50 AE. Undergoing limited field testing as a replacement for the older M19 and M22 pistols."
	magazine_type = /obj/item/ammo_magazine/m25
	allowed_magazines = /obj/item/ammo_magazine/m25
	icon = 'code/modules/projectiles/guns/projectile/pistol/m25/m25.dmi'
	icon_state = "m25"
	item_state = "m25"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/pistol/m25/m25.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/pistol/m25/m25.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "m25-wielded-r",
		slot_l_hand_str = "m25-wielded-l"
	)
	caliber = PROJECTILE_PISTOL_MASSIVE
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	empty_icon = TRUE
	fire_delay = 4

/obj/item/gun/projectile/pistol/m25/empty
	starts_loaded = FALSE
