/obj/item/gun/magnetic/railgun/flechette
	name = "flechette gun"
	desc = "The 'Skadi' is a burst fire capable railgun that fires flechette rounds at high velocity. \
			Deadly against armour, but much less effective against soft targets. A dreamt-up prototype."

	icon = 'code/modules/projectiles/guns/magnetic/railgun/flechette/flechette.dmi'
	icon_state = "flechette_gun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/flechette/flechette.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/flechette/flechette.dmi',
	)
	colocated_sprites = TRUE
	item_state = "z8carbine"
	wielded_item_state = "z8carbine-wielded"
	has_magnetic_overlays = FALSE

	cell = /obj/item/cell/hyper
	capacitor = /obj/item/stock_parts/capacitor/adv
	load_type = /obj/item/magnetic_ammo
	projectile_type = /obj/item/projectile/bullet/magnetic/flechette
	loaded = /obj/item/magnetic_ammo
	one_hand_penalty = 2
	fire_delay = 8
	power_cost = 100

	firemodes = list(
		list(
			"mode_name" = "semiauto",
			"burst" = 1,
			"fire_delay" = 0,
			"move_delay" = null,
			"one_hand_penalty" = 1,
			"burst_accuracy" = null,
			"dispersion" = null
		),
		list(
			"mode_name" = "short bursts",
			"burst" = 3,
			"fire_delay" = null,
			"move_delay" = 5,
			"one_hand_penalty" = 2,
			"burst_accuracy" = list(0, -1, -1),
			"dispersion" = list(0.0, 0.6, 1.0)
		)
	)


/obj/item/gun/magnetic/railgun/flechette/out_of_ammo()
	visible_message(SPAN_WARNING("\The [src] beeps to indicate the magazine is empty."))


/obj/item/gun/magnetic/railgun/flechette/skrell
	name = "skrellian rifle"
	desc = "The Zquiv*Tzuuli-8, or ZT-8, is a railgun rarely seen by anyone other than those within Skrellian SDTF ranks. \
			The rotary magazine houses a cylinder with individual chambers, that press against the barrel when loaded."

	icon = 'code/modules/projectiles/guns/magnetic/railgun/flechette/skrell.dmi'
	icon_state = "skrell_rifle"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/flechette/skrell.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/flechette/skrell.dmi',
	)
	colocated_sprites = TRUE
	item_state = "skrell_rifle"

	removable_components = FALSE

	cell = /obj/item/cell/hyper
	capacitor = /obj/item/stock_parts/capacitor/adv
	load_type = /obj/item/magnetic_ammo/skrell
	loaded = /obj/item/magnetic_ammo/skrell/slug
	projectile_type = /obj/item/projectile/bullet/magnetic/slug
	one_hand_penalty = 3
	fire_delay = 10
	slowdown_held = 1
	power_cost = 100

	firemodes = list()

/obj/item/gun/magnetic/railgun/flechette/skrell/vesta
	name = "ZT-8 rifle"
	desc = "The Zquiv*Tzuuli-8, or ZT-8, is a railgun rarely seen by anyone other than those within Skrellian SDTF ranks. The rotary magazine houses a cylinder with individual chambers, that press against the barrel when loaded."