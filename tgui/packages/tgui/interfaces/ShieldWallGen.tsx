import { Box, Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  draw: number;
  power: number;
  maxpower: number;
  current_draw: number;
  online: BooleanLike;
};

export const ShieldWallGen = () => {
  const { act, data } = useBackend<Data>();
  const { draw, power, maxpower, current_draw, online } = data;

  return (
    <Window title="Shield Generator" width={400} height={200}>
      <Window.Content>
        <Section title="Power Status">
          <LabeledList>
            <LabeledList.Item label="Stored Power">
              <ProgressBar
                value={power}
                maxValue={maxpower}
                ranges={{
                  good: [maxpower * 0.75, maxpower],
                  average: [maxpower * 0.25, maxpower * 0.75],
                  bad: [0, maxpower * 0.25],
                }}
              >
                {power} / {maxpower} W
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Current Draw">
              <Box>{current_draw} W</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Max Draw">
              <Box>{draw} W</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Shield">
              <Button
                icon="power-off"
                selected={!!online}
                color={online ? 'good' : 'default'}
                onClick={() => act('toggle')}
              >
                {online ? 'Online' : 'Offline'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
