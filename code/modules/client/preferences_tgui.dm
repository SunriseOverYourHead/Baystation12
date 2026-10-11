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

// GET_SINGLETON_SUBTYPE_MAP() is keyed by type path, not display name, so it can't be looked up directly with a
// name string the client sent back. Small linear scan (6 backpack types) rather than maintaining a second cache.
/datum/preferences/proc/get_backpack_outfit_by_name(bp_name)
	RETURN_TYPE(/singleton/backpack_outfit)
	var/list/bp_map = GET_SINGLETON_SUBTYPE_MAP(/singleton/backpack_outfit)
	for(var/bp_path in bp_map)
		var/singleton/backpack_outfit/bo = bp_map[bp_path]
		if(bo.name == bp_name)
			return bo
	return null

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
	// Only sent (and so only rendered -- PreferenceList shows exactly what's in this list, nothing more) for
	// Trans (PLURAL) -- Male/Female bodies already match their gender, no separate choice needed.
	if(gender == PLURAL)
		secondary["trans_body_type"] = trans_body_type
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
		if(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_LEG_TYPE)
			secondary["digitigrade_legs"] = leg_type
		if(LAZYLEN(mob_species.descriptors))
			for(var/entry in mob_species.descriptors)
				var/datum/mob_descriptor/descriptor = mob_species.descriptors[entry]
				secondary["bs12_desc_[tgui_descriptor_key(entry)]"] = descriptor.get_standalone_value_descriptor(body_descriptors?[entry])
		for(var/organ_tag in get_all_mutant_organ_tags())
			if(!mob_species.has_organ || !(organ_tag in mob_species.has_organ))
				continue
			var/list/cat_styles = mob_species.get_mutant_styles(organ_tag, allow_noncanon_bodyparts)
			// Anus has no style/color dimension at all (mutant_anus.dm) -- get_mutant_styles() for it is always
			// empty, which used to skip it here entirely, silently dropping its toggle checkbox from the UI.
			var/toggle_only = (organ_tag == BP_ANUS)
			if(!length(cat_styles) && !toggle_only)
				continue
			var/list/meta = get_mutant_category_meta(organ_tag)
			if(meta["is_erp"] && !(!config.disable_erp_preferences && master_erp_preferences))
				continue
			if(meta["is_erp"] && !organ_category_matches_gender(organ_tag))
				continue
			var/list/choice = mutant_organs[organ_tag]
			var/organ_enabled = islist(choice) && choice["enabled"]
			var/mandatory = mob_species.is_mutant_organ_mandatory(organ_tag)
			secondary[meta["toggle_key"]] = !!organ_enabled
			if(!toggle_only && (organ_enabled || mandatory))
				var/list/choice_colors = islist(choice) ? choice["colors"] : null
				var/fallback_color = get_mutant_fallback_color(meta, mob_species)
				var/current_style = islist(choice) ? choice["style"] : null
				if(mandatory && !(current_style in cat_styles))
					// Also self-heals a stale/legacy "None" saved before this category became mandatory --
					// cat_styles[1] happens to be the species' one true default in every mandatory case that
					// exists today: Unathi/Vox tail.
					current_style = cat_styles[1]
				else if(!current_style)
					current_style = meta["default_to_none"] ? "None" : cat_styles[1]
				secondary[meta["feature_key"]] = current_style
				// Always a 3-element list (primary/secondary/tertiary), mirroring Bubberstation's tri_color prefs --
				// most styles only ever use slot 1 (color_regions == 1), but the picker always shows all 3 swatches
				// regardless (matches upstream: unused slots are simply never read at render time, see
				// build_colored_icon() in _accessory_mutant.dm).
				secondary[meta["color_key"]] = list(
					(islist(choice_colors) && choice_colors[1]) || fallback_color,
					(islist(choice_colors) && choice_colors[2]) || fallback_color,
					(islist(choice_colors) && choice_colors[3]) || fallback_color,
					)
				if(meta["size_key"])
					var/current_size = islist(choice) ? choice["size"] : null
					secondary[meta["size_key"]] = isnull(current_size) ? meta["size_default"] : current_size
				// "P. Sheath" -- Penis only, a dedicated override preference rather than a shape choice (see
				// preferences.dm's copy_to()). Not part of get_mutant_category_meta() since no other category has
				// an equivalent concept.
				if(organ_tag == BP_PENIS)
					secondary["p_sheath"] = (islist(choice) && choice["sheath_mode"]) || "None"


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
				"species" = (mob_species ? display_species_name(mob_species.name) : SPECIES_HUMAN),
				"joblessrole" = max(1, alternate_option + 1),
				"job_clothes" = FALSE,
				"preview_mode" = preview_job ? "Job" : (preview_gear ? "Loadout" : (preview_nude ? (preview_aroused ? "Naked (Aroused)" : "Naked") : "Underwear")),
				"loadout_lists" = list(
					"loadout" = build_tgui_loadout(),
					"loadouts" = list("Default"),
				),
				"loadout_index" = "Default",
				"spawnpoint" = spawnpoint,
				// Read directly by CharacterAlteringToggles.tsx's own bespoke section -- NOT secondary_features,
				// which PreferenceList renders in full (every key needs a matching Feature export or it prints
				// "Feature ... is not recognized"); these two are deliberately unregistered there.
				"master_erp_preferences" = !!master_erp_preferences,
				"allow_noncanon_bodyparts" = !!allow_noncanon_bodyparts,
			),
			"secondary_features" = secondary,
			"non_contextual" = list(
				"random_body" = 2,
				"spawnpoint" = spawnpoint,
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
			"identity_media" = list(
				"headshot_url"      = (headshot_url      || ""),
				"headshot_nsfw_url" = (headshot_nsfw_url || ""),
				"art_reference_url" = (art_reference_url || ""),
				"art_ref_nsfw"      = art_ref_nsfw,
				"headshot_ai_generated"      = headshot_ai_generated,
				"headshot_nsfw_ai_generated" = headshot_nsfw_ai_generated,
				"art_reference_ai_generated" = art_reference_ai_generated,
				// Non-sexual, viewer-side, deliberately not part of the erp_directory/erp_unlocked family -- see
				// its own var comment (05_identity_media.dm). Still sent from here since it's edited from the same
				// TGUI page as the other identity-media fields, even though it's read back live off the VIEWER's
				// own preferences (examine_panel.dm), never off a mob.
				"view_ai_generated_headshots" = view_ai_generated_headshots,
			),
			"erp_directory" = list(
				// Forced off in the data sent to the client whenever ERP is locked, mirroring the ERP tags/
				// Dating Preferences gate below -- a character without Sexual Content enabled should never show
				// up in the directory, even if it was toggled on before ERP got disabled.
				"show_in_directory"     = ((!config.disable_erp_preferences && master_erp_preferences) ? show_in_directory : FALSE),
				"ooc_notes"             = (ooc_notes || ""),
				"attraction"            = attraction,
				"display_gender"        = display_gender,
				"emote_length"          = emote_length,
				"approach_pref"         = approach_pref,
				"furry_pref"            = furry_pref,
				"scalie_pref"           = scalie_pref,
				"other_pref"            = other_pref,
				"demihuman_pref"        = demihuman_pref,
				"human_pref"            = human_pref,
				"character_ad"          = (character_ad || ""),
				"erp_status"            = erp_status,
				"erp_status_nc"         = erp_status_nc,
				"erp_status_v"          = erp_status_v,
				"erp_status_hypno"      = erp_status_hypno,
				"erp_free_use"          = erp_free_use,
				"can_knot_partners"     = can_knot_partners,
				"mechanical_erp"        = mechanical_erp,
				"custom_species"        = (custom_species || ""),
				"custom_species_lore"   = (custom_species_lore || ""),
				"character_flavor_text" = (character_flavor_text || ""),
				"flavor_text_nsfw"      = (flavor_text_nsfw || ""),
				"show_nsfw_flavor_text" = show_nsfw_flavor_text,
				// ERP tags stay hidden from the editor entirely until the ERP master switch + config flag both
				// allow it -- same three-way gate as the genital toggles (build_species_enabled_features()).
				"erp_unlocked"          = (!config.disable_erp_preferences && master_erp_preferences),
				"choices" = list(
					"attraction"            = GLOB.valid_attraction_types,
					"display_gender"        = GLOB.valid_display_genders,
					"emote_length"          = GLOB.valid_emote_lengths,
					"approach_pref"         = GLOB.valid_approach_prefs,
					"directory_character"   = GLOB.valid_directory_character_prefs,
					"erp_status"            = GLOB.valid_erp_statuses,
					"erp_status_nc"         = GLOB.valid_erp_statuses_nc,
					"erp_status_v"          = GLOB.valid_erp_statuses_v,
					"erp_status_hypno"      = GLOB.valid_erp_statuses_hypno,
					"show_nsfw_flavor_text" = GLOB.valid_show_nsfw_flavor_text,
				),
			),
			"features" = list(),
			"clothing" = list(),
			"supplemental_features" = list(),
			"manually_rendered_features" = list(),
			"randomization" = list(),
			"game_preferences" = list(),
			// Feeds the "Character Voice" modal (CharacterPreferences/vocals.tsx). Keys must match the exported
			// feature names in preferences/features/character_preferences/nova/character_voice.tsx, which are
			// auto-registered by export name. The TTS-related keys that modal also knows about (voice_type,
			// tts_voice, tts_voice_pitch, fallback_to_blooper) are deliberately not sent -- there's no TTS here,
			// and vocals.tsx skips any key whose value is undefined.
			"vocals" = list(
				"blooper_speech" = vocal_chirp_id,
				"blooper_speech_speed" = vocal_chirp_speed,
				"blooper_speech_pitch" = vocal_chirp_pitch,
				"blooper_pitch_range" = vocal_chirp_variance,
			),
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
		"native_languages" = build_tgui_native_languages(),
		"language_levels" = build_tgui_language_levels(),
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

	// Species -- Kharmaan Alate/Gyne (mantid.dm) are real, distinct, fully-playable singletons (different age
	// ranges, body art, limb overrides) that stay exactly as they are internally; they're merged into one
	// "Kharmaan" dropdown entry purely at this display layer. Both are skipped from the normal per-singleton loop
	// below and replaced with one synthetic entry built off Alate (the gender-MALE default); set_tgui_preference's
	// "species" handler resolves a "Kharmaan" selection back to the real Alate/Gyne name based on gender (and
	// re-resolves on every later gender change too) -- see display_species_name()/resolve_kharmaan_species().
	var/list/species_map = list()
	for(var/spec_name in GLOB.playable_species)
		if(spec_name == SPECIES_MANTID_ALATE || spec_name == SPECIES_MANTID_GYNE)
			continue
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
	var/singleton/species/mantid_alate_display = GLOB.species_by_name[SPECIES_MANTID_ALATE]
	if(mantid_alate_display)
		var/sp_rsc = ""
		if(mantid_alate_display.preview_icon)
			var/sp_ico = tgui_cache_icon("species:Kharmaan", mantid_alate_display.preview_icon, "")
			var/sp_rsc_name = tgui_send_icon(tgui_rsc_name("sp", "Kharmaan"), sp_ico)
			if(sp_rsc_name)
				sp_rsc = sp_rsc_name
		species_map["Kharmaan"] = list(
			"name" = "Kharmaan",
			"desc" = mantid_alate_display.description || "",
			"lore" = list(),
			"icon" = sp_rsc,
			"use_skintones" = FALSE,
			"sexes" = TRUE,
			"enabled_features" = build_species_enabled_features(mantid_alate_display),
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
	feature_data["age"] = list(
		"minimum" = min_age,
		"maximum" = max_age,
		"step" = 1,
		"human_equivalent" = mob_species ? mob_species.get_human_equivalent_age(age) : age,
	)
	if(gender == PLURAL)
		feature_data["trans_body_type"] = list("choices" = list(MALE, FEMALE))

	if(mob_species)
		// get_hair_styles()/get_facial_hair_styles() return ASSOC lists (name→accessory).
		// Extract only the keys so JSON serializes as [] not {}.
		var/list/hair_keys = list()
		var/list/hair_icons = list()
		for(var/k in mob_species.get_hair_styles())
			hair_keys += k
			var/datum/sprite_accessory/H = GLOB.hair_styles_list[k]
			// icon_state "bald" is Bald hair's own state -- deliberately no icon sent for it, so the frontend's
			// existing "no art" fallback (a red X, see MainPage.tsx) shows instead of a blank/transparent
			// thumbnail (Bald's real icon renders as literally nothing, indistinguishable from a broken image).
			if(H && H.icon && H.icon_state != "bald")
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
			// Same "bald" icon_state suppression as head_hair_style above -- this is Shaved's state.
			if(FH && FH.icon && FH.icon_state != "bald")
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
				feature_data["bs12_desc_[tgui_descriptor_key(entry)]"] = list("choices" = desc_choices)
		for(var/organ_tag in get_all_mutant_organ_tags())
			if(!mob_species.has_organ || !(organ_tag in mob_species.has_organ))
				continue
			var/list/meta = get_mutant_category_meta(organ_tag)
			if(meta["is_erp"] && !(!config.disable_erp_preferences && master_erp_preferences))
				continue
			if(meta["is_erp"] && !organ_category_matches_gender(organ_tag))
				continue
			var/list/cat_keys = (meta["default_to_none"] && !mob_species.is_mutant_organ_mandatory(organ_tag)) ? list("None") : list()
			var/list/cat_icons = list()
			for(var/k in mob_species.get_mutant_styles(organ_tag, allow_noncanon_bodyparts))
				cat_keys += k
				var/datum/sprite_accessory/mutant/M = mob_species.get_mutant_styles(organ_tag, allow_noncanon_bodyparts)[k]
				var/icon_file
				var/preview_state
				if(M?.icon_animation)
					icon_file = M.icon_animation
					preview_state = M.preview_state ? M.preview_state : "[M.icon_state]_static"
				else if(M?.icon)
					icon_file = M.icon
					// A shape whose art has size-varying baked states (see build_colored_icon()'s `size` param) has
					// no bare "[icon_state]_s" state at all -- preview at the default size instead.
					preview_state = meta["size_key"] ? "[M.icon_state][meta["size_default"]]_s" : "[M.icon_state]_s"
				if(icon_file)
					var/ico = tgui_cache_icon("[meta["icon_prefix"]]:[k]", icon_file, preview_state)
					var/rsc_name = tgui_send_icon(tgui_rsc_name(meta["icon_prefix"], k), ico)
					if(rsc_name)
						cat_icons[k] = rsc_name
			feature_data[meta["feature_key"]] = list("choices" = cat_keys, "icons" = cat_icons, "supplemental_feature" = meta["color_key"])
			if(meta["size_key"])
				feature_data[meta["size_key"]] = list("minimum" = meta["size_min"], "maximum" = meta["size_max"], "step" = 1)
			if(organ_tag == BP_PENIS)
				feature_data["p_sheath"] = list("choices" = get_p_sheath_choices(mob_species))
	else
		feature_data["pronouns"] = list("choices" = PRONOUNS_ALL)
		// GLOB.hair_styles_list and GLOB.facial_hair_styles_list are ASSOC — extract keys only
		var/list/hair_keys = list()
		var/list/hair_icons = list()
		for(var/k in GLOB.hair_styles_list)
			hair_keys += k
			var/datum/sprite_accessory/H = GLOB.hair_styles_list[k]
			if(H.icon && H.icon_state != "bald")
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
			if(FH.icon && FH.icon_state != "bald")
				var/state = FH.preview_state ? FH.preview_state : "[FH.icon_state]_s"
				var/ico = tgui_cache_icon("facialhair:[k]", FH.icon, state)
				var/rsc_name = tgui_send_icon(tgui_rsc_name("facialhair", k), ico)
				if(rsc_name)
					facial_icons[k] = rsc_name
		feature_data["facial_hair_style"] = list("choices" = facial_keys, "icons" = facial_icons, "supplemental_feature" = "facial_hair_color")

	feature_data["blood_type"] = list("choices" = valid_bloodtypes)
	feature_data["digitigrade_legs"] = list("choices" = list(LEG_TYPE_NORMAL, LEG_TYPE_DIGITIGRADE))
	feature_data["spawnpoint"] = list("choices" = spawnpoint_keys)

	// Vocal chirps (vocal_chirps.dm). Species-independent, so this sits in the common tail rather than in either
	// branch above. "Species Default" is listed first so it reads as the neutral/default option in the dropdown.
	var/list/chirp_choices = list(VOCAL_CHIRP_SPECIES_DEFAULT)
	var/list/all_chirps = get_vocal_chirps()
	for(var/chirp_id in all_chirps)
		chirp_choices += chirp_id
	feature_data["blooper_speech"] = list("choices" = chirp_choices)
	feature_data["blooper_speech_speed"] = list("minimum" = VOCAL_CHIRP_DEFAULT_MINSPEED, "maximum" = VOCAL_CHIRP_DEFAULT_MAXSPEED, "step" = 1)
	feature_data["blooper_speech_pitch"] = list("minimum" = VOCAL_CHIRP_DEFAULT_MINPITCH, "maximum" = VOCAL_CHIRP_DEFAULT_MAXPITCH, "step" = 0.05)
	feature_data["blooper_pitch_range"] = list("minimum" = VOCAL_CHIRP_DEFAULT_MINVARY, "maximum" = VOCAL_CHIRP_DEFAULT_MAXVARY, "step" = 0.05)

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

	// Backpack options for TGUI. GET_SINGLETON_SUBTYPE_MAP() is keyed by TYPE PATH, not display name -- keying the
	// catalog (and, below, set_backpack's lookup) by that raw path instead of bo.name was the original bug here:
	// a client can only ever send text back, so a path-keyed map can never be looked up successfully by anything
	// the client sends. Key everything by bo.name instead, matching every other working picker (hair, underwear,
	// etc) and the old browser-popup UI's own backpacks_by_name (03_equipment.dm).
	var/list/tgui_backpack_choices = list()
	var/list/tgui_backpack_icons = list()
	var/list/bp_map = GET_SINGLETON_SUBTYPE_MAP(/singleton/backpack_outfit)
	for(var/bp_path in bp_map)
		var/singleton/backpack_outfit/bo = bp_map[bp_path]
		if(!bo.path)
			continue // "Nothing" (and any other pathless entry) isn't a real backpack -- must pick a real one
		tgui_backpack_choices += bo.name
		var/bp_icon_file = initial(bo.path:icon)
		if(bp_icon_file)
			var/bp_ico = tgui_cache_icon("bp:[bo.path]", bp_icon_file, initial(bo.path:icon_state))
			var/bp_rsc = tgui_send_icon(tgui_rsc_name("bp", bo.name), bp_ico)
			if(bp_rsc)
				tgui_backpack_icons[bo.name] = bp_rsc



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
	// Each option's lore blurb (/singleton/cultural_info/description), keyed the same as tgui_cultural_options --
	// previously only ever read by the legacy, pre-TGUI popup page (01_culture.dm), never surfaced to the real UI.
	var/list/tgui_cultural_descriptions = list()
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
		var/list/descriptions = list()
		if(islist(avail_values))
			for(var/value in avail_values)
				var/singleton/cultural_info/culture = SSculture.get_culture(value)
				descriptions[value] = culture ? culture.get_text_body() : ""
		tgui_cultural_descriptions[tag] = descriptions
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
		"cultural_descriptions" = tgui_cultural_descriptions,
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
		list("slot" = BP_CHEST,  "name" = "Chest"),
		list("slot" = BP_HEAD,   "name" = "Head"),
		list("slot" = BP_GROIN,  "name" = "Groin"),
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
		var/list/markings_data = build_tgui_markings_for_limb(limb_slot)
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

/datum/preferences/proc/build_tgui_markings_for_limb(limb_slot)
	var/singleton/species/mob_species = GLOB.species_by_name[species]
	var/list/limb_markings = body_markings[limb_slot]
	var/list/markings_list = list()
	var/list/disallowed = list()

	if(islist(limb_markings))
		for(var/M in limb_markings)
			var/datum/sprite_accessory/marking/mark_datum = GLOB.body_marking_styles_list[M]
			if(mark_datum)
				disallowed |= mark_datum.disallows
			var/list/mark_data = limb_markings[M]
			markings_list += list(list(
				"marking_id" = M,
				"name" = M,
				"color" = mark_data[1],
				"emissive" = mark_data[2],
			))

	var/list/marking_choices = list()
	for(var/name in GLOB.body_marking_styles_list)
		var/datum/sprite_accessory/marking/S = GLOB.body_marking_styles_list[name]
		if(!(limb_slot in S.body_parts))
			continue
		if(is_type_in_list(S, disallowed))
			continue
		if(S.species_allowed && mob_species && !(mob_species.get_bodytype() in S.species_allowed))
			continue
		if(S.subspecies_allowed && mob_species && !(mob_species.name in S.subspecies_allowed))
			continue
		marking_choices += name

	return list("markings_list" = markings_list, "marking_choices" = marking_choices)

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

// Every organ_tag with an independent mutant-organ TGUI picker. Add one entry here (and to
// get_mutant_category_meta()) per new category - everything else (enabled-feature gating, secondary/feature_data
// building, set_tgui_preference/set_tgui_color_preference handling) is generic over this list.
/datum/preferences/proc/get_all_mutant_organ_tags()
	return list(BP_TAIL, BP_HORNS, BP_FRILLS, BP_SPINES, BP_EARS, BP_XENODORSAL, BP_XENOHEAD, BP_WINGS, BP_SNOUT, BP_MOTH_ANTENNAE, BP_FLUFF, BP_BREASTS, BP_PENIS, BP_TESTICLES, BP_PUSSY, BP_ANUS)

/datum/preferences/proc/get_mutant_category_meta(organ_tag)
	switch(organ_tag)
		if(BP_TAIL)
			return list("feature_key" = "feature_lizard_tail", "color_key" = "feature_mcolor", "toggle_key" = "toggle_tail", "fallback_var" = "skin_color", "icon_prefix" = "tail", "default_to_none" = TRUE, "display_name" = "Tail")
		if(BP_HORNS)
			return list("feature_key" = "feature_lizard_horns", "color_key" = "feature_mcolor2", "toggle_key" = "toggle_horns", "fallback_var" = "head_hair_color", "icon_prefix" = "horns", "default_to_none" = TRUE, "display_name" = "Horns")
		if(BP_FRILLS)
			return list("feature_key" = "feature_lizard_frills", "color_key" = "feature_mcolor3", "toggle_key" = "toggle_frills", "fallback_var" = "head_hair_color", "icon_prefix" = "frills", "default_to_none" = TRUE, "display_name" = "Frills")
		if(BP_SPINES)
			return list("feature_key" = "feature_lizard_spines", "color_key" = "feature_mcolor4", "toggle_key" = "toggle_spines", "fallback_var" = "head_hair_color", "icon_prefix" = "spines", "default_to_none" = TRUE, "display_name" = "Spines")
		if(BP_EARS)
			return list("feature_key" = "feature_cat_ears", "color_key" = "feature_mcolor5", "toggle_key" = "toggle_ears", "fallback_var" = "head_hair_color", "icon_prefix" = "ears", "default_to_none" = TRUE, "display_name" = "Ears")
		if(BP_XENODORSAL)
			return list("feature_key" = "feature_xenodorsal", "color_key" = "feature_mcolor6", "toggle_key" = "toggle_xenodorsal", "fallback_var" = "head_hair_color", "icon_prefix" = "xenodorsal", "default_to_none" = TRUE, "display_name" = "Dorsal Spines")
		if(BP_XENOHEAD)
			return list("feature_key" = "feature_xenohead", "color_key" = "feature_mcolor7", "toggle_key" = "toggle_xenohead", "fallback_var" = "head_hair_color", "icon_prefix" = "xenohead", "default_to_none" = TRUE, "display_name" = "Carapace Plating")
		if(BP_WINGS)
			return list("feature_key" = "feature_wings", "color_key" = "feature_mcolor8", "toggle_key" = "toggle_wings", "fallback_var" = "skin_color", "icon_prefix" = "wings", "default_to_none" = TRUE, "display_name" = "Wings")
		if(BP_SNOUT)
			return list("feature_key" = "feature_snout", "color_key" = "feature_mcolor9", "toggle_key" = "toggle_snout", "fallback_var" = "head_hair_color", "icon_prefix" = "snout", "default_to_none" = TRUE, "display_name" = "Snout")
		if(BP_MOTH_ANTENNAE)
			return list("feature_key" = "feature_moth_antennae", "color_key" = "feature_mcolor10", "toggle_key" = "toggle_moth_antennae", "fallback_var" = "head_hair_color", "icon_prefix" = "mothantennae", "default_to_none" = TRUE, "display_name" = "Antennae")
		if(BP_FLUFF)
			// "#FFFFFF" (not a mob var) -- the source art is pre-colored per style (moth wing patterns each have
			// their own natural coloring, not a tintable grayscale mask like every other category here), so the
			// default has to be a no-op multiply (white) rather than skin_color, which would muddy the intended
			// per-style color. See get_mutant_fallback_color().
			return list("feature_key" = "feature_fluff", "color_key" = "feature_mcolor13", "toggle_key" = "toggle_fluff", "fallback_var" = "#FFFFFF", "icon_prefix" = "fluff", "default_to_none" = TRUE, "display_name" = "Fluff")
		if(BP_BREASTS)
			return list("feature_key" = "feature_breasts", "color_key" = "feature_mcolor11", "toggle_key" = "toggle_breasts", "fallback_var" = "skin_color", "icon_prefix" = "breasts", "default_to_none" = TRUE, "display_name" = "Breasts", "is_erp" = TRUE, \
				"size_key" = "size_breasts", "size_min" = BREASTS_MIN_SIZE, "size_max" = BREASTS_MAX_SIZE, "size_default" = BREASTS_DEFAULT_SIZE)
		if(BP_PENIS)
			return list("feature_key" = "feature_penis", "color_key" = "feature_mcolor12", "toggle_key" = "toggle_penis", "fallback_var" = "skin_color", "icon_prefix" = "penis", "default_to_none" = TRUE, "display_name" = "Penis", "is_erp" = TRUE, \
				"size_key" = "size_penis", "size_min" = PENIS_MIN_SIZE, "size_max" = PENIS_MAX_SIZE, "size_default" = PENIS_DEFAULT_SIZE)
		if(BP_TESTICLES)
			return list("feature_key" = "feature_testicles", "color_key" = "feature_mcolor14", "toggle_key" = "toggle_testicles", "fallback_var" = "skin_color", "icon_prefix" = "testicles", "default_to_none" = TRUE, "display_name" = "Testicles", "is_erp" = TRUE, \
				"size_key" = "size_testicles", "size_min" = TESTICLES_MIN_SIZE, "size_max" = TESTICLES_MAX_SIZE, "size_default" = TESTICLES_DEFAULT_SIZE)
		if(BP_PUSSY)
			return list("feature_key" = "feature_vagina", "color_key" = "feature_mcolor15", "toggle_key" = "toggle_vagina", "fallback_var" = "skin_color", "icon_prefix" = "vagina", "default_to_none" = TRUE, "display_name" = "Vagina", "is_erp" = TRUE)
		if(BP_ANUS)
			// No style/color dimension at all -- see mutant_anus.dm's header for why (no source art exists to pick
			// a shape/color of). "feature_key"/"color_key"/"icon_prefix" are still filled in (rather than left
			// null) purely so the generic per-category loops that build the client-facing feature list don't need
			// a null-field special case; the TGUI side only ever renders this category's "toggle_key" as a plain
			// enable/disable checkbox (species_features.tsx), never a style dropdown or color picker.
			return list("feature_key" = "feature_anus", "color_key" = "feature_mcolor16", "toggle_key" = "toggle_anus", "fallback_var" = "skin_color", "icon_prefix" = "anus", "default_to_none" = TRUE, "display_name" = "Anus", "is_erp" = TRUE)
	return null

// meta["fallback_var"] is normally a mob var name (skin_color, head_hair_color) looked up dynamically via vars[] --
// but for a baked-color category like Fluff, the correct "no tint yet" default is a literal white (multiply
// identity), not any mob var. A leading "#" marks fallback_var as a literal color instead of a var name.
/datum/preferences/proc/get_mutant_fallback_color(list/meta, singleton/species/mob_species)
	if(meta["is_erp"] && mob_species?.default_genital_color)
		return mob_species.default_genital_color
	var/fb = meta["fallback_var"]
	if(copytext(fb, 1, 2) == "#")
		return fb
	return vars[fb]

/datum/preferences/proc/get_organ_tag_for_feature_key(feature_key)
	for(var/organ_tag in get_all_mutant_organ_tags())
		var/list/meta = get_mutant_category_meta(organ_tag)
		if(meta["feature_key"] == feature_key)
			return organ_tag
	return null

// Male body type -> penis/testicles only; Female body type -> breasts/vagina only; Trans (PLURAL) and Other
// (NEUTER, Diona-exclusive) -> both sets, matching "always choosable for they/them or it/its" from the canon
// matrix. Anus and every non-genital category are unrestricted (TRUE) -- this only ever gates the 4 sexed
// categories.
// "Sheath" is Anthro-exclusive, canonically -- every other species either voluntarily picks (or is forced into,
// via force_male_sheath_mode) whatever names its own "Slit"/species-alias mirror instead. The third choice always
// names whatever style force_male_sheath_mode (species.dm) would force a male into -- "Slit" by default, but e.g.
// Teshari's own "Cloaca" mirror (accessory_mutant_penis_anthro.dm) replaces it here instead of adding a 4th
// option, matching how it's described as a same-art rename rather than a genuinely separate choice.
/datum/preferences/proc/get_p_sheath_choices(singleton/species/mob_species)
	var/list/choices = list("None")
	if(mob_species && mob_species.get_bodytype() == SPECIES_ANTHRO)
		choices += "Sheath"
	choices += (mob_species ? (mob_species.force_male_sheath_mode || "Slit") : "Slit")
	return choices

/datum/preferences/proc/organ_category_matches_gender(organ_tag)
	// Same bypass as the species-canon filter (get_mutant_styles()'s allow_noncanon param) -- a gender mismatch is
	// just as much a "non-canon" pick as a species mismatch, so the one toggle covers both consistently.
	if(allow_noncanon_bodyparts)
		return TRUE
	switch(organ_tag)
		if(BP_PENIS, BP_TESTICLES)
			return gender != FEMALE
		if(BP_BREASTS, BP_PUSSY)
			return gender != MALE
	return TRUE

// Fires once, the moment Enable Sexual Content flips from off to on -- picks sensible canon defaults for Male/
// Female bodies (e.g. Male GAS: Slit + Hemipenis + Anus; Female GAS: a "Human" vagina) so a player isn't dropped
// into a totally blank set of toggles. Trans/Other get nothing auto-assigned (stays "None"/disabled, same as
// today) since they're meant to opt into whichever parts they want themselves. Never overwrites a category the
// player already has a real choice in (re-toggling ERP off and back on doesn't clobber anything).
/datum/preferences/proc/auto_assign_default_genitals()
	if(gender != MALE && gender != FEMALE)
		return
	var/singleton/species/mob_species = GLOB.species_by_name[species]
	if(!mob_species)
		return
	for(var/organ_tag in list(BP_PENIS, BP_TESTICLES, BP_BREASTS, BP_PUSSY, BP_ANUS))
		if(!mob_species.has_organ || !(organ_tag in mob_species.has_organ))
			continue
		if(organ_tag != BP_ANUS && !organ_category_matches_gender(organ_tag))
			continue
		var/list/cat_entry = islist(mutant_organs[organ_tag]) ? mutant_organs[organ_tag] : list("style" = null, "colors" = list("", "", ""), "enabled" = FALSE)
		if(cat_entry["enabled"])
			continue
		cat_entry["enabled"] = TRUE
		if(organ_tag != BP_ANUS)
			// Always the CANON list here, regardless of the player's own Allow Non-Canon Bodyparts setting --
			// auto-assignment should always land on something that matches their species.
			var/list/style_list = mob_species.get_mutant_styles(organ_tag, FALSE)
			var/default_style = pick_default_genital_style(organ_tag, style_list)
			if(default_style)
				cat_entry["style"] = default_style
		if(organ_tag == BP_PENIS && gender == MALE && mob_species.force_male_sheath_mode)
			cat_entry["sheath_mode"] = mob_species.force_male_sheath_mode
		mutant_organs[organ_tag] = cat_entry

// Shared by auto_assign_default_genitals() above and copy_to()'s (preferences.dm) stale-style fallback -- "Human"
// if the species/gender combo allows it, else "Pair" for Testicles specifically (alphabetical order alone would
// pick "Internal" first for Human/Anthro/Machine too, which isn't the intended default), else alphabetically
// first (ADD_SORTED already sorts get_mutant_styles()'s result, so style_list[1] is well-defined).
/datum/preferences/proc/pick_default_genital_style(organ_tag, list/style_list)
	if(!length(style_list))
		return null
	if("Human" in style_list)
		return "Human"
	if(organ_tag == BP_TESTICLES && ("Pair" in style_list))
		return "Pair"
	return style_list[1]

/datum/preferences/proc/get_organ_tag_for_color_key(color_key)
	for(var/organ_tag in get_all_mutant_organ_tags())
		var/list/meta = get_mutant_category_meta(organ_tag)
		if(meta["color_key"] == color_key)
			return organ_tag
	return null

/datum/preferences/proc/get_organ_tag_for_toggle_key(toggle_key)
	for(var/organ_tag in get_all_mutant_organ_tags())
		var/list/meta = get_mutant_category_meta(organ_tag)
		if(meta["toggle_key"] == toggle_key)
			return organ_tag
	return null

/datum/preferences/proc/get_organ_tag_for_size_key(size_key)
	for(var/organ_tag in get_all_mutant_organ_tags())
		var/list/meta = get_mutant_category_meta(organ_tag)
		if(meta["size_key"] == size_key)
			return organ_tag
	return null

// A mutant-organ category is only actually granted (and its style/color pickers only shown) once the player
// explicitly opts in via its toggle -- off by default, matching "you do not gain that organ" until checked.
/datum/preferences/proc/is_mutant_organ_enabled(organ_tag)
	var/list/choice = mutant_organs[organ_tag]
	return islist(choice) && choice["enabled"]

/datum/preferences/proc/build_species_enabled_features(singleton/species/S)
	var/list/enabled = list("age", "pronouns", "blood_type", "nearsighted")
	// master_erp_preferences/allow_noncanon_bodyparts are intentionally never listed here -- this `enabled` list
	// feeds server_data (useServerPrefs(), randomization-availability metadata only), NOT the actual PreferenceList
	// grid (which renders data.character_preferences.secondary_features in full, unfiltered by this list -- the
	// real fix for both those two showing up as "Feature ... is not recognized" was moving their values out of
	// the main ui_data()'s `secondary` var into `misc` instead, read directly by CharacterAlteringToggles.tsx).
	var/erp_allowed = !config.disable_erp_preferences
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
	if(S.appearance_flags & SPECIES_APPEARANCE_HAS_LEG_TYPE)
		enabled += "digitigrade_legs"
	if(LAZYLEN(S.descriptors))
		for(var/entry in S.descriptors)
			enabled += "bs12_desc_[tgui_descriptor_key(entry)]"
	for(var/organ_tag in get_all_mutant_organ_tags())
		var/toggle_only = (organ_tag == BP_ANUS)
		if(!S.has_organ || !(organ_tag in S.has_organ) || (!toggle_only && !length(S.get_mutant_styles(organ_tag, allow_noncanon_bodyparts))))
			continue
		var/list/meta = get_mutant_category_meta(organ_tag)
		if(meta["is_erp"] && !(erp_allowed && master_erp_preferences))
			continue
		if(meta["is_erp"] && !organ_category_matches_gender(organ_tag))
			continue
		if(toggle_only)
			enabled += meta["toggle_key"]
		else if(S.is_mutant_organ_mandatory(organ_tag))
			// Always present, no opt-in toggle to show -- see is_mutant_organ_mandatory() (species_getters.dm).
			enabled += meta["feature_key"]
			enabled += meta["color_key"]
			if(meta["size_key"])
				enabled += meta["size_key"]
		else
			enabled += meta["toggle_key"]
			if(is_mutant_organ_enabled(organ_tag))
				enabled += meta["feature_key"]
				enabled += meta["color_key"]
				if(meta["size_key"])
					enabled += meta["size_key"]
				if(organ_tag == BP_PENIS)
					enabled += "p_sheath"
	return enabled

// TGUI feature keys have to be valid JS identifiers for a static `export const` to match them (see the features/
// auto-discovery in tgui/.../preferences/features/index.ts) -- some /datum/mob_descriptor names have a literal
// space in them (e.g. "headtail length", "body length"), which a bare "bs12_desc_[entry]" key would carry
// straight through as an un-exportable identifier. Sanitize only at this TGUI boundary, not the descriptor
// system's own .name var, since that's used unrelated elsewhere (species.descriptors's own key, chat messages).
/proc/tgui_descriptor_key(entry)
	return replacetext(entry, " ", "_")

// Every OOC/player-facing field (OOC Notes, headshots, art reference, flavor text, dating preferences, ERP tags,
// directory visibility, and now Mechanical ERP) is meant to take effect immediately, even mid-round -- unlike the
// character-altering toggles (Enable Sexual Content, Allow Non-Canon Bodyparts, species, gender, organs), which are
// spawn-time-only by design. Historically NONE of these actually did that: every setter here only ever wrote to
// this /datum/preferences instance, and the only place any of it reached a mob was copy_to(), called exactly once
// at character creation (new_player.dm) -- editing OOC Notes mid-round silently did nothing to what other players
// already saw. These two helpers push a live edit directly onto whatever mob this client is CURRENTLY playing (if
// any), using the same var name copy_to() writes to, so an edit takes effect immediately without a respawn.
/datum/preferences/proc/sync_live_mob(field, value)
	if(!client)
		return
	var/mob/living/carbon/human/H = client.mob
	if(!istype(H))
		return
	H.vars[field] = value

// Same as sync_live_mob() above, but for the subset of fields copy_to() locks to an "off" value when ERP is
// disabled (attraction, ERP tags, etc -- see copy_to()'s own erp_on ? X : <off> lines, preferences.dm). Gated on
// the MOB's own already-copied master_erp_preferences, not this datum's live (possibly since-changed) preference --
// Enable Sexual Content itself only ever takes effect at spawn, so a currently-playing mob should keep behaving
// like whatever ERP state it actually spawned with until it respawns, even if the saved preference has since
// changed underneath it.
/datum/preferences/proc/sync_live_mob_erp_gated(field, value, off_value)
	if(!client)
		return
	var/mob/living/carbon/human/H = client.mob
	if(!istype(H))
		return
	H.vars[field] = H.master_erp_preferences ? value : off_value

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

		if("open_food", "delete_character")
			return TRUE

		if("rotate")
			preview_dir = turn(preview_dir, params["backwards"] ? 90 : -90)
			preview_icon = null
			SStgui.update_uis(src)
			return TRUE

		if("update_preview")
			// Nude/Underwear/Loadout/Job preview-dressing toggle -- reuses the preview_job/preview_gear booleans
			// and dress_preview_mob() (05_preview.dm) that already drove the old HTML preview panel's "Hide/Show
			// Loadout"/"Hide/Show Uniform" buttons, plus the new preview_nude flag for the Nude/Underwear split
			// (with both job and gear off, the mannequin still shows whatever underwear copy_to() gave it unless
			// preview_nude explicitly strips it -- see dress_preview_mob()).
			switch(params["updated_preview"])
				if("Job")
					preview_job = TRUE
					preview_gear = FALSE
					preview_nude = FALSE
					preview_aroused = FALSE
				if("Loadout")
					preview_job = FALSE
					preview_gear = TRUE
					preview_nude = FALSE
					preview_aroused = FALSE
				if("Underwear")
					preview_job = FALSE
					preview_gear = FALSE
					preview_nude = FALSE
					preview_aroused = FALSE
				if("Naked")
					preview_job = FALSE
					preview_gear = FALSE
					preview_nude = TRUE
					preview_aroused = FALSE
				if("Naked (Aroused)")
					preview_job = FALSE
					preview_gear = FALSE
					preview_nude = TRUE
					preview_aroused = TRUE
				else
					return FALSE
			preview_icon = null
			SStgui.update_uis(src)
			return TRUE

		if("change_slot")
			var/new_slot = text2num("[params["slot"]]")
			if(isnull(new_slot))
				return FALSE
			save_preferences()
			save_character()
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
			preview_icon = null // job_high drives dress_preview_mob()'s uniform/gear choice
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
				preview_icon = null
				return TRUE
			// Validate the new title exists in this job's alt_titles
			if(!islist(J.alt_titles) || !(new_title in J.alt_titles))
				return FALSE
			if(!islist(player_alt_titles))
				player_alt_titles = list()
			player_alt_titles[job_name] = new_title
			preview_icon = null
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
			preview_icon = null // branch/rank affect equip_preview()'s insignia
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
			preview_icon = null
			return TRUE

		// Audition button next to the chirp dropdown (character_voice.tsx). Previews whichever entry is currently
		// highlighted -- params["chirp"] -- falling back to the saved one, so you can hear options before
		// committing. Cooldown because the button is trivially spam-clickable.
		if("play_blooper")
			if(world.time < next_chirp_preview_time)
				return FALSE
			if(!user)
				return FALSE
			var/preview_id = params["chirp"] || vocal_chirp_id
			var/singleton/vocal_chirp/chirp = get_vocal_chirp_by_id(preview_id)
			if(!chirp)
				// "Species Default" (the default value) has no sound of its own -- say so rather than having the
				// button appear broken, which is exactly how it read before.
				to_chat(user, SPAN_NOTICE("Pick a vocal chirp other than \"[VOCAL_CHIRP_SPECIES_DEFAULT]\" to hear a preview."))
				return FALSE
			var/pitch = clamp(vocal_chirp_pitch, chirp.min_pitch, chirp.max_pitch)
			var/variance = clamp(vocal_chirp_variance, chirp.min_variance, chirp.max_variance)
			next_chirp_preview_time = world.time + 2 SECONDS
			// is_global with no turf source: a menu preview shouldn't be positional, and shouldn't be attenuated
			// by the previewing mob's surroundings (playsound_local zeroes volume outright in vacuum).
			user.playsound_local(null, chirp.sound_file, 60, TRUE, VOCAL_CHIRP_DO_VARY(pitch, variance), is_global = TRUE)
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

		if("set_tricolor_preference")
			var/color_changed = set_tgui_tricolor_preference(params["preference"], text2num("[params["value"]]"), mob_species, user)
			if(color_changed)
				if(isnull(preview_icon))
					build_tgui_preview(user)  // Pre-send RSC before TGUI data so client has it ready
				SStgui.update_uis(src)
			return color_changed

		if("reset_genital_color_to_skin")
			var/color_reset = reset_tgui_organ_color_to_skin(params["preference"], mob_species)
			if(color_reset)
				if(isnull(preview_icon))
					build_tgui_preview(user)
				SStgui.update_uis(src)
			return color_reset

		if("set_random_preference")
			return TRUE // BS12 has no randomization system - silently succeed

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
				if("ooc_notes")
					ooc_notes = value
					sync_live_mob("ooc_notes", value)
				else
					return FALSE

		// Not run through sanitize()'s html-encode path -- these are URLs, and encoding would mangle
		// legitimate query-string characters real image-CDN links use. is_valid_media_url() (05_identity_media.dm)
		// already constrains the character set tightly (https + whitelisted host + real image extension).
		if("set_headshot_url")
			var/value = trimtext("[params["value"]]")
			if(length(value) && !is_valid_media_url(value))
				to_chat(usr, SPAN_WARNING(MEDIA_URL_REJECTED_MESSAGE))
				return FALSE
			headshot_url = value
			sync_live_mob("headshot_url", value)
			return TRUE

		if("set_art_reference_url")
			var/value = trimtext("[params["value"]]")
			if(length(value) && !is_valid_media_url(value))
				to_chat(usr, SPAN_WARNING(MEDIA_URL_REJECTED_MESSAGE))
				return FALSE
			art_reference_url = value
			sync_live_mob("art_reference_url", value)
			return TRUE

		if("set_headshot_nsfw_url")
			var/value = trimtext("[params["value"]]")
			if(length(value) && !is_valid_media_url(value))
				to_chat(usr, SPAN_WARNING(MEDIA_URL_REJECTED_MESSAGE))
				return FALSE
			headshot_nsfw_url = value
			sync_live_mob("headshot_nsfw_url", value)
			return TRUE

		if("set_art_ref_nsfw")
			art_ref_nsfw = !!params["value"]
			sync_live_mob("art_ref_nsfw", art_ref_nsfw)
			return TRUE

		if("set_headshot_ai_generated")
			headshot_ai_generated = !!params["value"]
			sync_live_mob("headshot_ai_generated", headshot_ai_generated)
			return TRUE

		if("set_headshot_nsfw_ai_generated")
			headshot_nsfw_ai_generated = !!params["value"]
			sync_live_mob("headshot_nsfw_ai_generated", headshot_nsfw_ai_generated)
			return TRUE

		if("set_art_reference_ai_generated")
			art_reference_ai_generated = !!params["value"]
			sync_live_mob("art_reference_ai_generated", art_reference_ai_generated)
			return TRUE

		// Non-sexual, viewer-side -- no ERP gate, no sync_live_mob() (read live off client.prefs directly instead,
		// see the var's own comment). A plain, always-editable toggle.
		if("set_view_ai_generated_headshots")
			view_ai_generated_headshots = !!params["value"]
			return TRUE

		// General "who am I looking to play with" dating-preference dropdowns -- NOT ERP-gated, matching
		// Bubberstation's own split (these are PREFERENCE_PLAYER-level there, distinct from the ERP tag matrix
		// below, which Bubberstation does gate behind its ERP master switch).
		if("set_erp_directory_choice")
			var/field = params["field"]
			var/value = "[params["value"]]"
			// Off-values mirror copy_to()'s own erp_on ? X : <off> lines (preferences.dm) exactly -- these fields
			// aren't gated at the editor level (see the header comment above -- NOT ERP-gated), so a live edit
			// still needs to check the mob's own ERP state itself before deciding whether to show the real value
			// or the off one, same as copy_to() does at spawn.
			switch(field)
				if("attraction")
					if(value in GLOB.valid_attraction_types)
						attraction = value
						sync_live_mob_erp_gated("attraction", value, "Unset")
				if("display_gender")
					if(value in GLOB.valid_display_genders)
						display_gender = value
						sync_live_mob("display_gender", value) // not ERP-gated even at spawn -- see copy_to()
				if("emote_length")
					if(value in GLOB.valid_emote_lengths)
						emote_length = value
						sync_live_mob_erp_gated("emote_length", value, "No Preference")
				if("approach_pref")
					if(value in GLOB.valid_approach_prefs)
						approach_pref = value
						sync_live_mob_erp_gated("approach_pref", value, "Unset")
				if("furry_pref")
					if(value in GLOB.valid_directory_character_prefs)
						furry_pref = value
						sync_live_mob_erp_gated("furry_pref", value, "No ERP")
				if("scalie_pref")
					if(value in GLOB.valid_directory_character_prefs)
						scalie_pref = value
						sync_live_mob_erp_gated("scalie_pref", value, "No ERP")
				if("other_pref")
					if(value in GLOB.valid_directory_character_prefs)
						other_pref = value
						sync_live_mob_erp_gated("other_pref", value, "No ERP")
				if("demihuman_pref")
					if(value in GLOB.valid_directory_character_prefs)
						demihuman_pref = value
						sync_live_mob_erp_gated("demihuman_pref", value, "No ERP")
				if("human_pref")
					if(value in GLOB.valid_directory_character_prefs)
						human_pref = value
						sync_live_mob_erp_gated("human_pref", value, "No ERP")
				if("show_nsfw_flavor_text")
					if(value in GLOB.valid_show_nsfw_flavor_text)
						show_nsfw_flavor_text = value
						sync_live_mob_erp_gated("show_nsfw_flavor_text", value, "Never")
				else
					return FALSE
			return TRUE

		// ERP tag matrix -- gated behind the same three-way switch (config flag + master ERP toggle) as the
		// genital preferences, matching Bubberstation's own is_accessible()/deserialize() gate on these fields.
		if("set_erp_status_choice")
			if(config.disable_erp_preferences || !master_erp_preferences)
				return FALSE
			var/field = params["field"]
			var/value = "[params["value"]]"
			switch(field)
				if("erp_status")
					if(value in GLOB.valid_erp_statuses)
						erp_status = value
						sync_live_mob_erp_gated("erp_status", value, "No")
				if("erp_status_nc")
					if(value in GLOB.valid_erp_statuses_nc)
						erp_status_nc = value
						sync_live_mob_erp_gated("erp_status_nc", value, "No")
				if("erp_status_v")
					if(value in GLOB.valid_erp_statuses_v)
						erp_status_v = value
						sync_live_mob_erp_gated("erp_status_v", value, "No")
				if("erp_status_hypno")
					if(value in GLOB.valid_erp_statuses_hypno)
						erp_status_hypno = value
						sync_live_mob_erp_gated("erp_status_hypno", value, "No")
				else
					return FALSE
			return TRUE

		if("set_erp_free_use")
			if(config.disable_erp_preferences || !master_erp_preferences)
				return FALSE
			erp_free_use = !!params["value"]
			sync_live_mob_erp_gated("erp_free_use", erp_free_use, FALSE)
			return TRUE

		if("set_can_knot_partners")
			if(config.disable_erp_preferences || !master_erp_preferences)
				return FALSE
			can_knot_partners = !!params["value"]
			sync_live_mob_erp_gated("can_knot_partners", can_knot_partners, FALSE)
			return TRUE

		if("set_mechanical_erp")
			if(config.disable_erp_preferences || !master_erp_preferences)
				return FALSE
			mechanical_erp = !!params["value"]
			sync_live_mob_erp_gated("mechanical_erp", mechanical_erp, FALSE)
			return TRUE

		if("set_show_in_directory")
			if(config.disable_erp_preferences || !master_erp_preferences)
				return FALSE
			show_in_directory = !!params["value"]
			// Ungated, matching copy_to()'s own unconditional character.show_in_directory = show_in_directory --
			// the editor gate above already prevents turning this on unless ERP is enabled.
			sync_live_mob("show_in_directory", show_in_directory)
			return TRUE

		if("set_character_ad")
			character_ad = sanitize("[params["value"]]", 0, extra = 0)
			sync_live_mob("character_ad", character_ad)
			return TRUE

		if("set_custom_species")
			custom_species = sanitize("[params["value"]]", 0, extra = 0)
			sync_live_mob("custom_species", custom_species)
			return TRUE

		if("set_custom_species_lore")
			custom_species_lore = sanitize("[params["value"]]", 0, extra = 0)
			sync_live_mob("custom_species_lore", custom_species_lore)
			return TRUE

		// Named distinctly from /mob/var/flavor_text (character_flavor_text, not flavor_text) even though this is
		// now the sole source copy_to() uses to populate that base var -- the per-bodypart flavor_texts list this
		// used to disambiguate against is gone (retired along with the rest of the per-limb editor).
		if("set_character_flavor_text")
			character_flavor_text = sanitize("[params["value"]]", 0, extra = 0)
			sync_live_mob("character_flavor_text", character_flavor_text)
			sync_live_mob("flavor_text", character_flavor_text) // copy_to() populates both from this one field
			return TRUE

		if("set_flavor_text_nsfw")
			flavor_text_nsfw = sanitize("[params["value"]]", 0, extra = 0)
			sync_live_mob("flavor_text_nsfw", flavor_text_nsfw)
			return TRUE

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
			var/singleton/backpack_outfit/new_bp = get_backpack_outfit_by_name(bp_name)
			if(!new_bp || !new_bp.path)
				return FALSE
			backpack = new_bp
			preview_icon = null
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
			preview_icon = null
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
			preview_icon = null
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
			if(!L || L.is_abstract())
				return FALSE
			if(L.flags & RESTRICTED)
				return FALSE
			// Gate on the same rules character setup uses, so a language accepted here is one that survives spawn.
			var/datum/category_item/player_setup_item/background/languages/item = get_language_setup_item()
			if(!item)
				return FALSE
			item.refresh_language_cache()
			if(item.free_languages[lang_name] || !item.is_allowed_language(item.preference_mob(), L))
				return FALSE
			if(!islist(alternate_languages))
				alternate_languages = list()
			if(lang_name in alternate_languages)
				return TRUE
			if(length(alternate_languages) >= MAX_LANGUAGES)
				return FALSE
			alternate_languages[lang_name] = sanitize_language_level(params["level"])
			return TRUE

		if("set_language_level")
			var/lang_name = params["language_name"]
			if(!istext(lang_name) || !islist(alternate_languages) || !(lang_name in alternate_languages))
				return FALSE
			alternate_languages[lang_name] = sanitize_language_level(params["level"])
			return TRUE

		if("set_language_variant")
			// Swapping which regional variant of a group the character speaks, keeping the level they had chosen.
			var/old_name = params["language_name"]
			var/new_name = params["variant_name"]
			if(!istext(old_name) || !istext(new_name) || !islist(alternate_languages) || !(old_name in alternate_languages))
				return FALSE
			var/datum/language/old_lang = all_languages[old_name]
			var/datum/language/new_lang = all_languages[new_name]
			if(!old_lang || !new_lang || new_lang.is_abstract())
				return FALSE
			if(!old_lang.language_group || old_lang.language_group != new_lang.language_group)
				return FALSE
			if(new_name == old_name)
				return TRUE
			var/level = alternate_languages[old_name]
			alternate_languages -= old_name
			alternate_languages[new_name] = level
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
			preview_icon = null
			return TRUE

		if("clear_all_items")
			if(islist(gear_list) && islist(gear_list[gear_slot]))
				gear_list[gear_slot].Cut()
			preview_icon = null
			return TRUE

		// Loadout gear-tweak customization and preset management — stubs
		if("pass_to_loadout_item", "set_loadout_preset", "add_loadout_preset", "rename_loadout_preset", "remove_loadout_preset", "toggle_job_clothes")
			return TRUE

		// No preset content exists in this codebase yet - accepted as a harmless no-op.
		if("set_preset")
			return TRUE

		if("add_marking")
			var/limb_slot = params["limb_slot"]
			if(!istext(limb_slot) || !(limb_slot in GLOB.marking_limb_slots))
				return FALSE
			var/list/marking_data = build_tgui_markings_for_limb(limb_slot)
			var/list/limb_markings = body_markings[limb_slot]
			if(!islist(limb_markings))
				limb_markings = list()
				body_markings[limb_slot] = limb_markings
			if(length(limb_markings) >= MAX_MARKINGS_PER_LIMB)
				return FALSE
			var/list/choices = marking_data["marking_choices"] - limb_markings
			if(!length(choices))
				return FALSE
			limb_markings[choices[1]] = list("#CCCCCC", FALSE) // no more #000000 defaults -- full black looked bad
			preview_icon = null
			return TRUE

		if("remove_marking")
			var/limb_slot = params["limb_slot"]
			var/marking_id = params["marking_id"]
			if(!istext(limb_slot) || !(limb_slot in GLOB.marking_limb_slots))
				return FALSE
			var/list/limb_markings = body_markings[limb_slot]
			if(islist(limb_markings))
				limb_markings -= marking_id
			preview_icon = null
			return TRUE

		if("change_marking")
			var/limb_slot = params["limb_slot"]
			var/marking_id = params["marking_id"]
			var/new_name = params["marking_name"]
			if(!istext(limb_slot) || !(limb_slot in GLOB.marking_limb_slots))
				return FALSE
			var/list/limb_markings = body_markings[limb_slot]
			if(!islist(limb_markings) || !(marking_id in limb_markings))
				return FALSE
			if(new_name != marking_id && (new_name in limb_markings))
				return FALSE
			var/list/marking_data = build_tgui_markings_for_limb(limb_slot)
			if(!(new_name in (marking_data["marking_choices"] + marking_id)))
				return FALSE
			var/list/old_entry = limb_markings[marking_id]
			limb_markings -= marking_id
			limb_markings[new_name] = old_entry
			preview_icon = null
			return TRUE

		if("color_marking")
			var/limb_slot = params["limb_slot"]
			var/marking_id = params["marking_id"]
			if(!istext(limb_slot) || !(limb_slot in GLOB.marking_limb_slots))
				return FALSE
			var/list/limb_markings = body_markings[limb_slot]
			if(!islist(limb_markings) || !(marking_id in limb_markings))
				return FALSE
			var/list/entry = limb_markings[marking_id]
			var/new_color = input(user, "Choose the [marking_id] color:", "Marking Color", entry[1]) as color|null
			if(new_color)
				entry[1] = new_color
				preview_icon = null
			return TRUE

		if("change_emissive")
			var/limb_slot = params["limb_slot"]
			var/marking_id = params["marking_id"]
			if(!istext(limb_slot) || !(limb_slot in GLOB.marking_limb_slots))
				return FALSE
			var/list/limb_markings = body_markings[limb_slot]
			if(!islist(limb_markings) || !(marking_id in limb_markings))
				return FALSE
			var/list/entry = limb_markings[marking_id]
			entry[2] = !entry[2]
			preview_icon = null
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
			preview_icon = null
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
			preview_icon = null
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
			preview_icon = null
			return TRUE

	return FALSE

// Kharmaan Alate/Gyne (mantid.dm) are merged into one "Kharmaan" species-dropdown entry at this display layer
// only -- pref.species itself is always a real, valid singleton name (never the literal string "Kharmaan"), so
// every other species_by_name[pref.species] lookup across the codebase keeps working unmodified. Body Type
// (gender) picks which real datum "Kharmaan" resolves to: FEMALE -> Gyne, anything else -> Alate (the default).
/proc/resolve_kharmaan_species(target_gender)
	return (target_gender == FEMALE) ? SPECIES_MANTID_GYNE : SPECIES_MANTID_ALATE

/proc/display_species_name(real_species_name)
	if(real_species_name == SPECIES_MANTID_ALATE || real_species_name == SPECIES_MANTID_GYNE)
		return "Kharmaan"
	return real_species_name

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
			// Kharmaan: Body Type actually swaps the underlying Alate/Gyne species datum (different age range,
			// limbs, organs) -- checked BEFORE the "value in mob_species.genders" guard below, since Alate/Gyne
			// are each deliberately single-gender (genders = list(MALE)/list(FEMALE)), so the guard would always
			// reject the very value ("female"/"male") that's supposed to trigger the switch to the other one.
			if((species == SPECIES_MANTID_ALATE || species == SPECIES_MANTID_GYNE) && (value == MALE || value == FEMALE))
				var/resolved = resolve_kharmaan_species(value)
				if(resolved != species)
					return set_tgui_preference("species", resolved, mob_species, user)
			if(mob_species && (value in mob_species.genders))
				gender = value
				if(!(facial_hair_style in mob_species.get_facial_hair_styles(gender)))
					var/list/valid_facial = mob_species.get_facial_hair_styles(gender)
					if(length(valid_facial))
						facial_hair_style = valid_facial[1]
			preview_icon = null
			return TRUE

		if("species")
			var/target_species = (value == "Kharmaan") ? resolve_kharmaan_species(gender) : value
			if(!(target_species in GLOB.playable_species))
				return FALSE
			var/prev_species = species
			species = target_species
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
				head_hair_color = "#CCCCCC" // no more #000000 defaults -- full black looked bad
				skin_tone = 0
				age = clamp(age, mob_species.min_age, mob_species.max_age)
				if(istype(body_markings))
					body_markings.Cut()
				if(istype(picked_traits))
					picked_traits.Cut()
				cultural_info = mob_species.default_cultural_info.Copy()
				tgui_sanitize_organs()
				tgui_sanitize_mutant_organs()
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

		// Vocal chirps (vocal_chirps.dm). No preview_icon invalidation -- these don't affect the sprite. No
		// live-sync either: they're a physical trait and only reach the mob via copy_to() at spawn.
		if("blooper_speech")
			if(value == VOCAL_CHIRP_SPECIES_DEFAULT || get_vocal_chirp_by_id(value))
				vocal_chirp_id = value
			return TRUE

		if("blooper_speech_speed")
			if(isnum(value))
				vocal_chirp_speed = clamp(value, VOCAL_CHIRP_DEFAULT_MINSPEED, VOCAL_CHIRP_DEFAULT_MAXSPEED)
			return TRUE

		if("blooper_speech_pitch")
			if(isnum(value))
				vocal_chirp_pitch = clamp(value, VOCAL_CHIRP_DEFAULT_MINPITCH, VOCAL_CHIRP_DEFAULT_MAXPITCH)
			return TRUE

		if("blooper_pitch_range")
			if(isnum(value))
				vocal_chirp_variance = clamp(value, VOCAL_CHIRP_DEFAULT_MINVARY, VOCAL_CHIRP_DEFAULT_MAXVARY)
			return TRUE

		if("trans_body_type")
			if(gender != PLURAL || !(value in list(MALE, FEMALE)))
				return FALSE
			trans_body_type = value
			preview_icon = null
			return TRUE

		if("blood_type")
			if(value in valid_bloodtypes)
				b_type = value
			return TRUE

		if("digitigrade_legs")
			if(value in list(LEG_TYPE_NORMAL, LEG_TYPE_DIGITIGRADE))
				leg_type = value
				preview_icon = null
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

		if("feature_lizard_tail", "feature_lizard_horns", "feature_lizard_frills", "feature_lizard_spines", "feature_cat_ears", "feature_xenodorsal", "feature_xenohead", "feature_wings", "feature_snout", "feature_moth_antennae", "feature_fluff", "feature_breasts", "feature_penis", "feature_testicles", "feature_vagina")
			var/organ_tag = get_organ_tag_for_feature_key(pref_name)
			if(!organ_tag || !mob_species || !mob_species.has_organ || !(organ_tag in mob_species.has_organ))
				return FALSE
			var/list/meta = get_mutant_category_meta(organ_tag)
			if(meta["is_erp"] && !organ_category_matches_gender(organ_tag))
				return FALSE
			var/is_none = meta["default_to_none"] && !mob_species.is_mutant_organ_mandatory(organ_tag) && value == "None"
			if(!is_none && !(value in mob_species.get_mutant_styles(organ_tag, allow_noncanon_bodyparts)))
				return FALSE
			if(!islist(mutant_organs[organ_tag]))
				mutant_organs[organ_tag] = list("style" = value, "colors" = list("", "", ""), "enabled" = FALSE)
			else
				var/list/cat_entry = mutant_organs[organ_tag]
				cat_entry["style"] = value
			preview_icon = null
			return TRUE

		if("toggle_tail", "toggle_horns", "toggle_frills", "toggle_spines", "toggle_ears", "toggle_xenodorsal", "toggle_xenohead", "toggle_wings", "toggle_snout", "toggle_moth_antennae", "toggle_fluff", "toggle_breasts", "toggle_penis", "toggle_testicles", "toggle_vagina", "toggle_anus")
			var/organ_tag = get_organ_tag_for_toggle_key(pref_name)
			if(!organ_tag || !mob_species || !mob_species.has_organ || !(organ_tag in mob_species.has_organ))
				return FALSE
			if(value)
				var/list/meta = get_mutant_category_meta(organ_tag)
				if(meta["is_erp"] && !organ_category_matches_gender(organ_tag))
					return FALSE
			if(!islist(mutant_organs[organ_tag]))
				mutant_organs[organ_tag] = list("style" = null, "colors" = list("", "", ""), "enabled" = !!value)
			else
				var/list/cat_entry = mutant_organs[organ_tag]
				cat_entry["enabled"] = !!value
			preview_icon = null
			return TRUE

		if("size_breasts", "size_penis", "size_testicles")
			var/organ_tag = get_organ_tag_for_size_key(pref_name)
			if(!organ_tag || !mob_species || !mob_species.has_organ || !(organ_tag in mob_species.has_organ))
				return FALSE
			var/list/meta = get_mutant_category_meta(organ_tag)
			var/new_size = text2num("[value]")
			if(isnull(new_size))
				return FALSE
			new_size = clamp(round(new_size), meta["size_min"], meta["size_max"])
			if(!islist(mutant_organs[organ_tag]))
				mutant_organs[organ_tag] = list("style" = null, "colors" = list("", "", ""), "enabled" = FALSE, "size" = new_size)
			else
				var/list/cat_entry = mutant_organs[organ_tag]
				cat_entry["size"] = new_size
			preview_icon = null
			return TRUE

		if("p_sheath")
			if(!(value in get_p_sheath_choices(mob_species)))
				return FALSE
			if(!islist(mutant_organs[BP_PENIS]))
				mutant_organs[BP_PENIS] = list("style" = null, "colors" = list("", "", ""), "enabled" = FALSE, "sheath_mode" = value)
			else
				var/list/cat_entry = mutant_organs[BP_PENIS]
				cat_entry["sheath_mode"] = value
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

		if("master_erp_preferences")
			if(config.disable_erp_preferences)
				return FALSE
			var/was_enabled = master_erp_preferences
			master_erp_preferences = !!value
			if(master_erp_preferences && !was_enabled)
				auto_assign_default_genitals()
			preview_icon = null
			return TRUE

		if("allow_noncanon_bodyparts")
			allow_noncanon_bodyparts = !!value
			preview_icon = null
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

	// Descriptor keys: "bs12_desc_<entry>" (entry sanitized for TGUI via tgui_descriptor_key() - reverse it)
	if(length(pref_name) > 9 && copytext(pref_name, 1, 10) == "bs12_desc_")
		var/entry_key = copytext(pref_name, 10)
		if(!(mob_species && mob_species.descriptors && mob_species.descriptors[entry_key]))
			entry_key = replacetext(entry_key, "_", " ") // fall back to the space-containing original name
		if(mob_species && mob_species.descriptors && mob_species.descriptors[entry_key])
			var/datum/mob_descriptor/descriptor = mob_species.descriptors[entry_key]
			var/new_index = descriptor.chargen_value_descriptors["[value]"]
			if(!isnull(new_index))
				if(!istype(body_descriptors))
					body_descriptors = list()
				body_descriptors[entry_key] = clamp(round(new_index), 1, LAZYLEN(descriptor.standalone_value_descriptors))
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

// Mutant-organ colors go through set_tgui_tricolor_preference() (below) instead, one for each of 3 independent
// primary/secondary/tertiary slots per category -- mirrors Bubberstation's tri_color prefs (see
// FeatureTriColorInput's set_tricolor_preference action, and the research this was built from).
/datum/preferences/proc/set_tgui_tricolor_preference(pref_name, index, singleton/species/mob_species, mob/user)
	if(!(index in list(1, 2, 3)))
		return FALSE
	var/organ_tag = get_organ_tag_for_color_key(pref_name)
	if(!organ_tag || !mob_species || !mob_species.has_organ || !(organ_tag in mob_species.has_organ))
		return FALSE
	var/list/meta = get_mutant_category_meta(organ_tag)
	if(!islist(mutant_organs[organ_tag]))
		mutant_organs[organ_tag] = list("style" = null, "colors" = list("", "", ""))
	var/list/cat_entry = mutant_organs[organ_tag]
	if(!islist(cat_entry["colors"]))
		cat_entry["colors"] = list("", "", "")
	var/fallback_color = get_mutant_fallback_color(meta, mob_species)
	var/current = cat_entry["colors"][index] || fallback_color
	var/list/SLOT_NAMES = list("primary", "secondary", "tertiary")
	var/new_color = input(user, "Choose [meta["display_name"]] [SLOT_NAMES[index]] color:", "[meta["display_name"]] Color", current) as color|null
	if(new_color)
		cat_entry["colors"][index] = new_color
	preview_icon = null
	return TRUE

// Breasts/Testicles only (Match Skin Tone button, FeatureTriColorInputWithSkinReset) -- writes the character's
// actual skin color into all 3 color slots. NOT the same as blanking them: for every ERP category,
// get_mutant_fallback_color() resolves a blank slot to the species' own default_genital_color first (the canon
// per-species tint, e.g. Human/Anthro's dull red) and only falls back to skin_color when a species has none set
// (Teshari) -- so merely clearing the slots would silently re-apply that species tint instead of the skin match
// this button promises. Writing the resolved color explicitly bypasses that fallback chain entirely.
/datum/preferences/proc/reset_tgui_organ_color_to_skin(pref_name, singleton/species/mob_species)
	var/organ_tag = get_organ_tag_for_color_key(pref_name)
	if(!organ_tag || !mob_species || !mob_species.has_organ || !(organ_tag in mob_species.has_organ))
		return FALSE
	if(!islist(mutant_organs[organ_tag]))
		mutant_organs[organ_tag] = list("style" = null, "colors" = list("", "", ""), "enabled" = FALSE)
	var/list/cat_entry = mutant_organs[organ_tag]
	var/matched_color = get_player_skin_color(mob_species)
	// Breasts/Testicles art (the only two categories this button exists for) is a greyscale MASK, tinted via
	// ICON_MULTIPLY (build_colored_icon(), _accessory_mutant.dm) -- result = mask_pixel * chosen_color / 255. The
	// mask isn't pure white (measured ~215/255 average for the source art here), so even a perfectly-sampled skin
	// color still rendered visibly darker/muddier than the actual skin -- confirmed the real bug behind "still
	// isn't properly matching" after the sampling fix alone. Pre-compensate by the mask's own average brightness
	// for the SPECIFIC style/size currently selected, so the post-multiply result is what actually lands on the
	// sampled color instead of a darkened version of it.
	var/style_name = cat_entry["style"]
	var/list/style_list = mob_species.get_mutant_styles(organ_tag, allow_noncanon_bodyparts)
	var/datum/sprite_accessory/mutant/style_datum = (islist(style_list) && style_name) ? style_list[style_name] : null
	if(style_datum && style_datum.mutant_blend == ICON_MULTIPLY)
		matched_color = scale_color_brightness(matched_color, get_mask_brightness_scale(style_datum, cat_entry["size"]))
	cat_entry["colors"] = list(matched_color, matched_color, matched_color)
	preview_icon = null
	return TRUE

// See reset_tgui_organ_color_to_skin() above -- the average brightness (0-255 scale) of a mutant-organ mask's
// actual pixels, across every non-transparent pixel of its SOUTH-facing, size-appropriate baked state. Returns 1
// (a no-op multiplier) if the mask can't be read or is fully transparent, rather than risk a divide-by-zero
// producing a wildly wrong color.
/datum/preferences/proc/get_mask_brightness_scale(datum/sprite_accessory/mutant/style_datum, size)
	if(!style_datum || !style_datum.icon)
		return 1
	var/base_state = "[style_datum.icon_state][size ? "[size]" : ""]_s"
	var/icon/mask = icon(style_datum.icon, base_state)
	var/w = mask.Width()
	var/h = mask.Height()
	if(!w || !h)
		return 1
	var/total = 0
	var/count = 0
	for(var/x = 0, x < w, x++)
		for(var/y = 0, y < h, y++)
			var/px = mask.GetPixel(x, y, base_state, SOUTH)
			if(!px)
				continue
			var/list/rgba = ReadRGB(px)
			if(!rgba || length(rgba) < 3)
				continue
			var/a = (length(rgba) >= 4) ? rgba[4] : 255
			if(a <= 10)
				continue
			total += (rgba[1] + rgba[2] + rgba[3]) / 3
			count++
	if(!count || total <= 0)
		return 1
	return 255 / (total / count)

// Multiplies a hex color's RGB channels by `scale`, clamped to 255. See reset_tgui_organ_color_to_skin() above.
/datum/preferences/proc/scale_color_brightness(color, scale)
	var/list/rgba = ReadRGB(color)
	if(!rgba || length(rgba) < 3)
		return color
	return rgb(min(255, round(rgba[1] * scale)), min(255, round(rgba[2] * scale)), min(255, round(rgba[3] * scale)))

// Humans (and any other SPECIES_APPEARANCE_HAS_A_SKIN_TONE species -- Human is the only one at the moment) don't
// have a freely-pickable skin_color at all -- they only pick a numeric skin_tone (a brightness offset, see
// apply_colouration() in _external_icons.dm), applied ON TOP of whatever base flesh color is already baked into
// their species' own torso_m/torso_f sprite. skin_color (this datum's own var) is meaningless for them -- it's
// left at its unrelated default and never touched by that species' own chargen UI. So for those species, sample
// the actual rendered center pixel of their torso sprite (base art + skin_tone applied) instead of trusting
// skin_color at all. Species with a real free-pick color (Anthro/GAS/IPC/...) keep using skin_color directly,
// same as before -- it already is what actually renders for them.
/datum/preferences/proc/get_player_skin_color(singleton/species/mob_species)
	if(mob_species && (mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR))
		return skin_color
	var/rendered = get_rendered_torso_center_color(mob_species)
	return rendered || skin_color

/datum/preferences/proc/get_rendered_torso_center_color(singleton/species/mob_species)
	if(!mob_species || !(mob_species.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE))
		return null
	var/gender_suffix = "_m"
	if(gender == FEMALE || (gender == PLURAL && trans_body_type == FEMALE))
		gender_suffix = "_f"
	var/chosen_icon_state = "torso[gender_suffix]"
	if(mob_species.base_skin_colours && !isnull(mob_species.base_skin_colours[base_skin]))
		chosen_icon_state += mob_species.base_skin_colours[base_skin]
	var/chosen_icon_file = mob_species.get_icobase(null)
	if(!chosen_icon_file)
		return null
	var/icon/sample = new(chosen_icon_file, chosen_icon_state)
	if(skin_tone)
		if(skin_tone >= 0)
			sample.Blend(rgb(skin_tone, skin_tone, skin_tone), ICON_ADD)
		else
			sample.Blend(rgb(-skin_tone, -skin_tone, -skin_tone), ICON_SUBTRACT)
	var/w = sample.Width()
	var/h = sample.Height()
	if(!w || !h)
		return null
	var/px = sample.GetPixel(round(w / 2), round(h / 2), chosen_icon_state, SOUTH)
	if(!px)
		return null
	var/list/rgba = ReadRGB(px)
	if(!rgba || length(rgba) < 3)
		return null
	return rgb(rgba[1], rgba[2], rgba[3])

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

// Clears any mutant_organs[tag]["style"] that isn't valid for the (just-switched-to) current species -- called
// alongside tgui_sanitize_organs() on species change, same spot hair/facial hair already get re-picked. Without
// this, a style choice like "Vox Primalis Tail" survives a switch to Teshari in the saved preference data
// untouched (mutant_organs is never otherwise cleared on species change), so the TGUI picker keeps showing it as
// selected even though it's meaningless for the new species. copy_to() (preferences.dm) independently guards
// against this same stale data ever actually rendering, but that's a render-time safety net, not a substitute for
// cleaning up the stored choice itself.
/datum/preferences/proc/tgui_sanitize_mutant_organs()
	var/singleton/species/mob_species = GLOB.species_by_name[species]
	if(!mob_species || !islist(mutant_organs))
		return
	for(var/organ_tag in get_all_mutant_organ_tags())
		var/list/choice = mutant_organs[organ_tag]
		if(!islist(choice))
			continue
		// P. Sheath's third choice is per-species-named ("Slit", or e.g. Teshari's "Cloaca") -- a value left over
		// from the PREVIOUS species (any non-"None"/"Sheath" value, since those two are species-independent)
		// needs remapping to the new species' own name for the same underlying concept, not just clearing to
		// "None" -- e.g. switching to Teshari with "Slit" set should land on "Cloaca", matching what the dropdown
		// itself would show, not silently revert.
		if(organ_tag == BP_PENIS && choice["sheath_mode"] && choice["sheath_mode"] != "None")
			var/list/valid_sheath_choices = get_p_sheath_choices(mob_species)
			if(!(choice["sheath_mode"] in valid_sheath_choices))
				choice["sheath_mode"] = (choice["sheath_mode"] == "Sheath") ? "None" : valid_sheath_choices[length(valid_sheath_choices)]
		// Genital colors reset to blank on every species switch (not just when the style itself became invalid)
		// so the species-appropriate fallback (default_genital_color, or skin tone) takes over automatically --
		// explicit user direction, e.g. a Kharmaan's yellow shouldn't carry over onto a Human picked afterward.
		if(get_mutant_category_meta(organ_tag)["is_erp"] && islist(choice["colors"]))
			choice["colors"] = list("", "", "")
		if(!choice["style"])
			continue
		var/list/style_list = mob_species.get_mutant_styles(organ_tag, allow_noncanon_bodyparts)
		if(islist(style_list) && style_list[choice["style"]])
			continue // still a valid style for the new species -- leave it alone
		choice["style"] = null // invalid for the new species -- copy_to() re-resolves mandatory organs to their own default

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
		// icon_state "bald" (Bald hair) deliberately sends no icon -- same suppression as the main grid's
		// hair_icons/facial_icons build, so the frontend's red-X fallback shows here too.
		if(H && H.icon && H.icon_state != "bald")
			var/state = H.preview_state ? H.preview_state : "[H.icon_state]_s"
			var/ico = tgui_cache_icon("hair:[head_hair_style]", H.icon, state)
			result["hair"] = tgui_send_icon(tgui_rsc_name("hair", head_hair_style), ico)

	// Facial hair
	if(facial_hair_style)
		var/datum/sprite_accessory/FH = GLOB.facial_hair_styles_list[facial_hair_style]
		if(FH && FH.icon && FH.icon_state != "bald")
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

// The character-setup language item owns the culture/whitelist gating rules (rebuild_language_cache,
// is_allowed_language, free_languages). The TGUI backend used to ignore all of it and offer every language in the
// game, which meant illegal picks were accepted here and then silently deleted at spawn by sanitize_alt_languages().
// Reaching for the real item keeps one set of rules rather than a second, more permissive copy.
/datum/preferences/proc/get_language_setup_item()
	if(!player_setup)
		return null
	for(var/datum/category_group/player_setup_category/PS in player_setup.categories)
		for(var/datum/category_item/player_setup_item/background/languages/item in PS.items)
			return item
	return null

/// Sends the flag badge for a language to the client, returning the RSC name the UI references it by.
/datum/preferences/proc/tgui_language_flag(datum/language/L)
	if(!L || !L.tag_icon)
		return null
	var/ico = tgui_cache_icon("langflag:[L.tag_icon]", 'icons/language_tags.dmi', L.tag_icon)
	return tgui_send_icon(tgui_rsc_name("langflag", L.tag_icon), ico)

/// One language's wire payload. `level` of LANGUAGE_LEVEL_NONE means "offered but not known".
/datum/preferences/proc/build_tgui_language(datum/language/L, level = LANGUAGE_LEVEL_NONE, native = FALSE)
	return list(list(
		"name" = L.name,
		"description" = (L.desc ? L.desc : "No description available."),
		"icon" = tgui_language_flag(L),
		"group" = L.language_group,
		"variant_name" = (L.variant_name ? L.variant_name : L.name),
		"shorthand" = L.shorthand,
		"level" = level,
		"level_name" = language_level_name(level),
		"native" = native,
		"warning" = L.warning,
		"speaking" = level >= LANGUAGE_LEVEL_B1
	))

/datum/preferences/proc/build_tgui_selected_languages()
	var/list/result = list()
	if(!islist(alternate_languages))
		return result
	for(var/lang_name in alternate_languages)
		var/datum/language/L = all_languages[lang_name]
		if(!L)
			continue
		result += build_tgui_language(L, alternate_languages[lang_name])
	return result

/// The proficiency ladder, sent once so the UI does not have to hardcode the scale or its descriptions.
/datum/preferences/proc/build_tgui_language_levels()
	var/list/result = list()
	for(var/level = LANGUAGE_LEVEL_MIN to LANGUAGE_LEVEL_MAX)
		result += list(list(
			"value" = level,
			"name" = language_level_name(level),
			"description" = language_level_desc(level)
		))
	return result

/// Culture-granted languages. Always native, never counted against MAX_LANGUAGES, and not editable here.
/datum/preferences/proc/build_tgui_native_languages()
	var/list/result = list()
	var/datum/category_item/player_setup_item/background/languages/item = get_language_setup_item()
	if(!item)
		return result
	item.refresh_language_cache()
	for(var/lang_name in item.free_languages)
		var/datum/language/L = all_languages[lang_name]
		if(!L || L.is_abstract())
			continue
		result += build_tgui_language(L, LANGUAGE_LEVEL_C2, native = TRUE)
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
	var/datum/category_item/player_setup_item/background/languages/item = get_language_setup_item()
	if(!item)
		return result

	item.refresh_language_cache()
	var/mob/user = item.preference_mob()

	for(var/lang_name in all_languages)
		var/datum/language/L = all_languages[lang_name]
		if(!L)
			continue
		// Abstract group roots ("English", /datum/language/human's proto-sapien) are inheritance scaffolding, not
		// languages anyone speaks -- only the concrete variants beneath them are offered.
		if(L.is_abstract())
			continue
		if(L.flags & RESTRICTED)
			continue
		if(islist(alternate_languages) && (lang_name in alternate_languages))
			continue
		// Culture already grants this one natively; it belongs in the native section, not the learnable list.
		if(item.free_languages[lang_name])
			continue
		if(!item.is_allowed_language(user, L))
			continue
		result += build_tgui_language(L)
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
	for(var/bp_path in bp_map)
		var/singleton/backpack_outfit/bo = bp_map[bp_path]
		if(bo.path)
			var/bp_icon_file = initial(bo.path:icon)
			if(bp_icon_file)
				var/ico = tgui_cache_icon("bp:[bo.path]", bp_icon_file, initial(bo.path:icon_state))
				tgui_send_icon(tgui_rsc_name("bp", bo.name), ico)
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
