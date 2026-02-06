/*

SCG Weapons

*/


/*
 ###    Pistols    ###
*/

/obj/item/gun/projectile/pistol/m22f
	name = "M22 military pistol"
	desc = "A Hephaestus Industries M22F. A 10mm pistol issued as an SCG service weapon."
	magazine_type = /obj/item/ammo_magazine/pistol/double
	allowed_magazines = /obj/item/ammo_magazine/pistol/double
	icon = 'maps/torch/icons/obj/extraguns/m22f.dmi'
	icon_state = "m22f"
	item_state = "m22f"
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 2)
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/m22f.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/m22f.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "m22f-wielded-r",
		slot_l_hand_str = "m22f-wielded-l"
	)
	fire_delay = 3
	ammo_indicator = FALSE

/obj/item/gun/projectile/pistol/m22f/empty
	starts_loaded = FALSE

/obj/item/gun/projectile/pistol/m19
	name = "M19 military pistol"
	desc = "A Hephaestus Industries M19. A 9mm pistol issued as an SCG service weapon."
	magazine_type = /obj/item/ammo_magazine/pistol
	allowed_magazines = /obj/item/ammo_magazine/pistol
	banned_magazines = list(
		/obj/item/ammo_magazine/pistol/double,
		/obj/item/ammo_magazine/pistol/small
	)
	icon = 'maps/torch/icons/obj/extraguns/m19.dmi'
	icon_state = "m19"
	item_state = "m19"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/m19.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/m19.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "m19-wielded-r",
		slot_l_hand_str = "m19-wielded-l"
	)
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	fire_delay = 2

/obj/item/gun/projectile/pistol/m19/empty
	starts_loaded = FALSE

/obj/item/gun/projectile/revolver/m55
	name = "M55 military revolver"
	desc = "The Hephaestus Industries M55. A hard-hitting .44 revolver issued as an SCG service weapon."
	caliber = PROJECTILE_PISTOL_HUGE
	ammo_type = /obj/item/ammo_casing/pistol/huge
	icon = 'maps/torch/icons/obj/extraguns/m55.dmi'
	icon_state = "m55"
	item_state = "m55"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/m55.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/m55.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "m55-wielded-r",
		slot_l_hand_str = "m55-wielded-l"
	)
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	accuracy = 1
	bulk = 0
	fire_delay = 3

/obj/item/gun/projectile/revolver/m55/empty
	starts_loaded = FALSE

/obj/item/gun/projectile/pistol/m25
	name = "M25 military pistol"
	desc = "A Hephaestus Industries M25. A hulking, formidable pistol chambered in .50 AE. Undergoing limited field testing as a replacement for the older M19 and M22 pistols."
	magazine_type = /obj/item/ammo_magazine/pistol
	allowed_magazines = /obj/item/ammo_magazine/pistol
	banned_magazines = list(
		/obj/item/ammo_magazine/pistol/double,
		/obj/item/ammo_magazine/pistol/small
	)
	icon = 'maps/torch/icons/obj/extraguns/m25.dmi'
	icon_state = "m25"
	item_state = "m25"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/m25.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/m25.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "m25-wielded-r",
		slot_l_hand_str = "m25-wielded-l"
	)
	caliber = PROJECTILE_PISTOL_MASSIVE
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	fire_delay = 4

/obj/item/gun/projectile/pistol/m25/empty
	starts_loaded = FALSE
/*
 ###    SMGs    ###
*/

/obj/item/gun/projectile/automatic/mp24
	name = "MP24 submachinegun"
	desc = "The Hephaestus Industries MP24 'Spectre'. Often seen in the hands of light infantry, medics and combat engineers. Struggles against body armor without the appropriate ammo."
	icon = 'maps/torch/icons/obj/extraguns/mp24.dmi'
	icon_state = "mp24"
	item_state = "mp24"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/mp24.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/mp24.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/mp24.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/mp24.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "mp24-wielded-r",
		slot_l_hand_str = "mp24-wielded-l",
		slot_back_str = "onsuit",
		slot_s_store_str = "onsuit"
	)
	var/empty_icon = TRUE
	caliber = PROJECTILE_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 3)
	burst_delay = 0.5
	ammo_type = /obj/item/ammo_casing/pistol
	magazine_type = /obj/item/ammo_magazine/machine_pistol
	allowed_magazines = /obj/item/ammo_magazine/machine_pistol
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	one_hand_penalty = 2

	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = 0.2,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0),
			"dispersion" = list(0.0, 0.1)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, 0, -0.5, -0.5, -1),
			"dispersion" = list(0, 0, 0, 0.1)
		),
	)

