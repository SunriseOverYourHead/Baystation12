/datum/preferences/var/list/background_states = list("000", "FFF", MATERIAL_STEEL, "white")

/datum/preferences/var/icon/bgstate = "000"

/datum/preferences/var/preview_job = TRUE

/datum/preferences/var/preview_gear = TRUE

/// TRUE strips the preview mannequin's underwear too (the "Naked" preview mode) -- otherwise, with
/// preview_job/preview_gear both FALSE, the mannequin still shows whatever underwear copy_to() gave it (the
/// "Underwear" preview mode). See "update_preview" in preferences_tgui.dm's ui_act().
/datum/preferences/var/preview_nude = FALSE

/// TRUE (only meaningful alongside preview_nude) forces the mannequin's penis/vagina organ(s) into their aroused
/// sprite (the "Naked (Aroused)" preview mode) -- lets a player see what their character's genital arousal state
/// actually looks like directly in character setup, without needing to be in a live round with the sexcon engine
/// running. See dress_preview_mob() below for where this is actually applied to the mannequin's organs.
/datum/preferences/var/preview_aroused = FALSE

/datum/preferences/var/icon/preview_icon
/datum/preferences/var/tgui_preview_version = 0

/// Which direction the TGUI character preview is currently facing -- cycled by the rotate-left/rotate-right
/// buttons (see "rotate" in preferences_tgui.dm's ui_act()). Only one direction is ever rendered at a time.
/datum/preferences/var/preview_dir = SOUTH


/datum/preferences/VV_static()
	return ..() + list(
		"background_states"
	)


/datum/preferences/proc/dress_preview_mob(mob/living/carbon/human/mannequin)
	var/update_icon = FALSE
	copy_to(mannequin, TRUE)
	if(preview_nude)
		QDEL_NULL_LIST(mannequin.worn_underwear)
		mannequin.worn_underwear = list()
	apply_preview_arousal(mannequin)
	var/datum/job/previewJob
	if (preview_job || preview_gear)
		// Determine what job is marked as 'High' priority, and dress them up as such.
		if(GLOB.using_map.default_assistant_title in job_low)
			previewJob = SSjobs.get_by_title(GLOB.using_map.default_assistant_title)
		else
			previewJob = SSjobs.get_by_title(job_high)
	else
		return
	var/list/loadout_taken_slots = list()
	if(preview_job && previewJob)
		mannequin.job = previewJob.title
		var/datum/mil_branch/branch = GLOB.mil_branches.get_branch(branches[previewJob.title])
		var/datum/mil_rank/rank = GLOB.mil_branches.get_rank(branches[previewJob.title], ranks[previewJob.title])
		previewJob.equip_preview(mannequin, player_alt_titles[previewJob.title], branch, rank)
		var/list/preview_gear = preview_job ? Uniform(previewJob) : list()
		if(preview_gear)
			for(var/thing in Uniform(previewJob))
				var/item = new thing(mannequin.loc)
				var/slot = mannequin.equip_to_appropriate_slot(item, TRUE, TRUE, TRUE, TRUE)
				if(slot)
					loadout_taken_slots |= slot
		update_icon = TRUE
	if(!(mannequin.species.appearance_flags && mannequin.species.appearance_flags & SPECIES_APPEARANCE_HAS_UNDERWEAR))
		if(all_underwear)
			all_underwear.Cut()
	if(preview_gear && !(previewJob && preview_job && (previewJob.type == /datum/job/ai || previewJob.type == /datum/job/cyborg)))
		// Equip custom gear loadout, replacing any job items
		for(var/thing in Gear())
			var/datum/gear/G = gear_datums[thing]
			if(G)
				var/permitted = 0
				if(G.allowed_roles && length(G.allowed_roles))
					if(previewJob)
						for(var/job_type in G.allowed_roles)
							if(previewJob.type == job_type)
								permitted = 1
				else
					permitted = 1
				if(G.whitelisted && !(mannequin.species.name in G.whitelisted))
					permitted = 0
				if(!permitted)
					continue
				if(G.slot && G.slot != slot_tie && !(G.slot in loadout_taken_slots) && G.spawn_on_mob(mannequin, gear_list[gear_slot][G.display_name]))
					loadout_taken_slots |= G.slot
					update_icon = TRUE
	if(update_icon)
		mannequin.update_icons()

/**
 * Sets the mannequin's penis/vagina organ(s) is_aroused flag to match preview_aroused (see sexcon.dm's
 * update_genital_arousal_visuals() for the live-game equivalent of this same flag/render pair) and refreshes the
 * groin limb if anything changed. The mannequin has no /datum/sex_controller (it's a preview dummy, not a
 * controllable living mob) so this sets the organ flag directly rather than going through the sexcon engine.
 * Always runs (even when preview_aroused is FALSE) so switching away from "Naked (Aroused)" correctly reverts the
 * mannequin's organs, rather than leaving them stuck aroused from a previous preview render.
 */
