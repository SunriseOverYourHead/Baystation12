/obj/item/gun/projectile/automatic/pp72
	name = "PP72 submachinegun"
	desc = "The Novaya Zemlya Arms PP72 submachinegun. Mostly relegated to support personnel in the Confederation Navy and Naval Infantry."
	icon = 'packs/factions/iccgn/guns/pp72/pp72.dmi'
	icon_state = "drozd-bs"
	item_icons = list(
		slot_l_hand_str = 'packs/factions/iccgn/guns/pp72/pp72.dmi',
		slot_r_hand_str = 'packs/factions/iccgn/guns/pp72/pp72.dmi',
	)
	item_state_slots = list(
		slot_l_hand_str = "lefthand",
		slot_r_hand_str = "righthand",
	)
	load_method = MAGAZINE
	caliber = PROJECTILE_PISTOL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ESOTERIC = 3)
	burst_delay = 0.5
	ammo_type = /obj/item/ammo_casing/pistol
	magazine_type = /obj/item/ammo_magazine/pp72
	allowed_magazines = /obj/item/ammo_magazine/pp72
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	one_hand_penalty = 2

	firemodes = list(
		list(
			"mode_name" = "3-round bursts",
			"burst" = 3,
			"fire_delay" = 0.2,
			"move_delay" = 0.5,
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

/obj/item/gun/projectile/automatic/pp72/on_update_icon()
	..()
	var/has_mag = !!ammo_magazine
	var/ammo_count = has_mag ? length(ammo_magazine.stored_ammo) : 0

	if(!has_mag)
		icon_state = "drozd-bs_slide"
	else if(ammo_count == 0)
		icon_state = "drozd-bs_mag10_slide"
	else if(ammo_count <= 10)
		icon_state = "drozd-bs_mag10"
	else
		icon_state = "drozd-bs_mag30"

	var/mob/living/M = loc
	if(istype(M))
		var/is_wielded = M.can_wield_item(src) && src.is_held_twohanded(M)
		if(is_wielded)
			item_state_slots[slot_l_hand_str] = "lefthand_doble"
			item_state_slots[slot_r_hand_str] = "righthand_doble"
		else
			item_state_slots[slot_l_hand_str] = has_mag ? "lefthand_mag" : "lefthand"
			item_state_slots[slot_r_hand_str] = has_mag ? "righthand_mag" : "righthand"
