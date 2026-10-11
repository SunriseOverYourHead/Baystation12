/obj/item/gun/projectile/automatic/z8/sd22
	name = "SD22-A assault rifle"
	desc = "The Novaya Zemlya Arms SD22-A 'Torch' is an internally-suppressed assault rifle in use by the Confederation Navy."
	icon = 'packs/factions/iccgn/guns/sd22/sd22.dmi'
	icon_state = "vintorez"
	item_state = "vintorez"
	item_icons = list(
		slot_r_hand_str = 'packs/factions/iccgn/guns/sd22/sd22.dmi',
		slot_l_hand_str = 'packs/factions/iccgn/guns/sd22/sd22.dmi',
		slot_back_str = 'packs/factions/iccgn/guns/sd22/sd22.dmi',
		slot_s_store_str = 'packs/factions/iccgn/guns/sd22/sd22.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "righthand",
		slot_l_hand_str = "lefthand",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_MASSIVE
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/massive
	magazine_type = /obj/item/ammo_magazine/sd22
	allowed_magazines = /obj/item/ammo_magazine/sd22
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
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

/obj/item/gun/projectile/automatic/z8/sd22/on_update_icon()
	..()
	var/has_mag = !!ammo_magazine
	var/is_empty = !ammo_magazine || !length(ammo_magazine.stored_ammo)
	icon_state = has_mag ? (is_empty ? "vintorez_mag20_slide" : "vintorez_mag20") : "vintorez_slide"
	var/mob/living/M = loc
	if(istype(M))
		var/is_wielded = M.can_wield_item(src) && src.is_held_twohanded(M)
		if(is_wielded)
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_doble_mag" : "lefthand_doble"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_doble_mag" : "righthand_doble"
		else
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_mag" : "lefthand"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_mag" : "righthand"
