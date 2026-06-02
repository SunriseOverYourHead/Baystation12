import { NumberInput } from 'tgui-core/components';

import type { Feature, FeatureNumericData, FeatureValueProps } from '../base';

function AgeNumberInput(
  props: FeatureValueProps<number, number, FeatureNumericData>,
) {
  const { serverData, handleSetValue, value } = props;
  return (
    <NumberInput
      onMouseDown={(e) => e.stopPropagation()}
      onChange={(value) => handleSetValue(value)}
      disabled={!serverData}
      minValue={serverData?.minimum || 0}
      maxValue={serverData?.maximum || 100}
      step={serverData?.step || 1}
      value={value}
    />
  );
}

export const age: Feature<number> = {
  name: 'Age',
  description:
    'Physical age represents how far your character has grown physically and mentally.',
  component: AgeNumberInput,
};
