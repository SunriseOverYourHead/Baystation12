/obj/item/ammo_casing/pistol/antique
	desc = "An antique pistol bullet casing."
	caliber = PROJECTILE_PISTOL_ANTIQUE

/obj/item/ammo_casing/pistol/tiny
	desc = "A minuscle pistol bullet casing."
	caliber = PROJECTILE_PISTOL_TINY
	projectile_type = /obj/item/projectile/bullet/pistol/tiny
	icon_state = "smallcasing"
	spent_icon = "smallcasing-spent"

/obj/item/ammo_casing/pistol/tiny/rubber
	desc = "A minuscle pistol rubber bullet casing."
	label = "rubber"
	projectile_type = /obj/item/projectile/bullet/pistol/rubber/tiny
	icon_state = "smallcasing_r"

/obj/item/ammo_casing/pistol/tiny/practice
	desc = "A minuscle pistol practice bullet casing."
	label = "practice"
	projectile_type = /obj/item/projectile/bullet/pistol/practice
	icon_state = "smallcasing_p"

/obj/item/ammo_casing/pistol/tiny/emp
	name = "minuscle haywire round"
	desc = "A small bullet casing fitted with a single-use ion pulse generator."
	projectile_type = /obj/item/projectile/ion/tiny
	icon_state = "smallcasing_h"

/obj/item/ammo_casing/pistol/small
	desc = "A small pistol bullet casing."
	caliber = PROJECTILE_PISTOL_SMALL
	projectile_type = /obj/item/projectile/bullet/pistol/small
	icon_state = "smallcasing"
	spent_icon = "smallcasing-spent"

/obj/item/ammo_casing/pistol
	desc = "A pistol bullet casing."
	caliber = PROJECTILE_PISTOL
	projectile_type = /obj/item/projectile/bullet/pistol
	icon_state = "pistolcasing"
	spent_icon = "pistolcasing-spent"

/obj/item/ammo_casing/pistol/rubber
	desc = "A rubber pistol bullet casing."
	label = "rubber"
	projectile_type = /obj/item/projectile/bullet/pistol/rubber
	icon_state = "pistolcasing_r"

/obj/item/ammo_casing/pistol/practice
	desc = "A practice pistol bullet casing."
	label = "practice"
	projectile_type = /obj/item/projectile/bullet/pistol/practice
	icon_state = "pistolcasing_p"

/obj/item/ammo_casing/pistol/emp
	name = "haywire round"
	desc = "A pistol bullet casing fitted with a single-use ion pulse generator."
	projectile_type = /obj/item/projectile/ion/small
	icon_state = "pistolcasing_h"
	matter = list(MATERIAL_STEEL = 130, MATERIAL_URANIUM = 100)

/obj/item/ammo_casing/pistol/big
	desc = "A high-power pistol bullet casing."
	caliber = PROJECTILE_PISTOL_BIG
	projectile_type = /obj/item/projectile/bullet/pistol/big
	icon_state = "pistolcasing"
	spent_icon = "pistolcasing-spent"

/obj/item/ammo_casing/pistol/huge
	desc = "An extremely high-power pistol bullet casing."
	caliber = PROJECTILE_PISTOL_HUGE
	projectile_type = /obj/item/projectile/bullet/pistol/huge
	icon_state = "magnumcasing"
	spent_icon = "magnumcasing-spent"

/obj/item/ammo_casing/pistol/massive
	desc = "An obscenely high-power pistol bullet casing."
	caliber = PROJECTILE_PISTOL_MASSIVE
	projectile_type = /obj/item/projectile/bullet/pistol/massive
	icon_state = "magnumcasing"
	spent_icon = "magnumcasing-spent"

/obj/item/ammo_casing/pistol/cannon
	desc = "A chunky, massive pistol bullet casing. Your wrist aches at its sight!"
	caliber = PROJECTILE_PISTOL_CANNON
	projectile_type = /obj/item/projectile/bullet/pistol/cannon
	icon_state = "magnumcasing"
	spent_icon = "magnumcasing-spent"

