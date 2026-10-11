/obj/item/gun/projectile/automatic/z8
	name = "Z8-C assault rifle"
	desc = "The Hephaestus Industries Z8-C 'Bulldog' is one of the oldest weapons currently in service with the SCG. Despite its age, it still remains the de-facto rifle of the SCG Army due to its ease of handling, cheap production costs, reliability, and plentiful surplus stock."
	icon = 'code/modules/projectiles/guns/projectile/automatic/z8/z8.dmi'
	icon_state = "z8"
	item_state = "z8"
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8.dmi',
		slot_back_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8.dmi',
		slot_s_store_str = 'code/modules/projectiles/guns/projectile/automatic/z8/z8.dmi',
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
	magazine_type = /obj/item/ammo_magazine/z9
	allowed_magazines = /obj/item/ammo_magazine/z9
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
	if (istype(tool, /obj/item/grenade) && launcher)
		launcher.load(tool, user)
		return TRUE
	return ..()

/obj/item/gun/projectile/automatic/z8/toggle_safety(mob/user)
	..()
	if(launcher)
		launcher.safety_state = safety_state

/obj/item/gun/projectile/automatic/z8/attack_hand(mob/user)
	if(user.get_inactive_hand() == src && launcher && use_launcher)
		launcher.unload(user)
	else
		..()

/obj/item/gun/projectile/automatic/z8/Fire(atom/target, mob/living/user, params, pointblank=0, reflex=0)
	if(launcher && use_launcher)
		launcher.Fire(target, user, params, pointblank, reflex)
		if(!launcher.chambered)
			switch_firemodes()
	else
		..()

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

	if(has_mag && magazine_state)
		AddOverlays(image(icon, "[magazine_state]"))
