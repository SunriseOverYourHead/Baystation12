/mob/proc/say()
	return

/mob/verb/whisper()
	set name = "Whisper"
	set category = "IC"
	return


/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	usr.say(message)


/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"
	message = sanitize(message)
	if (!message)
		return
	if(use_me)
		usr.emote("me",usr.emote_type,message)
	else
		usr.emote(message)


/mob/proc/say_dead(message)
	communicate(/singleton/communication_channel/dsay, client, message)

/mob/proc/say_understands(mob/other,datum/language/speaking = null)

	if (src.stat == 2)		//Dead
		return 1

	//Universal speak makes everything understandable, for obvious reasons.
	else if(src.universal_speak || src.universal_understand)
		return 1

	//Languages are handled after.
	if (!speaking)
		if(!other)
			return 1
		if(other.universal_speak)
			return 1
		if(isAI(src) && ispAI(other))
			return 1
		if (istype(other, src.type) || istype(src, other.type))
			return 1
		return 0

	if(speaking.flags & INNATE)
		return 1

	//Language check. This is the *fluent* threshold, not the "do you know any of it" one -- anything below C1 is
	//handled by the graded path in get_speech_comprehension() instead of being a flat yes/no.
	return get_language_level(speaking) >= LANGUAGE_LEVEL_C1

/**
 * How much of what `other` is saying in `speaking` this mob actually catches, as a percentage.
 *
 * Two things are folded together here. The listener's own proficiency sets the ceiling, and the speaker's fluency
 * sets another: a beginner's speech comes out broken no matter how well you understand the language. The lower of
 * the two wins. Speakers are exempt from their own penalty, because you always know what you meant to say.
 *
 * Returns LANGUAGE_COMPREHENSION_FULL for every case say_understands() exempts (the dead, universal speech, INNATE
 * languages, brain worms, species that read each other) so those paths keep behaving exactly as they did.
 */
/mob/proc/get_speech_comprehension(mob/other, datum/language/speaking)
	// You always read back your own words intact, whatever your command of the language you chose to mangle them in.
	if(other == src)
		return LANGUAGE_COMPREHENSION_FULL

	var/comprehension = say_understands(other, speaking) ? LANGUAGE_COMPREHENSION_FULL : language_level_comprehension(get_language_level(speaking))

	// ismob rather than a null check: runechat routes through /atom/movable, so the "speaker" can be a megaphone or
	// another object relaying speech. Those have no proficiency of their own and impose no penalty.
	if(ismob(other) && speaking && !(speaking.flags & INNATE))
		comprehension = min(comprehension, language_level_fluency(other.get_language_level(speaking)))

	return comprehension

/mob/proc/say_quote(message, datum/language/speaking = null)
	var/ending = copytext(message, -1)
	if(speaking)
		return speaking.get_spoken_verb(ending)

	var/verb = pick(speak_emote)
	if(verb == "says") //a little bit of a hack, but we can't let speak_emote default to an empty list without breaking other things
		if(ending == "!")
			verb = pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb ="asks"
	return verb

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/mob/proc/say_test(text)
	var/ending = copytext(text, -1)
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

//parses the message mode code (e.g. :h, :w) from text, such as that supplied to say.
//returns the message mode string or null for no message mode.
//standard mode is the mode returned for the special ';' radio code.
/mob/proc/parse_message_mode(message, standard_mode="headset")
	if(length(message) >= 1 && copytext_char(message,1,2) == get_prefix_key(/singleton/prefix/radio_main_channel))
		return standard_mode

	if(length(message) >= 2)
		var/channel_prefix = copytext_char(message, 1 ,3)
		return department_radio_keys[channel_prefix]

	return null

//parses the language code (e.g. :j) from text, such as that supplied to say.
//returns the language object only if the code corresponds to a language that src can speak, otherwise null.
/mob/proc/parse_language(message)
	var/prefix = copytext_char(message,1,2)
	if(length(message) >= 1 && prefix == get_prefix_key(/singleton/prefix/audible_emote))
		return all_languages["Noise"]

	if(length(message) >= 2 && is_language_prefix(prefix))
		var/language_prefix = lowertext(copytext_char(message, 2 ,3))
		var/datum/language/L = resolve_spoken_variant(language_keys[language_prefix])
		if (can_speak(L))
			return L

	return null
