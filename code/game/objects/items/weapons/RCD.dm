//Contains the rapid construction device.
//
// Modernized port of NovaSector's RCD: category/design-catalog construction driven by a tgui interface,
// disk-based upgrades, and a real Airlock Access panel - adapted onto this codebase's own use_tool/use_after
// click chain and turf/object construction idioms (no per-atom rcd_act() dispatch, no modern item_interaction
// click chain, and no ore-silo remote materials network exist here, so those parts of the original design were
// re-implemented as self-contained logic on the RCD itself instead of being ported file-for-file).

// design catalog modes - what kind of construction a design entry performs
#define RCD_TURF 1          // Floor/wall turf conversion (dynamic: open turf -> plating, plating -> wall)
#define RCD_STRUCTURE 2     // Spawns an object directly on the target turf (girder, frames, furniture, etc.)
#define RCD_WINDOWGRILLE 3  // Spawns a window, direction-aware
#define RCD_AIRLOCK 4       // Spawns an airlock/windoor, applies configured access

// upgrade disk bitflags
#define RCD_UPGRADE_FRAMES (1<<0)
#define RCD_UPGRADE_FURNISHING (1<<1)
#define RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN (1<<2)
#define RCD_ALL_UPGRADES (RCD_UPGRADE_FRAMES|RCD_UPGRADE_FURNISHING|RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN)

// Delay multiplier applied to back-to-back builds/deconstructions, discouraging spam-building. Bypassed by
// the "enhanced cooling" upgrade disk.
#define RCD_FREQUENT_USE_MULTIPLIER 3

