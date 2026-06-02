import { Button, LabeledList, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Entry = {
  name: string;
  value: string;
};

type Data = {
  electronic_warfare: BooleanLike;
  entries: Entry[];
};

export const AgentIdCard = () => {
  const { act, data } = useBackend<Data>();
  const { electronic_warfare, entries } = data;

  return (
    <Window title="Agent ID Card" width={600} height={400}>
      <Window.Content scrollable>
        <Section title="Available Entries">
          <Table>
            {entries.map((entry) => (
              <Table.Row key={entry.name}>
                <Table.Cell collapsing>
                  <Button
                    icon="edit"
                    onClick={() => act('set', { set: entry.name })}
                  />
                </Table.Cell>
                <Table.Cell bold>{entry.name}</Table.Cell>
                <Table.Cell color="label">{entry.value}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
        <Section title="Electronic Warfare">
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                selected={!!electronic_warfare}
                color={electronic_warfare ? 'good' : undefined}
                onClick={() =>
                  act('electronic_warfare', { electronic_warfare: 1 })
                }
              >
                Enabled
              </Button>
              <Button
                selected={!electronic_warfare}
                color={!electronic_warfare ? undefined : undefined}
                onClick={() =>
                  act('electronic_warfare', { electronic_warfare: 0 })
                }
              >
                Disabled
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
