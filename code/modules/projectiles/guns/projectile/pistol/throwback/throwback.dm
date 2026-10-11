/obj/item/gun/projectile/pistol/throwback
	name = "pistol"
	desc = "A product of one of thousands of illegal workshops from around the galaxy. This one appears to be a clone of a 20th century design."
	icon = 'code/modules/projectiles/guns/projectile/pistol/throwback/throwback.dmi'
	icon_state = "pistol1"
	magazine_type = /obj/item/ammo_magazine/pistol/throwback
	accuracy_power = 5
	one_hand_penalty = 2
	fire_delay = 7
	caliber = PROJECTILE_PISTOL_ANTIQUE
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	var/base_icon = "pistol1"

/obj/item/gun/projectile/pistol/throwback/Initialize()
	. = ..()
	base_icon = "pistol[rand(1,4)]"
	update_icon()

/obj/item/gun/projectile/pistol/throwback/on_update_icon()
	..()
	if(ammo_magazine && length(ammo_magazine.stored_ammo))
		icon_state = base_icon
	else
		icon_state = "[base_icon]-e"
