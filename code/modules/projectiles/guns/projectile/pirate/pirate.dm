/obj/item/gun/projectile/pirate
	name = "zip gun"
	desc = "Little more than a barrel, handle, and firing mechanism, cheap makeshift firearms like this one are not uncommon in frontier systems."
	icon = 'code/modules/projectiles/guns/projectile/pirate/pirate.dmi'
	icon_state = "zipgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/pirate/pirate.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/pirate/pirate.dmi',
	)
	colocated_sprites = TRUE
	item_state = "sawnshotgun"
	handle_casings = CYCLE_CASINGS //player has to take the old casing out manually before reloading
	load_method = SINGLE_CASING
	max_shells = 1 //literally just a barrel
	has_safety = FALSE
	w_class = ITEM_SIZE_NORMAL

	var/static/list/ammo_types = list(
		/obj/item/ammo_casing/pistol,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_casing/shotgun/pellet,
		/obj/item/ammo_casing/shotgun/pellet,
		/obj/item/ammo_casing/shotgun/pellet,
		/obj/item/ammo_casing/shotgun/beanbag ,
		/obj/item/ammo_casing/shotgun/stunshell,
		/obj/item/ammo_casing/shotgun/flash,
		/obj/item/ammo_casing/rifle/intermediate/small,
		/obj/item/ammo_casing/rifle
		)

/obj/item/gun/projectile/pirate/toggle_safety(mob/user)
	to_chat(user, SPAN_WARNING("There's no safety on \the [src]!"))

/obj/item/gun/projectile/pirate/Initialize()
	var/obj/item/ammo_casing/ammo = pick(ammo_types)
	caliber = initial(ammo.caliber)
	desc += " Uses [caliber] rounds."
	if(caliber == PROJECTILE_SHOTGUN)
		fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	if(caliber == PROJECTILE_PISTOL)
		fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	if(caliber == PROJECTILE_RIFLE_INTERMEDIATE_SMALL || caliber == PROJECTILE_RIFLE_INTERMEDIATE_BIG)
		fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'
	. = ..()

/obj/item/gun/projectile/pirate/unloaded
	starts_loaded = FALSE

/obj/item/gun/projectile/pirate/on_update_icon()
	..()
	if(length(loaded))
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-empty"
