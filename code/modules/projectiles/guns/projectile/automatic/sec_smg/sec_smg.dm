/obj/item/gun/projectile/automatic/sec_smg
	name = "submachine gun"
	desc = "The WT-550 Saber is a cheap self-defense weapon, mass-produced by Ward-Takahashi for paramilitary and private use."
	icon = 'code/modules/projectiles/guns/projectile/automatic/sec_smg/sec_smg.dmi'
	icon_state = "smg"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/sec_smg/sec_smg.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/sec_smg/sec_smg.dmi',
	)
	colocated_sprites = TRUE
	item_state = "wt550"
	safety_icon = "safety"
	w_class = ITEM_SIZE_NORMAL
	caliber = PROJECTILE_PISTOL_SMALL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/smg_top
	allowed_magazines = /obj/item/ammo_magazine/smg_top
	accuracy_power = 7
	one_hand_penalty = 3
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	barrel_thread = TRUE
	silencer_offset = 6

	//machine pistol, like SMG but easier to one-hand with
	firemodes = list(
		list(
			"mode_name" = "semi auto",
			"burst" = 1,
			"fire_delay" = null,
			"move_delay" = null,
			"one_hand_penalty" = 3,
			"burst_accuracy" = null,
			"dispersion" = null
		),
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 4,
			"burst_accuracy" = list(0, -1, -1),
			"dispersion" = list(0.0, 0.6, 1.0)
		),
		list(
			"mode_name" = "short bursts",
			"burst" = 5,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 5,
			"burst_accuracy" = list(0, -1, -1, -1, -2),
			"dispersion" = list(0.6, 0.6, 1.0, 1.0, 1.2)
		)
	)

/obj/item/gun/projectile/automatic/sec_smg/on_update_icon()
	..()
	if(ammo_magazine)
		AddOverlays(image(icon, "mag-[round(length(ammo_magazine.stored_ammo),5)]"))
	if(ammo_magazine && LAZYLEN(ammo_magazine.stored_ammo))
		AddOverlays(image(icon, "ammo-ok"))
	else
		AddOverlays(image(icon, "ammo-bad"))

/obj/item/gun/projectile/automatic/sec_smg/empty
	starts_loaded = FALSE
