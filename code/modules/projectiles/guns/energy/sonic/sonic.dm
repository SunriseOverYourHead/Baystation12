/*
 * Vox Sonic Cannon
 */
/obj/item/gun/energy/sonic
	name = "soundcannon"
	desc = "A vicious sonic weapon of alien manufacture. Parts of it quiver gelatinously, as though the insectile-looking thing is alive."
	icon = 'code/modules/projectiles/guns/energy/sonic/sonic.dmi'
	icon_state = "noise"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/energy/sonic/sonic.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/energy/sonic/sonic.dmi',
	)
	colocated_sprites = TRUE
	item_state = "noise"
	w_class = ITEM_SIZE_LARGE
	one_hand_penalty = 1
	self_recharge = 1
	recharge_time = 10
	fire_delay = 15
	projectile_type = /obj/item/projectile/energy/plasmastun/sonic/weak
	firemodes = list(
		list(
			"mode_name" = "normal",
			"projectile_type" = /obj/item/projectile/energy/plasmastun/sonic/weak,
			"charge_cost" = 50
		),
		list(
			"mode_name" = "overcharge",
			"projectile_type" = /obj/item/projectile/energy/plasmastun/sonic/strong,
			"charge_cost" = 200
		)
	)

/obj/item/gun/energy/sonic/Initialize()
	. = ..()
	set_extension(src, /datum/extension/voxform)

/obj/item/gun/energy/sonic/special_check(mob/living/carbon/human/user)
	. = ..()
	if(!QDELETED(src) && src.loc == user && .)
		var/datum/extension/voxform/voxform = get_extension(src, /datum/extension/voxform)
		if(voxform) . = voxform.check_held_user(user, src)
