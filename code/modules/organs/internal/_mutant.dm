/obj/item/organ/internal/mutant
	name = "mutant organ"
	parent_organ = BP_GROIN
	relative_size = 5

	var/datum/sprite_accessory/mutant/sprite_datum
	var/list/colors = list("", "", "")
	var/list/emissive = list(FALSE, FALSE, FALSE)
	var/default_style_name
	// Only meaningful for categories whose sprite_datum has size-varying art baked into its icon (see
	// /datum/sprite_accessory/mutant/build_colored_icon()'s `size` param) -- null for every category that doesn't,
	// which renders exactly as before this var was added.
	var/size
	// Only meaningful for penis/vagina (see build_colored_icon()'s `aroused` param) -- selects the "_a_s"-suffixed
	// aroused/erect art extracted from Bubberstation's own arousal-driven sprite swap (confirmed against their real
	// DM source, modular_skyrat/.../genitals.dm's update_genital_icon_state()/get_sprite_size_string(): `is_erect`/
	// `is_dripping` are literally `(aroused == AROUSAL_FULL)`, producing the exact "_0"/"_1" icon_state suffix this
	// var mirrors). FALSE and never set for every other mutant category -- harmless default, no "_a_s" state exists
	// for them to swap to anyway. Driven by /datum/sex_controller (code/datums/sexcon/sexcon.dm), not set directly.
	var/is_aroused = FALSE
	// TRUE only on Breasts/Penis/Testicles/Vagina/Anus (set on each of those 5 classes directly) -- gates
	// should_show_genitals() (mutant_genitals_visibility.dm) in the chest/groin render loops (standard.dm) so
	// Tail/Wings/Fluff/etc (also chest/groin-parented mutant organs) are correctly left unaffected by the
	// genital-visibility toggle, which is specifically about genitals.
	var/is_genital = FALSE

/obj/item/organ/internal/mutant/proc/get_style_list()
	return null

// Overridden on penis (see mutant_penis.dm) to swap in the underlying "real" shape while aroused and currently
// wearing a Sheath/Slit style -- matches Bubberstation's own real behavior (confirmed in their genitals.dm:
// get_sprite_size_string() stops using sheath/slit naming ENTIRELY at AROUSAL_FULL and falls through to the
// player's normal shape's own erect state instead) rather than just showing a slightly-bigger "poking out" sprite
// forever. Base implementation is a no-op passthrough for every other category.
/obj/item/organ/internal/mutant/proc/get_effective_sprite_datum()
	return sprite_datum

/obj/item/organ/internal/mutant/proc/get_effective_size()
	return size

/obj/item/organ/internal/mutant/Initialize(mapload, datum/dna/given_dna)
	. = ..()
	if(!sprite_datum && default_style_name)
		var/list/style_list = get_style_list()
		if(islist(style_list))
			sprite_datum = style_list[default_style_name]
