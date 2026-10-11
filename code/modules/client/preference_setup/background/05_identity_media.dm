/datum/preferences
	var/headshot_url = ""
	var/headshot_nsfw_url = ""
	// A single art reference image, self-flagged NSFW or not by the player (art_ref_nsfw) -- unlike Headshot,
	// there's no separate second URL slot; the one image just stops being sent to viewers who shouldn't see it
	// when flagged (examine_panel.dm), matching how the old two-URL design was explicitly walked back.
	var/art_reference_url = ""
	var/art_ref_nsfw = FALSE
	// Self-flagged "this specific image is AI-generated" for each of the three media slots above -- distinct from
	// (and orthogonal to) art_ref_nsfw: whether something is NSFW and whether it's AI-generated are independent
	// questions. Purely a courtesy label players apply to their own uploads (see view_ai_generated_headshots below
	// for the flip side) -- there's no actual detection, this only works if players tag their own art honestly.
	var/headshot_ai_generated = FALSE
	var/headshot_nsfw_ai_generated = FALSE
	var/art_reference_ai_generated = FALSE
	// Non-sexual -- deliberately NOT gated by master_erp_preferences/Enable Sexual Content anywhere in this system
	// (unlike everything else on this page). This is the VIEWER's own setting, not the examined character's: read
	// directly off user.client.prefs in examine_panel.dm's ui_data(), never mirrored onto a mob, since it only
	// ever matters for a live, currently-connected client actively looking at someone's examine panel -- there's
	// no "target disconnected" edge case to protect against the way headshot_url/ooc_notes/etc need to (see their
	// own header comment in examine_panel.dm), and reading it live means it takes effect immediately, same as
	// every other field in this session's live-sync retrofit.
	var/view_ai_generated_headshots = TRUE
	var/ooc_notes = ""

/datum/category_item/player_setup_item/background/identity_media
	name = "Identity Media"
	sort_order = 4

/datum/category_item/player_setup_item/background/identity_media/load_character(datum/pref_record_reader/R)
	pref.headshot_url = R.read("headshot_url")
	pref.headshot_nsfw_url = R.read("headshot_nsfw_url")
	pref.art_reference_url = R.read("art_reference_url")
	pref.art_ref_nsfw = R.read("art_ref_nsfw")
	// Re-validate on load, not just on set -- is_valid_media_url() got measurably stricter (see its own header
	// comment: a host-whitelist bypass and an HTML-injection gap were fixed there), and unlike every other field
	// on this page, a stale value here isn't just wrong data, it's an attack that already passed the old, looser
	// checks sitting dormant in a savefile. Silently drops anything that no longer validates rather than crashing
	// or leaving a known-bad value loaded.
	if(length(pref.headshot_url) && !is_valid_media_url(pref.headshot_url))
		pref.headshot_url = ""
	if(length(pref.headshot_nsfw_url) && !is_valid_media_url(pref.headshot_nsfw_url))
		pref.headshot_nsfw_url = ""
	if(length(pref.art_reference_url) && !is_valid_media_url(pref.art_reference_url))
		pref.art_reference_url = ""
	pref.headshot_ai_generated = R.read("headshot_ai_generated")
	pref.headshot_nsfw_ai_generated = R.read("headshot_nsfw_ai_generated")
	pref.art_reference_ai_generated = R.read("art_reference_ai_generated")
	// Explicit null-guard (unlike every FALSE-default bool above, which doesn't need one) -- this defaults to
	// TRUE, and a savefile predating this var simply won't have the key, so a bare R.read() would silently read
	// back null and override the compile-time TRUE default to "off" for every existing character on first load.
	pref.view_ai_generated_headshots = R.read("view_ai_generated_headshots")
	if(isnull(pref.view_ai_generated_headshots))
		pref.view_ai_generated_headshots = TRUE
	pref.ooc_notes = R.read("ooc_notes")
	// One-time migration from the old "OOC_Notes" savefile key (01_basic.dm's now-removed `metadata` var --
	// a write-only field, never actually copied onto the spawned mob or read anywhere, that a leftover TGUI
	// Feature confusingly still labeled "OOC notes") -- carries over anything a returning player already wrote
	// there into this, the real OOC-notes field, instead of silently discarding it.
	if(!length(pref.ooc_notes))
		var/legacy_notes = R.read("OOC_Notes")
		if(length(legacy_notes))
			pref.ooc_notes = legacy_notes

