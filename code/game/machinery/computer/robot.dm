/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Used to remotely lockdown or monitor linked synthetics."
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "mining_key"
	icon_screen = "robot"
	light_color = "#a97faa"
	req_access = list(access_robotics)
	machine_name = "robotics control console"
	machine_desc = "A control console that maintains a radio link with ship synthetics. Allows remote monitoring of them, as well as locking down their movement systems."

/obj/machinery/computer/robotics/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/obj/machinery/computer/robotics/ui_interact(mob/user, datum/tgui/ui)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access Denied"))
		return
	ui = tgui_interact(user, src, "RobotControl", "Robotic Control Console", ui)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/robotics/ui_data(mob/user)
	return list(
		"robots" = get_cyborgs(user),
		"is_ai" = issilicon(user)
	)

/obj/machinery/computer/robotics/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/robotics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access Denied"))
		return TRUE
	var/mob/living/silicon/robot/target = get_cyborg_by_name(params["name"])
	if(!target || !istype(target))
		return TRUE
	switch(action)
		if("lockdown")
			if(isrobot(user))
				to_chat(user, SPAN_WARNING("Access Denied."))
				return TRUE
			if(isAI(user) && (target.connected_ai != user))
				to_chat(user, SPAN_WARNING("Access Denied. This robot is not linked to you."))
				return TRUE
			var/choice = input("Really [target.lockcharge ? "unlock" : "lockdown"] [target.name] ?") in list("Yes", "No")
			if(choice != "Yes")
				return TRUE
			if(!target || !istype(target))
				return TRUE
			if(target.SetLockdown(!target.lockcharge))
				log_and_message_admins("[target.lockcharge ? "locked down" : "released"] [target.name]!", user)
				if(target.lockcharge)
					to_chat(target, SPAN_DANGER("You have been locked down!"))
				else
					to_chat(target, SPAN_NOTICE("Your lockdown has been lifted!"))
			else
				to_chat(user, SPAN_WARNING("ERROR: Lockdown attempt failed."))
			return TRUE
		if("hack")
			if(!istype(user, /mob/living/silicon/ai) || !(user.mind.special_role && user.mind.original == user))
				to_chat(user, SPAN_WARNING("Access Denied"))
				return TRUE
			if(target.emagged)
				to_chat(user, "Robot is already hacked.")
				return TRUE
			var/choice = input("Really hack [target.name]? This cannot be undone.") in list("Yes", "No")
			if(choice != "Yes")
				return TRUE
			if(!target || !istype(target))
				return TRUE
			log_and_message_admins("emagged [target.name] using robotic console!", user)
			target.emagged = TRUE
			to_chat(target, SPAN_NOTICE("Failsafe protocols overriden. New tools available."))
			return TRUE
		if("message")
			var/message = sanitize(input("Enter message to transmit to the synthetic.") as null|text)
			if(!message || !istype(target))
				return TRUE
			log_and_message_admins("sent message '[message]' to [target.name] using robotics control console!", user)
			to_chat(target, SPAN_NOTICE("New remote message received using R-SSH protocol:"))
			to_chat(target, message)
			return TRUE
	return FALSE

// Proc: get_cyborgs()
// Parameters: 1 (operator - mob which is operating the console.)
// Description: Returns NanoUI-friendly list of accessible cyborgs.
/obj/machinery/computer/robotics/proc/get_cyborgs(mob/operator)
	var/list/robots = list()

	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		// Ignore drones
		if(isdrone(R))
			continue
		// Ignore antagonistic cyborgs
		if(R.scrambledcodes)
			continue

		var/list/robot = list()
		robot["name"] = R.name
		var/turf/T = get_turf(R)
		var/area/A = get_area(T)

		if(istype(T) && istype(A) && (T.z in GLOB.using_map.contact_levels))
			robot["location"] = "[A.name] ([T.x], [T.y])"
		else
			robot["location"] = "Unknown"

		if(R.stat)
			robot["status"] = "Not Responding"
		else if (R.lockcharge)
			robot["status"] = "Lockdown"
		else
			robot["status"] = "Operational"

		if(R.cell)
			robot["cell"] = 1
			robot["cell_capacity"] = R.cell.maxcharge
			robot["cell_current"] = R.cell.charge
			robot["cell_percentage"] = round(R.cell.percent())
		else
			robot["cell"] = 0

		robot["module"] = R.module ? R.module.name : "None"
		robot["master_ai"] = R.connected_ai ? R.connected_ai.name : "None"
		robot["hackable"] = 0
		// Antag AIs know whether linked cyborgs are hacked or not.
		if(operator && istype(operator, /mob/living/silicon/ai) && (R.connected_ai == operator) && (operator.mind.special_role && operator.mind.original == operator))
			robot["hacked"] = R.emagged ? 1 : 0
			robot["hackable"] = R.emagged? 0 : 1
		robots.Add(list(robot))
	return robots

// Proc: get_cyborg_by_name()
// Parameters: 1 (name - Cyborg we are trying to find)
// Description: Helper proc for finding cyborg by name
/obj/machinery/computer/robotics/proc/get_cyborg_by_name(name)
	if (!name)
		return
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		if(R.name == name)
			return R
