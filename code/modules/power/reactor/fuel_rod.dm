// Standard tier is a U-Pu-Zr metallic alloy fuel (the classic fast-reactor fuel used in real designs like EBR-II/
// IFR - good thermal conductivity, easy to reprocess, but lower fissile density than a ceramic fuel). The upgrade
// tier is Uranium Nitride (UN) - a denser, higher-melting-point ceramic fuel favored in modern advanced fast
// reactor concepts for its combination of high fissile density AND good thermal conductivity (unlike oxide fuels).
//
// Depletion model: fuel_integrity runs 100 (fresh) down to a small nonzero floor (REACTOR_INTEGRITY_FLOOR,
// reactor_core.dm) - consumption each tick is proportional to how much is left (reactor_process.dm), so a rod
// asymptotically approaches empty and never fully depletes or converts into a different item. A rod's own
// contribution to fission rate follows a piecewise curve based on its current fuel_integrity
// (reactor_integrity_curve(), reactor_core.dm): full contribution from 100% down to 40%, declining below that.
//
// Once a rod has actually been burned at all (integrity below 100%), it becomes genuinely radioactive on its own -
// see Process() below - but only while the reactor's chamber isn't loaded (reactor_core.dm's loaded var). While
// loaded, the reactor is assumed to shield it and emits its own separate, reactor-level radiation instead
// (reactor_process.dm). The moment the chamber is unloaded - even with rods still physically sitting in their
// bay - that shielding assumption no longer holds and each rod goes back to irradiating on its own, unshielded.

#define FUEL_ROD_RAD_COEFFICIENT 3000 // scaling for "intensely radioactive" once burned and ejected

/obj/item/fuel_rod
	name = "U-Pu-Zr fuel rod"
	desc = "A titanium-sheathed rod containing a metallic uranium-plutonium-zirconium alloy slug. The classic fast-reactor fuel - decent thermal conductivity and easy to reprocess once spent, at the cost of a lower fissile density than a ceramic fuel."
	// Sprite ported from NSV13 (nsv13/icons/obj/control_rod.dmi), shared with control_rod.dm.
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "irradiated"
	w_class = ITEM_SIZE_HUGE

	/// 100 (fresh) down to REACTOR_INTEGRITY_FLOOR - never fully depletes, never converts to a different item.
	var/fuel_integrity = 100
	/// How much heat this rod can contribute per tick at 100% integrity and full reactor criticality - see
	/// reactor_process.dm.
	var/fuel_power = 0.15

/obj/item/fuel_rod/Initialize(mapload)
	. = ..()
	if(fuel_integrity < 100)
		START_PROCESSING(SSobj, src)

/obj/item/fuel_rod/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/// Only actually irradiates the environment once it's actually been burned at all (a never-used rod is inert) and
/// while it isn't shielded by a loaded reactor - see the header comment above.
/obj/item/fuel_rod/Process()
	if(fuel_integrity >= 100)
		return PROCESS_KILL
	var/obj/machinery/atmospherics/omni/reactor/R = loc
	if(istype(R) && R.loaded)
		return
	SSradiation.radiate(src, ((100 - fuel_integrity) / 100) * FUEL_ROD_RAD_COEFFICIENT)

/// Burns fuel_integrity down by amount (reactor_process.dm scales amount by current reactor activity and this
/// rod's own remaining integrity already, so the proportional-to-what's-left curve lives on the caller side) -
/// this just applies the floor and starts per-item radiation processing the first time a rod actually gets used.
/obj/item/fuel_rod/proc/deplete(amount)
	if(amount <= 0)
		return
	var/was_fresh = (fuel_integrity >= 100)
	fuel_integrity = max(fuel_integrity - amount, REACTOR_INTEGRITY_FLOOR)
	if(was_fresh && fuel_integrity < 100)
		START_PROCESSING(SSobj, src)

/obj/item/fuel_rod/nitride
	name = "uranium nitride fuel rod"
	desc = "A titanium-sheathed rod packed with dense uranium nitride ceramic pellets. Higher fissile density and better thermal conductivity than a metallic fuel slug, at the cost of being much harder to fabricate."
	icon_state = "inferior"
	fuel_power = 0.30

// Kept as mapper/admin-spawnable "already well-used" flavor variants, even though nothing converts a rod into
// these automatically anymore (fuel_integrity just asymptotically approaches its floor on the same item).
/obj/item/fuel_rod/depleted
	name = "well-used U-Pu-Zr fuel rod"
	desc = "A highly radioactive fuel rod, its metallic alloy fuel slug mostly transmuted into fission products."
	icon_state = "normal"
	fuel_power = 0.075
	fuel_integrity = 10

/obj/item/fuel_rod/depleted/nitride
	name = "well-used uranium nitride fuel rod"
	desc = "A highly radioactive fuel rod, its ceramic fuel pellets mostly transmuted into fission products."
	fuel_power = 0.075
