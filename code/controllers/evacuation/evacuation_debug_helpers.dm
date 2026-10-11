// Small helpers for code/modules/admin/verbs/starmap_debug.dm - kept in this directory (rather than alongside the
// rest of that panel) specifically because EVAC_IDLE/PREPPING/etc are #undef'd at the end of this module (see
// ~evac.dm) and aren't visible outside it.

/// Finds whichever timestamp the evac controller's current state is actually waiting on - see process() in
/// evacuation.dm, which polls exactly these vars already.
/proc/get_evac_next_time(datum/evacuation_controller/EC)
	if (!EC)
		return 0
	switch (EC.state)
		if (EVAC_PREPPING)
			return EC.evac_ready_time
		if (EVAC_LAUNCHING)
			return EC.evac_launch_time
		if (EVAC_IN_TRANSIT)
			return EC.evac_arrival_time
		if (EVAC_COOLDOWN)
			return EC.evac_cooldown_time
	return 0

/proc/set_evac_next_time(datum/evacuation_controller/EC, new_time)
	if (!EC)
		return
	switch (EC.state)
		if (EVAC_PREPPING)
			EC.evac_ready_time = new_time
		if (EVAC_LAUNCHING)
			EC.evac_launch_time = new_time
		if (EVAC_IN_TRANSIT)
			EC.evac_arrival_time = new_time
		if (EVAC_COOLDOWN)
			EC.evac_cooldown_time = new_time
