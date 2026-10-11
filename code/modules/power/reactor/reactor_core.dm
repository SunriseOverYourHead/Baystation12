// Advanced Gas-Cooled Nuclear Reactor - ported from NSV13's RBMK-style reactor (nsv13/code/modules/power/reactor/rbmk.dm),
// re-implemented for Baystation12SOYH's own atmos/power systems (see reactor_process.dm for the full explanation of
// what changed and why). Unlike NSV13's version, this reactor has NO moderator gas input and NO direct power-grid
// hookup - it is a pure fast-reactor-style heat source. It has exactly two working ports: coolant in (south),
// coolant out (north). To turn the hot coolant it produces into electricity, plumb its output toward a
// code/modules/power/turbine.dm compressor/turbine pair (or any other gas-consuming generator) - the reactor itself
// never touches a powernet.
//
// Reactivity model (see reactor_process.dm for the full per-tick math): control_rod_insertion (0-100%, console-set)
// is the operator's dial, but the reaction's actual behavior depends on both the loaded fuel_rod items (more/
// fresher fuel lowers the insertion level needed to go critical) and the loaded control_rod items (their combined
// capacity - count x effectiveness x an integrity curve - determines how much suppression "100%" on the dial can
// actually deliver). A full 5 fresh fuel rods + 5 fresh control rods goes critical at 90% insertion (10%
// withdrawn) - every other threshold is extrapolated from that anchor. If your control rods are missing or spent,
// 100% insertion may not be enough to reach true subcriticality even with a modest fuel load.
//
// Fuel rods being physically present (fuel_rods) is separate from the chamber being "loaded" (see the loaded var
// below) - fission only happens while loaded, and rods can only be inserted/ejected while unloaded. The control
// console's single "load/unload" button toggles all fuel rods into/out of the chamber at once.

#define REACTOR_TEMP_OPERATING 640
// Where integrity loss starts (and the alarm/warning triggers, and the console's "power" gauge reads 100%).
// Raised from 800 to 1200 per explicit request, to match the reactor's real-world-grounded gas-cooled fast
// reactor temperature targets (Gen IV GFR designs run around 1123K/850C core outlet) without immediately eating
// into vessel integrity at normal operating temperatures.
#define REACTOR_TEMP_CRITICAL 1200
#define REACTOR_NO_COOLANT_TOLERANCE 5
// Raised from 10132 to 15000 to match MAX_PUMP_PRESSURE (code/__defines/atmos.dm) - a loop pumped right up to a
// high power pump's own max would otherwise permanently trip the reactor's own overpressure alarm/damage ramp
// during completely normal operation.
#define REACTOR_PRESSURE_CRITICAL_KPA 15000
// Top of the heat/pressure vessel-damage ramps (handle_alerts(), reactor_process.dm) - exactly double their
// respective *_CRITICAL thresholds. Damage is ~0 right at the critical threshold and eases in (quadratically) up
// to a cap at these values, rather than the old flat rate that either didn't apply at all below a fixed
// "meltdown" temperature, or (for pressure) was already pegged at its max the instant the critical threshold was
// crossed. Requested explicitly: "very slow above 100%, speeding up all the way to a cap at 200%."
#define REACTOR_HEAT_DAMAGE_CAP_TEMP 2400
#define REACTOR_PRESSURE_DAMAGE_CAP_KPA 30000
#define REACTOR_MAX_CRITICALITY 3
#define REACTOR_MIN_GAS_LEVEL 5
#define REACTOR_MAX_RODS 5
#define REACTOR_PORT_VOLUME 1000
// Max core heat % at which the fuel rod chamber can be unloaded (see the control console's toggle_loaded action) -
// raised from 10 to 25 per explicit request.
#define REACTOR_UNLOAD_MAX_POWER 25

