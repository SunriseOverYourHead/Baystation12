// TGUI backend for datum/preferences (character customization screen).
// Overrides open_setup_window/update_setup_window to open PreferencesMenu TGUI
// instead of the legacy browser popup.

// Global icon object cache — populated lazily. Avoids re-running icon() on every ui_data() call.
// Key format: "hair:<name>", "facialhair:<name>", "gear:<type_path>", "bp:<type_path>", "uw:<type>"
GLOBAL_LIST_EMPTY(tgui_icon_cache)

// Returns (and lazily creates) a cached icon object for the given sprite.
/proc/tgui_cache_icon(cache_key, icon_file, icon_state_val)
	if(!GLOB.tgui_icon_cache[cache_key])
		GLOB.tgui_icon_cache[cache_key] = icon(icon_file, icon_state_val)
	return GLOB.tgui_icon_cache[cache_key]

// Per-preferences: tracks which RSC filenames have already been sent this session.
// send_rsc() is skipped for names already in this list.
/datum/preferences/var/list/tgui_sent_rsc = list()

// Sends an RSC file to the client at most once per session. Returns rsc_name.
/datum/preferences/proc/tgui_send_icon(rsc_name, icon/ico)
	if(!client)
		return null
	if(!(rsc_name in tgui_sent_rsc))
		send_rsc(client, ico, rsc_name)
		tgui_sent_rsc[rsc_name] = TRUE
	return rsc_name

// Computes a safe RSC filename from a display name and a prefix.
/proc/tgui_rsc_name(prefix, display_name)
	var/safe = replacetext(display_name, " ", "_")
	safe = replacetext(safe, "'", "")
	safe = replacetext(safe, "/", "_")
	return "[prefix]_[safe].png"

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new /datum/tgui(user, src, "PreferencesMenu", "Character Preferences")
		ui.open()

/datum/preferences/open_setup_window(mob/user)
	if(!SScharacter_setup.initialized)
		return
	ui_interact(user)

/datum/preferences/update_setup_window(mob/user)
	SStgui.update_uis(src)

/datum/preferences/ui_state(mob/user)
	return GLOB.tgui_always_state

/datum/preferences/ui_data(mob/user)
	var/singleton/species/mob_species = GLOB.species_by_name[species]

	// Character slot name list
	var/list/profiles = list()
	for(var/i = 1 to config.character_slots)
		profiles += slot_names?[get_slot_key(i)]

	// Job preferences: job title -> priority level (1=Low, 2=Medium, 3=High)
	var/list/job_prefs = list()
	if(job_high)
		job_prefs[job_high] = 3
	if(istype(job_medium))
		for(var/j in job_medium)
			job_prefs[j] = 2
	if(istype(job_low))
		for(var/j in job_low)
			job_prefs[j] = 1

	// Selected antags: union of High and Low preference lists
	var/list/selected_antags = list()
	if(istype(be_special_role))
		for(var/id in be_special_role)
			selected_antags |= id
	if(istype(may_be_special_role))
		for(var/id in may_be_special_role)
			selected_antags |= id

	// Build appearance secondary features
	var/list/secondary = list()
	secondary["age"] = age
	secondary["pronouns"] = pronouns
	secondary["blood_type"] = b_type
	secondary["nearsighted"] = !!(disabilities & NEARSIGHTED)

	if(mob_species)
		if(length(mob_species.get_hair_styles()) > 1)
			secondary["head_hair_style"] = head_hair_style
		if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_HAIR_COLOR)
			secondary["hair_color"] = head_hair_color
		if(length(mob_species.get_facial_hair_styles(gender)) > 1)
			secondary["facial_hair_style"] = facial_hair_style
			if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_HAIR_COLOR)
				secondary["facial_hair_color"] = facial_hair_color
		if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_EYE_COLOR)
			secondary["eye_color"] = eye_color
		if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR)
			secondary["skin_color"] = skin_color
		else if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE)
			secondary["bs12_skin_tone"] = (-skin_tone) + 35
		if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_BASE_SKIN_COLOURS)
			secondary["base_skin"] = base_skin
		if(LAZYLEN(mob_species.descriptors))
			for(var/entry in mob_species.descriptors)
				secondary["bs12_desc_[entry]"] = body_descriptors?[entry] || 1


	// Build ordered uplink source names for TGUI
	var/list/tgui_uplink_names = list()
	if(islist(uplink_sources))
		for(var/singleton/uplink_source/US in uplink_sources)
			tgui_uplink_names += US.name
	return list(
		"window" = 0,
		"active_slot" = default_slot,
		"character_profiles" = profiles,
		"content_unlocked" = (!is_guest && !load_failed) ? TRUE : FALSE,
		"name_to_use" = "real_name",
		"character_preview_view" = build_tgui_preview(user),
		"character_preferences" = list(
			"names" = list("real_name" = real_name),
			"misc" = list(
				"gender" = gender,
				"species" = (mob_species ? mob_species.name : SPECIES_HUMAN),
				"joblessrole" = max(1, alternate_option + 1),
				"job_clothes" = FALSE,
				"loadout_lists" = list(
					"loadout" = build_tgui_loadout(),
					"loadouts" = list("Default"),
				),
				"loadout_index" = "Default",
				"spawnpoint" = spawnpoint,
			),
			"secondary_features" = secondary,
			"non_contextual" = list(
				"random_body" = 2,
				"metadata" = (metadata || ""),
				"spawnpoint" = spawnpoint,
			),
			"flavor_texts" = list(
				"general" = (flavor_texts["general"] || ""),
				"head"    = (flavor_texts["head"]    || ""),
				"face"    = (flavor_texts["face"]    || ""),
				"eyes"    = (flavor_texts["eyes"]    || ""),
				"torso"   = (flavor_texts["torso"]   || ""),
				"arms"    = (flavor_texts["arms"]    || ""),
				"hands"   = (flavor_texts["hands"]   || ""),
				"legs"    = (flavor_texts["legs"]    || ""),
				"feet"    = (flavor_texts["feet"]    || ""),
			),
			"robot_flavor_texts" = (islist(flavour_texts_robot) ? flavour_texts_robot.Copy() : list()),
			"robot_module_names" = (SSrobots?.initialized ? SSrobots.all_module_names.Copy() : list()),
			"records" = list(
				"public_record" = (public_record || ""),
				"med_record"    = (med_record    || ""),
				"sec_record"    = (sec_record    || ""),
				"gen_record"    = (gen_record    || ""),
				"memory"        = (memory        || ""),
				"email_addr"    = (email_addr    || ""),
				"email_pass"    = (email_pass    || ""),
			),
			"features" = list(),
			"clothing" = list(),
			"supplemental_features" = list(),
			"manually_rendered_features" = list(),
			"randomization" = list(),
			"game_preferences" = list(),
			"vocals" = list(),
		),
		"job_preferences" = job_prefs,
		"job_bans" = list(),
		"selected_antags" = selected_antags,
		"overflow_role" = (GLOB.using_map?.default_assistant_title || "Crewman"),
		"default_quirk_balance" = 0,
		"selected_quirks" = list(),
		"selected_personalities" = null,
		"max_personalities" = 0,
		"mood_enabled" = FALSE,
		"species_disallowed_quirks" = list(),
		"exploit_record" = (exploit_record || ""),
		"laws" = islist(laws) ? laws.Copy() : list(),
		"is_shackled" = is_shackled,
		"has_posibrain" = !!(mob_species && mob_species.has_organ[BP_POSIBRAIN]),
		"uplink_sources" = tgui_uplink_names,
		"antag_bans" = list(),
		"antag_days_left" = list(),
		"keybindings" = list(),
		"is_nova_star" = FALSE,
		"erp_pref" = FALSE,
		"ckey" = (client ? client.ckey : ""),
		"is_donator" = FALSE,
		"robotic_styles" = build_tgui_robotic_styles(),
		"limbs_data" = build_tgui_limbs_data(),
		"organs_data" = build_tgui_organs_data(),
		"marking_presets" = list(),
		"selected_languages" = build_tgui_selected_languages(),
		"unselected_languages" = build_tgui_unselected_languages(),
		"total_language_points" = MAX_LANGUAGES,
		"quirk_points_enabled" = 0,
		"quirks_balance" = 0,
		"positive_quirk_count" = 0,
		"job_days_left" = list(),
		"job_required_experience" = list(),
		"species_restricted_jobs" = build_species_restricted_jobs(mob_species),
		"job_alt_titles" = islist(player_alt_titles) ? player_alt_titles : list(),
		"map_has_branch" = !!(GLOB.using_map && (GLOB.using_map.flags & MAP_HAS_BRANCH)),
		"job_branches" = islist(branches) ? branches : list(),
		"job_ranks" = islist(ranks) ? ranks : list(),
		"hiding_maps" = islist(hiding_maps) ? hiding_maps.Copy() : list(),
		"cultural_info" = islist(cultural_info) ? cultural_info.Copy() : list(),
		"backpack" = (backpack ? backpack.name : ""),
		"underwear" = islist(all_underwear) ? all_underwear.Copy() : list(),
		"uniforms_by_job" = islist(uniforms_by_job) ? uniforms_by_job.Copy() : list(),
		"skill_jobs" = build_tgui_skill_jobs(),
		"sensor_setting" = (isnull(sensor_setting) ? SUIT_SENSOR_OFF : sensor_setting),
		"sidebar_icons" = build_tgui_sidebar_icons(),
		"server_data" = build_tgui_server_data(mob_species),
	)

