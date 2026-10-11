// Core engine for the sexcon (arousal/sex-action) system, adapted from Ratwood-2.0-main's own
// code/datums/sexcon/sexcon.dm (1830 lines) down to this codebase's own primitives. See the
// baystation12soyh_ratwood_sexcon_port memory for the full research/scoping log. This is a deliberately trimmed
// FIRST PASS of the engine core + a TGUI reskin of the old "Sate Desire" browser popup -- explicitly NOT ported yet
// (tracked as follow-up phases, not silently dropped): chastity devices, knot mechanics, the bulk of the 123-file
// sex_action catalog (only a small starter set exists so far), and any rogue-town-specific furniture interaction
// (beds/pillories/grass/gloryholes -- none of that furniture exists in this codebase to begin with).
//
// Simplifications from Ratwood's own version, all deliberate:
// - No STACON stat, testicle ball_size, patron/divine, charflaw addiction, or stress-event hooks -- none of those
//   systems exist here. Charge capacity is a flat SEX_MAX_CHARGE rather than Ratwood's dynamic load-count formula.
// - No aphrodisiac reagent multiplier / arousal_frozen (explicitly out of scope per user request).
// - No signal-based chastity/intimate-state block in the zone-access check (see sex_action.dm's header).
//
// NOTE ON GENITAL SPRITE SWAPPING (UPDATED -- see baystation12soyh_ratwood_sexcon_port memory for the full story):
// this WAS believed impossible without new art (every shipped icons/mob/species/anthro/penis.dmi/vagina.dmi state
// had exactly one frame per size, no aroused/flaccid pair). That was true of the SHIPPED output, but not of the
// original Bubberstation source art it was extracted from -- confirmed directly against Bubberstation's real DM
// code (modular_skyrat/.../genitals.dm's update_genital_icon_state()/get_sprite_size_string(): `is_erect`/
// `is_dripping` are literally `aroused == AROUSAL_FULL`) and its source .dmis, which DO carry a second "_1"
// (aroused) frame per shape/size that the original extraction pass simply never pulled (arousal mechanics didn't
// exist in this codebase yet at the time). Re-extracted the missing "_1" frames for every currently-shipped
// penis/vagina shape+size (a scratchpad script, same tools/dmi_tool.py-based approach as the original port) and
// appended them as new "..._a_s"-suffixed states in the SAME shipped .dmi files -- see get_groin_mutant_icon()'s
// `is_aroused` plumbing (code/modules/organs/external/standard.dm, code/modules/organs/internal/_mutant.dm,
// code/modules/sprite_accessories/_accessory_mutant.dm) and update_genital_arousal_visuals() below for the
// runtime wiring. Testicles/breasts were confirmed to have NO such pair in their own source (their numeric suffix
// is a size index, not an arousal state) -- correctly untouched. The pink screen overlay below is a SEPARATE,
// additional feedback mechanism (the user's own follow-up request), not a stand-in for this.

/**
 * A full-screen pink vignette that creeps in from the edges and intensifies with arousal -- uses this codebase's
 * existing generic overlay_fullscreen()/screens[] system (code/_onclick/hud/fullscreen.dm) directly, matching how
 * the built-in "pain" overlay (fullscreen.dm's /obj/screen/fullscreen/pain) already works, since that's exactly
 * the reference live feedback pointed at. icons/effects/sexcon_screen.dmi (new, generated directly via
 * tools/dmi_tool.py, not extracted from anywhere) has real "pink0".."pink6" severity frames -- each a 480x480
 * radial gradient, alpha=0 at dead-center, ramping up toward the corners, both the inward reach and the peak edge
 * alpha increasing with severity (visually verified against icons/mob/screen_full.dmi's own brutedamageoverlay0..6,
 * which uses the exact same structure: always transparent at the true center, regardless of severity).
 * First version used a single solid-pink 32x32 tile with the built-in `color` var driving a black-tinted base --
 * abandoned for two reasons found from live feedback: (1) DM's `color` is a MULTIPLY blend by default, and
 * multiplying true black (0,0,0) by any tint stays black, which is why it only ever looked darker, never pink; (2)
 * even after fixing the color, a flat full-screen wash was never going to look like "creeping in from the edges"
 * -- that needed real vignette art, not a uniform alpha value.
 */
/obj/screen/fullscreen/love
	icon = 'icons/effects/sexcon_screen.dmi'
	icon_state = "pink"
	// No screen_loc override -- inherits the base /obj/screen/fullscreen's own "CENTER-7,CENTER-7" (a fixed
	// placement centering a large pre-rendered image, exactly what /obj/screen/fullscreen/pain below relies on for
	// its own 480x480 brutedamageoverlay art -- same dimensions as this new pink art). The previous version had
	// "WEST,SOUTH to EAST,NORTH" left over from the original flat-solid-tile design (meant for stretching a small
	// tileable texture across the viewport), never updated when the art became a real 480x480 vignette -- live
	// reports of both an invisible overlay AND a growing camera offset while any action ran turned out to trace to
	// two SEPARATE bugs found by re-reading the code (this one, and do_thrust_animate()'s below); this screen_loc
	// mismatch explains the invisibility, not the camera drift.
	alpha = 0

/mob/living/carbon/human
	var/datum/sex_controller/sexcon

/mob/living/carbon/human/proc/get_sexcon()
	if(!sexcon)
		sexcon = new(src)
	return sexcon

/mob/living/carbon/human/proc/sexcon_action_message(message, self_message, blind_message)
	if(sexcon?.do_subtle_action)
		if(self_message)
			to_chat(src, self_message)
		return
	// Bystanders with Sexual Content disabled don't see ERP-flavored action text at all -- gather everyone who'd
	// normally be in visible_message()'s own view scan and exclude the ones with it off, rather than touching
	// the shared base /mob/visible_message() proc itself (used by hundreds of unrelated messages).
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(get_turf(src), world.view, mobs, objs)
	var/list/exclude_mobs = list()
	for(var/mob/living/carbon/human/H in mobs)
		if(H != src && !H.master_erp_preferences)
			exclude_mobs += H
	visible_message(message, self_message, blind_message, exclude_mobs = exclude_mobs)