// Below this integrity %, a rod's contribution starts declining (linearly to 0). At/above it, ~full contribution.
#define REACTOR_CURVE_KNEE 40
// Reference "full healthy set": 5 control rods x 1.0 effectiveness each. Actual control_capacity is measured
// against this to see how much of the console's insertion% a real, possibly-degraded set can actually deliver.
#define REACTOR_MAX_CONTROL_CAPACITY 5.0
// Calibrated so 5 fresh standard fuel rods (fuel_score = 5 x 0.15 x 1.0 = 0.75) go critical at 90% insertion:
// 0.75 * 120 = 90. Scale linearly from there for any other fuel load.
#define REACTOR_CRITICAL_CALIBRATION 120
// Extra multiplier on total heat output per fuel rod loaded beyond the first - rewards spreading the same total
// output across more rods (each one then needs a smaller individual share, and so depletes slower for the same
// total power - see reactor_process.dm).
#define REACTOR_ROD_COUNT_BONUS 0.15
// Converts (how far past critical) x (fuel score) x (rod count bonus) into MEGAWATTS of fission heat production
// this tick (reactor_process.dm's heat_production) - a real physical quantity, not an abstract "core_temp
// units/tick" figure like earlier tunings of this constant assumed. Calibrated so 5 fresh STANDARD fuel rods at
// 0% insertion (criticality_ratio 0.9, fuel_score 0.75, rod_count_bonus 1.6) hit ~40MW:
// 0.9 * 0.75 * 1.6 * 37 = 39.96MW. Denser nitride fuel (fuel_power 0.30, double standard) exceeds this
// considerably (~89MW at the same load) - confirmed intentional, matches nitride's role as the premium tier.
#define REACTOR_HEAT_COEFFICIENT 37
// How many megajoules raise core_temp by one degree - makes core_temp a properly DERIVED "how hot is the metal"
// gauge instead of a free-floating accumulator with no defined thermal mass. heat_production (now real MW, see
// REACTOR_HEAT_COEFFICIENT above) raises core_temp by heat_production/REACTOR_CORE_THERMAL_MASS degrees/tick, and
// the coolant exchange (reactor_process.dm's slowprocess()) debits core_temp by the same real MW/mass conversion
// it uses to compute thermal_output_mw - so what the core generates, what it stores, and what leaves via coolant
// are finally all the same units and actually conserve energy with each other. Set to 1.0 (1MW net = ~1C/sec) to
// keep heat-up pacing similar to what was already tuned before this fix.
#define REACTOR_CORE_THERMAL_MASS 1.0
// Per-tick fuel burn rate at full criticality margin - actual consumption is this x criticality_ratio x
// (fuel_integrity/100), so it naturally slows down as a rod approaches its floor. Lowered 200x from the original 3
// per explicit request ("losing integrity HILLARIOUSLY fast").
#define REACTOR_FUEL_BURN_RATE 0.015
// Per-tick control rod wear at full criticality margin - unlike fuel, this is NOT scaled by the rod's own
// remaining integrity, so control rods deplete linearly and can hit true 0. Lowered 20x from the original 0.15 to
// 0.0075, then doubled back up to 0.015 per explicit request ("taking too long to lose durability"). See
// reactor_process.dm's wear formula for why this still doesn't wear rods down at 0% insertion.
#define REACTOR_CONTROL_WEAR_RATE 0.015

/// Shared integrity->contribution curve for both fuel and control rods: full contribution from 100% down to
/// REACTOR_CURVE_KNEE, declining linearly to 0 below that. For a fuel rod this scales its fission contribution;
/// for a control rod, its suppression effectiveness.
/proc/reactor_integrity_curve(integrity)
	if(integrity >= REACTOR_CURVE_KNEE)
		return 1.0
	return max(0, integrity) / REACTOR_CURVE_KNEE

