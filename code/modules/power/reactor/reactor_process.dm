// Core simulation tick, alert handling, and failure states for the reactor (see reactor_core.dm for vars/machine
// setup). Adapted from NSV13's rbmk.dm slowprocess()/handle_alerts()/meltdown()/blowout(), with the moderator gas
// system removed entirely (see reactor_core.dm's header) - reactivity is driven directly by control_rod_insertion
// and loaded fuel_rod items, and the coolant loop is a simple heat-in/heat-out pass-through with no power-grid
// code at all (an external turbine, code/modules/power/turbine.dm, is expected to convert the hot output gas to
// power).

// Observer-pattern broadcast of this reactor's danger state, mirroring GLOB.supermatter_status exactly
// (code/datums/observation/supermatter_status.dm) - the rotating alarm that used to watch the supermatter now
// watches this instead (see code/modules/supermatter/supermatter.dm's /obj/machinery/rotating_alarm/supermatter).
GLOBAL_TYPED_NEW(reactor_status, /singleton/observ/reactor_status)

/singleton/observ/reactor_status
	name = "Nuclear reactor status changed"
	expected_type = /obj/machinery/atmospherics/omni/reactor

/obj/machinery/atmospherics/omni/reactor/Destroy()
	if(warning)
		GLOB.reactor_status.raise_event(src, FALSE)
	return ..()

/obj/machinery/atmospherics/omni/reactor/Process()
	if(slagged)
		return

	// Self-heal an unlinked port. code/controllers/subsystems/machines.dm's setup_atmos_machinery() only calls
	// atmos_init()/build_network() ONCE, on whatever atmos machines exist at world init - anything placed after
	// that (admin-spawned, or anything else built outside the normal pipe/construction.dm flow, which explicitly
	// re-triggers atmos_init() on both sides of a new connection) never gets linked to its neighbors at all.
	// Both procs are safe to call repeatedly: they only touch ports that don't already have a node/network.
	if((coolant_input_port && !coolant_input_port.node) || (coolant_output_port && !coolant_output_port.node))
		atmos_init()
		build_network()

	if(world.time < next_slowprocess)
		return
	next_slowprocess = world.time + 1 SECONDS
	slowprocess()

