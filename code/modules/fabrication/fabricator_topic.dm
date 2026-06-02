/obj/machinery/fabricator/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	if(action == "change_category")
		var/choice = params["category"]
		if(!choice)
			return
		var/list/valid = SSfabrication.get_categories(fabricator_class)
		if(choice != "All" && !(choice in valid))
			return
		show_category = choice
		. = TRUE
	else if(action == "make")
		try_queue_build(locate(params["make"]), text2num(params["multiplier"]))
		. = TRUE
	else if(action == "cancel")
		try_cancel_build(locate(params["cancel"]))
		. = TRUE
	else if(action == "eject_mat")
		try_dump_material(params["eject_mat"])
		. = TRUE

/obj/machinery/fabricator/proc/try_cancel_build(datum/fabricator_build_order/order)
	if(istype(order) && currently_building != order && is_functioning())
		if(order in queued_orders)
			// Refund some mats.
			for(var/mat in order.earmarked_materials)
				stored_material[mat] = min(stored_material[mat] + (order.earmarked_materials[mat] * 0.9), storage_capacity[mat])
			queued_orders -= order
		qdel(order)

/obj/machinery/fabricator/proc/try_dump_material(mat_name)
	for(var/mat_path in stored_substances_to_names)
		if(stored_substances_to_names[mat_path] == mat_name)
			if(ispath(mat_path, /material))
				var/material/mat = SSmaterials.get_material_by_name(mat_name)
				if(mat && stored_material[mat_path] > mat.units_per_sheet && mat.stack_type)
					var/sheet_count = floor(stored_material[mat_path]/mat.units_per_sheet)
					stored_material[mat_path] -= sheet_count * mat.units_per_sheet
					mat.place_sheet(get_turf(src), sheet_count)
			else if(!isnull(stored_material[mat_path]))
				stored_material[mat_path] = 0
