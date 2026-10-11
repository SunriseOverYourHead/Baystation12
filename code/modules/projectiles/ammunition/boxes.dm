/obj/item/ammo_magazine/speedloader
	name = "speed loader"
	desc = "A speed loader for revolvers."
	icon_state = "spdloader"
	caliber = PROJECTILE_PISTOL
	ammo_type = /obj/item/ammo_casing/pistol
	matter = list(MATERIAL_STEEL = 1260)
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/speedloader/rubber
	labels = list("rubber")
	ammo_type = /obj/item/ammo_casing/pistol/rubber

/obj/item/ammo_magazine/speedloader/magnum
	icon_state = "spdloader_magnum"
	caliber = PROJECTILE_PISTOL_HUGE
	ammo_type = /obj/item/ammo_casing/pistol/huge
	matter = list(MATERIAL_STEEL = 1440)
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/speedloader/small
	name = "speed loader"
	icon_state = "spdloader_small"
	caliber = PROJECTILE_PISTOL_SMALL
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	matter = list(MATERIAL_STEEL = 1060)
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/speedloader/pclip
	name = "magnum pistol stripper clip"
	desc = "A stripper clip for pistol magnum caliber weapons."
	icon_state = "pclip"
	caliber = PROJECTILE_PISTOL_HUGE
	ammo_type = /obj/item/ammo_casing/pistol/huge
	matter = list(MATERIAL_STEEL = 1300)
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_magazine/speedloader/hpclip
	name = "holdout pistol stripper clip"
	desc = "A stripper clip for pistol holdout caliber weapons."
	icon_state = "hpclip"
	caliber = PROJECTILE_PISTOL_SMALL
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	matter = list(MATERIAL_STEEL = 1800)
	max_ammo = 10
	multiple_sprites = TRUE

/obj/item/ammo_magazine/speedloader/clip
	name = "rifle stripper clip"
	desc = "A stripper clip for rifle caliber weapons."
	icon_state = "clip"
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	ammo_type = /obj/item/ammo_casing/rifle
	matter = list(MATERIAL_STEEL = 1800)
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_magazine/shotholder
	name = "shotgun slug holder"
	desc = "A convenient pouch that holds 12 gauge shells."
	icon_state = "shotholder"
	caliber = PROJECTILE_SHOTGUN
	ammo_type = /obj/item/ammo_casing/shotgun
	matter = list(MATERIAL_STEEL = 1440)
	max_ammo = 4
	multiple_sprites = 1
	var/marking_color

/obj/item/ammo_magazine/shotholder/on_update_icon()
	..()
	ClearOverlays()
	if(marking_color)
		var/image/I = image(icon, "shotholder-marking")
		I.color = marking_color
		AddOverlays(I)

/obj/item/ammo_magazine/shotholder/attack_hand(mob/user)
	if((user.a_intent == I_HURT) && (length(stored_ammo)))
		var/obj/item/ammo_casing/C = stored_ammo[length(stored_ammo)]
		stored_ammo-=C
		user.put_in_hands(C)
		user.visible_message("\The [user] removes \a [C] from [src].", SPAN_NOTICE("You remove \a [C] from [src]."))
		update_icon()
	else
		..()

/obj/item/ammo_magazine/shotholder/shell
	name = "shotgun shell holder"
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	marking_color = COLOR_RED_GRAY

/obj/item/ammo_magazine/shotholder/flechette
	name = "flechette shell holder"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette
	marking_color = COLOR_BLUE

/obj/item/ammo_magazine/shotholder/beanbag
	name = "beanbag shell holder"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	matter = list(MATERIAL_STEEL = 720)
	marking_color = COLOR_PAKISTAN_GREEN

/obj/item/ammo_magazine/shotholder/flash
	name = "illumination shell holder"
	ammo_type = /obj/item/ammo_casing/shotgun/flash
	matter = list(MATERIAL_STEEL = 360, MATERIAL_GLASS = 360)
	marking_color = COLOR_PALE_YELLOW