/**
 * How the Sate Desire panel is actually opened -- deliberately NOT a player-visible verb (no IC-tab clutter, no
 * "how do I even find this" discoverability problem). Two gestures, both opening the ACTOR's own panel pre-targeted
 * at whoever they interacted with:
 * - Click+drag your own sprite onto another human (MouseDrop_T below).
 * - Ctrl+Shift+Click another human, or yourself (CtrlShiftClickOn below).
 * sate_desire_set_target() is kept as a hidden verb (not a proc) specifically because its "as mob in view()"
 * argument is what makes BYOND prompt the client to click a target on screen -- that click-prompt behavior is a
 * verb-argument feature, not something a plain /proc can trigger. `set hidden = TRUE` keeps it out of every verb
 * panel while still letting the TGUI panel's "Pick Target" button invoke it as a plain call.
 */
/mob/living/carbon/human/proc/open_sate_desire(mob/living/carbon/human/with_target)
	if(!master_erp_preferences)
		to_chat(src, SPAN_WARNING("You need to enable Sexual Content in your character preferences to do this."))
		return
	// Mechanical ERP is a narrower opt-out than master_erp_preferences -- a character can keep sexual content on
	// (dating preferences, tags, directory listing) while still opting out of the Sate Desire minigame
	// specifically, so this is checked separately and in addition to the master toggle above, not instead of it.
	if(!mechanical_erp)
		to_chat(src, SPAN_WARNING("You have Mechanical ERP off."))
		return
	var/mob/living/carbon/human/target = with_target || src
	if(target != src && !target.master_erp_preferences)
		to_chat(src, SPAN_WARNING("[target] has sexual content disabled."))
		return
	if(target != src && !target.mechanical_erp)
		to_chat(src, SPAN_WARNING("[target] has Mechanical ERP off."))
		return
	var/datum/sex_controller/con = get_sexcon()
	con.set_target(target)
	con.ui_interact(src)

/mob/living/carbon/human/verb/sate_desire_set_target(mob/living/carbon/human/M as mob in view())
	set name = "Set Sate Desire Target"
	set hidden = TRUE

	if(!ishuman(M))
		return
	if(M != src && !M.master_erp_preferences)
		to_chat(src, SPAN_WARNING("[M] has sexual content disabled."))
		return
	if(M != src && !M.mechanical_erp)
		to_chat(src, SPAN_WARNING("[M] has Mechanical ERP off."))
		return
	get_sexcon().set_target(M)
	to_chat(src, SPAN_NOTICE("Your Sate Desire panel now targets [M]."))

/mob/living/carbon/human/MouseDrop_T(atom/dropping, mob/user)
	if(dropping == user && ishuman(user) && user != src && user.Adjacent(src))
		var/mob/living/carbon/human/H = user
		H.open_sate_desire(src)
		return TRUE
	return ..()

/mob/living/carbon/human/CtrlShiftClickOn(atom/A)
	if(..())
		return TRUE
	if(ishuman(A) && (A == src || Adjacent(A)))
		open_sate_desire(A)
		return TRUE
	return FALSE

/datum/sex_controller
	/// The user and owner of the controller.
	var/mob/living/carbon/human/user
	/// Current partner of our actions -- can be ourself.
	var/mob/living/carbon/human/target
	/// The /datum/sex_action currently being performed, if any.
	var/datum/sex_action/current_action
	var/action_timer_id

	/// SEX_SPEED_*
	var/speed = SEX_SPEED_MID
	/// SEX_FORCE_*
	var/force = SEX_FORCE_MID
	// Force-tier adjective pools, ported verbatim from Ratwood's own sexcon.dm var block -- get_generic_force_
	// adjective() below picks one to drop into an action's message, matching Ratwood's own real usage pattern
	// (e.g. sex_actions/deviant/buttjob.dm: "[user] [get_generic_force_adjective()] [verb]s [target]...").
	var/static/list/low_force_adjectives = list("gently", "carefully", "tenderly", "gingerly", "delicately", "lazily")
	var/static/list/mid_force_adjectives = list("firmly", "vigorously", "eagerly", "steadily", "intently")
	var/static/list/high_force_adjectives = list("roughly", "carelessly", "forcefully", "fervently", "fiercely")
	var/static/list/extreme_force_adjectives = list("brutally", "violently", "relentlessly", "savagely", "mercilessly")
	var/static/list/ludicrous_force_adjectives = list("madly", "uncontrollably", "desperately", "deliriously", "freakishly")
	/// 0..MAX_AROUSAL
	var/arousal = 0
	/// SEX_MANUAL_AROUSAL_* -- whether genital arousal accrues automatically or is set by hand.
	var/manual_arousal = SEX_MANUAL_AROUSAL_DEFAULT
	/// Climax "ammo" gauge, 0..get_max_charge().
	var/charge = SEX_MAX_CHARGE
	/// Whether to stop automatically after climaxing, rather than continuing indefinitely.
	var/do_until_finished = TRUE
	/// Bypasses the clothing-exposure check for the groin specifically (crotch cutout-style access).
	var/bottom_exposed = FALSE
	/// Hides both arousal visual tells -- the genital sprite's aroused/erect swap (update_genital_arousal_visuals())
	/// and the pink screen overlay (update_pink_screen()). The organs/mechanics still function either way, this is
	/// visual only (a "keep the mechanics, don't show the tell" toggle).
	var/hide_genital_visuals = FALSE
	/// Bypasses positioning/exposure checks entirely for anyone targeting us (only adjacency enforced).
	var/freeuse = FALSE
	/// Whether actions should be performed subtly -- suppresses the public visible_message half of
	/// sexcon_action_message()/pain messages (self_message, sent only to the owner, still goes through).
	var/do_subtle_action = FALSE
	/// SEX_CATEGORY_* -- which menu tab is currently selected in the UI.
	var/action_category = SEX_CATEGORY_MISC

	/// Player-toggled intent to knot on climax, during a knot_capable action. Gated on the user's own
	/// can_knot_partners preference in try_form_knot() -- see chastity.dm's header-comment sibling note in
	/// baystation12soyh_ratwood_sexcon_port memory for why this is a plain preference instead of a knot-capable
	/// penis_type/organ variant (this codebase has no such distinction, and the user asked for a simple opt-in).
	var/do_knot_action = FALSE
	/// Whether a knot is currently tying us to knot_partner.
	var/knotted = FALSE
	var/mob/living/carbon/human/knot_partner

	var/last_arousal_increase_time = 0
	var/last_ejaculation_time = 0
	var/last_moan = 0
	var/last_pain = 0

