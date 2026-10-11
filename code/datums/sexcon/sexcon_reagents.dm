// Ejaculation byproduct reagents, adapted from Ratwood-2.0-main's own code/datums/sexcon/sexcon_reagents.dm.
// Ratwood's versions are already trivial LIQUID reagents with no real metabolic effect beyond flavor/color -- ported
// near-verbatim. The aphrodisiac-multiplier reagent system is explicitly out of scope for this port (user request),
// so no reagent here adjusts arousal on its own; they exist purely as the physical byproduct /datum/sex_controller's
// ejaculate() proc creates.
/datum/reagent/erpjuice
	name = "Genetic Material"
	description = "A viscous, musky fluid."
	reagent_state = LIQUID
	color = "#e8e8e8"
	taste_description = "salt"
	metabolism = REM * 2

/datum/reagent/erpjuice/cum
	name = "Semen"
	description = "A thick, white fluid."
	color = "#f0f0f0"

/datum/reagent/erpjuice/femcum
	name = "Love Juice"
	description = "A clear, slick fluid."
	color = "#f5f0ff"
	taste_description = "sweetness"
