/obj/item/gun/projectile/pistol/magnum_pistol
	name = "magnum pistol"
	desc = "The HelTek Magnus, a robust handgun that uses high-caliber ammo. Issued to Confederation Pioneers for holster sized defence."
	icon = 'code/modules/projectiles/guns/projectile/pistol/magnum_pistol/magnum_pistol.dmi'
	icon_state = "magnum"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/pistol/magnum_pistol/magnum_pistol.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/pistol/magnum_pistol/magnum_pistol.dmi',
	)
	colocated_sprites = TRUE
	item_state = "magnum"
	safety_icon = "safety"
	force = 9
	caliber = PROJECTILE_PISTOL_HUGE
	fire_delay = 12
	screen_shake = 2
	magazine_type = /obj/item/ammo_magazine/magnum
	allowed_magazines = /obj/item/ammo_magazine/magnum
	mag_insert_sound = 'sound/weapons/guns/interaction/hpistol_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/hpistol_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	accuracy = 2
	one_hand_penalty = 2
	bulk = 3
	ammo_indicator = TRUE
