/obj/item/gun/energy/revolver/secure
	name = "smart service revolver"
	desc = "The LAER680-S, a standard issue service revolver commonly used by higher ranking offcers among the SCG. Fitted with an NT1019 chip which allows remote authorization of the weapon's functionality."
	icon = 'code/modules/projectiles/guns/energy/revolver/revolver_secure.dmi'
	icon_state = "energyrevolverstun100"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns_secure.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns_secure.dmi',
		)
	modifystate = "energyrevolverstun"
	item_state = null
	projectile_type = /obj/item/projectile/beam/stun
	firemodes = list(
		list(
			"mode_name" = "stun",
			"projectile_type" = /obj/item/projectile/beam/stun,
			"modifystate" = "energyrevolverstun"
		),
		list(
			"mode_name" = "shock",
			"projectile_type" = /obj/item/projectile/beam/stun/shock,
			"modifystate" = "energyrevolvershock"
		),
		list(
			"mode_name" = "kill",
			"projectile_type" = /obj/item/projectile/beam,
			"modifystate" = "energyrevolverkill"
		)
	)
	req_access = list(list(access_brig, access_heads))
	authorized_modes = list(ALWAYS_AUTHORIZED, AUTHORIZED)

/obj/item/gun/energy/revolver/secure/preauthorized
	authorized_modes = list(ALWAYS_AUTHORIZED, AUTHORIZED, AUTHORIZED)
