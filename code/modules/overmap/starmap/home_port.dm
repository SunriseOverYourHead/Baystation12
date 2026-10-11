// HD 66161 - the Torch's home port, arrived at when a Return to Port bluespace jump (the calm, round-ending
// evacuation_controller/starship "bluespace_jump" flavour - see finish_evacuation() in
// code/controllers/evacuation/evacuation_pods.dm) completes. Deliberately NOT a /datum/star_system: those all
// register into GLOB.star_systems, which is exactly what the galaxy map console
// (code/modules/overmap/ships/computers/starmap.dm) reads to build its Known Systems list and its jump targets -
// staying off that list is what makes this system unreachable through the in-round jump console. Static (no name
// roll, no procedural generation) and marker-only: a single overmap icon with no interior z-level of its own.
#define HOME_PORT_OVERMAP_SIZE 5

/obj/overmap/visitable/home_port_marker
	name = "SCGF Third Fleet Observatory"
	desc = "A Sol Fleet forward observation post, quietly watching over the HD 66161 system."
	icon_state = "sector"
	anchored = TRUE
	randomize_location = FALSE

/datum/controller/subsystem/starmap/var/obj/overmap/visitable/home_port_marker/home_port_marker

/// Lazily builds the dedicated 5x5 HD 66161 grid and its marker the first time they're needed. Safe to call
/// repeatedly - no-ops (beyond the lookup) once built.
/datum/controller/subsystem/starmap/proc/get_home_port_z()
	if (!home_port_marker)
		var/z = build_overmap_grid(HOME_PORT_OVERMAP_SIZE)
		var/centre = ceil(HOME_PORT_OVERMAP_SIZE / 2)
		home_port_marker = new(locate(centre, centre, z))
	return home_port_marker.z

/// Moves the given vessel onto the HD 66161 grid, next to the Observatory marker. Called once, from
/// evacuation_controller/starship/finish_evacuation(), when the Return to Port jump concludes - the round-end
/// report (/datum/map/torch/roundend_summary() in maps/torch/torch_procs.dm) cites this arrival directly off
/// evacuation_controller's own state rather than a separate flag, since the only way to reach EVAC_COMPLETE with
/// emergency_evacuation FALSE on the starship controller is through this exact path.
/datum/controller/subsystem/starmap/proc/arrive_at_home_port(obj/overmap/visitable/ship/vessel)
	if (!vessel)
		return
	var/z = get_home_port_z()
	var/turf/T = locate(home_port_marker.x + 1, home_port_marker.y, z)
	if (T)
		vessel.forceMove(T)
		refresh_overmap_viewers(vessel)

#undef HOME_PORT_OVERMAP_SIZE
