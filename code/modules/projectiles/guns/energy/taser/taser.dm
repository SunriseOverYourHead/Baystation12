/obj/item/gun/energy/taser
	name = "electrolaser"
	desc = "The NT Mk30 NL is a small, low capacity gun used for non-lethal takedowns. Produced by NT, it's actually a licensed version of a W-T design. It can switch between high and low intensity stun shots."
	icon = 'code/modules/projectiles/guns/energy/taser/taser.dmi'
	icon_state = "taser"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/taser/taser.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/taser/taser.dmi',
	)
	colocated_sprites = TRUE
	item_state = null	//so the human update icon uses the icon_state instead.
	max_shots = 5
	projectile_type = /obj/item/projectile/beam/stun
	combustion = 0

	firemodes = list(
		list(
			"mode_name" = "stun",
			"projectile_type" = /obj/item/projectile/beam/stun
		),
		list(
			"mode_name" = "shock",
			"projectile_type" = /obj/item/projectile/beam/stun/shock
		)
	)

/obj/item/gun/energy/taser/disposable
	name = "disposable electrolaser"
	desc = "The NT Mk30 NL is a small, disposable gun used for non-lethal takedowns. This is a cheaper model commonly issued to police forces to supplement their service weapons. It can switch between high and low intensity stun shots."
	max_shots = 10
	disposable = TRUE

/obj/item/gun/energy/taser/mounted
	name = "mounted electrolaser"
	self_recharge = 1
	use_external_power = 1
	has_safety = FALSE

/obj/item/gun/energy/taser/mounted/cyborg
	name = "electrolaser"
	max_shots = 6
	recharge_time = 10 //Time it takes for shots to recharge (in ticks)