/obj/item/ammo_magazine/shotholder/stun
	name = "stun shell holder"
	ammo_type = /obj/item/ammo_casing/shotgun/stunshell
	matter = list(MATERIAL_STEEL = 1440, MATERIAL_GLASS = 2880)
	marking_color = COLOR_MUZZLE_FLASH

/obj/item/ammo_magazine/shotholder/empty
	name = "shotgun ammunition holder"
	matter = list(MATERIAL_STEEL = 250)
	initial_ammo = 0

/obj/item/ammo_magazine/machine_pistol
	name = "stick magazine"
	icon_state = "machine_pistol"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/pistol
	matter = list(MATERIAL_STEEL = 1200)
	caliber = PROJECTILE_PISTOL
	max_ammo = 16
	multiple_sprites = 1

/obj/item/ammo_magazine/machine_pistol/empty
	initial_ammo = 0

/obj/item/ammo_magazine/smg_top
	name = "top mounted magazine"
	icon_state = "smg_top"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	matter = list(MATERIAL_STEEL = 1200)
	caliber = PROJECTILE_PISTOL_SMALL
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/smg_top/empty
	initial_ammo = 0

/obj/item/ammo_magazine/smg_top/rubber
	labels = list("rubber")
	ammo_type = /obj/item/ammo_casing/pistol/tiny/rubber

/obj/item/ammo_magazine/smg_top/practice
	labels = list("practice")
	ammo_type = /obj/item/ammo_casing/pistol/tiny/practice

/obj/item/ammo_magazine/smg
	name = "box magazine"
	icon_state = "smg"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/smg/empty
	initial_ammo = 0

/obj/item/ammo_magazine/pistol
	name = "pistol magazine"
	icon_state = "pistol_mag"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL
	matter = list(MATERIAL_STEEL = 750)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_magazine/pistol/empty
	initial_ammo = 0

/obj/item/ammo_magazine/pistol/rubber
	labels = list("rubber")
	ammo_type = /obj/item/ammo_casing/pistol/rubber

/obj/item/ammo_magazine/pistol/practice
	labels = list("practice")
	ammo_type = /obj/item/ammo_casing/pistol/practice

/obj/item/ammo_magazine/pistol/double
	name = "doublestack pistol magazine"
	icon_state = "pistol_mag"
	matter = list(MATERIAL_STEEL = 1050)
	max_ammo = 15

/obj/item/ammo_magazine/pistol/double/empty
	initial_ammo = 0

/obj/item/ammo_magazine/pistol/double/rubber
	labels = list("rubber")
	ammo_type = /obj/item/ammo_casing/pistol/rubber

/obj/item/ammo_magazine/pistol/double/practice
	labels = list("practice")
	ammo_type = /obj/item/ammo_casing/pistol/practice

/obj/item/ammo_magazine/pistol/small
	icon_state = "holdout"
	matter = list(MATERIAL_STEEL = 480)
	caliber = PROJECTILE_PISTOL_SMALL
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	max_ammo = 8

/obj/item/ammo_magazine/pistol/small/empty
	initial_ammo = 0

/obj/item/ammo_magazine/magnum
	name = "magazine"
	icon_state = "magnum"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_HUGE
	matter = list(MATERIAL_STEEL = 1680)
	ammo_type = /obj/item/ammo_casing/pistol/huge
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_magazine/magnum/empty
	initial_ammo = 0

/obj/item/ammo_magazine/box/smallpistol
	name = "ammunition box"
	icon_state = "smallpistol"
	origin_tech = list(TECH_COMBAT = 2)
	matter = list(MATERIAL_STEEL = 1800)
	caliber = PROJECTILE_PISTOL_SMALL
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	max_ammo = 30

/obj/item/ammo_magazine/box/pistol
	name = "ammunition box"
	icon_state = "smallpistol"
	origin_tech = list(TECH_COMBAT = 2)
	caliber = PROJECTILE_PISTOL
	matter = list(MATERIAL_STEEL = 2250)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 30

/obj/item/ammo_magazine/box/pistol/empty
	initial_ammo = 0

