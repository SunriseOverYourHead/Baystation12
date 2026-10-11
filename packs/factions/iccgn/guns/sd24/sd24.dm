/obj/item/gun/projectile/sniper/sd24
	name = "SD24-C marksman rifle"
	desc = "An SD24-C 'Panther'. It is a simple and durable rifle made of stamped steel manufactured by Novaya Zemlya Arms for the Confederation Navy. \
	While it lacks the burst fire of other military rifles, it's exceptionally accurate and has a powerful optic."
	icon = 'packs/factions/iccgn/guns/sd24/sd24.dmi'
	icon_state = "dmr"
	item_state = "dmr"
	fire_delay = 8
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 4, TECH_ESOTERIC = 5)
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = PROJECTILE_RIFLE_INTERMEDIATE_SMALL
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/sd24
	allowed_magazines = /obj/item/ammo_magazine/sd24
	one_hand_penalty = 8
	scoped_accuracy = 8
	scope_zoom = 1
	accuracy_power = 8
	accuracy = 4
	bulk = GUN_BULK_RIFLE
	wielded_item_state = "dmr-wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'

/obj/item/gun/projectile/sniper/sd24/on_update_icon()
	if(ammo_magazine)
		icon_state = "dmr"
	else
		icon_state = "dmr-empty"
	..()
