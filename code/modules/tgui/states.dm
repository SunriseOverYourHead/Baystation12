/**
 * Base ui_state datum and shared ui_status proc.
 *
 * ui_state datums control whether a given user can interact with a tgui UI.
 * They replace NanoUI's topic_state system.
 */

/datum/ui_state
	// Subtype — override can_use_topic()

/datum/ui_state/proc/can_use_topic(src_object, mob/user)
	return UI_CLOSE

/**
 * Computes the UI status for a given user.
 * Observers are always allowed to view (UI_UPDATE) if in range.
 * Admin ghosts get full interaction.
 */
/datum/proc/ui_status(mob/user, datum/ui_state/state)
	var/src_object = ui_host(user)
	. = UI_CLOSE
	if(!state)
		return

	if(isobserver(user))
		if(user.can_admin_interact())
			. = max(., UI_INTERACTIVE)
		if(user.client)
			if(get_dist(src_object, user) <= user.client.view)
				. = max(., UI_UPDATE)

	var/result = state.can_use_topic(src_object, user)
	. = max(., result)

/**
 * Shared sanity checks used by all mob types.
 * Returns UI_CLOSE if no client, UI_DISABLED if unconscious, UI_UPDATE if incapacitated.
 */
/mob/proc/shared_ui_interaction(src_object)
	if(!client)
		return UI_CLOSE
	else if(stat)
		return UI_DISABLED
	else if(incapacitated())
		return UI_UPDATE
	return UI_INTERACTIVE

/mob/living/silicon/ai/shared_ui_interaction(src_object)
	if(!has_power())
		return UI_DISABLED
	if(check_unable(TRUE, FALSE))
		return UI_CLOSE
	return ..()

/mob/living/silicon/robot/shared_ui_interaction(src_object)
	if(!cell || cell.charge <= 0)
		return UI_CLOSE
	if(lockcharge)
		return UI_DISABLED
	return ..()

/**
 * Distance-based interactivity check. Base proc returns UI_CLOSE for non-living mobs.
 */
/mob/proc/shared_living_ui_distance(atom/movable/src_object, viewcheck = TRUE)
	return UI_CLOSE

/mob/living/shared_living_ui_distance(atom/movable/src_object, viewcheck = TRUE)
	if(viewcheck && !(src_object in view(src)))
		return UI_CLOSE
	var/dist = get_dist(src_object, src)
	if(dist <= 1)
		return Adjacent(src_object) ? UI_INTERACTIVE : UI_UPDATE
	else if(dist <= 2)
		return UI_UPDATE
	else if(dist <= 4)
		return UI_DISABLED
	return UI_CLOSE
