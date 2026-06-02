/obj/structure/closet/secure_closet/infantry
	name = "rifleman's locker"
	req_access = list(access_rifleman)
	closet_appearance = /singleton/closet_appearance/secure_closet/infantry

/obj/structure/closet/secure_closet/infantry/WillContain()
	return list(
		/obj/item/clothing/suit/armor/pcarrier/medium/security,
		/obj/item/clothing/head/helmet/solgov/infantry,
		/obj/item/device/radio/headset/infantry,
		/obj/item/device/radio/headset/infantry/alt,
		/obj/item/storage/belt/security/infantry,
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/clothing/gloves/thick,
		/obj/item/material/knife/folding/swiss/infantry,
	)

/obj/structure/closet/secure_closet/infantry/comtech
	name = "combat technician's locker"
	req_access = list(access_rifleman, access_comtech)
	closet_appearance = /singleton/closet_appearance/secure_closet/infantry/comtech

/obj/structure/closet/secure_closet/infantry/comtech/WillContain()
	return list(
		/obj/item/clothing/suit/armor/pcarrier/medium/security,
		/obj/item/clothing/head/helmet/solgov/infantry,
		/obj/item/device/radio/headset/infantry/comtech,
		/obj/item/device/radio/headset/infantry/comtech/alt,
		/obj/item/storage/belt/security/infantry,
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/clothing/gloves/thick,
		/obj/item/material/knife/folding/swiss/infantry,
	)

/obj/structure/closet/secure_closet/infantry/ftl
	name = "fire team leader's locker"
	req_access = list(access_rifleman, access_ftlead)
	closet_appearance = /singleton/closet_appearance/secure_closet/infantry/ftl

/obj/structure/closet/secure_closet/infantry/ftl/WillContain()
	return list(
		/obj/item/clothing/suit/armor/pcarrier/medium/security,
		/obj/item/clothing/head/helmet/solgov/infantry,
		/obj/item/device/radio/headset/infantry/lead,
		/obj/item/device/radio/headset/infantry/lead/alt,
		/obj/item/storage/belt/security/infantry,
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/clothing/gloves/thick,
		/obj/item/material/knife/folding/swiss/infantry,
	)

/obj/structure/closet/secure_closet/infantry/squadlead
	name = "squad lead's locker"
	req_access = list(access_rifleman, access_squadlead)
	closet_appearance = /singleton/closet_appearance/secure_closet/infantry/squadlead

/obj/structure/closet/secure_closet/infantry/squadlead/WillContain()
	return list(
		/obj/item/clothing/suit/armor/pcarrier/medium/security,
		/obj/item/clothing/head/helmet/solgov/infantry,
		/obj/item/device/radio/headset/infantry/lead,
		/obj/item/device/radio/headset/infantry/lead/alt,
		/obj/item/storage/belt/security/infantry,
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/clothing/gloves/thick,
		/obj/item/material/knife/folding/swiss/infantry,
	)

/obj/structure/closet/secure_closet/infantry/platoon
	name = "platoon officer's locker"
	req_access = list(access_rifleman, access_platoon)
	closet_appearance = /singleton/closet_appearance/secure_closet/infantry/platoon

/obj/structure/closet/secure_closet/infantry/platoon/WillContain()
	return list(
		/obj/item/clothing/suit/armor/pcarrier/medium/command/security,
		/obj/item/clothing/head/helmet/solgov/command,
		/obj/item/clothing/suit/armor/pcarrier/medium/security,
		/obj/item/clothing/head/helmet/solgov/infantry,
		/obj/item/device/radio/headset/heads/po/,
		/obj/item/device/radio/headset/heads/po/alt,
		/obj/item/storage/belt/security/infantry,
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/clothing/gloves/thick,
		/obj/item/material/knife/folding/swiss/officer,
		/obj/item/device/megaphone,
		/obj/item/melee/telebaton,
		/obj/item/material/folder/clipboard,
		/obj/item/material/folder/red,
	)
