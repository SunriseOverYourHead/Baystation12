// Backs the "Examine Closer..." link (examine.dm) and the Character Directory's "View" button
// (code/modules/client/character_directory.dm) -- one lazily-created instance per human, living/dying with its
// owner, so both entry points always reach the exact same panel instance for a given character.
//
// Data composition here mirrors Bubberstation's own modular_zubbers/code/modules/examine_tgui/examine_tgui.dm as
// closely as this codebase's own (mob-var-based, not dna.features-based) data model allows -- reads straight off
// the target mob's own vars rather than target.client.prefs, so it keeps working even if the target's client has
// disconnected (matching how the security/medical examine-HUD links already read off record vars directly).

/mob/living/carbon/human
	var/datum/examine_panel/examine_panel

/mob/living/carbon/human/proc/get_examine_panel()
	if(!examine_panel)
		examine_panel = new(src)
	return examine_panel

/datum/examine_panel
	var/mob/living/carbon/human/target

// Shared across every /datum/examine_panel instance (not per-target) so two different targets' panels can never
// end up with the same generated RSC filename within one session -- a per-instance counter could collide if two
// different targets' panels happened to be built the same number of times.
var/global/examine_panel_preview_counter = 0

/datum/examine_panel/New(mob/living/carbon/human/H)
	. = ..()
	target = H

/datum/examine_panel/Destroy()
	target = null
	return ..()

/datum/examine_panel/ui_state(mob/user)
	return GLOB.tgui_always_state

/datum/examine_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "ExaminePanel", "Examine: [target.name]", ui)

// A static PNG snapshot of the target's current appearance, sent via BYOND's RSC cache (the same mechanism
// /datum/preferences/build_tgui_preview() already uses for the player's own live setup preview), generalized to
// an arbitrary target mob rather than just "self". Substitutes for Bubberstation's live ByondUi map-view embed,
// which needs tgstation's plane-master/screen-map_view rendering infrastructure -- confirmed absent from this
// codebase entirely (see baystation12soyh_character_directory_examine_panel memory) -- so a snapshot image is
// used instead of a truly live view.
/datum/examine_panel/proc/build_character_preview(mob/user)
	if(!user?.client || !target)
		return ""
	var/icon/flat = getFlatIcon(target, SOUTH, always_use_defdir = TRUE)
	if(!flat)
		return ""
	examine_panel_preview_counter++
	var/rsc_name = "examinepreview_[examine_panel_preview_counter].png"
	send_rsc(user.client, flat, rsc_name)
	return rsc_name

/datum/examine_panel/ui_data(mob/user)
	var/list/data = list()
	data["character_name"] = target.name
	data["character_preview_view"] = build_character_preview(user)

	// NSFW flavor/headshot variants (and the single self-flagged-NSFW Art Reference) are only sent at all if the
	// TARGET's own privacy preference allows it -- "Always On", or "Nude Only" gated on the target's current
	// w_uniform (matches Bubberstation's own show_nsfw_flavor_text + !w_uniform check exactly) -- AND the VIEWER
	// themselves has Sexual Content enabled. A viewer with it off never sees anyone's NSFW content, regardless of
	// the target's own settings.
	var/mob/living/carbon/human/viewer = ishuman(user) ? user : null
	var/viewer_erp_enabled = viewer && viewer.master_erp_preferences
	var/show_nsfw = viewer_erp_enabled && ((target.show_nsfw_flavor_text == "Always On") || \
		(target.show_nsfw_flavor_text == "Nude Only" && !target.w_uniform))

	// Non-sexual, independent of every ERP gate above -- read live off the viewer's own preferences (see the var's
	// own comment, 05_identity_media.dm), not off the viewer's mob, since it has no reason to be spawn-locked the
	// way master_erp_preferences is. Defaults permissive (TRUE) on the rare chance user.client is somehow absent
	// here, matching this var's own "on by default" compile-time default rather than silently hiding things.
	var/viewer_wants_ai = user?.client ? user.client.prefs.view_ai_generated_headshots : TRUE
	var/show_headshot = !(target.headshot_ai_generated && !viewer_wants_ai)
	var/show_headshot_nsfw = show_nsfw && !(target.headshot_nsfw_ai_generated && !viewer_wants_ai)
	var/show_art_reference = (!target.art_ref_nsfw || show_nsfw) && !(target.art_reference_ai_generated && !viewer_wants_ai)

	data["headshot_url"] = show_headshot ? target.headshot_url : ""
	data["art_reference_url"] = show_art_reference ? target.art_reference_url : ""
	data["art_ref_nsfw"] = target.art_ref_nsfw
	data["flavor_text"] = target.character_flavor_text
	data["flavor_text_nsfw"] = show_nsfw ? target.flavor_text_nsfw : ""
	data["headshot_nsfw_url"] = show_headshot_nsfw ? target.headshot_nsfw_url : ""

	// Custom species name/lore -- falls back to the real species name/description when unset, matching
	// Bubberstation's own "report the normal custom species if there is not one set" behavior. This codebase has
	// no lore_protected species flag to check first (not ported -- see baystation12soyh_character_directory_examine_panel
	// memory), so custom species text is always editable regardless of species here.
	data["custom_species"] = length(target.custom_species) ? target.custom_species : target.species?.name
	data["custom_species_lore"] = length(target.custom_species_lore) ? target.custom_species_lore : (target.species?.description || "")

	// OOC Notes -- prefixed with the ERP tag block, same as Bubberstation, but only if the target has ERP enabled
	// at all (matches the genital toggles' own three-way gate: config flag + master switch).
	var/list/ooc_lines = list()
	if(!config.disable_erp_preferences && target.master_erp_preferences)
		ooc_lines += "ERP: [target.erp_status][target.erp_free_use ? " - Free Use" : ""]"
		ooc_lines += "Hypnosis: [target.erp_status_hypno]"
		ooc_lines += "Vore: [target.erp_status_v]"
		ooc_lines += "Non-Con: [target.erp_status_nc]"
		ooc_lines += ""
	ooc_lines += target.ooc_notes
	data["ooc_notes"] = jointext(ooc_lines, "\n")

	// Character Advert -- server-composed the same way: a short preference summary, a blank line, then the raw
	// free-text advert.
	var/list/ad_lines = list()
	if(target.display_gender != "Unset")
		ad_lines += "Gender: [target.display_gender]"
	if(target.attraction != "Unset")
		ad_lines += "Sexuality: [target.attraction]"
	ad_lines += "Preferred Emote Length: [target.emote_length]"
	ad_lines += "How to Approach: [target.approach_pref]"
	ad_lines += "Furries: [target.furry_pref] | Scalies: [target.scalie_pref] | Other: [target.other_pref]"
	ad_lines += "Demis: [target.demihuman_pref] | Humans: [target.human_pref]"
	// Only shown once sexual content is actually enabled -- otherwise this is always "No" (forced off, same as
	// every other ERP tag) for every single non-ERP character, which is just noise here.
	if(target.master_erp_preferences)
		ad_lines += "Mechanical ERP: [target.mechanical_erp ? "Yes" : "No"]"
	ad_lines += ""
	ad_lines += target.character_ad
	data["character_ad"] = jointext(ad_lines, "\n")

	return data
