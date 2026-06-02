GLOBAL_TYPED_NEW(tgui_default_state, /datum/ui_state/default)

/datum/ui_state/default/can_use_topic(src_object, mob/user)
	return user.default_tgui_can_use_topic(src_object)

/mob/proc/default_tgui_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/default_tgui_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. != UI_CLOSE && loc)
		. = min(., loc.contents_nano_distance(src_object, src))
	// Living mobs without a usable hand can view but not interact
	if(. == UI_INTERACTIVE && !istype(src, /mob/living/carbon/human))
		return UI_UPDATE

/mob/living/carbon/human/default_tgui_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. != UI_CLOSE)
		if(loc)
			. = min(., loc.contents_nano_distance(src_object, src))
		else
			. = min(., shared_living_ui_distance(src_object))

/mob/living/silicon/robot/default_tgui_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return
	if((src_object in view(src)) && get_dist(src_object, src) <= src.client.view)
		return UI_INTERACTIVE
	return UI_DISABLED

/mob/living/silicon/ai/default_tgui_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. != UI_INTERACTIVE)
		return
	var/turf/T = get_turf(src_object)
	var/turf/A = get_turf(src)
	if(!A || !T || !AreConnectedZLevels(A.z, T.z))
		return UI_CLOSE
	if(src_object in view(client.view, src))
		return UI_INTERACTIVE
	if(is_in_chassis())
		if(cameranet && !cameranet.is_turf_visible(get_turf(src_object)))
			return UI_CLOSE
		return UI_INTERACTIVE
	if(get_dist(src_object, src) <= client.view)
		return UI_INTERACTIVE
	return UI_CLOSE

/mob/living/silicon/pai/default_tgui_can_use_topic(src_object)
	if((src_object == src || src_object == silicon_radio) && !stat)
		return UI_INTERACTIVE
	return ..()
