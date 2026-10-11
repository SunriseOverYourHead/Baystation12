/obj/item/gun/projectile/automatic
	name = "prototype SMG"
	desc = "A protoype lightweight, fast firing submachine gun chambered in a small caliber."
	icon = 'code/modules/projectiles/guns/projectile/automatic/prototype_smg/prototype_smg.dmi'
	icon_state = "prototype"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/prototype_smg/prototype_smg.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/prototype_smg/prototype_smg.dmi',
	)
	colocated_sprites = FALSE
	item_state = "saber"
	item_state_slots = list(
		slot_l_hand_str = "prototype_l",
		slot_r_hand_str = "prototype_r",
	)
	w_class = ITEM_SIZE_NORMAL
	bulk = -1
	load_method = MAGAZINE
	caliber = PROJECTILE_PISTOL_FLECHETTE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 3)
	slot_flags = SLOT_BELT
	ammo_type = /obj/item/ammo_casing/flechette
	magazine_type = /obj/item/ammo_magazine/proto_smg
	allowed_magazines = /obj/item/ammo_magazine/proto_smg
	multi_aim = 1
	burst_delay = 2
	mag_insert_sound = 'sound/weapons/guns/interaction/smg_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/smg_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot_4mm.ogg'

	//machine pistol, easier to one-hand with
	firemodes = list(
		list(
			"mode_name" = "semi auto",
			"burst" = 1,
			"fire_delay" = null,
			"move_delay" = null,
			"one_hand_penalty" = 0,
			"burst_accuracy" = null,
			"dispersion" = null
		),
		list(
			"mode_name" = "4-round bursts",
			"burst" = 4,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 1,
			"burst_accuracy" = list(0, 0, -1, -1),
			"dispersion" = list(0.0, 0.0, 0.5, 0.6)
		),
		list(
			"mode_name" = "long bursts",
			"burst" = 8,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 2,
			"burst_accuracy" = list(0, 0, -1, -1, -1, -1, -2, -2),
			"dispersion" = list(0.0, 0.0, 0.5, 0.6, 0.8, 1.0, 1.0, 1.2)
		)
	)
