/datum/unit_test/language_groups_shall_be_cross_wired
	name = "LANGUAGE - Regional Variants Shall Understand Their Siblings"

// Mutual intelligibility between variants is wired at runtime by wire_language_groups() rather than written into
// each datum by hand, so nothing in the language definitions themselves would reveal it silently failing to run.
/datum/unit_test/language_groups_shall_be_cross_wired/start_test()
	var/fails = 0
	var/checked = 0

	for(var/lang_name in all_languages)
		var/datum/language/spoken = all_languages[lang_name]
		if(!spoken.language_group || spoken.is_abstract())
			continue
		for(var/datum/language/known in get_language_group_members(spoken))
			if(known == spoken)
				continue
			checked++
			var/wired = LAZYACCESS(spoken.partial_understanding, known.name)
			if(wired != LANGUAGE_GROUP_UNDERSTANDING)
				fails++
				log_bad("[spoken.name] should be understood at [LANGUAGE_GROUP_UNDERSTANDING]% by speakers of [known.name], got '[wired]'.")

	if(!checked)
		fail("No language variants found to check -- either every group lost its members, or is_abstract() is now excluding them all.")
	else if(fails)
		fail("[fails] missing cross-variant comprehension entr\s.")
	else
		pass("All [checked] variant pairings are wired for mutual comprehension.")
	return 1

/datum/unit_test/language_variants_shall_be_distinct
	name = "LANGUAGE - Regional Variants Shall Be Distinguishable"

// Variants exist to be told apart in chat and in character setup. Two sharing a flag or a shorthand would be
// indistinguishable to a player, which defeats the point of splitting them.
/datum/unit_test/language_variants_shall_be_distinct/start_test()
	var/fails = 0
	var/list/seen_tags = list()
	var/list/seen_shorthands = list()

	for(var/lang_name in all_languages)
		var/datum/language/L = all_languages[lang_name]
		if(!L.language_group || L.is_abstract())
			continue

		if(!L.variant_name)
			fails++
			log_bad("[L.name] is a regional variant with no variant_name to label it in character setup.")

		if(L.tag_icon)
			if(seen_tags[L.tag_icon])
				fails++
				log_bad("[L.name] shares its chat flag '[L.tag_icon]' with [seen_tags[L.tag_icon]].")
			else
				seen_tags[L.tag_icon] = L.name
		if(seen_shorthands[L.shorthand])
			fails++
			log_bad("[L.name] shares its shorthand '[L.shorthand]' with [seen_shorthands[L.shorthand]].")
		else
			seen_shorthands[L.shorthand] = L.name

	if(fails)
		fail("[fails] indistinguishable language variant\s.")
	else
		pass("All regional variants carry a distinct label, shorthand and flag.")
	return 1

/datum/unit_test/language_proficiency_ladder_shall_be_monotonic
	name = "LANGUAGE - Proficiency Ladder Shall Increase With Level"

// The comprehension and fluency curves are plain lookup tables, and a typo in one would be invisible in play beyond
// "something feels off" -- a B2 speaker quietly being harder to follow than an A1 one, say.
/datum/unit_test/language_proficiency_ladder_shall_be_monotonic/start_test()
	var/fails = 0
	var/last_comprehension = -1
	var/last_fluency = -1

	for(var/level = LANGUAGE_LEVEL_MIN to LANGUAGE_LEVEL_MAX)
		var/comprehension = language_level_comprehension(level)
		var/fluency = language_level_fluency(level)

		// Non-decreasing rather than strictly increasing: C1 and C2 are both full comprehension by design, since the
		// difference between advanced and native is not about how much of a sentence you catch.
		if(comprehension < last_comprehension)
			fails++
			log_bad("Comprehension at [language_level_name(level)] ([comprehension]) is worse than the level below ([last_comprehension]).")
		if(fluency < last_fluency)
			fails++
			log_bad("Fluency at [language_level_name(level)] ([fluency]) is worse than the level below ([last_fluency]).")
		if(comprehension > LANGUAGE_COMPREHENSION_FULL || fluency > LANGUAGE_COMPREHENSION_FULL)
			fails++
			log_bad("[language_level_name(level)] exceeds full comprehension (c:[comprehension] f:[fluency]).")

		last_comprehension = comprehension
		last_fluency = fluency

	if(language_level_comprehension(LANGUAGE_LEVEL_C2) != LANGUAGE_COMPREHENSION_FULL)
		fails++
		log_bad("C2 must be full comprehension, or native speakers would hear their own tongue scrambled.")
	if(language_level_fluency(LANGUAGE_LEVEL_C2) != LANGUAGE_COMPREHENSION_FULL)
		fails++
		log_bad("C2 must be full fluency, or native speakers would be misheard by everyone.")
	if(language_level_comprehension(LANGUAGE_LEVEL_NONE) || language_level_fluency(LANGUAGE_LEVEL_NONE))
		fails++
		log_bad("An unknown language must grant no comprehension or fluency of its own.")

	if(fails)
		fail("[fails] problem\s with the proficiency ladder.")
	else
		pass("Comprehension and fluency both rise monotonically and cap at full.")
	return 1

/datum/unit_test/language_levels_shall_survive_sanitization
	name = "LANGUAGE - Stored Proficiency Shall Survive Sanitization"

// Levels arrive as JSON numbers from savefiles and TGUI, and as text from the legacy savefile reader. An earlier
// draft of this code ran every value through text2num(), which would have turned each valid number into null and
// quietly reset every character to C2 on their next save. Pin the behaviour down.
/datum/unit_test/language_levels_shall_survive_sanitization/start_test()
	var/fails = 0

	for(var/level = LANGUAGE_LEVEL_MIN to LANGUAGE_LEVEL_MAX)
		if(sanitize_language_level(level) != level)
			fails++
			log_bad("Numeric level [level] did not survive sanitization (got [sanitize_language_level(level)]).")
		if(sanitize_language_level("[level]") != level)
			fails++
			log_bad("Text level \"[level]\" did not survive sanitization (got [sanitize_language_level("[level]")]).")

	if(sanitize_language_level(null) != LANGUAGE_LEVEL_C2)
		fails++
		log_bad("A missing level should default to fluent, so pre-existing characters are unaffected.")
	if(sanitize_language_level("nonsense") != LANGUAGE_LEVEL_C2)
		fails++
		log_bad("An unparseable level should fall back to the default rather than to zero.")
	if(sanitize_language_level(999) != LANGUAGE_LEVEL_MAX || sanitize_language_level(-5) != LANGUAGE_LEVEL_MIN)
		fails++
		log_bad("Out-of-range levels should clamp into the valid ladder.")

	if(fails)
		fail("[fails] problem\s with proficiency sanitization.")
	else
		pass("Proficiency levels survive sanitization from every source that supplies them.")
	return 1
