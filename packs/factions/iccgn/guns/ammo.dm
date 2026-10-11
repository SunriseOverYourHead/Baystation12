/obj/item/ammo_magazine/sd11
	name = "SD11-D magazine"
	desc = "A 20-round magazine for the SD11-D assault rifle."
	icon = 'code/modules/projectiles/ammunition/Rifle20ShortMagazine.dmi'
	icon_state = "lrifle_short"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/small
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/sd11/empty
	initial_ammo = 0

/obj/item/ammo_magazine/sd22
	name = "SD22-A magazine"
	desc = "A 20-round magazine for the SD22-A assault rifle."
	icon = 'code/modules/projectiles/ammunition/Rifle20ShortMagazine.dmi'
	icon_state = "lrifle_short"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_MASSIVE
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/massive
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/sd22/empty
	initial_ammo = 0

/obj/item/ammo_magazine/sd25
	name = "SD25-B box magazine"
	desc = "A 100-round box magazine for the SD25-B squad automatic weapon."
	icon = 'code/modules/projectiles/ammunition/ICCGLMG100BoxMagazine.dmi'
	icon_state = "pkl_box"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	matter = list(MATERIAL_STEEL = 5000)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/small
	max_ammo = 100
	multiple_sprites = 1

/obj/item/ammo_magazine/sd25/empty
	initial_ammo = 0

/obj/item/ammo_magazine/sd31
	name = "SD31 shotgun magazine"
	desc = "A 10-round magazine for the SD31 automatic shotgun."
	icon = 'code/modules/projectiles/ammunition/ShotgunMagazine.dmi'
	icon_state = "sbaw"
	mag_type = MAGAZINE
	caliber = PROJECTILE_SHOTGUN
	matter = list(MATERIAL_STEEL = 1000)
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	max_ammo = 10
	multiple_sprites = 1

/obj/item/ammo_magazine/sd31/empty
	initial_ammo = 0

/obj/item/ammo_magazine/pp72
	name = "PP72 magazine"
	desc = "A 32-round magazine for the PP72 submachinegun."
	icon = 'code/modules/projectiles/ammunition/lowCalSMGStickMagazine.dmi'
	icon_state = "smg"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 32
	multiple_sprites = 1

/obj/item/ammo_magazine/pp72/empty
	initial_ammo = 0

/obj/item/ammo_magazine/p225
	name = "P225 magazine"
	desc = "An 8-round magazine for the P225 service pistol."
	icon = 'code/modules/projectiles/ammunition/HighCalPistolMagazine.dmi'
	icon_state = "magnum"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_HUGE
	matter = list(MATERIAL_STEEL = 600)
	ammo_type = /obj/item/ammo_casing/pistol/huge
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_magazine/p225/empty
	initial_ammo = 0

/obj/item/ammo_magazine/p87
	name = "P87 magazine"
	desc = "A 12-round magazine for the P87 service pistol."
	icon = 'code/modules/projectiles/ammunition/HighCalPistolMagazine.dmi'
	icon_state = "magnum"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_BIG
	matter = list(MATERIAL_STEEL = 750)
	ammo_type = /obj/item/ammo_casing/pistol/big
	max_ammo = 12

/obj/item/ammo_magazine/p87/on_update_icon()
	..()
	// HighCalPistolMagazine.dmi has tiers at 0,2,4,6,8,10 — map 12-round mag to available states
	var/count = length(stored_ammo)
	if(count <= 0)
		icon_state = "magnum-0"
	else if(count <= 2)
		icon_state = "magnum-2"
	else if(count <= 4)
		icon_state = "magnum-4"
	else if(count <= 6)
		icon_state = "magnum-6"
	else if(count <= 8)
		icon_state = "magnum-8"
	else
		icon_state = "magnum-10"

/obj/item/ammo_magazine/p87/empty
	initial_ammo = 0

/obj/item/ammo_magazine/sd24
	name = "SD24-C magazine"
	desc = "A 10-round magazine for the SD24-C marksman rifle."
	icon = 'code/modules/projectiles/ammunition/Rifle20ShortMagazine.dmi'
	icon_state = "lrifle_short"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	matter = list(MATERIAL_STEEL = 1200)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/small
	max_ammo = 10

/obj/item/ammo_magazine/sd24/on_update_icon()
	..()
	// Rifle20ShortMagazine.dmi only has tiers 0 (empty) and 20 (full) — use binary display
	icon_state = length(stored_ammo) > 0 ? "lrifle_short-20" : "lrifle_short-0"

/obj/item/ammo_magazine/sd24/empty
	initial_ammo = 0

/obj/item/ammo_magazine/sd55
	name = "SD55-B magazine"
	desc = "A 5-round magazine for the SD55-B anti-materiel rifle."
	icon = 'code/modules/projectiles/ammunition/HeavyCalRifle20Magazine.dmi'
	icon_state = "hrifle"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_FULL_BIG
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/rifle/full/big
	max_ammo = 5

/obj/item/ammo_magazine/sd55/on_update_icon()
	..()
	// HeavyCalRifle20Magazine.dmi only has tiers 0 (empty) and 14 (full) — use binary display
	icon_state = length(stored_ammo) > 0 ? "hrifle-14" : "hrifle-0"

/obj/item/ammo_magazine/sd55/empty
	initial_ammo = 0
