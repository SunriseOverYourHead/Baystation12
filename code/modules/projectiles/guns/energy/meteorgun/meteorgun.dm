/obj/item/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon = 'code/modules/projectiles/guns/energy/meteorgun/meteorgun.dmi'
	icon_state = "riotgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/meteorgun/meteorgun.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/meteorgun/meteorgun.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/meteorgun/meteorgun.dmi',
	)
	colocated_sprites = TRUE
	item_state = "c20r"
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_HUGE
	projectile_type = /obj/item/projectile/meteor
	cell_type = /obj/item/cell/potato
	self_recharge = 1
	recharge_time = 5 //Time it takes for shots to recharge (in ticks)
	charge_meter = 0
	combustion = 0

/obj/item/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_BELT
