/obj/item/gun/energy/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by many mercenary stealth specialists."
	icon = 'code/modules/projectiles/guns/energy/crossbow/crossbow.dmi'
	icon_state = "crossbow"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/crossbow/crossbow.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/crossbow/crossbow.dmi',
	)
	colocated_sprites = TRUE
	w_class = ITEM_SIZE_NORMAL
	item_state = "crossbow"
	origin_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 2, TECH_ESOTERIC = 5)
	matter = list(MATERIAL_STEEL = 2000)
	slot_flags = SLOT_BELT
	silenced = TRUE
	fire_sound = 'sound/weapons/Genhit.ogg'
	projectile_type = /obj/item/projectile/energy/bolt
	max_shots = 8
	self_recharge = 1
	charge_meter = 0
	combustion = 0

/obj/item/gun/energy/crossbow/ninja
	name = "energy dart thrower"
	projectile_type = /obj/item/projectile/energy/dart
	max_shots = 5

/obj/item/gun/energy/crossbow/ninja/mounted
	use_external_power = 1
	has_safety = FALSE

/obj/item/gun/energy/crossbow/largecrossbow
	name = "energy crossbow"
	desc = "A weapon favored by mercenary infiltration teams."
	w_class = ITEM_SIZE_LARGE
	force = 10
	one_hand_penalty = 1
	matter = list(MATERIAL_STEEL = 200000)
	projectile_type = /obj/item/projectile/energy/bolt/large
