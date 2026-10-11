// Radioactive sludge spread on reactor meltdown - ported from NSV13's nuclear_waste_spawner landmark
// (nsv13/code/game/objects/effects/custom_landmarks.dm), simplified into a plain proc since it's only ever called
// dynamically by the reactor itself (see reactor_process.dm's meltdown()), never mapper-placed.

/obj/decal/nuclear_waste
	name = "plutonium sludge"
	desc = "A writhing pool of heavily irradiated, spent reactor fuel. You probably shouldn't step through this."
	// Sprite ported from NSV13 (nsv13/icons/obj/machinery/reactor_parts.dmi).
	icon = 'icons/obj/machines/power/reactor_parts.dmi'
	icon_state = "nuclearwaste"
	density = FALSE
	anchored = TRUE

/obj/decal/nuclear_waste/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		SSradiation.radiate(src, 625)

/obj/decal/nuclear_waste/epicenter
	name = "dense nuclear sludge"
	desc = "A thick, glowing pool of molten reactor core. Stay away."
	light_color = COLOR_CYAN

/obj/decal/nuclear_waste/epicenter/Initialize(mapload)
	. = ..()
	set_light(3)
	SSradiation.flat_radiate(src, 1500, 5, FALSE)

/// Scatters nuclear_waste decals around center - a strong epicenter decal at center itself (if strong), then a
/// scattered ring out to range tiles, 35% chance per tile, skipping anything solid enough to plausibly block it.
/proc/spread_nuclear_waste(turf/center, range = 3, strong = TRUE)
	if(!istype(center))
		return
	if(strong)
		new /obj/decal/nuclear_waste/epicenter(center)
	for(var/turf/simulated/floor in orange(range, center))
		if(!prob(35))
			continue
		var/blocked = FALSE
		for(var/obj/O in floor)
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille) || istype(O, /obj/structure/girder))
				blocked = TRUE
				break
		if(!blocked)
			new /obj/decal/nuclear_waste(floor)
