/obj/item/gun/projectile/automatic/z8/sd25
	name = "SD25-B squad automatic weapon"
	desc = "A Amaranth Armorers SD25-B 'Grizzly' machine gun. Excels at long, continuous fire. In service with the Confederation Naval Infantry."
	icon = 'packs/factions/iccgn/guns/sd25/sd25.dmi'
	icon_state = "pk"
	item_state = "pk"
	item_icons = list(
		slot_r_hand_str = 'packs/factions/iccgn/guns/sd25/sd25.dmi',
		slot_l_hand_str = 'packs/factions/iccgn/guns/sd25/sd25.dmi',
		slot_back_str = 'packs/factions/iccgn/guns/sd25/sd25.dmi',
		slot_s_store_str = 'packs/factions/iccgn/guns/sd25/sd25.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "righthand",
		slot_l_hand_str = "lefthand",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag100"
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/small
	magazine_type = /obj/item/ammo_magazine/sd25
	allowed_magazines = /obj/item/ammo_magazine/sd25
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	magazine_state = null
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

	var/cover_open = FALSE

/obj/item/gun/projectile/automatic/z8/sd25/special_check(mob/user)
	if(cover_open)
		to_chat(user, SPAN_WARNING("[src]'s feed cover is open! Close it before firing!"))
		return FALSE
	return ..()

/obj/item/gun/projectile/automatic/z8/sd25/proc/toggle_cover(mob/user)
	cover_open = !cover_open
	to_chat(user, SPAN_NOTICE("You [cover_open ? "open" : "close"] [src]'s feed cover."))
	update_icon()
	user.update_inv_l_hand()
	user.update_inv_r_hand()

/obj/item/gun/projectile/automatic/z8/sd25/attack_self(mob/user)
	if(cover_open)
		toggle_cover(user)
	else
		return ..()

/obj/item/gun/projectile/automatic/z8/sd25/attack_hand(mob/user)
	if(!cover_open && user.get_inactive_hand() == src)
		toggle_cover(user)
	else
		return ..()

/obj/item/gun/projectile/automatic/z8/sd25/load_ammo(obj/item/A, mob/user)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("You need to open the feed cover to load [src]."))
		return
	..()

/obj/item/gun/projectile/automatic/z8/sd25/unload_ammo(mob/user, allow_dump=1)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("You need to open the feed cover to unload [src]."))
		return
	..()

/obj/item/gun/projectile/automatic/z8/sd25/on_update_icon()
	..()
	var/has_mag = !!ammo_magazine
	icon_state = cover_open ? "pk_open" : (has_mag ? "pk" : "pk_closed")
	var/mob/living/M = loc
	if(istype(M))
		var/is_wielded = M.can_wield_item(src) && src.is_held_twohanded(M)
		if(is_wielded)
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_doble_mag" : "lefthand_doble"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_doble_mag" : "righthand_doble"
		else
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_mag" : "lefthand"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_mag" : "righthand"
	if(has_mag)
		item_state_slots[slot_s_store_str] = "onsuit_mag"
		item_state_slots[slot_back_str] = "back_mag"
	else
		item_state_slots[slot_s_store_str] = "onsuit"
		item_state_slots[slot_back_str] = "back"
	if(has_mag)
		var/ammo_count = round(length(ammo_magazine.stored_ammo), 25)
		AddOverlays(image(icon, "_mag[ammo_count]"))
