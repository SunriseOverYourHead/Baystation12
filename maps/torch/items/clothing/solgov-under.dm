/obj/item/clothing/under/solgov
	name = "master solgov uniform"
	desc = "You shouldn't be seeing this."
	icon = 'maps/torch/icons/obj/obj_under_solgov.dmi'
	item_icons = list(slot_w_uniform_str = 'maps/torch/icons/mob/onmob_under_solgov.dmi')
	sprite_sheets = list(
		SPECIES_UNATHI = 'maps/torch/icons/mob/unathi/onmob_under_solgov_unathi.dmi'
		)
	siemens_coefficient = 0.8
	gender_icons = 1
	// The base /obj/item/clothing class excludes Nabber (GAS/MSW/MSQ all share that bodytype) by default -- that
	// made sense before the leg-remap system existed to shape jumpsuit art to their silhouette, it doesn't anymore.
	// Nothing else was actually restricted here (Unathi already has its own onmob_under_solgov_unathi.dmi above),
	// so clearing this just opens the whole solgov line up to GAS/MSW/MSQ -- 2026-09-03, explicit user request.
	species_restricted = null

//PT
/obj/item/clothing/under/solgov/pt
	name = "pt uniform"
	desc = "Shorts! Shirt! Miami! Sexy!"
	icon_state = "miami"
	worn_state = "miami"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/solgov/pt/expeditionary
	name = "expeditionary pt uniform"
	desc = "A baggy shirt bearing the seal of the SCG Expeditionary Corps and some dorky looking blue shorts."
	icon_state = "expeditionpt"
	worn_state = "expeditionpt"

/obj/item/clothing/under/solgov/pt/fleet
	name = "fleet pt uniform"
	desc = "A tight-fitting navy blue shirt paired with black shorts. For when you need to 'get physical'."
	icon_state = "fleetpt"
	worn_state = "fleetpt"

/obj/item/clothing/under/scga/pt/solgov
	name = "marine pt uniform"
	desc = "Does NOT leave much to the imagination."
	icon_state = "armypt"
	worn_state = "armypt"

//Utility

/obj/item/clothing/under/solgov/utility
	name = "utility uniform"
	desc = "A comfortable turtleneck and black utility trousers."
	icon_state = "blackutility"
	item_state = "bl_suit"
	worn_state = "blackutility"
	armor = list(
		melee = ARMOR_MELEE_MINOR,
		energy = ARMOR_ENERGY_MINOR
		)

/obj/item/clothing/under/solgov/utility/expeditionary
	name = "expeditionary uniform"
	desc = "The utility uniform of the SCG Expeditionary Corps, made from biohazard resistant material. This one has silver trim."
	icon_state = "blackutility_crew"
	worn_state = "blackutility_crew"

