// Genital sprite visibility -- ported from Bubberstation's own real toggle_genitals() verb (modular_skyrat/.../
// genitals.dm, GAME_VERB_DESC) as closely as this codebase allows, including Bubberstation's own per-organ
// granularity (a picker for a specific genital, or "All") -- an earlier pass simplified this down to one mob-wide
// setting, per explicit follow-up request restored to match Bubberstation's real shape.
// Not saved via /datum/preferences -- like Bubberstation's own version, this is live, in-round state that resets
// to the default (Hidden by Clothes) on respawn, not a character-setup choice.
/mob/living/carbon/human
	/// organ_tag -> GENITAL_* value. An organ_tag absent from this list uses the default (Hidden by Clothes).
	var/list/genital_visibility = list()

/mob/living/carbon/human/proc/get_genital_visibility(organ_tag)
	return genital_visibility[organ_tag] || GENITAL_HIDDEN_BY_CLOTHES

/mob/living/carbon/human/proc/should_show_genitals(organ_tag, zone_flag)
	switch(get_genital_visibility(organ_tag))
		if(GENITAL_NEVER_SHOW)
			return FALSE
		if(GENITAL_ALWAYS_SHOW)
			return TRUE
	return get_zone_exposed(zone_flag)

/mob/living/carbon/human/proc/has_genital_organs()
	for(var/obj/item/organ/internal/mutant/MO in internal_organs)
		if(MO.is_genital)
			return TRUE
	return FALSE

/**
 * Clothing coverage is a SEPARATE overlay layer from a limb's own rendered appearance in this codebase (confirmed:
 * update_inv_w_uniform()/update_inv_wear_suit() only ever touch overlays_standing[] + queue_icon_update(), never
 * update_body()) -- meaning taking pants off does NOT, on its own, re-trigger the chest/groin limb's own
 * get_icon_key() comparison at all, so get_groin_mutant_icon()'s should_show_genitals() check (gated correctly by
 * a real key-content fix in get_mutant_organs_icon_key(), _external_icons.dm) would still never actually get
 * RE-EVALUATED after a clothing change without this. Called from the 3 real places genital-relevant coverage can
 * change: uniform/suit equip-or-removal (update_icons.dm) and underwear equip/removal (clothing/underwear/base.dm).
 * Gated on has_genital_organs() so this is a no-op for the common case (a human with no genital organs at all).
 */
/mob/living/carbon/human/proc/refresh_genital_visibility_if_needed()
	if(has_genital_organs())
		update_body()

/mob/living/carbon/human/verb/toggle_genitals()
	set name = "Expose/Hide Genitals"
	set desc = "Change which genitals show through clothing, and how."
	set category = "IC"

	if(stat != CONSCIOUS)
		to_chat(src, SPAN_WARNING("You can't do that right now."))
		return

	var/list/genital_organs = list()
	for(var/obj/item/organ/internal/mutant/MO in internal_organs)
		if(MO.is_genital)
			genital_organs[capitalize(MO.name)] = MO.organ_tag
	if(!length(genital_organs))
		to_chat(src, SPAN_WARNING("You have no genitals to expose or hide."))
		return
	genital_organs["All"] = "all"

	var/picked_name = input(src, "Choose which genitalia to expose/hide", "Expose/Hide Genitals") as null|anything in genital_organs
	if(!picked_name || !(picked_name in genital_organs))
		return
	var/picked_tag = genital_organs[picked_name]

	var/list/options = list("Never show" = GENITAL_NEVER_SHOW, "Hidden by clothes" = GENITAL_HIDDEN_BY_CLOTHES, "Always show" = GENITAL_ALWAYS_SHOW)
	var/picked_option = input(src, "Choose visibility setting", "Expose/Hide Genitals") as null|anything in options
	if(!picked_option || !(picked_option in options))
		return

	if(picked_tag == "all")
		for(var/obj/item/organ/internal/mutant/MO in internal_organs)
			if(MO.is_genital)
				genital_visibility[MO.organ_tag] = options[picked_option]
	else
		genital_visibility[picked_tag] = options[picked_option]
	update_body()
	to_chat(src, SPAN_NOTICE("[picked_name == "All" ? "Your genitals" : "Your [lowertext(picked_name)]"] will now [lowertext(picked_option)]."))
