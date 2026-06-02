GLOBAL_TYPED_NEW(tgui_admin_state, /datum/ui_state/admin)

/datum/ui_state/admin/can_use_topic(src_object, mob/user)
	if(!user.client || !check_rights(R_ADMIN, 0, user.client))
		return UI_CLOSE
	return UI_INTERACTIVE
