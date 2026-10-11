/obj/item/organ/external/groin/insectoid/nabber
	name = "abdomen"
	icon_position = UNDER
	encased = "carapace"
	action_button_name = "Toggle Active Camo"
	cavity_max_w_class = ITEM_SIZE_LARGE
	// Hand-placed by the user directly in icons/mob/reference_parts.dmi (full 4-dir body composites + a separate
	// Hemi reference, diffed per-direction against Hemi's own known reference position -- NOT against a
	// regenerated body silhouette; the user's edited file had the body content cleared out of each species state,
	// leaving just the repositioned Hemi shape, and the first extraction pass wrongly diffed against a freshly
	// regenerated body, which folded the body's own "disappearance" into the measurement and produced badly wrong
	// values). Visually re-verified via a rendered composite before shipping this time.
	mutant_organ_pixel_offset = alist(
		SOUTH = list(0, -1),
		NORTH = list(0, -1),
		EAST = list(5, 0),
		WEST = list(-5, 0)
	)

/obj/item/organ/external/groin/insectoid/nabber/monarch_queen
	name = "abdomen"
	icon_position = UNDER
	encased = "carapace"
	// MSQ has its own distinct body art (nabber/msq/body.dmi, a standard 32x32 tile, unlike base GAS/Worker's
	// 32x40) -- hand-placed the same way as GAS's above.
	mutant_organ_pixel_offset = alist(
		SOUTH = list(1, -7),
		NORTH = list(0, -7),
		EAST = list(5, -5),
		WEST = list(-5, -5)
	)

/obj/item/organ/external/groin/insectoid/nabber/refresh_action_button()
	. = ..()
	if(.)
		action.button_icon_state = "nabber-cloak-[owner && owner.is_cloaked_by(species) ? 1 : 0]"
		if(action.button) action.button.UpdateIcon()

/obj/item/organ/external/groin/insectoid/nabber/attack_self(mob/user)
	. = ..()
	if(.)
		if(owner.is_cloaked_by(species))
			owner.remove_cloaking_source(species)
		else
			owner.add_cloaking_source(species)
			owner.apply_effect(2, EFFECT_STUN, 0)
		refresh_action_button()
