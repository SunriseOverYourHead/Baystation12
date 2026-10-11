// Vocal chirps -- the short burst of sound a character makes when speaking. See vocal_chirps.dm for the catalog
// and the emitter. These are a PHYSICAL character trait: they reach the mob only through copy_to() at spawn, so
// editing them mid-round deliberately has no effect until the next spawn (same as species/organs/markings, and
// unlike the OOC fields that were made live-updating).
/datum/preferences
	/// Catalog id from vocal_chirps.dm, or VOCAL_CHIRP_SPECIES_DEFAULT to keep the species' own speech sound.
	var/vocal_chirp_id = VOCAL_CHIRP_SPECIES_DEFAULT
	/// Characters of message per chirp -- LOWER is faster. Clamped to the chosen chirp's own band at play time.
	var/vocal_chirp_speed = 4
	var/vocal_chirp_pitch = 1
	var/vocal_chirp_variance = 0.2
	/// Rate limit for the audition button in the Character Voice modal. Not saved -- purely UI spam control.
	var/tmp/next_chirp_preview_time = 0

/datum/category_item/player_setup_item/physical/vocals
	name = "Vocals"
	sort_order = 6

/datum/category_item/player_setup_item/physical/vocals/load_character(datum/pref_record_reader/R)
	pref.vocal_chirp_id = R.read("vocal_chirp_id")
	pref.vocal_chirp_speed = R.read("vocal_chirp_speed")
	pref.vocal_chirp_pitch = R.read("vocal_chirp_pitch")
	pref.vocal_chirp_variance = R.read("vocal_chirp_variance")

/datum/category_item/player_setup_item/physical/vocals/save_character(datum/pref_record_writer/W)
	W.write("vocal_chirp_id", pref.vocal_chirp_id)
	W.write("vocal_chirp_speed", pref.vocal_chirp_speed)
	W.write("vocal_chirp_pitch", pref.vocal_chirp_pitch)
	W.write("vocal_chirp_variance", pref.vocal_chirp_variance)

/datum/category_item/player_setup_item/physical/vocals/sanitize_character()
	// A savefile predating this feature reads back null for every key, and null is a legitimate "no chirp" state
	// only for the id -- the numerics need real defaults or the clamps downstream have nothing to work with.
	if(!pref.vocal_chirp_id || (pref.vocal_chirp_id != VOCAL_CHIRP_SPECIES_DEFAULT && !get_vocal_chirp_by_id(pref.vocal_chirp_id)))
		pref.vocal_chirp_id = VOCAL_CHIRP_SPECIES_DEFAULT
	// clamp() rather than sanitize_integer() -- pitch and variance are legitimately fractional (0.4-2, 0.1-0.8)
	// and sanitize_integer() would round them away.
	pref.vocal_chirp_speed = isnum(pref.vocal_chirp_speed) ? clamp(pref.vocal_chirp_speed, VOCAL_CHIRP_DEFAULT_MINSPEED, VOCAL_CHIRP_DEFAULT_MAXSPEED) : 4
	pref.vocal_chirp_pitch = isnum(pref.vocal_chirp_pitch) ? clamp(pref.vocal_chirp_pitch, VOCAL_CHIRP_DEFAULT_MINPITCH, VOCAL_CHIRP_DEFAULT_MAXPITCH) : 1
	pref.vocal_chirp_variance = isnum(pref.vocal_chirp_variance) ? clamp(pref.vocal_chirp_variance, VOCAL_CHIRP_DEFAULT_MINVARY, VOCAL_CHIRP_DEFAULT_MAXVARY) : 0.2

/datum/category_item/player_setup_item/physical/vocals/content(mob/user)
	. += "<b>Vocals:</b><br>"
	var/singleton/vocal_chirp/chirp = get_vocal_chirp_by_id(pref.vocal_chirp_id)
	. += "Vocal Chirp: [chirp ? chirp.name : VOCAL_CHIRP_SPECIES_DEFAULT]<br/>"
