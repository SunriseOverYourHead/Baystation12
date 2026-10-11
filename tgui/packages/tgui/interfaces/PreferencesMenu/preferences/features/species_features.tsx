import {
  CheckboxInput,
  type Feature,
  type FeatureChoiced,
  type FeatureChoicedServerData,
  FeatureColorInput,
  type FeatureNumericData,
  FeatureSliderInput,
  type FeatureToggle,
  FeatureTriColorInput,
  FeatureTriColorInputWithSkinReset,
  type FeatureValueProps,
} from './base';
import { FeatureDropdownInput } from './dropdowns';

// One toggle per mutant-organ category (see get_mutant_category_meta()'s "toggle_key" in preferences_tgui.dm) --
// off by default, gates whether the character has the organ at all. The matching style/color rows (feature_lizard_
// tail/feature_mcolor etc, below) are only sent by the server -- and so only rendered -- while the toggle is on.
export const toggle_tail: FeatureToggle = {
  name: 'Tail',
  component: CheckboxInput,
};

export const toggle_horns: FeatureToggle = {
  name: 'Horns',
  component: CheckboxInput,
};

export const toggle_frills: FeatureToggle = {
  name: 'Frills',
  component: CheckboxInput,
};

export const toggle_spines: FeatureToggle = {
  name: 'Spines',
  component: CheckboxInput,
};

export const toggle_ears: FeatureToggle = {
  name: 'Ears',
  component: CheckboxInput,
};

export const toggle_xenodorsal: FeatureToggle = {
  name: 'Dorsal Spines',
  component: CheckboxInput,
};

export const toggle_xenohead: FeatureToggle = {
  name: 'Carapace Plating',
  component: CheckboxInput,
};

export const toggle_wings: FeatureToggle = {
  name: 'Wings',
  component: CheckboxInput,
};

export const toggle_snout: FeatureToggle = {
  name: 'Snout',
  component: CheckboxInput,
};

export const toggle_moth_antennae: FeatureToggle = {
  name: 'Antennae',
  component: CheckboxInput,
};

export const toggle_fluff: FeatureToggle = {
  name: 'Fluff',
  component: CheckboxInput,
};

export const toggle_breasts: FeatureToggle = {
  name: 'Breasts',
  component: CheckboxInput,
};

export const toggle_penis: FeatureToggle = {
  name: 'Penis',
  component: CheckboxInput,
};

export const toggle_testicles: FeatureToggle = {
  name: 'Testicles',
  component: CheckboxInput,
};

export const toggle_vagina: FeatureToggle = {
  name: 'Vagina',
  component: CheckboxInput,
};

// Anus has no shape/color dimension at all (no source art exists to pick a style of -- see mutant_anus.dm), so
// unlike its siblings above it gets ONLY this enable toggle, no matching feature_anus shape dropdown.
export const toggle_anus: FeatureToggle = {
  name: 'Anus',
  component: CheckboxInput,
};

export const eye_color: Feature<string> = {
  name: 'Eye color',
  component: FeatureColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: 'Facial hair color',
  component: FeatureColorInput,
};