/datum/sex_controller/New(mob/living/carbon/human/owner)
	. = ..()
	user = owner
	charge = get_max_charge()
	START_PROCESSING(SSobj, src)

/datum/sex_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	stop_current_action()
	if(knotted)
		break_knot()
	user?.clear_fullscreen("horny")
	user = null
	target = null
	return ..()

/datum/sex_controller/proc/set_target(mob/living/carbon/human/new_target)
	target = new_target

/datum/sex_controller/ui_state(mob/user)
	return GLOB.tgui_always_state

/datum/sex_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_interact(user, src, "SateDesire", "Sate Desire", ui)

// `user` here is the mob VIEWING this panel (the tgui convention), not necessarily this datum's own `var/user`
// (the controller's owner) -- they're always the same mob in practice (nobody can open another human's Sate
// Desire panel), but the two are semantically distinct and the local parameter shadows the datum field, so every
// reference to the datum's own owner below uses `src.user` explicitly to avoid silently reading the (same-typed
// but differently-scoped) parameter instead.
/datum/sex_controller/ui_data(mob/user)
	var/list/data = list()
	data["arousal"] = round(arousal)
	data["max_arousal"] = MAX_AROUSAL
	data["charge"] = round(charge)
	data["max_charge"] = get_max_charge()
	data["speed"] = speed
	data["force"] = force
	data["manual_arousal"] = manual_arousal
	data["do_until_finished"] = do_until_finished
	data["bottom_exposed"] = bottom_exposed
	data["hide_genital_visuals"] = hide_genital_visuals
	data["freeuse"] = freeuse
	data["do_subtle_action"] = do_subtle_action
	data["action_category"] = action_category
	data["target_name"] = target ? target.name : null
	data["self_targeted"] = (target == src.user)
	data["current_action"] = current_action?.name
	data["can_use_penis"] = can_use_penis()
	data["can_use_vagina"] = can_use_vagina()
	data["can_knot_partners"] = src.user.can_knot_partners
	data["do_knot_action"] = do_knot_action
	data["knotted"] = knotted
	data["knot_partner_name"] = knot_partner?.name

	var/list/actions = list()
	if(target)
		for(var/path in GLOB.sex_actions)
			var/datum/sex_action/action = GLOB.sex_actions[path]
			if(action.category != action_category)
				continue
			if(!action.shows_on_menu(src.user, target))
				continue
			actions += list(list(
				"path" = "\ref[action]",
				"name" = action.name,
				"active" = (current_action == action),
			))
	data["actions"] = actions
	return data

/datum/sex_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("pick_target")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.sate_desire_set_target()
			return TRUE
		if("target_self")
			set_target(user)
			return TRUE
		if("set_speed")
			speed = clamp(text2num(params["value"]), SEX_SPEED_MIN, SEX_SPEED_MAX)
			if(current_action && action_timer_id)
				schedule_next_perform() // apply the new pace immediately instead of waiting out the old timer
			return TRUE
		if("set_force")
			force = clamp(text2num(params["value"]), SEX_FORCE_MIN, SEX_FORCE_MAX)
			return TRUE
		if("set_manual_arousal")
			manual_arousal = clamp(text2num(params["value"]), SEX_MANUAL_AROUSAL_MIN, SEX_MANUAL_AROUSAL_MAX)
			apply_manual_arousal()
			return TRUE
		if("set_category")
			action_category = text2num(params["value"])
			return TRUE
		if("toggle_do_until_finished")
			do_until_finished = !do_until_finished
			return TRUE
		if("toggle_bottom_exposed")
			bottom_exposed = !bottom_exposed
			return TRUE
		if("toggle_hide_genital_visuals")
			hide_genital_visuals = !hide_genital_visuals
			on_arousal_changed()
			return TRUE
		if("toggle_freeuse")
			freeuse = !freeuse
			return TRUE
		if("toggle_subtle")
			do_subtle_action = !do_subtle_action
			return TRUE
		if("perform_action")
			var/datum/sex_action/picked
			for(var/path in GLOB.sex_actions)
				var/datum/sex_action/candidate = GLOB.sex_actions[path]
				if("\ref[candidate]" == params["action"])
					picked = candidate
					break
			if(picked)
				try_start_action(picked)
			return TRUE
		if("stop_action")
			stop_current_action()
			return TRUE
		if("toggle_knot_action")
			if(user.can_knot_partners)
				do_knot_action = !do_knot_action
			return TRUE
		if("break_knot")
			break_knot()
			return TRUE
	return FALSE

/**
 * The action loop is timer-driven (addtimer/deltimer), NOT polled off Process()'s own tick -- a real bug found
 * from a live user report ("speed doesn't feel fast enough even at Ludicrous"). /datum/sex_controller only ever
 * ticks via SSobj, and SSobj's own subsystem wait (code/controllers/subsystems/processing/processing.dm,
 * `SUBSYSTEM_DEF(processing)`, inherited by PROCESSING_SUBSYSTEM_DEF(obj)) is 1 SECOND -- meaning a polling
 * approach can NEVER fire more than once per real second no matter how short do_time/get_speed_multiplier()
 * computes, silently flattening every speed tier above roughly "once per second" into the exact same felt cadence.
 * addtimer() has decisecond resolution and isn't bound to any subsystem's own polling floor, so this is the actual
 * fix, not just a retuned multiplier -- retuning alone would have hit the same 1-second wall.
 */
/datum/sex_controller/proc/try_start_action(datum/sex_action/action)
	if(!target)
		return FALSE
	// Spam-clicking the same action button in the TGUI panel must not restart it repeatedly -- live feedback
	// reported this as actions "stacking" (able to fire multiple times at once). Whatever the exact client-side
	// cause, this guard makes it a guaranteed no-op at the source of truth: an already-running action is left
	// completely alone, never re-run through on_start()/schedule_next_perform() a second time.
	if(current_action == action)
		return TRUE
	if(!action.can_perform(user, target))
		return FALSE
	stop_current_action()
	current_action = action
	action.on_start(user, target)
	schedule_next_perform()
	return TRUE

