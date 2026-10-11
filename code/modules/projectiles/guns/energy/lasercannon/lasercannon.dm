/obj/item/gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the laser cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon100"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/lasercannon/lasercannon.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/lasercannon/lasercannon.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/lasercannon/lasercannon.dmi',
	)
	colocated_sprites = TRUE
	modifystate = "lasercannon"
	icon = 'code/modules/projectiles/guns/energy/lasercannon/lasercannon.dmi'
	item_state = "lasercannon100"
	item_state_slots = list(slot_back_str = "lasercannon100_back")
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 3, TECH_POWER = 3)
	slot_flags = SLOT_BELT|SLOT_BACK
	one_hand_penalty = 6 //large and heavy
	w_class = ITEM_SIZE_HUGE
	projectile_type = /obj/item/projectile/beam/heavylaser
	charge_cost = 40
	max_shots = 6
	accuracy = 2
	fire_delay = 20
	wielded_item_state = "gun_wielded"

/obj/item/gun/energy/lasercannon/mounted
	name = "mounted laser cannon"
	self_recharge = 1
	use_external_power = 1
	recharge_time = 10
	accuracy = 0 //mounted laser cannons don't need any help, thanks
	one_hand_penalty = 0
	has_safety = FALSE