GLOBAL_LIST_AS(rcd_designs, list(
	"Construction" = list(
		"Structures" = list(
			list("title" = "Floor / Wall", "mode" = RCD_TURF, "path" = null, "cost" = 3, "delay" = 2 SECONDS),
			list("title" = "Low Wall", "mode" = RCD_STRUCTURE, "path" = /obj/structure/wall_frame, "cost" = 1, "delay" = 2 SECONDS),
			list("title" = "Grille", "mode" = RCD_STRUCTURE, "path" = /obj/structure/grille, "cost" = 2, "delay" = 2 SECONDS),
			list("title" = "Window", "mode" = RCD_WINDOWGRILLE, "path" = /obj/structure/window/basic, "cost" = 4, "delay" = 3 SECONDS),
			list("title" = "Reinforced Window", "mode" = RCD_WINDOWGRILLE, "path" = /obj/structure/window/reinforced, "cost" = 6, "delay" = 4 SECONDS),
			list("title" = "Full-Tile Window", "mode" = RCD_WINDOWGRILLE, "path" = /obj/structure/window/basic/full, "cost" = 8, "delay" = 4 SECONDS),
			list("title" = "Full-Tile Reinforced Window", "mode" = RCD_WINDOWGRILLE, "path" = /obj/structure/window/reinforced/full, "cost" = 12, "delay" = 5 SECONDS),
		),
		"Machines" = list(
			list("title" = "Machine Frame", "mode" = RCD_STRUCTURE, "path" = /obj/machinery/constructable_frame/machine_frame/deconstruct, "cost" = 1, "delay" = 2 SECONDS),
			list("title" = "Computer Frame", "mode" = RCD_STRUCTURE, "path" = /obj/machinery/constructable_frame/computerframe/deconstruct, "cost" = 1, "delay" = 2 SECONDS),
		),
		"Furniture" = list(
			list("title" = "Chair", "mode" = RCD_STRUCTURE, "path" = /obj/structure/bed/chair/office, "cost" = 2, "delay" = 2 SECONDS),
			list("title" = "Table", "mode" = RCD_STRUCTURE, "path" = /obj/structure/table/standard, "cost" = 2, "delay" = 2 SECONDS),
			list("title" = "Glass Table", "mode" = RCD_STRUCTURE, "path" = /obj/structure/table/glass, "cost" = 3, "delay" = 2 SECONDS),
			list("title" = "Rack", "mode" = RCD_STRUCTURE, "path" = /obj/structure/table/rack, "cost" = 2, "delay" = 2 SECONDS),
			list("title" = "Bed", "mode" = RCD_STRUCTURE, "path" = /obj/structure/bed, "cost" = 3, "delay" = 2 SECONDS),
		),
	),
	"Airlocks" = list(
		"Windoors" = list(
			list("title" = "Windoor", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/window, "cost" = 15, "delay" = 4 SECONDS),
			list("title" = "Secure Windoor", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/window/brigdoor, "cost" = 18, "delay" = 5 SECONDS),
		),
		"Glass Airlocks" = list(
			list("title" = "Standard", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Command", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/command, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Security", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/security, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Engineering", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/engineering, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Medical", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/medical, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Virology", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/virology, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Mining", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/mining, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Atmospherics", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/atmos, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Research", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/research, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Science", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/science, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Sol", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/sol, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Freezer", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/freezer, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Maintenance", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/maintenance, "cost" = 12, "delay" = 5 SECONDS),
			list("title" = "Civilian", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/glass/civilian, "cost" = 12, "delay" = 5 SECONDS),
		),
		"Solid Airlocks" = list(
			list("title" = "Standard", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Command", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/command, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Security", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/security, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Infantry", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/infantry, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Engineering", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/engineering, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Medical", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/medical, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Virology", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/virology, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Mining", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/mining, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Atmospherics", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/atmos, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Research", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/research, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Corporate", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/corporate, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Science", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/science, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Sol", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/sol, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Civilian", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/civilian, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Chaplain", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/chaplain, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Freezer", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/freezer, "cost" = 10, "delay" = 5 SECONDS),
			list("title" = "Maintenance", "mode" = RCD_AIRLOCK, "path" = /obj/machinery/door/airlock/maintenance, "cost" = 10, "delay" = 5 SECONDS),
		),
	),
	//Empty - the UI shows the embedded Airlock Access panel instead of a design list when this root is selected.
	"Airlock Access" = list(),
))

// Visual "you're building here" marker shown on the target turf for the duration of a construct/deconstruct
// do_after - neither the RCD nor RPD had any such feedback before (NovaSector's own version, /obj/effect/
// constructing_effect, needs its own dedicated icon file we don't have - icons/effects/rcd.dmi there - so this
// draws a plain translucent box at runtime instead of needing new art). Shared by both RCD.dm and RPD.dm.
/obj/effect/construction_indicator
	name = "construction zone"
	icon = 'icons/effects/rcd.dmi'
	icon_state = "rcd"
	anchored = TRUE
	density = FALSE
	mouse_opacity = 0
	layer = EFFECTS_LAYER

/**
 * delay - the real do_after() delay this indicator is standing in for, used to pick the shortest looping
 * animation state that still covers it (states shorter than the real delay just loop - every "rcd*" state in
 * rcd.dmi has loop=1 - so it keeps playing correctly even if the real construction takes longer than any single
 * animation cycle).
 * reverse - TRUE for deconstruction, which uses the "_reverse" family of states instead.
 */
/obj/effect/construction_indicator/Initialize(mapload, delay = 0, reverse = FALSE)
	. = ..()
	var/state = "rcd"
	if(delay < 1 SECOND)
		state = "rcd_shortest"
	else if(delay < 2 SECONDS)
		state = "rcd_shorter"
	else if(delay < 3.7 SECONDS)
		state = "rcd_short"
	icon_state = reverse ? "[state]_reverse" : state

/// On a successful build, plays the short "finished" flourish before removing itself. On a successful
/// deconstruction there's nothing left to flourish over, so it just removes itself immediately - matches
/// NovaSector's own constructing_effect/end_animation().
/obj/effect/construction_indicator/proc/end_animation(reverse = FALSE)
	if(reverse)
		qdel(src)
		return
	icon_state = "rcd_end"
	QDEL_IN(src, 1.5 SECONDS)

/obj/item/rcd
	name = "rapid construction device"
	desc = "Small, portable, and far, far heavier than it looks, this gun-shaped device has a port into which one may insert compressed matter cartridges."
	icon = 'icons/obj/tools/rcd.dmi'
	icon_state = "rcd"
	opacity = 0
	density = FALSE
	anchored = FALSE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 2)

	var/datum/effect/spark_spread/spark_system
	var/stored_matter = 0
	var/max_stored_matter = 160

	/// bitflags of installed design-disk upgrades
	var/construction_upgrades = 0
	/// bitflags of upgrades this RCD variant can never accept
	var/banned_upgrades = 0

	/// currently selected root category (top-level tab, e.g. "Construction"/"Airlocks"/"Airlock Access")
	var/root_category
	/// currently selected sub-category (e.g. "Structures"/"Machines")
	var/design_category
	/// display name of the currently selected design
	var/design_title
	/// RCD_TURF/RCD_STRUCTURE/RCD_WINDOWGRILLE/RCD_AIRLOCK - what the currently selected design does
	var/rcd_design_mode
	/// typepath the currently selected design builds (null for the dynamic Floor/Wall entry)
	var/rcd_design_path
	/// if TRUE, clicking a target deconstructs it instead of building the selected design
	var/deconstruct_mode = FALSE
	/// number of builds/deconstructs currently resolving concurrently - used for the frequent-use delay debuff
	var/active_builds = 0

	var/canRwall = 0
	var/disabled = 0

	var/crafting = FALSE //Rapid Crossbow Device memes

	/// this RCD's own airlock electronics, configured via the Airlock Access tab and applied to newly built airlocks
	var/obj/item/airlock_electronics/airlock_electronics

