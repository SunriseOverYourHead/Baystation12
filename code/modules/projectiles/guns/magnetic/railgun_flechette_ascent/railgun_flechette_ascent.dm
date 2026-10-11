/obj/item/gun/magnetic/railgun/flechette/ascent
	name = "mantid flechette rifle"
	desc = "A viciously pronged rifle-like weapon."
	has_safety = FALSE
	one_hand_penalty = 6
	var/charge_per_shot = 10
	var/global/list/species_can_use = list(
		SPECIES_MANTID_ALATE,
		SPECIES_MANTID_GYNE,
		SPECIES_NABBER,
		SPECIES_MONARCH_QUEEN,
		SPECIES_MONARCH_WORKER
	)

/obj/item/gun/magnetic/railgun/flechette/ascent/special_check(mob/living/carbon/human/user)
	. = ..()
	if(.)
		if(istype(user, /mob/living/silicon/robot/flying/ascent))
			return TRUE
		if(!length(species_can_use))
			return TRUE
		if(!istype(user) || !(user.species.get_bodytype(user) in species_can_use))
			return FALSE

/obj/item/gun/magnetic/railgun/flechette/ascent/get_cell()
	if(isrobot(loc) || istype(loc, /obj/item/rig_module))
		return loc.get_cell()

/obj/item/gun/magnetic/railgun/flechette/ascent/show_ammo(mob/user)
	var/obj/item/cell/cell = get_cell()
	to_chat(user, SPAN_NOTICE("There are [cell ? floor(cell.charge/charge_per_shot) : 0] shot\s remaining."))

/obj/item/gun/magnetic/railgun/flechette/ascent/check_ammo()
	var/obj/item/cell/cell = get_cell()
	return cell && cell.charge >= charge_per_shot

/obj/item/gun/magnetic/railgun/flechette/ascent/use_ammo()
	var/obj/item/cell/cell = get_cell()
	if(cell) cell.use(charge_per_shot)
