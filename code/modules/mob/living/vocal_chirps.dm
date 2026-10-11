// Vocal chirps -- a short burst of sound plays when a character speaks, customizable per character in
// Character Setup. Ported from NovaSector/Bubberstation, where it's called "vocal bloopers"/"barks"
// (modular_nova/modules/blooper/). The audio in sound/vocal_chirps/ is Nova's, copied wholesale; Bubberstation's
// newer rewrite moved to a runtime JSON config and ships no audio at all, so the assets and the per-entry tuning
// below both come from Nova, while the emitter (say.dm's play_vocal_chirps) follows Bubberstation's tidier
// message-length-scaled model.
//
// Values are raw, matching Nova (and matching the range hints already written into this feature's existing
// character_voice.tsx descriptions): speed 2-16 (LOWER is faster -- it's characters-per-chirp), pitch 0.4-2,
// variance 0.1-0.8. Per-entry min/max here are the slider bounds a player's own setting is clamped to, so a
// chirp with a narrow band stays recognisable no matter how the player tunes it.



/singleton/vocal_chirp
	abstract_type = /singleton/vocal_chirp
	/// Shown in the Character Setup dropdown.
	var/name
	/// Stable key stored in the savefile -- renaming `name` is safe, renaming this orphans saved characters.
	var/id
	var/sound_file

	var/min_pitch = VOCAL_CHIRP_DEFAULT_MINPITCH
	var/max_pitch = VOCAL_CHIRP_DEFAULT_MAXPITCH
	var/min_variance = VOCAL_CHIRP_DEFAULT_MINVARY
	var/max_variance = VOCAL_CHIRP_DEFAULT_MAXVARY
	/// Characters of message per chirp. Lower = faster/denser.
	var/min_speed = VOCAL_CHIRP_DEFAULT_MINSPEED
	var/max_speed = VOCAL_CHIRP_DEFAULT_MAXSPEED


/// id -> /singleton/vocal_chirp. Cached after the first successful build, since get_vocal_chirp_by_id() runs on
/// every spoken message. Deliberately only caches a NON-EMPTY result: a call made before the singleton repo has
/// resolved would otherwise poison the cache with an empty list for the rest of the round.
/proc/get_vocal_chirps()
	var/static/list/chirps_by_id
	if(length(chirps_by_id))
		return chirps_by_id
	var/list/built = list()
	for(var/singleton/vocal_chirp/chirp as anything in GET_SINGLETON_SUBTYPE_LIST(/singleton/vocal_chirp))
		if(chirp.id)
			built[chirp.id] = chirp
	if(length(built))
		chirps_by_id = built
	return built


/proc/get_vocal_chirp_by_id(id)
	RETURN_TYPE(/singleton/vocal_chirp)
	if(!id || id == VOCAL_CHIRP_SPECIES_DEFAULT)
		return null
	var/list/chirps = get_vocal_chirps()
	return chirps[id]


/singleton/vocal_chirp/moffsqueak
	name = "Moff squeak"
	id = "moffsqueak"
	sound_file = 'sound/vocal_chirps/mothsqueak.ogg'

/singleton/vocal_chirp/meow
	name = "Meow"
	id = "meow"
	sound_file = 'sound/vocal_chirps/meow1.ogg'
	min_speed = 5
	max_speed = 11

/singleton/vocal_chirp/chirp
	name = "Chirp"
	id = "chirp"
	sound_file = 'sound/vocal_chirps/chirp.ogg'

/singleton/vocal_chirp/caw
	name = "Caw"
	id = "caw"
	sound_file = 'sound/vocal_chirps/caw.ogg'

