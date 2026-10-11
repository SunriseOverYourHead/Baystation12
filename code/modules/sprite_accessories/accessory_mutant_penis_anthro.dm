// Penis, ported from Bubberstation. All 9 real shape families from the base source ported (each a separate
// pickable style, including Tentacle -- its animated, per-size-varying frame layout needed bespoke extraction
// handling, see extract script notes in [[baystation12soyh_genitals_port_plan]]), plus 9 more "(Alt)" shapes from
// Bubberstation's modular_zubbers addon (a genuinely different art style for mostly the same shape names, its own
// separate source .dmi). Size (1-7 within each shape) is driven by the "Penis size" slider (size_penis in
// preferences_tgui.dm/species_features.tsx), not separate named styles -- build_colored_icon() appends the chosen
// size directly to icon_state (e.g. "knotted" + size 4 -> "knotted4_s"). "amputated" is a damage/removal state,
// not a pickable style -- not ported here.
//
// species_allowed on each individual style below implements the canon genital matrix (per-species requirements,
// this session) -- get_mutant_styles() (species.dm) already filters by this exact list for every other
// species-restricted accessory category (hair, markings, etc), so no new plumbing was needed, just content. A
// player with Allow Non-Canon Bodyparts on bypasses this filter entirely (see get_mutant_styles()'s allow_noncanon
// param) and can pick any of these regardless of species.
/datum/sprite_accessory/mutant/penis/anthro
	icon = 'icons/mob/species/anthro/penis.dmi'
	// Ported art is a greyscale mask -- needs ICON_MULTIPLY to tint toward skin_color, not the base class's
	// ICON_ADD default. See accessory_mutant_breasts_anthro.dm/accessory_mutant_tail_anthro.dm precedent.
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/penis/anthro/human
	name = "Human"
	icon_state = "human"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/knotted
	name = "Knotted"
	icon_state = "knotted"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/barbknot
	name = "Barbed Knot"
	icon_state = "barbknot"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/flared
	name = "Flared"
	icon_state = "flared"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/hemi
	name = "Hemipenis"
	icon_state = "hemi"
	species_allowed = list(SPECIES_UNATHI, SPECIES_YEOSA, SPECIES_NABBER, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/hemiknot
	name = "Knotted Hemipenis"
	icon_state = "hemiknot"
	species_allowed = list(SPECIES_NABBER, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/tapered
	name = "Tapered"
	icon_state = "tapered"
	species_allowed = list(SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_YEOSA, SPECIES_NABBER, SPECIES_VOX, SPECIES_MANTID_ALATE, SPECIES_TESHARI, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/nondescript
	name = "Nondescript"
	icon_state = "nondescript"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/tentacle
	name = "Tentacle"
	icon_state = "tentacle"
	species_allowed = list(SPECIES_SKRELL, SPECIES_MANTID_ALATE, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/human_alt
	name = "Human (Alt)"
	icon_state = "humanalt"
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/knotted_alt
	name = "Knotted (Alt)"
	icon_state = "knottedalt"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/barbknot_alt
	name = "Barbed Knot (Alt)"
	icon_state = "barbknotalt"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/flared_alt
	name = "Flared (Alt)"
	icon_state = "flaredalt"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/hemi_alt
	name = "Hemipenis (Alt)"
	icon_state = "hemialt"
	species_allowed = list(SPECIES_UNATHI, SPECIES_YEOSA, SPECIES_NABBER, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/hemiknot_alt
	name = "Knotted Hemipenis (Alt)"
	icon_state = "hemiknotalt"
	species_allowed = list(SPECIES_NABBER, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/tapered_alt
	name = "Tapered (Alt)"
	icon_state = "taperedalt"
	species_allowed = list(SPECIES_SKRELL, SPECIES_UNATHI, SPECIES_YEOSA, SPECIES_NABBER, SPECIES_VOX, SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/nondescript_alt
	name = "Nondescript (Alt)"
	icon_state = "nondescriptalt"
	species_allowed = list(SPECIES_ANTHRO, SPECIES_IPC)

/datum/sprite_accessory/mutant/penis/anthro/tentacle_alt
	name = "Tentacle (Alt)"
	icon_state = "tentaclealt"
	species_allowed = list(SPECIES_SKRELL, SPECIES_ANTHRO, SPECIES_IPC)

// Sheath/Slit are the source's toggle-driven "retracted" overlays -- driven by the dedicated "P. Sheath"
// preference (preferences_tgui.dm/preferences.dm), which overrides organ.sprite_datum to one of these two
// regardless of the normally-chosen shape, not the ordinary shape dropdown -- hidden_from_picker keeps them out
// of get_mutant_styles()'s picker/validation list (species.dm) while still letting the override logic look them
// up by name from the raw GLOB registry. Sizeless in the source, single un-suffixed state each (P. Sheath also
// forces organ.size to null when active, so build_colored_icon() never appends a size to these). No
// species_allowed on these two -- hidden_from_picker already keeps them out of the normal dropdown regardless of
// species; force_male_sheath_mode (species.dm) is what actually decides which species get forced into one.
/datum/sprite_accessory/mutant/penis/anthro/sheath
	name = "Sheath"
	icon_state = "sheath"
	species_allowed = null
	hidden_from_picker = TRUE

/datum/sprite_accessory/mutant/penis/anthro/slit
	name = "Slit"
	icon_state = "slit"
	species_allowed = null
	hidden_from_picker = TRUE

// Teshari's own sheath alias -- same art, same icon_state, as "Slit" above, just named to match their canon
// anatomy ("Cloaca" rather than "Slit") for force_male_sheath_mode (teshari.dm) to force Teshari males into
// instead of the generic "Slit" name.
/datum/sprite_accessory/mutant/penis/anthro/cloaca_sheath
	name = "Cloaca"
	icon_state = "slit"
	species_allowed = null
	hidden_from_picker = TRUE
