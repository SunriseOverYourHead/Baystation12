/obj/item/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A custom-built weapon of some kind."
	icon = 'code/modules/projectiles/guns/energy/mindflayer/mindflayer.dmi'
	icon_state = "xray"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/mindflayer/mindflayer.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/mindflayer/mindflayer.dmi',
	)
	colocated_sprites = TRUE
	origin_tech = list(TECH_COMBAT = 5, TECH_MAGNET = 4)
	projectile_type = /obj/item/projectile/beam/mindflayer
