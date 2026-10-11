/obj/item/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An experimental energy projector with a miniature nuclear fission reactor. Various warning labels on it state to keep it away from electromagnetic fields. As if."
	icon = 'code/modules/projectiles/guns/energy/gun_nuclear/gun_nuclear.dmi'
	icon_state = "nucgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/gun_nuclear/gun_nuclear.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/gun_nuclear/gun_nuclear.dmi',
	)
	colocated_sprites = TRUE
	item_state = "nucgun-stun"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 5, TECH_POWER = 3)
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_LARGE
	force = 8 //looks heavier than a pistol
	self_recharge = 1
	modifystate = null
	one_hand_penalty = 1 //bulkier than an e-gun, but not quite the size of a carbine

	firemodes = list(
		list(
			"mode_name" = "stun",
			"projectile_type" = /obj/item/projectile/beam/stun
		),
		list(
			"mode_name" = "shock",
			"projectile_type" = /obj/item/projectile/beam/stun/shock
		),
		list(
			"mode_name" = "kill",
			"projectile_type" = /obj/item/projectile/beam
		)
	)

	var/fail_counter = 0

//override for failcheck behaviour
/obj/item/gun/energy/gun/nuclear/Process()
	if (fail_counter > 0)
		SSradiation.radiate(src, (fail_counter * 2))
		fail_counter--

	return ..()

/obj/item/gun/energy/gun/nuclear/emp_act(severity)
	..()
	switch (severity)
		if (EMP_ACT_HEAVY)
			fail_counter = max(fail_counter, 30)
			visible_message("\The [src]'s reactor overloads!")
		if (EMP_ACT_LIGHT)
			fail_counter = max(fail_counter, 10)
			if (ismob(loc))
				to_chat(loc, SPAN_WARNING("\The [src] feels pleasantly warm."))

/obj/item/gun/energy/gun/nuclear/proc/get_charge_overlay()
	var/power_remaining = power_supply.percent()
	var/datum/firemode/current_mode = firemodes[sel_mode]
	if (power_remaining < 10)
		return "nucgun-deadcharge"
	else
		switch (current_mode.name)
			if ("stun")
				return "nucgun-stuncharge"
			if ("shock")
				return "nucgun-shockcharge"
			if ("kill")
				return "nucgun-killcharge"

/obj/item/gun/energy/gun/nuclear/proc/get_reactor_overlay()
	if (fail_counter)
		return "nucgun-medium"
	if (power_supply.percent() <= 50)
		return "nucgun-light"
	return "nucgun-clean"

/obj/item/gun/energy/gun/nuclear/proc/get_mode_overlay()
	var/datum/firemode/current_mode = firemodes[sel_mode]
	switch (current_mode.name)
		if ("stun")
			return "nucgun-stun"
		if ("shock")
			return "nucgun-shock"
		if ("kill")
			return "nucgun-kill"

/obj/item/gun/energy/gun/nuclear/on_update_icon()
	ClearOverlays()
	AddOverlays(get_charge_overlay())
	AddOverlays(get_reactor_overlay())
	AddOverlays(get_mode_overlay())
	item_state = get_mode_overlay()

	// Safety
	if (ismob(loc))
		var/mob/M = loc
		if (M.skill_check(SKILL_WEAPONS, SKILL_BASIC))
			AddOverlays(image('icons/obj/guns/gui.dmi', "safety[safety()]"))
