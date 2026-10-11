/obj/item/gun/projectile/sniper/sd55
	name = "SD55-B anti-materiel rifle"
	desc = "A Novaya Zemlya Arms SD55-B 'Caracal'. A hulking anti-materiel rifle chambered in 10.5x99mm. In service with the Confederation Navy."
	icon = 'packs/factions/iccgn/guns/sd55/sd55.dmi'
	icon_state = "dmr"
	item_state = "dmr"
	fire_delay = 8
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 4, TECH_ESOTERIC = 5)
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = PROJECTILE_RIFLE_FULL_BIG
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/sd55
	allowed_magazines = /obj/item/ammo_magazine/sd55
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

/obj/item/gun/projectile/sniper/sd55/on_update_icon()
	if(ammo_magazine)
		icon_state = "dmr"
	else
		icon_state = "dmr-empty"
	..()
