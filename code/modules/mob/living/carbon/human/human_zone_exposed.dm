// A reusable "is this body zone currently covered by clothing" check -- extracted from print_flavor_text()'s own
// long-standing inline pattern (examine.dm) into a generic proc, adding LOWER_TORSO (groin) coverage, which that
// original check never needed. This is the primitive the sexcon engine's zone-accessibility check
// (code/datums/sexcon/sexcon.dm) is built on, standing in for Ratwood's own precise ~14-zone
// check_location_accessible() against this codebase's coarser 9-limb body model -- see
// baystation12soyh_ratwood_sexcon_port memory for the full rationale.
/mob/living/carbon/human/proc/get_zone_exposed(zone_flag)
	var/list/equipment = list(head, wear_mask, glasses, w_uniform, wear_suit, gloves, shoes)
	for(var/obj/item/clothing/C in equipment)
		if(C.body_parts_covered & zone_flag)
			return FALSE
	// worn_underwear items never set body_parts_covered (checked directly: base.dm's /obj/item/underwear/top/
	// bottom/socks/undershirt classes all leave it at the base /obj/item default of FLAGS_OFF) -- matched by
	// underwear TYPE here instead of touching that shared var, to avoid any risk of changing underwear's coverage
	// flag affecting some other system that reads it (protection checks, etc) in ways not fully traced.
	if(zone_flag & (UPPER_TORSO|LOWER_TORSO|FEET))
		for(var/obj/item/underwear/UW in worn_underwear)
			if((zone_flag & UPPER_TORSO) && (istype(UW, /obj/item/underwear/top) || istype(UW, /obj/item/underwear/undershirt)))
				return FALSE
			if((zone_flag & LOWER_TORSO) && istype(UW, /obj/item/underwear/bottom))
				return FALSE
			if((zone_flag & FEET) && istype(UW, /obj/item/underwear/socks))
				return FALSE
	return TRUE

// Maps a SEX_ZONE_* bitflag (sexcon_defines.dm) onto this codebase's own clothing-coverage bitflag
// (__defines/items_clothing.dm), for get_zone_exposed() above.
/proc/sex_zone_to_coverage_flag(zone_flag)
	switch(zone_flag)
		if(SEX_ZONE_GROIN)
			return LOWER_TORSO
		if(SEX_ZONE_CHEST)
			return UPPER_TORSO
		if(SEX_ZONE_MOUTH)
			return FACE
		if(SEX_ZONE_L_FOOT, SEX_ZONE_R_FOOT)
			return FEET
	return 0

// Finds the grab (if any) `src` currently holds on `target` -- the substitute for Ratwood's own
// get_highest_grab_state_on()/GRAB_AGGRESSIVE numeric-scale check, which doesn't exist here (this codebase's own
// grab system is a named upgrade/downgrade chain of /datum/grab singletons on a held /obj/item/grab, not a linear
// enum -- see code/modules/mob/grab/). `.restrains()` on the returned grab is the closest equivalent to "aggressive
// enough to bypass a positioning check": a grab strong enough to act like cuffs.
/mob/living/carbon/human/proc/get_grab_on(mob/living/carbon/human/target)
	if(!target)
		return null
	for(var/obj/item/grab/G in target.grabbed_by)
		if(G.assailant == src)
			return G
	return null
