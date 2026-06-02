/obj/machinery/uniform_vendor
	name = "uniform vendor"
	desc= "A uniform vendor for utility, service, and dress uniforms."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "uniform"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE

	// Power
	use_power = 1
	idle_power_usage = 10
	var/vend_power_usage = 150 //actuators and stuff

	var/obj/item/card/id/ID
	var/list/uniforms = list()
	var/list/selected_outfit = list()

/obj/machinery/uniform_vendor/on_update_icon()
	if(MACHINE_IS_BROKEN(src))
		icon_state = "[initial(icon_state)]-broken"
	else if(is_powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/uniform_vendor/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/uniform_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "UniformVendor", "Uniform Vendor", ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/uniform_vendor/ui_data(mob/user)
	var/list/cats = list()
	if (ID)
		var/datum/job/job = SSjobs.get_by_path(ID.job_access_type)
		if (job)
			uniforms = find_uniforms(ID.military_rank, ID.military_branch, job.department_flag)
		for (var/T in uniforms)
			var/list/items = list()
			for (var/piece in uniforms[T])
				if (!piece)
					continue
				var/obj/item/clothing/C = piece
				items += list(list(
					"name" = sanitize(initial(C.name)),
					"path" = "[piece]",
					"selected" = (piece in selected_outfit),
					"can_issue" = can_issue(piece)
				))
			cats += list(list("name" = T, "items" = items))
	return list(
		"has_id" = !!ID,
		"id_info" = ID ? "[ID.registered_name], [ID.military_rank], [ID.military_branch]" : null,
		"categories" = cats,
		"selected_count" = length(selected_outfit)
	)

/obj/machinery/uniform_vendor/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if (.)
		return
	var/mob/M = usr
	switch(action)
		if("toggle_id")
			if (ID)
				if (!issilicon(M))
					M.put_in_hands(ID)
				else
					ID.dropInto(loc)
				ID = null
				selected_outfit.Cut()
			else
				var/obj/item/card/id/I = M.get_active_hand()
				if (istype(I) && M.unEquip(I, src))
					ID = I
			. = TRUE
		if("select_category")
			var/cat_name = params["name"]
			if (cat_name in uniforms)
				var/list/addition = uniforms[cat_name]
				for (var/G in addition)
					if (can_issue(G))
						selected_outfit |= addition
			. = TRUE
		if("toggle_item")
			var/path = text2path(params["path"])
			if (!ispath(path))
				return
			if (params["add"])
				selected_outfit |= path
			else
				selected_outfit -= path
			. = TRUE
		if("vend")
			flick("uniform-vend", src)
			spawn_uniform(selected_outfit)
			selected_outfit.Cut()
			. = TRUE

/obj/machinery/uniform_vendor/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/clothingbag))
		if(length(W.contents))
			to_chat(user, SPAN_WARNING("You must empty \the [W] before you can put it in \the [src]."))
			return TRUE
		to_chat(user, SPAN_NOTICE("You put \the [W] into \the [src]'s recycling slot."))
		qdel(W)
		return TRUE

	if (istype(W, /obj/item/card/id) && !ID && user.unEquip(W, src))
		to_chat(user, SPAN_NOTICE("You slide \the [W] into \the [src]!"))
		ID = W
		attack_hand(user)
		return TRUE
	return ..()

/obj/machinery/uniform_vendor/proc/spawn_uniform(list/selected_outfit)
	listclearnulls(selected_outfit)
	if(!GLOB.uniform_issued_items[user_id()])
		GLOB.uniform_issued_items[user_id()] = list()
	var/list/checkedout = GLOB.uniform_issued_items[user_id()]
	if(length(selected_outfit) > 1)
		var/obj/item/clothingbag/bag = new /obj/item/clothingbag
		for(var/item in selected_outfit)
			new item(bag)
			checkedout += item
		bag.dropInto(loc)
	else if (length(selected_outfit))
		var/obj/item/clothing/C = selected_outfit[1]
		new C(get_turf(src))
		checkedout += C

/obj/machinery/uniform_vendor/proc/user_id()
	if(!ID)
		return "UNKNOWN"
	else
		return "[ID.registered_name], [ID.military_rank], [ID.military_branch]"

/obj/machinery/uniform_vendor/proc/can_issue(gear)
	var/list/issued = GLOB.uniform_issued_items[user_id()]
	if(!issued || !length(issued))
		return TRUE
	return !(gear in issued)
