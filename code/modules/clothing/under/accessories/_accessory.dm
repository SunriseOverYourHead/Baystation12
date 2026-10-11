#define ACCESSORY_ROLLED_DEFAULT null // Use the default/base sprite for the accessory.
#define ACCESSORY_ROLLED_NONE "none" // Use no sprite/hide the accessory.

/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/obj_accessories.dmi'
	icon_state = "tie"
	item_state = ""	//no inhands
	slot_flags = SLOT_TIE
	w_class = ITEM_SIZE_SMALL
	default_action_type = /datum/action/item_action/accessory
	var/accessory_flags = ACCESSORY_DEFAULT_FLAGS
	var/slot = ACCESSORY_SLOT_DECOR
	var/body_location = UPPER_TORSO //most accessories are here
	var/obj/item/clothing/parent //the suit the tie may be attached to
	var/image/inv_overlay = null	//overlay used when attached to clothing.
	var/list/mob_overlay = list()
	var/overlay_state = null
	var/list/accessory_icons = list(slot_w_uniform_str = 'icons/mob/onmob/onmob_accessories.dmi', slot_wear_suit_str = 'icons/mob/onmob/onmob_accessories.dmi')
	sprite_sheets = list(
		SPECIES_NABBER = 'icons/mob/species/nabber/onmob_accessories_gas.dmi',
		SPECIES_UNATHI = 'icons/mob/species/unathi/onmob_accessories_unathi.dmi'
		)
	/// String (One of `ACCESSORY_ROLLED_*` or a valid icon state). The icon_state or flag to use when the attached uniform is rolled down.
	var/on_rolled_down = ACCESSORY_ROLLED_DEFAULT
	/// String (One of `ACCESSORY_ROLLED_*` or a valid icon state). The icon_state or flag to use when the attached uniform has its sleeves rolled up.
	var/on_rolled_sleeves = ACCESSORY_ROLLED_DEFAULT
	var/slowdown //used when an accessory is meant to slow the wearer down when attached to clothing


/obj/item/clothing/accessory/Destroy()
	on_removed()
	return ..()


/obj/item/clothing/accessory/update_clothing_icon()
	..()
	if (parent)
		parent.update_clothing_icon()


/obj/item/clothing/accessory/proc/get_inv_overlay()
	if(!inv_overlay)
		var/tmp_icon_state = overlay_state
		if (!tmp_icon_state)
			tmp_icon_state = icon_state
		if(icon_override && ("[tmp_icon_state]_tie" in icon_states(icon_override)))
			inv_overlay = image(icon = icon_override, icon_state = "[tmp_icon_state]_tie", dir = SOUTH)
		else if("[tmp_icon_state]_tie" in icon_states(GLOB.default_onmob_icons[slot_tie_str]))
			inv_overlay = image(icon = GLOB.default_onmob_icons[slot_tie_str], icon_state = "[tmp_icon_state]_tie", dir = SOUTH)
		else
			inv_overlay = image(icon = GLOB.default_onmob_icons[slot_tie_str], icon_state = tmp_icon_state, dir = SOUTH)
	inv_overlay.color = color
	return inv_overlay


