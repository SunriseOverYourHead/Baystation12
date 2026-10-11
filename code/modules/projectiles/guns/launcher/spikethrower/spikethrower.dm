/obj/item/gun/launcher/alien
	var/last_regen = 0
	var/ammo_gen_time = 100
	var/max_ammo = 3
	var/ammo = 3
	var/ammo_type
	var/ammo_name

/obj/item/gun/launcher/alien/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	last_regen = world.time
	set_extension(src, /datum/extension/voxform)

/obj/item/gun/launcher/alien/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/launcher/alien/Process()
	if(ammo < max_ammo && world.time > last_regen + ammo_gen_time)
		ammo++
		last_regen = world.time
		update_icon()

/obj/item/gun/launcher/alien/examine(mob/user)
	. = ..()
	to_chat(user, "It has [ammo] [ammo_name]\s remaining.")

/obj/item/gun/launcher/alien/consume_next_projectile()
	if(ammo < 1) return null
	if(ammo == max_ammo) //stops people from buffering a reload (gaining effectively +1 to the clip)
		last_regen = world.time
	ammo--
	return new ammo_type

/obj/item/gun/launcher/alien/special_check(mob/living/carbon/human/user)
	. = ..()
	if(!QDELETED(src) && src.loc == user && .)
		var/datum/extension/voxform/voxform = get_extension(src, /datum/extension/voxform)
		if(voxform) . = voxform.check_held_user(user, src)

//Vox pinning weapon.
/obj/item/gun/launcher/alien/spikethrower

	name = "spike thrower"
	desc = "A vicious alien projectile weapon. Parts of it quiver gelatinously, as though the thing is insectile and alive."
	w_class = ITEM_SIZE_LARGE
	ammo_name = "spike"
	ammo_type = /obj/item/spike
	release_force = 30
	icon = 'code/modules/projectiles/guns/launcher/spikethrower/spikethrower.dmi'
	icon_state = "spikethrower3"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
	)
	colocated_sprites = FALSE
	item_state = "spikethrower"
	fire_sound_text = "a strange noise"
	fire_sound = 'sound/weapons/spike.ogg'

/obj/item/gun/launcher/alien/spikethrower/on_update_icon()
	icon_state = "spikethrower[ammo]"


/obj/item/gun/launcher/alien/spikethrower/check_accidents()
	return
