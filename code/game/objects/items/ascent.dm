/obj/item/clustertool
	name = "alien clustertool"
	desc = "A bewilderingly complex knot of tool heads."
	icon = 'icons/obj/ascent.dmi'
	icon_state = "clustertool"
	w_class = ITEM_SIZE_SMALL


/obj/item/storage/toolbox/ascent
	name = "odd toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	color = "#3b88bf"
	startswith = list(/obj/item/clustertool, /obj/item/weldingtool/electric/mantid, /obj/item/crowbar/ascent, /obj/item/device/multitool/mantid)

/obj/item/crowbar/ascent
	name = "odd maintenance jack"
	desc = "A special crowbar used for general maintenance. This one appears oddly weighted."
	color = "#3b88bf"
	w_class = ITEM_SIZE_NORMAL

/obj/item/device/flashlight/lamp/floodlamp/ascent
	name = "odd lamp"
	color = "#a33fbf"
