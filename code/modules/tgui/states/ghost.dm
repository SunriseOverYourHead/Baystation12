GLOBAL_TYPED_NEW(tgui_ghost_state, /datum/ui_state/ghost)

/datum/ui_state/ghost/can_use_topic(src_object, mob/user)
	if(!isghost(user))
		return UI_CLOSE
	return UI_INTERACTIVE
