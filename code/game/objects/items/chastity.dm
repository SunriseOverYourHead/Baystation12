// Core chastity device -- a deliberately trimmed adaptation of Ratwood-2.0-main's own chastity system
// (modular/code/game/objects/items/lewd/chastity/, ~1400 lines across chastity_core/cursed/equip/variants +
// chastity_helpers.dm + the key items). Ratwood's own device is NOT worn in a real clothing slot either -- it uses
// a bespoke "snowflake slot" var (`chastity_feature`, a bodypart_feature datum) plus a whole trait-list lookup
// table (chastity_standard_traits) and CURSED variants (magically-locked, mode-switching, tied to a cursed-collar
// signal/tally system). This port keeps the same "not a real clothing slot" shape (a direct mob-var ref, exactly
// like Ratwood's own reasoning: "belts don't work as clothing equippables") but drops, as separate follow-up work
// not started yet:
// - Cursed devices entirely (chastity_cursed.dm, 376 lines) -- a whole magic/curse subsystem tied to a "cursed
//   collar" master-mind item that doesn't exist here, and to signals this codebase has none of.
// - Spiked variants' pleasure/pain multiplier -- no pain mechanic exists yet in the ported sexcon engine at all
//   (try_do_pain_effect/damage_from_pain were never ported; PAIN_MILD/MED/HIGH_EFFECT sit unused in
//   sexcon_defines.dm). A spiked variant with nothing to multiply would be a no-op, so it's deferred together with
//   the pain system rather than half-built now.
// - JSON flavor-text string banks -- plain inline strings for now.
// - Crafting recipes, key items beyond the plain generic /obj/item/key already in this codebase.
// This codebase already has a real, generic lock/key primitive (code/modules/locks/lock.dm, /datum/lock +
// /obj/item/key) -- reused here directly instead of inventing new lock-matching logic.

/mob/living/carbon/human
	var/obj/item/chastity/chastity_device

/datum/sex_controller/proc/has_chastity_penis()
	var/obj/item/chastity/C = user.chastity_device
	return istype(C) && C.is_locked() && C.blocks_penis

/datum/sex_controller/proc/has_chastity_vagina()
	var/obj/item/chastity/C = user.chastity_device
	return istype(C) && C.is_locked() && C.blocks_vagina

/datum/sex_controller/proc/has_chastity_anal()
	var/obj/item/chastity/C = user.chastity_device
	return istype(C) && C.is_locked() && C.blocks_anal

/datum/sex_controller/proc/has_chastity_cage()
	return has_chastity_penis() || has_chastity_vagina()

/obj/item/chastity
	name = "chastity cage"
	desc = "A metal device designed to prevent penetrative sex. It has a lock built into the front."
	// Placeholder sprite -- no dedicated chastity-device art exists in this codebase yet (Ratwood's own icons
	// live in modular/icons/obj/lewd/chastity.dmi, a modular-only asset not present here). Reuses the generic
	// belt sprite until real art is made; purely a visual placeholder, doesn't affect the mechanic.
	icon = 'icons/obj/clothing/obj_belt.dmi'
	icon_state = "utilitybelt"
	w_class = ITEM_SIZE_TINY

	/// Which of the wearer's parts this specific device blocks -- concrete subtypes set these, not chastity_type
	/// index tables like Ratwood's own (that table's real job, mapping an index to a trait list, has no equivalent
	/// need here since there's no trait system to toggle).
	var/blocks_penis = TRUE
	var/blocks_vagina = FALSE
	var/blocks_anal = FALSE
	/// If TRUE, arousal gained while locked and blocking a part the wearer has is mostly converted to pain
	/// instead (/datum/sex_controller/proc/adjust_arousal()) -- the substitute for Ratwood's own spiked-variant
	/// pleasure/pain multiplier pair.
	var/spiked = FALSE

	var/datum/lock/lock
	var/mob/living/carbon/human/wearer

/obj/item/chastity/Initialize(mapload)
	. = ..()
	lock = new(src, 4) // /datum/lock/New() defaults status to locked already -- ships pre-locked
	new /obj/item/key/chastity(get_turf(src), lock.lock_data, src)

/obj/item/chastity/Destroy()
	if(wearer)
		unequip_from(wearer)
	QDEL_NULL(lock)
	return ..()

/obj/item/chastity/proc/is_locked()
	return lock?.isLocked()

/obj/item/chastity/examine(mob/user)
	. = ..()
	to_chat(user, is_locked() ? SPAN_WARNING("It's locked.") : SPAN_NOTICE("It's unlocked."))

/obj/item/chastity/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(wearer == H)
		if(is_locked())
			to_chat(user, SPAN_WARNING("You need to unlock \the [src] first!"))
			return
		unequip_from(H)
		to_chat(user, SPAN_NOTICE("You remove \the [src]."))
		return
	if(wearer)
		return
	equip_onto(H, user)

/obj/item/chastity/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !ishuman(target) || wearer)
		return
	var/mob/living/carbon/human/H = target
	if(H == user)
		return // self-equip goes through attack_self (activate-held-item) instead
	equip_onto(H, user)

/obj/item/chastity/proc/equip_onto(mob/living/carbon/human/target, mob/user)
	if(target.chastity_device)
		to_chat(user, SPAN_WARNING("[target] is already wearing a chastity device."))
		return FALSE
	if(!user.drop_from_inventory(src))
		return FALSE
	forceMove(target)
	wearer = target
	target.chastity_device = src
	target.visible_message(SPAN_NOTICE("[user] fits \the [src] onto [target]!"), SPAN_NOTICE("[user] fits \the [src] onto you."))
	return TRUE

/obj/item/chastity/proc/unequip_from(mob/living/carbon/human/target)
	if(!target)
		return
	if(target.chastity_device == src)
		target.chastity_device = null
	wearer = null
	var/turf/T = get_turf(target)
	if(T)
		forceMove(T)

/obj/item/chastity/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(istype(I, /obj/item/key) && lock)
		var/was_locked = is_locked()
		if(!lock.toggle(I, user))
			to_chat(user, SPAN_WARNING("\The [I] does not fit \the [src]'s lock!"))
		else
			to_chat(user, SPAN_NOTICE("You [was_locked ? "unlock" : "lock"] \the [src]."))
		return TRUE
	return ..()

/obj/item/chastity/cage
	name = "cock cage"
	desc = "A metal cage designed to prevent an erection. It has a lock built into the front."

/obj/item/chastity/belt
	name = "chastity belt"
	desc = "A metal belt designed to prevent penetration. It has a lock built into the front."
	blocks_penis = FALSE
	blocks_vagina = TRUE
	blocks_anal = TRUE

/obj/item/chastity/cage/spiked
	name = "spiked cock cage"
	desc = "A metal cage lined with small spikes. Getting excited while wearing this is a bad idea."
	spiked = TRUE

/obj/item/key/chastity
	name = "chastity key"
	desc = "A small key. It looks like it fits a chastity device."

	/// The specific device this key was generated for -- purely descriptive (examine flavor); the actual
	/// unlock check is done by /datum/lock's own key_data comparison, not by this ref.
	var/obj/item/chastity/paired_device

/obj/item/key/chastity/New(newloc, data, obj/item/chastity/paired)
	. = ..(newloc, data)
	paired_device = paired
