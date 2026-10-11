/obj/item/gun/energy/captain
	name = "antique laser gun"
	icon = 'code/modules/projectiles/guns/energy/captain/captain.dmi'
	icon_state = "caplaser"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/captain/captain.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/captain/captain.dmi',
	)
	colocated_sprites = TRUE
	item_state = "caplaser"
	desc = "A rare weapon, handcrafted by a now defunct specialty manufacturer on Luna for a small fortune. It's certainly aged well."
	force = 5
	slot_flags = SLOT_BELT //too unusually shaped to fit in a holster
	w_class = ITEM_SIZE_NORMAL
	projectile_type = /obj/item/projectile/beam
	origin_tech = null
	max_shots = 5 //to compensate a bit for self-recharging
	one_hand_penalty = 1 //a little bulky
	self_recharge = 1
