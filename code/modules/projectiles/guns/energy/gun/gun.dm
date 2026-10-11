/obj/item/gun/energy/gun
	name = "energy gun"
	desc = "Another bestseller of Lawson Arms and the FTU, the LAEP90 Perun is a versatile energy based sidearm, capable of switching between low, medium and high power projectile settings. In other words: stun, shock or kill."
	icon = 'code/modules/projectiles/guns/energy/gun/gun.dmi'
	icon_state = "energystun100"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/gun/gun.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/gun/gun.dmi',
	)
	colocated_sprites = TRUE
	item_state = null	//so the human update icon uses the icon_state instead.
	max_shots = 10
	fire_delay = 10 // To balance for the fact that it is a pistol and can be used one-handed without penalty

	projectile_type = /obj/item/projectile/beam/stun
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	modifystate = "energystun"

	firemodes = list(
		list(
			"mode_name" = "stun",
			"projectile_type" = /obj/item/projectile/beam/stun,
			"modifystate" = "energystun"
		),
		list(
			"mode_name" = "shock",
			"projectile_type" = /obj/item/projectile/beam/stun/shock,
			"modifystate" = "energyshock"
		),
		list(
			"mode_name" = "kill",
			"projectile_type" = /obj/item/projectile/beam,
			"modifystate" = "energykill"
		)
	)

/obj/item/gun/energy/gun/skrell
	name = "skrellian handgun"
	desc = "A common Skrellian side-arm, the Xuxquu*'Voom-5, or XV-5, is a more traditional energy weapon, tuned to dispense beams in three different wavelengths."
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	icon = 'code/modules/projectiles/guns/energy/gun/gun_skrell.dmi'
	icon_state = "skrell_pistol_stun100"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/gun/gun_skrell.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/gun/gun_skrell.dmi',
	)
	colocated_sprites = TRUE
	max_shots = 10
	fire_delay = 6
	one_hand_penalty = 1
	self_recharge = 1

	projectile_type = /obj/item/projectile/beam/stun
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 5, TECH_POWER = 3)
	modifystate = "skrell_pistol_stun"

	firemodes = list(
		list(
			"mode_name" = "stun",
			"projectile_type" = /obj/item/projectile/beam/stun,
			"modifystate" = "skrell_pistol_stun"
		),
		list(
			"mode_name" = "shock",
			"projectile_type" = /obj/item/projectile/beam/stun/shock,
			"modifystate" = "skrell_pistol_shock"
		),
		list(
			"mode_name" = "kill",
			"projectile_type" = /obj/item/projectile/beam,
			"modifystate" = "skrell_pistol_kill"
		)
	)

/obj/item/gun/energy/gun/skrell/on_update_icon()
	..()
	var/mob/living/M = loc
	if(istype(M))
		item_state_slots[slot_l_hand_str] = "[modifystate]_l"
		item_state_slots[slot_r_hand_str] = "[modifystate]_r"

/obj/item/gun/energy/gun/small
	name = "small energy gun"
	desc = "A smaller model of the versatile LAEP90 Perun, the LAEP90-C packs considerable utility in a smaller package. Best used in situations where full-sized sidearms are inappropriate."
	icon = 'code/modules/projectiles/guns/energy/gun/gun_small.dmi'
	icon_state = "smallgunstun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/gun/gun_small.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/gun/gun_small.dmi',
	)
	colocated_sprites = FALSE
	max_shots = 6
	w_class = ITEM_SIZE_SMALL
	force = 2 //it's the size of a car key, what did you expect?
	modifystate = "smallgunstun"

	firemodes = list(
		list(
			"mode_name" = "stun",
			"projectile_type" = /obj/item/projectile/beam/stun/smalllaser,
			"modifystate" = "smallgunstun"
		),
		list(
			"mode_name" = "shock",
			"projectile_type" = /obj/item/projectile/beam/stun/shock/smalllaser,
			"modifystate" = "smallgunshock"
		),
		list(
			"mode_name" = "kill",
			"projectile_type" = /obj/item/projectile/beam/smalllaser,
			"modifystate" = "smallgunkill"
		)
	)

/obj/item/gun/energy/gun/mounted
	name = "mounted energy gun"
	self_recharge = 1
	use_external_power = 1
	has_safety = FALSE

/obj/item/gun/energy/gun/skrell/vesta
	name = "XV-5 handgun"