/datum/preferences/proc/build_tgui_server_data(singleton/species/mob_species)
	var/map_has_branch = !!(GLOB.using_map && (GLOB.using_map.flags & MAP_HAS_BRANCH))
	var/map_has_rank   = !!(GLOB.using_map && (GLOB.using_map.flags & MAP_HAS_RANK))

	// Build job → maps reverse index for dynamic filtering
	// Strip BYOND text macros (\improper etc.) from map names so keys are plain text
	var/list/job_to_maps = list()
	if(SSjobs?.initialized)
		for(var/map_name in SSjobs.job_lists_by_map_name)
			var/clean_name = replacetext(map_name, "\improper ", "")
			var/list/map_list_data = SSjobs.job_lists_by_map_name[map_name]
			for(var/datum/job/MJ in map_list_data["jobs"])
				if(!islist(job_to_maps[MJ.title]))
					job_to_maps[MJ.title] = list()
				job_to_maps[MJ.title] |= clean_name

	// Jobs
	var/list/departments = list()
	var/list/jobs_map = list()
	if(SSjobs?.initialized)
		for(var/job_type in SSjobs.types_to_datums)
			var/datum/job/J = SSjobs.types_to_datums[job_type]
			var/dept = J.department
			// Jobs with no department var: assign by type
			if(!dept)
				if(istype(J, /datum/job/hop))
					dept = "Command"
				else if(istype(J, /datum/job/ai) || istype(J, /datum/job/cyborg))
					dept = "Silicon"
				else if(istype(J, /datum/job/submap))
					dept = "Exploration"
				else
					continue // skip other undepartmented jobs
			if(!departments[dept])
				departments[dept] = list("head" = null)
			if(J.head_position)
				// Captain always takes priority as Command head over HOP
				if(isnull(departments[dept]["head"]) || istype(J, /datum/job/captain))
					departments[dept]["head"] = J.title
			jobs_map[J.title] = list(
				"description" = J.get_description_blurb() || "",
				"department" = dept,
				"maps" = (islist(job_to_maps[J.title]) ? job_to_maps[J.title].Copy() : list()),
			)
			// alt_titles is an assoc list (title -> outfit path); extract keys only
			if(islist(J.alt_titles) && length(J.alt_titles))
				var/list/alt_keys = list()
				for(var/k in J.alt_titles)
					alt_keys += k
				jobs_map[J.title]["alt_titles"] = alt_keys
			// Branch/rank availability matrix — only built on branch-enabled maps
			if(map_has_branch && GLOB.mil_branches)
				var/list/branch_rank_matrix = list()
				var/list/avail_branch_names = list()
				var/list/spawn_brs = GLOB.mil_branches.spawn_branches(mob_species)
				if(J.allowed_branches)
					for(var/branch_type in J.allowed_branches)
						var/datum/mil_branch/allowed_B = GLOB.mil_branches.get_branch_by_type(branch_type)
						if(allowed_B && (allowed_B.name in spawn_brs))
							avail_branch_names += allowed_B.name
				else
					for(var/bname_iter in spawn_brs)
						avail_branch_names += bname_iter
				for(var/bname in avail_branch_names)
					var/list/rk_names = list()
					if(map_has_rank)
						var/list/spawn_rks = GLOB.mil_branches.spawn_ranks(bname, mob_species)
						if(spawn_rks)
							if(J.allowed_ranks)
								for(var/rank_type in J.allowed_ranks)
									var/datum/mil_rank/allowed_R = rank_type
									if(initial(allowed_R.name) in spawn_rks)
										rk_names += initial(allowed_R.name)
							else
								for(var/rname in spawn_rks)
									rk_names += rname
					branch_rank_matrix[bname] = rk_names
				if(length(branch_rank_matrix))
					jobs_map[J.title]["branch_rank"] = branch_rank_matrix

	// Species
	var/list/species_map = list()
	for(var/spec_name in GLOB.playable_species)
		var/singleton/species/S = GLOB.species_by_name[spec_name]
		if(!S)
			continue
		var/sp_rsc = ""
		if(S.preview_icon)
			var/sp_ico = tgui_cache_icon("species:[S.name]", S.preview_icon, "")
			var/sp_rsc_name = tgui_send_icon(tgui_rsc_name("sp", S.name), sp_ico)
			if(sp_rsc_name)
				sp_rsc = sp_rsc_name
		species_map[S.name] = list(
			"name" = S.name,
			"desc" = S.description || "",
			"lore" = list(),
			"icon" = sp_rsc,
			"use_skintones" = !!(S.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE),
			"sexes" = (length(S.genders) > 1),
			"enabled_features" = build_species_enabled_features(S),
			"nova_stars_only" = FALSE,
			"perks" = list("positive" = list(), "negative" = list(), "neutral" = list()),
		)

	// Spawnpoint choices (built early, used in both feature_data and the return list)
	var/list/spawnpoint_keys = list()
	for(var/k in spawntypes())
		spawnpoint_keys += k

	// Per-feature server data (species-specific choices/ranges)
	var/list/feature_data = list()

	var/min_age = mob_species ? mob_species.min_age : 17
	var/max_age = mob_species ? mob_species.max_age : 70
	feature_data["age"] = list("minimum" = min_age, "maximum" = max_age, "step" = 1)

	if(mob_species)
		// get_hair_styles()/get_facial_hair_styles() return ASSOC lists (name→accessory).
		// Extract only the keys so JSON serializes as [] not {}.
		var/list/hair_keys = list()
		var/list/hair_icons = list()
		for(var/k in mob_species.get_hair_styles())
			hair_keys += k
			var/datum/sprite_accessory/H = GLOB.hair_styles_list[k]
			if(H && H.icon)
				var/state = H.preview_state ? H.preview_state : "[H.icon_state]_s"
				var/ico = tgui_cache_icon("hair:[k]", H.icon, state)
				var/rsc_name = tgui_send_icon(tgui_rsc_name("hair", k), ico)
				if(rsc_name)
					hair_icons[k] = rsc_name
		var/has_hair_color = !!(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_HAIR_COLOR)
		feature_data["head_hair_style"] = list("choices" = hair_keys, "icons" = hair_icons, "supplemental_feature" = has_hair_color ? "hair_color" : null)

		var/list/facial_keys = list()
		var/list/facial_icons = list()
		for(var/k in mob_species.get_facial_hair_styles(gender))
			facial_keys += k
			var/datum/sprite_accessory/FH = GLOB.facial_hair_styles_list[k]
			if(FH && FH.icon)
				var/state = FH.preview_state ? FH.preview_state : "[FH.icon_state]_s"
				var/ico = tgui_cache_icon("facialhair:[k]", FH.icon, state)
				var/rsc_name = tgui_send_icon(tgui_rsc_name("facialhair", k), ico)
				if(rsc_name)
					facial_icons[k] = rsc_name
		feature_data["facial_hair_style"] = list("choices" = facial_keys, "icons" = facial_icons, "supplemental_feature" = has_hair_color ? "facial_hair_color" : null)

		// pronouns is a regular list — serializes as [] directly
		feature_data["pronouns"] = list("choices" = mob_species.pronouns)
		if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE)
			feature_data["bs12_skin_tone"] = list("minimum" = 1, "maximum" = mob_species.max_skin_tone(), "step" = 1)
		if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_BASE_SKIN_COLOURS)
			// base_skin_colours is ASSOC (name→color) — extract keys only
			var/list/skin_keys = list()
			for(var/k in mob_species.base_skin_colours)
				skin_keys += k
			feature_data["base_skin"] = list("choices" = skin_keys)
		if(LAZYLEN(mob_species.descriptors))
			for(var/entry in mob_species.descriptors)
				var/datum/mob_descriptor/descriptor = mob_species.descriptors[entry]
				var/list/desc_choices = list()
				for(var/i = 1 to LAZYLEN(descriptor.standalone_value_descriptors))
					desc_choices += descriptor.standalone_value_descriptors[i]
				feature_data["bs12_desc_[entry]"] = list("choices" = desc_choices)
	else
		feature_data["pronouns"] = list("choices" = PRONOUNS_ALL)
		// GLOB.hair_styles_list and GLOB.facial_hair_styles_list are ASSOC — extract keys only
		var/list/hair_keys = list()
		var/list/hair_icons = list()
		for(var/k in GLOB.hair_styles_list)
			hair_keys += k
			var/datum/sprite_accessory/H = GLOB.hair_styles_list[k]
			if(H.icon)
				var/state = H.preview_state ? H.preview_state : "[H.icon_state]_s"
				var/ico = tgui_cache_icon("hair:[k]", H.icon, state)
				var/rsc_name = tgui_send_icon(tgui_rsc_name("hair", k), ico)
				if(rsc_name)
					hair_icons[k] = rsc_name
		feature_data["head_hair_style"] = list("choices" = hair_keys, "icons" = hair_icons, "supplemental_feature" = "hair_color")

		var/list/facial_keys = list()
		var/list/facial_icons = list()
		for(var/k in GLOB.facial_hair_styles_list)
			facial_keys += k
			var/datum/sprite_accessory/FH = GLOB.facial_hair_styles_list[k]
			if(FH.icon)
				var/state = FH.preview_state ? FH.preview_state : "[FH.icon_state]_s"
				var/ico = tgui_cache_icon("facialhair:[k]", FH.icon, state)
				var/rsc_name = tgui_send_icon(tgui_rsc_name("facialhair", k), ico)
				if(rsc_name)
					facial_icons[k] = rsc_name
		feature_data["facial_hair_style"] = list("choices" = facial_keys, "icons" = facial_icons, "supplemental_feature" = "facial_hair_color")

	feature_data["blood_type"] = list("choices" = valid_bloodtypes)
	feature_data["metadata"] = list("maximum_length" = 1024)
	feature_data["spawnpoint"] = list("choices" = spawnpoint_keys)

	// Build branch name → short-name lookup for TGUI display
	var/list/mil_branches_info = list()
	if(map_has_branch && GLOB.mil_branches?.branches)
		for(var/bname in GLOB.mil_branches.branches)
			var/datum/mil_branch/B = GLOB.mil_branches.branches[bname]
			mil_branches_info[bname] = B.name_short || bname

	// Build rank name → abbreviation lookup for TGUI display
	var/list/rank_shorts = list()
	if(map_has_rank && GLOB.mil_branches?.branches)
		for(var/bname in GLOB.mil_branches.branches)
			var/datum/mil_branch/B = GLOB.mil_branches.branches[bname]
			if(!islist(B.ranks))
				continue
			for(var/rname in B.ranks)
				var/datum/mil_rank/R = B.ranks[rname]
				if(R.name_short)
					rank_shorts[rname] = R.name_short



	// Available shackling lawsets for TGUI
	var/list/tgui_lawsets = list()
	for(var/law_set_type in subtypesof(/datum/ai_laws))
		var/datum/ai_laws/ai_laws_check = law_set_type
		if(initial(ai_laws_check.shackles))
			var/datum/ai_laws/ls_inst = new law_set_type()
			var/list/datum/ai_law/ls_laws = ls_inst.all_laws()
			var/list/law_texts = list()
			for(var/datum/ai_law/law in ls_laws)
				law_texts += "[law.law]"
			tgui_lawsets += list(list(
				"name" = initial(ai_laws_check.name),
				"laws" = law_texts
		))
	// Build available uplink source options for TGUI
	var/list/tgui_uplink_options = list()
	for(var/singleton/uplink_source/US in GLOB.default_uplink_source_priority)
		tgui_uplink_options += US.name

	// Available job maps for hiding_maps UI (strip BYOND text macros for clean display keys)
	var/list/tgui_map_names = list()
	if(SSjobs?.initialized)
		for(var/mn in SSjobs.job_lists_by_map_name)
			tgui_map_names += replacetext(mn, "\improper ", "")

	// Backpack options for TGUI
	var/list/tgui_backpack_choices = list()
	var/list/tgui_backpack_icons = list()
	var/list/bp_map = GET_SINGLETON_SUBTYPE_MAP(/singleton/backpack_outfit)
	for(var/bp_name in bp_map)
		var/singleton/backpack_outfit/bo = bp_map[bp_name]
		tgui_backpack_choices += bp_name
		if(bo.path)
			var/bp_icon_file = initial(bo.path:icon)
			if(bp_icon_file)
				var/bp_ico = tgui_cache_icon("bp:[bo.path]", bp_icon_file, initial(bo.path:icon_state))
				var/bp_rsc = tgui_send_icon(tgui_rsc_name("bp", bp_name), bp_ico)
				if(bp_rsc)
					tgui_backpack_icons[bp_name] = bp_rsc



	// Uniform options for TGUI (per-job, requires branch+rank to be set)
	var/list/tgui_uniform_options = list()
	if(map_has_branch && GLOB.mil_branches && SSjobs?.initialized)
		for(var/job_type in SSjobs.types_to_datums)
			var/datum/job/UJ = SSjobs.types_to_datums[job_type]
			var/branch_name = islist(branches) ? branches[UJ.title] : null
			var/rank_name = islist(ranks) ? ranks[UJ.title] : null
			if(!branch_name || !rank_name)
				continue
			var/datum/mil_branch/UB = GLOB.mil_branches.get_branch(branch_name)
			var/datum/mil_rank/UR = UB ? GLOB.mil_branches.get_rank(branch_name, rank_name) : null
			if(!UB || !UR)
				continue
			var/list/unif_cats = find_uniforms(UR, UB, UJ.department_flag, FALSE, FALSE)
			if(!islist(unif_cats))
				continue
			var/list/job_options = list()
			for(var/cat_name in unif_cats)
				var/list/pieces = unif_cats[cat_name]
				var/list/piece_list = list()
				for(var/piece in pieces)
					if(isnull(piece))
						continue
					var/obj/item/clothing/C = piece
					piece_list += list(list("ref" = "[piece]", "name" = initial(C.name)))
				if(length(piece_list))
					job_options[cat_name] = piece_list
			if(length(job_options))
				tgui_uniform_options[UJ.title] = job_options
	// Cultural info options for TGUI (species-specific)
	var/list/tgui_cultural_options = list()
	var/list/cultural_tags = ALL_CULTURAL_TAGS
	for(var/tag in cultural_tags)
		var/list/avail_values
		if(mob_species)
			if(mob_species.force_cultural_info[tag])
				avail_values = list(mob_species.force_cultural_info[tag])
			else
				avail_values = mob_species.available_cultural_info[tag]
		else
			avail_values = GLOB.using_map?.available_cultural_info[tag]
		tgui_cultural_options[tag] = islist(avail_values) ? avail_values.Copy() : list()
	// Underwear options for TGUI
	var/list/tgui_underwear_options = list()
	for(var/datum/category_group/underwear/UWC in GLOB.underwear.categories)
		var/list/uw_item_names = list()
		var/list/uw_item_icons = list()
		for(var/iname in UWC.items_by_name)
			uw_item_names += iname
			var/datum/category_item/underwear/UWI = UWC.items_by_name[iname]
			if(UWI && UWI.icon && UWI.icon_state)
				var/uw_ico = tgui_cache_icon("uw:[UWI.type]", UWI.icon, UWI.icon_state)
				var/uw_rsc = tgui_send_icon(tgui_rsc_name("uw", "[UWC.name]_[iname]"), uw_ico)
				if(uw_rsc)
					uw_item_icons[iname] = uw_rsc
		tgui_underwear_options[UWC.name] = list("choices" = uw_item_names, "icons" = uw_item_icons)
	// Build static skill tree
	var/list/tgui_skill_tree = list()
	if(length(GLOB.skills))
		var/singleton/hierarchy/skill/root = GET_SINGLETON(/singleton/hierarchy/skill)
		for(var/singleton/hierarchy/skill/cat in root.children)
			var/list/cat_skills = list()
			for(var/singleton/hierarchy/skill/S in cat.children)
				var/list/skill_levels = list()
				for(var/i = 1, i <= length(S.levels), i++)
					skill_levels += list(list("name" = S.levels[i], "cost" = S.get_cost(i)))
				var/list/skill_prereqs = list()
				if(islist(S.prerequisites))
					for(var/prereq_type in S.prerequisites)
						skill_prereqs["[prereq_type]"] = S.prerequisites[prereq_type]
				var/list/skill_children = list()
				for(var/singleton/hierarchy/skill/perk in S.children)
					var/list/perk_levels = list()
					for(var/i = 1, i <= length(perk.levels), i++)
						perk_levels += list(list("name" = perk.levels[i], "cost" = perk.get_cost(i)))
					var/list/perk_prereqs = list()
					if(islist(perk.prerequisites))
						for(var/prereq_type in perk.prerequisites)
							perk_prereqs["[prereq_type]"] = perk.prerequisites[prereq_type]
					skill_children += list(list("id" = perk.ID, "type" = "[perk.type]", "name" = perk.name, "desc" = perk.desc, "levels" = perk_levels, "prerequisites" = perk_prereqs))
				cat_skills += list(list("id" = S.ID, "type" = "[S.type]", "name" = S.name, "desc" = S.desc, "levels" = skill_levels, "prerequisites" = skill_prereqs, "children" = skill_children))
			tgui_skill_tree += list(list("id" = cat.ID, "name" = cat.name, "skills" = cat_skills))
	return list(
		"jobs" = list(
			"departments" = departments,
			"jobs" = jobs_map,
		),
		"spawnpoints" = spawnpoint_keys,
		"names" = list(
			"types" = list(
				"real_name" = list(
					"can_randomize" = TRUE,
					"explanation" = "Your character's full name.",
					"group" = "Character",
				),
			),
		),
		"quirks" = list(
			"max_positive_quirks" = 0,
			"quirk_info" = list(),
			"quirk_blacklist" = list(),
			"points_enabled" = FALSE,
		),
		"personality" = list(
			"personalities" = list(),
			"personality_incompatibilities" = list(),
		),
		"random" = list(
			"randomizable" = list(),
		),
		"loadout" = list(
			"loadout_tabs" = build_tgui_loadout_tabs(),
		),
		"mil_branches" = mil_branches_info,
		"rank_shorts" = rank_shorts,
		"uplink_source_options" = tgui_uplink_options,
		"available_maps" = tgui_map_names,
		"backpack_options" = list("choices" = tgui_backpack_choices, "icons" = tgui_backpack_icons),
		"underwear_options" = tgui_underwear_options,
		"cultural_options" = tgui_cultural_options,
		"cultural_tag_labels" = ALL_CULTURAL_TAGS,
		"uniform_options" = tgui_uniform_options,
		"skill_tree" = tgui_skill_tree,
		"sensor_modes" = list("Off" = SUIT_SENSOR_OFF, "Binary" = SUIT_SENSOR_BINARY, "Vitals" = SUIT_SENSOR_VITAL, "Tracking" = SUIT_SENSOR_TRACKING),
		"lawsets" = tgui_lawsets,
		"species" = species_map,
	) + feature_data

