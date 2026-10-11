/obj/item/gun/projectile/pistol/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds."
	icon = 'code/modules/projectiles/guns/projectile/pistol/gyropistol/gyropistol.dmi'
	icon_state = "gyropistol"
	max_shells = 8
	caliber = PROJECTILE_GYROJET
	origin_tech = list(TECH_COMBAT = 3)
	magazine_type = /obj/item/ammo_magazine/gyrojet
	allowed_magazines = /obj/item/ammo_magazine/gyrojet
	handle_casings = CLEAR_CASINGS	//the projectile is the casing
	fire_delay = 25
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	mag_insert_sound = 'sound/weapons/guns/interaction/hpistol_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/hpistol_magout.ogg'
	empty_icon = FALSE

/obj/item/gun/projectile/pistol/gyropistol/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "gyropistolloaded"
	else
		icon_state = "gyropistol"
