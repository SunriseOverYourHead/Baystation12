// Circuitboard + R&D design for the reactor's single merged console (control + statistics - was two separate
// consoles, merged into one; see reactor_control_console.dm), mirroring code/modules/power/fusion/fusion_circuits.dm's
// pattern exactly. Also includes a protolathe design for a basic (inferior) control rod - fuel rods are
// deliberately NOT fabricable here, matching NSV13's own reactor (enriched fuel isn't something a protolathe prints).

/obj/item/stock_parts/circuitboard/reactor_control
	name = "circuit board (reactor control console)"
	build_path = /obj/machinery/computer/reactor/control
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4, TECH_POWER = 3)

/datum/design/circuit/reactor
	req_tech = list(TECH_POWER = 3, TECH_ENGINEERING = 3, TECH_MATERIAL = 3)

/datum/design/circuit/reactor/control
	name = "reactor control console"
	id = "reactor_control"
	build_path = /obj/item/stock_parts/circuitboard/reactor_control
	sort_string = "LAACA"

/datum/design/item/control_rod
	name = "techfab control rod"
	id = "control_rod_inferior"
	build_type = PROTOLATHE
	category = "Power Designs"
	materials = list(MATERIAL_STEEL = 500, MATERIAL_TITANIUM = 500)
	build_path = /obj/item/control_rod/inferior
	req_tech = list(TECH_ENGINEERING = 3, TECH_POWER = 2)
	sort_string = "LAACC"
