/**
 * tgui external definitions — the src_object API that every tgui-backed object implements.
 *
 * Objects override ui_interact(), ui_data(), ui_act(), and ui_state() to power their UI.
 */

/**
 * Open or update this object's tgui UI for the given user.
 * Must be implemented for the UI to update correctly.
 *
 * ui is non-null when called from SStgui.process() (the existing open UI).
 * When ui is null, open a new UI using tgui_interact() (see below).
 */
/datum/proc/ui_interact(mob/user, datum/tgui/ui)
	return FALSE

/**
 * Return the live data to be sent to the interface on each update.
 */
/datum/proc/ui_data(mob/user)
	return list()

/**
 * Return data that changes rarely. Sent on open and on force-refresh only.
 */
/datum/proc/ui_static_data(mob/user)
	return list()

/**
 * Force a full refresh for a specific viewer.
 */
/datum/proc/update_static_data(mob/user, datum/tgui/ui, always_instant)
	if(!ui)
		ui = SStgui.get_open_ui(user, src)
	if(ui)
		ui.send_full_update(always_instant = always_instant)

/**
 * Force a full refresh for all viewers.
 */
/datum/proc/update_static_data_for_all_viewers()
	for(var/datum/tgui/ui as anything in open_uis)
		ui.send_full_update()

/**
 * Force a data-only refresh for all viewers.
 */
/datum/proc/update_data_for_all_viewers()
	for(var/datum/tgui/ui as anything in open_uis)
		ui.send_update()

/**
 * Handle a user action from the UI. Equivalent to Topic() for tgui.
 *
 * Return TRUE to trigger a UI update after the action.
 */
/datum/proc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	SHOULD_CALL_PARENT(TRUE)
	if(!ui || ui.status != UI_INTERACTIVE)
		return TRUE

/**
 * Return a list of datum/asset datums to send alongside the UI.
 */
/datum/proc/ui_assets(mob/user)
	return list()

/**
 * Return the host atom for this UI (usually src itself).
 * Override for datums that are sub-components of an object.
 */
/datum/proc/ui_host(mob/user)
	return src

/**
 * Return the ui_state datum that controls access to this UI.
 * Override to restrict who can see/use the interface.
 */
/datum/proc/ui_state(mob/user)
	return GLOB.tgui_default_state

/**
 * Called when the UI is closed.
 */
/datum/proc/ui_close(mob/user)
	return

/**
 * Global: associative list of shared state values set by tgui clients.
 */
/datum/var/list/tgui_shared_states

/**
 * Global: list of open UIs attached to this datum (populated by SStgui).
 */
/datum/var/list/open_uis

/**
 * Per-mob tracking of open tgui UIs.
 */
/mob/var/list/tgui_open_uis = list()

/**
 * Per-client tracking of open tgui windows.
 */
/client/var/list/tgui_windows = list()

/**
 * Verb called by the browser when a window is closed (via on-close winset).
 * Must be a verb so winset() can invoke it.
 */
/client/verb/uiclose(window_id as text)
	set name = "uiclose"
	set hidden = TRUE
	var/mob/user = src?.mob
	if(!user)
		return
	SStgui.force_close_window(user, window_id)

/**
 * Middleware for /client/Topic — handles all tgui message routing.
 * Call this from your client/Topic override before processing other hrefs.
 * Returns TRUE to prevent further Topic processing.
 */
/proc/tgui_Topic(href_list)
	if(!href_list["tgui"])
		return FALSE

	var/type = href_list["type"]

	if(type == "log")
		var/context = href_list["window_id"]
		log_game("tgui ([context]): [href_list["message"]]")

	var/window_id = href_list["window_id"]
	var/datum/tgui_window/window
	if(window_id)
		window = usr.client?.tgui_windows[window_id]
		if(!window)
			log_game("tgui: Couldn't find window datum '[window_id]', force closing.")
			SStgui.force_close_window(usr, window_id)
			return TRUE

	// Decode the JSON payload
	var/payload
	if(href_list["payload"])
		var/payload_text = href_list["payload"]
		payload = json_decode(payload_text)

	if(window)
		window.on_message(type, payload, href_list)
	return TRUE

/**
 * Helper proc — the standard pattern for opening a tgui UI.
 * Call this from ui_interact() on your object.
 *
 * Usage:
 *   /obj/machinery/myobj/ui_interact(mob/user, datum/tgui/ui)
 *       ui = tgui_interact(user, src, "MyInterface", "My Title", ui)
 *       ui.set_autoupdate(TRUE)
 *       ui.open()
 *
 * If ui is non-null (existing open UI), sends an update instead of opening fresh.
 */
/proc/tgui_interact(mob/user, datum/src_object, interface, title, datum/tgui/ui, ui_x, ui_y)
	ui = SStgui.try_update_ui(user, src_object, ui)
	if(!ui)
		ui = new /datum/tgui(user, src_object, interface, title, ui_x, ui_y)
		ui.open()
	return ui
