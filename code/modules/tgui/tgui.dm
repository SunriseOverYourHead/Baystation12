/**
 * /datum/tgui — represents a single open tgui UI instance.
 */
/datum/tgui
	/// The mob using this UI
	var/mob/user
	/// The object/datum that owns this UI
	var/datum/src_object
	/// The UI title
	var/title
	/// The tgui_window this UI is displayed in
	var/datum/tgui_window/window
	/// Key for remembering window geometry
	var/window_key
	/// Deprecated: window size list
	var/window_size
	/// Interface name (maps to a React component)
	var/interface
	/// Whether to auto-update every MC tick
	var/autoupdate = TRUE
	/// Whether the window has finished its initial handshake
	var/initialized = FALSE
	/// Time this UI was opened
	var/opened_at
	/// Set to TRUE once close() has been called to prevent double-closes
	var/closing = FALSE
	/// Current status/visibility
	var/status = UI_INTERACTIVE
	/// Whether a deferred full update is pending
	var/refreshing = FALSE
	/// The ui_state controlling access
	var/datum/ui_state/state = null
	/// World time of the last full update, for rate-limiting
	var/last_update_time = 0

/**
 * Create a new tgui datum.
 *
 * required user mob
 * required src_object datum
 * required interface string  Name of the React component to render.
 * optional title string
 */
/datum/tgui/New(mob/user, datum/src_object, interface, title, ui_x, ui_y)
	src.user = user
	src.src_object = src_object
	src.window_key = "\ref[src_object]-main"
	src.interface = interface
	if(title)
		src.title = title
	src.state = src_object.ui_state(user)
	if(ui_x && ui_y)
		src.window_size = list(ui_x, ui_y)

/datum/tgui/Destroy()
	user = null
	src_object = null
	return ..()

/**
 * Open this UI (request a window, send initial data).
 * Returns TRUE if a new window was opened.
 */
/datum/tgui/proc/open()
	if(!user.client)
		return FALSE
	if(window)
		return FALSE
	process_status()
	if(status < UI_UPDATE)
		return FALSE
	window = SStgui.request_pooled_window(user)
	if(!window)
		return FALSE
	opened_at = world.time
	window.acquire_lock(src)
	// Send the JS/CSS bundle before we open the window so the browser
	// has the files in its resource cache when it processes the HTML.
	send_assets()
	if(!window.is_ready())
		window.initialize(strict_mode = TRUE)
	else
		window.send_message("ping")
	window.send_message("update", get_payload(
		with_data = TRUE,
		with_static_data = TRUE))
	SStgui.on_open(src)
	return TRUE

/**
 * Send the tgui JS/CSS bundle to the client.
 */
/datum/tgui/proc/send_assets()
	var/datum/asset/simple/tgui_assets = get_asset_datum(/datum/asset/simple/tgui)
	tgui_assets.send(user.client)

/**
 * Close this UI.
 */
/datum/tgui/proc/close(can_be_suspended = TRUE)
	if(closing)
		return
	closing = TRUE
	if(window)
		window.release_lock()
		window.close(can_be_suspended)
		src_object.ui_close(user)
		SStgui.on_close(src)
	state = null
	qdel(src)

/**
 * Enable or disable auto-updating.
 */
/datum/tgui/proc/set_autoupdate(autoupdate)
	src.autoupdate = autoupdate

/**
 * Replace the current ui_state.
 */
/datum/tgui/proc/set_state(datum/ui_state/state)
	src.state = state

/**
 * Send a full update (includes static_data). Rate-limited.
 */
/datum/tgui/proc/send_full_update(custom_data, force, always_instant)
	if(!user.client || !initialized || closing)
		return
	// Rate-limit to prevent DoS
	if(!always_instant && world.time - last_update_time < TGUI_REFRESH_FULL_UPDATE_COOLDOWN)
		if(!refreshing)
			refreshing = TRUE
			var/time_left = TGUI_REFRESH_FULL_UPDATE_COOLDOWN - (world.time - last_update_time)
			spawn(time_left)
				if(!closing)
					refreshing = FALSE
					send_full_update(custom_data, force)
		return
	refreshing = FALSE
	last_update_time = world.time
	var/should_update_data = force || status >= UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data,
		with_static_data = TRUE))

