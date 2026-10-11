// Character Directory / expanded Examine Panel fields, ported from Bubberstation's own
// modular_zubbers/code/modules/client/verbs/character_directory.dm and
// modular_skyrat/master_files/code/modules/client/preferences/erp_preferences.dm -- adapted onto BS12SOYH's own
// plain-var + category_item/player_setup_item preference pattern (this codebase has neither a typed
// /datum/preference/choiced/text/toggle class framework nor a dna.features assoc-list, see
// baystation12soyh_character_directory_examine_panel memory), not copied verbatim.
//
// GLOB choice lists (the client-side dropdown "choices" data, mirroring how valid_bloodtypes already works).
GLOBAL_LIST_AS(valid_attraction_types, list(
	"Unset", "Check OOC", "Straight", "Lesbian", "Gay", "Bisexual", "Pansexual", "Polysexual",
	"Asexual", "Aromantic", "Aro/Ace", "Skoliosexual", "Omnisexual"
	))
GLOBAL_LIST_AS(valid_display_genders, list(
	"Unset", "Check OOC", "Male", "Female", "Nonbinary", "Genderfluid", "Trans", "Transmasc",
	"Transfem", "Andromorph", "Gynomorph", "Agender", "Plural", "Omnigender"
	))
GLOBAL_LIST_AS(valid_emote_lengths, list(
	"A few sentences", "1-2 Paragraphs", "Multi-Paragraph", "I'll Match You", "No Preference", "Check OOC"
	))
GLOBAL_LIST_AS(valid_approach_prefs, list(
	"Approach IC", "Approach OOC", "Any", "Both", "Check OOC", "See Below", "Unset"
	))
// Shared by furry_pref/scalie_pref/other_pref/demihuman_pref/human_pref -- same "same 6 options" pattern
// Bubberstation's own /datum/preference/choiced/directory_character_prefs abstract type uses.
GLOBAL_LIST_AS(valid_directory_character_prefs, list("Yes", "No", "No ERP", "Check OOC", "Unset", "Maybe"))
GLOBAL_LIST_AS(valid_erp_statuses, list(
	"Top - Dom", "Top - Switch", "Top - Sub",
	"Verse-Top - Dom", "Verse-Top - Switch", "Verse-Top - Sub",
	"Verse - Dom", "Verse - Switch", "Verse - Sub",
	"Verse-Bottom - Dom", "Verse-Bottom - Switch", "Verse-Bottom - Sub",
	"Bottom - Dom", "Bottom - Switch", "Bottom - Sub",
	"Check OOC Notes", "Ask (L)OOC", "No", "Yes"
	))
GLOBAL_LIST_AS(valid_erp_statuses_nc, list("No", "Ask (L)OOC", "Check OOC Notes", "Yes", "Yes - Dom", "Yes - Switch", "Yes - Sub"))
GLOBAL_LIST_AS(valid_erp_statuses_v, list("No", "Ask (L)OOC", "Check OOC Notes", "Yes", "Yes - Pred", "Yes - Prey", "Yes - Switch"))
GLOBAL_LIST_AS(valid_erp_statuses_hypno, list("Always/Whenever", "Gameplay Only", "Ask (L)OOC", "Check OOC Notes", "No"))
GLOBAL_LIST_AS(valid_show_nsfw_flavor_text, list("Always On", "Nude Only", "Never"))

