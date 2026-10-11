/obj/item/gun/energy/laser/xenofauna
	name = "xenofauna carbine"
	desc = "An outdated LP76 energy carbine, repurposed for wildlife control. A safety limiter locks it to a beam capable of frying the nervous system of simple wildlife, but with barely any effect on humans."
	icon = 'code/modules/projectiles/guns/energy/xenofauna/xenofauna.dmi'
	icon_state = "laserwild"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/xenofauna/xenofauna.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/xenofauna/xenofauna.dmi',
	)
	colocated_sprites = TRUE
	item_state = "laserwild"
	projectile_type = /obj/item/projectile/beam/xenofauna
	slot_flags = null
	wielded_item_state = "laserwild-wielded"
	max_shots = 12
	var/emagged = FALSE


/obj/item/gun/energy/laser/xenofauna/emag_act(charges, mob/user)
	if (!charges)
		return NO_EMAG_ACT
	if (emagged)
		to_chat(user, SPAN_NOTICE("\The [src]'s safety limiter has already been disabled!"))
		return NO_EMAG_ACT
	else
		to_chat(user, SPAN_NOTICE("\The [src]'s safety limiter sparks and dies!"))
		projectile_type = /obj/item/projectile/beam/smalllaser
		charge_cost = 30
	return ..()


/obj/item/gun/energy/laser/xenofauna/examine(mob/user, distance)
	. = ..()
	if (emagged && distance < 3)
		to_chat(user, SPAN_DANGER("The safety limiter doesn't look functional."))


/obj/item/gun/energy/laser/xenofauna/broken
	desc = "An outdated LP76 energy carbine, repurposed for wildlife control. This one looks like junk."


/obj/item/gun/energy/laser/xenofauna/broken/Initialize()
	. = ..()
	emag_act(INFINITY)
