GLOBAL_TYPED_NEW(tgui_self_state, /datum/ui_state/self)

/datum/ui_state/self/can_use_topic(src_object, mob/user)
	if(src_object != user)
		return UI_CLOSE
	return user.shared_ui_interaction(src_object)
