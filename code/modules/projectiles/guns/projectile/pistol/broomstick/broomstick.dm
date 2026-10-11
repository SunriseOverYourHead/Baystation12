/obj/item/gun/projectile/pistol/broomstick
	name = "broomstick"
	desc = "An antique gun that makes you want to yell 'IT BELONGS IN A MUSEUM!'. There appears to be some thing scratched next to the fireselector, though you cant make it out."
	icon = 'code/modules/projectiles/guns/projectile/pistol/broomstick/broomstick.dmi'
	icon_state = "broomstick"
	accuracy_power = 6
	one_hand_penalty = 3
	fire_delay = 5
	caliber = PROJECTILE_PISTOL_SMALL
	origin_tech = list(
						TECH_COMBAT = 2,
						TECH_MATERIAL = 2
						)
	load_method = SINGLE_CASING|SPEEDLOADER
	max_shells = 10

	firemodes = list(
		list(
			"mode_name" = "semi auto",
			"burst" = 1,
			"fire_delay" = 5,
			"move_delay" = null,
			"one_hand_penalty" = 3,
			"burst_accuracy" = null,
			"dispersion" = null
		),
		list(
			"mode_name" = "scratched out option",
			"burst" = 10,
			"fire_delay" = 1,
			"one_hand_penalty" = 8,
			"burst_accuracy" = list(0, -1, -2, -3, -4, -4, -4, -4, -4),
			"dispersion" = list(1.0, 1.0, 1.0, 1.0, 1.2)
		)
	)
