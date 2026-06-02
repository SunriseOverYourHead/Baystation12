import { Button, LabeledList, ProgressBar, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type JammerMethod = {
  name: string;
  cost: number;
  ref: string;
};

type Data = {
  active: BooleanLike;
  current_charge: number;
  max_charge: number;
  range: number;
  max_range: number;
  methods: JammerMethod[];
  current_method: string;
  current_cost: number;
  total_cost: string;
};

export const SuitSensorJammer = () => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    current_charge,
    max_charge,
    range,
    max_range,
    methods,
    current_method,
    total_cost,
  } = data;

  return (
    <Window title="Sensor Jammer" width={300} height={640}>
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
        <Section title="Mode">
          <Table>
            <Table.Row header>
              <Table.Cell>Mode</Table.Cell>
              <Table.Cell>Cost</Table.Cell>
            </Table.Row>
            {methods.map((method) => (
              <Table.Row key={method.ref}>
                <Table.Cell>
                  <Button
                    selected={current_method === method.ref}
                    onClick={() =>
                      act('select_method', { select_method: method.ref })
                    }
                  >
                    {method.name}
                  </Button>
                </Table.Cell>
                <Table.Cell>{method.cost} W</Table.Cell>
              </Table.Row>
            ))}
          </Table>
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
