/*
	Ghost HUD TGUI datums
	Backs the four ghost screen buttons: Follow, Teleport, HUD Cycler, Ghost Roles.
*/

// ==================== FOLLOW MOB ====================

/mob/observer/ghost/proc/open_follow_ui()
	var/datum/tgui_ghost_follow/D = new(src)
	D.ui_interact(src)

/datum/tgui_ghost_follow
	var/mob/observer/ghost/ghost

/datum/tgui_ghost_follow/New(mob/observer/ghost/G)
	ghost = G
	..()

/datum/tgui_ghost_follow/Destroy()
	ghost = null
	return ..()

/datum/tgui_ghost_follow/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "GhostFollow", "Follow Mob")
		ui.open()

/datum/tgui_ghost_follow/ui_state(datum/tgui_state/state)
	return GLOB.tgui_ghost_state

// Returns how many active ghosts are currently following the given atom.
/datum/tgui_ghost_follow/proc/count_orbiters(atom/target)
	var/count = 0
	for(var/mob/observer/ghost/G in GLOB.ghost_mobs)
		if(G.following == target)
			count++
	return count

// Returns the sector name for a given z-level.
/datum/tgui_ghost_follow/proc/get_sector_name(z)
	var/obj/overmap/visitable/sector = map_sectors["[z]"]
	if(sector)
		return sector.name
	if(isPlayerLevel(z))
		return GLOB.using_map.name
	return null

// Extracts job display data for a given job title. Returns a list with color, icon_html, department, is_head.
/datum/tgui_ghost_follow/proc/get_job_data(job_title, mob/user, list/icon_cache)
	var/datum/job/DJ = SSjobs.get_by_title(job_title)
	if(!DJ)
		return list("", "", "", 0)
	var/job_color = DJ.selection_color
	var/department = DJ.department ? DJ.department : ""
	var/is_head = DJ.head_position
	if(!icon_cache[job_title])
		var/icon/I = icon(GLOB.using_map.id_hud_icons, DJ.hud_icon)
		icon_cache[job_title] = icon2html(I, user)
	return list(job_color, icon_cache[job_title], department, is_head)

