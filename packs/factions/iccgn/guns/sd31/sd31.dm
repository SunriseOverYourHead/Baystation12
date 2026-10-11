/obj/item/gun/projectile/automatic/z8/shotgun/sd31
	name = "SD31 automatic shotgun"
	desc = "The Amaranth Armorers SD31-D 'Jaguar' is an automatic shotgun in service with the Confederation Navy. It takes 12 gauge shells."
	icon = 'packs/factions/iccgn/guns/sd31/sd31.dmi'
	icon_state = "saiga"
	item_state = "saiga"
	item_icons = list(
		slot_r_hand_str = 'packs/factions/iccgn/guns/sd31/sd31.dmi',
		slot_l_hand_str = 'packs/factions/iccgn/guns/sd31/sd31.dmi',
		slot_back_str = 'packs/factions/iccgn/guns/sd31/sd31.dmi',
		slot_s_store_str = 'packs/factions/iccgn/guns/sd31/sd31.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "righthand",
		slot_l_hand_str = "lefthand",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	caliber = PROJECTILE_SHOTGUN
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	magazine_type = /obj/item/ammo_magazine/sd31
	allowed_magazines = /obj/item/ammo_magazine/sd31
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	magazine_state = null
	firemodes = list(
		list(
			"mode_name" = "2-round bursts",
			"burst" = 2,
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
			"fire_delay" = 0.5,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0, 2)
		)
	)

/obj/item/gun/projectile/automatic/z8/shotgun/sd31/on_update_icon()
	..()
	var/has_mag = !!ammo_magazine
	icon_state = has_mag ? "saiga_mag8" : "saiga"

	var/mob/living/M = loc
	if(istype(M))
		var/is_wielded = M.can_wield_item(src) && src.is_held_twohanded(M)
		if(is_wielded)
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_full_doble" : "lefthand_doble"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_full_doble" : "righthand_doble"
		else
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_full" : "lefthand"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_full" : "righthand"

	item_state_slots[slot_s_store_str] = has_mag ? "onsuit_full" : "onsuit"
	item_state_slots[slot_back_str] = "back"
