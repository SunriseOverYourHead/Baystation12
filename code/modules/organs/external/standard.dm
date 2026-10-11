/****************************************************
			   ORGAN DEFINES
****************************************************/

//Make sure that w_class is set as if the parent mob was medium sized! This is because w_class is adjusted automatically for mob_size in New()

/obj/item/organ/external/chest
	name = "upper body"
	organ_tag = BP_CHEST
	icon_name = "torso"
	max_damage = 100
	min_broken_damage = 35
	w_class = ITEM_SIZE_HUGE //Used for dismembering thresholds, in addition to storage. Humans are w_class 6, so it makes sense that chest is w_class 5.
	cavity_max_w_class = ITEM_SIZE_NORMAL
	body_part = UPPER_TORSO
	vital = 1
	amputation_point = "spine"
	joint = "neck"
	dislocated = -1
	parent_organ = null
	encased = "ribcage"
	artery_name = "aorta"
	cavity_name = "thoracic"
	limb_flags = ORGAN_FLAG_GENDERED_ICON | ORGAN_FLAG_HEALS_OVERKILL | ORGAN_FLAG_CAN_BREAK
	can_be_printed = FALSE
	// Breasts' source art was hand-aligned to sit correctly on HUMAN's own torso silhouette. Species with a
	// differently-proportioned torso tile (e.g. GAS/Nabber's 32x40 canvas vs the standard 32x32) need this
	// shifted to actually land on their own silhouette -- see the species-specific chest subclasses below.
	// Keyed by facing direction (SOUTH/NORTH/EAST/WEST), each a list(x, y) -- see get_icon_shifted_per_dir()
	// (_external_icons.dm) for why a single flat offset isn't enough.
	var/list/mutant_organ_pixel_offset = alist(
		SOUTH = list(0, 0),
		NORTH = list(0, 0),
		EAST = list(0, 0),
		WEST = list(0, 0)
	)

/obj/item/organ/external/chest/proc/get_current_skin()
	return

// Chest's own version of head.dm's get_hair_icon() mutant-organ compositing loop -- chest never had one of these
// before Breasts (Wings/Fluff, the only other BP_CHEST-parented mutant organs, render via their own dedicated
// mob-level overlay layer instead, since their source art is oversized for a normal 32x32 limb tile -- see
// update_wings_showing()/update_fluff_showing() in update_icons.dm). Breasts' art is standard 32x32, so it goes
// through a real per-organ compositing loop instead, same approach as horns/frills/spines/ears on the head.
/obj/item/organ/external/chest/get_icon_key()
	. = ..()
	. += get_mutant_organs_icon_key()

// Returns list(front, behind): `front` (real content for SOUTH/EAST/WEST) goes into the normal mob_overlays stack
// same as before; `behind` (real content only when facing NORTH, rendered at BODYPARTS_LOW_LAYER -- see
// get_icon_masked_to_dirs()/_external_icons.dm) sits behind the whole body. Breasts are the only thing this proc
// ever actually renders (Wings/Fluff/Tail, the other BP_CHEST-parented mutant organs, all render through their own
// dedicated mob-level overlay layers instead -- see update_wings_showing()/update_fluff_showing()/get_tail_icon()
// in update_icons.dm) -- explicit user direction: breasts stay visible in profile (EAST/WEST), only tucking behind
// the silhouette when the character's back is fully turned (NORTH). Groin's own version of this split (below)
// stays SOUTH-only, since Penis/Testicles/Vagina should NOT read as a distinct sprite in profile the way breasts do.
/obj/item/organ/external/chest/proc/get_chest_mutant_icon()
	var/list/sorted_chest_organs = list()
	for(var/obj/item/organ/internal/mutant/MO in internal_organs)
		if(!MO.sprite_datum)
			continue
		// Genitals (Breasts here) respect clothing/the genital-visibility verb -- Tail/Wings/Fluff/etc (also
		// chest/groin-parented mutant organs, is_genital left FALSE on all of them) are correctly unaffected.
		if(MO.is_genital && !owner.should_show_genitals(MO.organ_tag, UPPER_TORSO))
			continue
		ADD_SORTED(sorted_chest_organs, list(list(MO.sprite_datum.draw_order, MO)), GLOBAL_PROC_REF(cmp_marking_order))

	var/image/front = image(species.icon_template, "")
	var/image/behind = image(species.icon_template, "")
	for(var/entry in sorted_chest_organs)
		var/obj/item/organ/internal/mutant/MO = entry[2]
		var/datum/sprite_accessory/mutant/effective_datum = MO.get_effective_sprite_datum()
		var/organ_fallback_color = (MO.is_genital && species.default_genital_color) ? species.default_genital_color : owner.skin_color
		var/icon/organ_icon = effective_datum.build_colored_icon(MO.colors, organ_fallback_color, MO.get_effective_size(), MO.is_aroused)
		var/icon/shifted_icon = get_icon_shifted_per_dir(organ_icon, mutant_organ_pixel_offset)
		front.AddOverlays(get_icon_masked_to_dirs(shifted_icon, list(SOUTH, EAST, WEST)))
		behind.AddOverlays(get_icon_masked_to_dirs(shifted_icon, list(NORTH)))

	// Strictly lower than BODYPARTS_LOW_LAYER so this never ties with (and loses to, by list order) legs' own
	// East/West BODYPARTS_LOW_LAYER split -- see MUTANT_ORGAN_BEHIND_LAYER's comment.
	behind.layer = MUTANT_ORGAN_BEHIND_LAYER
	return list(front, behind)