/obj/item/gun/projectile/automatic/mp24/on_update_icon()
	..()
	if(empty_icon)
		if(ammo_magazine && length(ammo_magazine.stored_ammo))
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)]-e"

// /obj/item/gun/projectile/automatic/mp24/on_update_icon()
// 	..()
// 	icon_state = "mp24"
// 	if(ammo_magazine)
// 		AddOverlays(image(icon, "mag"))

// 	if(!ammo_magazine || !LAZYLEN(ammo_magazine.stored_ammo))
// 		icon_state = "mpistolen-empty"
// 		AddOverlays(image(icon, "[initial(icon_state)]-ammo0"))
// 	else if(LAZYLEN(ammo_magazine.stored_ammo) <= 0.5 * ammo_magazine.max_ammo)
// 		AddOverlays(image(icon, "[initial(icon_state)]-ammo1"))
// 	else
// 		AddOverlays(image(icon, "[initial(icon_state)]-ammo2"))


/obj/item/gun/projectile/automatic/mp85
	name = "MP85 PDW"
	desc = "The Ward-Takahashi MP85 'Ghost' personal defense weapon. Recently adopted by the SCG for support personnel."
	icon = 'maps/torch/icons/obj/extraguns/mp85.dmi'
	icon_state = "mp85"
	item_state = "mp85"
	item_state_slots = list(
		slot_r_hand_str = "mp85-wielded-r",
		slot_l_hand_str = "mp85-wielded-l"
	)
	var/empty_icon = TRUE
	caliber = PROJECTILE_PISTOL_SMALL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 3)
	burst_delay = 0.5
	ammo_type = /obj/item/ammo_casing/pistol
	magazine_type = /obj/item/ammo_magazine/machine_pistol
	allowed_magazines = /obj/item/ammo_magazine/machine_pistol
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	one_hand_penalty = 2

	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = 0.2,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0),
			"dispersion" = list(0.0, 0.1)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.1,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, 0, -0.5, -0.5, -1),
			"dispersion" = list(0, 0, 0, 0.1)
		),
	)

/obj/item/gun/projectile/automatic/mp85/on_update_icon()
	..()
	if(empty_icon)
		if(ammo_magazine && length(ammo_magazine.stored_ammo))
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)]-e"
/*
 ###    Intermed. Rifles    ###
*/

/obj/item/gun/projectile/automatic/z8
	name = "Z8-C assault rifle"
	desc = "The Hephaestus Industries Z8-C 'Bulldog' is one of the oldest weapons currently in service with the SCG. Despite its age, it still remains the de-facto rifle of the SCG Army due to its ease of handling, cheap production costs, reliability, and plentiful surplus stock."
	icon = 'maps/torch/icons/obj/extraguns/Z8.dmi'
	icon_state = "z8"
	item_state = "z8"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z8.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z8.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z8.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z8.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z8-wielded-r",
		slot_l_hand_str = "z8-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	var/magazine_state = "_mag35"
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = PROJECTILE_RIFLE_INTERMEDIATE
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 3)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	ammo_type = /obj/item/ammo_casing/rifle/intermediate
	magazine_type = /obj/item/ammo_magazine/mil_rifle/heavy
	allowed_magazines = /obj/item/ammo_magazine/mil_rifle //Interchangable but poor performance
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	accuracy = 2
	accuracy_power = 7
	one_hand_penalty = 8
	bulk = GUN_BULK_RIFLE
	burst_delay = 1.5
	mag_insert_sound = 'sound/weapons/guns/interaction/batrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/batrifle_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot2.ogg'
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = 0.2,
			"burst_delay" = 1.3,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0),
			"dispersion" = list(0.0, 0.1)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"move_delay" = 0.5,
			"burst_delay" = 3,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, 0, -0.5, -0.5, -1),
			"dispersion" = list(0, 0, 0, 0.1)
		),
		list(
			"mode_name" = "fire grenades",
			"burst" = null,
			"fire_delay" = null,
			"move_delay" = null,
			"use_launcher" = 1,
			"one_hand_penalty" = 10,
			"burst_accuracy" = null,
			"dispersion" = null
		)
	)

	var/use_launcher = 0

	///Determines if bullpup spawns with launcher, used in Initialize()
	var/has_launcher = TRUE
	var/obj/item/gun/launcher/grenade/underslung/launcher

/obj/item/gun/projectile/automatic/z8/Initialize()
	. = ..()
	if (has_launcher)
		launcher = new(src)


/obj/item/gun/projectile/automatic/z8/use_tool(obj/item/tool, mob/user, list/click_params)
	// Grenade - Load launcher
	if (istype(tool, /obj/item/grenade) && launcher)
		launcher.load(tool, user)
		return TRUE

	return ..()

