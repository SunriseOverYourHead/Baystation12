/obj/item/gun/projectile/automatic/merc_smg
	name = "submachine gun"
	desc = "The Novaya Zemlya Arms C-20r is a lightweight and rapid firing SMG. In production since the 2280s, the C-20r has proliferated across human space, in some part due to it being issued to smaller ICCGN vessels."
	icon = 'code/modules/projectiles/guns/projectile/automatic/merc_smg/merc_smg.dmi'
	icon_state = "c20r"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/merc_smg/merc_smg.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/merc_smg/merc_smg.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/merc_smg/merc_smg.dmi',
	)
	colocated_sprites = TRUE
	item_state = "c20r"
	safety_icon = "safety"
	w_class = ITEM_SIZE_LARGE
	force = 10
	load_method = MAGAZINE
	ammo_type = /obj/item/ammo_casing/pistol
	caliber = PROJECTILE_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 8)
	slot_flags = SLOT_BELT|SLOT_BACK
	magazine_type = /obj/item/ammo_magazine/smg
	allowed_magazines = /obj/item/ammo_magazine/smg
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	bulk = -1
	accuracy = 1
	one_hand_penalty = 4

	//SMG
	firemodes = list(
		list(
			"mode_name" = "semi auto",
			"burst" = 1,
			"fire_delay" = null,
			"move_delay" = null,
			"one_hand_penalty" = 4,
			"burst_accuracy" = null,
			"dispersion" = null
		),
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 5,
			"burst_accuracy" = list(0, -1, -1),
			"dispersion" = list(0.0, 0.6, 1.0)
		),
		list(
			"mode_name" = "short bursts",
			"burst" = 5,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 6,
			"burst_accuracy" = list(0, -1, -1, -1, -2),
			"dispersion" = list(0.6, 0.6, 1.0, 1.0, 1.2)
		)
	)

/obj/item/gun/projectile/automatic/merc_smg/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "c20r-[round(length(ammo_magazine.stored_ammo),4)]"
	else
		icon_state = "c20r"
