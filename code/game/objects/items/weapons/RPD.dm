//Contains the rapid piping device.
//
// Modernized port of NovaSector's RPD: a tgui-driven design catalog (reusing the existing
// GLOB.all_pipe_datums_by_category/GLOB.all_disposal_pipe_datums_by_category trees - unchanged, just consumed
// from a new frontend instead of the old browser-popup interact()) plus a real, independent pipe-layer system
// (see code/modules/atmospherics/atmospherics.dm's piping_layer var and the two check_connect_types() procs it's
// gated through), full atmos/disposals unification, and smart/reprogrammable pipes.

#define RPD_MODE_DISPENSE (1<<0)
#define RPD_MODE_CONNECT (1<<1)
#define RPD_MODE_DESTROY (1<<2)
#define RPD_MODE_REPROGRAM (1<<3)

#define RPD_PIPE_LAYER_BIT(num) (1 << ((num) - 1))

#define RPD_CATEGORY_ATMOS 0
#define RPD_CATEGORY_DISPOSAL 1

#define RPD_UPGRADE_UNWRENCH (1<<0)

/obj/item/rpd
	name = "rapid piping device"
	desc = "Portable, complex and deceptively heavy, it's the cousin of the RCD, use to dispense piping on the move."
	icon = 'icons/obj/tools/rpd.dmi'//Needs proper icon
	icon_state = "rpd"
	force = 12
	throwforce = 15
	throw_speed = 1
	throw_range = 3
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 5, TECH_MATERIAL = 4)

	var/datum/effect/spark_spread/spark_system
	/// currently selected pipe recipe datum
	var/datum/pipe/recipe
	var/pipe_color = "white"
	/// which of the 5 independent piping layers new atmos pipes get built on
	var/piping_layer = PIPING_LAYER_DEFAULT
	/// if TRUE, pipe_layers is a bitmask of several layers to stamp per click instead of a single layer
	var/multi_layer = FALSE
	var/pipe_layers = RPD_PIPE_LAYER_BIT(PIPING_LAYER_DEFAULT)
	/// bitflags of active modes - Dispense/Connect/Destroy/Reprogram. Connect auto-wrenches a just-dispensed
	/// atmos pipe into a real connected machinery object immediately, instead of leaving an unbuilt fitting item
	/// on the ground for a manual wrench pass.
	var/mode = RPD_MODE_DISPENSE | RPD_MODE_CONNECT | RPD_MODE_DESTROY | RPD_MODE_REPROGRAM
	/// RPD_CATEGORY_ATMOS/DISPOSAL - which design catalog is active
	var/root_category = RPD_CATEGORY_ATMOS
	/// bitflags of installed design-disk upgrades
	var/upgrade_flags = 0
	/// directions a newly-reprogrammed smart pipe should be set to connect on
	var/p_init_dir = NORTH|SOUTH|EAST|WEST

/obj/item/rpd/Initialize()
	. = ..()
	spark_system = new /datum/effect/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	select_first_recipe()

/obj/item/rpd/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/rpd/proc/get_category_tree()
	if(root_category == RPD_CATEGORY_DISPOSAL)
		return GLOB.all_disposal_pipe_datums_by_category
	return GLOB.all_pipe_datums_by_category

/obj/item/rpd/proc/select_first_recipe()
	var/list/tree = get_category_tree()
	for(var/subcategory_type in tree)
		var/list/subcategory_recipes = tree[subcategory_type]
		if(length(subcategory_recipes))
			recipe = subcategory_recipes[1]
			return
	recipe = null

/obj/item/rpd/proc/find_category_recipes(cat_name)
	var/list/tree = get_category_tree()
	for(var/subcategory_type in tree)
		var/list/subcategory_recipes = tree[subcategory_type]
		if(!length(subcategory_recipes))
			continue
		var/datum/pipe/first = subcategory_recipes[1]
		if(first.category == cat_name)
			return subcategory_recipes
	return null

/obj/item/rpd/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		if(user.skill_check(SKILL_ATMOS,SKILL_BASIC))
			to_chat(user, "[SPAN_NOTICE("Current selection reads:")] [recipe ? recipe.name : "nothing"] (layer [piping_layer])")
		else
			to_chat(user, SPAN_WARNING("The readout is flashing some atmospheric jargon, you can't understand."))

