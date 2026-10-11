#define MUTANT_COVER_DMI 'icons/effects/mutant_cover_pattern.dmi'

// Lays a department-colored weave over an already-built organ/limb icon, so anything that would otherwise stick
// out of a sealed space-proof suit/helmet (an external mutant organ -- tail/wings/fluff/horns/ears/spines/frills/
// snout/xenodorsal/xenohead -- or a plain limb whose species silhouette the suit's own art doesn't cover) instead
// reads as "covered by the suit."
//
// Ported from NovaSector/Bubberstation's MODsuit "hardlight" mask, compositing included: a white-flattened copy of
// the target (Blend-to-white preserves the alpha silhouette, so the weave is shaped exactly like whatever it's
// covering) gets the mask multiplied into it, and the RESULT is overlaid back on top of the untouched target,
// rather than multiplied into it directly. That indirection matters -- the ported art is deliberately
// semi-transparent (alpha 0/143/196), so multiplying it straight into the target would punch that translucency
// into the limb itself and you'd see the floor through it; overlaying instead leaves the body solid underneath and
// lets it read through the weave, which is the intended look.
//
// Since icon.Blend() applies across every frame/dir of a multi-state icon automatically, this needs no special
// handling for animated states (e.g. a wagging tail's "_idle0" state) -- whichever state is currently selected
// just gets covered the same way as any other.
/proc/apply_mutant_cover_pattern(icon/target, theme)
	var/icon/weave = icon(target)
	weave.Blend("#ffffff", ICON_ADD)
	weave.Blend(icon(MUTANT_COVER_DMI, theme), ICON_MULTIPLY)
	target.Blend(weave, ICON_OVERLAY)

/datum/sprite_accessory/mutant
	var/organ_tag
	var/icon_animation
	var/hair_state
	var/mutant_blend = ICON_ADD
	var/draw_order = 50 // lower draws first (further back); only matters for head-stacked categories
	// TRUE for styles that exist to be looked up by name for a dedicated override preference (e.g. Penis's
	// Sheath/Slit, driven by "P. Sheath" rather than the normal shape dropdown) rather than picked directly --
	// filtered out of get_mutant_styles() (species.dm), which both the dropdown display AND the normal shape
	// preference's validation read, so it can't be selected through the ordinary shape picker at all.
	var/hidden_from_picker = FALSE
	// How many independently-colorable regions this specific STYLE has art for (1-3), mirroring Bubberstation's
	// primary/secondary/tertiary system -- most styles are 1 (single flat sprite, region 1 uses the plain
	// "[icon_state]_s" file every style already has). A style with real secondary/tertiary art additionally needs
	// "[icon_state]_s_secondary"/"[icon_state]_s_tertiary" states baked into the same icon file and sets this to
	// 2 or 3 -- the suffix is appended AFTER "_s", not before (this comment used to say "_secondary_s", which
	// doesn't match what build_colored_icon_for_state() below actually computes -- that mismatch alone caused a
	// real, session-wide silent rendering bug across Snout/Ears/Wings/Frills, since every content-generation
	// script trusted this comment instead of deriving the string from the code; see get_hair_icon()/
	// get_chest_mutant_icon()-equivalent render loops, which composite one tinted sub-image per region and layer
	// them. Deliberately a per-LEAF-class var (not auto-detected from the DMI like Bubberstation does at runtime)
	// since BS12SOYH's extraction pipeline already knows this at build time.
	var/color_regions = 1

// Builds one flat icon with every color region this style actually has baked in and blended with its own color,
// mirroring Bubberstation's "one pre-drawn cutout per region, each independently tinted, all composited together"
// approach (see get_images()/color_images() in modular_zubbers' mutant_bodypart_overlay.dm) -- BS12SOYH flattens
// this to a single icon.Blend()-per-region + ICON_OVERLAY composite rather than keeping N separate overlay images,
// since every category here already flattens FRONT/ADJ/BEHIND source layers into one baked "[state]_s" file at
// extraction time (this session's established convention), so there's no separate-layers infrastructure to hook
// multiple images into in the first place. Region 1 always reads the plain "[icon_state]_s" file every style
// already has (zero re-extraction needed for single-region content); only styles explicitly re-extracted with
// color_regions >= 2 need "[icon_state]_secondary_s"/"_tertiary_s" states baked into the same icon file too.
// `size` is only passed by categories whose art has separate baked states per size (Breasts/Penis/Testicles as of
// this writing) -- appends the size number directly after icon_state, e.g. icon_state "human" + size 4 reads
// "human4_s". Null/unset (the default for every other category) behaves exactly as before this param existed.
// `cover_theme`, when non-null, applies apply_mutant_cover_pattern() as a final step -- see that
// proc's header for what it does and why. Passed through untouched to build_colored_icon_for_state().
/datum/sprite_accessory/mutant/proc/build_colored_icon(list/colors, fallback_color, size, aroused = FALSE, cover_theme)
	var/base_state = "[icon_state][size ? "[size]" : ""][aroused ? "_a" : ""]_s"
	return build_colored_icon_for_state(base_state, colors, fallback_color, cover_theme = cover_theme)

