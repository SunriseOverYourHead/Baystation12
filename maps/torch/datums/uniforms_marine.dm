/singleton/hierarchy/mil_uniform
	var/utility_under_urban = null
	var/utility_under_tan = null
	var/utility_under_green = null
	var/utility_hat_urban = null
	var/utility_hat_tan = null
	var/utility_hat_green = null

/singleton/hierarchy/mil_uniform/marine_corps
	name = "Master marine corps outfit"
	hierarchy_type = /singleton/hierarchy/mil_uniform/marine_corps
	branches = list(/datum/mil_branch/marine_corps)

	pt_under = /obj/item/clothing/under/scga/pt/solgov
	pt_shoes = /obj/item/clothing/shoes/black

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_shoes = /obj/item/clothing/shoes/dutyboots
	utility_hat_urban = /obj/item/clothing/head/scga/utility/urban/marine
	utility_hat_tan = /obj/item/clothing/head/scga/utility/tan/marine
	utility_hat_green = /obj/item/clothing/head/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov
	)

	service_under = /obj/item/clothing/under/scga/service/marine
	service_skirt = /obj/item/clothing/under/scga/service/skirt/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_shoes = /obj/item/clothing/shoes/dress
	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine)

	dress_under = /obj/item/clothing/under/scga/dress/marine
	dress_skirt =/obj/item/clothing/under/scga/dress/skirt/marine
	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_shoes = /obj/item/clothing/shoes/dress
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_gloves = /obj/item/clothing/gloves/white

	dress_extra = list(/obj/item/clothing/head/beret/solgov)

/singleton/hierarchy/mil_uniform/marine_corps/com //Can only be officers
	name = "Marine Corps command"
	departments = COM

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/cmd
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov)

/singleton/hierarchy/mil_uniform/marine_corps/com/seniorofficer
	name = "Marine Corps senior command"
	min_rank = 15

	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	dress_over = /obj/item/clothing/suit/dress/solgov/army

/singleton/hierarchy/mil_uniform/marine_corps/eng
	name = "Marine Corps engineering"
	departments = ENG

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/eng
	)

/singleton/hierarchy/mil_uniform/marine_corps/eng/noncom
	name = "Marine Corps engineering NCO"
	min_rank = 4

	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_extra = list(/obj/item/material/sword/replica/officersword/scga)

/singleton/hierarchy/mil_uniform/marine_corps/eng/officer
	name = "Marine Corps engineering CO"
	min_rank = 11

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/eng
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/eng/officer/com //Can only be officers
	name = "Marine Corps engineering command"
	departments = ENG|COM

/singleton/hierarchy/mil_uniform/marine_corps/eng/officer/com/seniorofficer
	name = "Marine Corps engineering senior command"
	min_rank = 15

	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	dress_over = /obj/item/clothing/suit/dress/solgov/army

/singleton/hierarchy/mil_uniform/marine_corps/sec
	name = "Marine Corps security"
	departments = SEC

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/sec,
		/obj/item/clothing/under/scga/utility/marine)

/singleton/hierarchy/mil_uniform/marine_corps/sec/noncom
	name = "Marine Corps security NCO"
	min_rank = 4

	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine, /obj/item/clothing/head/scga/dress/garrison/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_extra = list(/obj/item/material/sword/replica/officersword/scga)

/singleton/hierarchy/mil_uniform/marine_corps/sec/officer
	name = "Marine Corps security CO"
	min_rank = 11

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/sec
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/sec/officer/com //Can only be officers
	name = "Marine Corps security command"
	departments = SEC|COM

/singleton/hierarchy/mil_uniform/marine_corps/sec/officer/com/seniorofficer
	name = "Marine Corps security senior command"
	min_rank = 15

	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	dress_over = /obj/item/clothing/suit/dress/solgov/army

/singleton/hierarchy/mil_uniform/marine_corps/med
	name = "Marine Corps medical"
	departments = MED

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/med
	)

/singleton/hierarchy/mil_uniform/marine_corps/med/noncom
	name = "Marine Corps medical NCO"
	min_rank = 4

	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_extra = list(/obj/item/material/sword/replica/officersword/scga)