/obj/item/rpd/attack_self(mob/user)
	ui_interact(user)
	add_fingerprint(user)

/obj/item/rpd/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "RapidPipeDispenser", name, ui)
	ui.open()

/obj/item/rpd/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/pipes))

/// CSS class for a recipe's preview icon, or null if its build_icon/build_icon_state don't resolve to anything
/// (shouldn't normally happen - see /datum/asset/spritesheet/pipes/create_spritesheets()).
/obj/item/rpd/proc/get_recipe_icon_class(datum/pipe/recipe)
	var/datum/asset/spritesheet/pipes/sheet = get_asset_datum(/datum/asset/spritesheet/pipes)
	return sheet.icon_class_name(sanitize_css_class_name("[recipe.type]"))

/obj/item/rpd/ui_static_data(mob/user)
	return list(
		"paint_colors" = pipe_colors,
		"max_pipe_layers" = PIPING_LAYER_MAX,
	)

/obj/item/rpd/ui_data(mob/user)
	var/list/data = list(
		"category" = root_category,
		"mode" = mode,
		"multi_layer" = multi_layer,
		"pipe_layers" = pipe_layers,
		"selected_color" = pipe_color,
		"selected_recipe" = recipe ? recipe.name : null,
		"categories" = list(),
		"init_directions" = list(
			"north" = !!(p_init_dir & NORTH),
			"south" = !!(p_init_dir & SOUTH),
			"east" = !!(p_init_dir & EAST),
			"west" = !!(p_init_dir & WEST),
		),
	)

	var/list/tree = get_category_tree()
	for(var/subcategory_type in tree)
		var/list/subcategory_recipes = tree[subcategory_type]
		if(!length(subcategory_recipes))
			continue
		var/datum/pipe/first = subcategory_recipes[1]
		var/list/available_recipes = list()
		for(var/i in 1 to length(subcategory_recipes))
			var/datum/pipe/info = subcategory_recipes[i]
			available_recipes += list(list("pipe_name" = info.name, "pipe_index" = i, "icon" = get_recipe_icon_class(info)))
			if(info == recipe)
				data["selected_category"] = first.category
		data["categories"] += list(list("cat_name" = first.category, "recipes" = available_recipes))

	return data