// Same as build_colored_icon(), but for a caller-supplied base state name and (optionally) a different icon file
// than this datum's own `icon` var -- Tail is the one category with both a different naming convention (animated
// "_static"/"_idle0" states rather than a single static "_s" one) AND a different icon var (`icon_animation`, not
// `icon`), so it calls this directly with its own base state names and file; every other category goes through
// build_colored_icon()'s thin wrapper. Region 2/3 states are always "[base_state]_secondary"/"_tertiary".
/datum/sprite_accessory/mutant/proc/build_colored_icon_for_state(base_state, list/colors, fallback_color, icon_file, cover_theme)
	if(!icon_file)
		icon_file = icon
	var/icon/result = icon(icon_file, base_state)
	result.Blend(colors?[1] || fallback_color, mutant_blend)
	if(color_regions >= 2)
		var/icon/region2 = icon(icon_file, "[base_state]_secondary")
		region2.Blend(colors?[2] || fallback_color, mutant_blend)
		result.Blend(region2, ICON_OVERLAY)
	if(color_regions >= 3)
		var/icon/region3 = icon(icon_file, "[base_state]_tertiary")
		region3.Blend(colors?[3] || fallback_color, mutant_blend)
		result.Blend(region3, ICON_OVERLAY)
	if(cover_theme)
		apply_mutant_cover_pattern(result, cover_theme)
	return result

/datum/sprite_accessory/mutant/horns
	organ_tag = BP_HORNS
	draw_order = 70 // after frills/spines, matches source repos' horns-drawn-last convention

/datum/sprite_accessory/mutant/frills
	organ_tag = BP_FRILLS
	draw_order = 40

/datum/sprite_accessory/mutant/spines
	organ_tag = BP_SPINES
	draw_order = 30

/datum/sprite_accessory/mutant/ears
	organ_tag = BP_EARS
	draw_order = 60 // between frills and horns

/datum/sprite_accessory/mutant/xenodorsal
	organ_tag = BP_XENODORSAL
	draw_order = 45

/datum/sprite_accessory/mutant/xenohead
	organ_tag = BP_XENOHEAD
	draw_order = 80 // biggest/most head-shape-defining, draws on top of everything else head-stacked

/datum/sprite_accessory/mutant/wings
	organ_tag = BP_WINGS
	// draw_order is unused for wings -- they don't go through the head-stacked rendering loop at all (see
	// accessory_mutant_wings_anthro.dm's header comment for why), rendered instead via a dedicated mob-level
	// overlay layer (HO_WINGS_LAYER in update_icons.dm), same approach as the tail organ.

/datum/sprite_accessory/mutant/snout
	organ_tag = BP_SNOUT
	draw_order = 20 // base face/muzzle shape -- drawn first so horns/ears/frills/xenohead layer on top of it

/datum/sprite_accessory/mutant/moth_antennae
	organ_tag = BP_MOTH_ANTENNAE
	draw_order = 65 // peripheral protruding feature, similar priority to ears/horns

/datum/sprite_accessory/mutant/fluff
	organ_tag = BP_FLUFF
	draw_order = 40

/datum/sprite_accessory/mutant/breasts
	organ_tag = BP_BREASTS
	draw_order = 50 // only one chest-stacked category so far -- default is fine until something else needs ordering

/datum/sprite_accessory/mutant/penis
	organ_tag = BP_PENIS
	draw_order = 50 // groin-stacked; drawn after testicles so it layers on top

/datum/sprite_accessory/mutant/testicles
	organ_tag = BP_TESTICLES
	draw_order = 40 // drawn behind penis

/datum/sprite_accessory/mutant/vagina
	organ_tag = BP_PUSSY
	draw_order = 50
