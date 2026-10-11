/obj/item/gun/projectile/automatic/battlerifle
	name = "battle rifle"
	desc = "The battle rifle hasn't changed much since its inception in the mid 20th century. Built to last in the toughest conditions, the select fire rifle is well reguarded as a dependable weapon."
	icon = 'code/modules/projectiles/guns/projectile/automatic/battlerifle/battlerifle.dmi'
	icon_state = "battlerifle"
	item_state = "battlerifle"
	w_class = ITEM_SIZE_HUGE
	force = 12
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 1, TECH_ESOTERIC = 5)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	ammo_type = /obj/item/ammo_casing/rifle/intermediate/small
	magazine_type = /obj/item/ammo_magazine/mil_rifle/heavy
	allowed_magazines = /obj/item/ammo_magazine/mil_rifle
	one_hand_penalty = 10
	accuracy_power = 9
	accuracy = 1
	bulk = GUN_BULK_HEAVY_RIFLE
	item_icons = list(
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/battlerifle/battlerifle.dmi',
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/battlerifle/battlerifle.dmi',
	)
	item_state_slots = list(
		slot_r_hand_str = "battlerifle-r",
		slot_l_hand_str = "battlerifle-l",
	)
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'

	firemodes = list(
		list(
			"mode_name" = "semi auto",
			"burst" = 1,
			"fire_delay" = null,
			"move_delay" = null,
			"one_hand_penalty" = 8,
			"burst_accuracy" = null,
			"dispersion" = null
		),
		list(
			"mode_name" = "full auto",
			"can_autofire" = 1,
			"burst" = 1,
			"fire_delay" = 1,
			"one_hand_penalty" = 12,
			"burst_accuracy" = list(0, -1, -2, -3, -4, -4, -4, -4, -4),
			"dispersion" = list(1.0, 1.0, 1.0, 1.0, 1.2)
		)
	)

/obj/item/gun/projectile/automatic/battlerifle/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "battlerifle"
		item_state_slots[slot_l_hand_str] = "battlerifle-wielded-l"
		item_state_slots[slot_r_hand_str] = "battlerifle-wielded-r"
	else
		icon_state = "battlerifle-empty"
		item_state_slots[slot_l_hand_str] = "battlerifle-wielded-empty-l"
		item_state_slots[slot_r_hand_str] = "battlerifle-wielded-empty-r"

	var/mob/living/M = loc
	if(istype(M))
		var/is_left = (M.l_hand == src)
		var/is_right = (M.r_hand == src)
		var/other_free = is_left ? !M.r_hand : (is_right ? !M.l_hand : FALSE)
		if((is_left || is_right) && !other_free)
			if(ammo_magazine)
				item_state_slots[slot_l_hand_str] = "battlerifle-l"
				item_state_slots[slot_r_hand_str] = "battlerifle-r"
			else
				item_state_slots[slot_l_hand_str] = "battlerifle-l"
				item_state_slots[slot_r_hand_str] = "battlerifle-r"