/datum/preferences/proc/build_tgui_skill_jobs()
	var/list/result = list()
	if(!length(GLOB.skills))
		return result
	for(var/job_name in SSjobs.titles_to_datums)
		var/datum/job/job = SSjobs.get_by_title(job_name)
		if(!job || job.skill_points == 0)
			continue
		var/remaining = isnull(points_by_job[job]) ? job.skill_points : points_by_job[job]
		var/list/skill_levels = list()
		for(var/singleton/hierarchy/skill/S in GLOB.skills)
			var/s_min = get_min_skill(job, S)
			var/s_max = get_max_skill(job, S)
			var/s_cur = get_total_skill_value(job, S)
			if(!s_cur)
				s_cur = s_min
			skill_levels["[S.type]"] = list("min" = s_min, "max" = s_max, "current" = s_cur)
		result[job_name] = list("points_remaining" = remaining, "skills" = skill_levels)
	return result

/datum/preferences/proc/build_tgui_robotic_styles()
	var/list/styles = list()
	for(var/company in chargen_robolimbs)
		styles += company
	return styles

/datum/preferences/proc/build_tgui_limbs_data()
	var/list/limbs = list()
	var/list/limb_defs = list(
		list("slot" = BP_L_ARM,  "name" = "Left Arm"),
		list("slot" = BP_R_ARM,  "name" = "Right Arm"),
		list("slot" = BP_L_LEG,  "name" = "Left Leg"),
		list("slot" = BP_R_LEG,  "name" = "Right Leg"),
		list("slot" = BP_L_HAND, "name" = "Left Hand"),
		list("slot" = BP_R_HAND, "name" = "Right Hand"),
		list("slot" = BP_L_FOOT, "name" = "Left Foot"),
		list("slot" = BP_R_FOOT, "name" = "Right Foot"),
		list("slot" = BP_CHEST,  "name" = "Full Body"),
	)
	var/first_style = ""
	for(var/co in chargen_robolimbs)
		first_style = co
		break
	for(var/def in limb_defs)
		var/limb_slot = def["slot"]
		var/state = organ_data?[limb_slot]
		var/list/aug_choices = list()
		aug_choices["normal"] = "Normal"
		if(limb_slot != BP_CHEST)
			aug_choices["amputated"] = "Amputated"
		aug_choices["cyborg"] = "Prosthesis"
		var/chosen_aug
		switch(state)
			if("amputated") chosen_aug = "Amputated"
			if("cyborg")    chosen_aug = "Prosthesis"
			else            chosen_aug = "Normal"
		var/chosen_style = rlimb_data?[limb_slot]
		if(!chosen_style || !(chosen_style in chargen_robolimbs))
			chosen_style = first_style
		var/list/costs = list("Normal" = 0, "Amputated" = 0, "Prosthesis" = 0)
		var/list/markings_data = list("markings_list" = list(), "marking_choices" = list())
		limbs += list(list(
			"slot" = limb_slot,
			"name" = def["name"],
			"can_augment" = TRUE,
			"chosen_aug" = chosen_aug,
			"chosen_style" = chosen_style,
			"aug_choices" = aug_choices,
			"costs" = costs,
			"markings" = markings_data,
		))
	return limbs

