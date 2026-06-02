GLOBAL_TYPED_NEW(tgui_physical_state, /datum/ui_state/physical)

/datum/ui_state/physical/can_use_topic(src_object, mob/user)
	. = user.shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		. = min(., user.shared_living_ui_distance(src_object))

/mob/proc/physical_tgui_can_use_topic(src_object)
	return UI_CLOSE

/mob/living/silicon/ai/physical_tgui_can_use_topic(src_object)
	return UI_UPDATE // AIs are not physical