/// (Re)schedules perform_tick() -- cancels any pending timer first, so calling this mid-action (e.g. right after
/// the player changes Speed) reschedules off the NEW multiplier immediately rather than waiting for the stale one.
/datum/sex_controller/proc/schedule_next_perform()
	if(action_timer_id)
		deltimer(action_timer_id)
		action_timer_id = null
	if(!current_action)
		return
	var/interval = max(1, round(current_action.do_time / get_speed_multiplier()))
	action_timer_id = addtimer(new Callback(src, PROC_REF(perform_tick)), interval, TIMER_STOPPABLE)

/datum/sex_controller/proc/perform_tick()
	action_timer_id = null
	if(!current_action)
		return
	if(!current_action.can_perform(user, target))
		stop_current_action()
		return
	current_action.on_perform(user, target)
	// on_perform() can null/stop current_action itself (e.g. do_until_finished's stop_current_action() on climax)
	// -- re-check before touching it further.
	if(!current_action)
		return
	if(!current_action.continous)
		stop_current_action()
		return
	schedule_next_perform()

/datum/sex_controller/proc/stop_current_action()
	if(action_timer_id)
		deltimer(action_timer_id)
		action_timer_id = null
	if(!current_action)
		return
	var/datum/sex_action/finishing = current_action
	current_action = null
	if(target)
		finishing.on_finish(user, target)

/datum/sex_controller/Process(wait)
	handle_arousal_unhorny(wait)
	handle_charge(wait)
	if(knotted)
		check_knot_still_tied()

/**
 * Attempts to tie `user` to `target` on climax, if `do_knot_action` is set and the user's own can_knot_partners
 * preference allows it. The physical tether itself is NOT custom movement code -- it reuses this codebase's own
 * pre-existing pull system's STATE (`pulling`/`pulledby`, code/modules/mob/mob_defines.dm) directly, since
 * /mob/living/Move() already calls handle_pulling_after_move() (code/modules/mob/living/living.dm) on every move
 * whenever `pulling` is set, which drags a pulled mob one step along and automatically breaks the pull if
 * distance > 2 or the z-levels stop matching (can_pull()). That's precisely the "drag-along, forced separation on
 * distance mismatch" behavior Ratwood's own knot_movement_top()/knot_movement_btm() (sexcon_knotting.dm, hooked on
 * COMSIG_MOVABLE_MOVED, a signal this codebase doesn't have) had to build from scratch -- here it's a straight
 * reuse of the engine's own drag logic, not a rewrite.
 * NOTE: sets `pulling`/`pulledby` directly rather than calling /mob/proc/start_pulling() -- that proc's very first
 * guard clause is `if(!usr) return`, i.e. it silently no-ops unless invoked in the context of a live client-issued
 * verb call. Called from here (a sex_action's on_perform(), itself invoked from either a TGUI ui_act or an
 * unattended Process() tick), `usr` is not reliably the acting mob and is often outright null -- discovered by
 * reading start_pulling()'s source before shipping, not by a failed live test. stop_pulling() has no such
 * dependency (checked separately) and IS called normally in break_knot() below.
 * check_knot_still_tied() (below), called every Process() tick, mirrors the tie's state to the engine's pull state.
 * Called from ejaculate() (not from the sex_action itself) specifically BEFORE the do_until_finished check --
 * checking current_action?.knot_capable only works while current_action is still set, and do_until_finished's
 * default-TRUE stop_current_action() would otherwise null it out from under this check on the very same climax
 * that's supposed to trigger the knot. Found and fixed before ever running, by tracing the call order rather than
 * by a failed live test.
 */
/datum/sex_controller/proc/try_form_knot()
	if(knotted || !do_knot_action)
		return
	if(!user.can_knot_partners)
		return
	if(!target || !ishuman(target) || target == user)
		return
	if(!(current_action?.knot_capable))
		return
	knotted = TRUE
	knot_partner = target
	var/datum/sex_controller/target_con = target.get_sexcon()
	target_con.knotted = TRUE
	target_con.knot_partner = user
	if(user.pulling && user.pulling != target)
		user.stop_pulling()
	user.pulling = target
	target.pulledby = user
	target.add_hiddenprint(user)
	user.visible_message(SPAN_WARNING("[user]'s knot swells, tying [user] and [target] together!"), SPAN_WARNING("Your knot swells inside [target], tying you together!"))
	to_chat(target, SPAN_WARNING("You feel [user]'s knot swell inside you, tying you together!"))

/// Called every Process() tick while knotted -- breaks the tie if the engine's own pull relationship has lapsed
/// (partner pulled out of range, grabbed away, manually stopped, etc.), keeping our own knotted state truthful
/// rather than a stale flag the pull system has already silently dropped.
/datum/sex_controller/proc/check_knot_still_tied()
	if(!knot_partner || QDELETED(knot_partner) || user.pulling != knot_partner)
		break_knot()

/datum/sex_controller/proc/break_knot()
	if(!knotted)
		return
	knotted = FALSE
	var/mob/living/carbon/human/partner = knot_partner
	knot_partner = null
	if(user.pulling == partner)
		user.stop_pulling()
	user.visible_message(SPAN_WARNING("[user]'s knot slips free."), SPAN_WARNING("Your knot slips free."))
	if(partner && !QDELETED(partner))
		var/datum/sex_controller/partner_con = partner.get_sexcon()
		if(partner_con.knotted && partner_con.knot_partner == user)
			partner_con.break_knot()

/datum/sex_controller/proc/can_use_penis()
	if(has_chastity_penis())
		return FALSE
	var/obj/item/organ/internal/mutant/penis/P = user.internal_organs_by_name[BP_PENIS]
	return P && !P.is_broken()

/datum/sex_controller/proc/can_use_vagina()
	if(has_chastity_vagina())
		return FALSE
	var/obj/item/organ/internal/mutant/vagina/V = user.internal_organs_by_name[BP_PUSSY]
	return V && !V.is_broken()

/datum/sex_controller/proc/can_use_anus()
	if(has_chastity_anal())
		return FALSE
	var/obj/item/organ/internal/mutant/anus/A = user.internal_organs_by_name[BP_ANUS]
	return A && !A.is_broken()