/obj/item/ammo_magazine/pistol/throwback
	name = "pistol magazine"
	caliber = PROJECTILE_PISTOL_ANTIQUE
	ammo_type = /obj/item/ammo_casing/pistol/antique

/obj/item/ammo_magazine/box/emp/pistol
	name = "ammunition box"
	desc = "A box containing loose rounds of standard EMP ammo."
	labels = list("haywire")
	ammo_type = /obj/item/ammo_casing/pistol/emp
	caliber = PROJECTILE_PISTOL
	max_ammo = 15

/obj/item/ammo_magazine/box/emp/smallpistol
	name = "ammunition box"
	desc = "A box containing loose rounds of small EMP ammo."
	labels = list("haywire")
	ammo_type = /obj/item/ammo_casing/pistol/tiny/emp
	caliber = PROJECTILE_PISTOL_SMALL
	max_ammo = 8

/obj/item/ammo_magazine/proto_smg
	name = "4x60mm submachine gun magazine"
	icon = 'code/modules/projectiles/ammunition/lowCalSMGStickMagazine.dmi'
	icon_state = "smg"
	origin_tech = list(TECH_COMBAT = 4)
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_FLECHETTE
	matter = list(MATERIAL_STEEL = 2000)
	ammo_type = /obj/item/ammo_casing/flechette
	max_ammo = 40

/obj/item/ammo_magazine/proto_smg/on_update_icon()
	..()
	icon_state = length(stored_ammo) > 0 ? "smg-32" : "smg-0"

/obj/item/ammo_magazine/gyrojet
	name = "microrocket magazine"
	icon_state = "gyrojet"
	mag_type = MAGAZINE
	caliber = PROJECTILE_GYROJET
	ammo_type = /obj/item/ammo_casing/gyrojet
	multiple_sprites = 1
	max_ammo = 4

/obj/item/ammo_magazine/gyrojet/empty
	initial_ammo = 0

/obj/item/ammo_magazine/box/machinegun
	name = "magazine box"
	icon_state = "machinegun"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_BIG
	matter = list(MATERIAL_STEEL = 4500)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/big/antique
	max_ammo = 50
	multiple_sprites = 1

/obj/item/ammo_magazine/box/machinegun/empty
	initial_ammo = 0

/obj/item/ammo_magazine/rifle
	name = "assault rifle magazine"
	icon_state = "assault_rifle"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_BIG
	matter = list(MATERIAL_STEEL = 1800)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/big/antique
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/mil_rifle
	name = "assault rifle magazine"
	icon_state = "bullpup"
	origin_tech = list(TECH_COMBAT = 2)
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE
	matter = list(MATERIAL_STEEL = 1800)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate
	max_ammo = 18
	multiple_sprites = 1

/obj/item/ammo_magazine/mil_rifle/heavy
	labels = list("heavy")

/obj/item/ammo_magazine/mil_rifle/heavy/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mil_rifle/heavy/practice
	labels = list("heavy, practice")
	ammo_type = /obj/item/ammo_casing/rifle/practice/intermediate

/obj/item/ammo_magazine/mil_rifle/light
	icon_state = "bullpup_light"
	labels = list("light")
	ammo_type = /obj/item/ammo_casing/rifle/intermediate
	max_ammo = 14

/obj/item/ammo_magazine/mil_rifle/light/bottomless
	max_ammo = 14000

/obj/item/ammo_magazine/mil_rifle/light/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mil_rifle/light/practice
	labels = list("light, practice")
	ammo_type = /obj/item/ammo_casing/rifle/practice/intermediate

/obj/item/ammo_magazine/caps
	name = "speed loader"
	desc = "A cheap plastic speed loader for some kind of revolver."
	icon_state = "T38"
	caliber = PROJECTILE_CAPS
	ammo_type = /obj/item/ammo_casing/cap
	matter = list(MATERIAL_STEEL = 600)
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_magazine/iclipr
	name = "en-bloc clip"
	desc = "An en-bloc clip for the garand rifle."
	icon_state = "iclipr"
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/rifle
	matter = list(MATERIAL_STEEL = 1500)
	max_ammo = 8
	multiple_sprites = TRUE

