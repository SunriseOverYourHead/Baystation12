var/global/list/sounds_cache = list()

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = GLOB.admin_sound_channel)
	uploaded_sound.priority = 250

	sounds_cache += S
	var/volume = 100

	while (TRUE)
		volume = input(src, "Sound volume (0 - 100)", "Volume", volume) as null|num
		if (isnull(volume))
			return

		volume =  round(clamp(volume, 0, 100))
		to_chat(src, "Sound volume set to [volume]%")
		uploaded_sound.volume =volume
		var/choice = alert("Song: [S]", "Play Sound" , "Play", "Preview", "Cancel")

		if (choice == "Cancel")
			return

		if (choice == "Preview")
			sound_to(src, uploaded_sound)

		if (choice == "Play")
			break


	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]", 1)
	for(var/mob/M in GLOB.player_list)
		if(M.get_preference_value(/datum/client_preference/play_admin_midis) == GLOB.PREF_YES)
			sound_to(M, uploaded_sound)

/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return
	var/vol = input("Select a volume for the sound", "Play Local Sound", 50) as num|null
	if (!vol)
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]", 1)
	playsound(get_turf(src.mob), S, vol, 0, 0)


/client/proc/play_server_sound()
	set category = "Fun"
	set name = "Play Server Sound"
	if(!check_rights(R_SOUNDS))	return

	var/list/sounds = list("sound/items/bikehorn.ogg","sound/effects/siren.ogg")
	sounds += sounds_cache

	var/melody = input("Select a sound from the server to play", "Server sound list") as null|anything in sounds

	if(!melody)
		return

	play_sound(melody)

var/global/web_sound_cooldown = 0

/proc/web_sound(client/C, input)
	if(!check_rights(R_SOUNDS, FALSE, C))
		return
	var/ytdl = config.invoke_youtubedl
	if(!ytdl)
		to_chat(C, SPAN_WARNING("yt-dlp was not configured, action unavailable"))
		return
	var/web_sound_url = ""
	var/stop_web_sounds = FALSE
	var/list/music_extra_data = list()
	var/duration = 0
	if(istext(input))
		var/shell_scrubbed_input = shell_url_scrub(input)
		var/list/shelleo_output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
		var/errorlevel = shelleo_output[1]
		var/stdout = shelleo_output[2]
		var/stderr = shelleo_output[3]
		if(errorlevel)
			to_chat(C, SPAN_WARNING("yt-dlp URL retrieval FAILED:"))
			to_chat(C, SPAN_WARNING("[stderr]"))
			return
		var/list/data
		try
			data = json_decode(stdout)
		catch(var/exception/e)
			to_chat(C, SPAN_WARNING("yt-dlp JSON parsing FAILED: [e]: [stdout]"))
			return
		if(data["url"])
			web_sound_url = data["url"]
		var/title = "[data["title"]]"
		var/webpage_url = title
		if(data["webpage_url"])
			webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
		duration = data["duration"] * 10
		music_extra_data["duration"] = time_to_readable(duration)
		music_extra_data["link"] = data["webpage_url"]
		music_extra_data["artist"] = data["artist"]
		music_extra_data["upload_date"] = data["upload_date"]
		music_extra_data["album"] = data["album"]
		if(duration > 6000)
			if(alert(C, "This song is over 10 minutes long. Are you sure you want to play it?", "Length Warning", "Yes", "No") != "Yes")
				return
		var/include_song_data = alert(C, "Show the title of and link to this song to the players?\n[title]", "Song Info", "Yes", "No", "Cancel")
		if(!include_song_data || include_song_data == "Cancel")
			return
		if(include_song_data == "No")
			music_extra_data["link"] = "\[HYPERLINK BLOCKED\]"
			music_extra_data["title"] = "Untitled"
			music_extra_data["artist"] = "Unknown"
			music_extra_data["upload_date"] = "XX.YY.ZZZZ"
			music_extra_data["album"] = "Default"
		else
			music_extra_data["title"] = data["title"]
			music_extra_data["artist"] = data["artist"]
		var/credit_yourself = alert(C, "Display who played the song?", "Credit Yourself", "Yes", "No", "Cancel")
		if(!credit_yourself || credit_yourself == "Cancel")
			return
		var/announce
		if(credit_yourself == "Yes")
			announce = include_song_data == "Yes" ? "[key_name(C)] played: [webpage_url]" : "[key_name(C)] played a sound."
		else
			announce = include_song_data == "Yes" ? "An admin played: [webpage_url]" : "An admin played a sound."
		var/list/recipients = list()
		for(var/mob/M in GLOB.player_list)
			if(M.get_preference_value(/datum/client_preference/play_admin_midis) == GLOB.PREF_YES)
				recipients += M
		to_chat(recipients, SPAN_NOTICE("Now Playing: [music_extra_data["title"]] by [music_extra_data["artist"]]<br>[announce]"))
		log_admin("[key_name(C)] played web sound: [input]")
		message_admins("[key_name(C)] played web sound: [input]")
	else
		log_admin("[key_name(C)] stopped web sounds.")
		message_admins("[key_name(C)] stopped web sounds.")
		web_sound_url = null
		stop_web_sounds = TRUE
	if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
		alert(C, "The media provider returned a content URL that isn't using the HTTP or HTTPS protocol. This is a security risk and the sound will not be played.", "Security Risk", "OK")
		to_chat(C, SPAN_WARNING("BLOCKED: Content URL not using HTTP(S) Protocol!"))
		return
	if(web_sound_url || stop_web_sounds)
		for(var/mob/M in GLOB.player_list)
			var/client/client_M = M.client
			if(!client_M)
				continue
			if(M.get_preference_value(/datum/client_preference/play_admin_midis) != GLOB.PREF_YES)
				continue
			sound_to(client_M, sound(null, channel = GLOB.lobby_sound_channel))
			sound_to(client_M, sound(null, channel = GLOB.admin_sound_channel))
			if(!stop_web_sounds)
				client_M.chatOutput?.play_music(web_sound_url, music_extra_data)
			else
				client_M.chatOutput?.stop_music()
	web_sound_cooldown = world.time + duration

/client/proc/play_web_sound()
	set category = "Fun"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUNDS))
		return
	if(!config.invoke_youtubedl)
		to_chat(src, SPAN_WARNING("yt-dlp is not configured on this server."))
		return
	if(world.time < web_sound_cooldown)
		if(alert(src, "Someone else is already playing an Internet sound! It has [time_to_readable(web_sound_cooldown - world.time)] remaining. Would you like to override?", "Musicalis Interruptus", "Yes", "No") != "Yes")
			return
	var/web_sound_input = input(src, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound") as text|null
	if(length(web_sound_input))
		web_sound_input = trimtext(web_sound_input)
		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(src, SPAN_WARNING("Non-http(s) URIs are not allowed."))
			return
		web_sound(src, web_sound_input)
	else
		web_sound(src, null)
