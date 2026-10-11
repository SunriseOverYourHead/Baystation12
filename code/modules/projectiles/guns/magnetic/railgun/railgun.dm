/obj/item/gun/magnetic/railgun
	abstract_type = /obj/item/gun/magnetic/railgun
	name = "master railgun object"
	desc = "You should not see this."

	var/slowdown_held = 2
	var/slowdown_worn = 1

	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	bulk = GUN_BULK_RIFLE + 3
	icon = 'code/modules/projectiles/guns/magnetic/railgun/railgun.dmi'
	icon_state = "railgun"
	has_magnetic_overlays = FALSE
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/railgun.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/railgun.dmi',
		slot_back_str = 'code/modules/projectiles/guns/magnetic/railgun/railgun.dmi',
	)
	item_state = "railgun"

	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 4, TECH_MAGNET = 4)

	cell = /obj/item/cell/hyper
	capacitor = /obj/item/stock_parts/capacitor/adv
	projectile_type = /obj/item/projectile/bullet/magnetic/slug
	load_type = /obj/item/rcd_ammo
	loaded = /obj/item/rcd_ammo/large // ~30 shots
	one_hand_penalty = 6
	power_cost = 300
	fire_delay = 35
	gun_unreliable = 0


/obj/item/gun/magnetic/railgun/Initialize()
	slowdown_per_slot[slot_l_hand] =  slowdown_held
	slowdown_per_slot[slot_r_hand] =  slowdown_held
	slowdown_per_slot[slot_back] =    slowdown_worn
	slowdown_per_slot[slot_belt] =    slowdown_worn
	slowdown_per_slot[slot_s_store] = slowdown_worn

	. = ..()


// Not going to check type repeatedly, if you code or varedit
// load_type and get runtime errors, don't come crying to me.
/obj/item/gun/magnetic/railgun/show_ammo(mob/user)
	var/obj/item/rcd_ammo/ammo = loaded
	if (ammo)
		to_chat(user, SPAN_NOTICE("There are [ammo.remaining] shot\s remaining in \the [loaded]."))
	else
		to_chat(user, SPAN_NOTICE("There is nothing loaded."))


/obj/item/gun/magnetic/railgun/check_ammo()
	var/obj/item/rcd_ammo/ammo = loaded
	return ammo && ammo.remaining


/obj/item/gun/magnetic/railgun/use_ammo()
	var/obj/item/rcd_ammo/ammo = loaded
	ammo.remaining--
	if(ammo.remaining <= 0)
		spawn(3)
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
		out_of_ammo()


/obj/item/gun/magnetic/railgun/proc/out_of_ammo()
	qdel(loaded)
	loaded = null
	visible_message(SPAN_WARNING("\The [src] beeps and ejects its empty cartridge."))


/obj/item/gun/magnetic/railgun/thunderclap
	name = "railgun"
	desc = "The HelTek Arms LM-76 'Thunderclap'. A portable linear motor cannon produced during the Gaia Conflict for anti-armour and \
			anti-fortification operations. Today, it sees wide use among private militaries, and is a staple on the black market."
