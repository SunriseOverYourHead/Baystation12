/obj/item/gun/magnetic/railgun/tc
	name = "advanced railgun"
	desc = "The Mars Military Industries MI-2k2 'Hammerhead'. A man-portable helical rail cannon. \
			Adopted in the times of the Terran Commonwealth, during the Ares Conflict. A lost relic of tumultuous times."

	icon = 'code/modules/projectiles/guns/magnetic/railgun/tc/tc.dmi'
	icon_state = "railgun-tcc"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/tc/tc.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/magnetic/railgun/tc/tc.dmi',
		slot_back_str = 'code/modules/projectiles/guns/magnetic/railgun/tc/tc.dmi',
	)
	item_state = "railgun-tcc"

	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 3, TECH_MAGNET = 5)

	loaded = /obj/item/stack/material/rods
	load_type = /obj/item/stack/material/rods // The Confederation learned that chunks of metal work just as well as fancy matter cartridges - actually they dont
	projectile_type = /obj/item/projectile/bullet/magnetic
	power_cost = 280 // Same number of shots, but it'll seem to recharge slightly faster
	load_sheet_max = 6 // Fewer shots per "magazine", but more abundant than matter cartridges.
	slowdown_worn = 3 // Little slower when worn


/obj/item/gun/magnetic/railgun/tc/show_ammo(mob/user)
	var/obj/item/stack/material/rods/ammo = loaded
	if(istype(ammo))
		to_chat(user, SPAN_NOTICE("It has [ammo.amount] shots loaded."))


/obj/item/gun/magnetic/railgun/tc/check_ammo()
	var/obj/item/stack/material/rods/ammo = loaded
	return ammo && ammo.amount


/obj/item/gun/magnetic/railgun/tc/out_of_ammo()
	QDEL_NULL(loaded)
	loaded = null
	spawn(3)
		playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
	visible_message(SPAN_WARNING("\The [src] beeps, before clanging as the ammunition bank resets."))


/obj/item/gun/magnetic/railgun/tc/use_ammo()
	var/obj/item/stack/material/rods/ammo = loaded
	ammo.use(1)
	if(!istype(ammo) || ammo.amount < 1)
		out_of_ammo()
