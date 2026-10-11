// First penetrative sex_action -- needed as a vehicle for the knotting mechanic (sexcon.dm's try_form_knot()),
// which only makes sense during/after a penetrative act. A real subset of Ratwood's own sex_actions/sex/ +
// deviant/ + oral/ catalog (anal, oral, etc.) is still a following phase -- this is deliberately just the one
// action needed to make knotting testable, not a full penetrative catalog.
/datum/sex_action/vaginal_sex
	name = "Vaginal Sex"
	do_time = 4 SECONDS
	continous = TRUE
	category = SEX_CATEGORY_PENETRATE
	partner_action = TRUE
	self_action = FALSE
	user_zone = SEX_ZONE_GROIN
	target_zone = SEX_ZONE_GROIN
	user_sex_part = SEX_PART_COCK
	target_sex_part = SEX_PART_CUNT
	knot_capable = TRUE

/datum/sex_action/vaginal_sex/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.get_sexcon().can_use_penis())
		return FALSE
	if(!target.get_sexcon().can_use_vagina())
		return FALSE
	return ..()

/datum/sex_action/vaginal_sex/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/datum/sex_controller/user_con = user.get_sexcon()
	var/datum/sex_controller/target_con = target.get_sexcon()
	user_con.adjust_arousal(user_con.force)
	target_con.adjust_arousal(2 * user_con.force)
	if(user_con.force > SEX_FORCE_MID)
		target_con.try_do_pain_effect(user_con.get_pain_for_force(user_con.force))
	user.sexcon_action_message(
		user_con.spanify_force("[user] [user_con.get_generic_force_adjective()] has sex with [target]."),
		user_con.spanify_force("You [user_con.get_generic_force_adjective()] have sex with [target]."),
	)
	user_con.intercourse_noise(target)
	user_con.do_thrust_animate(target)
