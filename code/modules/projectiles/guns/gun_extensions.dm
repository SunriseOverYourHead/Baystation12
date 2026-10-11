/*
 * Species-restricted gun extensions.
 * Vox-only and Mantid-only weapons set these extensions in Initialize().
 * The special_check override below enforces the species restriction.
 */

/datum/extension/voxform
	base_type = /datum/extension/voxform

/datum/extension/voxform/proc/check_held_user(mob/living/carbon/human/user, atom/movable/thing)
	if(!istype(user))
		return FALSE
	if(user.species.get_bodytype(user) != SPECIES_VOX && user.unEquip(thing))
		to_chat(user, SPAN_WARNING("\The [thing] hisses and wriggles out of your grasp!"))
		playsound(user, 'sound/voice/BugHiss.ogg', 50, 1)
		return FALSE
	return TRUE

/datum/extension/mantidgun
	base_type = /datum/extension/mantidgun

/datum/extension/mantidgun/proc/check_held_user(mob/living/carbon/human/user, atom/movable/thing)
	if(!istype(user))
		return FALSE
	if(istype(user) && user.internal_organs_by_name[BP_SYSTEM_CONTROLLER])
		return TRUE
	if(user.species.get_bodytype(user) != SPECIES_MANTID_ALATE && user.species.get_bodytype(user) != SPECIES_MANTID_GYNE && user.species.get_bodytype(user) != SPECIES_MONARCH_WORKER && user.species.get_bodytype(user) != SPECIES_MONARCH_QUEEN && user.species.get_bodytype(user) != SPECIES_NABBER && user.unEquip(thing))
		to_chat(user, SPAN_WARNING("\The [thing] lets out a shock!"))
		playsound(user, 'sound/effects/zapbeep.ogg', 50, 1)
		return FALSE
	return TRUE

// Per-subtype special_check overrides are in each gun's own .dm file to avoid
// conflicting with the secure.dm override of /obj/item/gun/special_check.
