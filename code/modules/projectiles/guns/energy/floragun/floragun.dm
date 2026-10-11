/obj/item/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon = 'code/modules/projectiles/guns/energy/floragun/floragun.dmi'
	icon_state = "floramut100"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_guns.dmi',
	)
	colocated_sprites = FALSE
	item_state = "floramut"
	charge_cost = 10
	max_shots = 10
	projectile_type = /obj/item/projectile/energy/floramut
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 3, TECH_POWER = 3)
	modifystate = "floramut"
	self_recharge = 1
	var/singleton/plantgene/gene = null
	combustion = 0

	firemodes = list(
		list(
			"mode_name" = "induce mutations",
			"projectile_type" = /obj/item/projectile/energy/floramut,
			"modifystate" = "floramut"
		),
		list(
			"mode_name" = "increase yield",
			"projectile_type" = /obj/item/projectile/energy/florayield,
			"modifystate" = "florayield"
		),
		list(
			"mode_name" = "induce specific mutations",
			"projectile_type" = /obj/item/projectile/energy/floramut/gene,
			"modifystate" = "floramut"
		)
	)

/obj/item/gun/energy/floragun/use_before(atom/target, mob/living/user, click_parameters)
	if (!istype(target, /obj/machinery/portable_atmospherics/hydroponics))
		return FALSE

	user.visible_message(SPAN_DANGER("\The [user] fires \the [src] into \the [target]!"))
	Fire(target,user)
	return TRUE

/obj/item/gun/energy/floragun/verb/select_gene()
	set name = "Select Gene"
	set category = "Object"
	set src in view(1)

	var/genemask = input("Choose a gene to modify.") as null|anything in SSplants.plant_gene_datums

	if(!genemask)
		return

	gene = SSplants.plant_gene_datums[genemask]

	to_chat(usr, SPAN_INFO("You set the [src]'s targeted genetic area to [genemask]."))

	return

/obj/item/gun/energy/floragun/consume_next_projectile()
	. = ..()
	var/obj/item/projectile/energy/floramut/gene/G = .
	if(istype(G))
		G.gene = gene
