// Shared base for the reactor's console (/obj/machinery/computer/reactor/control - previously also had a
// separate /stats sibling, since merged into the one console). Links to its reactor by id_tag (the same universal
// machinery var turbine_computer.dm already uses for this exact purpose - code/modules/power/turbine.dm),
// searching SSmachines.machinery once at Initialize(). Deliberately NOT using the fusion console family's
// local_network_member extension (code/modules/power/fusion/consoles/_consoles.dm) - that's built for
// discovering multiple cores per console, which this doesn't need.
//
// id_tag can also be set/replaced in-round with a multitool: use one on the reactor to store its id_tag
// (reactor_core.dm's use_tool()), then use the same multitool on the console to push it here. This is the
// recovery path if a console is destroyed and rebuilt - the new console's id_tag starts blank (mapper-set id_tags
// only exist on the originally-placed instance), so without this there'd be no in-round way to relink it to its
// reactor at all.

/obj/machinery/computer/reactor
	name = "reactor console"
	var/obj/machinery/atmospherics/omni/reactor/reactor

/obj/machinery/computer/reactor/Initialize()
	. = ..()
	// Deferred to LateInitialize() rather than searched here directly. SSmachines.machinery is populated by each
	// machine's own Initialize() (code/game/machinery/_machines_base/machinery.dm's "SSmachines.machinery += src"),
	// and mapload order between different atom types isn't guaranteed - if this console's Initialize() happened to
	// run before the reactor's, the reactor wouldn't be in the list yet, this search would find nothing, and
	// reactor would stay null forever with no retry. LateInitialize only fires after every atom's Initialize() has
	// fully completed for the whole map (code/controllers/subsystems/atoms.dm's InitializeAtoms()), guaranteeing
	// the reactor - if one exists anywhere on the map - is already registered by the time we search for it.
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/reactor/LateInitialize(mapload)
	find_reactor()

// Also self-heals if the reactor is built/placed AFTER this console (e.g. admin-spawned out of order, or added
// mid-round) - mirrors the reactor's own port-link self-heal in reactor_process.dm's Process(). Cheap: the search
// only ever runs while reactor is still unlinked.
/obj/machinery/computer/reactor/Process()
	if(!reactor)
		find_reactor()

/obj/machinery/computer/reactor/proc/find_reactor()
	if(reactor || !id_tag)
		return
	for(var/obj/machinery/atmospherics/omni/reactor/R in SSmachines.machinery)
		if(R.id_tag == id_tag)
			reactor = R
			return

/obj/machinery/computer/reactor/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(isMultitool(I))
		var/obj/item/device/multitool/M = I
		if(!M.stored_id_tag)
			to_chat(user, SPAN_WARNING("[I] has no stored reactor ID tag - use it on a reactor first."))
			return TRUE
		id_tag = M.stored_id_tag
		reactor = null
		find_reactor()
		to_chat(user, SPAN_NOTICE("You push the stored ID tag ('[id_tag]') from [I] onto [src]."))
		if(reactor)
			to_chat(user, SPAN_NOTICE("[src] links up with [reactor]."))
		else
			to_chat(user, SPAN_WARNING("[src] couldn't find a reactor with that ID tag."))
		return TRUE
	return ..()

/obj/machinery/computer/reactor/interface_interact(mob/user)
	ui_interact(user)
	return TRUE
