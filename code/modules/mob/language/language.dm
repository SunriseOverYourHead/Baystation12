#define SCRAMBLE_CACHE_LEN 20

/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "base language"  // Fluff name of language if any.
	var/desc = "You should not have this language." // Short description for 'Check Languages'.
	var/speech_verb = "says"          // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"             // Used when sentence ends in a ?
	var/exclaim_verb = "exclaims"     // Used when sentence ends in a !
	var/whisper_verb                  // Optional. When not specified speech_verb + quietly/softly is used instead.
	var/signlang_verb = list("signs", "gestures") // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	var/colour = "body"               // CSS style to use for strings in this language.
	var/key = ""                     // Character used to speak in language eg. :o for Unathi.
	var/flags = 0                     // Various language flags.
	var/native                        // If set, non-native speakers will have trouble speaking.
	var/list/syllables                // Used when scrambling text for a non-speaker.
	var/list/space_chance = 55        // Likelihood of getting a space in the random scramble string
	var/machine_understands = 1       // Whether machines can parse and understand this language
	var/shorthand = "???"			  // Shorthand that shows up in chat for this language.
	/// Icon state in icons/language_tags.dmi, shown in chat instead of the shorthand for viewers who have chat
	/// tag icons enabled. Null means this language has no badge drawn yet and always falls back to `shorthand`.
	var/tag_icon
	var/list/partial_understanding				  // List of languages that can /somehwat/ understand it, format is: name = chance of understanding a word
	var/warning = ""
	var/hidden_from_codex			  // If it should not show up in Codex
	var/category = /datum/language    // Used to point at root language types that shouldn't be visible
	var/has_written_form = FALSE
	/// Languages sharing a non-null group are regional variants of one tongue -- English (GB) and English (US), say.
	/// They are wired to understand each other at LANGUAGE_GROUP_UNDERSTANDING by wire_language_groups(), they share
	/// a single speech prefix key, and character setup presents them as one entry with a variant picker.
	var/language_group
	/// The variant's label within its group, e.g. "Britain". Only meaningful when `language_group` is set; setup
	/// falls back to `name` without one.
	var/variant_name
	/// Set on exactly one member of each group: the variant that owns the group's entry in `language_keys`, and so
	/// the one a bare prefix resolves to before resolve_spoken_variant() swaps in whichever variant you actually know.
	var/is_group_primary = FALSE

/// The compact in-chat marker for this language: a badge image where one has been drawn and the viewer wants tag
/// icons, otherwise the plain "(SHORTHAND)" text this has always printed. Both forms say the same thing, so the
/// fallback is a real fallback rather than a degraded one -- which is also what lets languages be given badges
/// piecemeal instead of all at once.
/datum/language/proc/get_chat_tag(client/viewer)
	if(!tag_icon)
		return "([shorthand])"
	return create_text_tag(tag_icon, "([shorthand])", viewer, 'icons/language_tags.dmi')

/// TRUE for root types that exist only to be inherited from -- /datum/language/human, a variant group's shared
/// parent -- rather than to be spoken. Follows the convention already used by the codex: a root is its own category.
/datum/language/proc/is_abstract()
	return type == category

/datum/language/proc/can_be_spoken_properly_by(mob/speaker)
	return TRUE

/datum/language/proc/muddle(message)
	return message

/datum/language/proc/get_random_name(gender, name_count=2, syllable_count=4, syllable_divisor=2)
	if(!syllables || !length(syllables))
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

	var/full_name = ""
	var/new_name = ""

	for(var/i = 0;i<name_count;i++)
		new_name = ""
		for(var/x = rand(floor(syllable_count/syllable_divisor),syllable_count);x>0;x--)
			new_name += pick(syllables)
		full_name += " [capitalize(lowertext(new_name))]"

	return "[trimtext(full_name)]"

/datum/language
	var/list/scramble_cache = list()

/**
 * Degrades `input` word by word for a listener who does not fully understand this language.
 *
 * Each word independently survives verbatim with `understand_chance` probability and is otherwise replaced with
 * syllable gibberish, so a partial understander reads a mix of real and invented words rather than a wall of noise.
 *
 * `base_understanding` is the listener's own proficiency in this language expressed as a percentage (see
 * /mob/proc/get_speech_comprehension). Credit from `partial_understanding` -- knowing a related tongue -- stacks on
 * top of it, which is what lets an A1 Spanish speaker who is also fluent in Iberian follow along nearly perfectly.
 */