/obj/item/ammo_magazine/box/minigun
	name = "minigun box"
	icon_state = "minigun"
	origin_tech = list(TECH_COMBAT = 4)
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_SMALL
	matter = list(MATERIAL_STEEL = 10000)
	ammo_type = /obj/item/ammo_casing/pistol/tiny
	max_ammo = 200
	multiple_sprites = TRUE

/obj/item/ammo_magazine/box/minigun/empty
	initial_ammo = 0

/obj/item/ammo_magazine/shotgunmag
	name = "shotgun magazine"
	desc = "A magazine for semi-automatic shotguns."
	icon_state = "drum"
	caliber = PROJECTILE_SHOTGUN
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/shotgun
	matter = list(MATERIAL_STEEL = 2400)
	max_ammo = 15
	multiple_sprites = TRUE

/obj/item/ammo_magazine/shotgunmag/shot
	labels = list("shot")
	ammo_type = /obj/item/ammo_casing/shotgun/pellet

/obj/item/ammo_magazine/shotgunmag/flechette
	labels = list("flechette")
	ammo_type = /obj/item/ammo_casing/shotgun/flechette

/obj/item/ammo_magazine/shotgunmag/beanbag
	labels = list("beanbag")
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

// ---- Sol/SCG military magazines ----

/obj/item/ammo_magazine/m19
	name = "M19 magazine"
	desc = "A 10-round magazine for the M19 service pistol."
	icon = 'code/modules/projectiles/ammunition/lowcalPistols.dmi'
	icon_state = "pistol"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL
	matter = list(MATERIAL_STEEL = 600)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 10
	multiple_sprites = 1

/obj/item/ammo_magazine/m19/empty
	initial_ammo = 0

/obj/item/ammo_magazine/m22f
	name = "M22 magazine"
	desc = "A 10-round doublestack magazine for the M22 service pistol."
	icon = 'code/modules/projectiles/ammunition/HighCalPistolMagazine.dmi'
	icon_state = "magnum"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_BIG
	matter = list(MATERIAL_STEEL = 750)
	ammo_type = /obj/item/ammo_casing/pistol/big
	max_ammo = 10
	multiple_sprites = 1

/obj/item/ammo_magazine/m22f/empty
	initial_ammo = 0

/obj/item/ammo_magazine/m25
	name = "M25 magazine"
	desc = "An 8-round magazine for the M25 heavy pistol."
	icon = 'code/modules/projectiles/ammunition/50AEPistolMagazine.dmi'
	icon_state = "kurtz"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_MASSIVE
	matter = list(MATERIAL_STEEL = 700)
	ammo_type = /obj/item/ammo_casing/pistol/massive
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_magazine/m25/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mp85
	name = "MP85 magazine"
	desc = "A 30-round magazine for the MP85 PDW."
	icon = 'code/modules/projectiles/ammunition/lowCalSMGStickMagazine.dmi'
	icon_state = "smg"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL_SMALL
	matter = list(MATERIAL_STEEL = 1000)
	ammo_type = /obj/item/ammo_casing/pistol/small
	max_ammo = 30
	multiple_sprites = 1

/obj/item/ammo_magazine/mp85/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mp24
	name = "MP24 magazine"
	desc = "A 32-round stick magazine for the MP24 submachinegun."
	icon = 'code/modules/projectiles/ammunition/lowCalSMGStickMagazine.dmi'
	icon_state = "smg"
	mag_type = MAGAZINE
	caliber = PROJECTILE_PISTOL
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 32
	multiple_sprites = 1

/obj/item/ammo_magazine/mp24/empty
	initial_ammo = 0

/obj/item/ammo_magazine/mp24/drum
	name = "MP24 drum magazine"
	desc = "A 72-round drum magazine for the MP24 submachinegun."
	icon = 'code/modules/projectiles/ammunition/lowCalSMGDrumMagazine.dmi'
	icon_state = "ldrum"
	max_ammo = 72
	multiple_sprites = 1

