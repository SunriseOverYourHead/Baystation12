/obj/item/gun/projectile/pistol
	load_method = MAGAZINE
	caliber = PROJECTILE_PISTOL
	ammo_type = /obj/item/ammo_casing/pistol
	magazine_type = /obj/item/ammo_magazine/pistol
	allowed_magazines = /obj/item/ammo_magazine/pistol
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	accuracy_power = 7

/obj/item/gun/projectile/pistol/on_update_icon()
	..()
	var/is_empty = !ammo_magazine || !length(ammo_magazine.stored_ammo)
	if(empty_icon)
		icon_state = is_empty ? "[initial(icon_state)]-e" : initial(icon_state)
	if(ammo_indicator)
		if(is_empty)
			AddOverlays(image(icon, "[initial(icon_state)]-ammo0"))
		else if(LAZYLEN(ammo_magazine.stored_ammo) <= 0.5 * ammo_magazine.max_ammo)
			AddOverlays(image(icon, "[initial(icon_state)]-ammo1"))
		else
			AddOverlays(image(icon, "[initial(icon_state)]-ammo2"))
