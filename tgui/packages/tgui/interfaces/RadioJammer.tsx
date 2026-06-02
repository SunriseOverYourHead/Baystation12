import { Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  active: BooleanLike;
  current_charge: number;
  max_charge: number;
  range: number;
  max_range: number;
  frequency: string;
  code: number;
  total_cost: string;
};

export const RadioJammer = () => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    current_charge,
    max_charge,
    range,
    max_range,
    frequency,
    code,
    total_cost,
  } = data;

  return (
    <Window title="Portable Radio Jammer" width={300} height={640}>
      <Window.Content scrollable>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="State">
              <Button
                selected={!!active}
                color={active ? 'good' : 'bad'}
                onClick={() =>
                  act(active ? 'disable_jammer' : 'enable_jammer')
                }
              >
                {active ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Range">
          <LabeledList>
            <LabeledList.Item label="Range">
              {range} meter(s)
            </LabeledList.Item>
            <LabeledList.Item label="Adjust">
              <Button
                icon="minus"
                disabled={range <= 0}
                onClick={() => act('decrease_range')}
              >
                Decrease
              </Button>
              <Button
                icon="plus"
                disabled={range >= max_range}
                onClick={() => act('increase_range')}
              >
                Increase
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Remote Activation">
          <LabeledList>
            <LabeledList.Item label="Frequency">
              <Button onClick={() => act('set_frequency', { frequency: 0 })}>
                {frequency}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Code">
              <Button onClick={() => act('set_code', { code: 0 })}>
                {code}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Power">
          <LabeledList>
            <LabeledList.Item label="Charge">
              {current_charge} / {max_charge} W
            </LabeledList.Item>
            <LabeledList.Item label="">
              <ProgressBar
                value={max_charge > 0 ? current_charge / max_charge : 0}
                color="average"
              />
            </LabeledList.Item>
            <LabeledList.Item label="Energy Consumption">
              ~{total_cost} W
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