/datum/tgui_ghost_follow/ui_data(mob/user)
	// Faction palette: station gets index 1, off-station factions cycle through the rest.
	var/list/faction_colors = list("blue", "purple", "teal", "olive", "lime", "brown")
	var/faction_color_idx = 1

	var/list/factions    = list() // ordered list of faction entries (name, color, members)
	var/list/faction_map = list() // sector_name -> faction entry (for dedup)
	var/list/simplemobs  = list()
	var/list/dead        = list()
	var/list/ghosts      = list()
	var/list/icon_cache  = list() // job_title -> icon2html result, per-call cache

	for(var/mob/living/L in world)
		// Mechs and simple animals go to simplemobs
		if(istype(L, /mob/living/exosuit) || istype(L, /mob/living/simple_animal))
			simplemobs += list(list(
				"ref"  = "\ref[L]",
				"name" = L.name,
				"type" = istype(L, /mob/living/exosuit) ? "mech" : "animal"
			))
			continue

		var/job_title = L.job ? L.job : "No Role"
		var/list/jdata = get_job_data(job_title, user, icon_cache)
		var/job_color  = jdata[1]
		var/job_icon   = jdata[2]
		var/department = jdata[3]
		var/is_head    = jdata[4]

		// Dead player mobs
		if(L.stat == DEAD && L.mind)
			dead += list(list(
				"ref"        = "\ref[L]",
				"name"       = L.name,
				"job"        = job_title,
				"job_color"  = job_color,
				"job_icon"   = job_icon,
				"department" = department,
				"is_head"    = is_head,
				"health_pct" = 0,
				"orbiters"   = count_orbiters(L)
			))
			continue

		// Alive player-controlled mobs (or admin-ghosted bodies with a mind)
		if(L.stat != DEAD && (L.client || L.mind))
			var/turf/T = get_turf(L)
			if(!T)
				continue

			var/sector_name = get_sector_name(T.z)
			if(!sector_name)
				continue

			var/oxy_pct = 100
			var/brain_pct = L.maxHealth > 0 ? max(0, 100 - round((L.getBrainLoss() / L.maxHealth) * 100)) : 100
			if(istype(L, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = L
				oxy_pct = round(H.get_blood_oxygenation())

			var/list/member = list(
				"ref"        = "\ref[L]",
				"name"       = L.name,
				"job"        = job_title,
				"job_color"  = job_color,
				"job_icon"   = job_icon,
				"department" = department,
				"is_head"    = is_head,
				"oxy_pct"    = oxy_pct,
				"brain_pct"  = brain_pct,
				"has_client" = L.client ? 1 : 0,
				"orbiters"   = count_orbiters(L)
			)

			if(!faction_map[sector_name])
				var/col = faction_colors[faction_color_idx]
				faction_color_idx = (faction_color_idx % length(faction_colors)) + 1
				var/list/faction_entry = list(
					"name"    = sector_name,
					"color"   = col,
					"members" = list()
				)
				faction_map[sector_name] = faction_entry
				factions += list(faction_entry)

			faction_map[sector_name]["members"] += list(member)

	// Active ghost mobs
	for(var/mob/observer/ghost/G in world)
		if(!G.client)
			continue
		ghosts += list(list(
			"ref"      = "\ref[G]",
			"name"     = G.name,
			"orbiters" = count_orbiters(G)
		))

	return list(
		"factions"   = factions,
		"simplemobs" = simplemobs,
		"dead"       = dead,
		"ghosts"     = ghosts
	)

/datum/tgui_ghost_follow/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	var/mob/observer/ghost/G = ghost
	if(!isghost(G))
		return

	switch(action)
		if("follow")
			var/atom/target = locate(params["ref"])
			if(!target)
				return TRUE
			G.start_following(target)
			return TRUE

// ==================== TELEPORT ====================

/mob/observer/ghost/proc/open_teleport_ui()
	var/datum/tgui_ghost_teleport/D = new(src)
	D.ui_interact(src)

/datum/tgui_ghost_teleport
	var/mob/observer/ghost/ghost

/datum/tgui_ghost_teleport/New(mob/observer/ghost/G)
	ghost = G
	..()

/datum/tgui_ghost_teleport/Destroy()
	ghost = null
	return ..()

/datum/tgui_ghost_teleport/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "GhostTeleport", "Teleport")
		ui.open()

/datum/tgui_ghost_teleport/ui_state(datum/tgui_state/state)
	return GLOB.tgui_ghost_state

/datum/tgui_ghost_teleport/ui_data(mob/user)
	// Build list of areas grouped by sector name then z-level.
	// Sectors are identified via map_sectors, falling back to GLOB.using_map.name for station z-levels.
	var/list/sectors = list() // sector_name -> list of area entries

	for(var/area/A in get_filtered_areas(list(GLOBAL_PROC_REF(is_not_space_area))))
		if(!A.has_turfs())
			continue

		// Determine which sector owns this z-level
		var/sector_name
		var/obj/overmap/visitable/sector = map_sectors["[A.z]"]
		if(sector)
			sector_name = sector.name
		else if(isPlayerLevel(A.z))
			sector_name = GLOB.using_map.name
		else
			continue

		if(!sectors[sector_name])
			sectors[sector_name] = list()

		sectors[sector_name] += list(list(
			"name"   = A.name,
			"ref"    = "\ref[A]",
			"z"      = A.z
		))

	// Convert to list for TGUI
	var/list/result = list()
	for(var/sname in sectors)
		result += list(list(
			"sector" = sname,
			"areas"  = sectors[sname]
		))

	return list("sectors" = result)

/datum/tgui_ghost_teleport/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	var/mob/observer/ghost/G = ghost
	if(!isghost(G))
		return

	switch(action)
		if("teleport")
			var/area/target_area = locate(params["ref"])
			if(!istype(target_area))
				return TRUE

			var/list/predicates = list()
			if(G.shall_check_if_holy())
				predicates += GLOBAL_PROC_REF(is_not_holy_turf)

			var/list/area_turfs = get_area_turfs(target_area, predicates)
			if(!length(area_turfs))
				to_chat(G, SPAN_WARNING("This area has been entirely made into sacred grounds!"))
				return TRUE

			G.ghost_to_turf(pick(area_turfs))
			return TRUE

// ==================== HUD CYCLER ====================

/mob/observer/ghost/proc/open_hud_cycler_ui()
	var/datum/tgui_ghost_huds/D = new(src)
	D.ui_interact(src)

/datum/tgui_ghost_huds
	var/mob/observer/ghost/ghost

/datum/tgui_ghost_huds/New(mob/observer/ghost/G)
	ghost = G
	..()

/datum/tgui_ghost_huds/Destroy()
	ghost = null
	return ..()

/datum/tgui_ghost_huds/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "GhostHudCycler", "HUD Cycler")
		ui.open()

/datum/tgui_ghost_huds/ui_state(datum/tgui_state/state)
	return GLOB.tgui_ghost_state

/datum/tgui_ghost_huds/ui_data(mob/user)
	var/mob/observer/ghost/G = ghost
	return list(
		"med_hud"           = G.medHUD,
		"antag_hud"         = G.antagHUD,
		"sec_hud"           = G.secHUD,
		"ghost_vision"      = G.ghostvision,
		"see_darkness"      = G.seedarkness,
		"antag_hud_allowed" = (config.antag_hud_allowed || (user.client && user.client.holder)) ? TRUE : FALSE
	)