/datum/preferences/proc/build_tgui_organs_data()
	var/list/organs = list()
	var/list/organ_defs = list(
		list("slot" = BP_HEART,   "name" = "Heart"),
		list("slot" = BP_EYES,    "name" = "Eyes"),
		list("slot" = BP_LUNGS,   "name" = "Lungs"),
		list("slot" = BP_LIVER,   "name" = "Liver"),
		list("slot" = BP_KIDNEYS, "name" = "Kidneys"),
		list("slot" = BP_STOMACH, "name" = "Stomach"),
	)
	var/singleton/species/mob_species = GLOB.species_by_name[species]
	var/no_robotic = !!(mob_species?.spawn_flags & SPECIES_NO_ROBOTIC_INTERNAL_ORGANS)
	for(var/def in organ_defs)
		var/organ_slot = def["slot"]
		var/state = organ_data?[organ_slot]
		var/list/organ_choices = list()
		organ_choices["null"] = "Normal"
		if(!no_robotic)
			organ_choices["assisted"] = "Assisted"
			organ_choices["mechanical"] = "Synthetic"
		var/chosen_organ
		switch(state)
			if("assisted")   chosen_organ = "Assisted"
			if("mechanical") chosen_organ = "Synthetic"
			else             chosen_organ = "Normal"
		if(no_robotic) chosen_organ = "Normal"
		var/list/costs = list("Normal" = 0, "Assisted" = 0, "Synthetic" = 0)
		organs += list(list(
			"slot" = organ_slot,
			"name" = def["name"],
			"chosen_organ" = chosen_organ,
			"organ_choices" = organ_choices,
			"costs" = costs,
		))
	return organs

