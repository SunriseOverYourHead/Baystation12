import { Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// State constants matching DM defines
const STATE_FILL = 1;
const STATE_EVACUATE = 2;
const STATE_SEALED = 3;

type Data = {
  chamber_pressure: number;
  door_safety: BooleanLike;
  state: number;
};

export const TinCan = () => {
  const { act, data } = useBackend<Data>();
  const { chamber_pressure, door_safety, state } = data;

  const pressureColor =
    chamber_pressure < 80 || chamber_pressure > 120
      ? 'bad'
      : chamber_pressure < 95 || chamber_pressure > 110
        ? 'average'
        : 'good';

  return (
    <Window title="Tin Can Controller" width={470} height={290}>
      <Window.Content>
        <Section title="Atmosphere">
          <LabeledList>
            <LabeledList.Item label="Internal Pressure">
              <ProgressBar
                value={chamber_pressure}
                minValue={0}
                maxValue={200}
                color={pressureColor}
              >
                {chamber_pressure} kPa
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Atmosphere Control">
          <Button
            selected={state === STATE_EVACUATE}
            onClick={() => act('command', { command: 'evacuate_atmos' })}
          >
            Purge Air
          </Button>
          <Button
            selected={state === STATE_FILL}
            onClick={() => act('command', { command: 'fill_atmos' })}
          >
            Equalize With Exterior
          </Button>
          <Button
            selected={state === STATE_SEALED}
            onClick={() => act('command', { command: 'seal' })}
          >
            Hold
          </Button>
        </Section>
        <Section title="Door Safety">
          {door_safety ? (
            <Button
              color="bad"
              icon="exclamation-triangle"
              onClick={() => act('command', { command: 'toggle_door_safety' })}
            >
              Override Door Safety
            </Button>
          ) : (
            <Button
              color="average"
              icon="exclamation-triangle"
              onClick={() => act('command', { command: 'toggle_door_safety' })}
            >
              Re-engage Door Safety
            </Button>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
