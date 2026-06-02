//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/item/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = ITEM_SIZE_SMALL //It should be tiny! -Agouri

	matter = list(MATERIAL_STEEL = 50,MATERIAL_GLASS = 50)

	req_access = list(access_engine)

	var/secure = 0 //if set, then wires will be randomized and bolts will drop if the door is broken
	var/list/conf_access = list()
	var/one_access = 0 //if set to 1, door would receive OR instead of AND on the access restrictions.
	var/last_configurator = null
	var/locked = 1
	var/lockable = 1
	var/autoset = TRUE // Whether the door should inherit access from surrounding areas

/obj/item/airlock_electronics/attack_self(mob/user)
	if (!ishuman(user) && !istype(user,/mob/living/silicon/robot))
		return ..(user)

	ui_interact(user)


/obj/item/airlock_electronics/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "AirlockElectronics", src.name, ui)
	ui.open()

/obj/item/airlock_electronics/ui_data(mob/user)
	var/list/data = list()
	var/list/regions = list()
	var/list/selected = list()

	for(var/i in ACCESS_REGION_MIN to ACCESS_REGION_MAX) //code/game/jobs/_access_defs.dm
		var/list/region = list()
		var/list/area_accesses = list()
		for(var/j in get_region_accesses(i))
			area_accesses[LIST_PRE_INC(area_accesses)] = list(
				"desc" = get_access_desc(j),
				"ref" = "[j]"
			)
			if(j in src.conf_access)
				selected += "[j]"
		region["name"] = get_region_accesses_name(i)
		region["accesses"] = area_accesses
		regions[LIST_PRE_INC(regions)] = region
	data["regions"] = regions
	data["accesses"] = selected
	data["oneAccess"] = one_access

	return data

/obj/item/airlock_electronics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("unlock")
			if(lockable)
				if(!req_access || istype(usr, /mob/living/silicon))
					locked = FALSE
					last_configurator = usr.name
				else
					var/obj/item/card/id/I = usr.get_active_hand()
					I = I ? I.GetIdCard() : null
					if(!istype(I, /obj/item/card/id))
						to_chat(usr, SPAN_WARNING("[\src] flashes a yellow LED near the ID scanner. Did you remember to scan your ID or PDA?"))
						return FALSE
					if(check_access(I))
						locked = FALSE
						last_configurator = I.registered_name
					else
						to_chat(usr, SPAN_WARNING("[\src] flashes a red LED near the ID scanner, indicating your access has been denied."))
						return FALSE
			return TRUE
		if("lock")
			if(lockable)
				locked = TRUE
			return TRUE
		if("one_access")
			one_access = !one_access
			return TRUE
		if("autoset")
			autoset = !autoset
			return TRUE
		if("set")
			var/access = text2num(params["access"])
			if(!access)
				return TRUE
			if(!(access in conf_access))
				conf_access += access
			else
				conf_access -= access
			return TRUE
		if("grant_all")
			for(var/i in ACCESS_REGION_MIN to ACCESS_REGION_MAX)
				for(var/j in get_region_accesses(i))
					conf_access |= j
			return TRUE
		if("clear_all")
			conf_access = list()
			one_access = FALSE
			return TRUE
		if("grant_region")
			var/region_name = params["region"]
			for(var/i in ACCESS_REGION_MIN to ACCESS_REGION_MAX)
				if(get_region_accesses_name(i) == region_name)
					for(var/j in get_region_accesses(i))
						conf_access |= j
					break
			return TRUE
		if("deny_region")
			var/region_name = params["region"]
			for(var/i in ACCESS_REGION_MIN to ACCESS_REGION_MAX)
				if(get_region_accesses_name(i) == region_name)
					for(var/j in get_region_accesses(i))
						conf_access -= j
					break
			return TRUE
	return FALSE

/obj/item/airlock_electronics/ui_state(mob/user)
	return GLOB.hands_state


/obj/item/airlock_electronics/secure
	name = "secure airlock electronics"
	desc = "designed to be somewhat more resistant to hacking than standard electronics."
	origin_tech = list(TECH_DATA = 2)
	secure = TRUE

/obj/item/airlock_electronics/brace
	name = "airlock brace access circuit"
	req_access = list()
	locked = FALSE
	lockable = FALSE

/obj/item/airlock_electronics/brace/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/item/airlock_electronics/proc/set_access(obj/object)
	if(!object.req_access)
		object.check_access()
	if(length(object.req_access))
		conf_access = list()
		for(var/entry in object.req_access)
			conf_access |= entry // This flattens the list, turning everything into AND
			// Can be reworked to have the electronics inherit a precise access set, but requires UI changes.