/datum/language/proc/scramble(input, list/known_languages, base_understanding = 0)

	var/understand_chance = base_understanding
	for(var/datum/language/L in known_languages)
		if(LAZYACCESS(partial_understanding, L.name))
			understand_chance += partial_understanding[L.name]

	var/list/words = splittext(input, " ")
	var/list/scrambled_text = list()
	var/new_sentence = 0
	for(var/w in words)
		var/nword = "[w] "
		var/input_ending = copytext(w, -1)
		var/ends_sentence = findtext(".?!",input_ending)
		if(!prob(understand_chance))
			nword = scramble_word(w)
			if(new_sentence)
				nword = capitalize(nword)
				new_sentence = FALSE
			if(ends_sentence)
				nword = trimtext(nword)
				nword = "[nword][input_ending] "

		if(ends_sentence)
			new_sentence = TRUE

		scrambled_text += nword

	. = jointext(scrambled_text, null)
	. = capitalize(.)
	. = trimtext(.)

/datum/language/proc/scramble_word(input)
	if(!syllables || !length(syllables))
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	if(input in scramble_cache)
		var/n = scramble_cache[input]
		scramble_cache -= input
		scramble_cache[input] = n
		return n

	var/input_size = length(input)
	var/scrambled_text = ""
	var/capitalize = 0

	while(length(scrambled_text) < input_size)
		var/next = pick(syllables)
		if(capitalize)
			next = capitalize(next)
			capitalize = 0
		scrambled_text += next
		var/chance = rand(100)
		if(chance <= 5)
			scrambled_text += ". "
			capitalize = 1
		else if(chance > 5 && chance <= space_chance)
			scrambled_text += " "

	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = scrambled_text
	if(length(scramble_cache) > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, length(scramble_cache)-SCRAMBLE_CACHE_LEN-1)

	return scrambled_text

/datum/language/proc/format_message(message, verb)
	return "[verb], [SPAN_CLASS("message", "[SPAN_CLASS(colour, "\"[capitalize(message)]\"")]")]"

/datum/language/proc/format_message_plain(message, verb)
	return "[verb], \"[capitalize(message)]\""

/datum/language/proc/format_message_radio(message, verb)
	return "[verb], [SPAN_CLASS(colour, "\"[capitalize(message)]\"")]"

/datum/language/proc/get_talkinto_msg_range(message)
	// if you yell, you'll be heard from two tiles over instead of one
	return (copytext(message, -1) == "!") ? 2 : 1

/datum/language/proc/broadcast(mob/living/speaker,message,speaker_mask)
	log_say("[key_name(speaker)] : ([name]) [message]")

	if(!speaker_mask) speaker_mask = speaker.name
	message = format_message(message, get_spoken_verb(message))

	for(var/mob/player in GLOB.player_list)
		player.hear_broadcast(src, speaker, speaker_mask, message)

/mob/proc/hear_broadcast(datum/language/language, mob/speaker, speaker_name, message)
	if((language in languages) && language.check_special_condition(src))
		var/msg = "<i>[SPAN_CLASS("game say", "[language.name], [SPAN_CLASS("name", "[speaker_name]")] [message]")]</i>"
		to_chat(src, msg)

/mob/new_player/hear_broadcast(datum/language/language, mob/speaker, speaker_name, message)
	return

/mob/observer/ghost/hear_broadcast(datum/language/language, mob/speaker, speaker_name, message)
	if(speaker.name == speaker_name || antagHUD)
		to_chat(src, "<i>[SPAN_CLASS("game say", "[language.name], [SPAN_CLASS("name", "[speaker_name]")] ([ghost_follow_link(speaker, src)]) [message]")]</i>")
	else
		to_chat(src, "<i>[SPAN_CLASS("game say", "[language.name], [SPAN_CLASS("name", "[speaker_name]")] [message]")]</i>")

/datum/language/proc/check_special_condition(mob/other)
	return 1

/datum/language/proc/get_spoken_verb(msg_end)
	switch(msg_end)
		if("!")
			return exclaim_verb
		if("?")
			return ask_verb
	return speech_verb

/datum/language/proc/can_speak_special(mob/speaker)
	return 1

