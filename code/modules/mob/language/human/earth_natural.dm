/*//////////////////////////////////////////////////////////////////////////////////////////////////////
	Surviving natural languages of Earth.

	The other human languages in this folder are the setting's constructed descendants of Earth speech --
	Zurich Accord Common, Yangyu, Iberian. These are the older tongues those grew out of, still spoken on Earth
	(see the Earther culture, which keeps the old nation states culturally significant) and in diaspora
	communities. The two sets are meant to coexist: a character can speak Iberian, Spanish, or both.

	English and Spanish are language *groups* rather than single languages. The type at the head of each group is
	abstract -- it carries the shared description, syllables, cross-language comprehension and speech prefix, and is
	marked as its own `category` so the codex and character setup skip it the same way they skip /datum/language/human.
	Only the regional variants beneath it are real, selectable languages. Variants understand one another at
	LANGUAGE_GROUP_UNDERSTANDING (wired automatically by wire_language_groups(), not by hand), share their group's
	speech prefix, and differ only in what flag they fly in chat.

	Their chat tags are real flags, fitted from icons/flags.dmi -- see tools/add_flag_language_tag.py.
*///////////////////////////////////////////////////////////////////////////////////////////////////////

//
// English
//

/datum/language/human/english
	name = LANGUAGE_HUMAN_ENGLISH
	desc = "The dominant lingua franca of pre-spaceflight Earth. Zurich Accord Common borrowed heavily from it, \
			and the two remain close enough that a speaker of one can usually follow the other."
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = "english"
	key = "e"
	shorthand = "Eng"
	category = /datum/language/human/english
	language_group = LANGUAGE_HUMAN_ENGLISH
	partial_understanding = list(
		LANGUAGE_HUMAN_EURO = 70,
		LANGUAGE_HUMAN_SELENIAN = 50,
		LANGUAGE_SPACER = 20
	)
	syllables = list(
		"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
		"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
		"ve", "wa", "all", "and", "are", "but", "ent", "ere", "eve", "for", "had", "hat", "hen", "her",
		"hin", "ing", "ion", "ith", "not", "one", "our", "out", "ove", "ter", "tha", "the", "thi", "tio",
		"ver", "was", "whi", "wit", "you"
	)
	has_written_form = TRUE

/datum/language/human/english/gb
	name = LANGUAGE_HUMAN_ENGLISH_GB
	variant_name = "Britain"
	desc = "English as it is still spoken in the British Isles, and the variety the Zurich Accord standardised from."
	shorthand = "Eng-GB"
	tag_icon = "eng_gb"
	is_group_primary = TRUE

/datum/language/human/english/us
	name = LANGUAGE_HUMAN_ENGLISH_US
	variant_name = "America"
	desc = "North American English. The larger of the two great branches by speaker count, and the one that followed \
			humanity off-world in the greatest numbers."
	shorthand = "Eng-US"
	tag_icon = "eng_us"

//
// Spanish
//

/datum/language/human/spanish
	name = LANGUAGE_HUMAN_SPANISH
	desc = "The Castilian tongue of old Earth, and the direct ancestor of Iberian. Where Iberian smoothed out the \
			differences between the Spanish and Portuguese worlds, this is the older, unblended article."
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = "spanish"
	key = "a"
	shorthand = "Esp"
	category = /datum/language/human/spanish
	language_group = LANGUAGE_HUMAN_SPANISH
	partial_understanding = list(
		LANGUAGE_HUMAN_IBERIAN = 70,
		LANGUAGE_HUMAN_EURO = 25,
		LANGUAGE_SPACER = 15
	)
	syllables = list(
		"ad", "al", "an", "ar", "as", "ci", "co", "de", "do", "el", "en", "er", "es", "ie", "la", "lo",
		"ma", "me", "mi", "na", "no", "on", "os", "pa", "pe", "po", "qu", "ra", "re", "ro", "se", "si",
		"ta", "te", "ti", "to", "tra", "ue", "un", "aba", "ado", "ant", "cia", "cio", "com", "con", "cua",
		"des", "dad", "ent", "era", "ero", "est", "ien", "ion", "ist", "men", "mos", "nte", "par", "per",
		"que", "sta", "tar", "tro", "una"
	)
	has_written_form = TRUE

/datum/language/human/spanish/es
	name = LANGUAGE_HUMAN_SPANISH_ES
	variant_name = "Spain"
	desc = "Peninsular Spanish, the Castilian standard of old Earth and the direct ancestor of Iberian."
	shorthand = "Esp-ES"
	tag_icon = "esp_es"
	is_group_primary = TRUE

/datum/language/human/spanish/ar
	name = LANGUAGE_HUMAN_SPANISH_AR
	variant_name = "Argentina"
	desc = "Rioplatense Spanish, distinctive enough in cadence and address that other Spanish speakers place it \
			within a sentence or two."
	shorthand = "Esp-AR"
	tag_icon = "esp_ar"

/datum/language/human/spanish/mx
	name = LANGUAGE_HUMAN_SPANISH_MX
	variant_name = "Mexico"
	desc = "Mexican Spanish, the most widely spoken variety of the language on Earth and throughout the colonies."
	shorthand = "Esp-MX"
	tag_icon = "esp_mx"

//
// Mandarin
//
// Deliberately left ungrouped: a group with a single member would give character setup a sub-menu with one option
// and rename the language to "Mandarin (China)" for no gain. Splitting it into variants later is a local change to
// this block -- add a `category`/`language_group` pair and the children -- with no work anywhere else.
//

/datum/language/human/mandarin
	name = LANGUAGE_HUMAN_MANDARIN
	desc = "The most widely spoken natural language in human history, and the root from which Yangyu was \
			standardised. Still in everyday use across Earth and the older Chinese-settled colonies."
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = "mandarin"
	key = "m"
	shorthand = "Man"
	tag_icon = "man"
	partial_understanding = list(
		LANGUAGE_HUMAN_CHINESE = 70,
		LANGUAGE_SPACER = 10
	)
	syllables = list(
		"ba", "bei", "bu", "chi", "da", "de", "dao", "dong", "du", "fa", "fei", "gao", "ge", "gong", "guo",
		"hai", "hao", "he", "hua", "hui", "ji", "jia", "jian", "jiao", "jie", "jin", "jing", "ju", "kai",
		"lai", "le", "li", "lian", "liao", "ma", "mei", "men", "ming", "na", "nan", "ne", "ni", "nian",
		"qi", "qian", "qing", "qu", "ran", "ren", "sha", "shang", "shen", "shi", "shou", "shuo", "si",
		"tian", "ting", "wei", "wo", "xia", "xian", "xiang", "xie", "xin", "xing", "xue", "yan", "yang",
		"yi", "you", "yu", "yuan", "zai", "zhang", "zhe", "zhen", "zhi", "zhong", "zhu", "zi", "zuo"
	)
	has_written_form = TRUE