/obj/item/gun/projectile/automatic/z8/toggle_safety(mob/user)
	..()
	if(launcher)
		launcher.safety_state = safety_state //Set the launcher's safety to be equivalent to the bullpup's.

/obj/item/gun/projectile/automatic/z8/attack_hand(mob/user)
	if(user.get_inactive_hand() == src && launcher && use_launcher)
		launcher.unload(user)
	else
		..()

/obj/item/gun/projectile/automatic/z8/Fire(atom/target, mob/living/user, params, pointblank=0, reflex=0)
	if(launcher && use_launcher)
		launcher.Fire(target, user, params, pointblank, reflex)
		if(!launcher.chambered)
			switch_firemodes() //switch back automatically
	else
		..()

/obj/item/gun/projectile/automatic/z8/on_update_icon()
	..()
	if(ammo_magazine)
		if(length(ammo_magazine.stored_ammo))
			icon_state = "[item_state]-loaded"
		else
			icon_state = "[item_state]-empty"
	else
		icon_state = "[item_state]"

/obj/item/gun/projectile/automatic/z8/examine(mob/user)
	. = ..()
	if(!launcher)
		return
	if(launcher.chambered)
		to_chat(user, "\The [launcher] has \a [launcher.chambered] loaded.")
	else
		to_chat(user, "\The [launcher] is empty.")

/obj/item/gun/projectile/automatic/z8/on_update_icon()
	..()

	var/mob/living/M = loc
	var/is_empty = !ammo_magazine || !length(ammo_magazine.stored_ammo)
	var/has_mag = ammo_magazine ? TRUE : FALSE

	if(is_empty)
		icon_state = "[initial(item_state)]-e"
	else
		icon_state = initial(item_state)

	if(istype(M))
		var/is_left_hand = (M.l_hand == src)
		var/is_right_hand = (M.r_hand == src)
		var/other_hand_free = FALSE

		if(is_left_hand)
			other_hand_free = !M.r_hand
		else if(is_right_hand)
			other_hand_free = !M.l_hand

		if((is_left_hand || is_right_hand) && other_hand_free && M.can_wield_item(src))
			if(is_empty)
				item_state_slots[slot_l_hand_str] = "[initial(item_state)]-empty-wielded-l"
				item_state_slots[slot_r_hand_str] = "[initial(item_state)]-empty-wielded-r"
			else
				item_state_slots[slot_l_hand_str] = "[initial(item_state)]-wielded-l"
				item_state_slots[slot_r_hand_str] = "[initial(item_state)]-wielded-r"

		else if(is_left_hand || is_right_hand)
			item_state_slots[slot_l_hand_str] = "[initial(item_state)]-l"
			item_state_slots[slot_r_hand_str] = "[initial(item_state)]-r"

	if(has_mag)
		item_state_slots[slot_s_store_str] = "onsuit_mag"
		item_state_slots[slot_back_str] = "back_mag"
	else
		item_state_slots[slot_s_store_str] = "onsuit"
		item_state_slots[slot_back_str] = "back"

	if(has_mag)
		AddOverlays(image(icon, "[magazine_state]"))

/obj/item/gun/projectile/automatic/z8/z9
	name = "Z9-C bullpup carbine"
	desc = "The standard-issue rifle of the SCG. The Hephaestus Industries Z9-C 'Pitbull' is the modern answer to violence's question. It has been given a blued finish with a Sol yellow stripe for easy identification of its owner."
	icon = 'maps/torch/icons/obj/extraguns/Z9C.dmi'
	icon_state = "z9c"
	item_state = "z9c"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z9C.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z9C.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z9C.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z9C.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z9c-wielded-r",
		slot_l_hand_str = "z9c-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag35"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 6 //Slightly lighter than the Z8. Still don't try it.
	bulk = GUN_BULK_LIGHT_RIFLE
	has_launcher = FALSE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/obj/item/gun/projectile/automatic/z8/z10
	name = "Z10-A 'Rottweiler' assault rifle"
	desc = "The Hephaestus Industries Z10-A 'Rottweiler' is an assault rifle in service with the SCG. Chambered in 8.6x43mm cartridges, it's an alternative firearm offered to riflemen of the SCG defense forces."
	icon = 'maps/torch/icons/obj/extraguns/Z10A.dmi'
	icon_state = "z10a"
	item_state = "z10a"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z10A.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z10A.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z10A.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z10A.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z10a-wielded-r",
		slot_l_hand_str = "z10a-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag20"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)