/obj/machinery/atmospherics/omni/reactor
	name = "advanced gas-cooled nuclear reactor"
	desc = "A fission reactor that heats coolant gas passed through it. Requires fuel rods to run, and control rods to keep the reaction under control."
	// Sprite ported from NSV13 (nsv13/icons/obj/machinery/rbmk.dmi) - state names match 1:1 with on_update_icon() below.
	// Every state is a genuine 96x96 (3x3 tile) image, not a 32x32 sprite - the bound_*/pixel_* block below centers
	// that footprint on this atom's own turf (so loc stays the CENTER tile) and makes the full 3x3 area dense.
	// Since loc is still just the center turf, the inherited omni port logic (get_step(src, dir) in atmos_init(),
	// see omni_base.dm) already connects pipes one tile out from that center - i.e. at the edges of the footprint -
	// with no changes needed there.
	icon = 'icons/obj/machines/power/reactor.dmi'
	icon_state = "reactor_off"
	density = TRUE
	anchored = TRUE
	unacidable = TRUE
	light_color = COLOR_CYAN

	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -32

	tag_north = ATM_OUTPUT
	tag_south = ATM_INPUT

	var/datum/omni_port/coolant_input_port
	var/datum/omni_port/coolant_output_port

	/// "Celsius-equivalent" heat accumulator - not a real core_temp until written into a gas mixture.
	var/core_temp = 0
	var/vessel_integrity = 800
	var/pressure = 0
	/// 0-100. Console-set directly (no gradual convergence). This is the DIAL, not necessarily what's actually
	/// achieved - see effective_insertion. Starts at 100 (safe/off).
	var/control_rod_insertion = 100
	/// What control_rod_insertion actually delivers once the real loaded control rods' combined capacity is
	/// factored in - can be less than control_rod_insertion if rods are missing, spent, or sabotaged. Computed
	/// each tick in reactor_process.dm.
	var/effective_insertion = 100
	/// Insertion % at/above which the currently-loaded fuel can't sustain a chain reaction - computed each tick
	/// from the loaded fuel_rods (reactor_process.dm). Compare against effective_insertion, not
	/// control_rod_insertion, to see if the reactor is actually critical.
	var/critical_threshold = 0
	var/is_critical = FALSE
	/// 0-100+, how close core_temp is to REACTOR_TEMP_CRITICAL. A danger/staging gauge (icon state, console
	/// colors, the fuel-chamber unload threshold) - NOT a real power figure, despite the name. See
	/// thermal_output_mw below for an actual physical quantity.
	var/power = 0
	/// Real thermal power, in megawatts, actually being transferred into the coolant this tick - computed from the
	/// coolant gas's own heat_capacity() AND capped by how much energy core_temp actually has stored
	/// (REACTOR_CORE_THERMAL_MASS), then genuinely debited from core_temp by that same amount
	/// (reactor_process.dm's slowprocess()) - a real, energy-conserving Joules/sec figure, not a percentage and
	/// not disconnected from what the core itself loses. Reads 0 whenever coolant isn't flowing, even if the core
	/// is red hot - with nothing carrying heat away, no thermal power is actually being delivered anywhere.
	var/thermal_output_mw = 0

	var/list/fuel_rods = list()
	var/list/control_rods = list()
	/// Whether the loaded fuel_rods have been pushed into the reaction chamber. Starts FALSE - fuel rods can sit in
	/// their bay unloaded indefinitely with zero fission and zero reactor-level radiation shielding penalty (each
	/// rod instead radiates on its own, per fuel_rod.dm's Process(), exactly as if it were sitting outside the
	/// reactor entirely - "unshielded"). Fuel rods can only be inserted/ejected while unloaded (reactor_core.dm's
	/// use_tool(), the control console's eject_fuel), and can only be unloaded again once power has dropped to
	/// REACTOR_UNLOAD_MAX_POWER or below - see the control console's toggle_loaded action.
	var/loaded = FALSE

	var/gas_absorption_effectiveness = 0.5
	var/gas_absorption_constant = 0.5
	var/no_coolant_ticks = 0

	var/slagged = FALSE
	var/warning = FALSE
	var/next_warning = 0
	var/next_slowprocess = 0

	var/last_coolant_temperature = 0
	var/last_output_temperature = 0

/obj/machinery/atmospherics/omni/reactor/Initialize()
	. = ..()
	icon_state = "reactor_off"
	gas_absorption_effectiveness = rand(5, 6) / 10
	gas_absorption_constant = gas_absorption_effectiveness
	for(var/datum/omni_port/P in ports)
		P.air.volume = REACTOR_PORT_VOLUME

/obj/machinery/atmospherics/omni/reactor/sort_ports()
	for(var/datum/omni_port/P in ports)
		switch(P.dir)
			if(SOUTH)
				coolant_input_port = P
			if(NORTH)
				coolant_output_port = P

