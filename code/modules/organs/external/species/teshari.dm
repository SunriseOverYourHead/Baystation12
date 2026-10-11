// Teshari uses the same standard 32x32 icon_template as Human (no template_tall.dmi override, unlike GAS/Nabber),
// but its own body art's silhouette sits at a slightly different position within that tile -- these two subtypes
// exist solely to carry the pixel offset for Breasts/Penis/Testicles/Vagina's human-aligned art (see standard.dm's
// mutant_organ_pixel_offset) onto Teshari's own proportions. Wired in via teshari.dm's override_limb_types.

/obj/item/organ/external/chest/teshari
	// icons/mob/human_races/species/teshari/body.dmi's own torso_f/torso_m bbox is (12,14,20,21) vs human's
	// (10,10,21,20), both in a 32x32 tile -- converting to BYOND's bottom-up Y and comparing centroids gives
	// this offset (a plain re-centering translation, not a resculpt). NOT hand-verified per-direction the way
	// groin's offset was (this round's ask was genitals-only) -- kept as a single flat value for now.
	mutant_organ_pixel_offset = alist(
		SOUTH = list(1, -3),
		NORTH = list(1, -3),
		EAST = list(1, -3),
		WEST = list(1, -3)
	)

/obj/item/organ/external/groin/teshari
	// Hand-placed by the user directly in icons/mob/reference_parts.dmi (full 4-dir body composites + a separate
	// Hemi reference, diffed per-direction against Hemi's own known reference position -- NOT against a
	// regenerated body silhouette; the user's edited file had the body content cleared out of each species state,
	// leaving just the repositioned Hemi shape, and the first extraction pass wrongly diffed against a freshly
	// regenerated body, which folded the body's own "disappearance" into the measurement and produced badly wrong
	// values). Live-tested afterward and found 3px too far south across the board -- shifted back up by exactly
	// that (also the likely cause of Cloaca/Slit rendering as no sprite at all: get_icon_shifted_per_dir() clips
	// content that Shift()s past its own 32x32 canvas edge, and -6 south had noticeably less margin to work with
	// than -3).
	mutant_organ_pixel_offset = alist(
		SOUTH = list(0, -3),
		NORTH = list(0, -3),
		EAST = list(-1, 0),
		WEST = list(1, 0)
	)