/obj/item/rcd/Initialize()
	. = ..()
	root_category = GLOB.rcd_designs[1]
	select_first_design_in_root()

	airlock_electronics = new(src)
	airlock_electronics.name = "airlock access configuration"
	airlock_electronics.lockable = FALSE
	airlock_electronics.locked = FALSE

/obj/item/rcd/proc/select_first_design_in_root()
	var/list/root = GLOB.rcd_designs[root_category]
	for(var/cat_name in root)
		var/list/cat = root[cat_name]
		if(!length(cat))
			continue
		design_category = cat_name
		var/list/design = cat[1]
		rcd_design_mode = design["mode"]
		rcd_design_path = design["path"]
		design_title = design["title"]
		return
	design_category = null
	rcd_design_mode = null
	rcd_design_path = null
	design_title = null

/obj/item/rcd/proc/can_use(mob/user, turf/T)
	return (user.Adjacent(T) && user.get_active_hand() == src && !user.incapacitated())

/obj/item/rcd/examine(mob/user)
	. = ..()
	if(src.type == /obj/item/rcd && loc == user)
		to_chat(user, "It currently holds [stored_matter]/[max_stored_matter] matter-units.")
		if(construction_upgrades)
			to_chat(user, "It has the following upgrades installed:")
			if(construction_upgrades & RCD_UPGRADE_FRAMES)
				to_chat(user, "- Machine/computer frame designs")
			if(construction_upgrades & RCD_UPGRADE_FURNISHING)
				to_chat(user, "- Furniture designs")
			if(construction_upgrades & RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN)
				to_chat(user, "- Enhanced cooling")

/obj/item/rcd/New()
	..()
	src.spark_system = new /datum/effect/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	update_icon()	//Initializes the ammo counter

/obj/item/rcd/Destroy()
	qdel(spark_system)
	spark_system = null
	QDEL_NULL(airlock_electronics)
	return ..()

/obj/item/rcd/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/cartridge = W
		if(stored_matter >= max_stored_matter)
			to_chat(user, SPAN_WARNING("The RCD is at maximum capacity."))
			return TRUE
		var/matter_exchange = min(cartridge.remaining, max_stored_matter - stored_matter)
		stored_matter += matter_exchange
		cartridge.remaining -= matter_exchange
		if(cartridge.remaining <= 0)
			qdel(W)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("The RCD now holds [stored_matter]/[max_stored_matter] matter-units."))
		update_icon()
		return TRUE

	if(istype(W, /obj/item/rcd_upgrade))
		var/obj/item/rcd_upgrade/disk = W
		if(disk.upgrade & construction_upgrades)
			to_chat(user, SPAN_WARNING("[src] already has this upgrade installed."))
			return TRUE
		if(disk.upgrade & banned_upgrades)
			to_chat(user, SPAN_WARNING("[src] rejects the disk - this upgrade isn't compatible with this model."))
			return TRUE
		construction_upgrades |= disk.upgrade
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("You install [disk] into [src]."))
		qdel(disk)
		SStgui.update_uis(src)
		return TRUE

	if(isScrewdriver(W))
		crafting = !crafting
		if(!crafting)
			to_chat(user, SPAN_NOTICE("You reassemble the RCD"))
		else
			to_chat(user, SPAN_NOTICE("The RCD can now be modified."))
		return TRUE

	return ..()

