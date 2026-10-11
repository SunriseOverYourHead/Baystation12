// Starter sex_action content -- self-masturbation for both genital types. A proof-of-life subset of Ratwood's own
// 71-file sex_actions/masturbate/ folder, not a full port (see baystation12soyh_ratwood_sexcon_port memory for the
// remaining catalog scope). More actions (oral, mutual, deviant, force, toy) are a following phase.
/datum/sex_action/masturbate
	abstract_type = /datum/sex_action/masturbate
	name = "Masturbate"
	do_time = 4 SECONDS
	continous = TRUE
	self_action = TRUE
	partner_action = FALSE
	category = SEX_CATEGORY_HANDS
	target_zone = SEX_ZONE_GROIN

/datum/sex_action/masturbate/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user != target)
		return FALSE
	if(!can_use_part(user))
		return FALSE
	return ..()

/datum/sex_action/masturbate/proc/can_use_part(mob/living/carbon/human/user)
	return FALSE

/datum/sex_action/masturbate/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_controller/con = user.get_sexcon()
	// Force drives intensity/magnitude here -- speed already drives how often this fires at all (see
	// get_speed_multiplier()/schedule_next_perform() in sexcon.dm), so tying gain to speed too would double-count it.
	con.adjust_arousal(2 * con.force)
	if(con.force > SEX_FORCE_MID)
		con.try_do_pain_effect(con.get_pain_for_force(con.force))
	con.generic_sex_noise()
	var/datum/pronouns/P = user.choose_from_pronouns()
	user.sexcon_action_message(
		con.spanify_force("[user] [con.get_generic_force_adjective()] touches [P.self]."),
		con.spanify_force("You [con.get_generic_force_adjective()] touch yourself."),
	)

/datum/sex_action/masturbate/penis
	name = "Masturbate (Penis)"
	user_sex_part = SEX_PART_COCK

/datum/sex_action/masturbate/penis/can_use_part(mob/living/carbon/human/user)
	return user.get_sexcon().can_use_penis()

/datum/sex_action/masturbate/vagina
	name = "Masturbate (Vagina)"
	user_sex_part = SEX_PART_CUNT

/datum/sex_action/masturbate/vagina/can_use_part(mob/living/carbon/human/user)
	return user.get_sexcon().can_use_vagina()
