// Base class for the sexcon engine's sex_action catalog, adapted from Ratwood-2.0-main's own
// code/datums/sexcon/sex_action.dm as closely as this codebase's primitives allow. Ratwood's own version is
// trivially simple/portable (see baystation12soyh_ratwood_sexcon_port memory) -- the only real changes here are:
// - user_zone/target_zone replace Ratwood's per-action calls into check_location_accessible() with precise
//   BODY_ZONE_PRECISE_* args -- a single SEX_ZONE_* flag per side is enough for this codebase's coarser body model.
// - No signal-based intimate-state/chastity blocking (COMSIG_ERP_LOCATION_ACCESSIBLE) -- this codebase has no
//   signal system at all (confirmed via exhaustive grep). Chastity devices are a later phase; when they exist,
//   they'll need a direct virtual proc call substitute instead of a signal dispatch.
/datum/sex_action
	abstract_type = /datum/sex_action

	var/name = "Do something"
	/// How long a single cycle of this action takes, in deciseconds, before on_perform() fires again.
	var/do_time = 3 SECONDS
	/// Whether this action repeats on its own (held down) rather than firing once.
	var/continous = TRUE
	var/stamina_cost = 0

	/// Whether the user and target need to be on the same tile to perform this (most non-masturbation actions).
	var/check_same_tile = FALSE
	/// If check_same_tile fails, a strong enough grab (get_grab_on() .restrains()) can bypass it anyway.
	var/aggro_grab_instead_same_tile = FALSE
	var/check_incapacitated = TRUE
	/// Whether the user must be holding a grab on the target at all (any grab, not a specific escalation level --
	/// this codebase's grab system is a named upgrade chain, not Ratwood's numeric GRAB_* scale).
	var/require_grab = FALSE

	/// SEX_CATEGORY_* -- which menu tab this action is filed under.
	var/category = SEX_CATEGORY_MISC
	/// SEX_PART_* bitflags -- purely descriptive/menu-filtering, matching Ratwood's own shape.
	var/user_sex_part = SEX_PART_NULL
	var/target_sex_part = SEX_PART_NULL

	/// SEX_ZONE_* -- which zone on the user (if any) needs to be exposed/available for this action.
	var/user_zone = SEX_ZONE_NULL
	/// SEX_ZONE_* -- which zone on the target (if any) needs to be exposed/available for this action.
	var/target_zone = SEX_ZONE_NULL

	/// Whether the user can perform this on themselves (target == user).
	var/self_action = FALSE
	/// Whether this action can target someone else (target != user).
	var/partner_action = TRUE
	/// Whether /datum/sex_controller/proc/try_form_knot() is allowed to fire while this is the current_action.
	var/knot_capable = FALSE

/datum/sex_action/proc/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!user || !target)
		return FALSE
	var/self_target = (user == target)
	if(self_target && !self_action)
		return FALSE
	if(!self_target && !partner_action)
		return FALSE
	if(check_incapacitated && user.incapacitated())
		return FALSE
	if(user_zone && !check_location_accessible(user, user, user_zone))
		return FALSE
	if(target_zone && !check_location_accessible(user, target, target_zone))
		return FALSE
	return TRUE

/datum/sex_action/proc/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return can_perform(user, target)

/datum/sex_action/proc/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/sex_action/proc/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/sex_action/proc/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/**
 * Checks whether `zone` is currently accessible on `target`, from `user`'s perspective.
 *
 * Adapted from Ratwood's own /datum/sex_action/proc/check_location_accessible() (sexcon.dm ~237-325), trimmed of:
 * - the precise-zone GRAB/non-GRAB bitfield split (require_grab already gates this per-action here)
 * - the signal-based chastity/intimate-state block (no signal system here -- see file header)
 * - ranged/LOS actions, gloryhole furniture, and rogue bed/table/grass tracking (none of that furniture-specific
 *   state exists in this codebase; can be added back if/when those pieces are ported)
 */
/datum/sex_action/proc/check_location_accessible(mob/living/carbon/human/user, mob/living/carbon/human/target, zone)
	if(!user || !target)
		return FALSE
	var/self_target = (user == target)
	var/datum/sex_controller/target_con = target.get_sexcon()

	if(!self_target && target_con.freeuse)
		return user.Adjacent(target)

	// General adjacency floor for every partner action, regardless of check_same_tile/require_grab -- neither of
	// those flags is universally set (e.g. plain hand-on-partner actions need neither), so without this a partner
	// action could otherwise fire at any distance as long as the target's clothing-exposure check happened to pass.
	if(!self_target && !user.Adjacent(target))
		return FALSE

	var/bypass_exposure = target_con.bottom_exposed && (zone == SEX_ZONE_GROIN)
	if(!bypass_exposure && !target.get_zone_exposed(sex_zone_to_coverage_flag(zone)))
		return FALSE

	if(!self_target)
		if(check_same_tile && get_turf(user) != get_turf(target))
			var/grab_bypass = FALSE
			if(aggro_grab_instead_same_tile)
				var/obj/item/grab/G = user.get_grab_on(target)
				grab_bypass = G && G.restrains()
			if(!grab_bypass)
				return FALSE
		if(require_grab && !user.get_grab_on(target))
			return FALSE

	return TRUE
