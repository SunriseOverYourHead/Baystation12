/singleton/hierarchy/outfit/job/torch/crew/infantry
	name = OUTFIT_JOB_NAME("Rifleman")
	uniform = /obj/item/clothing/under/scga/utility/marine
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = /obj/item/device/radio/headset/infantry
	id_types = list(/obj/item/card/id/torch/crew/infantry)

/singleton/hierarchy/outfit/job/torch/crew/infantry/New()
	..()
	BACKPACK_OVERRIDE_COMMAND

/singleton/hierarchy/outfit/job/torch/crew/infantry/firelead
	name = OUTFIT_JOB_NAME("Fireteam Leader")
	uniform = /obj/item/clothing/under/scga/utility/marine
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = /obj/item/device/radio/headset/infantry
	id_types = list(/obj/item/card/id/torch/crew/infantry/firelead)

/singleton/hierarchy/outfit/job/torch/crew/infantry/firelead/New()
	..()
	BACKPACK_OVERRIDE_COMMAND

/singleton/hierarchy/outfit/job/torch/crew/command/po
	name = OUTFIT_JOB_NAME("Platoon Officer")
	uniform = /obj/item/clothing/under/scga/utility/marine
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = /obj/item/device/radio/headset/heads/po/
	id_types = list(/obj/item/card/id/torch/silver/po)

/singleton/hierarchy/outfit/job/torch/crew/infantry/po/New()
	..()
	BACKPACK_OVERRIDE_COMMAND

/singleton/hierarchy/outfit/job/torch/crew/infantry/squadlead
	name = OUTFIT_JOB_NAME("Squad Leader")
	uniform = /obj/item/clothing/under/scga/utility/marine
	id_types = list(/obj/item/card/id/torch/crew/infantry/squadlead)
	l_ear = /obj/item/device/radio/headset/infantry

/singleton/hierarchy/outfit/job/torch/crew/infantry/squadlead/New()
	..()
	BACKPACK_OVERRIDE_COMMAND

/singleton/hierarchy/outfit/job/torch/crew/infantry/comtech
	name = OUTFIT_JOB_NAME("Combat Technician")
	uniform = /obj/item/clothing/under/scga/utility/marine
	id_types = list(/obj/item/card/id/torch/crew/infantry/comtech)
	pda_type = /obj/item/modular_computer/pda/engineering
	l_ear = /obj/item/device/radio/headset/infantry/comtech/

/singleton/hierarchy/outfit/job/torch/crew/infantry/comtech/New()
	..()
	BACKPACK_OVERRIDE_COMMAND