/datum/tgui_ghost_huds/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	var/mob/observer/ghost/G = ghost
	if(!isghost(G))
		return

	switch(action)
		if("toggle_med_hud")
			G.medHUD = !G.medHUD
			if(G.medHUD)
				G.ensure_hud_loop()
			to_chat(G, SPAN_NOTICE("Medical HUD [G.medHUD ? "Enabled" : "Disabled"]"))
			return TRUE
		if("toggle_antag_hud")
			if(!config.antag_hud_allowed && !(G.client && G.client.holder))
				to_chat(G, SPAN_WARNING("Admins have disabled this for this round."))
				return TRUE
			if(jobban_isbanned(G, "AntagHUD"))
				to_chat(G, SPAN_WARNING("You have been banned from using this feature."))
				return TRUE
			if(config.antag_hud_restricted && !G.has_enabled_antagHUD && !(G.client && G.client.holder))
				G.can_reenter_corpse = 0
			if(!G.has_enabled_antagHUD && !(G.client && G.client.holder))
				G.has_enabled_antagHUD = 1
			G.antagHUD = !G.antagHUD
			if(G.antagHUD)
				G.ensure_hud_loop()
			to_chat(G, SPAN_NOTICE("AntagHUD [G.antagHUD ? "Enabled" : "Disabled"]"))
			return TRUE
		if("toggle_sec_hud")
			G.secHUD = !G.secHUD
			if(G.secHUD)
				G.ensure_hud_loop()
			to_chat(G, SPAN_NOTICE("Security HUD [G.secHUD ? "Enabled" : "Disabled"]"))
			return TRUE
		if("toggle_ghost_vision")
			G.ghostvision = !G.ghostvision
			G.updateghostsight()
			to_chat(G, SPAN_NOTICE("Ghost Vision [G.ghostvision ? "Enabled" : "Disabled"]"))
			return TRUE
		if("toggle_darkness")
			G.seedarkness = !G.seedarkness
			G.updateghostsight()
			to_chat(G, SPAN_NOTICE("Darkness [G.seedarkness ? "Enabled" : "Disabled"]"))
			return TRUE

// ==================== GHOST ROLES ====================

/mob/observer/ghost/proc/open_ghost_roles_ui()
	var/datum/tgui_ghost_roles/D = new(src)
	D.ui_interact(src)

/datum/tgui_ghost_roles
	var/mob/observer/ghost/ghost

/datum/tgui_ghost_roles/New(mob/observer/ghost/G)
	ghost = G
	..()

/datum/tgui_ghost_roles/Destroy()
	ghost = null
	return ..()

/datum/tgui_ghost_roles/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "GhostRoles", "Ghost Roles")
		ui.open()

/datum/tgui_ghost_roles/ui_state(datum/tgui_state/state)
	return GLOB.tgui_ghost_state

/datum/tgui_ghost_roles/ui_data(mob/user)
	var/list/submaps = list()

	for(var/thing in SSmapping.submaps)
		var/datum/submap/submap = thing
		if(!submap.available())
			continue
		if(!submap.jobs || !length(submap.jobs))
			continue

		var/list/jobs = list()
		for(var/job_name in submap.jobs)
			var/datum/job/submap/job = submap.jobs[job_name]
			// Skip full jobs; infinite slots have total_positions == 0
			if(job.total_positions > 0 && job.current_positions >= job.total_positions)
				continue
			if(!LAZYLEN(job.spawnpoints))
				continue

			var/slots_left
			if(job.total_positions == 0)
				slots_left = -1 // infinite
			else
				slots_left = job.total_positions - job.current_positions

			jobs += list(list(
				"title"      = job.title,
				"slots_left" = slots_left,
				"ref"        = "\ref[submap]"
			))

		if(!length(jobs))
			continue

		submaps += list(list(
			"name"      = submap.name,
			"archetype" = submap.pref_name,
			"jobs"      = jobs
		))

	return list("submaps" = submaps)

/datum/tgui_ghost_roles/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	var/mob/observer/ghost/G = ghost
	if(!isghost(G))
		return

	// Locate the submap referenced in params
	var/datum/submap/submap
	for(var/thing in SSmapping.submaps)
		var/datum/submap/S = thing
		if("\ref[S]" == params["ref"])
			submap = S
			break

	switch(action)
		if("jump")
			// Teleport ghost to a spawn point for the chosen job, without joining
			if(!istype(submap))
				return TRUE
			var/datum/job/submap/job = submap.jobs[params["job"]]
			if(!istype(job) || !LAZYLEN(job.spawnpoints))
				return TRUE
			G.ghost_to_turf(get_turf(pick(job.spawnpoints)))
			return TRUE

		if("join")
			// Convert ghost to new_player and join the chosen submap job
			if(!istype(submap))
				return TRUE
			if(!G.MayRespawn(TRUE, ANIMAL_SPAWN_DELAY))
				return TRUE

			var/datum/job/submap/job = submap.jobs[params["job"]]
			if(!istype(job))
				return TRUE
			if(!LAZYLEN(job.spawnpoints))
				to_chat(G, SPAN_WARNING("No spawn points available for that role."))
				return TRUE

			// Create a new_player shell and hand it the ghost's client
			var/mob/new_player/joiner = new /mob/new_player()
			joiner.key = G.key // transfers client from ghost to joiner
			submap.join_as(joiner, job)
			return TRUE
