/obj/machinery/atmospherics/unary/gas_extractor
	icon = 'icons/atmos/gas_extractor.dmi'
	icon_state = "map_extractor"

	name = "gas extractor"
	desc = "Transfers gas from its surroundings into pipes."

	use_power = POWER_USE_OFF
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 45000	//45000 W ~ 60 HP

	var/target_pressure = MAX_PUMP_PRESSURE
	var/external_mode = FALSE
	var/frequency = 1439
	var/id = null
	var/datum/radio_frequency/radio_connection

	level = ATOM_LEVEL_UNDER_TILE

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_FUEL

	build_icon = 'icons/atmos/gas_extractor.dmi'
	build_icon_state = "map_extractor"

/obj/machinery/atmospherics/unary/gas_extractor/Initialize()
	. = ..()
	air_contents.volume = ATMOS_DEFAULT_VOLUME_PUMP + 1200

	set_frequency(frequency)
	broadcast_status()


/obj/machinery/atmospherics/unary/gas_extractor/Destroy()
	unregister_radio(src, frequency)
	. = ..()

/obj/machinery/atmospherics/unary/gas_extractor/on_update_icon()
	if (!node)
		update_use_power(POWER_USE_OFF)

	if(!is_powered())
		icon_state = "off"

	else
		icon_state = "[use_power ? "on" : "off"]"

/obj/machinery/atmospherics/unary/gas_extractor/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(!T.is_plating() && node && node.level == ATOM_LEVEL_UNDER_TILE && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/unary/gas_extractor/ui_interact(mob/user, datum/tgui/ui)
	if(inoperable())
		return
	ui = tgui_interact(user, src, "GasExtractor", name, ui)

/obj/machinery/atmospherics/unary/gas_extractor/ui_data(mob/user)
	return list(
		"on" = use_power,
		"id" = id,
		"target_pressure" = round(target_pressure * 100),
		"pressure_check" = external_mode,
		"frequency" = frequency,
		"last_flow_rate" = round(last_flow_rate * 10),
	)

/obj/machinery/atmospherics/unary/gas_extractor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			update_use_power(!use_power)
			update_icon()
			return TRUE
		if("settag")
			var/t = sanitizeSafe(input(usr, "Enter the ID tag for [src.name]", src.name, id), MAX_NAME_LEN)
			id = t
			return TRUE
		if("toggle_mode")
			external_mode = !external_mode
			update_use_power(POWER_USE_OFF)
			return TRUE
		if("setfreq")
			var/freq = input(usr, "Enter the Frequency for [src.name]. Decimal will automatically be inserted", src.name, frequency) as num|null
			set_frequency(freq)
			return TRUE
		if("setpressure")
			switch(params["value"])
				if("max")
					target_pressure = MAX_PUMP_PRESSURE
					update_icon()
					return TRUE
				if("set")
					var/new_pressure = input(usr, "Enter new pressure (0-[MAX_PUMP_PRESSURE]kPa)", "Pressure control", src.target_pressure) as num
					src.target_pressure = clamp(new_pressure, 0, MAX_PUMP_PRESSURE)
					update_icon()
					return TRUE
	return FALSE

/obj/machinery/atmospherics/unary/gas_extractor/ui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/atmospherics/unary/gas_extractor/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/atmospherics/unary/gas_extractor/Process()
	..()

	last_power_draw = 0
	last_flow_rate = 0

	if((inoperable()) || !use_power)
		return

	var/power_draw = -1
	var/datum/gas_mixture/environment = loc.return_air()
	var/pressure_delta = 0

	if(environment && air_contents.return_pressure() <= MAX_PUMP_PRESSURE)
		if(external_mode == FALSE)
			pressure_delta = target_pressure - air_contents.return_pressure()
		else
			pressure_delta = environment.return_pressure() - target_pressure

		var/transfer_moles = calculate_transfer_moles(environment, air_contents, pressure_delta, (network)? network.volume : 0)
		transfer_moles = min(transfer_moles, environment.total_moles*air_contents.volume/environment.volume)
		power_draw = pump_gas(src, environment, air_contents, transfer_moles, power_rating)

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power_oneoff(power_draw)

		if(network)
			network.update = 1

	return 1

/obj/machinery/atmospherics/unary/gas_extractor/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(isWrench(O))
		new /obj/item/pipe(loc, src)
		qdel(src)
		return TRUE

	return ..()

/obj/machinery/atmospherics/unary/gas_extractor/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || signal.data["tag"] != id || signal.data["sigtype"]!="command")
		return 0

	if(signal.data["power_toggle"] || signal.data["command"] == "valve_toggle")
		update_use_power(!use_power)
		queue_icon_update()

	if(signal.data[2] == "set_internal_pressure")
		target_pressure = 0
		target_pressure = signal.data["set_internal_pressure"]
		external_mode = FALSE

	if(signal.data[2] == "set_external_pressure")
		target_pressure = 0
		target_pressure = signal.data["set_external_pressure"]
		external_mode = TRUE

	if(signal.data["status"])
		addtimer(new Callback(src, PROC_REF(broadcast_status)), 2, TIMER_UNIQUE)
		return

	addtimer(new Callback(src, PROC_REF(broadcast_status)), 2, TIMER_UNIQUE)

/obj/machinery/atmospherics/unary/gas_extractor/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/unary/gas_extractor/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1
	signal.source = src

	signal.data = list(
		"tag" = id,
		"power" = use_power,
		"external" = target_pressure,
		"sigtype" = "status"

	 )

	radio_connection.post_signal(src, signal)

	return 1