/// Flat cap for now -- Ratwood's own get_max_charge() scaled off Roguetown's STACON stat and testicle ball_size,
/// neither of which have an equivalent here yet.
/datum/sex_controller/proc/get_max_charge()
	return SEX_MAX_CHARGE

/datum/sex_controller/proc/set_arousal(amount)
	arousal = clamp(amount, 0, MAX_AROUSAL)
	last_arousal_increase_time = world.time
	on_arousal_changed()

/**
 * "Manual Arousal" lets the player assert a narrative arousal level instead of letting the mechanical gain math
 * drive it -- DEFAULT is the only setting where adjust_arousal() actually moves the meter; the other 3 immediately
 * snap arousal to a fixed value and hold it there (further adjust_arousal() calls are no-ops while active). This
 * gives all 4 values distinct, visible behavior -- previously only UNAROUSED did anything (forced 0 gain, but
 * never actually zeroed an already-nonzero meter), and PARTIAL/FULL were dead settings.
 */
/datum/sex_controller/proc/apply_manual_arousal()
	switch(manual_arousal)
		if(SEX_MANUAL_AROUSAL_UNAROUSED)
			set_arousal(0)
		if(SEX_MANUAL_AROUSAL_PARTIAL)
			set_arousal(round(MAX_AROUSAL * 0.5))
		if(SEX_MANUAL_AROUSAL_FULL)
			set_arousal(round(MAX_AROUSAL * 0.9))

/datum/sex_controller/proc/adjust_arousal(amount)
	if(manual_arousal != SEX_MANUAL_AROUSAL_DEFAULT)
		return
	// A spiked-and-locked chastity device redirects most of an incoming pleasure gain into pain instead --
	// substitutes for Ratwood's own spiked-chastity pleasure/pain multiplier pair (modular_adjust_action_for_
	// target_chastity: pleasure x0.75, pain x1.25) with a simpler single knob, since there's no separate
	// per-action arousal/pain dispatch pipeline here to hook both ends of.
	if(amount > 0 && is_spiked_and_locked())
		try_do_pain_effect(amount * 1.5)
		amount *= 0.5
	arousal = clamp(arousal + amount, 0, MAX_AROUSAL)
	if(amount > 0)
		last_arousal_increase_time = world.time
	on_arousal_changed()
	if(arousal >= PASSIVE_EJAC_THRESHOLD)
		handle_passive_ejaculation()

/// Called any time `arousal` changes -- refreshes every visual feedback mechanism this port has for it.
/datum/sex_controller/proc/on_arousal_changed()
	update_pink_screen()
	update_genital_arousal_visuals()

/// Severity 0-6, matching icons/effects/sexcon_screen.dmi's real "pink0".."pink6" frames -- each one a radial
/// vignette (fully transparent dead-center, pink creeping in from the corners/edges, same structural idea as
/// icons/mob/screen_full.dmi's own brutedamageoverlay0..6, which never touches the exact center either) that both
/// widens (creeps further inward) and darkens (higher edge alpha) with severity. Replaces the first version's flat
/// full-screen alpha wash, per live feedback that it "shouldn't obscure the entire screen" and should instead
/// "creep in from the edges and slowly increase both in area and intensity" -- explicitly pointing at the existing
/// pain overlay as the reference, which is exactly what got reverse-engineered here.
/datum/sex_controller/proc/update_pink_screen()
	if(!user)
		return
	if(hide_genital_visuals || arousal <= 0)
		user.clear_fullscreen("horny")
		return
	var/severity = clamp(round((arousal / MAX_AROUSAL) * 6), 1, 6)
	user.overlay_fullscreen("horny", /obj/screen/fullscreen/love, severity)

/**
 * Swaps the penis/vagina organ's sprite to its aroused ("_a_s") variant above AROUSAL_HARD_ON_THRESHOLD, and back
 * below it -- the actual genital-sprite arousal feedback the user asked to have ported over from Bubberstation/
 * SPLURT/Nova (see the file header for the confirmed source mechanism this mirrors: `is_erect`/`is_dripping` in
 * Bubberstation's own genitals.dm, both literally `aroused == AROUSAL_FULL`). Respects `hide_genital_visuals`
 * (forces flaccid regardless of actual arousal, same gate as the pink screen). Only calls update_icon() on an
 * organ whose is_aroused flag actually changed -- avoids a redundant full limb re-render every single tick while
 * arousal hovers above/below the threshold doing nothing new.
 * NOTE: calls owner.update_body(), NOT the organ's own update_icon()/on_update_icon() -- a real bug caught live
 * (user report: sprite never changed with arousal). on_update_icon() only rebuilds the ORGAN's own `mob_overlays`
 * instance var; nothing about calling it makes the human mob actually recomposite/display its appearance. That
 * only happens via update_body() (update_icons.dm), which is what actually reads each limb's get_overlays() and
 * rebuilds overlays_standing -- confirmed by grepping for update_body()'s only call sites codebase-wide
 * (_external_damage.dm and appearance.dm both call `owner.update_body()` directly after an organ-level change,
 * never just the organ's own update_icon()).
 */
/datum/sex_controller/proc/update_genital_arousal_visuals()
	if(!user)
		return
	var/should_be_aroused = arousal >= AROUSAL_HARD_ON_THRESHOLD && !hide_genital_visuals
	var/changed = FALSE
	var/obj/item/organ/internal/mutant/penis/P = user.internal_organs_by_name[BP_PENIS]
	if(istype(P) && P.is_aroused != should_be_aroused)
		P.is_aroused = should_be_aroused
		changed = TRUE
	var/obj/item/organ/internal/mutant/vagina/V = user.internal_organs_by_name[BP_PUSSY]
	if(istype(V) && V.is_aroused != should_be_aroused)
		V.is_aroused = should_be_aroused
		changed = TRUE
	if(changed)
		user.update_body()

/datum/sex_controller/proc/adjust_charge(amount)
	charge = clamp(charge + amount, 0, get_max_charge())

/datum/sex_controller/proc/handle_charge(dt)
	if(charge < get_max_charge())
		adjust_charge(CHARGE_RECHARGE_RATE * dt)

