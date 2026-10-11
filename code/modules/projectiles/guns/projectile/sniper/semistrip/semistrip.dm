/obj/item/gun/projectile/sniper/semistrip
	name = "carbine rifle"
	desc = "An old semi-automatic carbine chambered in large pistol rounds, this thing looks older than the SCG."
	icon = 'code/modules/projectiles/guns/projectile/sniper/semistrip/semistrip.dmi'
	icon_state = "semistrip"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/sniper/semistrip/semistrip.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/sniper/semistrip/semistrip.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/sniper/semistrip/semistrip.dmi',
	)
	colocated_sprites = TRUE
	item_state = "semistrip"
	w_class = ITEM_SIZE_HUGE
	force = 10
	origin_tech = list(TECH_COMBAT = 2)
	slot_flags = SLOT_BACK
	caliber = PROJECTILE_PISTOL_HUGE
	ammo_type = /obj/item/ammo_casing/pistol/huge
	load_method = SINGLE_CASING|SPEEDLOADER
	fire_delay = 2
	one_hand_penalty = 8
	max_shells = 10
	accuracy = 1
	wielded_item_state = "semistrip-wielded"
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'

/obj/item/gun/projectile/sniper/semistrip/on_update_icon()
	if(ammo_magazine && length(ammo_magazine.stored_ammo))
		icon_state = initial(icon_state)
		wielded_item_state = initial(wielded_item_state)
	else
		icon_state = "[initial(icon_state)]-empty"
		wielded_item_state = "[initial(wielded_item_state)]-empty"
	..()
