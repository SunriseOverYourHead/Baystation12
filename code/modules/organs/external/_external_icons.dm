var/global/list/limb_icon_cache = list()


/// Layer for bodyparts that should appear behind every other bodypart - Mostly, legs when facing WEST or EAST
#define BODYPARTS_LOW_LAYER -2

// Genital/breast "behind" overlays (standard.dm) need to draw behind arms/legs specifically when they're using
// THEIR OWN BODYPARTS_LOW_LAYER split for East/West (icon_position LEFT/RIGHT limbs, a few lines below) -- sharing
// the exact same layer value ties, and the tie is broken by list/insertion order, which favours the genital
// overlay (BP_GROIN is deliberately declared after the legs in has_limbs, so it draws in FRONT of them at the
// normal layer -- see species.dm's has_limbs comment). A strictly lower layer avoids the tie entirely.
#define MUTANT_ORGAN_BEHIND_LAYER (BODYPARTS_LOW_LAYER - 1)

// NOTE: there used to be a MUTANT_ORGAN_FRONT_LAYER here, the SOUTH-facing counterpart of MUTANT_ORGAN_BEHIND_LAYER
// above, meant to make `front` (standard.dm) sit in front of the whole body via a high .layer value. Two attempts
// (a small positive number, then FLOAT_LAYER + 1) both live-confirmed to change nothing. Low/negative layers in
// this small range (BODYPARTS_LOW_LAYER/MUTANT_ORGAN_BEHIND_LAYER above) demonstrably DO still work -- legs
// correctly duck behind the body via the exact same mechanism -- so this isn't "layer is ignored entirely"; going
// higher specifically never worked, plausibly because FLOAT_LAYER's territory interacts with BYOND's plane
// compositing differently rather than just sorting further up the same stack. Rather than chase that down further,
// `front` now gets its own overlays_standing bucket entirely instead -- see HO_GENITAL_FRONT_LAYER (update_icons.dm),
// the same fix Wings/Fluff already used for the same "must render above everything, .layer wasn't cutting it" need.

// Builds a copy of `source` with real content ONLY for the directions in `dirs_to_keep` -- every other direction
// is left as the "blank" icon_state's (fully transparent) content. Mirrors the existing LEFT/RIGHT limb-layering
// technique a few lines below (on_update_icon()'s under_icon/BODYPARTS_LOW_LAYER split for icon_position LEFT/
// RIGHT/UNDER limbs) generalized into a reusable helper -- used by chest/groin's mutant-organ compositing
// (standard.dm) so genital/breast overlays render in FRONT of the body only when facing SOUTH, and BEHIND it
// (BODYPARTS_LOW_LAYER) for every other direction, since the body's own silhouette would otherwise obstruct them.
/proc/get_icon_masked_to_dirs(icon/source, list/dirs_to_keep)
	var/icon/result = new('icons/mob/human.dmi', "blank")
	// Explicitly insert a blank frame at EVERY direction first, before inserting real content at only the wanted
	// ones -- forces the icon to genuinely store 4 independent directions (3 of them blank) rather than leaving
	// an unset direction as an ambiguous "never touched" state that some rendering paths could fall back to
	// showing the same single stored frame for regardless of the mob's actual current facing.
	var/icon/blank_frame = new(result)
	for(var/d in list(SOUTH, NORTH, EAST, WEST))
		result.Insert(blank_frame, dir = d)
	for(var/d in dirs_to_keep)
		result.Insert(new/icon(source, dir = d), dir = d)
	return result

