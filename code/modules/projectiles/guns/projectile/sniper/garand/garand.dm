/obj/item/gun/projectile/sniper/garand
	name = "garand rifle"
	desc = "The rugged garand is a old semi-automatic weapon popular on the frontier worlds. PING!"
	icon = 'code/modules/projectiles/guns/projectile/sniper/garand/garand.dmi'
	icon_state = "garand"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/sniper/garand/garand.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/sniper/garand/garand.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/sniper/garand/garand.dmi',
	)
	colocated_sprites = TRUE
	item_state = "garand"
	origin_tech = list(TECH_COMBAT = 2)
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/iclipr
	allowed_magazines = /obj/item/ammo_magazine/iclipr
	auto_eject = TRUE
	auto_eject_sound = 'sound/weapons/guns/interaction/garand_magout.ogg'
	one_hand_penalty = 9
	accuracy_power = 5
	accuracy = 2
	bulk = GUN_BULK_HEAVY_RIFLE
	wielded_item_state = "garand-wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/garand_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'

/obj/item/gun/projectile/sniper/garand/on_update_icon()
	if(ammo_magazine && length(ammo_magazine.stored_ammo))
		icon_state = initial(icon_state)
		wielded_item_state = initial(wielded_item_state)
	else
		icon_state = "[initial(icon_state)]-empty"
		wielded_item_state = "[initial(wielded_item_state)]-empty"
	..()
