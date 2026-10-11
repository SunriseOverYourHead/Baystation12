/obj/item/gun/projectile/pistol/holdout
	name = "holdout pistol"
	desc = "The Lumoco Arms P3 Whisper. A small, easily concealable gun."
	icon = 'code/modules/projectiles/guns/projectile/pistol/holdout/holdout.dmi'
	icon_state = "pistol"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/pistol/holdout/holdout.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/pistol/holdout/holdout.dmi',
	)
	colocated_sprites = TRUE
	item_state = "pistol"
	w_class = ITEM_SIZE_SMALL
	caliber = PROJECTILE_PISTOL_SMALL
	fire_delay = 4
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2, TECH_ESOTERIC = 2)
	magazine_type = /obj/item/ammo_magazine/pistol/small
	allowed_magazines = /obj/item/ammo_magazine/pistol/small
	barrel_thread = TRUE
	silencer_offset = -6

/obj/item/gun/projectile/pistol/holdout/on_update_icon()
	..()
	if (silencer)
		item_state = "[initial(item_state)]-silencer"
	else
		item_state = initial(item_state)

/obj/item/silencer
	name = "silencer"
	desc = "A silencer."
	icon = 'code/modules/projectiles/guns/projectile/pistol/holdout/holdout.dmi'
	icon_state = "silencer"
	w_class = ITEM_SIZE_SMALL
	var/caliber = PROJECTILE_PISTOL_SMALL
	var/silenced_sound = 'sound/weapons/gunshot/gunshot_suppressed.ogg'
