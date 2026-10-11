import { Box, NumberInput, Tooltip } from 'tgui-core/components';

import type { Feature, FeatureNumericData, FeatureValueProps } from '../base';

type AgeFeatureData = FeatureNumericData & {
  human_equivalent: number;
};

function AgeNumberInput(
  props: FeatureValueProps<number, number, AgeFeatureData>,
) {
  const { serverData, handleSetValue, value } = props;
  return (
    <Box>
      <NumberInput
        onMouseDown={(e) => e.stopPropagation()}
        onChange={(value) => handleSetValue(value)}
        disabled={!serverData}
        minValue={serverData?.minimum || 0}
        maxValue={serverData?.maximum || 100}
        step={serverData?.step || 1}
        value={value}
      />
      {serverData && (
        <Tooltip content="Read-only -- how old this age would be for a human, mapped from your species' own age range. Species can never be played below a human-equivalent age of 18.">
          <Box inline ml={1} color="label">
            Human Equivalent: {serverData.human_equivalent}
          </Box>
        </Tooltip>
      )}
    </Box>
  );
}

export const age: Feature<number> = {
  name: 'Age',
  description:
    'Physical age represents how far your character has grown physically and mentally.',
  component: AgeNumberInput,
};
