/obj/item/gun/projectile/automatic/z8/z11
	name = "Z11-D squad automatic weapon"
	desc = "The Hephaestus Industries Z11-D 'Tindalos' is a squad automatic weapon in service with the SCG. It takes the longer 6.5x59mm cartridge."
	icon = 'code/modules/projectiles/guns/projectile/automatic/z8/z11/z11.dmi'
	icon_state = "z11d"
	item_state = "z11d"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z11/z11.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z11/z11.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z11/z11.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z11/z11.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z11d-wielded-r",
		slot_l_hand_str = "z11d-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag100"
	caliber = PROJECTILE_RIFLE_FULL_SMALL
	ammo_type = /obj/item/ammo_casing/rifle/full/small
	magazine_type = /obj/item/ammo_magazine/z11
	allowed_magazines = /obj/item/ammo_magazine/z11
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
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

	var/cover_open = FALSE

/obj/item/gun/projectile/automatic/z8/z11/special_check(mob/user)
	if(cover_open)
		to_chat(user, SPAN_WARNING("[src]'s feed cover is open! Close it before firing!"))
		return FALSE
	return ..()

/obj/item/gun/projectile/automatic/z8/z11/proc/toggle_cover(mob/user)
	cover_open = !cover_open
	to_chat(user, SPAN_NOTICE("You [cover_open ? "open" : "close"] [src]'s feed cover."))
	update_icon()
	user.update_inv_l_hand()
	user.update_inv_r_hand()

/obj/item/gun/projectile/automatic/z8/z11/attack_self(mob/user)
	if(cover_open)
		toggle_cover(user)
	else
		return ..()

/obj/item/gun/projectile/automatic/z8/z11/attack_hand(mob/user)
	if(!cover_open && user.get_inactive_hand() == src)
		toggle_cover(user)
	else
		return ..()

/obj/item/gun/projectile/automatic/z8/z11/load_ammo(obj/item/A, mob/user)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("You need to open the feed cover to load [src]."))
		return
	..()

/obj/item/gun/projectile/automatic/z8/z11/unload_ammo(mob/user, allow_dump=1)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("You need to open the feed cover to unload [src]."))
		return
	..()

/obj/item/gun/projectile/automatic/z8/z11/on_update_icon()
	..()
	icon_state = cover_open ? "z11d_open" : (ammo_magazine ? "z11d" : "z11d_closed")
	if(ammo_magazine)
		var/ammo_count = round(length(ammo_magazine.stored_ammo), 25)
		AddOverlays(image(icon, "_mag[ammo_count]"))