// omni_base.dm's own atmos_init() scans exactly ONE tile out from src's own position for each port's neighbor -
// correct for a normal 1x1 machine, but wrong here: this reactor's bound_width/height (see the var block above)
// make it occupy a full 3x3 area centered on its own turf, so the tile 1 step out from center is one of the
// reactor's OWN occupied tiles (BYOND's turf-content enumeration includes a multi-tile atom on every turf its
// bounding box covers), not a tile outside it - the reactor would find itself as the "neighbor" on that tile and
// never look any further. Ports need to look 2 tiles out from center (1 tile past the edge of the 3x3 footprint)
// instead - i.e. pipes connect to the tile immediately OUTSIDE the reactor's footprint, not the edge tile of the
// footprint itself.
/obj/machinery/atmospherics/omni/reactor/atmos_init()
	atmos_initalized = TRUE
	for(var/datum/omni_port/P in ports)
		if(P.node || P.mode == 0)
			continue
		var/turf/step_turf = get_step(get_step(src, P.dir), P.dir)
		if(!step_turf)
			continue
		for(var/obj/machinery/atmospherics/target in step_turf)
			if(target == src)
				continue
			if(target.initialize_directions & get_dir(target, src))
				if(check_connect_types(target, src))
					P.node = target
					break

	for(var/datum/omni_port/P in ports)
		P.update = 1

	update_ports()

/obj/machinery/atmospherics/omni/reactor/proc/has_fuel()
	return length(fuel_rods)

/obj/machinery/atmospherics/omni/reactor/examine(mob/user, distance, is_adjacent)
	. = ..()
	if(!is_adjacent)
		return
	var/percent = vessel_integrity / initial(vessel_integrity) * 100
	switch(percent)
		if(0 to 10)
			. += SPAN_DANGER("[src]'s seals are dangerously warped, with cracks visible all over the reactor vessel!")
		if(10 to 40)
			. += SPAN_DANGER("[src]'s seals are heavily warped and cracked!")
		if(40 to 60)
			. += SPAN_WARNING("[src]'s seals are holding, but barely. Micro-fractures are forming in the vessel.")
		if(60 to 80)
			. += SPAN_WARNING("[src]'s seals are intact, but worn. No visible cracks yet.")
		if(80 to 95)
			. += SPAN_NOTICE("[src]'s seals are in good shape.")
		else
			. += SPAN_NOTICE("[src]'s seals look factory new.")

/obj/machinery/atmospherics/omni/reactor/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(istype(I, /obj/item/fuel_rod))
		if(loaded)
			to_chat(user, SPAN_WARNING("[src]'s fuel chamber is loaded - unload it from the control console first."))
			return TRUE
		if(length(fuel_rods) >= REACTOR_MAX_RODS)
			to_chat(user, SPAN_WARNING("[src]'s fuel bay is already full."))
			return TRUE
		to_chat(user, SPAN_NOTICE("You start to load [I] into [src]..."))
		// DO_PUBLIC_UNIQUE locks out a second overlapping do_after on this same reactor - without it, spam-clicking
		// while holding one rod fires multiple concurrent do_afters that each independently pass unEquip()/add the
		// rod once they resolve, duplicating it in fuel_rods. Re-checking loaded/capacity after the delay too, in
		// case either changed during the wait (e.g. two different rods queued back to back).
		if(do_after(user, 1.5 SECONDS, src, DO_PUBLIC_UNIQUE) && !loaded && length(fuel_rods) < REACTOR_MAX_RODS)
			if(!user.unEquip(I, src))
				return TRUE
			fuel_rods += I
		return TRUE

	if(istype(I, /obj/item/control_rod))
		// Control rods are deliberately hot-swappable, unlike fuel - a safety valve so a reactor that's overheating
		// because someone loaded fresh fuel and forgot to load/replace control rods isn't unrecoverable. No power
		// gate here on purpose.
		if(length(control_rods) >= REACTOR_MAX_RODS)
			to_chat(user, SPAN_WARNING("[src]'s control rod bay is already full."))
			return TRUE
		to_chat(user, SPAN_NOTICE("You start to load [I] into [src]..."))
		// Same DO_PUBLIC_UNIQUE duplication guard as the fuel_rod branch above.
		if(do_after(user, 1.5 SECONDS, src, DO_PUBLIC_UNIQUE) && length(control_rods) < REACTOR_MAX_RODS)
			if(!user.unEquip(I, src))
				return TRUE
			control_rods += I
		return TRUE

	if(isMultitool(I))
		if(!id_tag)
			to_chat(user, SPAN_WARNING("[src] has no ID tag set - nothing to store."))
			return TRUE
		var/obj/item/device/multitool/M = I
		M.stored_id_tag = id_tag
		to_chat(user, SPAN_NOTICE("You store [src]'s ID tag ('[id_tag]') on [I]."))
		return TRUE

	if(isWelder(I))
		if(slagged)
			to_chat(user, SPAN_WARNING("[src] is slagged beyond repair."))
			return TRUE
		if(power >= 20)
			to_chat(user, SPAN_WARNING("You cannot repair [src] while it's running above 20% output."))
			return TRUE
		if(vessel_integrity >= initial(vessel_integrity))
			to_chat(user, SPAN_NOTICE("[src]'s vessel is already in perfect condition."))
			return TRUE
		var/obj/item/weldingtool/WT = I
		if(!WT.can_use(1, user))
			return TRUE
		to_chat(user, SPAN_NOTICE("You begin repairing [src]'s vessel..."))
		// Same DO_PUBLIC_UNIQUE duplication guard as the rod branches above - without it, spam-clicking with a
		// welder could stack multiple overlapping repairs for free.
		if(do_after(user, 5 SECONDS, src, DO_PUBLIC_UNIQUE) && vessel_integrity < initial(vessel_integrity) && WT.remove_fuel(1, user))
			vessel_integrity = clamp(vessel_integrity + 20, 0, initial(vessel_integrity))
			to_chat(user, SPAN_NOTICE("You patch up some of [src]'s damage."))
		return TRUE
	// This is a fixed, indestructible installation - never allow it to be unwrenched/deconstructed.
	return TRUE