/obj/item/clothing/under/solgov/utility/expeditionary/command
	accessories = list(/obj/item/clothing/accessory/solgov/department/command)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/engineering
	accessories = list(/obj/item/clothing/accessory/solgov/department/engineering)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/service
	accessories = list(/obj/item/clothing/accessory/solgov/department/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/research
	accessories = list(/obj/item/clothing/accessory/solgov/department/research)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer
	name = "expeditionary officer's uniform"
	desc = "The utility uniform of the SCG Expeditionary Corps, made from biohazard resistant material. This one has gold trim."
	icon_state = "blackutility_com"
	worn_state = "blackutility_com"

/obj/item/clothing/under/solgov/utility/expeditionary/officer/command
	accessories = list(/obj/item/clothing/accessory/solgov/department/command)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/engineering
	accessories = list(/obj/item/clothing/accessory/solgov/department/engineering)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/service
	accessories = list(/obj/item/clothing/accessory/solgov/department/service)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/officer/research
	accessories = list(/obj/item/clothing/accessory/solgov/department/research)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet
	name = "fleet coveralls"
	desc = "The utility uniform of the SCG Fleet, made from an insulated material."
	icon_state = "navyutility"
	item_state = "jensensuit"
	worn_state = "navyutility"

/obj/item/clothing/under/solgov/utility/fleet/command
	accessories = list(/obj/item/clothing/accessory/solgov/department/command/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/command/pilot
	accessories = list(/obj/item/clothing/accessory/solgov/specialty/pilot)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/engineering
	accessories = list(/obj/item/clothing/accessory/solgov/department/engineering/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/service
	accessories = list(/obj/item/clothing/accessory/solgov/department/service/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/combat
	name = "fleet fatigues"
	desc = "Alternative utility uniform of the SCG Fleet, for when coveralls are impractical."
	icon_state = "navycombat"
	worn_state = "navycombat"

/obj/item/clothing/under/solgov/utility/fleet/combat/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/combat/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/combat/command
	accessories = list(/obj/item/clothing/accessory/solgov/department/command/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/combat/exploration
	accessories = list(/obj/item/clothing/accessory/solgov/department/exploration/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/combat/engineering
	accessories = list(/obj/item/clothing/accessory/solgov/department/engineering/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/combat/service
	accessories = list(/obj/item/clothing/accessory/solgov/department/service/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/combat/supply
	accessories = list(/obj/item/clothing/accessory/solgov/department/supply/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/polopants
	name = "fleet polo and pants"
	desc = "An alternative utility uniform of the SCG Fleet, specially designed for engineering staff. The pants sport some yellow reflective stripes, and have knee pads."
	icon_state = "navypolopants"
	worn_state = "navypolopants"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/polopants/command
	desc = "An alternative utility uniform of the SCG Fleet. The pants have knee pads."
	icon_state = "navypolopantsnostripe"
	worn_state = "navypolopantscom"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/polopants/security
	desc = "An alternative utility uniform of the SCG Fleet. The pants have knee pads."
	icon_state = "navypolopantsnostripe"
	worn_state = "navypolopantssec"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/polopants/medical
	desc = "An alternative utility uniform of the SCG Fleet, specially designed for medics and doctors. The pants have knee pads."
	icon_state = "navypolopantsnostripe"
	worn_state = "navypolopantsmed"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/polopants/supply
	desc = "An alternative utility uniform of the SCG Fleet. The pants have knee pads."
	icon_state = "navypolopantsnostripe"
	worn_state = "navypolopantssup"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/polopants/service
	desc = "An alternative utility uniform of the SCG Fleet. The pants have knee pads."
	icon_state = "navypolopantsnostripe"
	worn_state = "navypolopantssrv"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/polopants/exploration
	desc = "An alternative utility uniform of the SCG Fleet. The pants have knee pads."
	icon_state = "navypolopantsnostripe"
	worn_state = "navypolopantsxpl"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/officer
	name = "fleet officer's coveralls"
	desc = "Alternative utility uniform of the SCG Fleet, for officers."
	icon_state = "navyutilityoff"
	worn_state = "navyutilityoff"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/officer/command
	accessories = list(/obj/item/clothing/accessory/solgov/department/command/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/officer/engineering
	accessories = list(/obj/item/clothing/accessory/solgov/department/engineering/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/officer/security
	accessories = list(/obj/item/clothing/accessory/solgov/department/security/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/fleet/officer/medical
	accessories = list(/obj/item/clothing/accessory/solgov/department/medical/fleet)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/scga/utility/marine
	name = "utility uniform, SCGMC"
	desc = "A green, durable utility jumpsuit. Belonging to the SCGMC uniform"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/scga/utility/tan/marine
	name = "tan utility uniform, SCGMC"
	desc = "A tan, durable utility jumpsuit. Belonging to the SCGMC uniform"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/scga/utility/urban/marine
	name = "urban utility uniform, SCGMC"
	desc = "An urban, durable utility jumpsuit. Belonging to the SCGMC uniform"
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

//Service

/obj/item/clothing/under/solgov/service
	name = "service uniform"
	desc = "A service uniform of some kind."
	icon_state = "whiteservice"
	worn_state = "whiteservice"
	siemens_coefficient = 0.9

/obj/item/clothing/under/solgov/service/fleet
	name = "fleet service uniform"
	desc = "The service uniform of the SCG Fleet, made from immaculate white fabric."
	icon_state = "whiteservice"
	item_state = "nursesuit"
	worn_state = "whiteservice"
	accessories = list(/obj/item/clothing/accessory/navy)

/obj/item/clothing/under/solgov/service/fleet/skirt
	name = "fleet service skirt"
	desc = "The service uniform skirt of the SCG Fleet, made from immaculate white fabric."
	icon_state = "whiteservicefem"
	worn_state = "whiteservicefem"
	leg_remap_category = CLOTHING_LEG_CATEGORY_SKIRT

/obj/item/clothing/under/scga/service/marine
	name = "service uniform, SCGMC"
	desc = "A slimming brown service shirt and green pants. Belonging to the solar marine corps service uniform."

/obj/item/clothing/under/scga/service/skirt/marine
	name = "service skirt uniform, SCGMC"
	desc = "A slimming brown service shirt and green skirt. Belonging to the solar marine corps service uniform."
	worn_state = "under_service_skirt_worn"
	leg_remap_category = CLOTHING_LEG_CATEGORY_SKIRT

/obj/item/clothing/under/scga/service_command/marine
	name = "service uniform, SCGMC"
	desc = "A slimming brown service shirt and green pants with beige streaks, for senior officers. Belonging to the solar marine corps command service uniform."

/obj/item/clothing/under/scga/service_command/skirt/marine
	name = "service skirt uniform, SCGA"
	desc = "A slimming brown service shirt and green skirt with beige streaks, for senior officers. Belonging to the solar marine corps command service uniform."
	icon_state = "under_command_skirt"
	worn_state = "under_command_skirt_worn"
	leg_remap_category = CLOTHING_LEG_CATEGORY_SKIRT
	item_state_slots = list(
		slot_l_hand_str = "under_command_skirt_held_l",
		slot_r_hand_str = "under_command_skirt_held_r",
		slot_w_uniform_str = "under_command_skirt_worn"
	)

//Dress
/obj/item/clothing/under/solgov/mildress
	name = "dress uniform"
	desc = "A dress uniform of some kind."
	icon_state = "greydress"
	worn_state = "greydress"
	siemens_coefficient = 0.9


//dress

/obj/item/clothing/under/solgov/dress/expeditionary
	name = "expeditionary dress uniform"
	desc = "The dress uniform of the SCG Expeditionary Corps in silver trim."
	icon_state = "greydress"
	worn_state = "greydress"

/obj/item/clothing/under/solgov/dress/expeditionary/engineering
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/security
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/medical
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/supply
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/service
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/exploration
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/research
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/skirt
	name = "expeditionary dress skirt"
	desc = "A feminine version of the SCG Expeditionary Corps dress uniform in silver trim."
	icon_state = "greydressfem"
	worn_state = "greydressfem"
	leg_remap_category = null // skirt-shaped

/obj/item/clothing/under/solgov/dress/expeditionary/skirt/engineering
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/skirt/security
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/skirt/medical
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/skirt/supply
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/skirt/service
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/skirt/exploration
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/skirt/research
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command
	name = "expeditionary officer's dress uniform"
	desc = "The dress uniform of the SCG Expeditionary Corps in gold trim."
	icon_state = "greydress_com"
	worn_state = "greydress_com"

/obj/item/clothing/under/solgov/dress/expeditionary/command/engineering
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/security
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/medical
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/supply
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/service
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/exploration
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/research
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt
	name = "expeditionary officer's dress skirt"
	desc = "A feminine version of the SCG Expeditionary Corps dress uniform in gold trim."
	icon_state = "greydressfem_com"
	worn_state = "greydressfem_com"

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt/engineering
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt/security
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt/medical
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt/supply
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt/service
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt/exploration
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/dress/expeditionary/command/skirt/research
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/scga/dress/marine
	name = "dress uniform, SCGMC"
	desc = "A classy brown shirt and black dress pants. Part of the solar marine corps dress uniform."

/obj/item/clothing/under/scga/dress/skirt/marine
	name = "dress skirt uniform, SCGMC"
	desc = "A classy brown shirt and black dress skirt. Part of the solar marine corps dress uniform."

/obj/item/clothing/under/scga/dress_command/marine
	name = "dress uniform, SCGMC"
	desc = "A classy brown shirt and black dress pants with gold streaks, for senior officers. Part of the solar marine corps command dress uniform."
	icon_state = "under_dress_command"
	item_state_slots = list(
		slot_l_hand_str = "under_dress_command_held_l",
		slot_r_hand_str = "under_dress_command_held_r",
		slot_w_uniform_str = "under_dress_command_worn"
	)

/obj/item/clothing/under/scga/dress_command/skirt/marine
	name = "dress skirt uniform, SCGMC"
	desc = "A classy brown shirt and black dress skirt with gold streaks, for senior officers. Part of the solar marine corps command dress uniform."

//misc garbage
/obj/item/clothing/under/rank/internalaffairs/plain/solgov
	desc = "A plain shirt and pair of pressed black pants."
	name = "formal outfit"
	accessories = list(/obj/item/clothing/accessory/blue_clip)
	item_flags = ITEM_FLAG_WASHER_ALLOWED | ITEM_FLAG_INVALID_FOR_CHAMELEON

/obj/item/clothing/under/solgov/utility/expeditionary/monkey
	name = "adjusted expeditionary uniform"
	desc = "The utility uniform of the SCG Expeditionary Corps, made from biohazard resistant material. This one has silver trim. It was also mangled to fit a monkey. This better be worth the NJP you'll get for making it."
	species_restricted = list(SPECIES_MONKEY)
	sprite_sheets = list("Monkey" = 'icons/mob/species/monkey/onmob_under_monkey.dmi')
	accessories = list(/obj/item/clothing/accessory/solgov/rank/fleet/officer/wo1_monkey)
