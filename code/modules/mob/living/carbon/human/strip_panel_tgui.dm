// TGUI strip panel -- replaces the old-style /datum/browser HTML popup (show_inv()/human.dm) with a real TGUI
// interface, reusing handle_strip() (stripping.dm) as-is for every action's actual logic (no change to that proc
// at all -- it already accepts the exact same "slot text" values this panel sends: a numeric slot id, one of the
// special strings "pockets"/"sensors"/"lock_sensors"/"internals"/"tie", or a `\ref[underwear_item]`). This mirrors
// the same tgui_interact() pattern already used for /datum/examine_panel and /datum/sex_controller this session,
// implemented directly on /mob/living/carbon/human itself rather than a separate datum, since there's no
// meaningful state to track beyond what's already on the mob (unlike examine_panel/sex_controller, which needed
// their own lazily-created datum).

/mob/living/carbon/human/ui_state(mob/user)
	return GLOB.tgui_always_state

/mob/living/carbon/human/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "StripPanel", "Strip: [name]", ui)

/mob/living/carbon/human/ui_data(mob/user)
	var/list/data = list()
	data["target_name"] = name
	data["can_act"] = !user.incapacitated() && user.Adjacent(src) && user.IsAdvancedToolUser()

	var/list/slots = list()
	var/has_pockets = FALSE
	for(var/entry in species.hud.gear)
		var/list/slot_ref = species.hud.gear[entry]
		if(slot_ref["slot"] in list(slot_l_store, slot_r_store))
			has_pockets = TRUE
			continue
		var/obj/item/thing_in_slot = get_equipped_item(slot_ref["slot"])
		var/list/accessories = list()
		if(istype(thing_in_slot, /obj/item/clothing))
			var/obj/item/clothing/C = thing_in_slot
			for(var/obj/item/clothing/accessory/A in C.accessories)
				accessories += A.name
		slots += list(list(
			"name" = slot_ref["name"],
			"slot" = "[slot_ref["slot"]]",
			"item_name" = thing_in_slot ? "[thing_in_slot]" : null,
			"holder_ref" = thing_in_slot ? "\ref[thing_in_slot]" : null,
			"accessories" = accessories,
		))
	data["slots"] = slots
	data["has_pockets"] = has_pockets

	if(species.hud.has_hands)
		data["hands"] = list(
			list("name" = "Left hand", "slot" = "[slot_l_hand]", "item_name" = l_hand ? "[l_hand]" : null),
			list("name" = "Right hand", "slot" = "[slot_r_hand]", "item_name" = r_hand ? "[r_hand]" : null),
		)

	data["can_internals"] = istype(wear_mask, /obj/item/clothing/mask) || istype(head, /obj/item/clothing/head/helmet/space)
	data["has_internals_tank"] = istype(back, /obj/item/tank) || istype(belt, /obj/item/tank) || istype(s_store, /obj/item/tank)
	data["internals_active"] = !!internal

	var/obj/item/clothing/under/suit = w_uniform
	data["has_uniform"] = istype(suit)
	if(istype(suit))
		data["has_sensor"] = suit.has_sensor
		data["sensor_locked"] = suit.has_sensor == SUIT_LOCKED_SENSORS
		data["can_lock_sensors"] = suit.has_sensor && user.get_multitool()

	data["handcuffed"] = !!handcuffed
	data["handcuffed_slot"] = "[slot_handcuffed]"
	data["webbed"] = FALSE
	for(var/obj/aura/web/W in auras)
		data["webbed"] = TRUE
		break

	var/list/underwear_list = list()
	for(var/obj/item/underwear/UW in worn_underwear)
		underwear_list += list(list("name" = "[UW]", "ref" = "\ref[UW]"))
	data["underwear"] = underwear_list

	return data

/mob/living/carbon/human/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "strip")
		handle_strip(params["slot"], ui.user, locate(params["holder"]))
		return TRUE
	if(action == "remove_webbing")
		for(var/obj/aura/web/W in auras)
			W.remove_webbing(ui.user)
		return TRUE
	return FALSE