/datum/sex_controller/proc/handle_arousal_unhorny(dt)
	if(!arousal)
		return
	if(manual_arousal != SEX_MANUAL_AROUSAL_DEFAULT)
		return // held at a fixed value by apply_manual_arousal() -- not subject to passive decay
	if(world.time < last_arousal_increase_time + AROUSAL_TIME_TO_UNHORNY)
		return
	var/rate = AROUSAL_LOW_UNHORNY_RATE
	if(arousal > 100)
		rate = AROUSAL_HIGH_UNHORNY_RATE
	else if(arousal > 50)
		rate = AROUSAL_MID_UNHORNY_RATE
	arousal = max(0, arousal - (rate * dt))
	on_arousal_changed()

/// Whether the user is currently wearing a locked, spiked chastity device blocking a part they have (i.e. it's
/// actually pinching something, not just locked shut on an already-inaccessible organ).
/datum/sex_controller/proc/is_spiked_and_locked()
	var/obj/item/chastity/C = user.chastity_device
	if(!istype(C) || !C.is_locked() || !C.spiked)
		return FALSE
	return has_chastity_penis() || has_chastity_vagina()

/// Ratwood's own real values (sexcon.dm get_speed_multiplier()) -- how much faster than do_time's baseline the
/// current_action actually re-fires. This is what makes the Speed dropdown have any effect at all: previously
/// Process() called on_perform() every fixed SSobj tick regardless of do_time/speed entirely, so changing Speed
/// did nothing except feed into a couple actions' own arousal-gain formulas.
/// Bumped past Ratwood's own real values (1.0/1.5/2.0/2.5/3.0) -- those were tuned against a timer system with no
/// 1-second poll floor to begin with; on top of fixing the floor itself (see this proc's callers), widened the
/// actual spread per live feedback that even a "fixed" MID/HIGH/EXTREME/LUDICROUS still felt too close together/
/// too slow.
/datum/sex_controller/proc/get_speed_multiplier()
	switch(speed)
		if(SEX_SPEED_LOW)
			return 1.0
		if(SEX_SPEED_HIGH)
			return 2.5
		if(SEX_SPEED_EXTREME)
			return 3.5
		if(SEX_SPEED_LUDICROUS)
			return 5.0
	return 1.8 // SEX_SPEED_MID

/**
 * A small pixel-offset animate() bump toward `other` -- adapted from Ratwood's own do_thrust_animate() (sexcon.dm),
 * stripped of its rogue bed/table/pillory/grass furniture-jostling side effects (none of that furniture exists in
 * this codebase). Speed shortens the animation's duration; force widens how far it moves. Self-targeted actions
 * (masturbation) don't call this at all -- there's no meaningful "thrust toward yourself" direction.
 */
/**
 * The camera-offset bug a live report described ("tied to being aroused", drifting further the longer a scene
 * runs) traced back to this proc, not the pink overlay -- confirmed by re-reading it, not by more live testing.
 * It used to read `user.pixel_x`/`pixel_y` AT CALL TIME as the "resting" position to animate away from and back
 * to. Since this fires on every single action tick (repeatedly, via schedule_next_perform()'s timer) and animate()
 * updates pixel_x/pixel_y PROGRESSIVELY over its `time` window (not just at the end), a new tick reading "the
 * current value" while the PREVIOUS tick's return-to-rest animation was still mid-flight would capture some
 * partially-drifted intermediate value as the new "old_x" -- compounding a little further every tick, with no
 * ceiling, for as long as a continuous action kept running. Fixed by hardcoding 0 as the resting position instead
 * of ever reading it back, matching the exact convention this codebase's own pre-existing thrust-style animation
 * already uses (code/modules/mob/grab/grab_datum.dm's adjust_position()/reset_position(): `animate(pixel_x = 0,
 * pixel_y = 0, ...)`, never "whatever pixel_x currently is").
 */
/datum/sex_controller/proc/do_thrust_animate(mob/living/carbon/human/other, pixels = 4, time = 3)
	if(!user || !other || user == other)
		return
	var/dir = get_dir(user, other)
	if(!dir)
		return
	if(speed > SEX_SPEED_MID)
		time = max(1, time - 1)
	if(force >= SEX_FORCE_HIGH)
		pixels += 2
	var/dx = 0
	var/dy = 0
	if(dir & NORTH)
		dy = pixels
	else if(dir & SOUTH)
		dy = -pixels
	if(dir & EAST)
		dx = pixels
	else if(dir & WEST)
		dx = -pixels
	animate(user, pixel_x = dx, pixel_y = dy, time = time, easing = LINEAR_EASING)
	animate(pixel_x = 0, pixel_y = 0, time = time, easing = LINEAR_EASING)

/datum/sex_controller/proc/get_generic_force_adjective()
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(low_force_adjectives)
		if(SEX_FORCE_HIGH)
			return pick(high_force_adjectives)
		if(SEX_FORCE_EXTREME)
			return pick(extreme_force_adjectives)
		if(SEX_FORCE_LUDICROUS)
			return pick(ludicrous_force_adjectives)
	return pick(mid_force_adjectives)

/// Ratwood's own spanify_force() wraps a string in a CSS span class (love_low/love_mid/etc) this codebase has no
/// equivalent stylesheet for -- ported as an inline <font color> instead (matching how Ratwood's own get_force_
/// string()/get_speed_string() already do inline color for their status labels), same 5-color gradient.
/// Ratwood's own 5 hex values (#eac8de/#e9a8d1/#f05ee1/#d146f5/#d61a43) were all pale, closely-related pinks except
/// the very last -- live feedback confirmed LOW and MID in particular read as "the same color". Replaced with a
/// deliberately steep light-pink-to-near-black-red gradient so each tier is unambiguous at a glance, not just
/// technically-distinct hex values.
/datum/sex_controller/proc/spanify_force(string)
	var/force_color = "#e0729c" // SEX_FORCE_MID
	switch(force)
		if(SEX_FORCE_LOW)
			force_color = "#f4c2c2"
		if(SEX_FORCE_HIGH)
			force_color = "#c9184a"
		if(SEX_FORCE_EXTREME)
			force_color = "#a4133c"
		if(SEX_FORCE_LUDICROUS)
			force_color = "#590d22"
	return "<font color='[force_color]'>[string]</font>"

