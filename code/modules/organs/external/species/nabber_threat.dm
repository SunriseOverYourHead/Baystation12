/obj/item/organ/external/chest/insectoid/nabber
	name = "thorax"
	encased = "carapace"
	action_button_name = "Perform Threat Display"
	// GAS's torso tile is 32x40 (species.icon_template = template_tall.dmi) vs the standard 32x32, and BYOND
	// anchors overlays at the bottom-left origin shared with the (taller) base canvas -- so human-aligned art
	// composited with no offset lands too low relative to GAS's own silhouette. Measured directly: torso_f/
	// torso_m's own bbox in icons/mob/human_races/species/nabber/body.dmi is (11,8,20,31) (its own 32x40 tile)
	// vs human's (10,10,21,20) in a 32x32 tile; converting both to BYOND's bottom-up Y and comparing centroids
	// gives the offset below (a plain re-centering translation, not a resculpt -- GAS's silhouette shape here
	// is different enough that this won't be a perfect fit, only a much closer one than an unadjusted 0,0).
	// NOT hand-verified per-direction the way groin's offset was (this round's ask was genitals-only) -- kept as
	// a single flat value applied uniformly across all 4 directions for now.
	mutant_organ_pixel_offset = alist(
		SOUTH = list(0, 4),
		NORTH = list(0, 4),
		EAST = list(0, 4),
		WEST = list(0, 4)
	)

/obj/item/organ/external/chest/insectoid/nabber/monarch_queen
	name = "thorax"
	encased = "carapace"
	// MSQ has its own distinct body art (nabber/msq/body.dmi, a standard 32x32 tile, unlike base GAS/Worker's
	// 32x40) -- needs its own measured offset, not GAS's. Same caveat as above: not hand-verified per-direction.
	mutant_organ_pixel_offset = alist(
		SOUTH = list(1, -5),
		NORTH = list(1, -5),
		EAST = list(1, -5),
		WEST = list(1, -5)
	)

/obj/item/organ/external/chest/insectoid/nabber/refresh_action_button()
	. = ..()
	if(.)
		action.button_icon_state = "nabber-threat"
		if(action.button) action.button.UpdateIcon()

/obj/item/organ/external/chest/insectoid/nabber/attack_self(mob/user)
	. = ..()
	if(.)
		if(owner.incapacitated())
			to_chat(owner, SPAN_WARNING("You can't do a threat display in your current state."))
			return
		if(owner.skin_state == SKIN_NORMAL)
			if(owner.pulling_punches)
				to_chat(owner, SPAN_WARNING("You must be in your hunting stance to do a threat display."))
			else
				var/message = alert(owner, "Would you like to show a scary message?",,"Cancel","Yes", "No")
				if(message == "Cancel")
					return
				else if(message == "Yes")
					var/datum/pronouns/pronouns = owner.choose_from_pronouns()
					owner.visible_message(SPAN_WARNING("\The [owner]'s skin shifts to a deep red colour with dark chevrons running down in an almost hypnotic \
						pattern. Standing tall, [pronouns.he] strikes, sharp spikes aimed at those threatening [pronouns.him], claws whooshing through the air past them."))
				playsound(owner.loc, 'sound/effects/angrybug.ogg', 60, 0)
				owner.skin_state = SKIN_THREAT
				owner.update_skin()
				addtimer(new Callback(owner, TYPE_PROC_REF(/mob/living/carbon/human, reset_skin)), 10 SECONDS, TIMER_UNIQUE)
		else if(owner.skin_state == SKIN_THREAT)
			owner.reset_skin()