/obj/item/rcd/attack_self(mob/user)
	ui_interact(user)

/obj/item/rcd/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "RapidConstructionDevice", name, ui)
	ui.open()

/obj/item/rcd/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/rcd))

/// CSS class (already including the size class - see /datum/asset/spritesheet/icon_class_name) for a design
/// catalog entry's preview icon, or null if the underlying type has no icon (shouldn't normally happen).
/obj/item/rcd/proc/get_design_icon_class(list/design)
	var/datum/asset/spritesheet/rcd/sheet = get_asset_datum(/datum/asset/spritesheet/rcd)
	return sheet.icon_class_name(sanitize_css_class_name(rcd_design_sprite_key(design["path"])))

/obj/item/rcd/ui_data(mob/user)
	var/list/data = list()
	data["storedMatter"] = stored_matter
	data["maxStoredMatter"] = max_stored_matter
	data["deconstructMode"] = deconstruct_mode

	data["rootCategories"] = list()
	for(var/cat_name in GLOB.rcd_designs)
		data["rootCategories"] += cat_name
	data["selectedRoot"] = root_category

	data["categories"] = list()
	var/list/root = GLOB.rcd_designs[root_category]
	for(var/sub_category in root)
		var/list/target_category = root[sub_category]
		if(!length(target_category))
			continue
		if(sub_category == "Machines" && !(construction_upgrades & RCD_UPGRADE_FRAMES))
			continue
		if(sub_category == "Furniture" && !(construction_upgrades & RCD_UPGRADE_FURNISHING))
			continue

		var/list/designs = list()
		for(var/list/design in target_category)
			designs += list(list("title" = design["title"], "icon" = get_design_icon_class(design)))
		data["categories"] += list(list("catName" = sub_category, "designs" = designs))

	data["selectedCategory"] = design_category
	data["selectedDesign"] = design_title

	if(root_category == "Airlock Access")
		var/list/ae_data = airlock_electronics.ui_data(user)
		for(var/key in ae_data)
			data[key] = ae_data[key]

	return data

/obj/item/rcd/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("root_category")
			var/new_root = params["root_category"]
			if(!isnull(GLOB.rcd_designs[new_root]))
				root_category = new_root
				select_first_design_in_root()
			. = TRUE

		if("design")
			var/category_name = params["category"]
			var/index = text2num(params["index"])
			var/list/root = GLOB.rcd_designs[root_category]
			if(!root)
				return
			var/list/category = root[category_name]
			if(!category)
				return
			if(category_name == "Machines" && !(construction_upgrades & RCD_UPGRADE_FRAMES))
				return
			if(category_name == "Furniture" && !(construction_upgrades & RCD_UPGRADE_FURNISHING))
				return
			var/list/design = category[index]
			if(!design)
				return
			design_category = category_name
			rcd_design_mode = design["mode"]
			rcd_design_path = design["path"]
			design_title = design["title"]
			. = TRUE

		if("toggle_deconstruct")
			deconstruct_mode = !deconstruct_mode
			. = TRUE

		else
			if(root_category == "Airlock Access")
				. = airlock_electronics.ui_act(action, params, ui, state)

/obj/item/rcd/use_after(atom/A, mob/living/user, click_parameters)
	if(disabled && !isrobot(user))
		return FALSE
	if(istype(get_area(A), /area/shuttle) || istype(A, /turf/space/transit))
		return FALSE

	if(deconstruct_mode)
		do_deconstruct(A, user)
	else
		do_construct(A, user)
	return TRUE

