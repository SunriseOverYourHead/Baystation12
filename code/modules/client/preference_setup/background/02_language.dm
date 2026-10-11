/datum/preferences
	/// Languages the character has learned on top of whatever their culture grants, as an assoc of language name to
	/// LANGUAGE_LEVEL_*. Culture-granted languages are deliberately *not* stored here -- they are free, always
	/// native, and re-derived from cultural_info at spawn, so keeping them out stops them consuming MAX_LANGUAGES.
	var/list/alternate_languages

/// Languages that were split into regional variants after characters had already saved them. Legacy saves naming the
/// old undivided language are pointed at the group's primary variant so nobody silently loses a language they had.
/var/global/list/legacy_language_renames = list(
	"English" = LANGUAGE_HUMAN_ENGLISH_GB,
	"Spanish" = LANGUAGE_HUMAN_SPANISH_ES
)

/datum/category_item/player_setup_item/background/languages
	name = "Languages"
	sort_order = 2
	var/list/allowed_languages
	var/list/free_languages

/datum/category_item/player_setup_item/background/languages/load_character(datum/pref_record_reader/R)
	pref.alternate_languages = list()

	if(R.get_version() < 4)
		// Before proficiency levels this was a flat list of names, and knowing a language meant knowing it fully.
		var/list/legacy = R.read("language")
		if(islist(legacy))
			for(var/lang_name in legacy)
				lang_name = legacy_language_renames[lang_name] || lang_name
				pref.alternate_languages[lang_name] = LANGUAGE_LEVEL_C2
		return

	var/list/stored = R.read("language_levels")
	if(!islist(stored))
		return
	for(var/lang_name in stored)
		pref.alternate_languages[lang_name] = stored[lang_name]

/datum/category_item/player_setup_item/background/languages/save_character(datum/pref_record_writer/W)
	W.write("language_levels", pref.alternate_languages)

/datum/category_item/player_setup_item/background/languages/sanitize_character()
	if(!islist(pref.alternate_languages))
		pref.alternate_languages = list()
	sanitize_alt_languages()

/datum/category_item/player_setup_item/background/languages/content()
	. = list()
	. += "<b>Languages</b><br>"
	var/list/show_langs = get_language_text()
	if(LAZYLEN(show_langs))
		for(var/lang in show_langs)
			. += lang
	else
		. += "Your current species, faction or home system selection does not allow you to choose additional languages.<br>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/background/languages/OnTopic(href,list/href_list, mob/user)

	if(href_list["remove_language"])
		pref.alternate_languages -= href_list["remove_language"]
		return TOPIC_REFRESH

	else if(href_list["add_language"])

		if(length(pref.alternate_languages) >= MAX_LANGUAGES)
			alert(user, "You have already selected the maximum number of languages!")
			return

		sanitize_alt_languages()
		var/list/available_languages = allowed_languages - free_languages
		if(!LAZYLEN(available_languages))
			alert(user, "There are no additional languages available to select.")
		else
			var/new_lang = input(user, "Select an additional language", "Character Generation", null) as null|anything in available_languages
			if(new_lang)
				pref.alternate_languages[new_lang] = LANGUAGE_LEVEL_C2
				return TOPIC_REFRESH
	. = ..()

/datum/category_item/player_setup_item/background/languages/proc/rebuild_language_cache(mob/user)

	allowed_languages = list()
	free_languages = list()

	if(!user)
		return

	for(var/thing in pref.cultural_info)
		var/singleton/cultural_info/culture = SSculture.get_culture(pref.cultural_info[thing])
		if(istype(culture))
			var/list/langs = culture.get_spoken_languages()
			if(LAZYLEN(langs))
				for(var/checklang in langs)
					free_languages[checklang] =    TRUE
					allowed_languages[checklang] = TRUE
			if(LAZYLEN(culture.secondary_langs))
				for(var/checklang in culture.secondary_langs)
					allowed_languages[checklang] = TRUE

	for(var/thing in all_languages)
		var/datum/language/lang = all_languages[thing]
		if(user.has_admin_rights() || (!(lang.flags & RESTRICTED) && (lang.flags & WHITELISTED) && is_alien_whitelisted(user, lang)))
			allowed_languages[thing] = TRUE

/// Refreshes allowed_languages/free_languages against the current character, for callers outside this file that
/// need the gating lists (the TGUI picker) and have no preference mob of their own to pass in.
/datum/category_item/player_setup_item/background/languages/proc/refresh_language_cache()
	rebuild_language_cache(preference_mob())

/datum/category_item/player_setup_item/background/languages/proc/is_allowed_language(mob/user, datum/language/lang)
	if(!istype(lang) || lang.is_abstract())
		return FALSE
	if(isnull(allowed_languages) || isnull(free_languages))
		rebuild_language_cache(user)
	if(!user || ((lang.flags & RESTRICTED) && is_alien_whitelisted(user, lang)))
		return TRUE
	return allowed_languages[lang.name]

/datum/category_item/player_setup_item/background/languages/proc/sanitize_alt_languages()
	if(!istype(pref.alternate_languages))
		pref.alternate_languages = list()
	var/preference_mob = preference_mob()
	rebuild_language_cache(preference_mob)

	// Rebuilt rather than pruned in place: the levels are values in this list, and the old remove-and-reinsert
	// shuffle this proc used to do to order the list would have dropped every one of them.
	var/list/sanitized = list()
	for(var/lang_name in pref.alternate_languages)
		if(length(sanitized) >= MAX_LANGUAGES)
			break
		var/datum/language/lang = all_languages[lang_name]
		if(!lang || !is_allowed_language(preference_mob, lang))
			continue
		// Culture grants this one for free and always natively, so it does not belong in the learned list.
		if(free_languages[lang_name])
			continue
		sanitized[lang_name] = sanitize_language_level(pref.alternate_languages[lang_name])

	pref.alternate_languages = sanitized

/datum/category_item/player_setup_item/background/languages/proc/get_language_text()
	sanitize_alt_languages()
	for(var/lang_name in free_languages)
		LAZYADD(., "- [lang_name] (native).<br>")
	for(var/lang_name in pref.alternate_languages)
		var/datum/language/lang = all_languages[lang_name]
		LAZYADD(., "- [lang_name] \[[language_level_name(pref.alternate_languages[lang_name])]\] <a href='byond://?src=\ref[src];remove_language=[lang_name]'>Remove.</a> <span style='color:#ff0000;font-style:italic;'>[lang.warning]</span><br>")
	if(length(pref.alternate_languages) < MAX_LANGUAGES)
		var/remaining_langs = MAX_LANGUAGES - length(pref.alternate_languages)
		LAZYADD(., "- <a href='byond://?src=\ref[src];add_language=1'>add</a> ([remaining_langs] remaining)<br>")