/obj/machinery/atmospherics/omni/reactor/proc/slowprocess()
	if(!coolant_input_port || !coolant_output_port)
		return

	var/datum/gas_mixture/coolant_in = coolant_input_port.air
	var/datum/gas_mixture/coolant_out = coolant_output_port.air

	// Coolant loop - heat whatever gas is passed through, no gas is created or consumed beyond what's plumbed in.
	var/input_moles = coolant_in.get_total_moles()
	if(input_moles >= REACTOR_MIN_GAS_LEVEL)
		last_coolant_temperature = KELVIN_TO_CELSIUS(coolant_in.temperature)
		var/datum/gas_mixture/removed = coolant_in.remove_ratio(1)
		if(removed)
			// Real heat-exchanger direction: heat flows down the gradient between the core and the incoming
			// coolant. Colder coolant than the core ACTUALLY COOLS it; coolant hotter than the core adds
			// parasitic heat instead. Both directions now go through the SAME real energy accounting: compute the
			// actual Joules moved using the removed gas's own heat_capacity(), debit/credit core_temp by that same
			// amount (via REACTOR_CORE_THERMAL_MASS, reactor_core.dm), and set the outgoing gas's temperature rise
			// from what it actually received - not force-copied to core_temp. thermal_output_mw is now genuinely
			// the same number core_temp loses, not a disconnected figure computed from the raw gap.
			var/removed_heat_capacity = removed.heat_capacity()
			var/gap = core_temp - last_coolant_temperature
			if(gap >= 0)
				// Cooling the core: capped at how much energy the core actually has stored (core_temp *
				// REACTOR_CORE_THERMAL_MASS) - can't extract more than what's there, unlike the old model where
				// the outgoing gas was simply teleported to core_temp regardless of the core's own energy budget.
				var/potential_extraction_mw = (gap * removed_heat_capacity / 1e6) * gas_absorption_effectiveness
				var/available_mw = core_temp * REACTOR_CORE_THERMAL_MASS
				thermal_output_mw = min(potential_extraction_mw, available_mw)
				core_temp -= thermal_output_mw / REACTOR_CORE_THERMAL_MASS
				removed.temperature += (thermal_output_mw * 1e6) / removed_heat_capacity
			else
				// Parasitic heating: no cap needed - bounded by the incoming coolant's own finite heat content,
				// already fully captured by removed_heat_capacity * gap above.
				var/parasitic_mw = (-gap * removed_heat_capacity / 1e6) * gas_absorption_effectiveness
				thermal_output_mw = -parasitic_mw
				core_temp += parasitic_mw / REACTOR_CORE_THERMAL_MASS
				removed.temperature -= (parasitic_mw * 1e6) / removed_heat_capacity
			coolant_out.merge(removed)
			// Tell both pipe networks their member gas changed, same as circulator.dm's return_transfer_air() does
			// for its own input side - otherwise /datum/pipe_network/Process() (datum_pipe_network.dm) never
			// re-equalizes and the port we just drained never gets refilled from the rest of the network. Both
			// sides need marking here (unlike the circulator, which only ever touches its own input air1 - its
			// output air2 is written by an external caller, a TEG, which marks network2 itself) since we're the
			// ones mutating both coolant_in and coolant_out directly.
			if(coolant_input_port.network)
				coolant_input_port.network.update = 1
			if(coolant_output_port.network)
				coolant_output_port.network.update = 1
		no_coolant_ticks = max(0, no_coolant_ticks - 2)
	else
		// Nothing's flowing, so no thermal power is actually being delivered anywhere - even if the core itself
		// is red hot. Matches thermal_output_mw's own doc comment in reactor_core.dm.
		thermal_output_mw = 0
		if(has_fuel())
			no_coolant_ticks++
			if(no_coolant_ticks > REACTOR_NO_COOLANT_TOLERANCE)
				core_temp += core_temp / 500
				vessel_integrity -= core_temp / 200

	last_output_temperature = KELVIN_TO_CELSIUS(coolant_out.temperature)
	pressure = coolant_out.return_pressure()
	power = clamp((core_temp / REACTOR_TEMP_CRITICAL) * 100, 0, 999)

	// Criticality model. control_rod_insertion is the console DIAL; effective_insertion is what the currently
	// loaded control rods can actually deliver (their combined capacity - count x effectiveness x integrity curve
	// - measured against REACTOR_MAX_CONTROL_CAPACITY, the "5 fresh rods" reference). critical_threshold is how
	// high insertion needs to be to stay subcritical, and rises with more/fresher fuel loaded (5 fresh fuel rods
	// puts it at exactly 90% - REACTOR_CRITICAL_CALIBRATION is calibrated to that anchor). The reactor is
	// critical whenever effective_insertion falls below critical_threshold - which is why missing or spent
	// control rods can leave you unable to reach true subcriticality even at 100% on the dial, if there's enough
	// fuel loaded to compensate.
	var/control_capacity = 0
	for(var/obj/item/control_rod/CR in control_rods)
		control_capacity += CR.rod_effectiveness * reactor_integrity_curve(CR.rod_integrity)
	effective_insertion = control_rod_insertion * clamp(control_capacity / REACTOR_MAX_CONTROL_CAPACITY, 0, 1)

	var/fuel_score = 0
	for(var/obj/item/fuel_rod/FR in fuel_rods)
		fuel_score += FR.fuel_power * reactor_integrity_curve(FR.fuel_integrity)
	critical_threshold = clamp(fuel_score * REACTOR_CRITICAL_CALIBRATION, 0, 100)

	var/criticality_ratio = max(0, critical_threshold - effective_insertion) / 100
	// Nothing reacts at all while the chamber is unloaded - fuel rods can sit in their bay indefinitely with zero
	// fission (see reactor_core.dm's loaded var). This also zeroes fuel depletion and control rod wear below, both
	// of which are scaled by criticality_ratio.
	if(!loaded)
		criticality_ratio = 0
	is_critical = has_fuel() && (criticality_ratio > 0)

	// Heat splits across loaded fuel rods proportional to each one's own share of fuel_score (a heavily-worn rod,
	// whose curve has dropped, pulls less weight) - but the TOTAL gets an explicit bonus for rod count on top of
	// that (REACTOR_ROD_COUNT_BONUS), so spreading the same output across more rods means each individual rod
	// needs a smaller personal share to hit the same total heat, and so depletes slower for it. That's what
	// rewards loading many rods and running close to criticality instead of running fewer rods harder - at the
	// cost of putting the same (or more) total load on the control rods either way.
	var/heat_production = 0
	if(is_critical)
		var/rod_count_bonus = 1 + (length(fuel_rods) - 1) * REACTOR_ROD_COUNT_BONUS
		var/total_heat = criticality_ratio * fuel_score * rod_count_bonus * REACTOR_HEAT_COEFFICIENT
		for(var/obj/item/fuel_rod/FR in fuel_rods)
			var/share = fuel_score > 0 ? (FR.fuel_power * reactor_integrity_curve(FR.fuel_integrity)) / fuel_score : 0
			heat_production += total_heat * share
			// Proportional to what's left (fuel_integrity/100) as well as current activity - a real decay curve,
			// so a rod's own burn rate slows as it approaches REACTOR_INTEGRITY_FLOOR instead of hitting a wall.
			FR.deplete(REACTOR_FUEL_BURN_RATE * criticality_ratio * (FR.fuel_integrity / 100))

	// Control rods deplete linearly (not proportional to their own remaining integrity, unlike fuel) and CAN hit
	// true 0 - "fixed rate depending on reactor status." Wear needs BOTH criticality_ratio (there has to be a
	// chain reaction to absorb neutrons from - a fully subcritical, idling reactor doesn't wear its control rods
	// down at all) AND effective_insertion (the rods have to actually be in the neutron flux to absorb anything).
	// Without that second factor, rods withdrawn all the way to 0% insertion - i.e. sitting completely outside the
	// core - would still wear at criticality_ratio's own peak value (since pulling rods out is what MAKES the
	// core critical in the first place), which makes no physical sense: a rod that isn't in the core at all can't
	// be worn down by it.
	for(var/obj/item/control_rod/CR in control_rods)
		CR.rod_integrity = max(CR.rod_integrity - (REACTOR_CONTROL_WEAR_RATE * criticality_ratio * (effective_insertion / 100)), 0)

	core_temp += has_fuel() ? heat_production : -10
	core_temp = max(core_temp, 0)

	// Reactor-level radiation while loaded and operating scales with both current fission rate and how much fuel
	// is loaded (more assemblies means more total fissile/fission-product inventory contributing background
	// radiation, beyond just the rate of new fissions) - this is the "shielded" source, separate from each fuel
	// rod's OWN radioactivity (fuel_rod.dm), which stays suppressed while the chamber is loaded (the reactor is
	// assumed to shield it) and switches on again - unshielded, at each rod's own individual strength - the moment
	// the chamber is unloaded, even if the rods are still physically sitting in their bay. Re-radiating every tick
	// (instead of relying on a one-shot pulse) keeps this consistent instead of letting SSradiation's own decay
	// silently fade it out between insertions.
	if(loaded && has_fuel() && core_temp > 0)
		SSradiation.radiate(src, core_temp * length(fuel_rods) * 0.5)

	handle_alerts()
	update_icon()

