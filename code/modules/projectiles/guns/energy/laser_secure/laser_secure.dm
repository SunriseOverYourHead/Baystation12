/obj/item/gun/energy/laser/secure
	name = "laser carbine"
	desc = "A Hephaestus Industries G40E carbine, designed to kill with concentrated energy blasts. Fitted with an NT1019 chip to make sure killcount is tracked appropriately."
	icon = 'code/modules/projectiles/guns/energy/laser_secure/laser_secure.dmi'
	icon_state = "lasersec"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/laser_secure/laser_secure.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/laser_secure/laser_secure.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/laser_secure/laser_secure.dmi',
	)
	item_state = "lasersec"
	req_access = list(list(access_brig, access_bridge))