/// Maps a FORCE TIER (of whoever is DOING the touching) to a flat pain amount for try_do_pain_effect() below --
/// call this on the ACTOR's own controller and pass the result into the RECEIVER's try_do_pain_effect(), never the
/// other way around (see that proc's own header comment for the bug this fixes).
/// Bumped past the plain PAIN_MILD/MED/HIGH_EFFECT constants (10/20/30) -- those were tuned assuming
/// PAIN_MINIMUM_FOR_DAMAGE (=20) still gated real damage out below EXTREME, silently making HIGH force a
/// message-only flinch with no real bite (live feedback: "not enough pain" specifically at high force).
/// damage_from_pain() below no longer gates on that constant at all -- these are the real, final halloss amounts.
/// Returns a MESSAGE-severity value (matches PAIN_MILD/MED/HIGH_EFFECT, also what try_do_pain_effect() below
/// compares against to pick a flinch/wince/cry-out message) -- NOT the real health-damage amount, which
/// damage_from_pain() derives from this at a much smaller scale. The previous flat 15/30/50 (before that, an even
/// more aggressive multiplier-based formula) was live-reported as "way too much halloss damage" -- see
/// damage_from_pain()'s own header for why that's a bigger deal in this codebase than it sounds.
/datum/sex_controller/proc/get_pain_for_force(force_tier)
	switch(force_tier)
		if(SEX_FORCE_HIGH)
			return PAIN_MILD_EFFECT
		if(SEX_FORCE_EXTREME)
			return PAIN_MED_EFFECT
		if(SEX_FORCE_LUDICROUS)
			return PAIN_HIGH_EFFECT
	return 0

/**
 * Applies real pain via DAMAGE_STUN -> human's own adjustHalLoss() -> per-organ add_pain() (human_damage.dm/
 * _external_damage.dm) -- confirmed this correctly does NOT touch brute_dam/burn_dam at all (see
 * PAIN_SAFETY_SHOCK_CAP's header comment, sexcon_defines.dm, for the full corrected mechanism -- an earlier pass
 * wrongly believed this silently became brute damage from reading the wrong /mob/living stub). Gated on
 * user.get_shock() (the real "how much pain am I already in" reading, already accounting for painkillers) rather
 * than raw health, since health conflates pain with unrelated damage types -- stays comfortably under the real
 * paralysis trigger (species.total_health, life.dm) instead of ever approaching it.
 */
/datum/sex_controller/proc/damage_from_pain(pain_amt)
	if(pain_amt <= 0)
		return
	if(!user || user.get_shock() >= PAIN_SAFETY_SHOCK_CAP)
		return
	user.apply_damage(pain_amt / PAIN_DAMAGE_DIVISOR, DAMAGE_STUN)

/**
 * `pain_amt` must already be the FINAL amount (see get_pain_for_force() above) -- this proc used to multiply it by
 * get_force_pain_multiplier(force) internally, but `force` here is `src.force`, and this is always called on the
 * RECEIVING party's own controller (e.g. `target_con.try_do_pain_effect(...)`) -- meaning it was scaling pain by
 * the passive receiver's own unrelated force dial, not the actor's, a real logic bug caught while redesigning this
 * for clearer per-tier scaling (item 6 of a live feedback batch), not by observing wrong numbers in play.
 * PAIN_COOLDOWN now gates the actual damage_from_pain() call too, not just the flinch/wince/cry-out message below
 * -- previously only the message was throttled, so pain was silently being applied on EVERY action tick (as often
 * as do_time/get_speed_multiplier() allows, sub-second at high Speed) while this proc's own cooldown check only
 * ever suppressed the TEXT. That mismatch, not the per-application amount alone, was the real reason pain could
 * outpace organs' own slow passive decay (~1-3/tick, _external.dm) and accumulate toward the paralysis threshold.
 */
/datum/sex_controller/proc/try_do_pain_effect(pain_amt)
	if(pain_amt <= 0)
		return
	if(world.time < last_pain + PAIN_COOLDOWN)
		return
	last_pain = world.time
	damage_from_pain(pain_amt)
	var/msg = "[user] flinches."
	if(pain_amt >= PAIN_HIGH_EFFECT)
		msg = "[user] cries out in pain!"
	else if(pain_amt >= PAIN_MED_EFFECT)
		msg = "[user] winces in pain."
	user.sexcon_action_message(SPAN_WARNING(msg), SPAN_WARNING("That hurts!"))

/datum/sex_controller/proc/handle_passive_ejaculation()
	if(charge >= CHARGE_FOR_CLIMAX && (world.time > last_ejaculation_time + MOAN_COOLDOWN))
		ejaculate()