// Language handling.
//
// `languages` is an associative list of /datum/language to proficiency level. Typed for-loops iterate an assoc
// list's keys, so `for(var/datum/language/L in languages)` and `(lang in languages)` read exactly as they did when
// this was a flat list -- only code that *writes* to it has to care about the values.
/mob/proc/add_language(language, level = LANGUAGE_LEVEL_C2)

	var/datum/language/new_language = all_languages[language]

	if(!istype(new_language))
		return 0

	// A level at or below NONE is never a meaningful request -- a mob that knows nothing of a language simply is not
	// given it -- and it is the shape a stray FALSE from an older two-argument call takes. Treat it as "unspecified"
	// and grant full fluency, which is what every caller that passes no level at all expects.
	if(!isnum(level) || level < LANGUAGE_LEVEL_MIN)
		level = LANGUAGE_LEVEL_C2
	level = min(level, LANGUAGE_LEVEL_MAX)

	// Already known: upgrade to the better of the two levels rather than refusing outright, so a culture grant can
	// promote a language the player only picked up to B1 without a second grant path silently demoting them.
	if(new_language in languages)
		if(level > languages[new_language])
			languages[new_language] = level
		return 0

	languages[new_language] = level
	return 1

/// This mob's proficiency in `L`, as a LANGUAGE_LEVEL_* constant. The universal-speech and INNATE exemptions report
/// full fluency so callers do not have to special-case them.
/mob/proc/get_language_level(datum/language/L)
	if(!istype(L))
		return LANGUAGE_LEVEL_NONE
	if(universal_speak || universal_understand || (L.flags & INNATE))
		return LANGUAGE_LEVEL_C2
	return languages[L] || LANGUAGE_LEVEL_NONE

/// Percentage of words a listener at `level` catches. The A grades are deliberately low enough to read as struggling.
/proc/language_level_comprehension(level)
	switch(level)
		if(LANGUAGE_LEVEL_A1) return 25
		if(LANGUAGE_LEVEL_A2) return 45
		if(LANGUAGE_LEVEL_B1) return 65
		if(LANGUAGE_LEVEL_B2) return 85
		if(LANGUAGE_LEVEL_C1, LANGUAGE_LEVEL_C2) return LANGUAGE_COMPREHENSION_FULL
	return 0

/// Percentage of a speaker's words that come out intelligibly at `level`. Gentler than the comprehension curve:
/// speaking badly should be usable, not useless, so even A1 gets most of a sentence across.
/proc/language_level_fluency(level)
	switch(level)
		if(LANGUAGE_LEVEL_A1) return 55
		if(LANGUAGE_LEVEL_A2) return 75
		if(LANGUAGE_LEVEL_B1) return 90
		if(LANGUAGE_LEVEL_B2, LANGUAGE_LEVEL_C1, LANGUAGE_LEVEL_C2) return LANGUAGE_COMPREHENSION_FULL
	return 0

/**
 * Coerces a stored or client-supplied proficiency into a valid LANGUAGE_LEVEL_*.
 *
 * Levels reach us from two places that disagree about type: JSON savefiles and TGUI params decode them as numbers,
 * while the legacy savefile reader and any hand-edited record hand back text. Normalising both here rather than
 * reaching for text2num() at each call site matters -- text2num() is specified for text, and quietly turning a
 * perfectly good number into null would have defaulted every character back to C2 on their next save.
 */
/proc/sanitize_language_level(level, default_level = LANGUAGE_LEVEL_C2)
	if(!isnum(level))
		level = text2num(level)
	if(!isnum(level))
		return default_level
	return clamp(round(level), LANGUAGE_LEVEL_MIN, LANGUAGE_LEVEL_MAX)

/proc/language_level_name(level)
	switch(level)
		if(LANGUAGE_LEVEL_A1) return "A1"
		if(LANGUAGE_LEVEL_A2) return "A2"
		if(LANGUAGE_LEVEL_B1) return "B1"
		if(LANGUAGE_LEVEL_B2) return "B2"
		if(LANGUAGE_LEVEL_C1) return "C1"
		if(LANGUAGE_LEVEL_C2) return "C2"
	return "None"

/proc/language_level_desc(level)
	switch(level)
		if(LANGUAGE_LEVEL_A1) return "Beginner. You catch isolated words and speak haltingly."
		if(LANGUAGE_LEVEL_A2) return "Elementary. You follow simple speech and make yourself understood with effort."
		if(LANGUAGE_LEVEL_B1) return "Intermediate. You hold a conversation, missing the occasional word."
		if(LANGUAGE_LEVEL_B2) return "Upper intermediate. You follow almost everything and speak comfortably."
		if(LANGUAGE_LEVEL_C1) return "Advanced. Fluent for every practical purpose."
		if(LANGUAGE_LEVEL_C2) return "Native or near-native. Complete command of the language."
	return "You do not know this language."

/mob/proc/remove_language(rem_language)
	var/datum/language/L = all_languages[rem_language]
	. = (L in languages)
	languages.Remove(L)