/**
 * Send a partial update (excludes static_data).
 */
/datum/tgui/proc/send_update(custom_data, force)
	if(!user.client || !initialized || closing)
		return
	var/should_update_data = force || status >= UI_UPDATE
	window.send_message("update", get_payload(
		custom_data,
		with_data = should_update_data))

/**
 * Build the JSON payload to send to the browser.
 */
/datum/tgui/proc/get_payload(custom_data, with_data, with_static_data)
	var/list/json_data = list()
	json_data["config"] = list(
		"title" = title,
		"status" = status,
		"interface" = list(
			"name" = interface,
			"layout" = "default",
		),
		"refreshing" = refreshing,
		"window" = list(
			"key" = window_key,
			"size" = window_size,
			"locked" = FALSE,
			"scale" = FALSE,
		),
		"client" = list(
			"ckey" = user.client?.ckey,
			"address" = user.client?.address,
			"computer_id" = user.client?.computer_id,
		),
		"user" = list(
			"name" = "[user]",
			"observer" = isobserver(user),
		),
	)
	var/data = custom_data || with_data && src_object.ui_data(user)
	if(data)
		json_data["data"] = data
	var/static_data = with_static_data && src_object.ui_static_data(user)
	if(static_data)
		json_data["static_data"] = static_data
	if(src_object.tgui_shared_states)
		json_data["shared"] = src_object.tgui_shared_states
	return json_data

/**
 * Per-tick update cycle, called by SStgui.
 */
/datum/tgui/proc/process(seconds_per_tick, force = FALSE)
	if(closing)
		return
	var/datum/host = src_object.ui_host(user)
	if(QDELETED(src_object) || QDELETED(host) || QDELETED(user) || QDELETED(window))
		close(can_be_suspended = FALSE)
		return
	// Zombie window detection
	if(!initialized && world.time - opened_at > TGUI_PING_TIMEOUT)
		log_game("tgui: Zombie window detected for [user], closing.")
		close(can_be_suspended = FALSE)
		return
	if(status != UI_DISABLED && (autoupdate || force))
		src_object.ui_interact(user, src)
		return
	var/needs_update = process_status()
	if(status <= UI_CLOSE)
		close()
		return
	if(needs_update)
		window.send_message("update", get_payload())

/**
 * Recompute status from the ui_state. Returns TRUE if status changed.
 */
/datum/tgui/proc/process_status()
	var/prev_status = status
	status = src_object.ui_status(user, state)
	return prev_status != status

/**
 * Handle an incoming message from the browser.
 */
/datum/tgui/proc/on_message(type, list/payload, list/href_list)
	if(type && copytext(type, 1, 5) == "act/")
		var/act_type = copytext(type, 5)
		process_status()
		// Run ui_act asynchronously to avoid blocking the topic handler
		spawn(0)
			on_act_message(act_type, payload, state)
		return FALSE
	switch(type)
		if("ready")
			if(initialized)
				send_full_update()
			initialized = TRUE
		if("ping/reply")
			initialized = TRUE
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
		if("log")
			if(href_list["fatal"])
				close(can_be_suspended = FALSE)
		if("setSharedState")
			if(status != UI_INTERACTIVE)
				return
			LAZYINITLIST(src_object.tgui_shared_states)
			src_object.tgui_shared_states[href_list["key"]] = href_list["value"]
			SStgui.update_uis(src_object)

/datum/tgui/proc/on_act_message(act_type, payload, state)
	if(QDELETED(src) || QDELETED(src_object))
		return
	if(src_object.ui_act(act_type, payload, src, state))
		SStgui.update_uis(src_object)
