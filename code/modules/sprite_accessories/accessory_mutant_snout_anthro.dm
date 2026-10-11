// Snout ported directly from Bubberstation (modular_skyrat/master_files sprite_accessory/snouts.dmi +
// snout.dm catalog) -- names, icon_states, and per-style color-region counts are pulled 1:1 from
// Bubberstation's own source, not re-derived by heuristic. Each style's primary/secondary/tertiary
// layers were composited from Bubberstation's real BEHIND/ADJ/FRONT structural layers (flattened into
// one image per color region, since BS12SOYH doesn't have Bubberstation's separate structural-layer
// render pipeline) -- region presence/count matches exactly what Bubberstation's own matrixed-color
// detection finds for that style (a style with only 'secondary'+'tertiary' art in Bubberstation's own
// file gets color_regions = 2 here, using that art as regions 1/2, since that's how Bubberstation's own
// code renumbers colors for such styles too). Not verified in a live client (per user direction).
/datum/sprite_accessory/mutant/snout/anthro
	icon = 'icons/mob/species/anthro/snout.dmi'
	species_allowed = list(SPECIES_ANTHRO)
	mutant_blend = ICON_MULTIPLY

/datum/sprite_accessory/mutant/snout/anthro/bird
	name = "Beak"
	icon_state = "bird"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/birdsmall
	name = "Beak (small)"
	icon_state = "birdsmall"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/bigbeak
	name = "Big Beak"
	icon_state = "bigbeak"

/datum/sprite_accessory/mutant/snout/anthro/bigbeakshort
	name = "Big Beak Short"
	icon_state = "bigbeakshort"

/datum/sprite_accessory/mutant/snout/anthro/slimbeak
	name = "Slim Beak"
	icon_state = "slimbeak"

/datum/sprite_accessory/mutant/snout/anthro/slimbeakshort
	name = "Slim Beak Short"
	icon_state = "slimbeakshort"

/datum/sprite_accessory/mutant/snout/anthro/slimbeakalt
	name = "Slim Beak Alt"
	icon_state = "slimbeakalt"

/datum/sprite_accessory/mutant/snout/anthro/hookbeak
	name = "Hook Beak"
	icon_state = "hookbeak"

/datum/sprite_accessory/mutant/snout/anthro/hookbeakbig
	name = "Hook Beak Big"
	icon_state = "hookbeakbig"

/datum/sprite_accessory/mutant/snout/anthro/corvidbeak
	name = "Corvid Beak"
	icon_state = "corvidbeak"

/datum/sprite_accessory/mutant/snout/anthro/bug
	name = "Bug"
	icon_state = "bug"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/bug_no_eyes
	name = "Bug (No eyes)"
	icon_state = "bug_no_eyes"

/datum/sprite_accessory/mutant/snout/anthro/elephant
	name = "Elephant"
	icon_state = "elephant"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/husky
	name = "Husky"
	icon_state = "husky"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/rhino
	name = "Horn"
	icon_state = "rhino"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/rodent
	name = "Rodent"
	icon_state = "rodent"

/datum/sprite_accessory/mutant/snout/anthro/lcanid
	name = "Mammal, Long"
	icon_state = "lcanid"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/lcanidalt
	name = "Mammal, Long ALT"
	icon_state = "lcanidalt"

/datum/sprite_accessory/mutant/snout/anthro/lcanidstriped
	name = "Mammal, Long, Striped"
	icon_state = "lcanidstripe"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/lcanidstripedalt
	name = "Mammal, Long, Striped ALT"
	icon_state = "lcanidstripealt"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/scanid
	name = "Mammal, Short"
	icon_state = "scanid"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/scanidalt
	name = "Mammal, Short ALT"
	icon_state = "scanidalt"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/scanidalt2
	name = "Mammal, Short ALT 2"
	icon_state = "scanidalt2"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/scanidalt3
	name = "Mammal, Short ALT 3"
	icon_state = "scanidalt3"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/normal
	name = "Tajaran, normal"
	icon_state = "ntajaran"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/wolf
	name = "Mammal, Thick"
	icon_state = "wolf"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/wolfalt
	name = "Mammal, Thick ALT"
	icon_state = "wolfalt"

/datum/sprite_accessory/mutant/snout/anthro/otie
	name = "Otie"
	icon_state = "otie"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/otiesmile
	name = "Otie Smile"
	icon_state = "otiesmile"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/otter
	name = "Otter"
	icon_state = "otter"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/pede
	name = "Scolipede"
	icon_state = "pede"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/sergal
	name = "Sergal"
	icon_state = "sergal"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/shark
	name = "Shark"
	icon_state = "shark"

/datum/sprite_accessory/mutant/snout/anthro/hshark
	name = "hShark"
	icon_state = "hshark"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/hshark_eyes
	name = "hShark and eyes"
	icon_state = "hshark_eyes"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/toucan
	name = "Toucan"
	icon_state = "toucan"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/redpanda
	name = "WahCoon"
	icon_state = "wah"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/redpandaalt
	name = "WahCoon ALT"
	icon_state = "wahalt"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/skulldog
	name = "Skulldog"
	icon_state = "skulldog"
	color_regions = 3

/datum/sprite_accessory/mutant/snout/anthro/hanubus
	name = "Anubus"
	icon_state = "hanubus"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/hpanda
	name = "Panda"
	icon_state = "hpanda"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/hjackal
	name = "Jackal"
	icon_state = "hjackal"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/hspots
	name = "Hyena"
	icon_state = "hspots"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/hhorse
	name = "Horse"
	icon_state = "hhorse"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/hzebra
	name = "Zebra"
	icon_state = "hzebra"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/shark_light
	name = "Shark Light"
	icon_state = "sharkblubber"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/rat
	name = "Rat"
	icon_state = "rat"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/stubby
	name = "Stubby"
	icon_state = "stubby"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/leporid
	name = "Leporid"
	icon_state = "leporid"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/acrador
	name = "Acrador (Short)"
	icon_state = "acrador_short"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/acrador_1
	name = "Acrador 1 (Normal)"
	icon_state = "acrador_1"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/acrador_2
	name = "Acrador 2 (Normal)"
	icon_state = "acrador_2"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/acrador_3
	name = "Acrador 3 (Normal)"
	icon_state = "acrador_3"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/acrador_4
	name = "Acrador 4 (Normal)"
	icon_state = "acrador_4"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/renamon
	name = "Cyvian"
	icon_state = "renamon"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/exsharp
	name = "Extra Sharp"
	icon_state = "exsharp"
	color_regions = 2

/datum/sprite_accessory/mutant/snout/anthro/masked_wing
	name = "Masked Wing"
	icon_state = "masked"