// The reactor's own meltdown()/blowout() (reactor_process.dm) trigger real explosions centered on its own tile -
// without this, the base /atom/ex_act() (code/game/atoms.dm) would run its health-based explosion damage on the
// reactor and could delete it outright, undoing the failure state's own vessel_integrity/slagged bookkeeping.
// vessel_integrity is a bespoke stat this type tracks itself, not the generic machine health system, so being
// immune to ex_act() doesn't skip any real damage accounting - vessel_integrity is only ever touched in
// reactor_process.dm's own handle_alerts().
/obj/machinery/atmospherics/omni/reactor/ex_act(severity, turf_breaker)
	return

/obj/machinery/atmospherics/omni/reactor/on_update_icon()
	if(slagged)
		icon_state = "reactor_slagged"
		return
	if(!has_fuel() || !loaded)
		icon_state = "reactor_off"
		return
	switch(core_temp)
		if(0 to 200)
			icon_state = "reactor_on"
		if(200 to REACTOR_TEMP_OPERATING)
			icon_state = "reactor_hot"
		if(REACTOR_TEMP_OPERATING to 750)
			icon_state = "reactor_veryhot"
		if(750 to REACTOR_TEMP_CRITICAL)
			icon_state = "reactor_overheat"
		else
			icon_state = "reactor_meltdown"

// Called from the control console's toggle_loaded action when the fuel chamber goes from unloaded to loaded with
// fuel present.
/obj/machinery/atmospherics/omni/reactor/proc/start_up()
	if(slagged)
		return
	// control_rod_insertion is deliberately left untouched here - it starts at 100 (safe) and stays there until
	// an operator dials it down from a console. Loading the chamber alone shouldn't start a reaction.
	set_light(10)
	playsound(loc, 'sound/machines/warning-buzzer.ogg', 100)
	update_icon()

/obj/machinery/atmospherics/omni/reactor/proc/shut_down()
	set_light(0)
	control_rod_insertion = 100
	core_temp = 0
	update_icon()
	// handle_alerts() (reactor_process.dm) calls shut_down() and returns BEFORE reaching its own "clear the
	// warning" branch - without this, a reactor that idles all the way down to core_temp<=0 with no fuel while an
	// alert was still active would leave warning permanently TRUE and never raise the FALSE event, leaving any
	// nuclear reactor alarm listening (code/modules/supermatter/supermatter.dm) stuck on forever.
	if(warning)
		warning = FALSE
		light_color = COLOR_CYAN
		GLOB.reactor_status.raise_event(src, FALSE)
