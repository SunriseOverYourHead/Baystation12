/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "An industrial tool that expels focused plasma bursts for deconstruction and mining."
	charge_meter = 0
	icon = 'code/modules/projectiles/guns/energy/plasmacutter/plasmacutter.dmi'
	icon_state = "plasmacutter"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/plasmacutter/plasmacutter.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/plasmacutter/plasmacutter.dmi',
	)
	colocated_sprites = TRUE
	item_state = "plasmacutter"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_NORMAL
	force = 8
	origin_tech = list(TECH_MATERIAL = 4, TECH_PHORON = 4, TECH_ENGINEERING = 6, TECH_COMBAT = 3)
	matter = list(MATERIAL_STEEL = 4000)
	projectile_type = /obj/item/projectile/beam/plasmacutter
	max_shots = 10
	self_recharge = 1
	var/datum/effect/spark_spread/spark_system

	// As an industrial tool the plasma cutter's safety training falls under construction.
	gun_skill = SKILL_CONSTRUCTION
	safety_skill = SKILL_TRAINED

/obj/item/gun/energy/plasmacutter/mounted
	name = "mounted plasma cutter"
	use_external_power = 1
	max_shots = 4
	has_safety = FALSE

/obj/item/gun/energy/plasmacutter/Initialize()
	. = ..()
	spark_system = new /datum/effect/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/gun/energy/plasmacutter/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/gun/energy/plasmacutter/proc/slice(mob/M = null)
	if(!safety())
		if(M)
			M.welding_eyecheck()//Welding tool eye check
			if(check_accidents(M, "[M] loses grip on \the [src] from its sudden recoil!",gun_skill, 60, safety_skill))
				return 0
		spark_system.start()
		return 1
	handle_click_empty(M)
	return 0


/obj/item/gun/energy/plasmacutter/IsHeatSource()
	return 3800