/datum/preferences/proc/apply_preview_arousal(mob/living/carbon/human/mannequin)
	var/should_be_aroused = preview_nude && preview_aroused
	var/changed = FALSE
	var/obj/item/organ/internal/mutant/penis/P = mannequin.internal_organs_by_name[BP_PENIS]
	if(istype(P) && P.is_aroused != should_be_aroused)
		P.is_aroused = should_be_aroused
		changed = TRUE
	var/obj/item/organ/internal/mutant/vagina/V = mannequin.internal_organs_by_name[BP_PUSSY]
	if(istype(V) && V.is_aroused != should_be_aroused)
		V.is_aroused = should_be_aroused
		changed = TRUE
	if(changed)
		// update_body(), NOT the organ's own update_icon() -- see sexcon.dm's update_genital_arousal_visuals()
		// header comment for why the organ-level proc alone never actually refreshes what's displayed.
		mannequin.update_body()


/datum/preferences/proc/update_preview_icon(resize_only)
	var/static/icon/last_built_icon
	if (!resize_only || !last_built_icon)
		var/mob/living/carbon/human/dummy/mannequin/mannequin = get_mannequin(client_ckey)
		mannequin.delete_inventory(TRUE)
		dress_preview_mob(mannequin)
		mannequin.update_icons()
		mannequin.ImmediateOverlayUpdate()
		// Single-pose preview (cycled via the rotate-left/rotate-right buttons, preview_dir) rather than the old
		// fixed 3-pose (W/N/S) composite -- a plain square background just big enough to center the flat
		// mannequin render with a little margin.
		mannequin.dir = preview_dir
		var/icon/flat = getFlatIcon(mannequin, preview_dir, always_use_defdir = TRUE)
		// Canvas used to be a flat 48x48 with content blended at a fixed (9,9), sized on the assumption every
		// species renders inside a plain 32x32 tile -- true for Human/Anthro, but species with a taller/wider
		// icon_template (GAS 32x40, Gyne 40x48) genuinely need more room even with zero mutant organs toggled on,
		// so their own base render was already clipping against the fixed canvas. Size dynamically off the actual
		// flattened render instead, keeping the same ~16px margin the original constants implied (48-32=16).
		var/margin = 16
		var/canvas_w = max(48, flat.Width() + margin)
		var/canvas_h = max(48, flat.Height() + margin)
		last_built_icon = icon('icons/effects/128x48.dmi', bgstate)
		last_built_icon.Scale(canvas_w, canvas_h)
		last_built_icon.Blend(flat, ICON_OVERLAY, round((canvas_w - flat.Width()) / 2), round((canvas_h - flat.Height()) / 2))
	preview_icon = new (last_built_icon)
	var/scale = client.get_preference_value(/datum/client_preference/preview_scale)
	switch (scale)
		if (GLOB.PREF_LARGE)
			scale = 4
		if (GLOB.PREF_MEDIUM)
			scale = 3
		else
			scale = 2
	preview_icon.Scale(preview_icon.Width() * scale, preview_icon.Height() * scale)


/datum/category_item/player_setup_item/physical/preview
	name = "Preview"
	sort_order = 5


/datum/category_item/player_setup_item/physical/preview/load_character(datum/pref_record_reader/R)
	pref.bgstate = R.read("bgstate")
	pref.preview_icon = null


/datum/category_item/player_setup_item/physical/preview/save_character(datum/pref_record_writer/W)
	W.write("bgstate", pref.bgstate)


/datum/category_item/player_setup_item/physical/preview/sanitize_character()
	if(!pref.bgstate || !(pref.bgstate in pref.background_states))
		pref.bgstate = pref.background_states[1]


/datum/category_item/player_setup_item/physical/preview/OnTopic(query_text, list/query, mob/user)
	if (!query)
		return
	else if (query["cyclebg"])
		var/index = pref.background_states.Find(pref.bgstate)
		if (!index || index == length(pref.background_states))
			pref.bgstate = pref.background_states[1]
		else
			pref.bgstate = pref.background_states[index + 1]
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if (query["resize"])
		pref.client?.cycle_preference(/datum/client_preference/preview_scale)
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if (query["previewjob"])
		pref.preview_job = !pref.preview_job
		pref.preview_icon = null
		return TOPIC_REFRESH_UPDATE_PREVIEW
	else if (query["previewgear"])
		pref.preview_gear = !pref.preview_gear
		pref.preview_icon = null
		return TOPIC_REFRESH_UPDATE_PREVIEW
	return ..()


/datum/category_item/player_setup_item/physical/preview/content(mob/user)
	if(!pref.preview_icon)
		pref.update_preview_icon()
	send_rsc(user, pref.preview_icon, "previewicon.png")
	var/width = pref.preview_icon.Width()
	var/height = pref.preview_icon.Height()
	. = "<b>Preview:</b>"
	. += "<br />[BTN("cyclebg", "Cycle Background")]"
	. += " - [BTN("previewgear", "[pref.preview_gear ? "Hide" : "Show"] Loadout")]"
	. += " - [BTN("previewjob", "[pref.preview_job ? "Hide" : "Show"] Uniform")]"
	. += " - [BTN("resize", "Resize")]"
	. += {"<br /><div class="statusDisplay" style="text-align:center"><img src="previewicon.png" width="[width]" height="[height]"></div>"}