/mob/living/remove_language(rem_language)
	var/datum/language/L = all_languages[rem_language]
	if(default_language == L)
		default_language = null
	return ..()

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak(datum/language/speaking)
	if(!speaking)
		return 0

	if (only_species_language && speaking != all_languages[species_language])
		return 0

	return (speaking.can_speak_special(src) && (universal_speak || (speaking && speaking.flags & INNATE) || (speaking in src.languages)))

/mob/proc/get_language_prefix()
	return get_prefix_key(/singleton/prefix/language)

/mob/proc/is_language_prefix(prefix)
	return prefix == get_prefix_key(/singleton/prefix/language)

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b>[FONT_GIANT("Known Languages")]</b><br/><br/>"

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			dat += "<b>[L.name]([L.shorthand]) ([get_language_prefix()][L.key])</b><br/>[L.desc]<br/><br/>"

	show_browser(src, dat, "window=checklanguage")
	return

/mob/living/check_languages()
	var/dat = "<b>[FONT_GIANT("Known Languages")]</b><br/><br/>"

	if(default_language)
		dat += "Current default language: [default_language] - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/><br/>"

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			var/level = get_language_level(L)
			var/header = "<b>[L.name] ([L.shorthand]) ([get_language_prefix()][L.key]) - [language_level_name(level)]</b>"
			var/footer = "[L.desc]<br/><i>[language_level_desc(level)]</i><br/><br/>"
			if(L == default_language)
				dat += "[header] - default - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/>[footer]"
			else if (can_speak(L))
				dat += "[header] - <a href='byond://?src=\ref[src];default_lang=\ref[L]'>set default</a><br/>[footer]"
			else
				dat += "[header] - cannot speak!<br/>[footer]"

	show_browser(src, dat, "window=checklanguage")

/mob/living/OnSelfTopic(href_list, topic_status)
	if(href_list["default_lang"])
		if(href_list["default_lang"] == "reset")

			if (species_language)
				set_default_language(all_languages[species_language])
			else
				set_default_language(null)

		else
			var/datum/language/L = locate(href_list["default_lang"])
			if(L && (L in languages))
				set_default_language(L)
		check_languages()
		return TOPIC_HANDLED
	return ..()

/proc/transfer_languages(mob/source, mob/target, except_flags)
	for(var/datum/language/L in source.languages)
		if(L.flags & except_flags)
			continue
		target.add_language(L.name, source.languages[L])

/**
 * Cross-wires every regional variant of a tongue to understand its siblings, called once after all_languages is
 * populated. Doing it here rather than in the datum definitions keeps the tables from growing quadratically: adding
 * a sixth Spanish variant is one new file, not five edits to existing ones.
 *
 * Note the direction. `partial_understanding` lives on the language being *spoken* and is keyed by languages the
 * *listener* knows, so A's table is what gets consulted when A is spoken -- see /datum/language/proc/scramble.
 */
/proc/wire_language_groups()
	var/list/by_group = list()
	for(var/lang_name in all_languages)
		var/datum/language/L = all_languages[lang_name]
		if(!L.language_group || L.is_abstract())
			continue
		LAZYADD(by_group[L.language_group], L)

	for(var/group in by_group)
		var/list/members = by_group[group]
		for(var/datum/language/spoken in members)
			for(var/datum/language/known in members)
				if(spoken == known)
					continue
				LAZYSET(spoken.partial_understanding, known.name, LANGUAGE_GROUP_UNDERSTANDING)

/// Every variant of `L`'s group, `L` included. A list of one for a language that is not part of a group.
/proc/get_language_group_members(datum/language/L)
	. = list(L)
	if(!L || !L.language_group)
		return
	. = list()
	for(var/lang_name in all_languages)
		var/datum/language/other = all_languages[lang_name]
		if(other.language_group == L.language_group && !other.is_abstract())
			. += other

/**
 * Variants of one tongue share a single speech prefix, so `,e` has to mean "speak my English" rather than naming a
 * specific dialect. Given the variant a prefix literally resolved to, this returns the one this mob actually speaks:
 * the group's primary if they know it, otherwise whichever sibling they know best.
 *
 * Returns `L` unchanged for ungrouped languages and when the mob knows no member of the group -- can_speak() is
 * left to reject it, exactly as before.
 */
/mob/proc/resolve_spoken_variant(datum/language/L)
	if(!L || !L.language_group)
		return L
	if(can_speak(L))
		return L

	var/datum/language/best
	var/best_level = LANGUAGE_LEVEL_NONE
	for(var/datum/language/variant in get_language_group_members(L))
		if(!can_speak(variant))
			continue
		var/level = get_language_level(variant)
		if(!best || level > best_level)
			best = variant
			best_level = level
	return best || L

#undef SCRAMBLE_CACHE_LEN