/singleton/vocal_chirp/monster1
	name = "Monster 1"
	id = "monster1"
	sound_file = 'sound/vocal_chirps/monster1.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster2
	name = "Monster 2"
	id = "monster2"
	sound_file = 'sound/vocal_chirps/monster2.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster3
	name = "Monster 3"
	id = "monster3"
	sound_file = 'sound/vocal_chirps/monster3.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster4
	name = "Monster 4"
	id = "monster4"
	sound_file = 'sound/vocal_chirps/monster4.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster5
	name = "Monster 5"
	id = "monster5"
	sound_file = 'sound/vocal_chirps/monster5.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster6
	name = "Monster 6"
	id = "monster6"
	sound_file = 'sound/vocal_chirps/monster6.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster7
	name = "Monster 7"
	id = "monster7"
	sound_file = 'sound/vocal_chirps/monster7.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster8
	name = "Monster 8"
	id = "monster8"
	sound_file = 'sound/vocal_chirps/monster8.ogg'
	min_variance = 0
	max_pitch = VOCAL_CHIRP_DEFAULT_MAXPITCH*2

/singleton/vocal_chirp/monster9
	name = "Monster 9"
	id = "monster9"
	sound_file = 'sound/vocal_chirps/monster9.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster10
	name = "Monster 10"
	id = "monster10"
	sound_file = 'sound/vocal_chirps/monster10.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster11
	name = "Monster 11"
	id = "monster11"
	sound_file = 'sound/vocal_chirps/monster11.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster12
	name = "Monster 12"
	id = "monster12"
	sound_file = 'sound/vocal_chirps/monster12.ogg'
	min_variance = 0

/singleton/vocal_chirp/monster13
	name = "Monster 13"
	id = "monster13"
	sound_file = 'sound/vocal_chirps/monster13.ogg'
	min_variance = 0

/singleton/vocal_chirp/gen_monster_1
	name = "Generic Monster 1"
	id = "gen_monster_1"
	sound_file = 'sound/vocal_chirps/voice_monster1.ogg'
	min_variance = 0

/singleton/vocal_chirp/gen_monster_2
	name = "Generic Monster 2"
	id = "gen_monster_2"
	sound_file = 'sound/vocal_chirps/voice_monster2.ogg'
	min_variance = 0

/singleton/vocal_chirp/blerp
	name = "Blerp"
	id = "blerp"
	sound_file = 'sound/vocal_chirps/blerp.ogg'

/singleton/vocal_chirp/brrp
	name = "Brrp"
	id = "brrp"
	sound_file = 'sound/vocal_chirps/brrp.ogg'
	min_speed = 3
	max_speed = 9

/singleton/vocal_chirp/whistle1
	name = "Whistle 1"
	id = "whistle1"
	sound_file = 'sound/vocal_chirps/birdwhistle.ogg'

/singleton/vocal_chirp/whistle2
	name = "Whistle 2"
	id = "whistle2"
	sound_file = 'sound/vocal_chirps/birdwhistle2.ogg'

/singleton/vocal_chirp/caw2
	name = "Caw 2"
	id = "caw2"
	sound_file = 'sound/vocal_chirps/caw2.ogg'
	min_speed = 4
	max_speed = 9

/singleton/vocal_chirp/caw3
	name = "Caw 3"
	id = "caw3"
	sound_file = 'sound/vocal_chirps/caw3.ogg'
	min_speed = 3
	max_speed = 9

/singleton/vocal_chirp/caw4
	name = "Caw 4"
	id = "caw4"
	sound_file = 'sound/vocal_chirps/caw4.ogg'
	min_speed = 3
	max_speed = 9

/singleton/vocal_chirp/ehh1
	name = "Ehh 1"
	id = "ehh1"
	sound_file = 'sound/vocal_chirps/ehh.ogg'
	min_speed = 3
	max_speed = 9

/singleton/vocal_chirp/ehh2
	name = "Ehh 2"
	id = "ehh2"
	sound_file = 'sound/vocal_chirps/ehh2.ogg'

/singleton/vocal_chirp/ehh3
	name = "Ehh 3"
	id = "ehh3"
	sound_file = 'sound/vocal_chirps/ehh3.ogg'

/singleton/vocal_chirp/ehh5
	name = "Ehh 5"
	id = "ehh5"
	sound_file = 'sound/vocal_chirps/ehh5.ogg'