/obj/machinery/atmospherics/omni/reactor/proc/handle_alerts()
	if(core_temp <= 0 && !has_fuel())
		shut_down()
		return

	var/alert = FALSE

	if(core_temp >= REACTOR_TEMP_CRITICAL)
		alert = TRUE
		// Quadratic ease-in from REACTOR_TEMP_CRITICAL (ratio 0, effectively no damage) up to
		// REACTOR_HEAT_DAMAGE_CAP_TEMP (ratio 1, capped at initial(vessel_integrity)/40 - the same cap the old
		// flat rate used). Previously this only activated at all once core_temp hit a separate, higher fixed
		// "meltdown" temperature, and even then scaled linearly - a sudden, harsh onset. Now damage starts the
		// moment the alarm does, but stays negligible until you're well past it.
		var/heat_ratio = clamp((core_temp - REACTOR_TEMP_CRITICAL) / (REACTOR_HEAT_DAMAGE_CAP_TEMP - REACTOR_TEMP_CRITICAL), 0, 1)
		var/temp_damage = (initial(vessel_integrity) / 40) * (heat_ratio ** 2)
		if(temp_damage > 0)
			vessel_integrity -= temp_damage
			if(vessel_integrity <= temp_damage)
				meltdown()
				return

	if(core_temp < -200)
		core_temp = -200

	if(pressure >= REACTOR_PRESSURE_CRITICAL_KPA)
		alert = TRUE
		shake_animation(3)
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 100, TRUE)
		// Same quadratic ease-in as the heat damage above, from REACTOR_PRESSURE_CRITICAL_KPA up to a cap at
		// REACTOR_PRESSURE_DAMAGE_CAP_KPA (same cap as before, initial(vessel_integrity)/45). Previously this
		// branch could only ever be reached with pressure already >= REACTOR_PRESSURE_CRITICAL_KPA, so
		// pressure/100 was always far past the cap - every single overpressure tick dealt max damage instantly,
		// the harshest possible onset.
		var/pressure_ratio = clamp((pressure - REACTOR_PRESSURE_CRITICAL_KPA) / (REACTOR_PRESSURE_DAMAGE_CAP_KPA - REACTOR_PRESSURE_CRITICAL_KPA), 0, 1)
		var/pressure_damage = (initial(vessel_integrity) / 45) * (pressure_ratio ** 2)
		vessel_integrity -= pressure_damage
		if(vessel_integrity <= pressure_damage)
			blowout()
			return

	if(warning)
		if(!alert)
			warning = FALSE
			light_color = COLOR_CYAN
			set_light(10)
			GLOB.reactor_status.raise_event(src, FALSE)
	else if(alert && world.time >= next_warning)
		next_warning = world.time + 30 SECONDS
		warning = TRUE
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 100, TRUE)
		visible_message(SPAN_DANGER("[src] blares a warning alarm!"))
		light_color = COLOR_RED
		set_light(10)
		GLOB.reactor_status.raise_event(src, TRUE)

