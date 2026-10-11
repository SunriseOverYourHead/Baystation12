/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(client/client, asset_name, verify = TRUE, check_cache = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	if(check_cache && (client.cache.Find(asset_name) || client.sending.Find(asset_name)))
		return 0

	var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
	send_rsc(client, asset_cache.cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += asset_name
		return 1
	if (!client)
		return 0

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	show_browser(client, "<script>window.location.href=\"byond://?asset_cache_confirm_arrival=[job]\"</script>", "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * length(client.sending)) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(client/client, list/asset_list, verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !length(unreceived))
		return 0
	if (length(unreceived) >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending Resources...")
	var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
	for(var/asset in unreceived)
		if (asset in asset_cache.cache)
			send_rsc(client, asset_cache.cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += unreceived
		return 1
	if (!client)
		return 0
	client.sending |= unreceived
	var/job = ++client.last_asset_job

	show_browser(client, "<script>window.location.href=\"byond://?asset_cache_confirm_arrival=[job]\"</script>", "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * length(client.sending)
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(client/client, list/files, register_asset = TRUE)
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file,files[file])
		send_asset(client,file)
		sleep(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(asset_name, asset)
	var/singleton/asset_cache/asset_cache = GET_SINGLETON(/singleton/asset_cache)
	asset_cache.cache[asset_name] = asset

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(file)
	return "asset.[md5(fcopy_rsc(file))]"

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset/New()
	asset_datums[type] = src
	register()

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)

// For registering or sending multiple others at once
/datum/asset/group
	var/list/children

/datum/asset/group/register()
	for(var/type in children)
		get_asset_datum(type)

/datum/asset/group/send(client/C)
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		A.send(C)

//DEFINITIONS FOR ASSET DATUMS START HERE.
/datum/asset/nanoui
	var/list/common = list()

	var/list/common_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/js/"
	)
	var/list/uncommon_dirs = list(
		"nano/templates/"
	)

/datum/asset/nanoui/register()
	// Crawl the directories to find files.
	for (var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, -1) != "/") // Ignore directories.
				if(fexists(path + filename))
					common[filename] = fcopy_rsc(path + filename)
					register_asset(filename, common[filename])
	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, -1) != "/") // Ignore directories.
				if(fexists(path + filename))
					register_asset(filename, fcopy_rsc(path + filename))

	var/list/mapnames = list()
	for(var/z in GLOB.using_map.map_levels)
		mapnames += map_image_file_name(z)

	var/list/filenames = flist(MAP_IMAGE_PATH)
	for(var/filename in filenames)
		if(copytext(filename, -1) != "/") // Ignore directories.
			var/file_path = MAP_IMAGE_PATH + filename
			if((filename in mapnames) && fexists(file_path))
				common[filename] = fcopy_rsc(file_path)
				register_asset(filename, common[filename])

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon, FALSE)
	send_asset_list(client, common, TRUE)

/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/browserassets/js/jquery.min.js',
	)

/datum/asset/simple/goonchat
	verify = TRUE
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
		"browserOutput_white.css"  = 'code/modules/goonchat/browserassets/css/browserOutput_white.css'
	)

/datum/asset/simple/fontawesome
	verify = FALSE
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

// Background art for the TGUI Lobby screen (code/modules/mob/new_player/lobby_tgui.dm) - the same images the
// old lobbybrowser title-screen window used to show (GLOB.using_map.lobby_screens, see maps/torch/torch_lobby.dm
// for Torch's own list), just delivered through the normal asset pipeline so resolveAsset() can reach them
// instead of the old file=/display=0 show_browser() trick.
/datum/asset/simple/lobby
	verify = FALSE
	assets = list(
		"default_lobby.png" = 'icons/default_lobby.png',
		"ship.gif"           = 'maps/torch/lobby/ship.gif',
		"hullside.gif"       = 'maps/torch/lobby/hullside.gif',
		"torchlogo.gif"      = 'maps/torch/lobby/torchlogo.gif'
	)

/*
	Spritesheet batching - composites many small icon states into one strip PNG + CSS file, so a tgui interface
	can show real per-entry icons (e.g. the RCD's design picker, the RPD's pipe recipe list) as a couple of asset
	transfers instead of one per icon. This is a pure-DM adaptation of NovaSector's /datum/asset/spritesheet_batched
	(code/modules/asset_cache/spritesheet/batched/batched_spritesheet.dm there) - that system depends on the rust-g
	"iconforge" extension (rustg_iconforge_generate/rustg_hash_file/etc.), which doesn't exist in this codebase at
	all, so the compositing here is done with plain DM icon.Crop()/icon.Blend() instead of a native helper, and
	delivery reuses this file's own register_asset()/send_asset_list() rather than a separate SSassets.transport
	subsystem. Layout is a single horizontal strip per distinct icon size (no row-wrapping), which sidesteps having
	to reverse-engineer how BYOND's own multi-state icon export would lay things out - every position is chosen and
	tracked by this code, not inferred.
*/
/datum/asset/spritesheet
	abstract_type = /datum/asset/spritesheet
	/// also used as the CSS class prefix and the generated file name stem - keep it filename/CSS-safe
	var/name
	/// "32x32" -> list(sprite count, composite icon so far)
	var/list/sizes = list()
	/// sanitized sprite name -> list(size_id, x index within that size's strip)
	var/list/sprites = list()
	var/fully_generated = FALSE

/datum/asset/spritesheet/register()
	if(!name)
		CRASH("spritesheet [type] cannot register without a name")
	create_spritesheets()
	realize_spritesheets()

/// Override this to make Insert() calls, building up the spritesheet.
/datum/asset/spritesheet/proc/create_spritesheets()
	CRASH("create_spritesheets() not implemented for [type]!")