// Applies a PER-DIRECTION pixel shift to a copy of `source` -- `pixel_offset_by_dir` is a list keyed by SOUTH/
// NORTH/EAST/WEST, each value a 2-element list(x, y). A single flat pixel_x/pixel_y applied uniformly (the
// original approach) turned out to be insufficient once real species were hand-checked in icons/mob/
// reference_parts.dmi -- East/West often need a substantial, genuinely different X correction (not just a
// mirror-image of one another), since the mob's East/West art is itself an independently-drawn (or independently
// mirrored) pair of frames, and a single shift can only ever be correct for one of the two. Each direction's own
// frame is extracted, shifted independently via icon.Shift(), and reinserted -- same extract/Insert idiom as
// get_icon_masked_to_dirs() above.
// NOTE: an earlier version of this proc padded the icon's canvas first (via Crop()+Shift()) to give large shifts
// room to move without clipping against the source's native 32x32 bounds. That was reverted -- growing a mutant-
// organ overlay's own nominal icon size, even with a compensating pixel_x/pixel_y, inflates whatever bounding box
// getFlatIcon() computes for the character-setup preview (update_preview_icon(), 05_preview.dm, blends that result
// at a hardcoded (9,9) assuming a fixed ~32px size), breaking the preview for every species, not just the one
// needing a large shift. A shift bigger than a direction's own native margin (e.g. Gyne's East, see
// baystation12soyh_genitals_port_plan memory) will clip some content rather than risk that regression again.
/proc/get_icon_shifted_per_dir(icon/source, list/pixel_offset_by_dir)
	var/icon/result = new(source)
	for(var/d in list(SOUTH, NORTH, EAST, WEST))
		var/list/offset = pixel_offset_by_dir[d]
		if(!offset || (offset[1] == 0 && offset[2] == 0))
			continue
		var/icon/frame = new/icon(result, dir = d)
		if(offset[1] > 0)
			frame.Shift(EAST, offset[1])
		else if(offset[1] < 0)
			frame.Shift(WEST, -offset[1])
		if(offset[2] > 0)
			frame.Shift(NORTH, offset[2])
		else if(offset[2] < 0)
			frame.Shift(SOUTH, -offset[2])
		result.Insert(frame, dir = d)
	return result

/obj/item/organ/external/set_dir()
	return

/obj/item/organ/external/proc/compile_icon()
	ClearOverlays()
	update_icon()

/obj/item/organ/external/proc/sync_colour_to_human(mob/living/carbon/human/human)
	skin_tone = null
	s_col = null
	base_skin = ""
	h_col = rgb2num(human.head_hair_color)
	if(BP_IS_ROBOTIC(src) && !(human.species.appearance_flags & SPECIES_APPEARANCE_HAS_BASE_SKIN_COLOURS))
		var/datum/robolimb/franchise = all_robolimbs[model]
		if(!(franchise && franchise.skintone))
			return
	if(species && human.species && species.name != human.species.name)
		return
	if(!isnull(human.skin_tone) && (human.species.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE))
		skin_tone = human.skin_tone
	if(!isnull(human.base_skin) && (human.species.appearance_flags & SPECIES_APPEARANCE_HAS_BASE_SKIN_COLOURS))
		base_skin = human.base_skin
	if(human.species.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR)
		s_col = rgb2num(human.skin_color)

/obj/item/organ/external/proc/sync_colour_to_dna()
	skin_tone = null
	s_col = null
	base_skin = dna.base_skin
	h_col = list(dna.GetUIValue(DNA_UI_HAIR_R),dna.GetUIValue(DNA_UI_HAIR_G),dna.GetUIValue(DNA_UI_HAIR_B))
	if(BP_IS_ROBOTIC(src))
		var/datum/robolimb/franchise = all_robolimbs[model]
		if(!(franchise && franchise.skintone))
			return
	if(!isnull(dna.GetUIValue(DNA_UI_SKIN_TONE)) && (species.appearance_flags & SPECIES_APPEARANCE_HAS_A_SKIN_TONE))
		skin_tone = dna.GetUIValue(DNA_UI_SKIN_TONE)
	if(species.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR)
		s_col = list(dna.GetUIValue(DNA_UI_SKIN_R), dna.GetUIValue(DNA_UI_SKIN_G), dna.GetUIValue(DNA_UI_SKIN_B))

/obj/item/organ/external/head/sync_colour_to_human(mob/living/carbon/human/human)
	..()
	// Skrell headtails are skin, not hair -- there's no independent headtail color, it's just skin_color
	// rendered through the hair slot (explicit user decision).
	if(istype(human.species, /singleton/species/skrell))
		h_col = s_col
	var/obj/item/organ/internal/eyes/eyes = owner.internal_organs_by_name[BP_EYES]
	if(eyes) eyes.update_colour()

/obj/item/organ/external/head/sync_colour_to_dna()
	..()
	if(istype(species, /singleton/species/skrell))
		h_col = s_col

/obj/item/organ/external/head/removed()
	update_icon(1)
	if(owner)
		SetName("[owner.real_name]'s head")
		addtimer(new Callback(owner, TYPE_PROC_REF(/mob/living/carbon/human, update_hair)), 1, TIMER_UNIQUE)
	..()

