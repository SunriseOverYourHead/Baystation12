/obj/item/gun/energy/laser
	name = "laser carbine"
	desc = "A Hephaestus Industries G40E carbine, designed to kill with concentrated energy blasts."
	icon = 'code/modules/projectiles/guns/energy/laser/laser.dmi'
	icon_state = "laser"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/laser/laser.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/laser/laser.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/laser/laser.dmi',
	)
	colocated_sprites = TRUE
	item_state = "laser"
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_LARGE
	force = 10
	one_hand_penalty = 2
	bulk = GUN_BULK_RIFLE
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 2)
	matter = list(MATERIAL_STEEL = 2000)
	projectile_type = /obj/item/projectile/beam/midlaser
	wielded_item_state = "laser-wielded"

/obj/item/gun/energy/laser/mounted
	self_recharge = 1
	use_external_power = 1
	one_hand_penalty = 0 //just in case
	has_safety = FALSE

/obj/item/gun/energy/laser/practice
	name = "practice laser carbine"
	desc = "A modified version of the HI G40E, this one fires less concentrated energy bolts designed for target practice."
	icon_state = "laserp"
	colocated_sprites = FALSE
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/laser/laser.dmi',
	)
	projectile_type = /obj/item/projectile/beam/practice
	charge_cost = 10 //How much energy is needed to fire.

/obj/item/gun/energy/laser/practice/proc/hacked()
	return projectile_type != /obj/item/projectile/beam/practice

/obj/item/gun/energy/laser/practice/emag_act(remaining_charges, mob/user, emag_source)
	if(hacked())
		return NO_EMAG_ACT
	to_chat(user, SPAN_WARNING("You disable the safeties on [src] and crank the output to the lethal levels."))
	desc += " Its safeties are disabled and output is set to dangerous levels."
	projectile_type = /obj/item/projectile/beam/midlaser
	charge_cost = 20
	max_shots = rand(3,6) //will melt down after those
	return 1

/obj/item/gun/energy/laser/practice/handle_post_fire(mob/user, atom/target, pointblank=0, reflex=0)
	..()
	if(hacked())
		max_shots--
		if(!max_shots) //uh hoh gig is up
			to_chat(user, SPAN_DANGER("\The [src] sizzles in your hands, acrid smoke rising from the firing end!"))
			desc += " The optical pathway is melted and useless."
			projectile_type = null
