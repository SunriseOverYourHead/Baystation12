#define SAVE_RESET -1

#define JOB_PRIORITY_HIGH   FLAG_01
#define JOB_PRIORITY_MEDIUM FLAG_02
#define JOB_PRIORITY_LOW    FLAG_03
#define JOB_PRIORITY_LIKELY (JOB_PRIORITY_HIGH | JOB_PRIORITY_MEDIUM)
#define JOB_PRIORITY_PICKED (JOB_PRIORITY_HIGH | JOB_PRIORITY_MEDIUM | JOB_PRIORITY_LOW)

#define MAX_LOAD_TRIES 5

/datum/preferences_slot
	var/slot
	var/age

/datum/preferences
	//doohickeys for savefiles
	var/is_guest = FALSE
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used

	var/use_slot_priority_list = FALSE
	var/list/datum/preferences_slot/slot_priority_list = list()

	// Cache, mapping slot record ids to character names
	// Saves reading all the slot records when listing
	var/list/slot_names = null

	//non-preference stuff
	var/warns = 0
	var/muted = 0
	var/last_ip
	var/last_id

	// Populated with an error message if loading fails.
	var/load_failed = null

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change

	var/client/client = null
	var/client_ckey = null

	var/datum/browser/popup

	var/datum/category_collection/player_setup_collection/player_setup
	var/datum/browser/panel

/datum/preferences/New(client/C)
	if(istype(C))
		client = C
		client_ckey = C.ckey
		SScharacter_setup.preferences_datums[C.ckey] = src
		if(SScharacter_setup.initialized)
			setup()
		else
			SScharacter_setup.prefs_awaiting_setup += src
	..()

/datum/preferences/proc/setup()
	if(!length(GLOB.skills))
		GET_SINGLETON(/singleton/hierarchy/skill)
	player_setup = new(src)
	gender = pick(MALE, FEMALE)
	real_name = random_name(gender,species)
	b_type = RANDOM_BLOOD_TYPE

	if(client)
		if(IsGuestKey(client.key))
			is_guest = TRUE
		else
			load_data()

	sanitize_preferences()
	if(client && istype(client.mob, /mob/new_player))
		var/mob/new_player/np = client.mob
		np.new_player_panel(TRUE)

/datum/preferences/proc/load_data()
	load_failed = null
	var/stage = "pre"
	try
		var/pref_path = get_path(client_ckey, "preferences")
		if(!fexists(pref_path))
			stage = "migrate"
			// Try to migrate legacy savefile-based preferences
			if(!migrate_legacy_preferences())
				// If there's no old save, there'll be nothing to load.
				return

		stage = "load"
		load_preferences()
		load_character()
	catch(var/exception/E)
		load_failed = "{[stage]} [E]"
		throw E

/datum/preferences/proc/migrate_legacy_preferences()
	// We make some assumptions here:
	// - all relevant savefiles were version 17, which covers anything saved from 2018+
	// - legacy saves were only made on the "torch" map
	// - a maximum of 40 slots were used

	var/legacy_pref_path = get_path(client.ckey, "preferences", "sav")
	if(!fexists(legacy_pref_path))
		return 0

	var/savefile/S = new(legacy_pref_path)
	if(S["version"] != 17)
		return 0

	// Legacy version 17 ~= new version 1
	var/datum/pref_record_reader/savefile/savefile_reader = new(S, 1)

	player_setup.load_preferences(savefile_reader)
	var/orig_slot = default_slot

	S.cd = "/torch"
	for(var/slot = 1 to 40)
		if(!S.dir.Find("character[slot]"))
			continue
		S.cd = "/torch/character[slot]"
		default_slot = slot
		player_setup.load_character(savefile_reader)
		save_character(override_key="character_torch_[slot]")
		S.cd = "/torch"
	S.cd = "/"

	default_slot = orig_slot
	save_preferences()

	return 1