/singleton/vocal_chirp/faucet1
	name = "Faucet 1"
	id = "faucet1"
	sound_file = 'sound/vocal_chirps/faucet.ogg'

/singleton/vocal_chirp/faucet2
	name = "Faucet 2"
	id = "faucet2"
	sound_file = 'sound/vocal_chirps/faucet2.ogg'

/singleton/vocal_chirp/ribbit
	name = "Ribbit"
	id = "ribbit"
	sound_file = 'sound/vocal_chirps/ribbit.ogg'

/singleton/vocal_chirp/hoot
	name = "Hoot"
	id = "hoot"
	sound_file = 'sound/vocal_chirps/hoot.ogg'
	min_speed = 4
	max_speed = 9

/singleton/vocal_chirp/tweet
	name = "Tweet"
	id = "tweet"
	sound_file = 'sound/vocal_chirps/tweet.ogg'

/singleton/vocal_chirp/dwoop
	name = "Dwoop"
	id = "dwoop"
	sound_file = 'sound/vocal_chirps/dwoop.ogg'
	min_speed = 3
	max_speed = 9

/singleton/vocal_chirp/uhm
	name = "Uhm"
	id = "uhm"
	sound_file = 'sound/vocal_chirps/uhm.ogg'

/singleton/vocal_chirp/wurtesh
	name = "Wurtesh"
	id = "wurtesh"
	sound_file = 'sound/vocal_chirps/wurble1.ogg'

/singleton/vocal_chirp/chitter2
	name = "Chitter2"
	id = "chitter2"
	sound_file = 'sound/vocal_chirps/chitter1.ogg'

/singleton/vocal_chirp/genius
	name = "Genius"
	id = "genius"
	sound_file = 'sound/vocal_chirps/genius.ogg'

/singleton/vocal_chirp/jester
	name = "Jester"
	id = "jester"
	sound_file = 'sound/vocal_chirps/jester.ogg'

/singleton/vocal_chirp/goober
	name = "Goober"
	id = "goober"
	sound_file = 'sound/vocal_chirps/goober.ogg'

/singleton/vocal_chirp/royal
	name = "Royal"
	id = "royal"
	sound_file = 'sound/vocal_chirps/royal.ogg'

/singleton/vocal_chirp/salesman
	name = "Salesman"
	id = "salesman"
	sound_file = 'sound/vocal_chirps/salesman.ogg'

/singleton/vocal_chirp/old
	name = "Old"
	id = "old"
	sound_file = 'sound/vocal_chirps/old.ogg'

/singleton/vocal_chirp/spell1
	name = "SpeechSynth 1"
	id = "spell1"
	sound_file = 'sound/vocal_chirps/spell1.ogg'

/singleton/vocal_chirp/spell2
	name = "SpeechSynth 2"
	id = "spell2"
	sound_file = 'sound/vocal_chirps/spell2.ogg'

/singleton/vocal_chirp/spell3
	name = "SpeechSynth 3"
	id = "spell3"
	sound_file = 'sound/vocal_chirps/spell3.ogg'

/singleton/vocal_chirp/chitter
	name = "Chitter"
	id = "chitter"
	sound_file = 'sound/vocal_chirps/chitter.ogg'

/singleton/vocal_chirp/ehh4
	name = "Ehh 4"
	id = "ehh4"
	sound_file = 'sound/vocal_chirps/ehh4.ogg'

/singleton/vocal_chirp/mothchitter
	name = "Moth chitter"
	id = "mothchitter"
	sound_file = 'sound/vocal_chirps/mothchitter2.ogg'

/singleton/vocal_chirp/accordion
	name = "Accordion"
	id = "accordion"
	sound_file = 'sound/vocal_chirps/accordion.ogg'

/singleton/vocal_chirp/cello
	name = "Cello"
	id = "cello"
	sound_file = 'sound/vocal_chirps/cello.ogg'

/singleton/vocal_chirp/trombone
	name = "Trombone"
	id = "trombone"
	sound_file = 'sound/vocal_chirps/trumbone.ogg'

