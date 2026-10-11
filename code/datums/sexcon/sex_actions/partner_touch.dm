// Starter partner-facing sex_action content -- the first batch that actually exercises partner_action/target_zone
// (the 2 masturbation actions from the first pass are self-only). Small, deliberately simple hand-based actions:
// nothing here requires a grab or same-tile positioning, just adjacency + the target's own clothing exposure --
// matching how a plain consensual hands-on-partner action should behave. A real subset of Ratwood's own 71-file
// sex_actions/{oral,sex,deviant,force,toy}/ catalog is still a following phase (see baystation12soyh_ratwood_sexcon_port
// memory).
/datum/sex_action/hand_on_partner
	abstract_type = /datum/sex_action/hand_on_partner
	do_time = 3 SECONDS
	continous = TRUE
	category = SEX_CATEGORY_HANDS
	self_action = FALSE
	partner_action = TRUE
	/// The visible_message verb phrase, e.g. "strokes" -- overridden per concrete subtype.
	var/verb_phrase = "touches"
	/// Whether outercourse_noise() should layer its wetness-specific sound on top -- only Fingering targets a wet
	/// part.
	var/wetness_sound = FALSE

/datum/sex_action/hand_on_partner/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!can_use_target_part(target))
		return FALSE
	return ..()

/// Whether the target actually has the anatomy this action touches -- overridden per concrete subtype.
/datum/sex_action/hand_on_partner/proc/can_use_target_part(mob/living/carbon/human/target)
	return TRUE

/datum/sex_action/hand_on_partner/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_controller/user_con = user.get_sexcon()
	var/datum/sex_controller/target_con = target.get_sexcon()
	target_con.adjust_arousal(2 * user_con.force)
	// Above MID force, the target starts taking real pain in the touched area, scaling with the actor's own force
	// tier (get_pain_for_force() reads the ACTOR's force, not the target's -- see that proc's header for the bug
	// this replaced).
	if(user_con.force > SEX_FORCE_MID)
		target_con.try_do_pain_effect(user_con.get_pain_for_force(user_con.force))
	user.sexcon_action_message(
		user_con.spanify_force("[user] [user_con.get_generic_force_adjective()] [verb_phrase] [target]."),
		user_con.spanify_force("You [user_con.get_generic_force_adjective()] [verb_phrase] [target]."),
	)
	user_con.outercourse_noise(target, wetness_sound)
	user_con.do_thrust_animate(target)

/datum/sex_action/hand_on_partner/handjob
	name = "Handjob"
	target_zone = SEX_ZONE_GROIN
	verb_phrase = "strokes"

/datum/sex_action/hand_on_partner/handjob/can_use_target_part(mob/living/carbon/human/target)
	return target.get_sexcon().can_use_penis()

/datum/sex_action/hand_on_partner/fingering
	name = "Fingering"
	target_zone = SEX_ZONE_GROIN
	verb_phrase = "fingers"
	wetness_sound = TRUE

/datum/sex_action/hand_on_partner/fingering/can_use_target_part(mob/living/carbon/human/target)
	return target.get_sexcon().can_use_vagina()

/datum/sex_action/hand_on_partner/chest
	name = "Fondle Chest"
	target_zone = SEX_ZONE_CHEST
	verb_phrase = "fondles the chest of"

/datum/sex_action/hand_on_partner/chest/can_use_target_part(mob/living/carbon/human/target)
	return !!target.internal_organs_by_name[BP_BREASTS]

/datum/sex_action/hand_on_partner/makeout
	name = "Make Out"
	target_zone = SEX_ZONE_MOUTH
	verb_phrase = "makes out with"

/datum/sex_action/hand_on_partner/makeout/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	// Mutual -- unlike the other hand_on_partner actions, kissing arouses both parties.
	var/datum/sex_controller/user_con = user.get_sexcon()
	user_con.adjust_arousal(user_con.force)