/obj/item/ammo_magazine/mp24/drum/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z9
	name = "Z9-C magazine"
	desc = "A 30-round magazine for the Z9-C bullpup carbine."
	icon = 'code/modules/projectiles/ammunition/Rifle30Magazine.dmi'
	icon_state = "lrifle_long"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE
	matter = list(MATERIAL_STEEL = 1800)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate
	max_ammo = 30
	multiple_sprites = 1

/obj/item/ammo_magazine/z9/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z9/short
	name = "Z9-C short magazine"
	desc = "A compact 20-round magazine for the Z9-C bullpup carbine."
	icon = 'code/modules/projectiles/ammunition/Rifle20ShortMagazine.dmi'
	icon_state = "lrifle_short"
	max_ammo = 20

/obj/item/ammo_magazine/z9/short/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z9/drum
	name = "Z9-C drum magazine"
	desc = "A 50-round drum magazine for the Z9-C bullpup carbine."
	icon = 'code/modules/projectiles/ammunition/Rifle50DrumMagazine.dmi'
	icon_state = "rifle_drum"
	max_ammo = 50

/obj/item/ammo_magazine/z9/drum/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z9/drum/large
	name = "Z9-C large drum magazine"
	desc = "A 75-round drum magazine for the Z9-C bullpup carbine."
	icon = 'code/modules/projectiles/ammunition/Rifle75DrumMagazine.dmi'
	icon_state = "lrifle_drum"
	max_ammo = 75

/obj/item/ammo_magazine/z9/drum/large/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z10
	name = "Z10-A magazine"
	desc = "A 20-round magazine for the Z10-A assault rifle."
	icon = 'code/modules/projectiles/ammunition/HeavyCalRifle20Magazine.dmi'
	icon_state = "hrifle"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_BIG
	matter = list(MATERIAL_STEEL = 1800)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/big
	max_ammo = 20
	multiple_sprites = 1

/obj/item/ammo_magazine/z10/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z11
	name = "Z11-D box magazine"
	desc = "A 100-round box magazine for the Z11-D squad automatic weapon."
	icon = 'code/modules/projectiles/ammunition/LMG100BoxMagazine.dmi'
	icon_state = "pk_box"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_FULL_SMALL
	matter = list(MATERIAL_STEEL = 5000)
	ammo_type = /obj/item/ammo_casing/rifle/full/small
	max_ammo = 100
	multiple_sprites = 1

/obj/item/ammo_magazine/z11/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z8d
	name = "Z8-D magazine"
	desc = "A 20-round magazine for the Z8-D marksman rifle."
	icon = 'code/modules/projectiles/ammunition/HeavyCalRifle20Magazine.dmi'
	icon_state = "hrifle"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_FULL_SMALL
	matter = list(MATERIAL_STEEL = 1200)
	ammo_type = /obj/item/ammo_casing/rifle/full/small
	max_ammo = 20

/obj/item/ammo_magazine/z8d/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z9e
	name = "Z9-E drum magazine"
	desc = "A 36-round drum magazine for the Z9-E SOCOM bullpup rifle."
	icon = 'code/modules/projectiles/ammunition/Hdrums.dmi'
	icon_state = "hdrum"
	mag_type = MAGAZINE
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_HUGE
	matter = list(MATERIAL_STEEL = 2000)
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/huge
	max_ammo = 36
	multiple_sprites = 1

/obj/item/ammo_magazine/z9e/empty
	initial_ammo = 0

/obj/item/ammo_magazine/z8g
	name = "Z8-G drum magazine"
	desc = "A 20-round drum magazine for the Z8-G automatic shotgun."
	icon = 'code/modules/projectiles/ammunition/ShotgunDrum.dmi'
	icon_state = "m12"
	mag_type = MAGAZINE
	caliber = PROJECTILE_SHOTGUN
	matter = list(MATERIAL_STEEL = 1500)
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	max_ammo = 20

/obj/item/ammo_magazine/z8g/empty
	initial_ammo = 0