// Sound effects, ported directly from Ratwood-2.0-main's own sound/misc/mat/ folder (copied into
// sound/misc/sexcon/ -- see intercourse_noise()/outercourse_noise()/generic_sex_noise() below for how each list is
// used). Kept as this codebase's own /sound/misc/sexcon/ tree rather than reusing Ratwood's original paths, since
// this is a different repo with its own asset layout.
/datum/sex_controller/var/static/list/intercourse_gentle_sounds = list('sound/misc/sexcon/intercourse/gentle (1).ogg', 'sound/misc/sexcon/intercourse/gentle (2).ogg', 'sound/misc/sexcon/intercourse/gentle (3).ogg')
/datum/sex_controller/var/static/list/intercourse_firm_sounds = list('sound/misc/sexcon/intercourse/firm (1).ogg', 'sound/misc/sexcon/intercourse/firm (2).ogg', 'sound/misc/sexcon/intercourse/firm (3).ogg')
/datum/sex_controller/var/static/list/intercourse_rough_sounds = list('sound/misc/sexcon/intercourse/rough (1).ogg', 'sound/misc/sexcon/intercourse/rough (2).ogg', 'sound/misc/sexcon/intercourse/rough (3).ogg')
/datum/sex_controller/var/static/list/intercourse_brutal_sounds = list('sound/misc/sexcon/intercourse/brutal (1).ogg', 'sound/misc/sexcon/intercourse/brutal (2).ogg', 'sound/misc/sexcon/intercourse/brutal (3).ogg')
/datum/sex_controller/var/static/list/intercourse_knotfuck_sounds = list('sound/misc/sexcon/intercourse/knotfuck (1).ogg', 'sound/misc/sexcon/intercourse/knotfuck (2).ogg', 'sound/misc/sexcon/intercourse/knotfuck (3).ogg', 'sound/misc/sexcon/intercourse/knotfuck (4).ogg')
/datum/sex_controller/var/static/list/intercourse_plap_sounds = list('sound/misc/sexcon/intercourse/plap layer (1).ogg', 'sound/misc/sexcon/intercourse/plap layer (2).ogg', 'sound/misc/sexcon/intercourse/plap layer (3).ogg', 'sound/misc/sexcon/intercourse/plap layer (4).ogg')
/datum/sex_controller/var/static/list/outercourse_gentle_sounds = list('sound/misc/sexcon/outercourse/gentle (1).ogg', 'sound/misc/sexcon/outercourse/gentle (2).ogg', 'sound/misc/sexcon/outercourse/gentle (3).ogg')
/datum/sex_controller/var/static/list/outercourse_firm_sounds = list('sound/misc/sexcon/outercourse/firm (1).ogg', 'sound/misc/sexcon/outercourse/firm (2).ogg', 'sound/misc/sexcon/outercourse/firm (3).ogg')
/datum/sex_controller/var/static/list/outercourse_rough_sounds = list('sound/misc/sexcon/outercourse/rough (1).ogg', 'sound/misc/sexcon/outercourse/rough (2).ogg', 'sound/misc/sexcon/outercourse/rough (3).ogg')
/datum/sex_controller/var/static/list/outercourse_brutal_sounds = list('sound/misc/sexcon/outercourse/brutal (1).ogg', 'sound/misc/sexcon/outercourse/brutal (2).ogg')
/datum/sex_controller/var/static/list/outercourse_wetness_sounds = list('sound/misc/sexcon/outercourse/wetness (1).ogg', 'sound/misc/sexcon/outercourse/wetness (2).ogg', 'sound/misc/sexcon/outercourse/wetness (3).ogg')

/// Masturbation-tier sound -- Ratwood's own generic_sex_noise(), which only ever played 'fingering.ogg' regardless
/// of organ; picks between the two source files that best match this codebase's actual masturbate/penis vs
/// /vagina split instead.
/datum/sex_controller/proc/generic_sex_noise()
	if(!user)
		return
	playsound(user, can_use_penis() ? 'sound/misc/sexcon/fap.ogg' : 'sound/misc/sexcon/fingering.ogg', 30, TRUE)

/// Penetrative (vaginal_sex, future anal/oral) sound -- ported from Ratwood's own intercourse_noise(), force-tiered,
/// with a knot-specific sound swap at HIGH+ while do_knot_action is armed on a knot_capable action.
/datum/sex_controller/proc/intercourse_noise(atom/movable/noise_target)
	if(!user || !noise_target)
		return
	var/knotting = do_knot_action && current_action?.knot_capable
	switch(force)
		if(SEX_FORCE_LOW)
			playsound(noise_target, pick(intercourse_gentle_sounds), 50, TRUE)
		if(SEX_FORCE_HIGH)
			playsound(noise_target, pick(intercourse_plap_sounds), 40, TRUE)
			playsound(noise_target, pick(knotting ? intercourse_knotfuck_sounds : intercourse_rough_sounds), 60, TRUE)
		if(SEX_FORCE_EXTREME, SEX_FORCE_LUDICROUS)
			playsound(noise_target, pick(intercourse_plap_sounds), 60, TRUE)
			playsound(noise_target, pick(knotting ? intercourse_knotfuck_sounds : intercourse_brutal_sounds), 60, TRUE)
		else // SEX_FORCE_MID
			playsound(noise_target, pick(intercourse_plap_sounds), 20, TRUE)
			playsound(noise_target, pick(intercourse_firm_sounds), 50, TRUE)

/// Hand-based (hand_on_partner) sound -- ported from Ratwood's own outercourse_noise(), force-tiered, with an
/// optional wetness layer for vagina-targeting actions (fingering).
/datum/sex_controller/proc/outercourse_noise(atom/movable/noise_target, wetness_layer = FALSE)
	if(!user || !noise_target)
		return
	switch(force)
		if(SEX_FORCE_LOW)
			playsound(noise_target, pick(outercourse_gentle_sounds), 10, TRUE)
		if(SEX_FORCE_HIGH)
			if(wetness_layer)
				playsound(noise_target, pick(outercourse_wetness_sounds), 20, TRUE)
			playsound(noise_target, pick(outercourse_rough_sounds), 50, TRUE)
		if(SEX_FORCE_EXTREME, SEX_FORCE_LUDICROUS)
			if(wetness_layer)
				playsound(noise_target, pick(outercourse_wetness_sounds), 30, TRUE)
			playsound(noise_target, pick(intercourse_plap_sounds), 30, TRUE)
			playsound(noise_target, pick(outercourse_brutal_sounds), 60, TRUE)
		else // SEX_FORCE_MID
			if(wetness_layer)
				playsound(noise_target, pick(outercourse_wetness_sounds), 10, TRUE)
			playsound(noise_target, pick(outercourse_firm_sounds), 30, TRUE)

/datum/sex_controller/proc/ejaculate()
	if(!user)
		return
	var/is_penis = can_use_penis()
	var/msg = is_penis ? "[user] makes a mess!" : "[user] gushes!"
	user.sexcon_action_message(SPAN_WARNING(msg), SPAN_WARNING("You climax!"))
	adjust_charge(-CHARGE_FOR_CLIMAX)
	set_arousal(40)
	last_ejaculation_time = world.time
	user.emote("moan")
	playsound(user, is_penis ? 'sound/misc/sexcon/endout.ogg' : 'sound/misc/sexcon/end.ogg', 50, TRUE)

	var/obj/item/reagent_containers/glass/held = user.get_active_hand()
	if(istype(held) && held.reagents && held.reagents.total_volume < held.volume)
		held.reagents.add_reagent(is_penis ? /datum/reagent/erpjuice/cum : /datum/reagent/erpjuice/femcum, is_penis ? 3 : 2)

	if(is_penis)
		try_form_knot() // must run before do_until_finished's stop_current_action() below -- see try_form_knot()'s own header comment
	if(do_until_finished)
		stop_current_action()
