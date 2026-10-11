/obj/item/gun/projectile/pistol/sec
	name = "pistol"
	desc = "The NT Mk58 is a cheap, ubiquitous sidearm, produced by a NanoTrasen subsidiary. Found pretty much everywhere humans are."
	icon = 'code/modules/projectiles/guns/projectile/pistol/sec/sec.dmi'
	icon_state = "secguncomp"
	safety_icon = "safety"
	magazine_type = /obj/item/ammo_magazine/pistol/rubber
	accuracy = -1
	fire_delay = 6
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)

/obj/item/gun/projectile/pistol/sec/empty
	starts_loaded = FALSE

/obj/item/gun/projectile/pistol/sec/lethal
	magazine_type = /obj/item/ammo_magazine/pistol
