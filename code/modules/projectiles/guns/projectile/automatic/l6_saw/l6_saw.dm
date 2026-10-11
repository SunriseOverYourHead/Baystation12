/obj/item/gun/projectile/automatic/l6_saw
	name = "light machine gun"
	desc = "An unbranded machine gun, based off a design made long ago."
	icon = 'code/modules/projectiles/guns/projectile/automatic/l6_saw/l6_saw.dmi'
	icon_state = "l6closed50"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/l6_saw/l6_saw.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/l6_saw/l6_saw.dmi',
	)
	colocated_sprites = TRUE
	item_state = "l6closedmag"
	wielded_item_state = "l6closed-wielded"
	w_class = ITEM_SIZE_HUGE
	bulk = 10
	force = 10
	slot_flags = 0
	max_shells = 50
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_BIG
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 2)
	slot_flags = 0 //need sprites for SLOT_BACK
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/big/antique
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/box/machinegun
	allowed_magazines = list(/obj/item/ammo_magazine/box/machinegun, /obj/item/ammo_magazine/rifle)
	one_hand_penalty = 10
	mag_insert_sound = 'sound/weapons/guns/interaction/lmg_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/lmg_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'
	can_special_reload = FALSE

	//LMG, better sustained fire accuracy than assault rifles (comparable to SMG), higer move delay and one-handing penalty
	//No single-shot or 3-round-burst modes since using this weapon should come at a cost to flexibility.
	firemodes = list(
		list(
			"mode_name" = "short bursts",
			"can_autofire" = 0,
			"burst" = 5,
			"fire_delay" = 5,
			"move_delay" = 12,
			"one_hand_penalty" = 8,
			"burst_accuracy" = list(0, -1, -1, -2, -2),
			"dispersion" = list(0.6, 1.0, 1.0, 1.0, 1.2)
		),
		list(
			"mode_name" = "long bursts",
			"can_autofire" = 0,
			"burst" = 8,
			"fire_delay" = 5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, -1, -1, -2, -2, -2, -3, -3),
			"dispersion" = list(1.0, 1.0, 1.0, 1.0, 1.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 1,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, -1, -1, -2, -2, -2, -3, -3),
			"dispersion" = list(1.0, 1.0, 1.0, 1.0, 1.2)
		)
	)

	var/cover_open = 0

/obj/item/gun/projectile/automatic/l6_saw/mag
	magazine_type = /obj/item/ammo_magazine/rifle

/obj/item/gun/projectile/automatic/l6_saw/special_check(mob/user)
	if(cover_open)
		to_chat(user, SPAN_WARNING("[src]'s cover is open! Close it before firing!"))
		return 0
	return ..()

/obj/item/gun/projectile/automatic/l6_saw/proc/toggle_cover(mob/user)
	cover_open = !cover_open
	to_chat(user, SPAN_NOTICE("You [cover_open ? "open" : "close"] [src]'s cover."))
	update_icon()
	user.update_inv_l_hand()
	user.update_inv_r_hand()

/obj/item/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	if(cover_open)
		toggle_cover(user) //close the cover
		update_icon()
		user.update_inv_l_hand()
		user.update_inv_r_hand()

	else
		return ..() //once closed, behave like normal

/obj/item/gun/projectile/automatic/l6_saw/attack_hand(mob/user as mob)
	if(!cover_open && user.get_inactive_hand() == src)
		toggle_cover(user) //open the cover
		update_icon()
		user.update_inv_l_hand()
		user.update_inv_r_hand()

	else
		return ..() //once open, behave like normal

/obj/item/gun/projectile/automatic/l6_saw/on_update_icon()
	..()
	if(istype(ammo_magazine, /obj/item/ammo_magazine/box))
		icon_state = "l6[cover_open ? "open" : "closed"][round(length(ammo_magazine.stored_ammo), 10)]"
		item_state = "l6[cover_open ? "open" : "closed"]"
		wielded_item_state = "l6[cover_open ? "open" : "closed"]-wielded"
	else if(ammo_magazine)
		icon_state = "l6[cover_open ? "open" : "closed"]mag"
		item_state = "l6[cover_open ? "open" : "closed"]mag"
		wielded_item_state = "l6[cover_open ? "open" : "closed"]mag-wielded"
	else
		icon_state = "l6[cover_open ? "open" : "closed"]-empty"
		item_state = "l6[cover_open ? "open" : "closed"]-empty"
		wielded_item_state = "l6[cover_open ? "open" : "closed"]-empty-wielded"

/obj/item/gun/projectile/automatic/l6_saw/load_ammo(obj/item/A, mob/user)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("You need to open the cover to load that into [src]."))
		return
	..()

/obj/item/gun/projectile/automatic/l6_saw/unload_ammo(mob/user, allow_dump=1)
	if(!cover_open)
		to_chat(user, SPAN_WARNING("You need to open the cover to unload [src]."))
		return
	..()