/singleton/hierarchy/mil_uniform/marine_corps/med/officer
	name = "Marine Corps medical CO"
	min_rank = 11

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/med
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/med/officer/com //Can only be officers
	name = "Marine Corps medical command"
	departments = MED|COM

/singleton/hierarchy/mil_uniform/marine_corps/med/officer/com/seniorofficer
	name = "Marine Corps medical senior command"
	min_rank = 15

	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	dress_over = /obj/item/clothing/suit/dress/solgov/army

/singleton/hierarchy/mil_uniform/marine_corps/sup
	name = "Marine Corps supply"
	departments = SUP

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/sup
	)

/singleton/hierarchy/mil_uniform/marine_corps/sup/noncom
	name = "Marine Corps supply NCO"
	min_rank = 4

	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_extra = list(/obj/item/material/sword/replica/officersword/scga)

/singleton/hierarchy/mil_uniform/marine_corps/sup/officer
	name = "Marine Corps supply CO"
	min_rank = 11

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/sup
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/sup/seniorofficer
	name = "Marine Corps supply senior command"
	min_rank = 15

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/srv
	name = "Marine Corps service"
	departments = SRV

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/svc
	)

/singleton/hierarchy/mil_uniform/marine_corps/srv/noncom
	name = "Marine Corps service NCO"
	min_rank = 4

	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_extra = list(/obj/item/material/sword/replica/officersword/scga)

/singleton/hierarchy/mil_uniform/marine_corps/srv/officer
	name = "Marine Corps service CO"
	min_rank = 11

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/svc
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/exp
	name = "Marine Corps exploration"
	departments = INF

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine
	utility_extra = list(
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/exp
	)

/singleton/hierarchy/mil_uniform/marine_corps/exp/noncom
	name = "Marine Corps exploration NCO"
	min_rank = 4

	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_extra = list(/obj/item/material/sword/replica/officersword/scga)

/singleton/hierarchy/mil_uniform/marine_corps/exp/officer
	name = "Marine Corps exploration CO"
	min_rank = 11

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/exp
	)

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/spt
	name = "Marine Corps command support"
	departments = SPT

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine

/singleton/hierarchy/mil_uniform/marine_corps/spt/noncom
	name = "Marine Corps support NCO"
	min_rank = 4

	service_hat = /obj/item/clothing/head/scga/service/wheel/marine
	service_over = /obj/item/clothing/suit/scga/service/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison/marine, /obj/item/clothing/head/scga/dress/garrison/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_extra = list(/obj/item/material/sword/replica/officersword/scga)

/singleton/hierarchy/mil_uniform/marine_corps/spt/officer
	name = "Marine Corps command support CO"
	min_rank = 11

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/cmd
	)

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine
	service_extra = list(/obj/item/clothing/head/scga/service/garrison_officer/marine)

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)

/singleton/hierarchy/mil_uniform/marine_corps/spt/seniorofficer
	name = "Marine Corps senior command support"
	min_rank = 15

	utility_extra = list(
		/obj/item/clothing/under/scga/utility/marine,
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/head/scga/utility/ushanka/marine,
		/obj/item/clothing/head/scga/utility/ushanka/green/marine,
		/obj/item/clothing/suit/scga/hooded/wintercoat/marine,
		/obj/item/clothing/head/soft/solgov,
		/obj/item/clothing/gloves/thick/duty/solgov/cmd
	)

	utility_under_urban = /obj/item/clothing/under/scga/utility/urban/marine
	utility_under_tan = /obj/item/clothing/under/scga/utility/tan/marine
	utility_under_green = /obj/item/clothing/under/scga/utility/marine

	service_hat = /obj/item/clothing/head/scga/service/wheel_command/marine
	service_over = /obj/item/clothing/suit/scga/service_officer/marine

	dress_over = /obj/item/clothing/suit/dress/solgov/army
	dress_hat = /obj/item/clothing/head/scga/dress/garrison/marine
	dress_extra = list(/obj/item/clothing/head/beret/solgov, /obj/item/material/sword/replica/officersword/scga/officer)
