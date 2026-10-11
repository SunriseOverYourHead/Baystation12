/obj/item/gun/projectile/automatic/machine_pistol
	name = "machine pistol"
	desc = "The Hephaestus Industries MP6 Vesper, A fairly common machine pistol based off a mid 20th century design. Sometimes refered to as an 'uzi' by the backwater spacers it is often associated with."
	icon = 'code/modules/projectiles/guns/projectile/automatic/machine_pistol/machine_pistol.dmi'
	icon_state = "mpistolen"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/machine_pistol/machine_pistol.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/machine_pistol/machine_pistol.dmi',
	)
	colocated_sprites = TRUE
	safety_icon = "safety"
	item_state = "mpistolen"
	load_method = MAGAZINE
	caliber = PROJECTILE_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 3)
	ammo_type = /obj/item/ammo_casing/pistol
	magazine_type = /obj/item/ammo_magazine/machine_pistol
	allowed_magazines = /obj/item/ammo_magazine/machine_pistol //more damage compared to the wt550, smaller mag size
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	one_hand_penalty = 2

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
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 1,
			"burst_accuracy" = list(0, -1, -1),
			"dispersion" = list(0.0, 0.6, 1.0)
		),
		list(
			"mode_name" = "short bursts",
			"burst" = 5,
			"fire_delay" = null,
			"move_delay" = 4,
			"one_hand_penalty" = 2,
			"burst_accuracy" = list(0, -1, -1, -1, -2),
			"dispersion" = list(0.6, 0.6, 1.0, 1.0, 1.2)
		)
	)

/obj/item/gun/projectile/automatic/machine_pistol/on_update_icon()
	..()
	icon_state = "mpistolen"
	if(ammo_magazine)
		AddOverlays(image(icon, "mag"))

	if(!ammo_magazine || !LAZYLEN(ammo_magazine.stored_ammo))
		icon_state = "mpistolen-empty"
		AddOverlays(image(icon, "[initial(icon_state)]-ammo0"))
	else if(LAZYLEN(ammo_magazine.stored_ammo) <= 0.5 * ammo_magazine.max_ammo)
		AddOverlays(image(icon, "[initial(icon_state)]-ammo1"))
	else
		AddOverlays(image(icon, "[initial(icon_state)]-ammo2"))
