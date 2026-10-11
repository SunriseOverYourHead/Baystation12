/obj/item/organ/internal/mutant/penis
	name = "penis"
	organ_tag = BP_PENIS
	parent_organ = BP_GROIN
	is_genital = TRUE
	// Set by copy_to() (preferences.dm) only when "P. Sheath" is active (Sheath/Slit) -- the shape+size the player
	// actually picked before that override replaced sprite_datum/size, preserved so get_effective_sprite_datum()
	// below can reveal it once fully aroused. Null whenever Sheath/Slit isn't in use, matching every other penis
	// shape's behavior exactly (no override at all).
	var/datum/sprite_accessory/mutant/underlying_sprite_datum
	var/underlying_size

/obj/item/organ/internal/mutant/penis/get_style_list()
	return GLOB.mutant_penis_styles_list

/obj/item/organ/internal/mutant/penis/get_effective_sprite_datum()
	if(is_aroused && underlying_sprite_datum)
		return underlying_sprite_datum
	return sprite_datum

/obj/item/organ/internal/mutant/penis/get_effective_size()
	if(is_aroused && underlying_sprite_datum)
		return underlying_size
	return size