/obj/item/gun/projectile/automatic/z8/z9e
	name = "Z9-E SOCOM bullpup rifle"
	desc = "The Hephaestus Industries Z9-E SOCOM is a conversion of the Z9-C 'Pitbull'. It uses a modified upper receiver which allows it to take the formidable 11.6x57mm cartridge."
	icon = 'maps/torch/icons/obj/extraguns/Z9E.dmi'
	icon_state = "z9e"
	item_state = "z9e"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z9E.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z9E.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z9E.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z9E.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z9e-wielded-r",
		slot_l_hand_str = "z9e-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag15"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/*
 ###    Full Rifles    ###
*/

/obj/item/gun/projectile/automatic/z8/d
	name = "Z8-D marksman rifle"
	desc = "The Hephaestus Industries Z8-D 'Barghest' is a bullpup marksman rifle in service with the SCG. It takes the longer 6.5x59mm cartridge."
	icon = 'maps/torch/icons/obj/extraguns/Z8DDMR.dmi'
	icon_state = "z8dmr"
	item_state = "z8dmr"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z8DDMR.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z8DDMR.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z8DDMR.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z8DDMR.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z8dmr-wielded-r",
		slot_l_hand_str = "z8dmr-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag20"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/obj/item/gun/projectile/automatic/z8/z11
	name = "Z11-D squad automatic weapon"
	desc = "The Hephaestus Industries Z11-D 'Tindalos' is a squad automatic weapon in service with the SCG. It takes the longer 6.5x59mm cartridge."
	icon = 'maps/torch/icons/obj/extraguns/Z11D.dmi'
	icon_state = "z11d"
	item_state = "z11d"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z11D.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z11D.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z11D.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z11D.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z11d-wielded-r",
		slot_l_hand_str = "z11d-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag100"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/obj/item/gun/projectile/automatic/z8/z11/on_update_icon()
	..()
	var/has_mag = ammo_magazine ? TRUE : FALSE
	if(has_mag)
		var/ammo_count = round(length(ammo_magazine.stored_ammo), 25)
		AddOverlays(image(icon, "[initial(item_state)]_mag[ammo_count]"))

/obj/item/gun/projectile/heavysniper/z12
	name = "Z12-A anti-materiel rifle"
	desc = "The Hephaestus Industries Z12-A 'Coyote' is an anti-materiel rifle in service with the SCG. It takes the 11.6x101mm cartridge."
	icon = 'maps/torch/icons/obj/extraguns/Z12A.dmi'
	icon_state = "z12a"
	item_state = "z12a"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z12A.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z12A.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z12A.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z12A.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z12a-wielded-r",
		slot_l_hand_str = "z12a-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.3,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/obj/item/gun/projectile/heavysniper/on_update_icon()
	..()
	if(bolt_open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = "[initial(icon_state)]-closed"

/*
 ###    Shotguns    ###
*/

/obj/item/gun/projectile/automatic/z8/shotgun
	name = "Z8-G automatic shotgun"
	desc = "The Hephaestus Industries Z8-G 'Fenrir' is a bullpup, automatic shotgun utilizing the Z8 platform in service with the SCG. It takes 12 gauge shells."
	icon = 'maps/torch/icons/obj/extraguns/Z8G.dmi'
	icon_state = "z8g"
	item_state = "z8g"
	item_icons = list(
		slot_r_hand_str = 'maps/torch/icons/obj/extraguns/Z8G.dmi',
		slot_l_hand_str = 'maps/torch/icons/obj/extraguns/Z8G.dmi',
		slot_back_str = 'maps/torch/icons/obj/extraguns/Z8G.dmi',
		slot_s_store_str = 'maps/torch/icons/obj/extraguns/Z8G.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "z8g-wielded-r",
		slot_l_hand_str = "z8g-wielded-l",
		slot_back_str = "back",
		slot_s_store_str = "onsuit"
	)
	magazine_state = "_mag12"
	magazine_type = /obj/item/ammo_magazine/mil_rifle/light
	burst_delay = 1.5
	one_hand_penalty = 10
	bulk = GUN_BULK_RIFLE
	has_launcher = FALSE
	wielded_item_state = "z10ar-wielded"
	firemodes = list(
		list(
			"mode_name" = "2-round bursts",
			"burst" = 2,
			"fire_delay" = null,
			"burst_delay" = 1.5,
			"move_delay" = 0.5,
			"use_launcher" = null,
			"one_hand_penalty" = 7,
			"burst_accuracy" = list(0, -0.5),
			"dispersion" = list(0, 0.1, 0.2)
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 0.5,
			"burst_delay" = 2.5,
			"move_delay" = 0.5,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, 0, -0.5, -1, -1, -2),
			"dispersion" = list(0, 0, 0, 0,2)
		)
	)

/*
 ###    Special    ###
*/