// Which mutant_cover_pattern.dmi theme (if any) this limb should be painted with -- default is body-parented
// (suit-covered); overridden on /obj/item/organ/external/head to be helmet-covered instead, matching the same
// suit-vs-helmet split get_worn_cover_theme()/get_worn_head_cover_theme() (update_icons.dm) already established
// for tail/wings/fluff vs horns/ears/etc -- a suit never covers the head and a helmet never covers the body,
// independently of whether the other piece is worn.
//
// Gated on the worn item's own body_parts_covered actually including THIS limb, so a suit that legitimately
// leaves a limb bare doesn't pattern it. Note there's deliberately no pixel-level "is this specific part of the
// limb sticking out" test: the body renders at HO_BODY_LAYER (1) and the suit at HO_SUIT_LAYER (12), i.e. the
// suit's own art already draws OVER the limb, so painting the whole limb and letting z-order occlude it gives
// exactly the right result for free -- covered pixels are hidden behind the suit sprite, and only genuine gaps in
// the suit's own coverage art (eg GAS/Nabber's missing boot region, where the species leg-remap reference art was
// never painted below y=6) actually show through. An earlier version of this tried to compute the exposed region
// itself by diffing the two icons with ICON_AND/ICON_SUBTRACT; it was live-tested repeatedly and never worked,
// and it was solving a problem the layer order had already solved.
/obj/item/organ/external/proc/get_cover_theme()
	if(!owner || !istype(owner.wear_suit, /obj/item/clothing/suit/space))
		return null
	var/obj/item/clothing/suit/space/S = owner.wear_suit
	if(!HAS_FLAGS(S.body_parts_covered, body_part))
		return null
	return S.get_cover_theme()

/obj/item/organ/external/proc/get_icon_key()
	RETURN_TYPE(/list)
	. = list()

	var/gender = "_m"
	if(!(limb_flags & ORGAN_FLAG_GENDERED_ICON))
		gender = null
	else if (dna && dna.GetUIState(DNA_UI_GENDER))
		gender = "_f"
	else if(owner && (owner.gender == FEMALE || (owner.gender == PLURAL && owner.trans_body_type == FEMALE)))
		gender = "_f"

	. += "[gender]-"
	. += "[organ_tag]-"
	. += "[species.get_race_key(owner)]"

	if(species.base_skin_colours && !isnull(species.base_skin_colours[base_skin]))
		. += "-[species.base_skin_colours[base_skin]]"

	if(force_icon)
		. += "[force_icon]"
	else if (BP_IS_ROBOTIC(src))
		. += "robot"
	else if (status & ORGAN_MUTATED)
		. += "deformed"
	else if (owner && (MUTATION_SKELETON in owner.mutations))
		. += "skeleton"
	else if (owner && (MUTATION_HUSK in owner.mutations))
		. += "husk"
	else if (get_digitigrade_icon_override())
		. += "digitigrade"

	//Colour, maybe simplify this one day and actually calculate it once
	if(status & ORGAN_DEAD)
		. += "_dead"

	if(skin_tone)
		. += "_tone_[skin_tone]"

	if(species.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR)
		if(s_col && length(s_col) >= 3)
			. += "_color_[s_col[1]]_[s_col[2]]_[s_col[3]]_[s_col_blend]"

	for(var/E in markings)
		var/datum/sprite_accessory/marking/M = E
		if (M.draw_target == MARKING_TARGET_SKIN)
			var/list/mark_data = markings[E]
			. += "-[M.name][mark_data[1]][mark_data[2]]"

	if(body_hair && islist(h_col) && length(h_col) >= 3)
		. += "[body_hair]-[icon_name]-[h_col[1]][h_col[2]][h_col[3]]"

	if(model)
		. += "_model_[model]"

	if(is_stump())
		. += "-stump"

	// Suit/helmet cover-pattern theme -- see get_cover_theme()'s header comment. Needs to be part of this key or
	// update_body()'s cache-skip-if-unchanged check (update_icons.dm) won't know to rebuild when a themed
	// suit/helmet goes on or off.
	. += "-cover_[get_cover_theme()]"

	return .