// Per-character state, copied from prefs at spawn only (preferences.dm's copy_to) -- this is a physical trait,
// so changing the setting mid-round deliberately does nothing until you respawn. Values are raw (see header).
/mob/living/var/vocal_chirp_id = VOCAL_CHIRP_SPECIES_DEFAULT
/mob/living/var/vocal_chirp_speed = 4
/mob/living/var/vocal_chirp_pitch = 1
/mob/living/var/vocal_chirp_variance = 0.2
/// Speaker-side cooldown so one chirp train finishes before the next can start. Mirrors the audible-emote
/// cooldown pattern in emotes/definitions/_mob.dm.
/mob/living/var/next_vocal_chirp_time = 0


/**
 * Plays this mob's chirp train for one spoken message.
 *
 * Called from /mob/living/say() once the listener list is known. Everything that shouldn't chirp (emotes,
 * hivemind, muzzled, sign language, the :w whisper prefix) has already returned out of say() by that point;
 * whisper-verb speech and radio use are gated here via the args.
 *
 * Chirp count scales with message length rather than word count, matching the source implementation, and the
 * train is capped both in count and in wall-clock duration so a long message can't machine-gun.
 */
/mob/living/proc/play_vocal_chirps(message, list/listeners, whispering, on_radio)
	if(!length(message) || !length(listeners))
		return
	// Radio chatter is already represented by the "talks into their headset" message and the halved speech
	// sound; chirping on top of that gets noisy fast.
	if(on_radio)
		return
	if(world.time < next_vocal_chirp_time)
		return
	var/singleton/vocal_chirp/chirp = get_vocal_chirp_by_id(vocal_chirp_id)
	if(!chirp)
		return

	var/speed = clamp(vocal_chirp_speed, chirp.min_speed, chirp.max_speed)
	var/pitch = clamp(vocal_chirp_pitch, chirp.min_pitch, chirp.max_pitch)
	var/variance = clamp(vocal_chirp_variance, chirp.min_variance, chirp.max_variance)

	var/volume = whispering ? 27 : 55
	// Shouting is louder, same as the source implementation's check for a trailing '!'.
	if(findtext(message, "!", -1))
		volume *= 2

	var/chirp_count = min(round(length(message) / speed, 1) + 1, VOCAL_CHIRP_MAX_PER_MESSAGE)
	// Gap between chirps in deciseconds, scaled off the speed setting so slower voices space out as well as
	// chirping less often. Floor of 1ds keeps the fastest setting from collapsing into a single instant burst.
	var/gap = max(1, round(speed / VOCAL_CHIRP_SPEED_BASELINE))
	var/total_delay = 0
	for(var/i = 1 to chirp_count)
		if(total_delay > VOCAL_CHIRP_MAX_TIME)
			break
		addtimer(new Callback(src, PROC_REF(play_one_vocal_chirp), listeners.Copy(), chirp.sound_file, volume, VOCAL_CHIRP_DO_VARY(pitch, variance)), total_delay)
		total_delay += rand(gap, gap * 2)
	next_vocal_chirp_time = world.time + total_delay


/// One chirp of a train. Emitted per-listener so each client gets its own positional falloff and can opt out.
/mob/living/proc/play_one_vocal_chirp(list/listeners, sound_file, volume, frequency)
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return
	for(var/mob/listener in listeners)
		if(!listener?.client)
			continue
		var/listener_volume = volume * listener.get_vocal_chirp_volume_scalar()
		if(listener_volume <= 0)
			continue
		listener.playsound_local(source_turf, sound_file, listener_volume, TRUE, frequency, VOCAL_CHIRP_FALLOFF_EXPONENT)


/// 0 when this listener has chirps muted, otherwise their chosen volume as a multiplier.
/mob/proc/get_vocal_chirp_volume_scalar()
	if(!client)
		return 1
	switch(get_preference_value(/datum/client_preference/hear_vocal_chirps))
		if(GLOB.PREF_OFF)
			return 0
		if(GLOB.PREF_LOW)
			return 0.5
		if(GLOB.PREF_HIGH)
			return 1.5
	return 1
