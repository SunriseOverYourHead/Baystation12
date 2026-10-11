/obj/item/gun/projectile/automatic/skrell
	name = "QX-2 Miniaturized Railgun"
	desc = "Modeled after VT-3, the Qerr Xira-2 or, as refered in Sol, QX-2, is a miniaturized railgun popular with SDTF squadrons. An internal microfusion cell and a sizeable ammo capacity both guarantee reliability even on prolonged engagements."
	icon = 'code/modules/projectiles/guns/projectile/automatic/skrell/skrell.dmi'
	icon_state = "skrellshotgun"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/automatic/skrell/skrell.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/automatic/skrell/skrell.dmi',
	)
	colocated_sprites = TRUE
	item_state = "skrellshotgun"
	safety_icon = "safety"
	move_delay = 2
	one_hand_penalty = 5
	fire_delay = 5
	wielded_item_state = "skrellshotgun-wielded"
	w_class = ITEM_SIZE_HUGE
	force = 10
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	caliber = CALIBER_SKRELL_SHOTGUN
	ammo_type = /obj/item/ammo_casing/skrell_shotgun
	magazine_type = /obj/item/ammo_magazine/skrell_shotgun
	allowed_magazines = /obj/item/ammo_magazine/skrell_shotgun
	bulk = GUN_BULK_RIFLE
	handle_casings = CLEAR_CASINGS
	firemodes = list()

/obj/item/gun/projectile/automatic/skrell/on_update_icon()
	..()
	if(ammo_magazine)
		icon_state = "skrellshotgun"
	else
		icon_state = "skrellshotgun-e"

/obj/item/ammo_casing/skrell_shotgun
	name = "QX-2 flechette slug"
	desc = "A compact flechette slug designed for the skrellian QX-2 miniaturized railgun."
	caliber = CALIBER_SKRELL_SHOTGUN
	projectile_type = /obj/item/projectile/bullet/flechette
	icon_state = "skrellflechette"
	spent_icon = "skrellflechette-spent"