/datum/preferences
	// Directory listing / OOC dating-preference fields (not ERP-gated -- these are general "who am I looking to
	// play with" fields, matching Bubberstation's own PREFERENCE_PLAYER-level split for these specifically).
	var/show_in_directory = TRUE
	var/attraction = "Unset"
	var/display_gender = "Unset"
	var/emote_length = "No Preference"
	var/approach_pref = "Unset"
	var/furry_pref = "Unset"
	var/scalie_pref = "Unset"
	var/other_pref = "Unset"
	var/demihuman_pref = "Unset"
	var/human_pref = "Unset"
	var/character_ad = ""
	// ERP tag matrix -- gated behind master_erp_preferences same as the genital toggles (see
	// preferences_tgui.dm's is_erp handling), matching Bubberstation's own is_accessible() gate on these specific
	// fields (unlike the fields above, which Bubberstation does NOT gate behind its ERP master switch).
	var/erp_status = "No"
	var/erp_status_nc = "No"
	var/erp_status_v = "No"
	var/erp_status_hypno = "No"
	var/erp_free_use = FALSE
	// Gates whether this character's penis is written as knot-capable for the sexcon engine's knotting mechanic
	// (code/datums/sexcon/sexcon.dm) -- deliberately NOT tied to any specific penis_type/shape choice (this
	// codebase has no knot-capable-vs-not genital style distinction), just a plain opt-in, matching how
	// Bubberstation/SPLURT-family forks gate similar mechanics behind a simple ERP checkbox rather than anatomy.
	var/can_knot_partners = FALSE
	// Consent flag for the sexcon engine's own "Sate Desire" minigame specifically (code/datums/sexcon/sexcon.dm) --
	// distinct from master_erp_preferences (which gates ERP entirely) and can_knot_partners/erp_free_use (which
	// only shape what the mechanic does once opened). A character with sexual content enabled can still opt out of
	// this one mechanic while keeping everything else (dating preferences, tags, directory listing) intact.
	var/mechanical_erp = FALSE
	// Custom species name/lore (blocked for species with species.lore_protected, matching Bubberstation).
	var/custom_species = ""
	var/custom_species_lore = ""
	// A single freeform "about this character" blurb -- the sole source of a spawned character's flavor text
	// (copy_to() writes it onto both character_flavor_text and the base /mob/var/flavor_text); the old
	// per-bodypart `flavor_texts` list editor this used to sit alongside has been retired.
	var/character_flavor_text = ""
	var/flavor_text_nsfw = ""
	var/show_nsfw_flavor_text = "Nude Only"

/datum/category_item/player_setup_item/background/erp_directory
	name = "ERP & Directory"
	sort_order = 6

/datum/category_item/player_setup_item/background/erp_directory/load_character(datum/pref_record_reader/R)
	pref.show_in_directory = R.read("show_in_directory")
	pref.attraction = R.read("attraction")
	pref.display_gender = R.read("display_gender")
	pref.emote_length = R.read("emote_length")
	pref.approach_pref = R.read("approach_pref")
	pref.furry_pref = R.read("furry_pref")
	pref.scalie_pref = R.read("scalie_pref")
	pref.other_pref = R.read("other_pref")
	pref.demihuman_pref = R.read("demihuman_pref")
	pref.human_pref = R.read("human_pref")
	pref.character_ad = R.read("character_ad")
	pref.erp_status = R.read("erp_status")
	pref.erp_status_nc = R.read("erp_status_nc")
	pref.erp_status_v = R.read("erp_status_v")
	pref.erp_status_hypno = R.read("erp_status_hypno")
	pref.erp_free_use = R.read("erp_free_use")
	pref.can_knot_partners = R.read("can_knot_partners")
	pref.mechanical_erp = R.read("mechanical_erp")
	pref.custom_species = R.read("custom_species")
	pref.custom_species_lore = R.read("custom_species_lore")
	pref.character_flavor_text = R.read("character_flavor_text")
	pref.flavor_text_nsfw = R.read("flavor_text_nsfw")
	pref.show_nsfw_flavor_text = R.read("show_nsfw_flavor_text")

/datum/category_item/player_setup_item/background/erp_directory/save_character(datum/pref_record_writer/W)
	W.write("show_in_directory", pref.show_in_directory)
	W.write("attraction", pref.attraction)
	W.write("display_gender", pref.display_gender)
	W.write("emote_length", pref.emote_length)
	W.write("approach_pref", pref.approach_pref)
	W.write("furry_pref", pref.furry_pref)
	W.write("scalie_pref", pref.scalie_pref)
	W.write("other_pref", pref.other_pref)
	W.write("demihuman_pref", pref.demihuman_pref)
	W.write("human_pref", pref.human_pref)
	W.write("character_ad", pref.character_ad)
	W.write("erp_status", pref.erp_status)
	W.write("erp_status_nc", pref.erp_status_nc)
	W.write("erp_status_v", pref.erp_status_v)
	W.write("erp_status_hypno", pref.erp_status_hypno)
	W.write("erp_free_use", pref.erp_free_use)
	W.write("can_knot_partners", pref.can_knot_partners)
	W.write("mechanical_erp", pref.mechanical_erp)
	W.write("custom_species", pref.custom_species)
	W.write("custom_species_lore", pref.custom_species_lore)
	W.write("character_flavor_text", pref.character_flavor_text)
	W.write("flavor_text_nsfw", pref.flavor_text_nsfw)
	W.write("show_nsfw_flavor_text", pref.show_nsfw_flavor_text)