/datum/preferences/proc/get_content(mob/user)
	if(!SScharacter_setup.initialized)
		return
	if(!user || !user.client)
		return

	var/dat = "<center>"

	if(is_guest)
		dat += "Please create an account to save your preferences. If you have an account and are seeing this, please adminhelp for assistance."
	else if(load_failed)
		dat += "Loading your savefile failed. Please adminhelp for assistance."
	else
		dat += "Slot - "
		dat += "<a href='byond://?src=\ref[src];load=1'>Load slot</a> - "
		dat += "<a href='byond://?src=\ref[src];save=1'>Save slot</a> - "
		dat += "<a href='byond://?src=\ref[src];resetslot=1'>Reset slot</a> - "
		dat += "<a href='byond://?src=\ref[src];reload=1'>Reload slot</a>"

	dat += "<br>"
	dat += player_setup.header()
	dat += "<br><HR></center>"
	dat += player_setup.content(user)
	return dat

/datum/preferences/proc/open_setup_window(mob/user)
	if (!SScharacter_setup.initialized)
		return
	popup = new (user, "preferences_browser", "Character Setup", 1200, 800, src)
	var/content = {"
	<script type='text/javascript'>
		function update_content(data){
			document.getElementById('content').innerHTML = data;
		}
	</script>
	<div id='content'>[get_content(user)]</div>
	"}
	popup.set_content(content)
	popup.open()

/datum/preferences/proc/update_setup_window(mob/user)
	send_output(user, url_encode(get_content(user)), "preferences_browser.browser:update_content")

/datum/preferences/proc/process_link(mob/user, list/href_list)

	if(!user)	return
	if(isliving(user)) return

	if(href_list["preference"] == "open_whitelist_forum")
		if(config.forum_url)
			send_link(user, config.forum_url)
		else
			to_chat(user, SPAN_DANGER("The forum URL is not set in the server configuration."))
			return
	update_setup_window(usr)
	return 1

/datum/preferences/Topic(href, list/href_list)
	if(..())
		return 1

	if (href_list["close"])
		popup = null

	. = 1

	if(href_list["save"])
		save_preferences()
		save_character()
	else if(href_list["reload"])
		load_preferences()
		load_character()
		sanitize_preferences()
	else if(href_list["load"])
		if(!IsGuestKey(usr.key))
			open_load_dialog(usr, href_list["details"])
	else if (href_list["order_prefs"])
		open_prefs_ordering_panel(usr)
	else if(href_list["changeslot"])
		load_character(text2num(href_list["changeslot"]))
		sanitize_preferences()
		close_load_dialog(usr)

		if (winget(usr, "preferences_browser", "is-visible") == "true")
			open_setup_window(usr)

	else if(href_list["resetslot"])
		if(real_name != input("This will reset the current slot. Enter the character's full name to confirm."))
			. = 0
		else
			load_character(SAVE_RESET)
			sanitize_preferences()
	else if(href_list["addslot"])
		if(length(slot_priority_list) < config.maximum_queued_characters)
			var/datum/preferences_slot/new_slot = new()
			new_slot.slot = text2num(href_list["addslot"])
			load_slot(new_slot)
			slot_priority_list.Add(new_slot)
			save_preferences()
	else if(href_list["removeslot"])
		var/slotnum = text2num(href_list["removeslot"])
		for(var/datum/preferences_slot/slot in slot_priority_list)
			if(slot.slot == slotnum)
				slot_priority_list.Remove(slot)
		save_preferences()
	else if(href_list["moveslotup"])
		var/slot = text2num(href_list["moveslotup"])
		if(slot != 1)
			slot_priority_list.Swap(slot, slot - 1)
		save_preferences()
	else if(href_list["moveslotdown"])
		var/slot = text2num(href_list["moveslotdown"])
		if(slot != length(slot_priority_list))
			slot_priority_list.Swap(slot, slot + 1)
		save_preferences()
	else if (href_list["show_preferences_loaded"])
		load_character(text2num(href_list["show_preferences_loaded"]))
		open_setup_window(usr)
	else
		. = 0

	if(href_list["refresh"])
		if (istype(client.mob, /mob/new_player))
			var/mob/new_player/M = client.mob
			M.new_player_panel()
	if(href_list["refreshslots"] && panel?.title == "Character Priorities")
		open_prefs_ordering_panel(usr)

	update_setup_window(usr)

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, is_preview_copy = FALSE)
	// Sanitizing rather than saving as someone might still be editing when copy_to occurs.
	player_setup.sanitize_setup()
	character.set_species(species)

	character.fully_replace_character_name(real_name)

	character.gender = gender
	character.trans_body_type = trans_body_type
	character.pronouns = pronouns
	character.age = age
	character.b_type = b_type

	// Vocal chirps (vocal_chirps.dm) -- a physical trait, so this copy at spawn is the ONLY path onto the mob.
	// Deliberately not part of the live-sync helpers in preferences_tgui.dm: editing these mid-round should do
	// nothing until the next spawn.
	character.vocal_chirp_id = vocal_chirp_id
	character.vocal_chirp_speed = vocal_chirp_speed
	character.vocal_chirp_pitch = vocal_chirp_pitch
	character.vocal_chirp_variance = vocal_chirp_variance

	character.eye_color = eye_color

	character.head_hair_style = head_hair_style
	character.head_hair_color = head_hair_color

	character.facial_hair_style = facial_hair_style
	character.facial_hair_color = facial_hair_color

	character.skin_color = skin_color

	character.skin_tone = skin_tone
	character.base_skin = base_skin
	character.leg_type = leg_type

	// Replace any missing limbs.
	for(var/name in BP_ALL_LIMBS)
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(!O && organ_data[name] != "amputated")
			var/list/organ_data = character.species.has_limbs[name]
			if(!islist(organ_data)) continue
			var/limb_path = organ_data["path"]
			O = new limb_path(character)

	// Destroy/cyborgize organs and limbs. The order is important for preserving low-level choices for robolimb sprites being overridden.
	for(var/name in BP_BY_DEPTH)
		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(!O)
			continue
		O.status = 0
		O.model = null
		if(status == "amputated")
			character.organs_by_name[O.organ_tag] = null
			character.organs -= O
			if(O.children) // This might need to become recursive.
				for(var/obj/item/organ/external/child in O.children)
					character.organs_by_name[child.organ_tag] = null
					character.organs -= child
					qdel(child)
			qdel(O)
		else if(status == "cyborg")
			if(rlimb_data[name])
				O.robotize(rlimb_data[name])
			else
				O.robotize()
		else //normal organ
			O.force_icon = initial(O.force_icon)
			O.SetName(initial(O.name))
			O.desc = initial(O.desc)

	//For species that don't care about your silly prefs
	character.species.handle_limbs_setup(character)
	if(!is_preview_copy)
		for(var/name in list(BP_HEART,BP_EYES,BP_BRAIN,BP_LUNGS,BP_LIVER,BP_KIDNEYS,BP_STOMACH))
			var/status = organ_data[name]
			if(!status)
				continue
			var/obj/item/organ/I = character.internal_organs_by_name[name]
			if(I)
				if(status == "assisted")
					I.mechassist()
				else if(status == "mechanical")
					I.robotize()

	QDEL_NULL_LIST(character.worn_underwear)
	character.worn_underwear = list()

	for(var/underwear_category_name in all_underwear)
		var/datum/category_group/underwear/underwear_category = GLOB.underwear.categories_by_name[underwear_category_name]
		if(underwear_category)
			var/underwear_item_name = all_underwear[underwear_category_name]
			var/datum/category_item/underwear/UWD = underwear_category.items_by_name[underwear_item_name]
			var/metadata = all_underwear_metadata[underwear_category_name]
			var/obj/item/underwear/UW = UWD.create_underwear(character, metadata)
			if(UW)
				UW.ForceEquipUnderwear(character, FALSE)
		else
			all_underwear -= underwear_category_name

	character.backpack_setup = new(backpack, backpack_metadata["[backpack]"])

	for(var/N in character.organs_by_name)
		var/obj/item/organ/external/O = character.organs_by_name[N]
		O.markings.Cut()

	for(var/limb_slot in body_markings)
		var/list/limb_markings = body_markings[limb_slot]
		for(var/M in limb_markings)
			var/datum/sprite_accessory/marking/mark_datum = GLOB.body_marking_styles_list[M]
			if(!mark_datum)
				continue
			var/list/mark_data = limb_markings[M]

			for(var/BP in mark_datum.body_parts)
				var/obj/item/organ/external/O = character.organs_by_name[BP]
				if (O)
					O.markings[mark_datum] = mark_data.Copy()

	for(var/obj/item/organ/internal/mutant/organ in character.internal_organs.Copy())
		// The preview mannequin (get_mannequin(), 05_preview.dm) is a single long-lived mob reused across every
		// preview refresh, so this loop's `organ` can be the SAME instance copy_to() touched last time -- unlike a
		// fresh round-start spawn, is_aroused (internal/_mutant.dm) can already be TRUE here from a previous
		// "Naked (Aroused)" preview. Resetting it unconditionally means the style/underlying_sprite_datum resolved
		// a few lines down (and this proc's own update_body() calls further below) are never briefly computed
		// against a stale arousal state -- apply_preview_arousal() (05_preview.dm), which runs right after copy_to()
		// returns, is solely responsible for setting it back to TRUE when the "Naked (Aroused)" preview is active.
		// A no-op for a real spawn, where organs are freshly created and already default FALSE.
		organ.is_aroused = FALSE
		var/list/choice = mutant_organs[organ.organ_tag]
		var/organ_enabled = islist(choice) && choice["enabled"]
		// Safety net for stale saved data (e.g. Body Type changed after a mismatched category was already
		// enabled) -- Male never gets Breasts/Vagina, Female never gets Penis/Testicles, matching the same
		// organ_category_matches_gender() gate the TGUI editor itself already enforces.
		if(organ_enabled && organ.is_genital && !organ_category_matches_gender(organ.organ_tag))
			organ_enabled = FALSE
		// A mandatory organ (e.g. a Unathi's tail) is never opt-in, and never loses its default style to a
		// missing/"None" choice -- see is_mutant_organ_mandatory() (species_getters.dm) for why.
		var/mandatory = character.species.is_mutant_organ_mandatory(organ.organ_tag)
		if(!organ_enabled && !mandatory)
			if(is_preview_copy)
				organ.sprite_datum = null
				// BP_PENIS-specific state (underlying_sprite_datum/underlying_size) is only ever cleared by the
				// sheath-override block further down, which this branch skips entirely -- without this, a stale
				// value from an earlier enabled+aroused state lingers on the reused preview mannequin, confusing
				// anything that inspects the organ (e.g. get_effective_sprite_datum()) while it's disabled.
				if(organ.organ_tag == BP_PENIS)
					var/obj/item/organ/internal/mutant/penis/penis_organ = organ
					penis_organ.underlying_sprite_datum = null
					penis_organ.underlying_size = null
			else
				qdel(organ) // player never opted in via this category's toggle -- they don't gain the organ at all
			continue
		if(islist(choice))
			var/list/style_list = character.species.get_mutant_styles(organ.organ_tag, allow_noncanon_bodyparts)
			var/datum/sprite_accessory/mutant/resolved_style = (islist(style_list) && choice["style"]) ? style_list[choice["style"]] : null
			if(mandatory)
				if(!resolved_style && islist(style_list) && organ.default_style_name)
					resolved_style = style_list[organ.default_style_name]
				if(resolved_style)
					organ.sprite_datum = resolved_style
			else if(!resolved_style && organ_enabled && organ.is_genital && choice["style"] != "None")
				// The player's saved style choice is no longer valid for their current species/gender/canon
				// settings (e.g. a species restriction added after they picked it, or Body Type changed) --
				// falls back to a sensible default instead of silently clearing sprite_datum to null, which
				// would make an enabled category just stop rendering entirely rather than showing *something*.
				// Deliberately NOT requiring choice["style"] to be truthy here (only excluding the literal "None"
				// case) -- tgui_sanitize_mutant_organs() clears an invalid style to null, not to an invalid string,
				// so a null choice["style"] on an enabled genital organ means "needs a default", same as any other
				// unresolvable value. Missing this was the actual bug behind organs going invisible on a loaded
				// (not freshly-created) character: sanitize correctly nulled the stale style, but this fallback's
				// old truthy check then skipped recovering it, leaving sprite_datum null with no way to self-heal.
				var/fallback_style_name = pick_default_genital_style(organ.organ_tag, style_list)
				organ.sprite_datum = fallback_style_name ? style_list[fallback_style_name] : null
			else
				organ.sprite_datum = resolved_style // null (eg "None", or an invalid cross-species style) clears the organ's style
			if(islist(choice["colors"]))
				organ.colors = choice["colors"].Copy()
			if(!isnull(choice["size"]))
				organ.size = choice["size"]
			else
				// Player enabled this category without ever touching its size slider -- fall back to the
				// category's own default rather than leaving organ.size null, which would make
				// build_colored_icon() look for a bare "[icon_state]_s" state that doesn't exist for any
				// size-driven category (only "[icon_state][N]_s" states are baked into these .dmi files).
				var/list/meta = get_mutant_category_meta(organ.organ_tag)
				if(meta && !isnull(meta["size_default"]))
					organ.size = meta["size_default"]
			// "Penis Sheath" (Penis only): overrides the normally-resolved shape+size entirely with the fixed
			// Sheath/Slit sprite when active, regardless of which shape is otherwise selected -- matches the
			// original pasted design's separate penis_sheath preference, not a shape choice (see
			// [[baystation12soyh_genitals_port_plan]]). Looked up directly from the raw GLOB registry, not
			// species.get_mutant_styles(), since Sheath/Slit (and species-specific aliases like Teshari's
			// "Cloaca") are hidden_from_picker there on purpose. force_male_sheath_mode (species.dm) overrides
			// whatever the player picked when this species requires it for males -- e.g. Unathi/GAS/Vox/Skrell
			// males are always Slit -- unless Allow Non-Canon Bodyparts is on.
			if(organ.organ_tag == BP_PENIS)
				var/obj/item/organ/internal/mutant/penis/penis_organ = organ
				var/effective_sheath_mode = islist(choice) ? choice["sheath_mode"] : null
				if(!allow_noncanon_bodyparts && character.species.force_male_sheath_mode && character.gender == MALE)
					effective_sheath_mode = character.species.force_male_sheath_mode
				var/datum/sprite_accessory/mutant/sheath_style = effective_sheath_mode ? GLOB.mutant_penis_styles_list[effective_sheath_mode] : null
				if(sheath_style)
					// Preserve the shape+size just resolved above (before overwriting it) so
					// get_effective_sprite_datum() (_mutant.dm/mutant_penis.dm) can reveal it once fully
					// aroused -- matches Bubberstation's own real behavior of dropping the sheath/slit sprite
					// entirely at full arousal in favor of the underlying shape's own erect state.
					penis_organ.underlying_sprite_datum = organ.sprite_datum
					penis_organ.underlying_size = organ.size
					organ.sprite_datum = sheath_style
					organ.size = null
				else
					// Not in Sheath/Slit mode (any more) -- clear any stale reference from a previous copy_to()
					// call so get_effective_sprite_datum() doesn't reveal a shape that's no longer relevant.
					penis_organ.underlying_sprite_datum = null
					penis_organ.underlying_size = null

	character.force_update_limbs()
	character.update_mutations(0)
	character.update_body(0)
	character.update_underwear(0)
	character.update_hair(0)
	character.update_icons()

	if(is_preview_copy)
		return

	for(var/token in cultural_info)
		character.set_cultural_value(token, cultural_info[token], defer_language_update = TRUE)
	character.update_languages()
	for(var/lang in alternate_languages)
		character.add_language(lang, alternate_languages[lang])

	character.public_record = public_record
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	character.headshot_url = headshot_url
	character.headshot_nsfw_url = headshot_nsfw_url
	character.art_reference_url = art_reference_url
	character.art_ref_nsfw = art_ref_nsfw
	character.headshot_ai_generated = headshot_ai_generated
	character.headshot_nsfw_ai_generated = headshot_nsfw_ai_generated
	character.art_reference_ai_generated = art_reference_ai_generated
	character.ooc_notes = ooc_notes

	character.master_erp_preferences = master_erp_preferences
	character.show_in_directory = show_in_directory
	// Dating Preferences are locked to their nearest "off" value when Enable Sexual Content is off, matching the
	// same spawn-time-only semantics as the genital organs above (never mutates the player's own saved pref.*
	// fields -- only what gets written onto the spawned mob -- so re-enabling later restores whatever they'd set).
	var/erp_on = !config.disable_erp_preferences && master_erp_preferences
	character.attraction = erp_on ? attraction : "Unset"
	character.display_gender = display_gender
	character.emote_length = erp_on ? emote_length : "No Preference"
	character.approach_pref = erp_on ? approach_pref : "Unset"
	character.furry_pref = erp_on ? furry_pref : "No ERP"
	character.scalie_pref = erp_on ? scalie_pref : "No ERP"
	character.other_pref = erp_on ? other_pref : "No ERP"
	character.demihuman_pref = erp_on ? demihuman_pref : "No ERP"
	character.human_pref = erp_on ? human_pref : "No ERP"
	character.character_ad = character_ad
	character.erp_status = erp_on ? erp_status : "No"
	character.erp_status_nc = erp_on ? erp_status_nc : "No"
	character.erp_status_v = erp_on ? erp_status_v : "No"
	character.erp_status_hypno = erp_on ? erp_status_hypno : "No"
	character.erp_free_use = erp_on ? erp_free_use : FALSE
	character.can_knot_partners = erp_on ? can_knot_partners : FALSE
	character.mechanical_erp = erp_on ? mechanical_erp : FALSE
	character.custom_species = custom_species
	character.custom_species_lore = custom_species_lore
	character.character_flavor_text = character_flavor_text
	character.flavor_text = character_flavor_text
	character.flavor_text_nsfw = flavor_text_nsfw
	character.show_nsfw_flavor_text = erp_on ? show_nsfw_flavor_text : "Never"

	if(LAZYLEN(picked_traits))
		for (var/picked_type as anything in picked_traits)
			var/singleton/trait/selected = GET_SINGLETON(picked_type)
			if (!selected || !istype(selected))
				continue
			if (length(selected.metaoptions))
				var/list/temp_list = picked_traits[picked_type]
				for (var/meta_option in temp_list)
					character.SetTrait(picked_type, temp_list[meta_option], meta_option)
			else
				character.SetTrait(picked_type, picked_traits[picked_type])

	if(LAZYLEN(character.descriptors))
		for(var/entry in body_descriptors)
			character.descriptors[entry] = body_descriptors[entry]

	if(!character.isSynthetic())
		character.set_nutrition(rand(140,360))
		character.set_hydration(rand(140,360))