/obj/item/organ/external/chest/on_update_icon()
	..()
	// NOT AddOverlays() here -- that queues into atom_overlay_cache/SSoverlays (see controllers/subsystems/
	// overlays.dm), which is deferred to the next SSoverlays tick, not applied to src.overlays immediately. The
	// actual body-render pathway (update_body() in update_icons.dm) never looks at src.overlays at all -- it calls
	// get_overlays(), which returns `mob_overlays` (the plain instance var the base on_update_icon() above builds
	// up throughout this proc and only queues via AddOverlays as ITS OWN last step, before this override's code
	// even runs). Appending to mob_overlays directly is what get_overlays()/update_body() actually see, matching
	// how head.dm's own on_update_icon() override adds its extra eye/lip content straight into mob_overlays rather
	// than through AddOverlays. Confirmed via live testing: this is why the organ existing, sprite_datum
	// resolving, and get_chest_mutant_icon() itself returning a real icon still isn't sufficient to render.
	// `front` is NOT added here -- see HO_GENITAL_FRONT_LAYER (update_icons.dm) for why it has its own dedicated
	// overlay bucket instead of living in mob_overlays/HO_BODY_LAYER alongside `behind`.
	var/list/mutant_icons = get_chest_mutant_icon()
	mob_overlays += mutant_icons[2]

/obj/item/organ/external/chest/robotize()
	if(..())
		// Give them a new cell.
		var/obj/item/organ/internal/cell/C = owner.internal_organs_by_name[BP_CELL]
		if(!istype(C))
			owner.internal_organs_by_name[BP_CELL] = new /obj/item/organ/internal/cell(owner,1)

/obj/item/organ/external/get_scan_results()
	. = ..()
	var/obj/item/organ/internal/lungs/L = locate() in src
	if( L && L.is_bruised())
		. += "Lung ruptured"

/obj/item/organ/external/groin
	name = "lower body"
	organ_tag = BP_GROIN
	icon_name = "groin"
	max_damage = 100
	min_broken_damage = 35
	w_class = ITEM_SIZE_LARGE
	cavity_max_w_class = ITEM_SIZE_SMALL
	body_part = LOWER_TORSO
	parent_organ = BP_CHEST
	amputation_point = "lumbar"
	joint = "hip"
	dislocated = -1
	artery_name = "iliac artery"
	cavity_name = "abdominal"
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_GENDERED_ICON | ORGAN_FLAG_CAN_BREAK
	// See chest's mutant_organ_pixel_offset above -- same reasoning, for Penis/Testicles/Vagina's groin-parented art.
	var/list/mutant_organ_pixel_offset = alist(
		SOUTH = list(0, 0),
		NORTH = list(0, 0),
		EAST = list(0, 0),
		WEST = list(0, 0)
	)

