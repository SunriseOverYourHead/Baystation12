/// List (string => integer). Map of descriptive words to the age threshhold to display these words. Age threshhold is the _highest_ age that can use this descriptor. Descriptors should make grammatical sense when used in the following sentence: "They are of [X] age for a [species]."
/singleton/species/var/list/age_descriptors = list(
	"very young" = 20,
	"young" = 40,
	"moderate" = 60,
	"old" = 80,
	"very old" = 100,
	"ancient" = INFINITY
)


/// List (string => integer). Map of descriptive words to the age different threshhold to display these words. Age difference threshhold is the _highest_ number that can use this descriptor. Descriptors should make grammatical sence when used in the following sentence: "They are [X] you."
/singleton/species/var/list/age_diff_descriptors = list(
	"much younger than" = -15,
	"younger than" = -10,
	"slightly younger than" = -5,
	"around the same age as" = 5,
	"slightly older than" = 10,
	"older than" = 15,
	"much older than" = INFINITY
)


/// Boolean. If set, allows other species to see age descriptions.
/singleton/species/var/show_age_to_other_species = FALSE


/// Maps a raw age onto its "human equivalent" for display next to the Age slider (Character Setup). A var (not a
/// per-subtype proc override) so it composes cleanly with inheritance -- Kharmaan Gyne, for instance, needs to
/// fall back to "linear" even though its parent Alate uses "quadruple", which a plain proc override can't express
/// without literally duplicating the base formula.
/// "linear" (default): stretches this species' own min_age-max_age range onto 18-75, always rounding up --
///   anchoring the low end to exactly 18 means the ">= 18" requirement holds automatically, no separate clamp
///   needed. Used by anyone not called out below (Skrell, Unathi, Vox, Kharmaan Gyne, ...).
/// "identity": human_equivalent = raw_age, unscaled (Human/Anthro/Teshari -- ages exactly like a human already).
/// "offset18": human_equivalent = raw_age + 18 (Machine/IPC -- a freshly manufactured chassis is 0, immediately a
///   legal adult).
/// "quadruple": human_equivalent = raw_age * 4 (Kharmaan Alate -- ages noticeably faster than a human).
/// "constant": always human_equivalent_age_constant, ignoring raw_age entirely (Diona -- plants, don't age like
///   an animal does).
/// "two_point": a straight line through two explicit (raw_age, human_equivalent) anchor points -- unlike "linear"
///   above, neither anchor has to be this species' own min_age, and the low anchor doesn't have to land on 18.
///   GAS: a 5-year-old (their min_age) is 20, but by 40 (their max_age) they're 75 -- a steeper-than-"linear"
///   slope that "quadruple" can't express either (5*4=20 checks out, but 40*4=160, not 75).
/singleton/species/var/human_equivalent_age_formula = "linear"
/singleton/species/var/human_equivalent_age_constant = 20
/singleton/species/var/human_equivalent_age_point1_raw = 0
/singleton/species/var/human_equivalent_age_point1_human = 18
/singleton/species/var/human_equivalent_age_point2_raw = 70
/singleton/species/var/human_equivalent_age_point2_human = 75

/singleton/species/proc/get_human_equivalent_age(raw_age)
	switch(human_equivalent_age_formula)
		if("identity")
			return raw_age
		if("offset18")
			return raw_age + 18
		if("quadruple")
			return raw_age * 4
		if("constant")
			return human_equivalent_age_constant
		if("two_point")
			if(human_equivalent_age_point2_raw <= human_equivalent_age_point1_raw)
				return human_equivalent_age_point1_human
			var/t = (raw_age - human_equivalent_age_point1_raw) / (human_equivalent_age_point2_raw - human_equivalent_age_point1_raw)
			return -round(-(human_equivalent_age_point1_human + t * (human_equivalent_age_point2_human - human_equivalent_age_point1_human)))
	// "linear"
	if(max_age <= min_age)
		return 18
	var/fraction = (raw_age - min_age) / (max_age - min_age)
	return -round(-(18 + fraction * (75 - 18)))

/singleton/species/proc/get_age_comparison_string(mob/living/carbon/human/observed, mob/living/carbon/human/observer)
	if (!age_descriptors || !age_diff_descriptors || !istype(observed) || observed.isSynthetic())
		return
	if (!show_age_to_other_species && name != observer.get_species())
		return

	var/observed_real_age = observed.age + observed.changed_age
	var/age_percentile = round((observed_real_age / max_age) * 100)
	var/age_descriptor
	var/age_diff_descriptor

	for (var/descriptor in age_descriptors)
		if (age_percentile > age_descriptors[descriptor])
			continue
		age_descriptor = descriptor
		break
	if (!age_descriptor)
		age_descriptor = age_descriptors[length(age_descriptors)]

	if (istype(observer) && observed.get_species() == observer.get_species() && !observer.isSynthetic())
		var/observer_real_age = observer.age + observer.changed_age
		var/age_diff = observed_real_age - observer_real_age
		for (var/descriptor in age_diff_descriptors)
			if (age_diff > age_diff_descriptors[descriptor])
				continue
			age_diff_descriptor = descriptor
			break
		if (!age_diff_descriptor)
			age_diff_descriptor = age_diff_descriptors[length(age_diff_descriptors)]

	if (observer == observed)
		return "You are of [age_descriptor] age for \a [name]."

	var/datum/pronouns/pronouns = observed.choose_from_pronouns()
	if (age_diff_descriptor)
		return "[pronouns.He] [pronouns.is] of [age_descriptor] age for \a [name], [age_diff_descriptor] you."
	else if (age_descriptor)
		return "[pronouns.He] [pronouns.is] of [age_descriptor] age for \a [name]."