/obj/item/ammo_casing/gyrojet
	desc = "A minirocket casing."
	caliber = PROJECTILE_GYROJET
	projectile_type = /obj/item/projectile/bullet/gyro
	icon_state = "lcasing"
	spent_icon = "lcasing-spent"

/obj/item/ammo_casing/flechette
	desc = "A flechette casing."
	caliber = PROJECTILE_PISTOL_FLECHETTE
	projectile_type = /obj/item/projectile/bullet/flechette
	icon_state = "flechette-casing"
	spent_icon = "flechette-casing-spent"

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A shotgun slug."
	icon_state = "slshell"
	spent_icon = "slshell-spent"
	caliber = PROJECTILE_SHOTGUN
	projectile_type = /obj/item/projectile/bullet/shotgun
	matter = list(MATERIAL_STEEL = 160)
	fall_sounds = list('sound/weapons/guns/shotgun_fall.ogg')

/obj/item/ammo_casing/shotgun/pellet
	name = "shotgun shell"
	desc = "A shotshell."
	icon_state = "gshell"
	spent_icon = "gshell-spent"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun

/obj/item/ammo_casing/shotgun/flechette
	name = "flechette shell"
	desc = "A flechette shell."
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun/flechette

/obj/item/ammo_casing/shotgun/blank
	name = "shotgun shell"
	desc = "A blank shell."
	icon_state = "blshell"
	spent_icon = "blshell-spent"
	label = "blank"
	projectile_type = /obj/item/projectile/bullet/blank
	matter = list(MATERIAL_STEEL = 60)

/obj/item/ammo_casing/shotgun/practice
	name = "shotgun shell"
	desc = "A practice shell."
	icon_state = "pshell"
	spent_icon = "pshell-spent"
	label = "practice"
	projectile_type = /obj/item/projectile/bullet/shotgun/practice
	matter = list(MATERIAL_STEEL = 60)

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag shell"
	desc = "A beanbag shell."
	icon_state = "bshell"
	spent_icon = "bshell-spent"
	projectile_type = /obj/item/projectile/bullet/shotgun/beanbag
	matter = list(MATERIAL_STEEL = 140)

//Can stun in one hit if aimed at the head, but
//is blocked by clothing that stops tasers and is vulnerable to EMP
/obj/item/ammo_casing/shotgun/stunshell
	name = "stun shell"
	desc = "An energy stun cartridge."
	icon_state = "stunshell"
	spent_icon = "stunshell-spent"
	projectile_type = /obj/item/projectile/energy/electrode/stunshot
	leaves_residue = FALSE
	matter = list(MATERIAL_STEEL = 160, MATERIAL_GLASS = 320)

/obj/item/ammo_casing/shotgun/stunshell/emp_act(severity)
	if(prob(100/severity)) BB = null
	update_icon()
	..()

//Does not stun, only blinds, but has area of effect.
/obj/item/ammo_casing/shotgun/flash
	name = "flash shell"
	desc = "A chemical shell used to signal distress or provide illumination."
	icon_state = "fshell"
	spent_icon = "fshell-spent"
	projectile_type = /obj/item/projectile/energy/flash/flare
	matter = list(MATERIAL_STEEL = 80, MATERIAL_GLASS = 80)

// Base rifle ammo.
/obj/item/ammo_casing/rifle
	desc = "A rifle bullet casing."
	caliber = PROJECTILE_RIFLE_INTERMEDIATE
	projectile_type = /obj/item/projectile/bullet/rifle
	icon_state = "riflecasing"
	spent_icon = "riflecasing-spent"

/obj/item/ammo_casing/rifle/practice
	desc = "A rifle practice bullet casing."
	label = "practice"
	projectile_type = /obj/item/projectile/bullet/rifle/practice
	icon_state = "riflecasing_p"

/obj/item/ammo_casing/rifle/intermediate/small/antique
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_SMALL
	projectile_type = /obj/item/projectile/bullet/rifle/intermediate/small/antique

/obj/item/ammo_casing/rifle/intermediate/big/antique
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_ANTIQUE_BIG
	projectile_type = /obj/item/projectile/bullet/rifle/intermediate/big/antique

