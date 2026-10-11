// TGUI backend for the pregame lobby screen. Replaces the old new_player_panel() browser popup (plain
// byond://-link HTML in a /datum/browser) with a single modern TGUI interface - a "landing hub" in the same
// spirit as CM13's LobbyMenu.tsx: full-bleed background art, a welcome card, and a round-state-aware action
// button stack, all in one place.
//
// Unlike a normal tgui interface, this one deliberately does NOT use a pooled floating window (which always
// renders with a draggable title bar - see tgui/packages/tgui/layouts/Window.tsx). CM13's own LobbyMenu
// achieves the "superimposed on the game view" look by targeting a permanent, pane-embedded BROWSER skin
// element that sits directly on top of the map view instead (interface/skin.dmf's "lobby_browser", inside
// their "mapwindow"); this codebase already has the exact same pre-existing element under the name
// "lobbybrowser" (interface/skin.dmf, same window block as "map", same anchor1=0,0/anchor2=100,100 - it's
// what the old GLOB.using_map.show_titlescreen()/hide_titlescreen() system used, see maps/mapsystem/maps.dm),
// so initialize_lobby_screen() below just re-targets that element with a real tgui_window instead of the
// static browse()'d HTML the old system pushed into it.
//
// Deliberately out of scope: character setup itself is untouched (already the PreferencesMenu TGUI interface,
// code/modules/client/preferences_tgui.dm - "Setup Character" just opens it, same as before), and so are the
// late-join job picker (LateChoices()) and crew manifest (ViewManifest()) in new_player.dm, which keep their
// existing popups for now - matching how CM13's own LobbyMenu only modernizes the entry hub and leaves deeper
// screens (its own character setup, its playtimes panel) as separate, older UI rather than rebuilding everything
// at once.

/// Claims the "lobbybrowser" pane (interface/skin.dmf) for this client and readies a tgui_window pointed at
/// it. Called once, early, from Login() - before ui_interact()/new_player_panel() ever run - so the window
/// datum already exists by the time anything tries to open a UI into it. Safe to call more than once (e.g.
/// the defensive fallback in ui_interact() below); re-initializing just reloads the same pane.
/mob/new_player/proc/initialize_lobby_screen()
	if(!client)
		return
	winset(client, "lobbybrowser", "is-disabled=false;is-visible=true")
	lobby_window = new /datum/tgui_window(client, "lobbybrowser")
	lobby_window.initialize(strict_mode = TRUE)

/mob/new_player/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!lobby_window)
			initialize_lobby_screen()
		ui = new /datum/tgui(user, src, "Lobby", "Lobby", window = lobby_window)
		ui.set_autoupdate(TRUE)
		ui.open(preinitialized = TRUE)

/mob/new_player/ui_state(mob/user)
	return GLOB.tgui_always_state

/mob/new_player/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/lobby))

/// Data that never changes for the life of this lobby session - the background image picked once at login
/// (matches the old system's one-random-pick-per-connect behaviour), and which optional buttons/links even
/// apply for this server's config.
/mob/new_player/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = GLOB.using_map.full_name
	// current_lobby_screen is a full DM file path (e.g. 'maps/torch/lobby/ship.gif') - /datum/asset/simple/lobby
	// (code/modules/client/asset_cache.dm) registers these under their bare filename instead, matching what
	// resolveAsset() looks up on the frontend, so only the last path segment is actually wanted here.
	var/list/path_parts = splittext(GLOB.using_map.current_lobby_screen, "/")
	data["background_image"] = length(path_parts) ? path_parts[length(path_parts)] : "default_lobby.png"
	data["has_wiki"] = !!config.wiki_url
	data["has_rules"] = !!config.rules_url
	data["has_lore"] = !!config.lore_url
	data["multi_character"] = config.maximum_queued_characters > 1
	return data

/mob/new_player/ui_data(mob/user)
	var/list/data = list()
	data["ready"] = ready
	data["round_started"] = (GAME_STATE > RUNLEVEL_LOBBY)
	// client can be momentarily null here (a stale UI refresh landing during the disconnect/new_player->mob handoff)
	data["character_name"] = client?.prefs?.real_name || "(Random)"
	data["character_job"] = client?.prefs?.job_high

	var/players = 0
	var/players_ready = 0
	for(var/mob/new_player/player in GLOB.player_list)
		if (!player.client || player.is_stealthed())
			continue
		players++
		if (player.ready)
			players_ready++
	data["player_count"] = players
	data["ready_count"] = players_ready
	data["time_to_start"] = (GAME_STATE <= RUNLEVEL_LOBBY) ? round(SSticker.pregame_timeleft / 10) : null

	return data

/mob/new_player/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("ready")
			ready = (GAME_STATE > RUNLEVEL_LOBBY) ? 0 : !ready
			return TRUE

		if("observe")
			become_observer()
			return TRUE

		if("late_join")
			if(GAME_STATE != RUNLEVEL_GAME)
				to_chat(src, SPAN_WARNING("The round has either not started yet or already ended."))
				return TRUE
			if (!client.holder)
				var/dsdiff = config.respawn_menu_delay MINUTES - (world.time - respawned_time)
				if (dsdiff > 0)
					to_chat(src, SPAN_WARNING("You must wait [time2text(dsdiff, "mm:ss")] before rejoining."))
					return TRUE
			LateChoices()
			return TRUE

		if("manifest")
			ViewManifest()
			return TRUE

		if("preferences")
			client.prefs.open_setup_window(src)
			return TRUE

		if("manage_characters")
			client.prefs.open_prefs_ordering_panel(src)
			return TRUE

		if("toggle_multi_character")
			if (config.maximum_queued_characters > 1)
				client.prefs.use_slot_priority_list = !client.prefs.use_slot_priority_list
				client.prefs.save_preferences()
				client.prefs.close_load_dialog()
			return TRUE

		if("wiki")
			if (config.wiki_url)
				send_link(src, config.wiki_url)
			return TRUE

		if("rules")
			if (config.rules_url)
				send_link(src, config.rules_url)
			return TRUE

		if("lore")
			if (config.lore_url)
				send_link(src, config.lore_url)
			return TRUE

		if("next_track")
			if(get_preference_value(/datum/client_preference/play_lobby_music) == GLOB.PREF_NO)
				return TRUE
			var/singleton/audio/track/track = GLOB.using_map.get_lobby_track(GLOB.using_map.lobby_track.type)
			sound_to(src, track.get_sound())
			to_chat(src, track.get_info())
			return TRUE