/datum/category_item/player_setup_item/background/identity_media/save_character(datum/pref_record_writer/W)
	W.write("headshot_url", pref.headshot_url)
	W.write("headshot_nsfw_url", pref.headshot_nsfw_url)
	W.write("art_reference_url", pref.art_reference_url)
	W.write("art_ref_nsfw", pref.art_ref_nsfw)
	W.write("headshot_ai_generated", pref.headshot_ai_generated)
	W.write("headshot_nsfw_ai_generated", pref.headshot_nsfw_ai_generated)
	W.write("art_reference_ai_generated", pref.art_reference_ai_generated)
	W.write("view_ai_generated_headshots", pref.view_ai_generated_headshots)
	W.write("ooc_notes", pref.ooc_notes)

// Headshot/art-reference URLs are never uploaded to or stored by the server -- just externally-hosted image
// links, validated here the same way Bubberstation's own headshot preference does: https only, a real image
// extension, and a small host whitelist (image CDNs known to work embedded in a BYOND client's browser; e.g.
// Imgur specifically does not render correctly embedded this way).
//
// SECURITY: two real, confirmed issues were found and fixed here.
// 1. The l3n.co host alternative used to be ".*\.l3n\.co/" -- the leading ".*" isn't anchored to a hostname at
//    all, so "https://attacker.example/x.l3n.co/y.png" passed (host_regex just needs the literal substring
//    ".l3n.co/" to appear SOMEWHERE, with the actual request going to attacker.example, not l3n.co). Replaced
//    with a real subdomain-label character class ([A-Za-z0-9.\-]+, no "/") so the match can't cross into a path
//    on a different host. Still allows multi-level subdomains (a.b.l3n.co), just not arbitrary text.
// 2. Nothing here rejected HTML-attribute-breakout characters (", ', <, >). Since headshot_url gets embedded into
//    a RAW (non-React) HTML string with zero escaping for the Shift-click chat preview (examine.dm), a "URL" like
//    https://files.catbox.moe/x" onerror="...".png used to pass every check here -- real whitelisted host, ends
//    in .png -- while injecting a live onerror handler that executes in the chat client of anyone who examines
//    that character (confirmed: tgui-panel's chat renderer sets node.innerHTML directly, no sanitization on
//    receipt). Fixed with a strict allowlist of URL-safe characters below, which excludes every HTML-special
//    character by construction rather than trying to blocklist the ones we thought of. examine.dm additionally
//    HTML-escapes the URL before embedding it, as defense in depth in case this validator ever changes.
/proc/is_valid_media_url(url)
	if(!istext(url) || !length(url))
		return FALSE
	if(!findtext(url, "https://", 1, 9))
		return FALSE
	var/static/regex/safe_chars_regex = regex(@"^[A-Za-z0-9\-._~:/?#\[\]@!$&()*+,;=%]+$")
	if(!safe_chars_regex.Find(url))
		return FALSE
	var/static/regex/extension_regex = regex(@"\.(jpg|jpeg|png)$", "i")
	if(!extension_regex.Find(url))
		return FALSE
	var/static/regex/host_regex = regex(@"^https://(i\.gyazo\.com/|[A-Za-z0-9.\-]+\.l3n\.co/|static\.f-list\.net/images/|images2\.imgbox\.com/|thumbs2\.imgbox\.com/|files\.catbox\.moe/)", "i")
	if(!host_regex.Find(url))
		return FALSE
	return TRUE