/datum/preferences/proc/open_load_dialog(mob/user, details)
	var/dat  = list()
	dat += "<body>"
	dat += "<tt><center>"

	dat += "<b>Select a character slot to load</b><hr>"
	for(var/i = 1 to config.character_slots)
		var/name = slot_names?[get_slot_key(i)]
		if (!name)
			name = "Character [i]"
		if (i == default_slot)
			name = "<b>[name]</b>"
		dat += "<a href='byond://?src=\ref[src];changeslot=[i];[details?"details=1":""];refresh=1'>[name]</a><br>"

	dat += "<hr>"
	dat += "</center></tt>"
	panel = new(user, "Character Slots", "Character Slots", 300, 390, src)
	panel.set_content(jointext(dat,null))
	panel.open()

/datum/preferences/proc/close_load_dialog(mob/user)
	if(panel)
		panel.close()
		panel = null
	close_browser(user, "window=saves")

/datum/preferences/proc/open_prefs_ordering_panel(mob/user)
	if (!client)
		return
	if (!SScharacter_setup.initialized)
		return
	var/list/dat = list()
	dat += "<div align='center'><b>Select your character priorities (up to [config.maximum_queued_characters])</b><hr>"

	dat += "<div align='right' style='width:45%;float:left;'><b>Inactive</b><br>"
	for(var/i = 1 to config.character_slots)
		var/active = FALSE
		for(var/datum/preferences_slot/slot in slot_priority_list)
			if(slot.slot == i)
				active = TRUE
				break
		if(!active)
			var/name = slot_names?[get_slot_key(i)]
			if (!name)
				name = "Character [i]"
			dat += "<a href='byond://?src=\ref[src];show_preferences_loaded=[i]'>[name]</a>"
			if(length(slot_priority_list) < config.maximum_queued_characters)
				dat += "<a href='byond://?src=\ref[src];addslot=[i];refreshslots=1;refresh=1'>&gt;</a>"
			dat += "<br>"
	dat += "</div><div style='width:10%;float:center;'>   </div>"
	dat += "<div align='left' style='width:45%;float:right;'><b>Active</b><br>"
	for(var/i = 1 to length(slot_priority_list))
		var/datum/preferences_slot/pref = client.prefs.slot_priority_list[i]
		if(length(slot_priority_list) != 1)
			dat += "<a href='byond://?src=\ref[src];removeslot=[pref.slot];refreshslots=1;refresh=1'>&lt;</a>"
		var/name = slot_names?[get_slot_key(pref.slot)]
		if (!name)
			name = "Character [i]"
		dat += "<a href='byond://?src=\ref[src];show_preferences_loaded=[i]'>[name]</a>"
		if(i != 1)
			dat += "<a href='byond://?src=\ref[src];moveslotup=[i];refreshslots=1;refresh=1'>&uarr;</a>"
		if(i != length(slot_priority_list))
			dat += "<a href='byond://?src=\ref[src];moveslotdown=[i];refreshslots=1;refresh=1'>&darr;</a>"
		dat += "<br>"
	dat += "</div></div>"

	panel = new(user, "Character Priorities", "Character Priorities", 350, 390, src)
	panel.set_content(dat.Join())
	panel.open()