/obj/item/ammo_casing/rifle/intermediate/small
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	projectile_type = /obj/item/projectile/bullet/rifle/intermediate/small

/obj/item/ammo_casing/rifle/intermediate
	desc = "An intermediate rifle bullet casing."
	caliber = PROJECTILE_RIFLE_INTERMEDIATE
	projectile_type = /obj/item/projectile/bullet/rifle/intermediate/small

/obj/item/ammo_casing/rifle/practice/intermediate
	desc = "An intermediate rifle practice bullet casing."
	projectile_type = /obj/item/projectile/bullet/rifle/practice

/obj/item/ammo_casing/rifle/intermediate/big
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_BIG
	projectile_type = /obj/item/projectile/bullet/rifle/intermediate/big

/obj/item/ammo_casing/rifle/intermediate/massive
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_MASSIVE
	projectile_type = /obj/item/projectile/bullet/rifle/intermediate/massive

/obj/item/ammo_casing/rifle/intermediate/huge
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_HUGE
	projectile_type = /obj/item/projectile/bullet/rifle/intermediate/huge



/obj/item/ammo_casing/rifle/full/small/antique
	caliber = PROJECTILE_RIFLE_FULL_ANTIQUE_SMALL
	projectile_type = /obj/item/projectile/bullet/rifle/full/small/antique

/obj/item/ammo_casing/rifle/full/big/antique
	caliber = PROJECTILE_RIFLE_FULL_ANTIQUE_BIG
	projectile_type = /obj/item/projectile/bullet/rifle/full/big/antique

/obj/item/ammo_casing/rifle/full/huge/antique
	caliber = PROJECTILE_RIFLE_FULL_ANTIQUE_HUGE
	projectile_type = /obj/item/projectile/bullet/rifle/full/huge/antique

/obj/item/ammo_casing/rifle/full/small
	caliber = PROJECTILE_RIFLE_FULL_SMALL
	projectile_type = /obj/item/projectile/bullet/rifle/full/small

/obj/item/ammo_casing/rifle/full
	desc = "A full-length rifle bullet casing."
	caliber = PROJECTILE_RIFLE_FULL
	projectile_type = /obj/item/projectile/bullet/rifle/full/small
	icon_state = "rifle_mil"
	spent_icon = "rifle_mil-spent"

/obj/item/ammo_casing/rifle/practice/full
	desc = "An full-length rifle practice bullet casing."
	projectile_type = /obj/item/projectile/bullet/rifle/practice
	icon_state = "rifle_mil_p"

/obj/item/ammo_casing/rifle/full/big
	caliber = PROJECTILE_RIFLE_FULL_BIG
	projectile_type = /obj/item/projectile/bullet/rifle/full/big

/obj/item/ammo_casing/rifle/full/huge
	caliber = PROJECTILE_RIFLE_FULL_HUGE
	projectile_type = /obj/item/projectile/bullet/rifle/full/huge
	name = "shell casing"
	desc = "An antimaterial shell casing."
	icon_state = "lcasing"
	spent_icon = "lcasing-spent"
	matter = list(MATERIAL_STEEL = 1250)

/obj/item/ammo_casing/rocket
	name = "rocket shell"
	desc = "A high explosive designed to be fired from a launcher."
	icon_state = "rocketshell"
	projectile_type = /obj/item/missile
	caliber = "rocket"

/obj/item/ammo_casing/cap
	name = "cap"
	desc = "A cap for children toys."
	caliber = PROJECTILE_CAPS
	color = "#ff0000"
	projectile_type = /obj/item/projectile/bullet/pistol/cap

/obj/item/ammo_casing/shotgun/emp
	name = "haywire slug"
	desc = "A 12-gauge shotgun slug fitted with a single-use ion pulse generator."
	icon_state = "empshell"
	spent_icon = "empshell-spent"
	projectile_type  = /obj/item/projectile/ion
	matter = list(MATERIAL_STEEL = 160, MATERIAL_URANIUM = 160)