// Real bug, found via live user testing: update_body() (update_icons.dm) only redraws a limb whose get_icon_key()
// changed since last time -- otherwise it silently reuses GLOB.limb_overlays_cache's stale entry (a real
// optimization for ordinary gameplay, e.g. taking damage doesn't need to re-check unrelated limbs). The base
// get_icon_key() above has no idea mutant organs (Breasts/Penis/Testicles/Vagina, chest/groin's own
// get_chest_mutant_icon()/get_groin_mutant_icon() loops) exist at all, so toggling one on, changing its shape, or
// changing its size/color never changes the key -- the character (and the char-creation preview mannequin
// specifically, since it's a single long-lived mob reused across every preference tweak in a session, unlike a
// fresh spawn whose icon_render_keys starts empty) just keeps showing whatever the chest/groin looked like the
// last time its key actually changed (e.g. a species switch), even though get_chest_mutant_icon() itself computes
// the right icon correctly if called directly. Chest/groin's get_icon_key() overrides call this to fold that
// state into the key so a genital pick actually invalidates the cache.
/obj/item/organ/external/proc/get_mutant_organs_icon_key()
	. = list()
	for(var/obj/item/organ/internal/mutant/MO in internal_organs)
		// is_aroused is included so toggling it (sexcon.dm's update_genital_arousal_visuals(), preview's
		// apply_preview_arousal()) actually changes the computed key -- otherwise update_body() (update_icons.dm)
		// sees no change and keeps serving whatever was cached before, the exact same stale-icon-key bug the
		// original genitals port hit (see baystation12soyh_genitals_port_plan memory) for shape/color/size, just
		// for a var that didn't exist yet when that fix was written.
		. += "[MO.organ_tag]:[MO.sprite_datum ? MO.sprite_datum.type : "none"]:[MO.colors?.Join(",")]:[MO.size]:[MO.is_aroused]"
		if(MO.is_genital)
			// should_show_genitals()'s result depends on live clothing/underwear state -- but clothing itself is a
			// SEPARATE overlay layer, not baked into a limb's own get_icon_key() at all (confirmed: the base key
			// only covers gender/species/skin tone/markings/damage/stump state), so simply taking off pants does
			// NOT on its own invalidate this limb's cached key. Same stale-cache trap as is_aroused above, just for
			// clothing instead of arousal -- folding both torso zones' raw exposure in unconditionally (cheaper
			// and simpler than figuring out which one this specific organ's slot actually cares about) plus THIS
			// organ's own per-tag visibility setting (genital_visibility is now per-organ-tag, not one mob-wide
			// value), so a clothing change OR a toggle_genitals() call on any one genital both correctly bust the
			// cache regardless of which genital organ or render loop is involved.
			. += ":[owner.get_genital_visibility(MO.organ_tag)]:[owner.get_zone_exposed(UPPER_TORSO)]:[owner.get_zone_exposed(LOWER_TORSO)]"

