/obj/item/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon = 'code/modules/projectiles/guns/energy/decloner/decloner.dmi'
	icon_state = "decloner"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/decloner/decloner.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/decloner/decloner.dmi',
	)
	colocated_sprites = TRUE
	item_state = "decloner"
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 4, TECH_POWER = 3)
	max_shots = 10
	projectile_type = /obj/item/projectile/energy/declone
	combustion = 0
