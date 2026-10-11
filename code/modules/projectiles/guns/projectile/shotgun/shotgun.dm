/obj/item/gun/projectile/shotgun
	abstract_type = /obj/item/gun/projectile/shotgun
	name = "master shotgun object"
	desc = "You should not see this."
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'

/obj/item/gun/projectile/shotgun/on_update_icon()
	..()
	if(length(loaded))
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-empty"