/obj/item/rcd/proc/apply_frequent_use_penalty(delay)
	if(active_builds > 0 && !(construction_upgrades & RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN))
		return delay * RCD_FREQUENT_USE_MULTIPLIER
	return delay

/obj/item/rcd/proc/do_construct(atom/target, mob/user)
	if(!can_use(user, get_turf(target)))
		return
	if(!rcd_design_mode)
		to_chat(user, SPAN_WARNING("No design selected."))
		return

	var/list/build = resolve_build(target)
	if(!build)
		to_chat(user, SPAN_WARNING("You can't build that here."))
		return

	var/cost = build["cost"]
	var/delay = apply_frequent_use_penalty(build["delay"])

	if(stored_matter < cost)
		lowAmmo(user)
		return

	user.visible_message(SPAN_NOTICE("\The [user] uses \a [src] to construct something."), SPAN_NOTICE("You begin constructing \a [design_title]."))
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)

	active_builds++
	var/obj/effect/construction_indicator/indicator = new(get_turf(target), delay)
	var/success = do_after(user, delay, target, DO_PUBLIC_UNIQUE)
	active_builds--

	if(!success || !can_use(user, get_turf(target)) || stored_matter < cost)
		qdel(indicator)
		return
	//re-validate - the target may have changed state during the delay
	build = resolve_build(target)
	if(!build || build["cost"] != cost)
		qdel(indicator)
		to_chat(user, SPAN_WARNING("[src] beeps - conditions changed, construction aborted."))
		return
	indicator.end_animation()

	stored_matter -= cost
	update_icon()
	playsound(get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)

	var/turf/build_turf = get_turf(target)
	var/result_path = build["path"]
	if(build["turf_result"])
		build_turf.ChangeTurf(build["turf_result"], keep_air = TRUE)
	else if(result_path)
		var/atom/movable/new_obj = new result_path(build_turf)
		if(istype(new_obj, /obj/structure/window))
			var/obj/structure/window/new_window = new_obj
			//full-tile windows have a fixed dir (e.g. dir=5) that means "spans the whole tile" - overwriting it
			//with the builder's facing direction breaks that and makes them render/behave as directional windows.
			if(!new_window.is_fulltile())
				new_window.set_dir(user.dir)
		else if(istype(new_obj, /obj/machinery/door/airlock))
			apply_airlock_access(new_obj)

	if(prob(20))
		spark_system.start()

/obj/item/rcd/proc/do_deconstruct(atom/target, mob/user)
	if(!can_use(user, get_turf(target)))
		return

	var/list/info = resolve_deconstruct(target)
	if(!info)
		to_chat(user, SPAN_WARNING("[src] can't deconstruct that."))
		return

	var/cost = info["cost"]
	var/delay = apply_frequent_use_penalty(info["delay"])

	if(stored_matter < cost)
		lowAmmo(user)
		return

	user.visible_message(SPAN_WARNING("\The [user] is using \a [src] to deconstruct \the [target]!"), SPAN_WARNING("You are deconstructing \the [target]!"))
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)

	active_builds++
	var/obj/effect/construction_indicator/indicator = new(get_turf(target), delay, TRUE)
	var/success = do_after(user, delay, target, DO_PUBLIC_UNIQUE)
	qdel(indicator)
	active_builds--

	if(!success || !can_use(user, get_turf(target)) || stored_matter < cost || QDELETED(target))
		return
	if(!resolve_deconstruct(target))
		to_chat(user, SPAN_WARNING("[src] beeps - conditions changed, deconstruction aborted."))
		return

	stored_matter -= cost
	update_icon()
	playsound(get_turf(user), 'sound/items/Deconstruct.ogg', 50, 1)

	if(isturf(target))
		var/turf/T = target
		if(istype(T, /turf/simulated/wall))
			T.ChangeTurf(/turf/simulated/floor/plating, keep_air = TRUE)
		else
			T.ChangeTurf(get_base_turf_by_area(T), keep_air = TRUE)
	else
		qdel(target)

