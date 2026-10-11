// Anus organ -- mechanics-only, no visual component, matching Bubberstation's own real source (confirmed directly:
// no /datum/sprite_accessory/genital/anus class exists anywhere in modular_skyrat or modular_zubbers, no
// "anus_onmob.dmi" sheet either -- the only anus.dmi in the source is the standalone ITEM icon, irrelevant to
// on-mob rendering). sprite_datum is intentionally never assigned (no get_style_list()/default_style_name override)
// so get_groin_mutant_icon()'s render loop (`if(!MO.sprite_datum) continue`, standard.dm) always skips it --
// existence is purely for SEX_ZONE_ANUS/can_use_anus() gating (chastity's anal-blocking, future anal sex_actions),
// not char-creator cosmetics.
/obj/item/organ/internal/mutant/anus
	name = "anus"
	organ_tag = BP_ANUS
	parent_organ = BP_GROIN
	is_genital = TRUE