/obj/item/organ/external/on_update_icon(regenerate = 0)
	ClearOverlays()
	mob_overlays = list()

	var/husk_color_mod = rgb(96,88,80)
	var/husk = owner && (MUTATION_HUSK in owner.mutations)

	var/gender = "_m"
	if(!(limb_flags & ORGAN_FLAG_GENDERED_ICON))
		gender = null
	else if (dna && dna.GetUIState(DNA_UI_GENDER))
		gender = "_f"
	else if(owner && (owner.gender == FEMALE || (owner.gender == PLURAL && owner.trans_body_type == FEMALE)))
		gender = "_f"


	var/chosen_icon = ""
	var/chosen_icon_state = ""

	chosen_icon_state = "[icon_name][gender]"
	if(species.base_skin_colours && !isnull(species.base_skin_colours[base_skin]))
		chosen_icon_state += species.base_skin_colours[base_skin]

	if(force_icon)
		chosen_icon = force_icon
	else if (BP_IS_ROBOTIC(src))
		chosen_icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	else if (!dna)
		chosen_icon = 'icons/mob/human_races/species/human/body.dmi'
	else if (status & ORGAN_MUTATED)
		chosen_icon = species.deform
	else if (owner && (MUTATION_SKELETON in owner.mutations))
		chosen_icon = 'icons/mob/human_races/species/human/skeleton.dmi'
	else
		chosen_icon = get_digitigrade_icon_override() || species.get_icobase(owner)

	var/icon/mob_icon = apply_colouration(new/icon(chosen_icon, chosen_icon_state))

	if (husk)
		mob_icon.ColorTone(husk_color_mod)

	//Handle husk overlay.
	if(husk)
		var/husk_icon = species.get_husk_icon(src)
		if(husk_icon)
			var/icon/mask = new/icon(chosen_icon)
			var/blood = species.get_blood_colour(owner)
			var/icon/husk_over = new(species.husk_icon,"")
			mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
			husk_over.Blend(mask, ICON_ADD)
			husk_over.Blend(blood, ICON_MULTIPLY)
			mob_icon.Blend(husk_over, ICON_OVERLAY)

	var/list/sorted = list()
	for(var/datum/sprite_accessory/marking/marking as anything in markings)
		if (marking.draw_target == MARKING_TARGET_SKIN)
			var/list/mark_data = markings[marking]
			var/color = mark_data[1]
			var/state = marking.icon_state
			if (marking.use_organ_tag)
				state = "[state]-[organ_tag]"
			var/icon/icon = icon(marking.icon, state)
			icon.Blend(color, marking.blend)
			var/list/entry = list(list(marking.draw_order, icon, marking))
			ADD_SORTED(sorted, entry, GLOBAL_PROC_REF(cmp_marking_order))
			if(mark_data[2])
				mob_overlays += emissive_appearance(marking.icon, state, FLOAT_LAYER)

	for (var/entry in sorted) //Revisit this with blendmodes
		var/datum/sprite_accessory/marking/marking = entry[3]
		mob_icon.Blend(entry[2], marking.layer_blend)

	if(body_hair && islist(h_col) && length(h_col) >= 3)
		var/cache_key = "[body_hair]-[icon_name]-[h_col[1]][h_col[2]][h_col[3]]"
		if(!limb_icon_cache[cache_key])
			var/icon/I = icon(species.get_icobase(owner), "[icon_name]_[body_hair]")
			I.Blend(rgb(h_col[1],h_col[2],h_col[3]), ICON_ADD)
		mob_icon.Blend(limb_icon_cache[cache_key], ICON_OVERLAY)

	// Applied before the LEFT/RIGHT split below so both split halves inherit the pattern. See get_cover_theme()'s
	// header for the suit-vs-helmet split and for why this paints the whole limb instead of diffing.
	var/organ_cover_theme = get_cover_theme()
	if(organ_cover_theme)
		apply_mutant_cover_pattern(mob_icon, organ_cover_theme)

	//Fix leg layering here
	//Alternatively you could use masks but it's about same amount of work
	//Note: This really only works because everything up until now was icon ops to build an icon we can work with
	// If we ever move to pure overlays for body hair / modifiers / cosmetic changes to a limb, look up daedalusdock's implementation
	if(icon_position & (LEFT | RIGHT))
		var/icon/under_icon = new('icons/mob/human.dmi',"blank")
		under_icon.Insert(new/icon(mob_icon,dir=NORTH),dir=NORTH)
		under_icon.Insert(new/icon(mob_icon,dir=SOUTH),dir=SOUTH)
		if(!(icon_position & LEFT))
			under_icon.Insert(new/icon(mob_icon,dir=EAST),dir=EAST)
		if(!(icon_position & RIGHT))
			under_icon.Insert(new/icon(mob_icon,dir=WEST),dir=WEST)
		//At this point, the icon has all the valid states for both left and right leg overlays
		var/mutable_appearance/upper_appearance = mutable_appearance(under_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS)
		upper_appearance.layer = FLOAT_LAYER
		mob_overlays += upper_appearance

		if(icon_position & LEFT)
			under_icon.Insert(new/icon(mob_icon,dir=EAST),dir=EAST)
		if(icon_position & RIGHT)
			under_icon.Insert(new/icon(mob_icon,dir=WEST),dir=WEST)

		var/mutable_appearance/under_appearance = mutable_appearance(under_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS)
		upper_appearance.layer = BODYPARTS_LOW_LAYER
		mob_overlays += under_appearance
	else
		var/mutable_appearance/limb_appearance = mutable_appearance(mob_icon, chosen_icon_state, flags = DEFAULT_APPEARANCE_FLAGS)
		if(icon_position & UNDER)
			limb_appearance.layer = BODYPARTS_LOW_LAYER
		mob_overlays += limb_appearance

	if(blocks_emissive)
		var/mutable_appearance/limb_em_block = emissive_blocker(chosen_icon, chosen_icon_state, FLOAT_LAYER)
		limb_em_block.dir = dir
		mob_overlays += limb_em_block

	AddOverlays(mob_overlays)

	dir = EAST
	icon = null

/obj/item/organ/external/proc/get_overlays()
	update_icon()
	return mob_overlays

// Returns an image for use by the human health dolly HUD element.
// If the limb is in pain, it will be used as a minimum damage
// amount to represent the obfuscation of being in agonizing pain.

// Global scope, used in code below.
var/global/list/flesh_hud_colours = list("#00ff00","#aaff00","#ffff00","#ffaa00","#ff0000","#aa0000","#660000")
var/global/list/robot_hud_colours = list("#ffffff","#cccccc","#aaaaaa","#888888","#666666","#444444","#222222","#000000")

