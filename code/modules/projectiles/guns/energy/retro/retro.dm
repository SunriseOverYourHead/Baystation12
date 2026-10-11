/obj/item/gun/energy/retro
	name = "retro laser"
	icon = 'code/modules/projectiles/guns/energy/retro/retro.dmi'
	icon_state = "retro"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/retro/retro.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/retro/retro.dmi',
	)
	colocated_sprites = TRUE
	item_state = "retro"
	desc = "An older model of the basic lasergun. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	w_class = ITEM_SIZE_NORMAL
	projectile_type = /obj/item/projectile/beam
	fire_delay = 15 //old technology, and a pistol