export const facial_hair_gradient: FeatureChoiced = {
  name: 'Facial hair gradient',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const facial_hair_gradient_color: Feature<string> = {
  name: 'Facial hair gradient color',
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: 'Hair color',
  component: FeatureColorInput,
};

export const skin_color: Feature<string> = {
  name: 'Skin color',
  component: FeatureColorInput,
};

// /datum/mob_descriptor-backed features (code/modules/mob/living/carbon/human/descriptors/*.dm) -- server key is
// "bs12_desc_[descriptor's .name, sanitized via tgui_descriptor_key()]". This is a small, fixed, known set (every
// descriptor that currently exists across every species file), not dynamically generated, so static exports are
// fine here the same as everywhere else in this file.
export const bs12_desc_height: FeatureChoiced = {
  name: 'Height',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const bs12_desc_build: FeatureChoiced = {
  name: 'Build',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const bs12_desc_body_length: FeatureChoiced = {
  name: 'Body length',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const bs12_desc_headtail_length: FeatureChoiced = {
  name: 'Headtail length',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const bs12_desc_neck_markings: FeatureChoiced = {
  name: 'Neck markings',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const hair_gradient: FeatureChoiced = {
  name: 'Hair gradient',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const hair_gradient_color: Feature<string> = {
  name: 'Hair gradient color',
  component: FeatureColorInput,
};

export const feature_cat_ears: FeatureChoiced = {
  name: 'Ears',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_cat_tail: FeatureChoiced = {
  name: 'Tail',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_monkey_tail: FeatureChoiced = {
  name: 'Tail',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_lizard_legs: FeatureChoiced = {
  name: 'Legs',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_lizard_spines: FeatureChoiced = {
  name: 'Spines',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_lizard_tail: FeatureChoiced = {
  name: 'Tail',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_lizard_horns: FeatureChoiced = {
  name: 'Horns',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor2: Feature<string[]> = {
  name: 'Horns color',
  component: FeatureTriColorInput,
};

export const feature_lizard_frills: FeatureChoiced = {
  name: 'Frills',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor3: Feature<string[]> = {
  name: 'Frills color',
  component: FeatureTriColorInput,
};

export const feature_mcolor4: Feature<string[]> = {
  name: 'Spines color',
  component: FeatureTriColorInput,
};

export const feature_mcolor5: Feature<string[]> = {
  name: 'Ears color',
  component: FeatureTriColorInput,
};

export const feature_xenodorsal: FeatureChoiced = {
  name: 'Dorsal Spines',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor6: Feature<string[]> = {
  name: 'Dorsal Spines color',
  component: FeatureTriColorInput,
};

export const feature_xenohead: FeatureChoiced = {
  name: 'Carapace Plating',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor7: Feature<string[]> = {
  name: 'Carapace Plating color',
  component: FeatureTriColorInput,
};

export const feature_wings: FeatureChoiced = {
  name: 'Wings',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor8: Feature<string[]> = {
  name: 'Wings color',
  component: FeatureTriColorInput,
};

export const feature_snout: FeatureChoiced = {
  name: 'Snout',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor9: Feature<string[]> = {
  name: 'Snout color',
  component: FeatureTriColorInput,
};

export const feature_moth_antennae: FeatureChoiced = {
  name: 'Antennae',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor10: Feature<string[]> = {
  name: 'Antennae color',
  component: FeatureTriColorInput,
};

export const feature_fluff: FeatureChoiced = {
  name: 'Fluff',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor13: Feature<string[]> = {
  name: 'Fluff color',
  component: FeatureTriColorInput,
};

export const feature_breasts: FeatureChoiced = {
  name: 'Breasts',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor11: Feature<string[]> = {
  name: 'Breasts color',
  component: FeatureTriColorInputWithSkinReset,
};

export const size_breasts: Feature<number, number, FeatureNumericData> = {
  name: 'Breasts size',
  component: FeatureSliderInput,
};

export const feature_penis: FeatureChoiced = {
  name: 'Penis',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor12: Feature<string[]> = {
  name: 'Penis color',
  component: FeatureTriColorInput,
};

export const size_penis: Feature<number, number, FeatureNumericData> = {
  name: 'Penis size',
  component: FeatureSliderInput,
};

// P. Sheath -- a dedicated override (None/Sheath/Slit), not a shape choice; see preferences.dm's copy_to().
export const p_sheath: FeatureChoiced = {
  name: 'P. Sheath',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_testicles: FeatureChoiced = {
  name: 'Testicles',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor14: Feature<string[]> = {
  name: 'Testicles color',
  component: FeatureTriColorInputWithSkinReset,
};

export const size_testicles: Feature<number, number, FeatureNumericData> = {
  name: 'Testicles size',
  component: FeatureSliderInput,
};

export const feature_vagina: FeatureChoiced = {
  name: 'Vagina',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const feature_mcolor15: Feature<string[]> = {
  name: 'Vagina color',
  component: FeatureTriColorInput,
};

// Tail's own color override (was literally called "Mutant color" pre-migration; renamed to "Skin color" during
// an earlier pass, then hidden entirely whenever the species also had a species-wide skin_color swatch -- both
// steps undone here since that hid this picker for any species with skin_color, including tails/wings that want
// an independently-chosen color, not just a mirror of skin tone. Named "Tail color" now, matching the sibling
// mcolor2..8 categories' "<Category> color" naming) -- it still *defaults* to skin_color when nothing is picked
// (see get_mutant_category_meta()'s "fallback_var" for BP_TAIL in preferences_tgui.dm), it's just no longer hidden.
export const feature_mcolor: Feature<string[]> = {
  name: 'Tail color',
  component: FeatureTriColorInput,
};

export const underwear_color: Feature<string> = {
  name: 'Underwear color',
  component: FeatureColorInput,
};

export const bra_color: Feature<string> = {
  name: 'Bra color',
  component: FeatureColorInput,
};

export const feature_vampire_status: Feature<string> = {
  name: 'Vampire status',
  component: FeatureDropdownInput,
};

export const heterochromatic: Feature<string> = {
  name: 'Heterochromatic (Right Eye) color',
  component: FeatureColorInput,
};
