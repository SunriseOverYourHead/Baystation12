/obj/item/gun/projectile/automatic/assault_rifle
	name = "assault rifle"
	desc = "The rugged STS-35 is a durable automatic weapon of a make popular on the frontier worlds. Originally designed in the mid 20th century, today variants are made by most firearm producers. This one appears to be HI made, with the serial number conveniently absent."
	icon = 'code/modules/projectiles/guns/projectile/automatic/assault_rifle/assault_rifle.dmi'
	icon_state = "arifle"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/assault_rifle/assault_rifle.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/assault_rifle/assault_rifle.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/assault_rifle/assault_rifle.dmi',
	)
	colocated_sprites = TRUE
	item_state = null
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_BIG
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/big/antique
	magazine_type = /obj/item/ammo_magazine/rifle
	one_hand_penalty = 8
	allowed_magazines = /obj/item/ammo_magazine/rifle
	accuracy_power = 7
	accuracy = 2
	bulk = GUN_BULK_HEAVY_RIFLE
	wielded_item_state = "arifle-wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'

	//Assault rifle, burst fire degrades quicker than SMG, worse one-handing penalty, slightly increased move delay
	firemodes = list(
		list(
			"mode_name" = "semi auto",
			"burst" = 1,
			"fire_delay" = null,
			"move_delay" = null,
			"one_hand_penalty" = 8,
			"burst_accuracy" = null,
			"dispersion" = null
		),
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"move_delay" = 6,
			"one_hand_penalty" = 9,
			"burst_accuracy" = list(0, -1, -1),
			"dispersion" = list(0.0, 0.6, 1.0)
		),
		list(
			"mode_name" = "short bursts",
			"burst" = 5,
			"fire_delay" = null,
			"move_delay" = 6,
			"one_hand_penalty" = 11,
			"burst_accuracy" = list(0, -1, -2, -3, -3),
			"dispersion" = list(0.6, 1.0, 1.2, 1.2, 1.5)
		)
	)

/obj/item/gun/projectile/automatic/assault_rifle/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "arifle"
		wielded_item_state = "arifle-wielded"
	else
		icon_state = "arifle-empty"
		wielded_item_state = "arifle-wielded-empty"