/obj/item/clothing/accessory/get_mob_overlay(mob/user_mob, slot)
	if(!istype(loc,/obj/item/clothing))	//don't need special handling if it's worn as normal item.
		return ..()
	var/bodytype = "Default"
	if(ishuman(user_mob))
		var/mob/living/carbon/human/user_human = user_mob
		if(user_human.species.get_bodytype(user_human) in sprite_sheets)
			bodytype = user_human.species.get_bodytype(user_human)

		var/tmp_icon_state = overlay_state? overlay_state : icon_state

		if(istype(loc,/obj/item/clothing/under))
			var/obj/item/clothing/under/C = loc
			if (on_rolled_down && C.rolled_down > 0)
				tmp_icon_state = on_rolled_down
			else if (on_rolled_sleeves && C.rolled_sleeves > 0)
				tmp_icon_state = on_rolled_sleeves

		var/use_sprite_sheet = accessory_icons[slot]
		var/using_species_spritesheet = FALSE
		if(sprite_sheets[bodytype])
			use_sprite_sheet = sprite_sheets[bodytype]
			using_species_spritesheet = TRUE
			// Don't trust a species sheet that doesn't actually have this state -- same reasoning as
			// get_mob_overlay()'s own re-check in items.dm (see its comment): a sheet existing for this
			// bodytype doesn't guarantee it covers every icon_state this accessory might use.
			if(!(tmp_icon_state in icon_states(use_sprite_sheet)))
				use_sprite_sheet = accessory_icons[slot]
				using_species_spritesheet = FALSE

		// Bulk-generated species sprites -- see the identical fallback (and its full comment) in items.dm's
		// get_mob_overlay(). Not currently populated for any accessory category, but the hook costs nothing to
		// have ready for when one is.
		if(!using_species_spritesheet && leg_remap_category)
			var/list/generated_for_category = GLOB.generated_sprite_sheets[leg_remap_category]
			var/generated_icon = generated_for_category ? generated_for_category[bodytype] : null
			if(generated_icon && (tmp_icon_state in icon_states(generated_icon)))
				use_sprite_sheet = generated_icon
				using_species_spritesheet = TRUE

		if(icon_override && ("[tmp_icon_state]_mob" in icon_states(icon_override)))
			return overlay_image(icon_override, "[tmp_icon_state]_mob", color, RESET_COLOR)
		else
			// Accessories render via this override, not the generic get_worn_icon() in items.dm -- so the
			// leg_remap_category pixel-remap hook (see _leg_shape_remap.dm) needs its own copy here, same
			// logic as get_worn_icon()'s, or it silently never fires for any accessory (ties, solgov
			// insignia/rank, etc). Skipped when a species-specific sprite_sheet is already in use, same reason
			// as get_worn_icon()'s own using_species_spritesheet/spritesheet check -- that art (eg Unathi's own
			// onmob_accessories_solgov_unathi.dmi) is already correctly shaped, a table built against the
			// generic human sprite would crop the wrong positions out of it.
			var/shape_key = (leg_remap_category && !using_species_spritesheet) ? user_human.get_body_shape_key() : null
			if(shape_key)
				var/icon/remapped = get_leg_remapped_icon(use_sprite_sheet, tmp_icon_state, shape_key)
				if(remapped)
					return overlay_image(remapped, "", color, RESET_COLOR)
			return overlay_image(use_sprite_sheet, tmp_icon_state, color, RESET_COLOR)


//when user attached an accessory to S
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/S, mob/user)
	if(istype(src,/obj/item/clothing/accessory/chameleon/changeling))
		if(is_type_in_list(S,changeling_fabricated_clothing))
			return
	if(!istype(S))
		return
	parent = S
	forceMove(parent)
	parent.AddOverlays(get_inv_overlay())

	if(user)
		to_chat(user, SPAN_NOTICE("You attach \the [src] to \the [parent]."))
		src.add_fingerprint(user)


/obj/item/clothing/accessory/proc/on_removed(mob/user)
	if(!parent)
		return
	parent.CutOverlays(get_inv_overlay())
	parent = null
	if(user)
		usr.put_in_hands(src)
		src.add_fingerprint(user)
	else
		dropInto(loc)

//default attack_hand behaviour
/obj/item/clothing/accessory/attack_hand(mob/user as mob)
	if(parent)
		return	//we aren't an object on the ground so don't call parent
	..()


/obj/item/clothing/accessory/get_pressure_weakness(pressure,zone)
	if(body_parts_covered & zone)
		return ..()
	return 1


/obj/item/clothing/accessory/toggleable/var/icon_closed


/obj/item/clothing/accessory/toggleable/Initialize()
	if (!icon_closed)
		icon_closed = icon_state
	return ..()


/obj/item/clothing/accessory/toggleable/on_attached(obj/item/clothing/under/S, mob/user as mob)
	..()
	parent.verbs += /obj/item/clothing/accessory/toggleable/verb/toggle

/obj/item/clothing/accessory/toggleable/on_removed(mob/user as mob)
	if(parent)
		parent.verbs -= /obj/item/clothing/accessory/toggleable/verb/toggle
	..()


/obj/item/clothing/accessory/toggleable/verb/toggle()
	set name = "Toggle Buttons"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return 0
	var/obj/item/clothing/accessory/toggleable/H = null
	if (istype(src, /obj/item/clothing/accessory/toggleable))
		H = src
	else
		H = locate() in src
	if(H)
		H.do_toggle(usr)
	update_clothing_icon()


/obj/item/clothing/accessory/toggleable/proc/do_toggle(user)
	if(icon_state == icon_closed)
		icon_state = "[icon_closed]_open"
		to_chat(user, "You unbutton [src].")
	else
		icon_state = icon_closed
		to_chat(user, "You button up [src].")
	update_clothing_icon()