/datum/preferences/proc/build_species_enabled_features(singleton/species/S)
	var/list/enabled = list("age", "pronouns", "blood_type", "nearsighted")
	if(length(S.get_hair_styles()) > 1)
		enabled += "head_hair_style"
	if(S.appearance_flags & SPECIES_APPEARANCE_HAS_HAIR_COLOR)
		enabled += "hair_color"
	if(length(S.get_facial_hair_styles()) > 1) // gender-neutral check for species listing
		enabled += "facial_hair_style"
		if(S.appearance_flags & SPECIES_APPEARANCE_HAS_HAIR_COLOR)
			enabled += "facial_hair_color"
	if(S.appearance_flags & SPECIES_APPEARANCE_HAS_EYE_COLOR)
		enabled += "eye_color"
	if(S.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR)
		enabled += "skin_color"
	else if(S.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE)
		enabled += "bs12_skin_tone"
	if(S.appearance_flags & SPECIES_APPEARANCE_HAS_BASE_SKIN_COLOURS)
		enabled += "base_skin"
	if(LAZYLEN(S.descriptors))
		for(var/entry in S.descriptors)
			enabled += "bs12_desc_[entry]"
	return enabled

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!client)
		return FALSE

	var/mob/user = ui.user
	var/singleton/species/mob_species = GLOB.species_by_name[species]

	switch(action)
		if("save")
			save_preferences()
			save_character()
			return TRUE

		if("reload")
			load_preferences()
			load_character()
			sanitize_preferences()
			SStgui.update_uis(src)
			return TRUE

		if("randomize_name")
			real_name = random_name(gender, species)
			return TRUE

		if("rotate", "open_food", "delete_character")
			return TRUE

		if("update_preview")
			preview_icon = null
			SStgui.update_uis(src)
			return TRUE

		if("change_slot")
			var/new_slot = text2num("[params["slot"]]")
			if(isnull(new_slot))
				return FALSE
			load_character(round(new_slot))
			sanitize_preferences()
			SStgui.update_uis(src)
			return TRUE

		if("set_antags")
			var/list/antags = params["antags"]
			var/toggled = params["toggled"]
			if(!islist(antags))
				return FALSE
			for(var/antag_id in antags)
				if(toggled)
					be_special_role |= antag_id
					may_be_special_role -= antag_id
				else
					be_special_role -= antag_id
					may_be_special_role -= antag_id
			return TRUE

		if("set_job_preference")
			var/job_name = params["job"]
			var/level = params["level"]
			if(!istext(job_name))
				return FALSE
			// Clear current preference for this job
			if(job_high == job_name)
				job_high = null
			if(istype(job_medium))
				job_medium -= job_name
			if(istype(job_low))
				job_low -= job_name
			// Apply new level (null = off)
			if(!isnull(level) && isnum(level))
				switch(round(level))
					if(3) // High - demote previous high job to medium
						if(job_high)
							if(!istype(job_medium))
								job_medium = list()
							job_medium |= job_high
						job_high = job_name
					if(2) // Medium
						if(!istype(job_medium))
							job_medium = list()
						job_medium |= job_name
					if(1) // Low
						if(!istype(job_low))
							job_low = list()
						job_low |= job_name
			return TRUE

		if("set_job_title")
			var/job_name = params["job"]
			var/new_title = params["new_title"]
			if(!istext(job_name) || !istext(new_title))
				return FALSE
			var/datum/job/J = SSjobs?.get_by_title(job_name)
			if(!J)
				return FALSE
			// Allow setting to the base job title (removes alt title)
			if(new_title == job_name)
				if(islist(player_alt_titles))
					player_alt_titles -= job_name
				return TRUE
			// Validate the new title exists in this job's alt_titles
			if(!islist(J.alt_titles) || !(new_title in J.alt_titles))
				return FALSE
			if(!islist(player_alt_titles))
				player_alt_titles = list()
			player_alt_titles[job_name] = new_title
			return TRUE

		if("set_job_branch")
			var/job_name = params["job"]
			var/branch_name = params["branch"]
			if(!istext(job_name) || !istext(branch_name))
				return FALSE
			if(!GLOB.using_map || !(GLOB.using_map.flags & MAP_HAS_BRANCH) || !GLOB.mil_branches)
				return FALSE
			var/singleton/species/br_species = GLOB.species_by_name[species]
			if(!GLOB.mil_branches.is_spawn_branch(branch_name, br_species))
				return FALSE
			var/datum/job/br_job = SSjobs?.get_by_title(job_name)
			if(br_job && br_job.allowed_branches && !br_job.is_branch_allowed(branch_name))
				return FALSE
			if(!islist(branches))
				branches = list()
			branches[job_name] = branch_name
			// Clear rank — it may not be valid for the new branch
			if(islist(ranks))
				ranks -= job_name
			return TRUE

		if("set_job_rank")
			var/job_name = params["job"]
			var/rank_name = params["rank"]
			if(!istext(job_name) || !istext(rank_name))
				return FALSE
			if(!GLOB.using_map || !(GLOB.using_map.flags & MAP_HAS_RANK) || !GLOB.mil_branches)
				return FALSE
			if(!islist(branches))
				return FALSE
			var/branch_name = branches[job_name]
			if(!branch_name)
				return FALSE
			var/singleton/species/rk_species = GLOB.species_by_name[species]
			if(!GLOB.mil_branches.is_spawn_rank(branch_name, rank_name, rk_species))
				return FALSE
			var/datum/job/rk_job = SSjobs?.get_by_title(job_name)
			if(rk_job && rk_job.allowed_ranks && !rk_job.is_rank_allowed(branch_name, rank_name))
				return FALSE
			if(!islist(ranks))
				ranks = list()
			ranks[job_name] = rank_name
			return TRUE

		if("set_preference")
			var/pref_changed = set_tgui_preference(params["preference"], params["value"], mob_species, user)
			if(pref_changed)
				if(isnull(preview_icon))
					build_tgui_preview(user)  // Pre-send RSC before TGUI data so client has it ready
				SStgui.update_uis(src)
			return pref_changed

		if("set_color_preference")
			var/color_changed = set_tgui_color_preference(params["preference"], mob_species, user)
			if(color_changed)
				if(isnull(preview_icon))
					build_tgui_preview(user)  // Pre-send RSC before TGUI data so client has it ready
				SStgui.update_uis(src)
			return color_changed

		if("set_random_preference")
			return TRUE // BS12 has no randomization system - silently succeed

		if("set_flavor_text")
			var/field = params["field"]
			if(!(field in list("general","head","face","eyes","torso","arms","hands","legs","feet")))
				return FALSE
			if(!istype(flavor_texts))
				flavor_texts = list()
			flavor_texts[field] = sanitize("[params["value"]]", 0)
			return TRUE

		if("set_record")
			var/field = params["field"]
			var/value = sanitize("[params["value"]]", 0)
			switch(field)
				if("public_record") public_record = value
				if("med_record")    med_record    = value
				if("sec_record")    sec_record    = value
				if("gen_record")    gen_record    = value
				if("memory")        memory        = value
				if("email_addr")
					if(!length(value) || length(value) <= 24)
						email_addr = value
				else
					return FALSE


		if("set_email_pass")
			var/new_pass = sanitize("[params["value"]]", 0)
			if(!length(new_pass))
				email_pass = ""
				return TRUE
			if(length(new_pass) >= 4 && length(new_pass) <= 16)
				email_pass = new_pass
				return TRUE
			return FALSE

		if("set_robot_flavor_text")
			var/module = params["module"]
			if(!istext(module))
				return FALSE
			if(module != "Default" && !(module in SSrobots.all_module_names))
				return FALSE
			if(!istype(flavour_texts_robot))
				flavour_texts_robot = list()
			flavour_texts_robot[module] = sanitize("[params["value"]]", 0)
			return TRUE

		if("set_exploit_record")
			exploit_record = sanitize("[params["value"]]", 0, extra = 0)
			return TRUE

		if("toggle_uplink_source")
			var/source_name = params["source"]
			if(!istext(source_name))
				return FALSE
			var/singleton/uplink_source/US = null
			for(var/singleton/uplink_source/candidate in GLOB.default_uplink_source_priority)
				if(candidate.name == source_name)
					US = candidate
					break
			if(!US)
				return FALSE
			if(!islist(uplink_sources))
				uplink_sources = list()
			if(US in uplink_sources)
				uplink_sources.Remove(US)
			else
				uplink_sources += US
			return TRUE

		if("move_uplink_source")
			var/source_name = params["source"]
			var/direction = params["direction"]
			if(!istext(source_name) || !istext(direction))
				return FALSE
			if(!islist(uplink_sources))
				return FALSE
			var/singleton/uplink_source/US = null
			for(var/singleton/uplink_source/candidate in uplink_sources)
				if(candidate.name == source_name)
					US = candidate
					break
			if(!US)
				return FALSE
			var/idx = uplink_sources.Find(US)
			if(direction == "up" && idx > 1)
				uplink_sources.Swap(idx, idx - 1)
			else if(direction == "down" && idx < length(uplink_sources))
				uplink_sources.Swap(idx, idx + 1)
			return TRUE

		if("toggle_map")
			var/mapname = params["map"]
			if(!istext(mapname))
				return FALSE
			if(!SSjobs?.initialized)
				return FALSE
			var/toggle_key = null
			for(var/mn in SSjobs.job_lists_by_map_name)
				if(replacetext(mn, "\improper ", "") == mapname)
					toggle_key = mn
					break
			if(!toggle_key)
				return FALSE
			var/clean_key = replacetext(toggle_key, "\improper ", "")
			if(!islist(hiding_maps))
				hiding_maps = list()
			if(isnull(hiding_maps[clean_key]))
				var/list/map_data = SSjobs.job_lists_by_map_name[toggle_key]
				hiding_maps[clean_key] = !map_data["default_to_hidden"]
			else
				hiding_maps[clean_key] = !hiding_maps[clean_key]
			return TRUE

		if("select_map")
			// Exclusive map filter: show only jobs for one map (or all if "all" passed)
			var/mapname = params["map"]
			if(!istext(mapname))
				return FALSE
			if(!SSjobs?.initialized)
				return FALSE
			if(mapname == "all")
				hiding_maps = null
				return TRUE
			// Find the raw DM key that matches the cleaned name sent from the frontend
			var/actual_key = null
			for(var/mn in SSjobs.job_lists_by_map_name)
				if(replacetext(mn, "\improper ", "") == mapname)
					actual_key = mn
					break
			if(!actual_key)
				return FALSE
			if(!islist(hiding_maps))
				hiding_maps = list()
			// Mark selected map as visible, all others as hidden (store clean names as keys)
			for(var/mn in SSjobs.job_lists_by_map_name)
				hiding_maps[replacetext(mn, "\improper ", "")] = (mn == actual_key)
			return TRUE

		if("toggle_shackle")
			var/singleton/species/shackle_species = GLOB.species_by_name[species]
			if(!(shackle_species && shackle_species.has_organ[BP_POSIBRAIN]))
				return FALSE
			is_shackled = !is_shackled
			return TRUE

		if("set_lawset")
			var/lawset_name = params["lawset"]
			if(!istext(lawset_name))
				return FALSE
			for(var/law_set_type in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/ai_laws = law_set_type
				if(initial(ai_laws.name) == lawset_name && initial(ai_laws.shackles))
					var/datum/ai_laws/lawset = new law_set_type()
					var/list/datum/ai_law/law_list = lawset.all_laws()
					if(!islist(laws))
						laws = list()
					else
						laws.Cut()
					for(var/datum/ai_law/law in law_list)
						laws += sanitize_text("[law.law]", default="")
					return TRUE
			return FALSE

		if("set_backpack")
			var/bp_name = params["backpack"]
			if(!istext(bp_name))
				return FALSE
			var/singleton/backpack_outfit/new_bp = GET_SINGLETON_SUBTYPE_MAP(/singleton/backpack_outfit)[bp_name]
			if(!new_bp)
				return FALSE
			backpack = new_bp
			return TRUE

		if("set_sensor")
			var/new_sensor = text2num("[params["sensor"]]")
			if(isnull(new_sensor))
				return FALSE
			if(!(new_sensor in list(SUIT_SENSOR_OFF, SUIT_SENSOR_BINARY, SUIT_SENSOR_VITAL, SUIT_SENSOR_TRACKING)))
				return FALSE
			sensor_setting = new_sensor
			return TRUE

		if("set_underwear")
			var/cat_name = params["category"]
			var/item_name = params["item"]
			if(!istext(cat_name) || !istext(item_name))
				return FALSE
			var/datum/category_group/underwear/UWC = GLOB.underwear.categories_by_name[cat_name]
			if(!UWC)
				return FALSE
			if(!(item_name in UWC.items_by_name))
				return FALSE
			if(!islist(all_underwear))
				all_underwear = list()
			all_underwear[cat_name] = item_name
			return TRUE

		if("set_cultural_info")
			var/tag = params["tag"]
			var/value = params["value"]
			if(!istext(tag) || !istext(value))
				return FALSE
			var/singleton/species/ci_species = GLOB.species_by_name[species]
			var/list/allowed
			if(ci_species)
				if(ci_species.force_cultural_info[tag])
					allowed = list(ci_species.force_cultural_info[tag])
				else
					allowed = ci_species.available_cultural_info[tag]
			else
				allowed = GLOB.using_map?.available_cultural_info[tag]
			if(!islist(allowed) || !(value in allowed))
				return FALSE
			if(!islist(cultural_info))
				cultural_info = list()
			cultural_info[tag] = value
			return TRUE

		if("toggle_uniform")
			var/job_name = params["job"]
			var/piece_ref = params["piece"]
			if(!istext(job_name) || !istext(piece_ref))
				return FALSE
			var/piece_type = text2path(piece_ref)
			if(!piece_type || !ispath(piece_type, /obj/item/clothing))
				return FALSE
			if(!islist(uniforms_by_job))
				uniforms_by_job = list()
			if(!islist(uniforms_by_job[job_name]))
				uniforms_by_job[job_name] = list()
			if(piece_ref in uniforms_by_job[job_name])
				uniforms_by_job[job_name] -= piece_ref
			else
				uniforms_by_job[job_name] += piece_ref
			return TRUE
		if("set_skill_level")
			var/job_name = params["job"]
			var/skill_str = params["skill"]
			var/new_level = params["level"]
			if(!istext(job_name) || !istext(skill_str) || !isnum(new_level))
				return FALSE
			var/datum/job/job = SSjobs.get_by_title(job_name)
			if(!job || job.skill_points == 0)
				return FALSE
			var/skill_type = text2path(skill_str)
			if(!skill_type || !ispath(skill_type, /singleton/hierarchy/skill))
				return FALSE
			var/singleton/hierarchy/skill/S = GET_SINGLETON(skill_type)
			if(!S || !(S in GLOB.skills))
				return FALSE
			new_level = round(new_level)
			var/min_lv = get_min_skill(job, S)
			var/max_lv = get_max_skill(job, S)
			if(new_level < min_lv || new_level > max_lv)
				return FALSE
			if(!check_skill_prerequisites(job, S))
				return FALSE
			if(isnull(points_by_job[job]))
				points_by_job[job] = job.skill_points
			if(new_level == min_lv)
				clear_skill(job, S)
				purge_skills_missing_prerequisites(job)
				return TRUE
			if(!(job in skills_allocated))
				skills_allocated[job] = list()
			var/list/alloc = skills_allocated[job]
			var/cur_cost = get_level_cost(job, S, min_lv + (alloc[S] || 0))
			var/new_cost = get_level_cost(job, S, new_level)
			if(points_by_job[job] + cur_cost - new_cost < 0)
				return FALSE
			points_by_job[job] += (cur_cost - new_cost)
			alloc[S] = new_level - min_lv
			purge_skills_missing_prerequisites(job)
			return TRUE

		if("speak_language", "understand_language")
			var/lang_name = params["language_name"]
			if(!istext(lang_name))
				return FALSE
			var/datum/language/L = all_languages[lang_name]
			if(!L)
				return FALSE
			if(L.flags & RESTRICTED)
				return FALSE
			if(!islist(alternate_languages))
				alternate_languages = list()
			if(lang_name in alternate_languages)
				return TRUE
			if(length(alternate_languages) >= MAX_LANGUAGES)
				return FALSE
			alternate_languages |= lang_name
			return TRUE

		if("forget_understand_language", "forget_speak_language")
			var/lang_name = params["language_name"]
			if(!istext(lang_name))
				return FALSE
			if(!islist(alternate_languages))
				return FALSE
			alternate_languages -= lang_name
			return TRUE

		if("select_item")
			var/gear_name = params["path"]
			var/deselect = params["deselect"]
			if(!istext(gear_name) || !(gear_name in gear_datums))
				return FALSE
			if(!islist(gear_list))
				gear_list = list()
			if(length(gear_list) < gear_slot)
				LIST_RESIZE(gear_list, gear_slot)
			if(!islist(gear_list[gear_slot]))
				gear_list[gear_slot] = list()
			var/list/gears = gear_list[gear_slot]
			if(deselect)
				gears -= gear_name
			else
				var/datum/gear/G = gear_datums[gear_name]
				var/total_cost = 0
				for(var/g in gears)
					var/datum/gear/GG = gear_datums[g]
					if(GG) total_cost += GG.cost
				if(total_cost + G.cost <= config.max_gear_cost)
					gears |= gear_name
			return TRUE

		if("clear_all_items")
			if(islist(gear_list) && islist(gear_list[gear_slot]))
				gear_list[gear_slot].Cut()
			return TRUE

		// Loadout gear-tweak customization and preset management — stubs
		if("pass_to_loadout_item", "set_loadout_preset", "add_loadout_preset", "rename_loadout_preset", "remove_loadout_preset", "toggle_job_clothes")
			return TRUE

		// Markings — stubs (not yet implemented)
		if("change_marking", "color_marking", "change_emissive", "remove_marking", "add_marking", "set_preset")
			return TRUE

		if("set_limb_aug")
			var/limb_slot = params["limb_slot"]
			var/augment_name = params["augment_name"]
			if(!istext(limb_slot) || !istext(augment_name))
				return FALSE
			var/list/valid_limb_slots = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT, BP_CHEST)
			if(!(limb_slot in valid_limb_slots))
				return FALSE
			if(!islist(organ_data)) organ_data = list()
			if(!islist(rlimb_data)) rlimb_data = list()
			var/second_limb
			switch(limb_slot)
				if(BP_L_ARM)  second_limb = BP_L_HAND
				if(BP_R_ARM)  second_limb = BP_R_HAND
				if(BP_L_LEG)  second_limb = BP_L_FOOT
				if(BP_R_LEG)  second_limb = BP_R_FOOT
			switch(augment_name)
				if("Normal")
					organ_data[limb_slot] = null
					rlimb_data[limb_slot] = null
					if(second_limb)
						organ_data[second_limb] = null
						rlimb_data[second_limb] = null
				if("Amputated")
					if(limb_slot == BP_CHEST)
						return FALSE
					organ_data[limb_slot] = "amputated"
					rlimb_data[limb_slot] = null
					if(second_limb)
						organ_data[second_limb] = "amputated"
						rlimb_data[second_limb] = null
				if("Prosthesis")
					var/style = rlimb_data[limb_slot]
					if(!style || !(style in chargen_robolimbs))
						for(var/co in chargen_robolimbs)
							style = co
							break
					if(!style) return FALSE
					organ_data[limb_slot] = "cyborg"
					rlimb_data[limb_slot] = style
					if(second_limb)
						organ_data[second_limb] = "cyborg"
						rlimb_data[second_limb] = style
					if(limb_slot == BP_CHEST)
						for(var/other_limb in list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT))
							organ_data[other_limb] = "cyborg"
							rlimb_data[other_limb] = style
						if(!organ_data[BP_BRAIN])
							organ_data[BP_BRAIN] = "assisted"
						for(var/internal_organ in list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS))
							organ_data[internal_organ] = "mechanical"
				else
					return FALSE
			return TRUE

		if("set_limb_aug_style")
			var/limb_slot = params["limb_slot"]
			var/style_name = params["style_name"]
			if(!istext(limb_slot) || !istext(style_name))
				return FALSE
			if(!(style_name in chargen_robolimbs))
				return FALSE
			var/list/valid_limb_slots = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT, BP_CHEST)
			if(!(limb_slot in valid_limb_slots))
				return FALSE
			if(!islist(rlimb_data)) rlimb_data = list()
			if(organ_data?[limb_slot] != "cyborg")
				return FALSE
			rlimb_data[limb_slot] = style_name
			return TRUE

		if("set_organ_aug")
			var/organ_slot = params["organ_slot"]
			var/augment_name = params["augment_name"]
			if(!istext(organ_slot) || !istext(augment_name))
				return FALSE
			var/list/valid_organ_slots = list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS, BP_STOMACH)
			if(!(organ_slot in valid_organ_slots))
				return FALSE
			var/singleton/species/aug_species = GLOB.species_by_name[species]
			if(!islist(organ_data)) organ_data = list()
			switch(augment_name)
				if("Normal")
					organ_data[organ_slot] = null
				if("Assisted")
					if(aug_species?.spawn_flags & SPECIES_NO_ROBOTIC_INTERNAL_ORGANS)
						return FALSE
					organ_data[organ_slot] = "assisted"
				if("Synthetic")
					if(aug_species?.spawn_flags & SPECIES_NO_ROBOTIC_INTERNAL_ORGANS)
						return FALSE
					organ_data[organ_slot] = "mechanical"
				else
					return FALSE
			return TRUE

	return FALSE

