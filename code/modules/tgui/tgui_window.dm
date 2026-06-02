/**
 * /datum/tgui_window — represents a browser window used to render tgui.
 * Windows are pooled and reused across UIs.
 */
/datum/tgui_window
	var/id
	var/client/client
	var/pooled
	var/pool_index
	var/is_browser = FALSE
	var/status = TGUI_WINDOW_CLOSED
	var/locked = FALSE
	var/visible = FALSE
	var/datum/tgui/locked_by
	var/datum/subscriber_object
	var/subscriber_delegate
	var/fatally_errored = FALSE
	var/list/message_queue
	// Saved init args for reinitialize()
	var/initial_strict_mode
	var/initial_inline_html
	var/initial_inline_js
	var/initial_inline_css

/datum/tgui_window/New(client/client, id, pooled = FALSE)
	src.id = id
	src.client = client
	src.client.tgui_windows[id] = src
	src.pooled = pooled
	if(pooled)
		src.pool_index = TGUI_WINDOW_INDEX(id)

/**
 * Open (or re-open) the browser window with the tgui HTML.
 */
/datum/tgui_window/proc/initialize(
		strict_mode = FALSE,
		inline_html = "",
		inline_js = "",
		inline_css = "")
	if(!client)
		return
	src.initial_strict_mode = strict_mode
	src.initial_inline_html = inline_html
	src.initial_inline_js = inline_js
	src.initial_inline_css = inline_css
	status = TGUI_WINDOW_LOADING
	fatally_errored = FALSE

	var/options = "file=[id].html;can_minimize=0;auto_format=0;titlebar=0;can_resize=0;"

	// Build the HTML from the cached base template
	var/html = SStgui.basehtml
	html = replacetextEx(html, "\[tgui:windowId]", id)
	html = replacetextEx(html, "\[tgui:strictMode]", strict_mode)

	// Inject tgui bundle assets using Byond.loadJs / Byond.loadCss
	// The files are sent separately via send_asset_list(); browsers access them by filename.
	var/asset_inject = "<script>\nByond.loadJs('tgui.bundle.js', true);\nByond.loadCss('tgui.bundle.css', true);\n</script>\n"
	html = replacetextEx(html, "<!-- tgui:assets -->", asset_inject)

	// Inject optional inline HTML
	if(inline_html)
		var/content = isfile(inline_html) ? file2text(inline_html) : inline_html
		html = replacetextEx(html, "<!-- tgui:inline-html -->", content)

	// Inject optional inline JS
	if(inline_js)
		var/content = isfile(inline_js) ? file2text(inline_js) : inline_js
		html = replacetextEx(html, "<!-- tgui:inline-js -->",
			"<script>\n'use strict';\n[content]\n</script>")

	// Inject optional inline CSS
	if(inline_css)
		var/content = isfile(inline_css) ? file2text(inline_css) : inline_css
		html = replacetextEx(html, "<!-- tgui:inline-css -->",
			"<style>\n[content]\n</style>")

	client << browse(html, "window=[id];[options]")
	is_browser = winexists(client, id) == "BROWSER"
	if(!is_browser)
		winset(client, id, "on-close=\"uiclose [id]\"")

/**
 * Reinitialize the window with its previously saved parameters.
 */
/datum/tgui_window/proc/reinitialize()
	initialize(
		strict_mode = initial_strict_mode,
		inline_html = initial_inline_html,
		inline_js = initial_inline_js,
		inline_css = initial_inline_css)

/datum/tgui_window/proc/is_ready()
	return status == TGUI_WINDOW_READY

/datum/tgui_window/proc/can_be_suspended()
	return !fatally_errored \
		&& pooled \
		&& pool_index > 0 \
		&& pool_index <= TGUI_WINDOW_SOFT_LIMIT \
		&& status == TGUI_WINDOW_READY

/**
 * Acquire the pool lock, preventing other UIs from reusing this window.
 */
/datum/tgui_window/proc/acquire_lock(datum/tgui/ui)
	locked = TRUE
	locked_by = ui

/**
 * Release the pool lock.
 */
/datum/tgui_window/proc/release_lock()
	locked = FALSE
	locked_by = null

/**
 * Subscribe a datum to receive messages from this window.
 */
/datum/tgui_window/proc/subscribe(datum/object, delegate)
	subscriber_object = object
	subscriber_delegate = delegate

/datum/tgui_window/proc/unsubscribe()
	subscriber_object = null
	subscriber_delegate = null

/**
 * Close (or suspend) this window.
 */
/datum/tgui_window/proc/close(can_be_suspended = TRUE)
	if(!client)
		return
	if(can_be_suspended && can_be_suspended())
		visible = FALSE
		status = TGUI_WINDOW_READY
		send_message("suspend")
		return
	release_lock()
	visible = FALSE
	status = TGUI_WINDOW_CLOSED
	message_queue = null
	if(!fatally_errored)
		client << browse(null, "window=[id]")

/**
 * Send a typed message to the tgui window.
 */
/datum/tgui_window/proc/send_message(type, payload, force)
	if(!client)
		return
	var/message = TGUI_CREATE_MESSAGE(type, payload)
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

/**
 * Send a pre-encoded message blob.
 */
/datum/tgui_window/proc/send_raw_message(message, force)
	if(!client)
		return
	if(!force && status != TGUI_WINDOW_READY)
		if(!message_queue)
			message_queue = list()
		message_queue += list(message)
		return
	client << output(message, is_browser \
		? "[id]:update" \
		: "[id].browser:update")

/**
 * Flush the message queue once the window is ready.
 */
/datum/tgui_window/proc/flush_message_queue()
	if(!client || !message_queue)
		return
	for(var/message in message_queue)
		client << output(message, is_browser \
			? "[id]:update" \
			: "[id].browser:update")
	message_queue = null

/**
 * Handle an incoming message from the browser.
 */
/datum/tgui_window/proc/on_message(type, payload, href_list)
	if(type == "ready" && status == TGUI_WINDOW_READY)
		// Client refreshed: re-send the bundle so it loads correctly
		var/datum/asset/simple/tgui_assets = get_asset_datum(/datum/asset/simple/tgui)
		tgui_assets.send(client)

	if(type == "log" && href_list["fatal"])
		fatally_errored = TRUE

	if(status != TGUI_WINDOW_READY)
		status = TGUI_WINDOW_READY
		flush_message_queue()

	if(locked && locked_by)
		var/prevent_default = locked_by.on_message(type, payload, href_list)
		if(prevent_default)
			return
	else if(subscriber_object)
		var/prevent_default = call(subscriber_object, subscriber_delegate)(type, payload, href_list)
		if(prevent_default)
			return

	switch(type)
		if("ping")
			send_message("ping/reply", payload)
		if("visible")
			visible = TRUE
		if("suspend")
			close(can_be_suspended = TRUE)
		if("close")
			close(can_be_suspended = FALSE)
		if("openLink")
			client << link(href_list["url"])
		if("cacheReloaded")
			reinitialize()