/obj/item/organ/external/proc/get_damage_hud_image()

	// Generate the greyscale base icon and cache it for later.
	// icon_cache_key is set by any get_icon() calls that are made.
	// This looks convoluted, but it's this way to avoid icon proc calls.
	if(!hud_damage_image)
		var/cache_key = "dambase-[json_encode(get_icon_key())]"
		if(!cache_key || !limb_icon_cache[cache_key])
			var/list/appearances = get_overlays()
			for(var/image/I as anything in appearances) //Mutable appearances are a type of image
				I.dir = SOUTH
				I.icon_state = null
				if(species)
				// Calculate the required colour matrix.
					var/r = 0.30 * species.health_hud_intensity
					var/g = 0.59 * species.health_hud_intensity
					var/b = 0.11 * species.health_hud_intensity
					I.color = list(r, r, r, g, g, g, b, b, b)
				I.pixel_x = owner.default_pixel_x
				I.pixel_y = owner.default_pixel_y
			limb_icon_cache[cache_key] = appearances
		var/list/appearances = limb_icon_cache[cache_key]
		hud_damage_image = image(null)
		hud_damage_image.AddOverlays(appearances)

	// Calculate the required color index.
	var/dam_state = min(1,((brute_dam+burn_dam)/max(1,max_damage)))
	var/min_dam_state = min(1,(get_pain()/max(1,max_damage)))
	if(min_dam_state && dam_state < min_dam_state)
		dam_state = min_dam_state
	// Apply colour and return product.
	var/list/hud_colours = !BP_IS_ROBOTIC(src) ? flesh_hud_colours : robot_hud_colours
	hud_damage_image.color = hud_colours[max(1,min(ceil(dam_state*length(hud_colours)),length(hud_colours)))]
	return hud_damage_image

// Overridden on leg/foot only (see standard.dm) -- returns an icon file to use instead of the species' normal
// icobase when this organ should currently render as digitigrade, or null otherwise (wrong species, or player
// chose plantigrade). Digitigrade legs always render regardless of what's worn -- clothing covering them gets
// its own sprite pixel-remapped at render time instead (code/modules/clothing/_leg_shape_remap.dm) rather than
// squashing the leg back to plantigrade, which used to be this codebase's stopgap for lacking digitigrade art.
/obj/item/organ/external/proc/get_digitigrade_icon_override()
	return null

// Shared by leg/foot's own override (see standard.dm) -- kept as a standalone proc rather than duplicated on both
// so the actual condition only needs to be right in one place.
/proc/get_digitigrade_icon_override_shared(obj/item/organ/external/O)
	if(!O.owner || !ishuman(O.owner))
		return null
	var/mob/living/carbon/human/H = O.owner
	if(!O.species || !(O.species.appearance_flags & SPECIES_APPEARANCE_HAS_LEG_TYPE))
		return null
	if(H.leg_type != LEG_TYPE_DIGITIGRADE)
		return null
	return 'icons/mob/species/anthro/legs_digitigrade.dmi'

/obj/item/organ/external/proc/apply_colouration(icon/applying)

	if(species.limbs_are_nonsolid)
		applying.MapColors("#4d4d4d","#969696","#1c1c1c", "#000000")
		if(species && species.get_bodytype(owner) != SPECIES_HUMAN)
			applying.SetIntensity(1.5)
		else
			applying.SetIntensity(0.7)
		applying += rgb(,,,180) // Makes the icon translucent, SO INTUITIVE TY BYOND

	else if(status & ORGAN_DEAD)
		applying.ColorTone(rgb(10,50,0))
		applying.SetIntensity(0.7)

	if(skin_tone)
		if(skin_tone >= 0)
			applying.Blend(rgb(skin_tone, skin_tone, skin_tone), ICON_ADD)
		else
			applying.Blend(rgb(-skin_tone,  -skin_tone,  -skin_tone), ICON_SUBTRACT)
	if(species.appearance_flags & SPECIES_APPEARANCE_HAS_SKIN_COLOR)
		if(s_col && length(s_col) >= 3)
			applying.Blend(rgb(s_col[1], s_col[2], s_col[3]), s_col_blend)

	return applying

/obj/item/organ/external/proc/bandage_level()
	if(damage_state_text() == "00")
		return 0
	if(!is_bandaged())
		return 0
	if(burn_dam + brute_dam == 0)
		. = 0
	else if (burn_dam + brute_dam < (max_damage * 0.25 / 2))
		. = 1
	else if (burn_dam + brute_dam < (max_damage * 0.75 / 2))
		. = 2
	else
		. = 3