// Groin's own version of get_chest_mutant_icon() (see the chest override above) -- Penis/Testicles/Vagina are all
// BP_GROIN-parented, same reasoning as Tail (which predates this loop and still renders via its own dedicated
// mob-overlay path instead -- not migrated here to avoid touching already-working, already-verified code).
/obj/item/organ/external/groin/get_icon_key()
	. = ..()
	. += get_mutant_organs_icon_key()

// See chest's get_chest_mutant_icon() above for the list(front, behind) split rationale.
/obj/item/organ/external/groin/proc/get_groin_mutant_icon()
	var/list/sorted_groin_organs = list()
	for(var/obj/item/organ/internal/mutant/MO in internal_organs)
		// Tail is also BP_GROIN-parented but already renders through its own dedicated mob-overlay path (see
		// get_tail_icon()/update_tail_showing() in update_icons.dm, which predates this loop) -- skip it here to
		// avoid drawing it a second time.
		if(istype(MO, /obj/item/organ/internal/mutant/tail))
			continue
		if(!MO.sprite_datum)
			continue
		// See get_chest_mutant_icon() above for the is_genital/should_show_genitals() reasoning.
		if(MO.is_genital && !owner.should_show_genitals(MO.organ_tag, LOWER_TORSO))
			continue
		ADD_SORTED(sorted_groin_organs, list(list(MO.sprite_datum.draw_order, MO)), GLOBAL_PROC_REF(cmp_marking_order))

	var/image/front = image(species.icon_template, "")
	var/image/behind = image(species.icon_template, "")
	for(var/entry in sorted_groin_organs)
		var/obj/item/organ/internal/mutant/MO = entry[2]
		var/datum/sprite_accessory/mutant/effective_datum = MO.get_effective_sprite_datum()
		var/organ_fallback_color = (MO.is_genital && species.default_genital_color) ? species.default_genital_color : owner.skin_color
		var/icon/organ_icon = effective_datum.build_colored_icon(MO.colors, organ_fallback_color, MO.get_effective_size(), MO.is_aroused)
		var/list/organ_pixel_offset = mutant_organ_pixel_offset
		// Male body types: Sheath/Slit (and species sheath aliases, e.g. Teshari's Cloaca -- anything
		// hidden_from_picker, matching how those are identified everywhere else) plus every vagina shape sit 1px
		// too high against the male groin silhouette -- nudge just those specific organs 1px south. Female/other
		// body types, and every other penis shape, are unaffected.
		if(owner.gender == MALE && (MO.organ_tag == BP_PUSSY || (MO.organ_tag == BP_PENIS && effective_datum.hidden_from_picker)))
			// alist(), NOT list() -- SOUTH/NORTH/EAST/WEST are numbers (2/1/4/8), so on a plain list these are
			// INDICES and assigning them on an empty one is an out-of-bounds runtime that kills this whole proc
			// mid-loop (nothing composites, nothing renders, no error surfaces to the player). mutant_organ_pixel_offset
			// itself is declared as an alist for exactly this reason; this rebuild has to match it.
			organ_pixel_offset = alist()
			for(var/d in list(SOUTH, NORTH, EAST, WEST))
				var/list/base = mutant_organ_pixel_offset[d]
				organ_pixel_offset[d] = list(base[1], base[2] - 1)
		var/icon/shifted_icon = get_icon_shifted_per_dir(organ_icon, organ_pixel_offset)
		front.AddOverlays(get_icon_masked_to_dirs(shifted_icon, list(SOUTH)))
		behind.AddOverlays(get_icon_masked_to_dirs(shifted_icon, list(NORTH, EAST, WEST)))

	// See chest's get_chest_mutant_icon() above for this.
	behind.layer = MUTANT_ORGAN_BEHIND_LAYER
	return list(front, behind)