/obj/item/rpd/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("category")
			var/new_category = text2num(params["category"])
			if(new_category != RPD_CATEGORY_ATMOS && new_category != RPD_CATEGORY_DISPOSAL)
				return
			root_category = new_category
			select_first_recipe()
			. = TRUE

		if("color")
			if(params["paint_color"] in pipe_colors)
				pipe_color = params["paint_color"]
				. = TRUE

		if("pipe_type")
			var/list/category_recipes = find_category_recipes(params["category"])
			var/index = text2num(params["pipe_type"])
			if(category_recipes && category_recipes[index])
				recipe = category_recipes[index]
				. = TRUE

		if("pipe_layers")
			var/selected_layers = text2num(params["pipe_layers"])
			var/valid_layer = FALSE
			for(var/n in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
				if(RPD_PIPE_LAYER_BIT(n) & selected_layers)
					valid_layer = TRUE
					break
			if(!valid_layer)
				return

			if(multi_layer)
				pipe_layers ^= selected_layers
			else
				pipe_layers = selected_layers
				for(var/n in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
					if(RPD_PIPE_LAYER_BIT(n) & pipe_layers)
						piping_layer = n
						break
			. = TRUE

		if("toggle_multi_layer")
			if(multi_layer)
				//collapse back down to a single layer - the lowest one currently selected
				for(var/n in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
					if(RPD_PIPE_LAYER_BIT(n) & pipe_layers)
						piping_layer = n
						pipe_layers = RPD_PIPE_LAYER_BIT(n)
						break
			multi_layer = !multi_layer
			. = TRUE

		if("mode")
			var/selected_mode = text2num(params["mode"])
			mode ^= selected_mode
			. = TRUE

		if("init_dir_setting")
			var/dir_bit
			switch(params["dir_flag"])
				if("north")
					dir_bit = NORTH
				if("south")
					dir_bit = SOUTH
				if("east")
					dir_bit = EAST
				if("west")
					dir_bit = WEST
			if(!dir_bit)
				return
			var/target_dir = p_init_dir ^ dir_bit
			//refuse a configuration that can only connect in one direction - it would be a dead-end stub
			if(target_dir && !(target_dir & (target_dir - 1)))
				return
			p_init_dir = target_dir
			. = TRUE

		if("init_reset")
			p_init_dir = NORTH|SOUTH|EAST|WEST
			. = TRUE

	if(.)
		playsound(src, 'sound/effects/pop.ogg', 50, FALSE)

/obj/item/rpd/proc/get_active_layers()
	if(!multi_layer)
		return list(piping_layer)
	var/list/layers = list()
	for(var/n in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		if(RPD_PIPE_LAYER_BIT(n) & pipe_layers)
			layers += n
	return layers

/obj/item/rpd/proc/is_destroyable(atom/A)
	if(istype(A, /obj/item/pipe))
		return TRUE
	if(istype(A, /obj/structure/disposalconstruct))
		var/obj/structure/disposalconstruct/D = A
		return !D.anchored
	return FALSE

/obj/item/rpd/use_after(atom/A, mob/living/user, click_parameters)
	if(root_category == RPD_CATEGORY_ATMOS && (mode & RPD_MODE_REPROGRAM) && istype(A, /obj/machinery/atmospherics/pipe/smart))
		return do_reprogram(A, user)

	if(root_category == RPD_CATEGORY_ATMOS && (upgrade_flags & RPD_UPGRADE_UNWRENCH) && (mode & RPD_MODE_DESTROY) \
			&& istype(A, /obj/machinery/atmospherics) && !istype(A, /obj/machinery/atmospherics/omni))
		try_unwrench_built(A, user)
		return TRUE

	if(is_destroyable(A))
		if(mode & RPD_MODE_DESTROY)
			recycle(A, user)
		return TRUE

	if(!(mode & RPD_MODE_DISPENSE) || !recipe)
		return TRUE

	if(root_category == RPD_CATEGORY_DISPOSAL)
		return do_disposal_build(A, user)
	return do_atmos_build(A, user, click_parameters)

/obj/item/rpd/proc/do_atmos_build(atom/A, mob/user, click_parameters)
	if(user.skill_fail_prob(SKILL_ATMOS, 80, SKILL_TRAINED))
		var/fumble_category_type = pick(GLOB.all_pipe_datums_by_category)
		var/list/fumble_category = GLOB.all_pipe_datums_by_category[fumble_category_type]
		recipe = pick(fumble_category)
		user.visible_message(SPAN_WARNING("\The [user] cluelessly fumbles with \the [src]."))

	var/turf/T = get_turf(A)
	if (!T.Adjacent(loc))
		return TRUE

	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	if (T.is_wall())
		var/obj/effect/construction_indicator/indicator = new(T, 3 SECONDS)
		var/success = do_after(user, 3 SECONDS, T, DO_PUBLIC_UNIQUE)
		qdel(indicator)
		if (!success)
			return TRUE
		playsound (get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)

	var/num_rotations
	if (user.skill_check(SKILL_ATMOS, SKILL_EXPERIENCED))
		num_rotations = get_placement_rotation(user, recipe.placement_mode, click_parameters)
	else
		num_rotations = rand(3)

	for(var/layer in get_active_layers())
		var/obj/item/pipe/pipe_item = recipe.Build(recipe, T, pipe_colors[pipe_color], layer)
		// p_init_dir is an absolute N/S/E/W bitmask (the RPD keypad's restricted directions) - not relative to
		// pipe_item.dir, so the random/skill-based rotation below doesn't need to touch it. Was previously never
		// set at all here, meaning every built smart pipe silently ignored the keypad and defaulted to all 4
		// directions open regardless of what was toggled off.
		pipe_item.p_init_dir = p_init_dir
		for (var/i = 0, i < num_rotations, i++)
			pipe_item.dir = GLOB.cw_dir[pipe_item.dir]
		if(mode & RPD_MODE_CONNECT)
			try_wrench_built(pipe_item, user)

	if (prob(20))
		spark_system.start()
	return TRUE

/// Auto-finalizes a just-dispensed /obj/item/pipe fitting into a real connected machinery object, reusing the
/// real wrench-build logic (pressure safety checks, network rebuild, etc.) via a throwaway wrench instance
/// rather than duplicating it. Mirrors NovaSector's own RPD, which wrenches the fitting immediately when its
/// WRENCH_MODE bit (this codebase's "Connect") is set instead of leaving it to a manual follow-up wrench.
/obj/item/rpd/proc/try_wrench_built(obj/item/pipe/pipe_item, mob/user)
	if(QDELETED(pipe_item))
		return
	var/obj/item/wrench/temp_wrench = new(src)
	pipe_item.use_tool(temp_wrench, user, list())
	qdel(temp_wrench)

/obj/item/rpd/proc/do_disposal_build(atom/A, mob/user)
	var/turf/T = get_turf(A)
	if(!T.Adjacent(loc))
		return TRUE
	if(T.is_wall())
		to_chat(user, SPAN_WARNING("You can't build a disposal pipe there."))
		return TRUE

	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	var/obj/effect/construction_indicator/indicator = new(T, 5 SECONDS)
	var/success = do_after(user, 5 SECONDS, T, DO_PUBLIC_UNIQUE)
	qdel(indicator)
	if(!success)
		return TRUE

	var/obj/structure/disposalconstruct/built = recipe.Build(recipe, T, PIPE_COLOR_GREY)
	playsound(get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)
	if(mode & RPD_MODE_CONNECT)
		try_finalize_disposal(built, user)
	if(prob(20))
		spark_system.start()
	return TRUE

/// Auto-finalizes a just-dispensed disposalconstruct the same way Connect mode does for atmos pipes. Disposal
/// pipes need two real tools to finish (wrench to anchor - which only works on bare plating, then a welder to
/// convert into the real /obj/structure/disposalpipe - see disposal-construction.dm's use_tool()); the wrench
/// step is simulated the same throwaway-item way as everywhere else in this file, but the weld step's real
/// version needs a fueled welder, so this replicates its actual end effect (build() + qdel_self()) directly
/// instead of fighting with welding-tool fuel-tank internals for a simulated tool that's about to be discarded.
/obj/item/rpd/proc/try_finalize_disposal(obj/structure/disposalconstruct/built, mob/user)
	if(QDELETED(built))
		return
	var/obj/item/wrench/temp_wrench = new(src)
	built.use_tool(temp_wrench, user, list())
	qdel(temp_wrench)
	if(QDELETED(built) || !built.anchored)
		return //couldn't anchor (e.g. not on plating) - leave it loose for the player to finish by hand
	var/obj/structure/disposalpipe/connected_pipe = locate() in get_turf(built)
	built.build(connected_pipe)
	qdel(built)

/obj/item/rpd/proc/do_reprogram(obj/machinery/atmospherics/pipe/smart/target, mob/user)
	if(target.p_init_dir == p_init_dir)
		to_chat(user, SPAN_WARNING("[target] is already configured that way."))
		return TRUE
	if(!do_after(user, 1 SECOND, target, DO_PUBLIC_UNIQUE))
		return TRUE
	if(QDELETED(target))
		return TRUE

	target.p_init_dir = p_init_dir
	target.node1 = null
	target.node2 = null
	target.node3 = null
	target.node4 = null
	target.set_dir(target.dir) //recomputes initialize_directions via get_initialze_directions()
	target.atmos_init()
	target.build_network()
	for(var/obj/machinery/atmospherics/neighbor in oview(1, target))
		neighbor.atmos_init()
		neighbor.build_network()

	user.visible_message(SPAN_NOTICE("[user] reprograms [target]."), SPAN_NOTICE("You reprogram [target]."))
	playsound(get_turf(target), 'sound/machines/click.ogg', 50, 1)
	return TRUE

/obj/item/rpd/proc/try_unwrench_built(obj/machinery/atmospherics/target, mob/user)
	var/obj/item/wrench/temp_wrench = new(src)
	target.use_tool(temp_wrench, user, list())
	qdel(temp_wrench)

/obj/item/rpd/proc/get_placement_rotation(mob/user, placement_mode, click_parameters)
	var/mouse_x = text2num(click_parameters[MOUSE_ICON_X])
	var/mouse_y = text2num(click_parameters[MOUSE_ICON_Y])
	switch (placement_mode)
		if (PIPE_PLACEMENT_SIMPLE)
			// Zero rotations as we use the default direction of the pipe
			return 0
		if (PIPE_PLACEMENT_DIAGONAL)
			// One case for each of the four quarters of a square
			//  0 │ 1
			// ───┼───
			//  3 │ 2
			if (mouse_x <= 16)
				if (mouse_y <= 16)
					. = 3
				else
					. = 0
			else
				if (mouse_y <= 16)
					. = 2
				else
					. = 1
		if (PIPE_PLACEMENT_ORTHOGONAL)
			// One case for each of the four triangles of a square
			//  ⟍ 0 ⟋
			//  3 ⤫ 1
			//  ⟋ 2 ⟍
			if (mouse_y > mouse_x)
				if (mouse_y > 32-mouse_x)
					. = 0
				else
					. = 3
			else
				if (mouse_y > 32-mouse_x)
					. = 1
				else
					. = 2

/obj/item/rpd/use_tool(obj/item/item, mob/living/user, list/click_params)
	if(istype(item, /obj/item/rpd_upgrade))
		var/obj/item/rpd_upgrade/disk = item
		if(disk.upgrade_flags & upgrade_flags)
			to_chat(user, SPAN_WARNING("[src] already has this upgrade installed."))
			return TRUE
		upgrade_flags |= disk.upgrade_flags
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("You install [disk] into [src]."))
		qdel(disk)
		return TRUE

	if(istype(item, /obj/item/pipe))
		if(!(mode & RPD_MODE_DESTROY))
			return ..()
		if(!user.unEquip(item))
			FEEDBACK_UNEQUIP_FAILURE(user, item)
			return TRUE
		recycle(item,user)
		return TRUE
	return ..()

/obj/item/rpd/proc/recycle(obj/item/W,mob/user)
	if(!user.skill_check(SKILL_ATMOS,SKILL_BASIC))
		user.visible_message("[user] struggles with \the [src], as they futilely jam \the [W] against it")
		return
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 1)
	qdel(W)

/obj/item/rpd_upgrade
	name = "RPD design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "datadisk0"
	w_class = ITEM_SIZE_SMALL
	var/upgrade_flags

/obj/item/rpd_upgrade/unwrench
	name = "RPD design disk - unwrench mode"
	desc = "Adds reverse-wrench mode to the RPD, letting it unfasten built pipe sections directly. Hard-linked to the Destroy mode toggle."
	upgrade_flags = RPD_UPGRADE_UNWRENCH

/datum/asset/spritesheet/pipes
	name = "pipes-tgui"

/datum/asset/spritesheet/pipes/create_spritesheets()
	insert_recipe_tree(GLOB.all_pipe_datums_by_category)
	insert_recipe_tree(GLOB.all_disposal_pipe_datums_by_category)

/datum/asset/spritesheet/pipes/proc/insert_recipe_tree(list/tree)
	for(var/subcategory_type in tree)
		var/list/recipes = tree[subcategory_type]
		for(var/datum/pipe/recipe in recipes)
			if(!recipe.build_icon || !recipe.build_icon_state)
				continue
			Insert(sanitize_css_class_name("[recipe.type]"), recipe.build_icon, recipe.build_icon_state, SOUTH)

#undef RPD_MODE_DISPENSE
#undef RPD_MODE_CONNECT
#undef RPD_MODE_DESTROY
#undef RPD_MODE_REPROGRAM
#undef RPD_PIPE_LAYER_BIT
#undef RPD_CATEGORY_ATMOS
#undef RPD_CATEGORY_DISPOSAL
#undef RPD_UPGRADE_UNWRENCH
