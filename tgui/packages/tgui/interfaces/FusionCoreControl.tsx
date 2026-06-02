import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Reactant = {
  name: string;
  amount: number;
};

type Core = {
  id: string;
  ref: string;
  field: BooleanLike;
  power: string;
  size: string;
  instability: string;
  temperature: string;
  powerstatus: string;
  fuel: Reactant[];
};

type Data = {
  id: string;
  name: string;
  cores: Core[];
};

export const FusionCoreControl = () => {
  const { act, data } = useBackend<Data>();
  const { id, name, cores = [] } = data;

  return (
    <Window title={name} width={400} height={600}>
      <Window.Content scrollable>
        <Section title={`Fusion Plant: ${id}`}>
          {cores.length === 0 ? (
            <NoticeBox>No electromagnetic field generators connected.</NoticeBox>
          ) : (
            cores.map((core) => (
              <Section key={core.ref} title={core.id}>
                <LabeledList>
                  <LabeledList.Item label="Field generator">
                    {core.field ? (
                      <>
                        <Box inline color="good">
                          Online.
                        </Box>
                        <Button
                          ml={1}
                          color="bad"
                          onClick={() =>
                            act('toggle_active', { machine: core.ref })
                          }
                        >
                          Shut down
                        </Button>
                      </>
                    ) : (
                      <>
                        <Box inline color="bad">
                          Offline.
                        </Box>
                        <Button
                          ml={1}
                          color="good"
                          onClick={() =>
                            act('toggle_active', { machine: core.ref })
                          }
                        >
                          Start up
                        </Button>
                      </>
                    )}
                  </LabeledList.Item>
                  {core.field && (
                    <>
                      <LabeledList.Item label="Power status">
                        {core.powerstatus}
                      </LabeledList.Item>
                      <LabeledList.Item label="Field strength">
                        {core.power}
                        <Box mt={0.5}>
                          {[-100, -10, -1, 1, 10, 100].map((delta) => (
                            <Button
                              key={delta}
                              mr={0.5}
                              onClick={() =>
                                act('str', {
                                  machine: core.ref,
                                  str: delta,
                                })
                              }
                            >
                              {delta > 0 ? '+' : ''}
                              {delta / 10} T
                            </Button>
                          ))}
                          <Button.Input
                            buttonText="Set"
                            onCommit={(val) =>
                              act('set_strength', {
                                machine: core.ref,
                                value: val,
                              })
                            }
                          />
                        </Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Size">
                        {core.size}
                      </LabeledList.Item>
                      <LabeledList.Item label="Instability">
                        {core.instability}
                      </LabeledList.Item>
                      <LabeledList.Item label="Plasma temperature">
                        {core.temperature}
                      </LabeledList.Item>
                      <LabeledList.Item label="Reactants">
                        {core.fuel && core.fuel.length > 0 ? (
                          <Table>
                            {core.fuel.map((r) => (
                              <Table.Row key={r.name}>
                                <Table.Cell>{r.name}</Table.Cell>
                                <Table.Cell>{r.amount}</Table.Cell>
                              </Table.Row>
                            ))}
                          </Table>
                        ) : (
                          <Box color="label">Nothing.</Box>
                        )}
                      </LabeledList.Item>
                    </>
                  )}
                </LabeledList>
              </Section>
            ))
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