/datum/preferences/proc/selected_jobs_titles(priority = JOB_PRIORITY_PICKED)
	. = list()
	if (priority & JOB_PRIORITY_HIGH)
		. |= job_high
	if (priority & JOB_PRIORITY_MEDIUM)
		. |= job_medium
	if (priority & JOB_PRIORITY_LOW)
		. |= job_low

/datum/preferences/proc/selected_jobs_list(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/title in selected_jobs_titles(priority))
		var/datum/job/job = SSjobs.get_by_title(title)
		if (!job)
			continue
		. += job

/datum/preferences/proc/selected_jobs_assoc(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/title in selected_jobs_titles(priority))
		var/datum/job/job = SSjobs.get_by_title(title)
		if (!job)
			continue
		.[title] = job

/datum/preferences/proc/selected_branches_list(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/datum/job/job in selected_jobs_list(priority))
		var/name = branches[job.title]
		if (!name)
			continue
		. |= GLOB.mil_branches.get_branch(name)

/datum/preferences/proc/selected_branches_assoc(priority = JOB_PRIORITY_PICKED)
	. = list()
	for (var/datum/job/job in selected_jobs_list(priority))
		var/name = branches[job.title]
		if (!name || .[name])
			continue
		.[name] = GLOB.mil_branches.get_branch(name)

/datum/preferences/proc/for_each_selected_job(datum/callback/callback, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_jobs_assoc(priority)
	for (var/title in priority)
		var/datum/job/job = priority[title]
		.[title] = invoke(callback, job)

/datum/preferences/proc/for_each_selected_job_multi(list/callbacks, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_jobs_assoc(priority)
	for (var/callback in callbacks)
		. += for_each_selected_job(callback, priority)

/datum/preferences/proc/for_each_selected_branch(datum/callback/callback, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_branches_assoc(priority)
	for (var/name in priority)
		var/datum/mil_branch/branch = priority[name]
		.[name] = invoke(callback, branch)

/datum/preferences/proc/for_each_selected_branch_multi(list/callbacks, priority = JOB_PRIORITY_LIKELY)
	. = list()
	if (!islist(priority))
		priority = selected_branches_assoc(priority)
	for (var/callback in callbacks)
		. += for_each_selected_branch(callback, priority)
