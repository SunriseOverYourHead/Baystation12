import { Box, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  integrity_percentage: number;
  ambient_temp: number;
  ambient_pressure: number;
  energy: number;
  detonating: BooleanLike;
};

export const SupermatterCrystal = (props) => {
  const { data } = useBackend<Data>();
  const { integrity_percentage, ambient_temp, ambient_pressure, energy, detonating } =
    data;

  if (detonating) {
    return (
      <Window title="Supermatter Crystal" width={500} height={300}>
        <Window.Content>
          <Section>
            <Box bold color="bad" fontSize="1.5em" textAlign="center">
              CRYSTAL DELAMINATING
            </Box>
            <Box bold textAlign="center">
              Evacuate area immediately
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const integrityColor =
    integrity_percentage >= 90
      ? 'good'
      : integrity_percentage >= 25
        ? 'average'
        : 'bad';

  const tempColor =
    ambient_temp >= 5000
      ? 'bad'
      : ambient_temp >= 4000
        ? 'average'
        : 'good';

  return (
    <Window title="Supermatter Crystal" width={500} height={300}>
      <Window.Content>
        <Section title="Crystal Integrity">
          <ProgressBar value={integrity_percentage / 100} color={integrityColor} />
          &nbsp;<b>{integrity_percentage} %</b>
        </Section>
        <Section title="Environment">
          <LabeledList>
            <LabeledList.Item label="Temperature">
              <ProgressBar value={ambient_temp / 10000} color={tempColor} />
              &nbsp;{ambient_temp} K
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              {ambient_pressure} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Relative EER">
              {energy}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
