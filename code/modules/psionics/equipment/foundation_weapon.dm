/obj/item/gun/projectile/revolver/foundation
	name = "\improper Foundation revolver"
	icon = 'icons/obj/guns/foundation.dmi'
	icon_state = "foundation"
	item_icons = list(
		slot_l_hand_str = 'code/modules/projectiles/guns/projectile/revolver/revolver.dmi',
		slot_r_hand_str = 'code/modules/projectiles/guns/projectile/revolver/revolver.dmi',
	)
	colocated_sprites = FALSE
	item_state_slots = list(
		slot_l_hand_str = "revolver_l",
		slot_r_hand_str = "revolver_r",
	)
	desc = "The CF 'Troubleshooter', a compact plastic-composite weapon designed for concealed carry by Cuchulain Foundation field agents. Smells faintly of copper."
	ammo_type = /obj/item/ammo_casing/pistol/huge/nullglass

/obj/item/gun/projectile/revolver/foundation/disrupts_psionics()
	return FALSE

/obj/item/storage/briefcase/foundation
	name = "\improper Foundation briefcase"
	desc = "A handsome black leather briefcase embossed with a stylized radio telescope."
	icon_state = "fbriefcase"
	item_state = "fbriefcase"

/obj/item/storage/briefcase/foundation/disrupts_psionics()
	return FALSE

/obj/item/storage/briefcase/foundation/New()
	..()
	new /obj/item/ammo_magazine/speedloader/magnum/nullglass(src)
	new /obj/item/gun/projectile/revolver/foundation(src)
	make_exact_fit()