/**
 * Returns list("cost"=,"delay"=,"path"=,"turf_result"=) describing what would be built on `target` with the
 * currently selected design, or null if the design can't be placed there. `path` is instantiated directly on
 * the target's turf; `turf_result` (only used by the dynamic Floor/Wall entry) is passed to ChangeTurf() instead.
 */
/obj/item/rcd/proc/resolve_build(atom/target)
	var/turf/T = get_turf(target)
	if(!istype(T))
		return null

	switch(rcd_design_mode)
		if(RCD_TURF)
			if(isopenturf(T) || isspaceturf(T))
				return list("cost" = 1, "delay" = 2 SECONDS, "turf_result" = /turf/simulated/floor/plating)
			if(istype(T, /turf/simulated/floor) && !istype(T, /turf/simulated/wall))
				if(T.contains_dense_objects())
					return null
				return list("cost" = 3, "delay" = 2 SECONDS, "turf_result" = /turf/simulated/wall)
			return null

		if(RCD_STRUCTURE)
			if(rcd_design_path == /obj/structure/grille)
				//grilles mount onto a low wall the same way a window does - a wall_frame alone shouldn't block them
				if(locate(/obj/structure/grille) in T)
					return null
				if(turf_blocked_ignoring(T, list(/obj/structure/wall_frame)))
					return null
				return list("cost" = get_selected_cost(), "delay" = get_selected_delay(), "path" = rcd_design_path)
			if(T.contains_dense_objects())
				return null
			return list("cost" = get_selected_cost(), "delay" = get_selected_delay(), "path" = rcd_design_path)

		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/window) in T)
				return null
			return list("cost" = get_selected_cost(), "delay" = get_selected_delay(), "path" = rcd_design_path)

		if(RCD_AIRLOCK)
			if(T.contains_dense_objects())
				return null
			return list("cost" = get_selected_cost(), "delay" = get_selected_delay(), "path" = rcd_design_path)

	return null

/// Same check as turf/contains_dense_objects(), but lets specific types through - used for grilles, which
/// should be buildable on a low wall (wall_frame) the same way they can already sit on a window frame.
/obj/item/rcd/proc/turf_blocked_ignoring(turf/T, list/ignore_types)
	if(T.density)
		return TRUE
	for(var/atom/A in T)
		if(!A.density)
			continue
		var/ignored = FALSE
		for(var/ignore_type in ignore_types)
			if(istype(A, ignore_type))
				ignored = TRUE
				break
		if(!ignored)
			return TRUE
	return FALSE

/obj/item/rcd/proc/get_selected_cost()
	var/list/design = find_selected_design()
	return design ? design["cost"] : 999999

/obj/item/rcd/proc/get_selected_delay()
	var/list/design = find_selected_design()
	return design ? design["delay"] : 999999

/obj/item/rcd/proc/find_selected_design()
	var/list/root = GLOB.rcd_designs[root_category]
	if(!root)
		return null
	var/list/category = root[design_category]
	if(!category)
		return null
	for(var/list/design in category)
		if(design["title"] == design_title && design["mode"] == rcd_design_mode && design["path"] == rcd_design_path)
			return design
	return null

/**
 * Returns list("cost"=,"delay"=) describing what it would cost to deconstruct `target`, or null if the RCD
 * can't deconstruct it (wrong type, or a reinforced structure without canRwall).
 */
/obj/item/rcd/proc/resolve_deconstruct(atom/target)
	if(istype(target, /obj/machinery/door/airlock))
		return list("cost" = 30, "delay" = 5 SECONDS)
	if(istype(target, /obj/machinery/door/window))
		return list("cost" = 15, "delay" = 4 SECONDS)
	if(istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if(W.reinf_material && !canRwall)
			return null
		return list("cost" = 4, "delay" = 2 SECONDS)
	if(istype(target, /obj/machinery/constructable_frame))
		return list("cost" = 4, "delay" = 2 SECONDS)
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/bed))
		return list("cost" = 4, "delay" = 2 SECONDS)
	if(istype(target, /obj/structure/wall_frame))
		return list("cost" = 4, "delay" = 2 SECONDS)
	if(istype(target, /obj/structure/girder))
		return list("cost" = 4, "delay" = 2 SECONDS)
	if(istype(target, /obj/structure/catwalk))
		return list("cost" = 2, "delay" = 1 SECOND)
	if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/W = target
		if(W.reinf_material && !canRwall)
			return null
		return list("cost" = 9, "delay" = 2 SECONDS)
	if(isturf(target))
		var/turf/T = target
		if(istype(T, /turf/simulated/floor) && !istype(T, /turf/simulated/floor/plating))
			return list("cost" = 9, "delay" = 2 SECONDS)
	return null

