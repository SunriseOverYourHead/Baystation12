// Wings ported directly from Bubberstation (modular_skyrat/master_files sprite_accessory/wings.dmi +
// wings.dm catalog, wings/mammal + wings/low_wings branches only -- wings/moth is a separate,
// non-matrixed, full-art organ category (/obj/item/organ/wings/moth) not part of this one;
// wings/angel, wings/dragon (TG-special, locked/potion-granted) and wings_open use a different icon
// entirely and aren't part of the selectable customization catalog either. '(Top)' variants (a second
// copy of several styles, drawn at a different z-order for compatibility with certain headwear in
// Bubberstation's layered render pipeline) are dropped -- BS12SOYH composites one flat image per
// organ with no such distinction, so keeping both would just be a confusing near-duplicate entry.
// Names, icon_states, and per-style color-region counts are pulled 1:1 from Bubberstation's own
// source (see accessory_mutant_snout_anthro.dm for the full region-detection/renumbering method,
// identical here). Tile size is 45x34 (from the source DMI header), not the usual 32x32.
// Not verified in a live client (per user direction).
/datum/sprite_accessory/mutant/wings/anthro
	icon = 'icons/mob/species/anthro/wings.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/wings/anthro/bat
	name = "Bat"
	icon_state = "bat"

/datum/sprite_accessory/mutant/wings/anthro/bee
	name = "Bee"
	icon_state = "bee"

/datum/sprite_accessory/mutant/wings/anthro/beetle
	name = "Beetle"
	icon_state = "beetle"

/datum/sprite_accessory/mutant/wings/anthro/alt1
	name = "Dragon (Alt 1)"
	icon_state = "dragonalt1"
	color_regions = 2

/datum/sprite_accessory/mutant/wings/anthro/alt2
	name = "Dragon (Alt 2)"
	icon_state = "dragonalt2"
	color_regions = 2

/datum/sprite_accessory/mutant/wings/anthro/synth
	name = "Dragon (Synthetic)"
	icon_state = "dragonsynth"
	color_regions = 3

/datum/sprite_accessory/mutant/wings/anthro/mechanical
	name = "Dragon (Mechanical)"
	icon_state = "robowing"
	color_regions = 2

/datum/sprite_accessory/mutant/wings/anthro/fairy
	name = "Fairy"
	icon_state = "fairy"

/datum/sprite_accessory/mutant/wings/anthro/feathery
	name = "Feathery"
	icon_state = "feathery"
	color_regions = 3

/datum/sprite_accessory/mutant/wings/anthro/alt1_2
	name = "Feathery (Alt 1)"
	icon_state = "featheryalt1"
	color_regions = 3

/datum/sprite_accessory/mutant/wings/anthro/alt2_2
	name = "Feathery (Alt 2)"
	icon_state = "featheryalt2"
	color_regions = 2

/datum/sprite_accessory/mutant/wings/anthro/harpy
	name = "Harpy"
	icon_state = "harpy"

/datum/sprite_accessory/mutant/wings/anthro/alt
	name = "Harpy (Alt)"
	icon_state = "harpyalt"

/datum/sprite_accessory/mutant/wings/anthro/fluffless
	name = "Harpy (Alt - Fluffless)"
	icon_state = "harpyalt_fluffless"

/datum/sprite_accessory/mutant/wings/anthro/bat_2
	name = "Harpy (Bat)"
	icon_state = "harpybat"
	color_regions = 3

/datum/sprite_accessory/mutant/wings/anthro/fluffless_2
	name = "Harpy (Bat - Fluffless)"
	icon_state = "harpybat_fluffless"
	color_regions = 2

/datum/sprite_accessory/mutant/wings/anthro/pterodactyl
	name = "Pterodactyl"
	icon_state = "pterodactyl"
	color_regions = 2

/datum/sprite_accessory/mutant/wings/anthro/insect
	name = "Insectoid"
	icon_state = "insect"

/datum/sprite_accessory/mutant/wings/anthro/bat_3
	name = "Mini-Bat"
	icon_state = "minibat"

/datum/sprite_accessory/mutant/wings/anthro/feather
	name = "Mini-Feathery"
	icon_state = "minifeather"

/datum/sprite_accessory/mutant/wings/anthro/spider
	name = "Spider Legs"
	icon_state = "spider_legs"

/datum/sprite_accessory/mutant/wings/anthro/succubus
	name = "Succubus"
	icon_state = "succubus"

/datum/sprite_accessory/mutant/wings/anthro/bat_4
	name = "Tiny-Bat"
	icon_state = "tinybat"

/datum/sprite_accessory/mutant/wings/anthro/feather_2
	name = "Tiny-Feathery"
	icon_state = "tinyfeather"

/datum/sprite_accessory/mutant/wings/anthro/low_wings
	name = "Low wings"
	icon_state = "low"

/datum/sprite_accessory/mutant/wings/anthro/tri
	name = "Low Wings (Tri-Tone)"
	icon_state = "low_tri"
	color_regions = 3

/datum/sprite_accessory/mutant/wings/anthro/jewel
	name = "Low Wings Jeweled"
	icon_state = "low_jewel"
	color_regions = 3

/datum/sprite_accessory/mutant/wings/anthro/renamon
	name = "Cyvian"
	icon_state = "renamon"
	color_regions = 2