/datum/preferences/proc/set_tgui_preference(pref_name, value, singleton/species/mob_species, mob/user)
	switch(pref_name)
		if("real_name")
			if(istext(value) && length(value))
				if(cultural_info && cultural_info[TAG_CULTURE])
					var/singleton/cultural_info/check = SSculture.get_culture(cultural_info[TAG_CULTURE])
					var/new_name = check?.sanitize_name(value, species)
					if(new_name)
						real_name = new_name
				else
					real_name = sanitize_text(value, real_name)
			return TRUE

		if("gender")
			if(mob_species && (value in mob_species.genders))
				gender = value
				if(!(facial_hair_style in mob_species.get_facial_hair_styles(gender)))
					var/list/valid_facial = mob_species.get_facial_hair_styles(gender)
					if(length(valid_facial))
						facial_hair_style = valid_facial[1]
			preview_icon = null
			return TRUE

		if("species")
			if(!(value in GLOB.playable_species))
				return FALSE
			var/prev_species = species
			species = value
			if(prev_species != species)
				mob_species = GLOB.species_by_name[species]
				if(!(gender in mob_species.genders))
					gender = mob_species.genders[1]
				if(!(pronouns in mob_species.pronouns))
					pronouns = mob_species.pronouns[1]
				var/list/valid_hair = mob_species.get_hair_styles()
				if(length(valid_hair))
					head_hair_style = pick(valid_hair)
				var/list/valid_facial = mob_species.get_facial_hair_styles(gender)
				if(length(valid_facial))
					facial_hair_style = pick(valid_facial)
				head_hair_color = "#000000"
				skin_tone = 0
				age = clamp(age, mob_species.min_age, mob_species.max_age)
				if(istype(body_markings))
					body_markings.Cut()
				if(istype(picked_traits))
					picked_traits.Cut()
				cultural_info = mob_species.default_cultural_info.Copy()
				tgui_sanitize_organs()
			preview_icon = null
			return TRUE

		if("age")
			var/new_age = text2num("[value]")
			if(!isnull(new_age))
				var/min_a = mob_species ? mob_species.min_age : 17
				var/max_a = mob_species ? mob_species.max_age : 70
				age = clamp(round(new_age), min_a, max_a)
			return TRUE

		if("pronouns")
			if(mob_species && (value in mob_species.pronouns))
				pronouns = value
			return TRUE

		if("blood_type")
			if(value in valid_bloodtypes)
				b_type = value
			return TRUE

		if("head_hair_style")
			if(mob_species && (value in mob_species.get_hair_styles()))
				head_hair_style = value
			preview_icon = null
			return TRUE

		if("facial_hair_style")
			if(mob_species && (value in mob_species.get_facial_hair_styles(gender)))
				facial_hair_style = value
			preview_icon = null
			return TRUE

		if("base_skin")
			if(mob_species && mob_species.base_skin_colours && !isnull(mob_species.base_skin_colours[value]))
				base_skin = value
			preview_icon = null
			return TRUE

		if("bs12_skin_tone")
			if(mob_species && (mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE))
				var/new_tone = text2num("[value]")
				if(!isnull(new_tone))
					skin_tone = 35 - clamp(round(new_tone), 1, mob_species.max_skin_tone())
			preview_icon = null
			return TRUE

		if("nearsighted")
			if(value)
				disabilities |= NEARSIGHTED
			else
				disabilities &= ~NEARSIGHTED
			return TRUE

		if("metadata")
			metadata = sanitize_text("[value]", "")
			return TRUE

		if("spawnpoint")
			if(value in spawntypes())
				spawnpoint = value
			return TRUE

		if("joblessrole")
			var/role_num = text2num("[value]")
			if(!isnull(role_num))
				alternate_option = clamp(round(role_num) - 1, 0, 2)
			return TRUE

		if("random_body", "random_species", "random_name")
			return TRUE // BS12 has no randomization - silently succeed

	// Descriptor keys: "bs12_desc_<entry>"
	if(length(pref_name) > 9 && copytext(pref_name, 1, 10) == "bs12_desc_")
		var/entry_key = copytext(pref_name, 10)
		if(mob_species && mob_species.descriptors && mob_species.descriptors[entry_key])
			var/datum/mob_descriptor/descriptor = mob_species.descriptors[entry_key]
			var/new_val = text2num("[value]")
			if(!isnull(new_val))
				if(!istype(body_descriptors))
					body_descriptors = list()
				body_descriptors[entry_key] = clamp(round(new_val), 1, LAZYLEN(descriptor.standalone_value_descriptors))
		preview_icon = null
		return TRUE

	return FALSE

