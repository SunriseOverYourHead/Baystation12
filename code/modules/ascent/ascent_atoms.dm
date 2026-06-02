// Submap specific atom definitions.

MANTIDIFY(/obj/item/storage/bag/trash/purple,   "sample collection carrier", "material storage")
MANTIDIFY(/obj/structure/bed/chair/padded/purple,      "mantid nest",               "resting place")
MANTIDIFY(/obj/item/pickaxe/diamonddrill,       "lithobliterator",           "drilling")
MANTIDIFY(/obj/item/tank/jetpack/carbondioxide, "maneuvering pack",          "propulsion")

/obj/structure/bed/chair/padded/purple/ascent
	icon_state = "nest_chair"
	base_icon = "nest_chair"
	pixel_z = 0

/obj/structure/bed/chair/padded/purple/ascent/gyne
	name = "mantid throne"
	icon_state = "nest_chair_large"
	base_icon = "nest_chair_large"

/obj/item/light/tube/ascent
	name = "mantid light filament"
	light_color = COLOR_BLUE_LIGHT
	color = COLOR_BLUE_LIGHT
	b_colour = COLOR_BLUE_LIGHT
	desc = "Some kind of strange alien lightbulb technology."

/obj/structure/ascent_spawn
	name = "mantid cryotank"
	desc = "A liquid-filled, cloudy tank with strange forms twitching inside."
	icon = 'icons/obj/machines/medical/cryogenics.dmi'
	icon_state = "cellold2"
	anchored = TRUE
	density =  TRUE

/obj/structure/wall_frame/hull/ascent
	paint_color = COLOR_INDIGO
	stripe_color = COLOR_INDIGO

/obj/wallframe_spawn/reinforced_phoron/ascent
	frame_path = /obj/structure/wall_frame/hull/ascent

/obj/item/device/personal_shield/mantid
	name = "personal shield"
	desc = "Truly a life-saver: this device protects its user from being hit by objects moving very, very fast, though only for a few shots."
	color = "#a33fbf"
