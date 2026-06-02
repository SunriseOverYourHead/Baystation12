/obj/item/clothing/accessory/armor_plate // Anything lower and it should be a soft vest.
	name = "IIIA+ armor plate"
	desc = "A level IIIA+ armor plate made of steel-reinforced synthetic fibers. Provides great protection against pistol rounds and limited protection to rifle rounds. Attaches to a plate carrier."
	icon = 'icons/obj/clothing/obj_suit_modular_armor.dmi'
	icon_state = "armor_light"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_IIIAP,
		laser = ARMOR_LASER_MINOR,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_MINOR
		)
	slot = ACCESSORY_SLOT_ARMOR_CHEST
	flags_inv = CLOTHING_BULKY


/obj/item/clothing/accessory/armor_plate/III
	name = "III armor plate"
	desc = "A level III armor plate, providing good protection against rifle rounds. Attaches to a plate carrier."
	icon_state = "armor_medium"
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_III,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED
	)


/obj/item/clothing/accessory/armor_plate/IIIP
	name = "III+ armor plate"
	desc = "A III+ armor plate with additional material. Provides great protection against rifle rounds. Attaches to a plate carrier."
	icon_state = "armor_tactical"
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_IIIP,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
	)


/obj/item/clothing/accessory/armor_plate/IV
	name = "IV armor plate"
	desc = "A level IV ceramics-reinforced synthetic armor plate, providing state of of the art protection against rifle rounds. Attaches to a plate carrier."
	icon_state = "armor_merc"
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_IV,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
	)
	slowdown = 0.1


/obj/item/clothing/accessory/armor_plate/sneaky
	name = "low-profile armor vest"
	desc = "An armor vest made of layered polymer fibers. Can attach to your slacks and office shirt."
	siemens_coefficient = 0.6
	item_icons = list(slot_wear_suit_str = 'icons/mob/onmob/onmob_accessories.dmi')
	item_flags = ITEM_FLAG_THICKMATERIAL
	slot_flags = SLOT_OCLOTHING //can wear in suit slot as well
	slot = ACCESSORY_SLOT_UTILITY
	w_class = ITEM_SIZE_NORMAL
	blood_overlay_type = "armorblood"
	icon_state = "undervest"


/obj/item/clothing/accessory/armor_plate/sneaky/tactical
	name = "low-profile tactical armor vest"
	desc = "An armor vest made of layered smart polymers. Can attach to your slacks and office shirt."
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_IIIAP,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_SMALL,
		bomb = ARMOR_BOMB_PADDED
	)
