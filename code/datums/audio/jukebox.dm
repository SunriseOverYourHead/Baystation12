/datum/jukebox
	var/atom/owner
	var/sound_id
	var/datum/sound_token/token
	var/list/tracks
	var/index = 1
	var/volume = 20
	var/volume_max = 50
	var/volume_step = 10
	var/frequency = 1
	var/range = 7
	var/falloff = 1
	var/template
	var/ui_title
	var/ui_width
	var/ui_height
	var/playing
	var/looping = TRUE


/datum/jukebox/New(atom/_owner, _template, _ui_title, _ui_width, _ui_height)
	. = ..()
	if (QDELETED(_owner) || !istom(_owner))
		qdel(src)
		return
	owner = _owner
	tracks = list()
	for (var/path in GLOB.jukebox_tracks)
		var/singleton/audio/track/track = GET_SINGLETON(path)
		AddTrack(track.display || track.title, track.source)
	sound_id = "[/datum/jukebox]_[sequential_id(/datum/jukebox)]"
	template = _template
	ui_title = _ui_title
	ui_width = _ui_width
	ui_height = _ui_height


/datum/jukebox/Destroy()
	QDEL_NULL_LIST(tracks)
	QDEL_NULL(token)
	owner = null
	return ..()


/datum/jukebox/proc/AddTrack(title = "Track [length(tracks) + 1]", source)
	tracks += new /datum/jukebox_track (title, source)


/datum/jukebox/proc/ClearTracks()
	QDEL_NULL_LIST(tracks)
	tracks = list()


/datum/jukebox/proc/Next()
	if (++index > length(tracks))
		index = 1
	if (playing)
		Stop()
		Play()


/datum/jukebox/proc/Last()
	if (--index < 1)
		index = length(tracks)
	if (playing)
		Stop()
		Play()


/datum/jukebox/proc/Track(_index)
	_index = text2num(_index)
	if (!IsInteger(_index))
		return
	index = clamp(_index, 1, length(tracks))
	if (playing)
		Stop()
		Play()


/datum/jukebox/proc/Stop()
	playing = FALSE
	QDEL_NULL(token)
	owner.queue_icon_update()
	SStgui.update_uis(src)


/datum/jukebox/proc/Play()
	if (playing)
		return
	var/datum/jukebox_track/track = tracks[index]
	if (!track.source)
		return
	playing = TRUE
	token = GLOB.sound_player.PlayLoopingSound(owner, sound_id, track.source,
		volume, range, falloff, frequency = frequency, prefer_mute = TRUE)
	owner.queue_icon_update()
	SStgui.update_uis(src)


/datum/jukebox/proc/Volume(_volume)
	_volume = text2num(_volume)
	if (!isfinite(_volume))
		return
	if (_volume >= 0)
		volume = min(_volume, volume_max)
	else if (_volume == -1)
		volume = max(volume - volume_step, 0)
	else if (_volume == -2)
		volume = min(volume + volume_step, volume_max)
	if (token)
		token.SetVolume(volume)


/datum/jukebox/ui_host()
	return owner


/datum/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "Jukebox", ui_title || "Jukebox", ui)
	ui.set_autoupdate(TRUE)
	ui.open()


/datum/jukebox/ui_data(mob/user)
	var/list/songs = list()
	for (var/datum/jukebox_track/track in tracks)
		songs += list(list("name" = track.title))
	var/datum/jukebox_track/current = tracks[index]
	return list(
		"active" = playing,
		"looping" = looping,
		"volume" = volume,
		"track_selected" = current?.title,
		"songs" = songs
	)


/datum/jukebox/ui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle")
			if(playing)
				Stop()
			else
				Play()
			. = TRUE
		if("loop")
			looping = params["looping"] ? TRUE : FALSE
			. = TRUE
		if("select_track")
			var/track_name = params["track"]
			for(var/i = 1 to length(tracks))
				var/datum/jukebox_track/T = tracks[i]
				if(T.title == track_name)
					Track(i)
					break
			. = TRUE
		if("set_volume")
			var/vol = params["volume"]
			if(vol == "min")
				Volume(0)
			else if(vol == "max")
				Volume(volume_max)
			else if(vol == "reset")
				Volume(20)
			else
				Volume("[vol]")
			. = TRUE



/datum/jukebox_track
	var/title
	var/source


/datum/jukebox_track/New(_title, _source)
	title = _title
	source = _source



GLOBAL_LIST_AS(jukebox_tracks, list(
	/singleton/audio/track/absconditus,
	/singleton/audio/track/ambispace,
	/singleton/audio/track/asfarasitgets,
	/singleton/audio/track/clouds_of_fire,
	/singleton/audio/track/comet_haley,
	/singleton/audio/track/df_theme,
	/singleton/audio/track/digit_one,
	/singleton/audio/track/dilbert,
	/singleton/audio/track/eighties,
	/singleton/audio/track/elevator,
	/singleton/audio/track/elibao,
	/singleton/audio/track/endless_space,
	/singleton/audio/track/floating,
	/singleton/audio/track/hull_rupture,
	/singleton/audio/track/human,
	/singleton/audio/track/inorbit,
	/singleton/audio/track/lasers,
	/singleton/audio/track/level3_mod,
	/singleton/audio/track/lysendraa,
	/singleton/audio/track/marhaba,
	/singleton/audio/track/martiancowboy,
	/singleton/audio/track/misanthropic_corridors,
	/singleton/audio/track/monument,
	/singleton/audio/track/nebula,
	/singleton/audio/track/on_the_rocks,
	/singleton/audio/track/one_loop,
	/singleton/audio/track/pwmur,
	/singleton/audio/track/rimward_cruise,
	/singleton/audio/track/space_oddity,
	/singleton/audio/track/thunderdome,
	/singleton/audio/track/torch,
	/singleton/audio/track/torn,
	/singleton/audio/track/treacherous_voyage,
	/singleton/audio/track/voidsent,
	/singleton/audio/track/wake,
	/singleton/audio/track/wildencounters
))
