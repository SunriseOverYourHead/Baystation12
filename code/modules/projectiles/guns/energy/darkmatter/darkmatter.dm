/*
 * Vox Darkmatter Cannon
 */
/obj/item/gun/energy/darkmatter
	name = "flux cannon"
	desc = "A vicious beam weapon that crushes targets with dark-matter gravity pulses. Parts of it twitch and writhe, as if alive."
	icon = 'code/modules/projectiles/guns/energy/darkmatter/darkmatter.dmi'
	icon_state = "darkcannon"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/darkmatter/darkmatter.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/darkmatter/darkmatter.dmi',
	)
	colocated_sprites = TRUE
	item_state = "darkcannon"
	w_class = ITEM_SIZE_LARGE
	projectile_type = /obj/item/projectile/beam/stun/darkmatter
	one_hand_penalty = 2 //a little bulky
	self_recharge = 1
	firemodes = list(
		list(
			"mode_name" = "stunning",
			"burst" = 1,
			"fire_delay" = null,
			"move_delay" = null,
			"burst_accuracy" = list(30),
			"dispersion" = null,
			"projectile_type" = /obj/item/projectile/beam/stun/darkmatter,
			"charge_cost" = 50
		),
		list(
			"mode_name" = "focused",
			"burst" = 1,
			"fire_delay" = null,
			"move_delay" = null,
			"burst_accuracy" = list(30),
			"dispersion" = null,
			"projectile_type" = /obj/item/projectile/beam/darkmatter,
			"charge_cost" = 75
		),
		list(
			"mode_name" = "scatter burst",
			"burst" = 8,
			"fire_delay" = null,
			"move_delay" = 4,
			"burst_accuracy" = list(0, 0, 0, 0, 0, 0, 0, 0),
			"dispersion" = list(0, 1, 2, 2, 3, 3, 3, 3, 3),
			"projectile_type" = /obj/item/projectile/energy/darkmatter,
			"charge_cost" = 10
		)
	)

/obj/item/gun/energy/darkmatter/Initialize()
	. = ..()
	set_extension(src, /datum/extension/voxform)

/obj/item/gun/energy/darkmatter/special_check(mob/living/carbon/human/user)
	. = ..()
	if(!QDELETED(src) && src.loc == user && .)
		var/datum/extension/voxform/voxform = get_extension(src, /datum/extension/voxform)
		if(voxform) . = voxform.check_held_user(user, src)