/**
 * Adds one icon_state/dir combination to the spritesheet under `sprite_name` (already expected to be a
 * CSS-safe class name - see sanitize_css_class_name()). Silently no-ops on a duplicate name or a nonexistent
 * icon_state, rather than crashing - callers here are driven by design/recipe catalogs that may share icons.
 */
/datum/asset/spritesheet/proc/Insert(sprite_name, icon/source, icon_state = "", dir = SOUTH)
	var/icon/single = icon(source, icon_state = icon_state, dir = dir)
	if(!single || !length(icon_states(single)))
		return
	InsertIcon(sprite_name, single)

/// Same as Insert(), but takes an already-built /icon (e.g. a multi-layer composite from icon.Blend()) instead
/// of resolving one icon_state/dir - use this when a sprite needs assembling from more than one source icon.
/datum/asset/spritesheet/proc/InsertIcon(sprite_name, icon/single)
	if(!sprite_name || sprites[sprite_name] || !single)
		return

	var/width = single.Width()
	var/height = single.Height()
	var/size_id = "[width]x[height]"
	var/list/size_entry = sizes[size_id]
	if(!size_entry)
		size_entry = list(0, null)
		sizes[size_id] = size_entry

	var/position = size_entry[1]
	var/icon/composite = size_entry[2]
	if(isnull(composite))
		composite = icon(single)
	else
		var/old_width = composite.Width()
		composite.Crop(1, 1, old_width + width, height) //grow the canvas rightward, padding with transparency
		composite.Blend(single, ICON_OVERLAY, old_width + 1, 1) //paste the new sprite into the new slot
	size_entry[2] = composite
	size_entry[1] = position + 1

	sprites[sprite_name] = list(size_id, position)

/// Inserts every icon_state of `source` (optionally restricted to `only_states`) under `sprite_name(icon_state)`.
/datum/asset/spritesheet/proc/insert_all_icons(prefix, icon/source, dir = SOUTH)
	if(length(prefix))
		prefix = "[prefix]_"
	for(var/icon_state_name in icon_states(source))
		Insert(sanitize_css_class_name("[prefix][icon_state_name]"), source, icon_state_name, dir)

/datum/asset/spritesheet/proc/realize_spritesheets()
	if(fully_generated)
		return
	if(!length(sprites))
		fully_generated = TRUE
		return

	for(var/size_id in sizes)
		var/list/size_entry = sizes[size_id]
		var/icon/composite = size_entry[2]
		var/png_name = "[name]_[size_id].png"
		var/file_path = "data/spritesheets/[png_name]"
		fcopy(composite, file_path)
		register_asset(png_name, fcopy_rsc(file_path))

	var/css_name = "spritesheet_[name].css"
	var/css_path = "data/spritesheets/[css_name]"
	text2file(generate_css(), css_path)
	register_asset(css_name, fcopy_rsc(css_path))

	fully_generated = TRUE

/datum/asset/spritesheet/send(client/client)
	if(!fully_generated)
		return
	var/list/all = list("spritesheet_[name].css")
	for(var/size_id in sizes)
		all += "[name]_[size_id].png"
	send_asset_list(client, all, FALSE)

/datum/asset/spritesheet/proc/generate_css()
	var/list/out = list()
	for(var/size_id in sizes)
		var/size_split = splittext(size_id, "x")
		var/width = text2num(size_split[1])
		var/height = text2num(size_split[2])
		out += ".[name][size_id]{display:inline-block;width:[width]px;height:[height]px;background-image:url('[name]_[size_id].png');background-repeat:no-repeat;image-rendering:pixelated;}"

	for(var/sprite_id in sprites)
		var/list/sprite = sprites[sprite_id]
		var/size_id = sprite[1]
		var/idx = sprite[2]
		var/size_split = splittext(size_id, "x")
		var/width = text2num(size_split[1])
		var/x = idx * width
		out += ".[name][size_id].[sprite_id]{background-position:-[x]px 0px;}"

	return out.Join("\n")

/// CSS class name for a given already-registered sprite, or null if it was never inserted (e.g. a nonexistent
/// icon_state that Insert() silently skipped) - callers should treat null as "no icon available".
/datum/asset/spritesheet/proc/icon_class_name(sprite_name)
	var/list/sprite = sprites[sprite_name]
	if(!sprite)
		return null
	return "[name][sprite[1]] [sprite_name]"

/// Turns arbitrary text into a CSS-class-safe token (lowercase, alphanumerics and hyphens only).
/proc/sanitize_css_class_name(text)
	var/static/regex/invalid_chars = regex(@"[^a-z0-9_-]", "g")
	return invalid_chars.Replace(replacetext(lowertext(text), " ", "-"), "-")

/*
	Asset cache
*/
/singleton/asset_cache
	var/list/cache = list()

/singleton/asset_cache/proc/load()
	for(var/type in typesof(/datum/asset))
		// typesof() returns abstract bases too (e.g. /datum/asset/spritesheet, which sets abstract_type on itself) --
		// was previously excluded by hand via a hardcoded list that didn't cover every abstract base in the
		// hierarchy, so instantiating one directly hit spritesheet/register()'s "cannot register without a name"
		// CRASH(). Skip anything abstract generically instead of maintaining that list.
		if(is_abstract(type))
			continue
		var/datum/asset/A = new type()
		A.register()

	for(var/client/C in GLOB.clients) // This is also called in client/New, but as we haven't initialized the cache until now, and it's possible the client is already connected, we risk doing it twice.
		// Doing this to a client too soon after they've connected can cause issues, also the proc we call sleeps.
		spawn(10)
			getFilesSlow(C, cache, FALSE)
