/obj/item/gun/projectile/automatic/z8/sd11
	name = "SD11-D assault rifle"
	desc = "The standard-issue rifle of the ICCG. The Novaya Zemlya Arms SD11-D 'Boltcutter' is a nimble, lightweight rifle in use by the Confederation Naval Infantry."
	icon = 'packs/factions/iccgn/guns/sd11/sd11.dmi'
	icon_state = "pitbull"
	item_state = "pitbull"
	item_icons = list(
		slot_r_hand_str = 'packs/factions/iccgn/guns/sd11/sd11.dmi',
		slot_l_hand_str = 'packs/factions/iccgn/guns/sd11/sd11.dmi',
		slot_back_str = 'packs/factions/iccgn/guns/sd11/sd11.dmi',
		slot_s_store_str = 'packs/factions/iccgn/guns/sd11/sd11.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "righthand",
		slot_l_hand_str = "lefthand",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/small
	magazine_type = /obj/item/ammo_magazine/sd11
	allowed_magazines = /obj/item/ammo_magazine/sd11
	burst_delay = 1.5
	one_hand_penalty = 6
	bulk = GUN_BULK_LIGHT_RIFLE
	has_launcher = FALSE
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
			"dispersion" = list(0, 0, 0, 0, 2)
		)
	)

/obj/item/gun/projectile/automatic/z8/sd11/on_update_icon()
	..()
	var/has_mag = !!ammo_magazine
	var/is_empty = !ammo_magazine || !length(ammo_magazine.stored_ammo)
	icon_state = has_mag ? (is_empty ? "pitbull_mag20_slide" : "pitbull_mag20") : "pitbull_slide"
	var/mob/living/M = loc
	if(istype(M))
		var/is_wielded = M.can_wield_item(src) && src.is_held_twohanded(M)
		if(is_wielded)
			item_state_slots[slot_l_hand_str] = "lefthand_doble"
			item_state_slots[slot_r_hand_str] = "righthand_doble"
		else
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_mag" : "lefthand"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_mag" : "righthand"