/obj/item/rcd/proc/apply_airlock_access(obj/machinery/door/airlock/A)
	if(!length(airlock_electronics.conf_access))
		return //no custom access configured - leave the airlock's own default (area-inherited) access alone
	A.autoset_access = FALSE
	if(airlock_electronics.one_access)
		A.req_access = list(airlock_electronics.conf_access.Copy())
	else
		A.req_access = airlock_electronics.conf_access.Copy()

/obj/item/rcd/proc/useResource(amount, mob/user)
	if(stored_matter < amount)
		return 0
	stored_matter -= amount
	queue_icon_update()	//Updates the ammo counter if ammo is succesfully used
	return 1

/obj/item/rcd/on_update_icon()	//For the fancy "ammo" counter
	ClearOverlays()
	var/ratio = 0
	ratio = stored_matter / max_stored_matter
	ratio = max(round(ratio, 0.10) * 100, 10)
	AddOverlays("rcd-[ratio]")

/obj/item/rcd/proc/lowAmmo(mob/user)	//Kludge to make it animate when out of ammo, but I guess you can make it blow up when it's out of ammo or something
	to_chat(user, SPAN_WARNING("The \'Low Ammo\' light on the device blinks yellow."))
	flick("[icon_state]-empty", src)

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "A highly-compressed matter cartridge usable in rapid construction (and deconstruction) devices, such as railguns."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 20000,MATERIAL_GLASS = 10000)
	var/remaining = 40

/obj/item/rcd_ammo/examine(mob/user, distance)
	. = ..()
	if(distance <= 1)
		to_chat(user, SPAN_NOTICE("It has [remaining] unit\s of matter left."))

/obj/item/rcd_ammo/large
	name = "high-capacity matter cartridge"
	desc = "Do not ingest."
	icon_state = "rcdlarge"
	matter = list(MATERIAL_STEEL = 60000,MATERIAL_GLASS = 30000)
	remaining = 160
	origin_tech = list(TECH_MATERIAL = 4)

/obj/item/rcd_upgrade
	name = "RCD design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "datadisk0"
	w_class = ITEM_SIZE_SMALL
	var/upgrade

/obj/item/rcd_upgrade/frames
	name = "RCD design disk - machine frames"
	desc = "Contains the design schema for machine and computer frames."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/furnishing
	name = "RCD design disk - furnishings"
	desc = "Contains the design schema for chairs, tables, racks, and beds."
	upgrade = RCD_UPGRADE_FURNISHING

/obj/item/rcd_upgrade/cooling
	name = "RCD design disk - enhanced cooling"
	desc = "Contains the upgrades necessary to allow more frequent use of the RCD without a construction speed penalty."
	upgrade = RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN

/obj/item/rcd/borg
	canRwall = 1
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_NO_TOOLS

