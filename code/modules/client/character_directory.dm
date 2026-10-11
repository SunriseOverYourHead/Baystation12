// A global, shared TGUI panel listing every currently-connected, currently-alive player character -- opened via
// the "Character Directory" OOC verb (character_setup()'s neighbour, client_procs.dm). "View" on any row opens
// that character's own /datum/examine_panel (examine_panel.dm) -- the same instance a self-examine would reach.
// Column set / Controls section / erpTagColor row coloring match Bubberstation's own
// modular_zubbers/code/modules/client/verbs/character_directory.dm + ZubbersCharacterDirectory.jsx as closely as
// this codebase's mob-var-based (not dna.features-based) data model allows.
GLOBAL_TYPED_NEW(character_directory, /datum/character_directory)

/datum/character_directory/ui_state(mob/user)
	return GLOB.tgui_always_state

/datum/character_directory/ui_interact(mob/user, datum/tgui/ui)
	var/mob/living/carbon/human/H = ishuman(user) ? user : null
	if(!H || !H.master_erp_preferences)
		to_chat(user, SPAN_WARNING("You need to enable Sexual Content in your character preferences to view the Character Directory."))
		return
	ui = tgui_interact(user, src, "CharacterDirectory", "Character Directory", ui)

/datum/character_directory/ui_data(mob/user)
	return list(
		"roster" = build_roster(),
		"controls" = build_controls(user),
	)

// The viewer's OWN preferences, displayed read-only at the top of the directory (Bubberstation's "Controls"
// section) -- editing happens in the normal Preferences Menu, not here.
/datum/character_directory/proc/build_controls(mob/user)
	if(!ishuman(user))
		return list()
	var/mob/living/carbon/human/H = user
	var/erp_unlocked = !config.disable_erp_preferences && H.master_erp_preferences
	return list(
		"show_in_directory" = H.show_in_directory,
		"attraction" = H.attraction,
		"display_gender" = H.display_gender,
		"erp_status" = erp_unlocked ? H.erp_status : "Unset",
		"erp_status_v" = erp_unlocked ? H.erp_status_v : "Unset",
		"erp_status_hypno" = erp_unlocked ? H.erp_status_hypno : "Unset",
		"erp_status_nc" = erp_unlocked ? H.erp_status_nc : "Unset",
	)

// "Currently alive" is read as currently-connected + not dead -- deliberately excludes SSD/logged-off bodies,
// matching who()'s (code/game/verbs/who.dm) framing of "current players" rather than every body in play.
/datum/character_directory/proc/build_roster()
	var/list/roster = list()
	for(var/mob/living/carbon/human/H in GLOB.human_mobs)
		if(!H.client)
			continue
		if(H.is_real_dead())
			continue
		if(!H.show_in_directory)
			continue
		// ERP tag columns show "Unset" rather than leaking a default "No" if the character has ERP off entirely --
		// same three-way privacy gate (config flag + master switch) used everywhere else this session.
		var/erp_unlocked = !config.disable_erp_preferences && H.master_erp_preferences
		roster += list(list(
			"ref" = "\ref[H]",
			"name" = H.real_name,
			"species" = H.species?.name,
			"attraction" = H.attraction,
			"display_gender" = H.display_gender,
			"erp_status" = erp_unlocked ? H.erp_status : "Unset",
			"erp_status_v" = erp_unlocked ? H.erp_status_v : "Unset",
			"erp_status_hypno" = erp_unlocked ? H.erp_status_hypno : "Unset",
			"erp_status_nc" = erp_unlocked ? H.erp_status_nc : "Unset",
		))
	return roster

/datum/character_directory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("view")
			var/mob/living/carbon/human/H = locate(params["ref"])
			if(!istype(H))
				return FALSE
			H.get_examine_panel().ui_interact(ui.user)
			return TRUE

		// ui_data() already recomputes the roster fresh on every poll -- no server-side caching to invalidate --
		// so this is just a client-requested redraw, matching Bubberstation's own cooldown-gated refresh button
		// in spirit (that one exists because ITS roster is cached in ui_static_data; TRUE here is enough to make
		// TGUI re-fetch ui_data()).
		if("refresh")
			return TRUE
