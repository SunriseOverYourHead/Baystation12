/singleton/species/proc/get_valid_shapeshifter_forms(mob/living/carbon/human/H)
	return list()

/singleton/species/proc/get_additional_examine_text(mob/living/carbon/human/H)
	return

/singleton/species/proc/get_tail(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/tail/T = H.internal_organs_by_name[BP_TAIL]
	if(T?.sprite_datum)
		return T.sprite_datum.icon_state
	return tail

/singleton/species/proc/get_tail_animation(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/tail/T = H.internal_organs_by_name[BP_TAIL]
	if(T?.sprite_datum?.icon_animation)
		return T.sprite_datum.icon_animation
	return tail_animation

/singleton/species/proc/get_tail_hair(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/tail/T = H.internal_organs_by_name[BP_TAIL]
	if(T?.sprite_datum)
		return T.sprite_datum.hair_state
	return tail_hair

/singleton/species/proc/get_tail_blend(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/tail/T = H.internal_organs_by_name[BP_TAIL]
	if(T?.sprite_datum)
		return T.sprite_datum.mutant_blend
	return tail_blend

// Returns the tail organ's own color override, or null if it should fall back to skin_color (the pre-organ
// default behaviour).
/singleton/species/proc/get_tail_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/tail/T = H.internal_organs_by_name[BP_TAIL]
	if(T && T.colors && T.colors[1])
		return T.colors[1]
	return null

// Most mutant-organ categories (tail/horns/frills/etc) are opt-in cosmetic add-ons, off by default until the
// player explicitly enables them in chargen (see /datum/preferences/copy_to(), preferences.dm) -- fine for a
// species like Anthro where the organ is a true option. For a species where the organ is just part of the
// canonical body (e.g. a Unathi's tail), that opt-in-off-by-default behaviour is wrong: it deletes the organ
// entirely unless the player happens to toggle it on, and even then offers a "None" choice that falls back to
// a stale legacy tail sprite (get_tail() etc, species_getters.dm) instead of actually removing anything. A
// species overriding this to TRUE for an organ_tag keeps that organ always present with its default style
// (colors are still customizable), with no toggle or "None" option shown at all.
/singleton/species/proc/is_mutant_organ_mandatory(organ_tag)
	return FALSE

// Wings have no legacy species-level fallback (unlike tail) -- they only ever exist as a chosen organ, so these
// simply return null when there's no organ or no style picked, which callers treat as "don't draw wings."
/singleton/species/proc/get_wings(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/wings/W = H.internal_organs_by_name[BP_WINGS]
	if(W?.sprite_datum)
		return W.sprite_datum.icon_state
	return null

/singleton/species/proc/get_wings_icon_file(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/wings/W = H.internal_organs_by_name[BP_WINGS]
	if(W?.sprite_datum)
		return W.sprite_datum.icon
	return null

/singleton/species/proc/get_wings_blend(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/wings/W = H.internal_organs_by_name[BP_WINGS]
	if(W?.sprite_datum)
		return W.sprite_datum.mutant_blend
	return ICON_ADD

/singleton/species/proc/get_wings_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/wings/W = H.internal_organs_by_name[BP_WINGS]
	if(W && W.colors && W.colors[1])
		return W.colors[1]
	return null

// Fluff and Moth Markings mirror Wings' getters exactly -- same reasoning (oversized 45x34 art rendered as a
// dedicated mob-level overlay, not through chest's compositing loop) and no legacy species-level fallback either.
/singleton/species/proc/get_fluff(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/fluff/F = H.internal_organs_by_name[BP_FLUFF]
	if(F?.sprite_datum)
		return F.sprite_datum.icon_state
	return null

/singleton/species/proc/get_fluff_icon_file(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/fluff/F = H.internal_organs_by_name[BP_FLUFF]
	if(F?.sprite_datum)
		return F.sprite_datum.icon
	return null

/singleton/species/proc/get_fluff_blend(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/fluff/F = H.internal_organs_by_name[BP_FLUFF]
	if(F?.sprite_datum)
		return F.sprite_datum.mutant_blend
	return ICON_ADD

/singleton/species/proc/get_fluff_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/mutant/fluff/F = H.internal_organs_by_name[BP_FLUFF]
	if(F && F.colors && F.colors[1])
		return F.colors[1]
	return null

/singleton/species/proc/get_blood_mask(mob/living/carbon/human/H)
	return blood_mask

/singleton/species/proc/get_damage_overlays(mob/living/carbon/human/H)
	return damage_overlays

/singleton/species/proc/get_damage_mask(mob/living/carbon/human/H)
	return damage_mask

/singleton/species/proc/get_examine_name(mob/living/carbon/human/H)
	return name

/singleton/species/proc/get_icobase(mob/living/carbon/human/H, get_deform)
	return (get_deform ? deform : icobase)

/singleton/species/proc/get_station_variant()
	return name

/singleton/species/proc/get_race_key(mob/living/carbon/human/H)
	return race_key

/singleton/species/proc/get_bodytype(mob/living/carbon/human/H)
	return name

/singleton/species/proc/get_knockout_message(mob/living/carbon/human/H)
	return ((H && H.isSynthetic()) ? "encounters a hardware fault and suddenly reboots!" : knockout_message)

/singleton/species/proc/get_death_message(mob/living/carbon/human/H)
	return ((H && H.isSynthetic()) ? "gives one shrill beep before falling lifeless." : death_message)

/singleton/species/proc/get_ssd(mob/living/carbon/human/H)
	if (H.ai_holder)
		return

	if (H.key)
		return ((H && H.isSynthetic()) ? "flashing a 'system offline' glyph on their monitor" : show_ssd)
	else
		return ((H && H.isSynthetic()) ? "displaying a blue screen on their monitor indicating total system failure" : show_coma)

/singleton/species/proc/get_blood_colour(mob/living/carbon/human/H)
	return ((H && H.isSynthetic()) ? SYNTH_BLOOD_COLOUR : blood_color)

/singleton/species/proc/get_flesh_colour(mob/living/carbon/human/H)
	return ((H && H.isSynthetic()) ? SYNTH_FLESH_COLOUR : flesh_color)

/singleton/species/proc/get_environment_discomfort(mob/living/carbon/human/H, msg_type)

	if(!prob(5))
		return

	var/covered = 0 // Basic coverage can help.
	for(var/obj/item/clothing/clothes in H)
		if (H.IsHolding(clothes))
			continue
		if((clothes.body_parts_covered & UPPER_TORSO) && (clothes.body_parts_covered & LOWER_TORSO))
			covered = 1
			break

	switch(msg_type)
		if("cold")
			if(!covered)
				to_chat(H, SPAN_DANGER("[pick(cold_discomfort_strings)]"))
		if("heat")
			if(covered)
				to_chat(H, SPAN_DANGER("[pick(heat_discomfort_strings)]"))

/singleton/species/proc/get_vision_flags(mob/living/carbon/human/H)
	return vision_flags

/singleton/species/proc/get_husk_icon(mob/living/carbon/human/H)
	return husk_icon

/singleton/species/proc/get_sex(mob/living/carbon/H)
	return H.gender

/singleton/species/proc/get_surgery_overlay_icon(mob/living/carbon/human/H)
	return 'icons/mob/surgery.dmi'

/singleton/species/proc/get_footstep(mob/living/carbon/human/H, footstep_type)
	return

/singleton/species/proc/get_brute_mod(mob/living/carbon/human/H)
	. = brute_mod

/singleton/species/proc/get_burn_mod(mob/living/carbon/human/H)
	. = burn_mod

/singleton/species/proc/get_toxins_mod(mob/living/carbon/human/H)
	. = toxins_mod

/singleton/species/proc/get_radiation_mod(mob/living/carbon/human/H)
	. = (H && H.isSynthetic() ? 0.5 : radiation_mod)

/singleton/species/proc/get_slowdown(mob/living/carbon/human/H)
	. = (H && H.isSynthetic() ? 0 : slowdown)