/obj/item/rcd/borg/useResource(amount, mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			var/cost = amount*30
			if(R.cell.charge >= cost)
				R.cell.use(cost)
				return 1
	return 0

/obj/item/rcd/borg/can_use(mob/user,turf/T)
	return (user.Adjacent(T) && !user.incapacitated())


/obj/item/rcd/mounted
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_NO_TOOLS

/obj/item/rcd/mounted/useResource(amount, mob/user)
	var/cost = amount*20 // About 5 deconstructions of walls on a standard cell (1k), less if it involves airlocks.
	var/obj/item/cell/cell
	if(istype(loc,/obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.cell)
			cell = module.holder.cell
	else if(loc) cell = loc.get_cell()
	if(cell && cell.charge >= cost)
		cell.use(cost)
		return 1
	return 0

/obj/item/rcd/mounted/can_use(mob/user,turf/T)
	return (user.Adjacent(T) && !user.incapacitated())

/obj/item/rcd/ce
	name = "professional RCD"
	desc = "A higher-end model of the rapid construction device, pre-loaded with every design disk. Provided to the chief engineer."
	icon_state = "rcd"
	max_stored_matter = 240
	stored_matter = 240
	construction_upgrades = RCD_ALL_UPGRADES

/obj/item/rcd/combat
	name = "industrial RCD"
	desc = "A high-capacity RCD capable of deconstructing reinforced walls and windows."
	icon_state = "rcd"
	max_stored_matter = 500
	stored_matter = 500
	canRwall = 1
	construction_upgrades = RCD_ALL_UPGRADES

/obj/item/rcd/combat/admin
	name = "admin RCD"
	max_stored_matter = INFINITY
	stored_matter = INFINITY

/// Stable per-design key used to name spritesheet entries, shared between spritesheet generation and lookup.
/// Distinct designs from different categories can share a title (e.g. "Command" appears in both Glass and Solid
/// Airlocks) but never share a build path, so the path itself - stringified - is the safe uniqueness key. The
/// one exception is the dynamic Floor/Wall entry, whose path is null.
/proc/rcd_design_sprite_key(path)
	return path ? "[path]" : "dynamic-floor-wall"

/datum/asset/spritesheet/rcd
	name = "rcd-tgui"

/datum/asset/spritesheet/rcd/create_spritesheets()
	for(var/root_category in GLOB.rcd_designs)
		var/list/category_designs = GLOB.rcd_designs[root_category]
		for(var/category in category_designs)
			var/list/designs = category_designs[category]
			for(var/list/design in designs)
				var/atom/movable/path = design["path"]
				var/sprite_name = sanitize_css_class_name(rcd_design_sprite_key(path))
				if(ispath(path, /obj/machinery/door/airlock))
					InsertIcon(sprite_name, build_airlock_preview_icon(path))
					continue

				var/icon/source
				var/icon_state_name
				if(path)
					source = initial(path.icon)
					icon_state_name = initial(path.icon_state)
				else
					//the dynamic Floor/Wall entry has no build path. initial() doesn't reliably resolve var
					//values on /turf subtypes here (confirmed by direct testing - it just comes back null,
					//unlike on /obj/atom types), so this hardcodes plating's known icon/icon_state
					//(code/game/turfs/flooring/flooring_premade.dm) instead of trying to read them off a
					//never-instantiated turf reference. Plating is what this entry actually builds most often
					//(on open turfs); wall turfs use smoothing and would've rendered blank as a static preview
					//even if initial() worked on them.
					source = icon('icons/turf/flooring/plating.dmi')
					icon_state_name = "plating"
				if(!source || !icon_state_name)
					continue
				Insert(sprite_name, source, icon_state_name, SOUTH)

/// Airlocks all share the same base "closed" sprite - what actually distinguishes departments in-game is a
/// color tint blended on top (see /obj/machinery/door/airlock/proc/set_airlock_overlays(), airlock.dm), not a
/// different icon_state. Replicates just that one layer (skips the glass/fill-pattern overlay) for the preview.
/datum/asset/spritesheet/rcd/proc/build_airlock_preview_icon(obj/machinery/door/airlock/path)
	var/icon/base = icon(initial(path.icon), initial(path.icon_state))
	var/door_color = initial(path.door_color)
	if(door_color && door_color != "none")
		var/icon/color_layer = icon(initial(path.color_file), initial(path.icon_state))
		color_layer.Blend(door_color, ICON_MULTIPLY)
		base.Blend(color_layer, ICON_OVERLAY)
	return base

#undef RCD_TURF
#undef RCD_STRUCTURE
#undef RCD_WINDOWGRILLE
#undef RCD_AIRLOCK
#undef RCD_UPGRADE_FRAMES
#undef RCD_UPGRADE_FURNISHING
#undef RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN
#undef RCD_ALL_UPGRADES
#undef RCD_FREQUENT_USE_MULTIPLIER
