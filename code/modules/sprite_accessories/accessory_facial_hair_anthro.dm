/datum/sprite_accessory/facial_hair/anthro
	icon = 'icons/mob/human_races/species/human/facial.dmi'
	species_allowed = list(SPECIES_HUMAN, SPECIES_ANTHRO) // hair/facial hair only makes sense for these two (explicit user decision, 2026-09-02) -- GAS/Gyne/Vox/etc don't get hair options
	blend = ICON_MULTIPLY // greyscale-authored art (white/grey shading, not flat black), unlike the base class's ICON_ADD default -- ICON_ADD would just clamp every near-white pixel to white regardless of chosen color

/datum/sprite_accessory/facial_hair/anthro/sideburns
	name = "Sideburns"
	icon_state = "sideburns"

/datum/sprite_accessory/facial_hair/anthro/goatee
	name = "Nova Goatee"
	icon_state = "goatee"

/datum/sprite_accessory/facial_hair/anthro/fiveoclock
	name = "Nova 5 O'clock Shadow"
	icon_state = "5oclock"

/datum/sprite_accessory/facial_hair/anthro/tribeard
	name = "Tribal Beard"
	icon_state = "tribeard"

/datum/sprite_accessory/facial_hair/anthro/neckfluff
	name = "Neck Fluff"
	icon_state = "neckfluff"

/datum/sprite_accessory/facial_hair/anthro/squid
	name = "Squid Beard"
	icon_state = "squid"

/datum/sprite_accessory/facial_hair/anthro/selleckreceeded
	name = "Receded Selleck Moustache"
	icon_state = "selleckreceeded"


// Teshari facial hair, ported from S.P.L.U.R.T-tg-master (modular_zzplurt) -- 2026-09-02 hair sweep.
// Not yet wired to a Teshari species (not playable in this codebase yet); left in the general
// Human+Anthro pool for now, matching upstream (no species restriction on these there either).
// gender = NEUTER on all 3 -- the base facial_hair class defaults to MALE-only (real-world "beards are a male
// thing" convention, fine for Human), but Teshari has no gendered body art anywhere else (identical art for
// every gender, see teshari.dm/teshari body.dmi), so these were silently invisible to any non-male Teshari
// (get_facial_hair_styles() excludes MALE-gendered entries for a FEMALE query) -- only "Shaved" (already
// NEUTER) survived, which fails the "more than 1 choice" gate that shows the selector at all.
/datum/sprite_accessory/facial_hair/anthro/teshari_gap
	name = "Teshari Chops"
	icon_state = "teshari_gap"
	gender = NEUTER
	species_allowed = list(SPECIES_ANTHRO, SPECIES_TESHARI)

/datum/sprite_accessory/facial_hair/anthro/teshari_chin
	name = "Teshari Beard"
	icon_state = "teshari_chin"
	gender = NEUTER
	species_allowed = list(SPECIES_ANTHRO, SPECIES_TESHARI)

/datum/sprite_accessory/facial_hair/anthro/teshari_scraggly
	name = "Teshari Scraggly"
	icon_state = "teshari_scraggly"
	gender = NEUTER
	species_allowed = list(SPECIES_ANTHRO, SPECIES_TESHARI)



// New content ported 2026-09-02 -- Nova's own facialhair.dmi extras + Bubberstation's modular_zubbers pack.
/datum/sprite_accessory/facial_hair/anthro/lizardlick
	name = "Lizard Tongue Flick"
	icon_state = "lizardlick"

/datum/sprite_accessory/facial_hair/anthro/lizardlickslow
	name = "Lizard Tongue Flick Slow"
	icon_state = "lizardlickslow"

/datum/sprite_accessory/facial_hair/anthro/lizardlickfast
	name = "Lizard Tongue Flick Fast"
	icon_state = "lizardlickfast"

/datum/sprite_accessory/facial_hair/anthro/noselick
	name = "Nose Lick"
	icon_state = "noselick"

/datum/sprite_accessory/facial_hair/anthro/fullstub
	name = "Full Stub"
	icon_state = "fullstub"

/datum/sprite_accessory/facial_hair/anthro/viking
	name = "Beard (Viking)"
	icon_state = "viking"

// Vox facial hair, ported from NovaSector/Bubberstation (vox_facial_hair.dmi) -- restored 2026-09-02.
// Not species-restricted to Vox (Vox is excluded from hair/facial hair by standing policy); kept as
// general-pool flavor content, same treatment as the Teshari and Vox head-hair styles above.
/datum/sprite_accessory/facial_hair/anthro/vox_beard
	name = "Vox Beard"
	icon_state = "vox_beard"

/datum/sprite_accessory/facial_hair/anthro/vox_colonel
	name = "Vox Colonel"
	icon_state = "vox_colonel"

/datum/sprite_accessory/facial_hair/anthro/vox_fu
	name = "Vox Fu Manchu"
	icon_state = "vox_fu"

/datum/sprite_accessory/facial_hair/anthro/vox_neck
	name = "Vox Neck Beard"
	icon_state = "vox_neck"

/datum/sprite_accessory/facial_hair/anthro/vox_mane
	name = "Vox Mane"
	icon_state = "vox_mane"

