/obj/item/gun/projectile/automatic/mp85
	name = "MP85 PDW"
	desc = "The Ward-Takahashi MP85 'Ghost' personal defense weapon. Recently adopted by the SCG for support personnel."
	icon = 'code/modules/projectiles/guns/projectile/automatic/mp85/mp85.dmi'
	icon_state = "mp85"
	item_state = "mp85"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/mp85/mp85.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/mp85/mp85.dmi',
	)
	colocated_sprites = FALSE
	item_state_slots = list(
		slot_r_hand_str = "mp85",
		slot_l_hand_str = "mp85"
	)
	empty_icon = TRUE
	load_method = MAGAZINE
	caliber = PROJECTILE_PISTOL_SMALL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 3)
	burst_delay = 0.5
	ammo_type = /obj/item/ammo_casing/pistol/small
	magazine_type = /obj/item/ammo_magazine/mp85
	allowed_magazines = /obj/item/ammo_magazine/mp85
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	one_hand_penalty = 2

	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = 0.2,
			"move_delay" = 0.5,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0),
			"dispersion" = list(0.0, 0.1)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.1,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, 0, -0.5, -0.5, -1),
			"dispersion" = list(0, 0, 0, 0.1)
		),
	)

/obj/item/gun/projectile/automatic/mp85/on_update_icon()
	..()
	if(empty_icon)
		if(ammo_magazine && length(ammo_magazine.stored_ammo))
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)]-e"