// Failure 1: overheat. Destroys the reactor, spreads radioactive sludge, and leaves a lingering radiation source.
// explosion() range below is halved from 20 to 10 per explicit request - explosion()'s "range" arg
// (code/game/objects/explosion.dm) is what actually controls both blast radius AND how much of that radius falls
// into higher-severity rings (the max_power tier just sets the ratio split), so scaling range directly scales
// both damage and radius together. empulse() left untouched - that's an EMP pulse radius, not the explosion.
/obj/machinery/atmospherics/omni/reactor/proc/meltdown()
	set waitfor = FALSE
	if(slagged)
		return
	slagged = TRUE
	update_icon()

	visible_message(SPAN_DANGER("[src] shudders and lets out a horrible metallic hissing!"))
	playsound(loc, 'sound/machines/warning-buzzer.ogg', 100)

	SSradiation.radiate(src, 15000)

	var/turf/T = get_turf(src)
	for(var/datum/omni_port/P in ports)
		if(!P.air)
			continue
		P.air.temperature = (core_temp * 2) + T0C
		T.assume_air(P.air)

	explosion(T, 10, EX_ACT_HEAVY)
	empulse(T, 50, 100)

	spread_nuclear_waste(T, 3, TRUE)

// Failure 2: overpressure. Rarer, more dangerous - always melts down too.
/obj/machinery/atmospherics/omni/reactor/proc/blowout()
	var/turf/T = get_turf(src)
	explosion(T, 25, EX_ACT_DEVASTATING)
	empulse(T, 100, 200)
	meltdown()
