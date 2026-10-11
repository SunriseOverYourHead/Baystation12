/obj/item/gun/energy/incendiary_laser
	name = "dispersive blaster"
	desc = "The A&M 'Shayatin' was the first of a class of dispersive laser weapons which, instead of firing a focused beam, scan over a target rapidly with the goal of setting it ablaze."
	icon = 'code/modules/projectiles/guns/energy/incendiary_laser/incendiary_laser.dmi'
	icon_state = "incen"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/incendiary_laser/incendiary_laser.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/incendiary_laser/incendiary_laser.dmi',
	)
	colocated_sprites = TRUE
	item_state = "incen"
	origin_tech = list(TECH_COMBAT = 7, TECH_MAGNET = 4, TECH_ESOTERIC = 4)
	matter = list(MATERIAL_ALUMINIUM = 1000, MATERIAL_PLASTIC = 500, MATERIAL_DIAMOND = 500)
	projectile_type = /obj/item/projectile/beam/incendiary_laser
	max_shots = 4