/datum/preferences/proc/set_tgui_color_preference(pref_name, singleton/species/mob_species, mob/user)
	switch(pref_name)
		if("hair_color")
			if(!mob_species || !(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_HAIR_COLOR))
				return FALSE
			var/new_color = input(user, "Choose hair color:", "Hair Color", head_hair_color) as color|null
			if(new_color)
				head_hair_color = new_color
			preview_icon = null
			return TRUE

		if("facial_hair_color")
			if(!mob_species || !(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_HAIR_COLOR))
				return FALSE
			var/new_color = input(user, "Choose facial hair color:", "Facial Hair Color", facial_hair_color) as color|null
			if(new_color)
				facial_hair_color = new_color
			preview_icon = null
			return TRUE

		if("eye_color")
			if(!mob_species || !(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_EYE_COLOR))
				return FALSE
			var/new_color = input(user, "Choose eye color:", "Eye Color", eye_color) as color|null
			if(new_color)
				eye_color = new_color
			preview_icon = null
			return TRUE

		if("skin_color")
			if(!mob_species || !(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR))
				return FALSE
			var/new_color = input(user, "Choose skin color:", "Skin Color", skin_color) as color|null
			if(new_color)
				skin_color = new_color
			preview_icon = null
			return TRUE

	return FALSE

// Mirrors sanitize_organs() from /datum/category_item/player_setup_item/physical/body
// but called on datum/preferences directly when species changes via TGUI.
/datum/preferences/proc/tgui_sanitize_organs()
	var/singleton/species/S = GLOB.species_by_name[species]
	if(!S || !istype(organ_data))
		return
	if(S.spawn_flags & SPECIES_NO_ROBOTIC_INTERNAL_ORGANS)
		for(var/name in organ_data)
			if(organ_data[name] in list("assisted", "mechanical"))
				organ_data[name] = null
	if(organ_data[BP_CHEST] == "cyborg" && organ_data[BP_EYES] == "assisted")
		for(var/name in organ_data)
			if(name in list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS))
				organ_data[name] = "mechanical"

/datum/preferences/proc/build_tgui_preview(mob/user)
	if(!client)
		return "no_preview"
	if(isnull(preview_icon))
		update_preview_icon(FALSE)
		if(!preview_icon)
			return "no_preview"
		tgui_preview_version++
	var/rsc_name = "charpreview_[tgui_preview_version].png"
	send_rsc(client, preview_icon, rsc_name)
	return rsc_name