/obj/item/organ/external/groin/on_update_icon()
	..()
	// See chest's on_update_icon() above for why mob_overlays, not AddOverlays() -- and for why `front` isn't
	// added here (HO_GENITAL_FRONT_LAYER, update_icons.dm).
	var/list/mutant_icons = get_groin_mutant_icon()
	mob_overlays += mutant_icons[2]

/obj/item/organ/external/arm
	organ_tag = BP_L_ARM
	name = "left arm"
	icon_name = "l_arm"
	max_damage = 50
	min_broken_damage = 30
	w_class = ITEM_SIZE_NORMAL
	body_part = ARM_LEFT
	parent_organ = BP_CHEST
	joint = "left elbow"
	amputation_point = "left shoulder"
	tendon_name = "palmaris longus tendon"
	artery_name = "basilic vein"
	arterial_bleed_severity = 0.75
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP | ORGAN_FLAG_HAS_TENDON | ORGAN_FLAG_CAN_BREAK

/obj/item/organ/external/arm/right
	organ_tag = BP_R_ARM
	name = "right arm"
	icon_name = "r_arm"
	body_part = ARM_RIGHT
	joint = "right elbow"
	amputation_point = "right shoulder"

/obj/item/organ/external/leg
	organ_tag = BP_L_LEG
	name = "left leg"
	icon_name = "l_leg"
	max_damage = 50
	min_broken_damage = 30
	w_class = ITEM_SIZE_NORMAL
	body_part = LEG_LEFT
	icon_position = LEFT
	parent_organ = BP_GROIN
	joint = "left knee"
	amputation_point = "left hip"
	tendon_name = "cruciate ligament"
	artery_name = "femoral artery"
	arterial_bleed_severity = 0.75
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND | ORGAN_FLAG_HAS_TENDON | ORGAN_FLAG_CAN_BREAK

/obj/item/organ/external/leg/get_digitigrade_icon_override()
	return get_digitigrade_icon_override_shared(src)

/obj/item/organ/external/leg/right
	organ_tag = BP_R_LEG
	name = "right leg"
	icon_name = "r_leg"
	body_part = LEG_RIGHT
	icon_position = RIGHT
	joint = "right knee"
	amputation_point = "right hip"

/obj/item/organ/external/foot
	organ_tag = BP_L_FOOT
	name = "left foot"
	icon_name = "l_foot"
	max_damage = 30
	min_broken_damage = 15
	w_class = ITEM_SIZE_SMALL
	body_part = FOOT_LEFT
	icon_position = LEFT
	parent_organ = BP_L_LEG
	joint = "left ankle"
	amputation_point = "left ankle"
	tendon_name = "Achilles tendon"
	arterial_bleed_severity = 0.5
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_STAND | ORGAN_FLAG_HAS_TENDON | ORGAN_FLAG_CAN_BREAK

/obj/item/organ/external/foot/get_digitigrade_icon_override()
	return get_digitigrade_icon_override_shared(src)

/obj/item/organ/external/foot/right
	organ_tag = BP_R_FOOT
	name = "right foot"
	icon_name = "r_foot"
	body_part = FOOT_RIGHT
	icon_position = RIGHT
	parent_organ = BP_R_LEG
	joint = "right ankle"
	amputation_point = "right ankle"

/obj/item/organ/external/hand
	organ_tag = BP_L_HAND
	name = "left hand"
	icon_name = "l_hand"
	max_damage = 30
	min_broken_damage = 15
	w_class = ITEM_SIZE_SMALL
	body_part = HAND_LEFT
	parent_organ = BP_L_ARM
	joint = "left wrist"
	amputation_point = "left wrist"
	tendon_name = "carpal ligament"
	arterial_bleed_severity = 0.5
	limb_flags = ORGAN_FLAG_CAN_AMPUTATE | ORGAN_FLAG_CAN_GRASP | ORGAN_FLAG_FINGERPRINT | ORGAN_FLAG_HAS_TENDON | ORGAN_FLAG_CAN_BREAK

/obj/item/organ/external/hand/right
	organ_tag = BP_R_HAND
	name = "right hand"
	icon_name = "r_hand"
	body_part = HAND_RIGHT
	parent_organ = BP_R_ARM
	joint = "right wrist"
	amputation_point = "right wrist"
