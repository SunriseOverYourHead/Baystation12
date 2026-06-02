// BS12-specific character features not present in Nova's feature registry.
// Each export key matches the preference ID sent in secondary_features/non_contextual.

import {
  type Feature,
  type FeatureChoiced,
  type FeatureChoicedServerData,
  CheckboxInput,
  type FeatureNumericData,
  FeatureShortTextInput,
  FeatureSliderInput,
  type FeatureToggle,
  type FeatureValueProps,
} from '../base';

type FeatureShortTextData = { maximum_length: number };
import { FeatureDropdownInput } from '../dropdowns';

// Hair style selector — choices provided by server per species
export const head_hair_style: FeatureChoiced = {
  name: 'Hair style',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => <FeatureDropdownInput buttons {...props} />,
};

// Facial hair style selector — choices provided by server per species+gender
export const facial_hair_style: FeatureChoiced = {
  name: 'Facial hair style',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => <FeatureDropdownInput buttons {...props} />,
};

// Blood type dropdown — fixed list
export const blood_type: FeatureChoiced = {
  name: 'Blood type',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => <FeatureDropdownInput {...props} />,
};

// Pronouns dropdown — choices provided by server per species
export const pronouns: FeatureChoiced = {
  name: 'Pronouns',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => <FeatureDropdownInput {...props} />,
};

// Base skin colour dropdown — choices provided by server per species
export const base_skin: FeatureChoiced = {
  name: 'Base skin',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => <FeatureDropdownInput {...props} />,
};

// Nearsighted checkbox — maps to NEARSIGHTED disability flag
export const nearsighted: FeatureToggle = {
  name: 'Nearsighted',
  description: 'Your character requires glasses to see clearly.',
  component: CheckboxInput,
};

// Numeric skin tone slider — range/step provided by server per species.
// Using key "bs12_skin_tone" to avoid conflicting with Nova's skin_tone component.
export const bs12_skin_tone: Feature<number, number, FeatureNumericData> = {
  name: 'Skin tone',
  component: FeatureSliderInput,
};

// OOC notes / metadata text field
export const metadata: Feature<string, string, FeatureShortTextData> = {
  name: 'OOC notes',
  description: 'Out-of-character notes visible to other players who examine you.',
  component: (
    props: FeatureValueProps<string, string, FeatureShortTextData>,
  ) => <FeatureShortTextInput {...props} />,
};

// Spawn point dropdown
export const spawnpoint: FeatureChoiced = {
  name: 'Spawn Point',
  description: 'Where your character spawns at round start.',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => <FeatureDropdownInput {...props} />,
};
