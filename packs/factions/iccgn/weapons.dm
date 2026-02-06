/*

ICCG Weapons

*/


/*
 ###    Pistols    ###
*/

/obj/item/gun/projectile/pistol/p225
	name = "P225 military pistol"
	desc = "A Novaya Zemlya P225 Optimus. A .44 pistol best known as one of the Confederation Navy's service weapons."
	icon = 'packs/factions/iccgn/weapons.dmi'
	caliber = PROJECTILE_PISTOL_HUGE
	icon_state = "optimus"
	item_state = "secgundark"
	safety_icon = "optimus-safety"
	magazine_type = /obj/item/ammo_magazine/pistol/double
	allowed_magazines = /obj/item/ammo_magazine/pistol/double
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2, TECH_ESOTERIC = 4)
	ammo_indicator = TRUE
	fire_delay = 8


/obj/item/gun/projectile/pistol/p87
	name = "P87 military pistol"
	desc = "An Amaranth Armorers P87 Bobcat. A 10mm pistol issued as a Confederation Navy service weapon."
	icon = 'packs/factions/iccgn/weapons.dmi'
	w_class = ITEM_SIZE_SMALL
	caliber = PROJECTILE_PISTOL_BIG
	icon_state = "bobcat"
	item_state = "secgundark"
	safety_icon = "bobcat-safety"
	magazine_type = /obj/item/ammo_magazine/pistol
	allowed_magazines = /obj/item/ammo_magazine/pistol
	banned_magazines = list(
		/obj/item/ammo_magazine/pistol/double,
		/obj/item/ammo_magazine/pistol/small
	)
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_ESOTERIC = 4)
	fire_delay = 4

/obj/item/gun/projectile/revolver/p20
	name = "P20 military handcannon"
	desc = "A Novaya Zemlya Arms P20 Triumph. A massive revolver chambered in 20mm shells. Occasionally seen in service by the Confederation Naval Infantry"
	icon = 'packs/factions/iccgn/weapons.dmi'
	w_class = ITEM_SIZE_SMALL
	caliber = PROJECTILE_PISTOL_CANNON
	icon_state = "bobcat"
	item_state = "secgundark"
	safety_icon = "bobcat-safety"
	max_shells = 3
	magazine_type = /obj/item/ammo_magazine/pistol
	allowed_magazines = /obj/item/ammo_magazine/pistol
	banned_magazines = list(
		/obj/item/ammo_magazine/pistol/double,
		/obj/item/ammo_magazine/pistol/small
	)
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_ESOTERIC = 4)
	fire_delay = 4

/*
 ###    SMGs    ###
*/

/obj/item/gun/projectile/automatic/pp72
	name = "PP72 submachinegun"
	desc = "The Novaya Zemlya Arms PP72 submachinegun. Mostly relegated to support personnel in the Confederation Navy and Naval Infantry."
	icon = 'icons/obj/guns/machine_pistol.dmi'
	icon_state = "mpistolen"
	safety_icon = "safety"
	item_state = "mpistolen"
	caliber = PROJECTILE_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 3)
	burst_delay = 0.5
	ammo_type = /obj/item/ammo_casing/pistol
	magazine_type = /obj/item/ammo_magazine/machine_pistol
	allowed_magazines = /obj/item/ammo_magazine/machine_pistol
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	one_hand_penalty = 2

	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = 0.2,
			"move_delay" = 0.5,
			"use_launcher" = null,
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

/*
 ###    Intermed. Rifles   ###
*/


/obj/item/gun/projectile/automatic/z8/sd11
	name = "SD11-D assault rifle"
	desc = "The standard-issue rifle of the ICCG. The Novaya Zemlya Arms SD11-D 'Boltcutter' is a nimble, lightweight rifle in use by the Confederation Naval Infantry."
	icon = 'maps/torch/icons/obj/weapons.dmi'
	icon_state = "sd11ak"
	item_state = "sd11ak"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 6 //Slightly lighter than the Z8. Still don't try it.
	bulk = GUN_BULK_LIGHT_RIFLE
	has_launcher = FALSE
	wielded_item_state = "sd11ak-wielded"
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/obj/item/gun/projectile/automatic/z8/sd22
	name = "SD22-A assault rifle"
	desc = "The Novaya Zemlya Arms SD22-A 'Torch' is an internally-suppressed assault rifle in use by the Confederation Navy."
	icon = 'maps/torch/icons/obj/weapons.dmi'
	icon_state = "sd22ar"
	item_state = "sd22ar"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	wielded_item_state = "sd22ar-wielded"
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/*
 ###    Full Rifles   ###
*/

/obj/item/gun/projectile/sniper/sd24 //semi-automatic only
	name = "SD24-C marksman rifle"
	desc = "An SD24-C 'Panther'. It is a simple and durable rifle made of stamped steel manufactured by Novaya Zemlya Arms for the Confederation Navy. \
	While it lacks the burst fire of other military rifles, it's exceptionally accurate and has a powerful optic."
	icon = 'icons/obj/guns/terran_rifle.dmi'
	icon_state = "dmr"
	item_state = "dmr"
	fire_delay = 8
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 4, TECH_ESOTERIC = 5)
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	one_hand_penalty = 8
	scoped_accuracy = 8
	scope_zoom = 1
	accuracy_power = 8
	accuracy = 4
	bulk = GUN_BULK_RIFLE
	wielded_item_state = "dmr-wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'

/obj/item/gun/projectile/sniper/sd24/on_update_icon()
	if(ammo_magazine)
		icon_state = "dmr"
	else
		icon_state = "dmr-empty"
	..()

/obj/item/gun/projectile/automatic/z8/sd25
	name = "SD25-B squad automatic weapon"
	desc = "A Amaranth Armorers SD25-B 'Grizzly' machine gun. Excels at long, continuous fire. In service with the Confederation Naval Infantry."
	icon = 'maps/torch/icons/obj/weapons.dmi'
	icon_state = "sd22ar"
	item_state = "sd22ar"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	wielded_item_state = "sd22ar-wielded"
	firemodes = list(
	list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/obj/item/gun/projectile/sniper/sd55 //semi-automatic only
	name = "SD55-B anti-materiel rifle"
	desc = "A Novaya Zemlya Arms SD55-B 'Caracal'. A hulking anti-materiel rifle chambered in 10.5x99mm. In service with the Confederation Navy."
	icon = 'icons/obj/guns/terran_rifle.dmi'
	icon_state = "dmr"
	item_state = "dmr"
	fire_delay = 8
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 4, TECH_ESOTERIC = 5)
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	one_hand_penalty = 8
	scoped_accuracy = 8
	scope_zoom = 1
	accuracy_power = 8
	accuracy = 4
	bulk = GUN_BULK_RIFLE
	wielded_item_state = "dmr-wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'

/obj/item/gun/projectile/sniper/sd24/on_update_icon()
	if(ammo_magazine)
		icon_state = "dmr"
	else
		icon_state = "dmr-empty"
	..()

/*
 ###    Shotguns    ###
*/

/obj/item/gun/projectile/automatic/z8/shotgun/sd31
	name = "SD31 automatic shotgun"
	desc = "The Amaranth Armorers SD31-D 'Jaguar' is an automatic shotgun in service with the Confederation Navy. It takes 12 gauge shells."
	icon = 'maps/torch/icons/obj/weapons.dmi'
	icon_state = "z11rifle"
	item_state = "z11rifle"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	wielded_item_state = "z10ar-wielded"
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)
