// The reactor's single console - merges what used to be two separate machines (a control console and a
// statistics console) into one, per explicit request. The TGUI interface (ReactorControl.tsx) renders the old
// control panel and the old stat graphs side by side as two columns in one doubled-width window; the stat
// sampling loop below is the old reactor_stats_console.dm's Process(), unchanged except for living here now.

/obj/machinery/computer/reactor/control
	name = "reactor control console"
	desc = "Controls a nuclear reactor's control rod insertion and fuel chamber loading, and monitors its pressure, thermal output, and coolant temperatures over time."

	var/next_stat_interval = 0
	var/list/pressureData = list()
	var/list/thermalOutputData = list()
	var/list/coolantInData = list()
	var/list/coolantOutData = list()

/obj/machinery/computer/reactor/control/Process()
	..()
	if(!reactor)
		return
	if(world.time < next_stat_interval)
		return
	next_stat_interval = world.time + 1 SECONDS

	pressureData += reactor.pressure
	thermalOutputData += reactor.thermal_output_mw
	coolantInData += reactor.last_coolant_temperature
	coolantOutData += reactor.last_output_temperature

	if(pressureData.len > 100)
		pressureData.Cut(1, 2)
	if(thermalOutputData.len > 100)
		thermalOutputData.Cut(1, 2)
	if(coolantInData.len > 100)
		coolantInData.Cut(1, 2)
	if(coolantOutData.len > 100)
		coolantOutData.Cut(1, 2)

/obj/machinery/computer/reactor/control/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "ReactorControl", name, ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/reactor/control/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = !!reactor
	if(!reactor)
		return data

	data["insertion"] = reactor.control_rod_insertion
	data["effectiveInsertion"] = round(reactor.effective_insertion)
	data["criticalThreshold"] = round(reactor.critical_threshold)
	data["isCritical"] = reactor.is_critical
	data["slagged"] = reactor.slagged
	data["power"] = reactor.power
	data["thermalOutputMW"] = round(reactor.thermal_output_mw, 0.1)
	data["pressure"] = reactor.pressure
	data["vesselIntegrity"] = round(reactor.vessel_integrity / initial(reactor.vessel_integrity) * 100)
	data["loaded"] = reactor.loaded
	data["canUnload"] = reactor.power <= REACTOR_UNLOAD_MAX_POWER

	var/list/fuel = list()
	for(var/obj/item/fuel_rod/FR in reactor.fuel_rods)
		fuel += list(list(
			"ref" = "\ref[FR]",
			"name" = FR.name,
			"integrity" = round(FR.fuel_integrity),
		))
	data["fuelRods"] = fuel

	var/list/control = list()
	for(var/obj/item/control_rod/CR in reactor.control_rods)
		control += list(list(
			"ref" = "\ref[CR]",
			"name" = CR.name,
			"integrity" = round(CR.rod_integrity),
		))
	data["controlRods"] = control

	data["pressureData"] = pressureData
	data["thermalOutputData"] = thermalOutputData
	data["coolantInData"] = coolantInData
	data["coolantOutData"] = coolantOutData

	return data

/obj/machinery/computer/reactor/control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !reactor)
		return

	switch(action)
		if("set_insertion")
			reactor.control_rod_insertion = clamp(text2num(params["target"]), 0, 100)
			return TRUE
		if("toggle_loaded")
			if(reactor.loaded)
				if(reactor.power > REACTOR_UNLOAD_MAX_POWER)
					to_chat(usr, SPAN_WARNING("[reactor] is too hot to safely unload - wait for thermal output to drop to [REACTOR_UNLOAD_MAX_POWER]% or below."))
					return TRUE
				reactor.loaded = FALSE
				reactor.update_icon()
				to_chat(usr, SPAN_NOTICE("You retract [reactor]'s fuel rods from the reaction chamber."))
			else
				reactor.loaded = TRUE
				if(reactor.has_fuel())
					reactor.start_up()
				to_chat(usr, SPAN_NOTICE("You push [reactor]'s fuel rods into the reaction chamber."))
			return TRUE
		if("eject_fuel")
			if(reactor.loaded)
				to_chat(usr, SPAN_WARNING("[reactor]'s fuel chamber is loaded - unload it first."))
				return TRUE
			var/obj/item/fuel_rod/FR = locate(params["ref"]) in reactor.fuel_rods
			if(FR)
				reactor.fuel_rods -= FR
				FR.forceMove(get_turf(reactor))
			return TRUE
		if("eject_control")
			// Control rods are hot-swappable, unlike fuel - no loaded gate, see reactor_core.dm's use_tool().
			var/obj/item/control_rod/CR = locate(params["ref"]) in reactor.control_rods
			if(CR)
				reactor.control_rods -= CR
				CR.forceMove(get_turf(reactor))
			return TRUE
