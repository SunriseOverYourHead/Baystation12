/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "The NT Mk60 EW Halicon is a man portable anti-armor weapon designed to disable mechanical threats, produced by NT. Not the best of its type."
	icon = 'code/modules/projectiles/guns/energy/ionrifle/ionrifle.dmi'
	icon_state = "ionrifle"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/ionrifle/ionrifle.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/ionrifle/ionrifle.dmi',
		slot_back_str = 'code/modules/projectiles/guns/energy/ionrifle/ionrifle.dmi',
	)
	colocated_sprites = TRUE
	item_state = "ionrifle"
	origin_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 4)
	w_class = ITEM_SIZE_HUGE
	force = 10
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	one_hand_penalty = 4
	charge_cost = 60
	max_shots = 5
	fire_delay = 60
	projectile_type = /obj/item/projectile/ion
	wielded_item_state = "ionrifle-wielded"
	combustion = 0

/obj/item/gun/energy/ionrifle/small
	name = "ion pistol"
	desc = "The NT Mk72 EW Preston is a personal defense weapon designed to disable mechanical threats."
	icon = 'code/modules/projectiles/guns/energy/ionrifle/ion_pistol.dmi'
	icon_state = "ionpistol"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/ionrifle/ion_pistol.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/ionrifle/ion_pistol.dmi',
	)
	colocated_sprites = FALSE
	item_state = "ionpistol"
	origin_tech = list(TECH_COMBAT = 2, TECH_MAGNET = 4)
	w_class = ITEM_SIZE_NORMAL
	force = 5
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	one_hand_penalty = 0
	charge_cost = 40
	max_shots = 3
	fire_delay = 30
	projectile_type = /obj/item/projectile/ion/small

/obj/item/gun/energy/ionrifle/mounted
	name = "mounted ion gun"
	desc = "You should not see this. Call a developer."
	fire_delay = 30
	one_hand_penalty = 0
	self_recharge = TRUE
	use_external_power = TRUE
	has_safety = FALSE
