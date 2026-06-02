/**
 * tgui subsystem
 *
 * Manages all open tgui UIs and drives their update cycle.
 */

SUBSYSTEM_DEF(tgui)
	name = "tgui"
	wait = 9
	flags = SS_NO_INIT | SS_BACKGROUND
	priority = SS_PRIORITY_NANO + 1
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	/// UIs scheduled to process this fire
	var/list/current_run = list()
	/// All open UIs
	var/list/all_uis = list()
	/// The base HTML used for all tgui windows
	var/basehtml

/datum/controller/subsystem/tgui/PreInit()
	basehtml = file2text('tgui/public/tgui.html')

	// Inject inline helpers
	var/helpers = file2text('tgui/public/helpers.min.js')
	helpers = "<script type='text/javascript'>\n[helpers]\n</script>"
	basehtml = replacetextEx(basehtml, "<!-- tgui:helpers -->", helpers)

	// Inject ntos-error styles
	var/ntos_error = file2text('tgui/public/ntos-error.min.css')
	ntos_error = "<style type='text/css'>\n[ntos_error]\n</style>"
	basehtml = replacetextEx(basehtml, "<!-- tgui:ntos-error -->", ntos_error)

	// Inject the storagecdn placeholder with an empty string (no CDN in Baystation)
	basehtml = replacetextEx(basehtml, "\[tgui:storagecdn]", "")

	// Update copyright line
	basehtml = replacetextEx(basehtml, "<!-- tgui:nt-copyright -->", "NanoTrasen (c) 2525")

/datum/controller/subsystem/tgui/Shutdown()
	close_all_uis()


/datum/controller/subsystem/tgui/fire(resumed = FALSE)
	if(!resumed)
		src.current_run = all_uis.Copy()
	var/list/current_run = src.current_run
	while(current_run.len)
		var/datum/tgui/ui = current_run[current_run.len]
		current_run.len--
		if(ui?.user && ui.src_object)
			ui.process(wait * 0.1)
		else
			ui.close(FALSE)
		if(MC_TICK_CHECK)
			return

/**
 * Request a usable tgui window from the pool.
 * Returns null if the pool was exhausted.
 */
/datum/controller/subsystem/tgui/proc/request_pooled_window(mob/user)
	if(!user.client)
		return null
	var/list/windows = user.client.tgui_windows
	var/window_id
	var/datum/tgui_window/window
	var/window_found = FALSE
	for(var/i in 1 to TGUI_WINDOW_HARD_LIMIT)
		window_id = TGUI_WINDOW_ID(i)
		window = windows[window_id]
		if(!window)
			window = new(user.client, window_id, pooled = TRUE)
		if(window.locked)
			continue
		if(window.status == TGUI_WINDOW_READY)
			return window
		if(window.status == TGUI_WINDOW_CLOSED)
			window.status = TGUI_WINDOW_LOADING
			window_found = TRUE
			break
	if(!window_found)
		log_game("tgui: Pool exhausted for [user.client.ckey]")
		return null
	return window

/**
 * Force-close all tgui windows for a user.
 */
/datum/controller/subsystem/tgui/proc/force_close_all_windows(mob/user)
	if(user.client)
		user.client.tgui_windows = list()
		for(var/i in 1 to TGUI_WINDOW_HARD_LIMIT)
			var/window_id = TGUI_WINDOW_ID(i)
			user << browse(null, "window=[window_id]")

/**
 * Force-close a specific tgui window by id.
 */
/datum/controller/subsystem/tgui/proc/force_close_window(mob/user, window_id)
	for(var/datum/tgui/ui in user.tgui_open_uis)
		if(ui.window && ui.window.id == window_id)
			ui.close(can_be_suspended = FALSE)
	user << browse(null, "window=[window_id]")

/**
 * Try to update an existing UI, or return null if none was found.
 */
/datum/controller/subsystem/tgui/proc/try_update_ui(mob/user, datum/src_object, datum/tgui/ui)
	if(isnull(ui))
		ui = get_open_ui(user, src_object)
	if(isnull(ui))
		return null
	ui.process_status()
	if(ui.status <= UI_CLOSE)
		ui.close()
		return null
	ui.send_update()
	return ui

/**
 * Get an open UI for a given user + src_object pair.
 */
/datum/controller/subsystem/tgui/proc/get_open_ui(mob/user, datum/src_object)
	if(!LAZYLEN(src_object?.open_uis))
		return null
	for(var/datum/tgui/ui in src_object.open_uis)
		if(ui.user == user)
			return ui
	return null

/**
 * Update all UIs attached to src_object.
 */
/datum/controller/subsystem/tgui/proc/update_uis(datum/src_object)
	if(!LAZYLEN(src_object?.open_uis))
		return 0
	var/count = 0
	for(var/datum/tgui/ui in src_object.open_uis)
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			spawn(0)
				ui.process(wait * 0.1, TRUE)
			count++
	return count

/**
 * Close all UIs attached to src_object.
 */
/datum/controller/subsystem/tgui/proc/close_uis(datum/src_object)
	if(!LAZYLEN(src_object?.open_uis))
		return 0
	var/count = 0
	for(var/datum/tgui/ui in src_object.open_uis)
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.close()
			count++
	return count

/**
 * Close all UIs regardless of src_object.
 */
/datum/controller/subsystem/tgui/proc/close_all_uis()
	var/count = 0
	for(var/datum/tgui/ui in all_uis)
		if(ui?.src_object && ui.user && ui.src_object.ui_host(ui.user))
			ui.close()
			count++
	return count

/**
 * Update all UIs belonging to a user.
 */
/datum/controller/subsystem/tgui/proc/update_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.tgui_open_uis) == 0)
		return count
	for(var/datum/tgui/ui in user.tgui_open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.process(wait * 0.1, force = TRUE)
			count++
	return count

/**
 * Close all UIs belonging to a user.
 */
/datum/controller/subsystem/tgui/proc/close_user_uis(mob/user, datum/src_object)
	var/count = 0
	if(length(user?.tgui_open_uis) == 0)
		return count
	for(var/datum/tgui/ui in user.tgui_open_uis)
		if(isnull(src_object) || ui.src_object == src_object)
			ui.close()
			count++
	return count

// Called when a UI opens
/datum/controller/subsystem/tgui/proc/on_open(datum/tgui/ui)
	ui.user?.tgui_open_uis |= ui
	LAZYDISTINCTADD(ui.src_object.open_uis, ui)
	all_uis |= ui

// Called when a UI closes
/datum/controller/subsystem/tgui/proc/on_close(datum/tgui/ui)
	all_uis -= ui
	current_run -= ui
	if(ui.user)
		ui.user.tgui_open_uis -= ui
	if(ui.src_object)
		LAZYREMOVE(ui.src_object.open_uis, ui)
	return TRUE

// Called on client logout
/datum/controller/subsystem/tgui/proc/on_logout(mob/user)
	close_user_uis(user)

// Called when a player transfers mobs
/datum/controller/subsystem/tgui/proc/on_transfer(mob/source, mob/target)
	if(length(source?.tgui_open_uis) == 0)
		return FALSE
	if(isnull(target.tgui_open_uis) || !istype(target.tgui_open_uis, /list))
		target.tgui_open_uis = list()
	for(var/datum/tgui/ui in source.tgui_open_uis)
		ui.user = target
		target.tgui_open_uis += ui
	source.tgui_open_uis.Cut()
	return TRUE
