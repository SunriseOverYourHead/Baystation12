/obj/item/gun/magnetic/railgun/automatic // Adminspawn only, this shit is absurd.
	name = "\improper LM-RA autocannon"
	desc = "The HelTek Arms LM-RA/14A 'Meteor'. A vehicle-mounted turret weapon for anti-armour targets. \
			Originally, a Terran Commonwealth design. The fact that it was made man-portable is mindboggling in itself."

	icon = 'code/modules/projectiles/guns/magnetic/railgun/automatic/automatic.dmi'
	icon_state = "heavy_railgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/automatic/automatic.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/automatic/automatic.dmi',
		slot_back_str = 'code/modules/projectiles/guns/magnetic/railgun/automatic/automatic.dmi',
	)
	item_state = "heavy_railgun"

	w_class = ITEM_SIZE_NO_CONTAINER
	removable_components = FALSE // Absolutely not. This has an infinity cell.

	cell = /obj/item/cell/infinite
	capacitor = /obj/item/stock_parts/capacitor/super
	fire_delay =  8

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
		),
		list(
			"mode_name" = "long bursts",
			"burst" = 6,
			"fire_delay" = null,
			"move_delay" = 10,
			"one_hand_penalty" = 2,
			"burst_accuracy" = list(0, -1, -1, -1, -2),
			"dispersion" = list(0.6, 0.6, 1.0, 1.0, 1.2)
		)
	)
	var/verse

/obj/item/gun/magnetic/railgun/automatic/Initialize()
	. = ..()
	verse = pick(list(
		"Ultima Ratio Regnum",
		"Ad Finem Amarum",
		"Unum Ultimum Proelium"
	))

/obj/item/gun/magnetic/railgun/automatic/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		to_chat(user, SPAN_NOTICE("Someone has scratched <i>[verse]</i> onto the side of the barrel."))


/obj/item/gun/magnetic/railgun/automatic/halberd
	name = "\improper RHR accelerator"
	desc = "The Hephaestus Industries RG-3 'Halberd'. A vehicle-mounted turret weapon for anti-armour targets. \
			Originally, a Terran Commonwealth design. The fact that it was made man-portable is mindboggling in itself."
	icon = 'code/modules/projectiles/guns/magnetic/railgun/automatic/halberd.dmi'
	icon_state = "old_heavy_railgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/automatic/halberd.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/automatic/halberd.dmi',
		slot_back_str = 'code/modules/projectiles/guns/magnetic/railgun/automatic/halberd.dmi',
	)
	item_state = "old_heavy_railgun"

/obj/item/gun/magnetic/railgun/automatic/halberd/Initialize()
	. = ..()
	verse = pick(list(
		"For Those Who Fell Before Us",
		"Peace on Earth + Mars",
		"Death From Below",
		"Thunder Magic Spoke",
		"NAME_HERE FROM HELLSHEN",
		"NAME_HERE FROM GIDEONSBURG",
		"Thor's Hammer"
	))
	var/name = random_name(prob(50) ? MALE : FEMALE, SPECIES_HUMAN)
	verse = replacetext(verse, "NAME_HERE", uppertext(name))
