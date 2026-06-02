// TGUI host for the admin player panel.
// Instantiated once per (admin, target-mob) pair and cached on the admins datum.

GLOBAL_TYPED_NEW(tgui_holder_state, /datum/ui_state/holder_access)

/datum/ui_state/holder_access/can_use_topic(src_object, mob/user)
	if(!user.client?.holder)
		return UI_CLOSE
	return UI_INTERACTIVE

// Cache open panels so repeated show_player_panel() calls reuse the same datum.
/datum/admins
	var/list/player_panels = null

/datum/admins/Destroy()
	if(player_panels)
		for(var/datum/player_panel/P in player_panels)
			qdel(P)
		player_panels = null
	return ..()

/datum/player_panel
	var/weakref/target_ref

/datum/player_panel/New(mob/target)
	target_ref = weakref(target)

/datum/player_panel/proc/get_target()
	var/mob/M = target_ref?.resolve()
	if(!M || QDELETED(M))
		return null
	return M

/datum/player_panel/ui_interact(mob/user, datum/tgui/ui)
	var/mob/M = get_target()
	if(!M)
		return
	ui = tgui_interact(user, src, "PlayerPanel", "[M.name] Player Panel", ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/datum/player_panel/ui_state(mob/user)
	return GLOB.tgui_holder_state

/datum/player_panel/ui_data(mob/user)
	var/mob/M = get_target()
	if(!M)
		return list()
	var/last_ckey = LAST_CKEY(M)

	var/client_muted = M.client ? M.client.prefs.muted : 0
	var/godmode = FALSE
	var/is_frozen = FALSE
	var/is_slept = FALSE
	if(isliving(M))
		var/mob/living/L = M
		godmode = !!(L.status_flags & GODMODE)
		is_frozen = L.admin_paralyzed
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			is_slept = C.sleeping > 0

	var/data = list(
		"mob_name" = M.name,
		"mob_type" = "[M.type]",
		"admin_mob_type" = "[user.type]",
		"client_ckey" = M.client ? M.client.ckey : null,
		"client_rank" = (M.client && M.client.holder) ? M.client.holder.rank : "Player",
		"ranks" = null,
		"last_ckey" = last_ckey,
		"playtimes_enabled" = FALSE,
		"playtime" = "N/A",
		"godmode" = godmode,
		"is_frozen" = is_frozen,
		"is_slept" = is_slept,
		"client_muted" = client_muted,
		"current_time" = time_stamp(),
		"data_related_ip" = M.last_address ? M.last_address : "Unknown",
		"data_related_cid" = M.last_cid ? M.last_cid : "Unknown",
		"data_player_join_date" = "N/A",
		"data_account_join_date" = "N/A",
		"data_byond_version" = M.client ? "[M.client.byond_version]" : "N/A",
		"data_old_names" = "N/A",
	)

	// Mute bits list for toggle buttons
	data["glob_mute_bits"] = list(
		list("name" = "IC",   "bitflag" = MUTE_IC),
		list("name" = "OOC",  "bitflag" = MUTE_OOC),
		list("name" = "PRAY", "bitflag" = MUTE_PRAY),
		list("name" = "HELP", "bitflag" = MUTE_ADMINHELP),
		list("name" = "DEAD", "bitflag" = MUTE_DEADCHAT),
		list("name" = "AOOC", "bitflag" = MUTE_AOOC),
	)

	// External limb names → body part tags (for delimb/relimb)
	data["glob_limbs"] = list(
		"Left Arm"  = BP_L_ARM,
		"Right Arm" = BP_R_ARM,
		"Left Leg"  = BP_L_LEG,
		"Right Leg" = BP_R_LEG,
	)

	// Transformation categories
	data["transformables"] = list(
		list("name" = "Animals", "color" = "orange", "types" = list(
			list("name" = "Monkey",  "key" = "/mob/living/carbon/human/monkey"),
			list("name" = "Corgi",   "key" = "/mob/living/simple_animal/passive/corgi"),
			list("name" = "Ian",     "key" = "/mob/living/simple_animal/passive/corgi/Ian"),
			list("name" = "Cat",     "key" = "/mob/living/simple_animal/passive/cat"),
			list("name" = "Runtime", "key" = "/mob/living/simple_animal/passive/cat/fluff/Runtime"),
			list("name" = "Crab",    "key" = "/mob/living/simple_animal/passive/crab"),
		)),
		list("name" = "Silicon", "color" = "blue", "types" = list(
			list("name" = "Robot",   "key" = "/mob/living/silicon/robot"),
		)),
		list("name" = "Special", "color" = "red", "types" = list(
			list("name" = "Slime",       "key" = "/mob/living/carbon/slime"),
			list("name" = "Alien Larva", "key" = "/mob/living/carbon/alien/larva"),
			list("name" = "Ghost",       "key" = "/mob/observer/ghost"),
		)),
	)

	return data

/datum/player_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/M = get_target()
	if(!M)
		return TRUE

	var/mob/user = ui.user
	if(!user.client?.holder)
		return TRUE

	switch(action)

		// ──────────────────── Header ────────────────────

		if("set_name")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			var/new_name = sanitize(params["name"])
			if(!new_name) return TRUE
			log_and_message_admins("renamed [key_name_admin(M)] to [new_name].")
			M.name = new_name
			return TRUE

		if("edit_rank")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!M.client?.holder)
				return TRUE
			var/new_rank = input(user, "Enter new rank for [M.client.ckey]:", "Edit Rank", M.client.holder.rank) as text|null
			if(new_rank)
				log_and_message_admins("changed [key_name_admin(M)]'s rank to [new_rank].")
				M.client.holder.rank = new_rank
			return TRUE

		if("access_variables")
			if(!check_rights(R_DEBUG, FALSE, user.client))
				return TRUE
			user.client.debug_variables(M)
			return TRUE

		if("open_latest_panel")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			var/last_ckey = LAST_CKEY(M)
			if(!last_ckey) return TRUE
			for(var/mob/found in SSmobs.mob_list)
				if(found.ckey == last_ckey && found.client)
					user.client.holder.show_player_panel(found)
					return TRUE
			to_chat(user, SPAN_WARNING("Could not find an active mob for [last_ckey]."))
			return TRUE

		if("private_message")
			if(!check_rights(R_MOD, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			user.client.cmd_admin_pm(M.client, null)
			return TRUE

		if("subtle_message")
			if(!check_rights(R_MOD, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			user.client.cmd_admin_direct_narrate(M)
			return TRUE

		// ──────────────────── General tab ────────────────────

		if("heal")
			if(!check_rights(R_REJUVINATE, FALSE, user.client))
				return TRUE
			if(!isliving(M))
				return TRUE
			if(!config.allow_admin_rev)
				to_chat(user, SPAN_WARNING("Admin rejuvenates have been disabled."))
				return TRUE
			var/mob/living/L = M
			L.revive()
			log_and_message_admins("healed/revived [key_name_admin(M)].")
			return TRUE

		if("smite")
			if(!check_rights(R_FUN, FALSE, user.client))
				return TRUE
			if(!istype(M, /mob/living/carbon/human))
				return TRUE
			log_and_message_admins("smited [key_name_admin(M)].")
			M.gib()
			return TRUE

		if("bring")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			user.client.Getmob(M)
			return TRUE

		if("orbit")
			if(!check_rights(R_MOD, FALSE, user.client))
				return TRUE
			if(!isghost(user))
				user.client.admin_ghost()
			sleep(2)
			if(isghost(user))
				var/mob/observer/ghost/G = user
				G.start_following(M)
			return TRUE

		if("jump_to")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			user.client.jumptomob(M)
			return TRUE

		if("cryo")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!isliving(M))
				return TRUE
			if(M.buckled)
				M.buckled.unbuckle_mob()
			var/last_ckey = LAST_CKEY(M)
			if(isAI(M))
				var/mob/living/silicon/ai/AI = M
				AI.despawn()
				log_and_message_admins("forced [last_ckey]/([M]) to ghost and deactivate.")
				return TRUE
			if(!istype(M.loc, /obj/machinery/cryopod))
				var/obj/machinery/cryopod/C
				if(isrobot(M))
					for(var/obj/machinery/cryopod/robot/CP in SSmachines.machinery)
						if(CP.occupant || !(CP.z in GLOB.using_map.station_levels))
							continue
						C = CP
						break
				else
					for(var/obj/machinery/cryopod/CP in SSmachines.machinery)
						if(CP.occupant || !(CP.z in GLOB.using_map.station_levels))
							continue
						C = CP
						break
				if(!C || C.occupant)
					to_chat(user, SPAN_WARNING("Could not find an empty cryopod!"))
					return TRUE
				C.set_occupant(M)
			log_and_message_admins("put [last_ckey]/([M]) into a cryopod and ghosted them.")
			M.ghostize(FALSE)
			return TRUE

		if("lobby")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!isghost(M))
				return TRUE
			log_and_message_admins("sent [key_name_admin(M)] to the lobby.")
			M.key = null
			return TRUE

		if("ghost")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!isliving(M) || !M.client)
				return TRUE
			log_and_message_admins("ejected ghost from [key_name_admin(M)].")
			M.ghostize(TRUE)
			return TRUE

		if("take_control")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(isghost(user) && !isghost(M))
				log_and_message_admins("took control of [key_name_admin(M)].")
				user.client.mob = M
			return TRUE

		if("offer_control")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!isliving(M))
				return TRUE
			to_chat(user, SPAN_NOTICE("Offer Control is not implemented; use the VV interface."))
			return TRUE

		if("select_equipment")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			var/mob/living/carbon/human/H = M
			if(!ishuman(H)) return TRUE
			var/datum/job/job = SSjobs.get_by_title(H.job)
			if(!job)
				to_chat(user, SPAN_WARNING("No valid job found for [H]."))
				return TRUE
			H.delete_inventory(TRUE)
			for(var/obj/item/organ/internal/augment/custom_augment in H.contents)
				custom_augment.removed(H)
				qdel(custom_augment)
			var/alt_title = H.mind ? H.mind.role_alt_title : null
			job.equip(H, alt_title || "", H.char_branch, H.char_rank)
			SSjobs.equip_custom_loadout(H, job)
			log_and_message_admins("equipped [key_name_admin(H)] with their spawn loadout.")
			return TRUE

		if("strip")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			for(var/obj/item/W in M)
				M.drop_from_inventory(W)
			log_and_message_admins("dropped all items from [key_name_admin(M)].")
			return TRUE

		// ──────────────────── Mob tab ────────────────────

		if("toggle_godmode")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!isliving(M)) return TRUE
			user.client.cmd_admin_godmode(M)
			return TRUE

		if("species")
			if(!check_rights(R_SPAWN, FALSE, user.client))
				return TRUE
			var/mob/living/carbon/human/H = M
			if(!ishuman(H)) return TRUE
			var/new_species = input(user, "Choose a new species:", "Species", null) as null|anything in GLOB.species_by_name
			if(!new_species) return TRUE
			if(QDELETED(H)) return TRUE
			if(H.set_species(new_species))
				log_and_message_admins("changed [key_name_admin(H)]'s species to [new_species].")
			return TRUE

		if("quirk")
			to_chat(user, SPAN_NOTICE("Quirk editing is not supported in this codebase."))
			return TRUE

		if("spell")
			to_chat(user, SPAN_NOTICE("Spell editing is not supported in this codebase."))
			return TRUE

		if("martial_art")
			to_chat(user, SPAN_NOTICE("Martial art editing is not supported in this codebase."))
			return TRUE

		if("skill_panel")
			if(!check_rights(R_INVESTIGATE, FALSE, user.client))
				return TRUE
			if(GAME_STATE < RUNLEVEL_GAME)
				to_chat(user, SPAN_WARNING("The game hasn't started yet."))
				return TRUE
			user.client.holder.show_skills(M)
			return TRUE

		if("languages")
			if(!check_rights(R_SPAWN, FALSE, user.client))
				return TRUE
			// Build a list of toggleable non-innate languages.
			var/list/lang_names = list()
			for(var/k in all_languages)
				var/datum/language/L = all_languages[k]
				if(!(L.flags & INNATE))
					lang_names += k
			if(!length(lang_names))
				to_chat(user, SPAN_WARNING("No toggleable languages found."))
				return TRUE
			var/lang_choice = input(user, "Toggle language for [M.name]:", "Languages") as null|anything in lang_names
			if(!lang_choice) return TRUE
			if(QDELETED(M)) return TRUE
			var/datum/language/L = all_languages[lang_choice]
			if(L in M.languages)
				if(!M.remove_language(lang_choice))
					to_chat(user, SPAN_WARNING("Failed to remove '[lang_choice]'."))
				else
					log_and_message_admins("removed language [lang_choice] from [key_name_admin(M)].")
			else
				if(!M.add_language(lang_choice))
					to_chat(user, SPAN_WARNING("Failed to add '[lang_choice]'."))
				else
					log_and_message_admins("added language [lang_choice] to [key_name_admin(M)].")
			return TRUE

		if("limb")
			if(!check_rights(R_SPAWN, FALSE, user.client))
				return TRUE
			var/mob/living/carbon/human/H = M
			if(!ishuman(H)) return TRUE
			var/list/limbs = params["limbs"]
			var/delimb_mode = params["delimb_mode"]
			if(delimb_mode)
				for(var/limb_tag in limbs)
					if(!limb_tag || !istext(limb_tag))
						continue
					var/obj/item/organ/external/organ = H.organs_by_name[limb_tag]
					if(organ)
						organ.droplimb(TRUE, DROPLIMB_EDGE)
				log_and_message_admins("delimbed [key_name_admin(H)].")
			else
				// Relimb: recreate all organs fresh (full organ reset from species template).
				H.species.create_organs(H)
				H.revive()
				log_and_message_admins("relimbed (full organ reset) [key_name_admin(H)].")
			return TRUE

		if("scale")
			to_chat(user, SPAN_NOTICE("Mob scaling is not supported in this codebase."))
			return TRUE

		if("force_say")
			if(!check_rights(R_FUN, FALSE, user.client))
				return TRUE
			var/speech = sanitize(params["to_say"])
			if(!speech) return TRUE
			M.say(speech)
			log_and_message_admins("forced [key_name_admin(M)] to say: [speech]")
			return TRUE

		if("force_emote")
			if(!check_rights(R_FUN, FALSE, user.client))
				return TRUE
			var/emote = sanitize(params["to_emote"])
			if(!emote) return TRUE
			M.visible_message(SPAN_NOTICE("[M] [emote]"), SPAN_NOTICE("You emote: [emote]"))
			log_and_message_admins("forced [key_name_admin(M)] to emote: [emote]")
			return TRUE

		// ──────────────────── Transform tab ────────────────────

		if("transform")
			if(!check_rights(R_SPAWN, FALSE, user.client))
				return TRUE
			var/new_type_str = params["newType"]
			if(!new_type_str) return TRUE
			if(new_type_str == "/mob/living")
				// Custom transform: prompt for type.
				new_type_str = input(user, "Enter mob type path:", "Transform", "/mob/living/carbon/human") as text|null
				if(!new_type_str) return TRUE
			var/new_type = text2path(new_type_str)
			if(!new_type || !ispath(new_type, /mob))
				to_chat(user, SPAN_WARNING("Invalid mob type: [new_type_str]"))
				return TRUE
			var/del_old = alert(user, "Delete old mob?", "Transform", "Yes", "No", "Cancel")
			if(del_old == "Cancel") return TRUE
			if(QDELETED(M)) return TRUE
			log_and_message_admins("transformed [key_name_admin(M)] into [new_type_str].")
			M.change_mob_type(new_type, null, null, del_old == "Yes")
			return TRUE

		// ──────────────────── Punish tab ────────────────────

		if("notes")
			if(!check_rights(R_INVESTIGATE, FALSE, user.client))
				return TRUE
			var/target_ckey = LAST_CKEY(M)
			if(target_ckey)
				user.client.holder.show_player_info(target_ckey)
			return TRUE

		if("logs")
			if(!check_rights(R_INVESTIGATE, FALSE, user.client))
				return TRUE
			var/target_ckey = LAST_CKEY(M)
			if(target_ckey)
				user.client.holder.show_player_info(target_ckey)
			return TRUE

		if("freeze")
			if(!check_rights(R_INVESTIGATE, FALSE, user.client))
				return TRUE
			if(!isliving(M)) return TRUE
			var/mob/living/L = M
			if(!L.admin_paralyzed)
				L.paralysis = 8000
				L.admin_paralyzed = TRUE
				L.visible_message(SPAN_DEBUG("OOC: \The [L] has been paralyzed by a staff member."))
				to_chat(L, SPAN_DEBUG("OOC: You have been paralyzed by a staff member."))
				log_and_message_staff("has paralyzed [key_name(L)].")
			else
				L.paralysis = 0
				L.admin_paralyzed = FALSE
				L.visible_message(SPAN_DEBUG("OOC: \The [L] has been released from paralysis by staff."))
				to_chat(L, SPAN_DEBUG("OOC: You have been released from paralysis by staff."))
				log_and_message_staff("has unparalyzed [key_name(L)].")
			return TRUE

		if("sleep")
			if(!check_rights(R_INVESTIGATE, FALSE, user.client))
				return TRUE
			if(!iscarbon(M)) return TRUE
			var/mob/living/carbon/C = M
			if(C.sleeping)
				C.sleeping = 0
				log_and_message_admins("woke up [key_name_admin(C)].")
			else
				C.sleeping = 1
				log_and_message_admins("put [key_name_admin(C)] to sleep.")
			return TRUE

		if("prison")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!ismob(M) || istype(M, /mob/living/silicon/ai))
				return TRUE
			var/turf/prison_cell = pick(GLOB.prisonwarp)
			if(!prison_cell) return TRUE
			var/obj/structure/closet/secure_closet/brig/locker = new /obj/structure/closet/secure_closet/brig(prison_cell)
			locker.opened = FALSE
			locker.locked = TRUE
			for(var/obj/item/I in M)
				M.drop_from_inventory(I, locker)
			M.update_icons()
			M.Paralyse(5)
			sleep(5)
			if(QDELETED(M)) return TRUE
			M.forceMove(prison_cell)
			if(ishuman(M))
				var/mob/living/carbon/human/prisoner = M
				prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
				prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
			to_chat(M, SPAN_WARNING("You have been sent to the prison station!"))
			log_and_message_admins("sent [key_name_admin(M)] to the prison station.")
			return TRUE

		if("kick")
			if(!check_rights(R_MOD, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			if(!check_if_greater_rights_than(M.client))
				return TRUE
			var/reason = input(user, "Please enter kick reason:", "Kick") as text|null
			if(isnull(reason)) return TRUE
			reason = sanitize(reason)
			if(!reason)
				to_chat(M, SPAN_WARNING("You have been kicked from the server."))
			else
				to_chat(M, SPAN_WARNING("You have been kicked from the server: [reason]"))
			log_and_message_admins("kicked [key_name_admin(M)].")
			qdel(M.client)
			return TRUE

		if("ban")
			if(!check_rights(R_BAN, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			if(M.client.holder) return TRUE
			var/given_key = LAST_CKEY(M)
			if(!given_key)
				to_chat(user, SPAN_DANGER("This mob has no known last occupant and cannot be banned."))
				return TRUE
			switch(alert(user, "Temporary Ban?", , "Yes", "No", "Cancel"))
				if("Yes")
					var/mins = input(user, "How long (in minutes)?", "Ban time", 1440) as num|null
					if(!mins) return TRUE
					if(mins >= 525600) mins = 525599
					var/reason = sanitize(input(user, "Reason?", "reason", "Griefer") as text|null)
					if(!reason) return TRUE
					if(QDELETED(M))
						to_chat(user, SPAN_DANGER("The mob you are banning no longer exists."))
						return TRUE
					var/mob_key = LAST_CKEY(M)
					if(mob_key != given_key)
						to_chat(user, SPAN_DANGER("This mob's occupant has changed. Please try again."))
						return TRUE
					AddBan(mob_key, M.last_cid, reason, user.ckey, 1, mins)
					var/mins_readable = time_to_readable(mins MINUTES)
					ban_unban_log_save("[user.client.ckey] has banned [mob_key]. - Reason: [reason] - Expires in [mins_readable].")
					notes_add(mob_key, "[user.client.ckey] has banned [mob_key]. - Reason: [reason] - Expires in [mins_readable].", user)
					to_chat(M, SPAN_DANGER("You have been temporarily banned by [user.client.ckey].\nReason: [reason]."))
					to_chat(M, SPAN_WARNING("This ban expires in [mins_readable]."))
					user.client.holder.DB_ban_record(BANTYPE_TEMP, M, mins, reason)
					log_and_message_admins("banned [mob_key]. Reason: [reason]. Expires in [mins_readable].")
					qdel(M.client)
				if("No")
					if(!check_rights(R_BAN, FALSE, user.client)) return TRUE
					var/reason = sanitize(input(user, "Reason?", "reason", "Griefer") as text|null)
					if(!reason) return TRUE
					if(QDELETED(M))
						to_chat(user, SPAN_DANGER("The mob you are banning no longer exists."))
						return TRUE
					switch(alert(user, "IP ban?", , "Yes", "No", "Cancel"))
						if("Cancel") return TRUE
						if("Yes")
							AddBan(given_key, M.last_cid, reason, user.ckey, 0, 0, M.last_address)
						if("No")
							AddBan(given_key, M.last_cid, reason, user.ckey, 0, 0)
					to_chat(M, SPAN_DANGER("You have been permanently banned by [user.client.ckey].\nReason: [reason]."))
					ban_unban_log_save("[user.client.ckey] has permabanned [given_key]. - Reason: [reason]")
					notes_add(given_key, "[user.client.ckey] has permabanned [given_key]. - Reason: [reason]", user)
					log_and_message_admins("permabanned [given_key]. Reason: [reason].")
					user.client.holder.DB_ban_record(BANTYPE_PERMA, M, -1, reason)
					qdel(M.client)
			return TRUE

		if("sticky_ban")
			if(!check_rights(R_BAN, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			if(M.client.holder) return TRUE
			var/last_ckey = LAST_CKEY(M)
			if(!last_ckey) return TRUE
			var/reason = sanitize(input(user, "Sticky ban reason:", "Sticky Ban", "Rule violation") as text|null)
			if(!reason) return TRUE
			if(QDELETED(M)) return TRUE
			AddBan(last_ckey, M.last_cid, reason, user.ckey, 0, 0, M.last_address)
			to_chat(M, SPAN_DANGER("You have been permanently banned by [user.client.ckey]. Reason: [reason]"))
			ban_unban_log_save("[user.client.ckey] has sticky-banned [last_ckey]. Reason: [reason]")
			notes_add(last_ckey, "[user.client.ckey] has sticky-banned [last_ckey]. Reason: [reason]", user)
			log_and_message_admins("sticky-banned [last_ckey]. Reason: [reason]")
			user.client.holder.DB_ban_record(BANTYPE_PERMA, M, -1, reason)
			qdel(M.client)
			return TRUE

		if("mute")
			if(!check_rights(R_MOD, FALSE, user.client) && !check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			if(M.client.holder) return TRUE
			var/new_muted = text2num(params["mute_flag"])
			if(!isnum(new_muted)) return TRUE
			var/old_muted = M.client.prefs.muted
			M.client.prefs.muted = new_muted
			log_admin("[key_name(user)] changed [key_name(M)]'s mute mask from [old_muted] to [new_muted].")
			message_staff("[key_name_admin(user)] changed [key_name_admin(M)]'s mute mask.", 1)
			to_chat(M, SPAN_CLASS("alert", "Your mute settings have been updated by staff."))
			return TRUE

		if("unmute_all")
			if(!check_rights(R_MOD, FALSE, user.client) && !check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			if(M.client.holder) return TRUE
			M.client.prefs.muted = 0
			log_admin("[key_name(user)] unmuted all channels for [key_name(M)].")
			message_staff("[key_name_admin(user)] unmuted all channels for [key_name_admin(M)].", 1)
			to_chat(M, SPAN_CLASS("alert", "You have been unmuted from all channels."))
			return TRUE

		if("mute_all")
			if(!check_rights(R_MOD, FALSE, user.client) && !check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			if(M.client.holder) return TRUE
			M.client.prefs.muted = MUTE_ALL
			log_admin("[key_name(user)] muted all channels for [key_name(M)].")
			message_staff("[key_name_admin(user)] muted all channels for [key_name_admin(M)].", 1)
			to_chat(M, SPAN_CLASS("alert", "You have been muted from all channels."))
			return TRUE

		if("related_accounts")
			if(!check_rights(R_ADMIN, FALSE, user.client))
				return TRUE
			M.show_associated_connections(user)
			M.show_associated_bans(user)
			return TRUE

		// ──────────────────── Fun tab ────────────────────

		if("explode")
			if(!check_rights(R_FUN, FALSE, user.client))
				return TRUE
			var/power = text2num(params["power"])
			var/emp_mode = params["emp_mode"]
			if(!isnum(power)) power = 8
			power = clamp(round(power), 1, 30)
			log_and_message_admins("triggered [emp_mode ? "EMP" : "explosion"] (power [power]) at [key_name_admin(M)]'s location.")
			if(emp_mode)
				empulse(M, max(1, power - 2), power)
			else
				explosion(get_turf(M), power - 4, power - 2, power, power + 2)
			return TRUE

		if("narrate")
			if(!check_rights(R_INVESTIGATE, FALSE, user.client))
				return TRUE
			var/msg = params["message"]
			if(!msg) return TRUE
			var/list/classes = params["classes"]
			var/color   = classes ? classes["color"]       : null
			var/size    = classes ? classes["font-size"]   : null
			var/weight  = classes ? classes["font-weight"] : null
			var/family  = classes ? classes["font-family"] : null
			var/style   = classes ? classes["font-style"]  : null
			var/styled = "<span style='[color ? "color:[color];" : ""][size ? "font-size:[size];" : ""][weight ? "font-weight:[weight];" : ""][family ? "font-family:[family];" : ""][style ? "font-style:[style];" : ""]'>[html_encode(msg)]</span>"
			var/is_global = params["mode_global"]
			var/range = text2num(params["range"])
			if(!isnum(range)) range = 7
			if(is_global)
				to_world(styled)
				log_and_message_admins("sent global narrate: [msg]")
			else
				for(var/mob/listener in view(range, M))
					to_chat(listener, styled)
				log_and_message_admins("sent local narrate to [key_name_admin(M)] (range [range]): [msg]")
			return TRUE

		// ──────────────────── Other tab ────────────────────

		if("traitor_panel")
			if(!check_rights(R_ADMIN | R_MOD, FALSE, user.client))
				return TRUE
			if(GAME_STATE < RUNLEVEL_GAME)
				to_chat(user, SPAN_WARNING("The game hasn't started yet."))
				return TRUE
			user.client.holder.show_traitor_panel(M)
			return TRUE

		if("commend")
			to_chat(user, SPAN_NOTICE("Commend behavior is not implemented in this codebase."))
			return TRUE

		if("play_sound_to")
			if(!check_rights(R_FUN, FALSE, user.client))
				return TRUE
			if(!M.client) return TRUE
			user.client.play_sound()
			return TRUE

		if("apply_client_quirks")
			to_chat(user, SPAN_NOTICE("Apply client quirks is not implemented in this codebase."))
			return TRUE

	return TRUE


// ──────────────────── show_player_panel replacement ────────────────────

/datum/admins/proc/show_player_panel(mob/M in SSmobs.mob_list)
	set category = null
	set name = "Show Player Panel"
	set desc = "Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return
	if(!istype(src, /datum/admins))
		src = usr.client.holder
	if(!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!player_panels)
		player_panels = list()

	var/datum/player_panel/panel = player_panels[M]
	if(!panel || QDELETED(panel))
		panel = new /datum/player_panel(M)
		player_panels[M] = panel
	panel.ui_interact(usr)
