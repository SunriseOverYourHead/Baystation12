// Control rods (renamed back from "moderator rod" - NSV13's own original name for this item, control_rods.dm,
// before this port's earlier "fast reactor" pass repurposed it - see reactor_core.dm's header). Loaded physically
// into the reactor's rod bay, same as fuel rods. Reactivity is now set directly via control_rod_insertion (a
// console-controlled 0-100% dial, see reactor_process.dm) rather than these rods' own rod_effectiveness stat -
// that var is kept for flavor/future use but isn't currently read by the reactivity formula.

/obj/item/control_rod
	name = "reactor control rod"
	desc = "A neutron-absorbing control rod for a nuclear reactor. Insert into a reactor's rod bay - insertion depth is set remotely from a control console."
	// Sprite ported from NSV13 (nsv13/icons/obj/control_rod.dmi), shared with fuel_rod.dm.
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "normal"
	w_class = ITEM_SIZE_HUGE

	var/rod_integrity = 100
	var/rod_effectiveness = 1
	var/rad_strength = 0

/obj/item/control_rod/inferior
	name = "techfab control rod"
	desc = "A control rod manufactured on-board. Techfabs lack the resolution to fully solidify the core, so this one is weaker than a factory-made rod."
	icon_state = "inferior"
	rod_integrity = 80
	rod_effectiveness = 0.8

/obj/item/control_rod/superior
	name = "reinforced control rod"
	desc = "A superior control rod with a longer service life."
	icon_state = "superior"
	rod_integrity = 200

/obj/item/control_rod/plasma
	name = "unstable control rod"
	desc = "A control rod with a phoron-doped core. Rather than absorbing neutrons, it actively encourages fission - installing this is either a mistake or an act of sabotage."
	icon_state = "plasma"
	rod_effectiveness = -0.5

/obj/item/control_rod/irradiated
	name = "depleted control rod"
	desc = "A control rod saturated with radioactive particles. It's no longer effective at anything but making the area around it dangerous."
	icon_state = "irradiated"
	rod_integrity = 0
	rod_effectiveness = 0
	rad_strength = 500