/datum/preferences/proc/build_tgui_sidebar_icons()
	var/list/result = list("underwear" = list())
	if(!client)
		return result

	// Hair — reuse the same RSC name as the grid (already sent after build_tgui_server_data)
	if(head_hair_style)
		var/datum/sprite_accessory/H = GLOB.hair_styles_list[head_hair_style]
		if(H && H.icon)
			var/state = H.preview_state ? H.preview_state : "[H.icon_state]_s"
			var/ico = tgui_cache_icon("hair:[head_hair_style]", H.icon, state)
			result["hair"] = tgui_send_icon(tgui_rsc_name("hair", head_hair_style), ico)

	// Facial hair
	if(facial_hair_style)
		var/datum/sprite_accessory/FH = GLOB.facial_hair_styles_list[facial_hair_style]
		if(FH && FH.icon)
			var/state = FH.preview_state ? FH.preview_state : "[FH.icon_state]_s"
			var/ico = tgui_cache_icon("facialhair:[facial_hair_style]", FH.icon, state)
			result["facial_hair"] = tgui_send_icon(tgui_rsc_name("facialhair", facial_hair_style), ico)

	// Backpack
	if(backpack && backpack.path)
		var/icon_file = initial(backpack.path:icon)
		if(icon_file)
			var/ico = tgui_cache_icon("bp:[backpack.path]", icon_file, initial(backpack.path:icon_state))
			result["backpack"] = tgui_send_icon(tgui_rsc_name("bp", backpack.name), ico)

	// Underwear — one per category
	if(islist(all_underwear))
		for(var/cat_name in all_underwear)
			var/item_name = all_underwear[cat_name]
			var/datum/category_group/underwear/UWC = GLOB.underwear.categories_by_name[cat_name]
			if(!UWC)
				continue
			var/datum/category_item/underwear/UWI = UWC.items_by_name[item_name]
			if(!UWI || !UWI.icon || !UWI.icon_state)
				continue
			var/ico = tgui_cache_icon("uw:[UWI.type]", UWI.icon, UWI.icon_state)
			var/rsc_name = tgui_send_icon(tgui_rsc_name("uw", "[cat_name]_[item_name]"), ico)
			if(rsc_name)
				result["underwear"][cat_name] = rsc_name

	return result

/datum/preferences/proc/build_tgui_selected_languages()
	var/list/result = list()
	if(!islist(alternate_languages))
		return result
	for(var/lang_name in alternate_languages)
		var/datum/language/L = all_languages[lang_name]
		if(!L)
			continue
		result += list(list(
			"name" = L.name,
			"description" = (L.desc ? L.desc : "No description available."),
			"icon" = "",
			"speaking" = TRUE
		))
	return result

/datum/preferences/proc/build_tgui_loadout()
	var/list/result = list()
	var/list/current_gear = Gear()
	if(!islist(current_gear))
		return result
	for(var/gear_name in current_gear)
		if(!(gear_name in gear_datums))
			continue
		result[gear_name] = list()
	return result

/datum/preferences/proc/build_tgui_loadout_tabs()
	var/list/tabs = list()
	for(var/cat_name in loadout_categories)
		var/datum/loadout_category/LC = loadout_categories[cat_name]
		var/list/contents = list()
		for(var/gear_name in LC.gear)
			var/datum/gear/G = LC.gear[gear_name]
			if(!G.path)
				continue
			var/list/info = list()
			if(G.cost > 1)
				info += list(list("icon" = "coins", "tooltip" = "Costs [G.cost] points"))
			if(G.allowed_roles)
				info += list(list("icon" = "user-tie", "tooltip" = "Restricted to specific roles"))
			if(G.allowed_branches)
				info += list(list("icon" = "star", "tooltip" = "Restricted to specific branches"))
			if(G.whitelisted)
				info += list(list("icon" = "lock", "tooltip" = "Species restricted"))
			var/icon_rsc = null
			var/item_icon_file = initial(G.path:icon)
			if(item_icon_file)
				var/ico = tgui_cache_icon("gear:[G.path]", item_icon_file, initial(G.path:icon_state))
				icon_rsc = tgui_send_icon(tgui_rsc_name("gear", gear_name), ico)
			contents += list(list(
				"name" = gear_name,
				"group" = "",
				"path" = gear_name,
				"icon" = icon_rsc,
				"icon_state" = null,
				"buttons" = list(),
				"reskins" = null,
				"information" = info,
				"ckey_whitelist" = null,
				"restricted_roles" = null,
				"blacklisted_roles" = null,
				"restricted_species" = null,
				"donator_only" = FALSE,
				"nova_stars_only" = FALSE,
				"erp_item" = FALSE,
			))
		if(!length(contents))
			continue
		tabs += list(list(
			"name" = cat_name,
			"category_icon" = null,
			"category_info" = null,
			"contents" = contents,
			"erp_category" = FALSE,
		))
	return tabs

/datum/preferences/proc/build_tgui_unselected_languages()
	var/list/result = list()
	for(var/lang_name in all_languages)
		var/datum/language/L = all_languages[lang_name]
		if(!L)
			continue
		if(L.flags & RESTRICTED)
			continue
		if(islist(alternate_languages) && (lang_name in alternate_languages))
			continue
		result += list(list(
			"name" = L.name,
			"description" = (L.desc ? L.desc : "No description available."),
			"icon" = "",
			"speaking" = FALSE
		))
	return result

/datum/preferences/ui_close(mob/user)
	save_preferences()
	save_character()

// Builds the icon cache and pre-sends RSC files to the client before prefs are opened.
// Called with spawn() on login so the first ui_data call hits warm caches.
/datum/preferences/proc/tgui_prewarm_icons()
	if(!client)
		return
	var/singleton/species/mob_species = GLOB.species_by_name[species]
	var/i = 0

	var/list/hair_list = mob_species ? mob_species.get_hair_styles() : GLOB.hair_styles_list
	for(var/k in hair_list)
		var/datum/sprite_accessory/H = GLOB.hair_styles_list[k]
		if(H && H.icon)
			var/state = H.preview_state ? H.preview_state : "[H.icon_state]_s"
			var/ico = tgui_cache_icon("hair:[k]", H.icon, state)
			tgui_send_icon(tgui_rsc_name("hair", k), ico)
		if(!(++i % 10))
			sleep(0)
			if(!client) return

	var/list/facial_list = mob_species ? mob_species.get_facial_hair_styles(gender) : GLOB.facial_hair_styles_list
	for(var/k in facial_list)
		var/datum/sprite_accessory/FH = GLOB.facial_hair_styles_list[k]
		if(FH && FH.icon)
			var/state = FH.preview_state ? FH.preview_state : "[FH.icon_state]_s"
			var/ico = tgui_cache_icon("facialhair:[k]", FH.icon, state)
			tgui_send_icon(tgui_rsc_name("facialhair", k), ico)
		if(!(++i % 10))
			sleep(0)
			if(!client) return

	for(var/datum/category_group/underwear/UWC in GLOB.underwear.categories)
		for(var/iname in UWC.items_by_name)
			var/datum/category_item/underwear/UWI = UWC.items_by_name[iname]
			if(UWI && UWI.icon && UWI.icon_state)
				var/ico = tgui_cache_icon("uw:[UWI.type]", UWI.icon, UWI.icon_state)
				tgui_send_icon(tgui_rsc_name("uw", "[UWC.name]_[iname]"), ico)
			if(!(++i % 10))
				sleep(0)
				if(!client) return

	var/list/bp_map = GET_SINGLETON_SUBTYPE_MAP(/singleton/backpack_outfit)
	for(var/bp_name in bp_map)
		var/singleton/backpack_outfit/bo = bp_map[bp_name]
		if(bo.path)
			var/bp_icon_file = initial(bo.path:icon)
			if(bp_icon_file)
				var/ico = tgui_cache_icon("bp:[bo.path]", bp_icon_file, initial(bo.path:icon_state))
				tgui_send_icon(tgui_rsc_name("bp", bp_name), ico)
		if(!(++i % 10))
			sleep(0)
			if(!client) return

	for(var/spec_name in GLOB.playable_species)
		var/singleton/species/S = GLOB.species_by_name[spec_name]
		if(S && S.preview_icon)
			var/ico = tgui_cache_icon("species:[S.name]", S.preview_icon, "")
			tgui_send_icon(tgui_rsc_name("sp", S.name), ico)
		if(!(++i % 10))
			sleep(0)
			if(!client) return

/datum/preferences/proc/build_species_restricted_jobs(singleton/species/mob_species)
	var/list/restricted = list()
	if(!mob_species || !SSjobs?.initialized)
		return restricted
	for(var/job_type in SSjobs.types_to_datums)
		var/datum/job/J = SSjobs.types_to_datums[job_type]
		if(!J.is_species_allowed(mob_species))
			restricted += J.title
	return restricted
