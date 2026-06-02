import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Multiplier = {
  label: string;
  multiplier: number;
};

type BuildOption = {
  name: string;
  reference: string;
  illegal: BooleanLike;
  cost: string;
  unavailable?: BooleanLike;
  multipliers?: Multiplier[];
};

type QueueEntry = {
  name: string;
  multiplier: number;
  reference: string | null;
};

type MaterialEntry = {
  name: string;
  stored: number;
  max: number;
  eject_key: string;
  eject_label: string;
};

type CurrentBuild = {
  name: string;
  multiplier: string;
  progress: string;
};

type Data = {
  functional: BooleanLike;
  category: string;
  categories: string[];
  material_storage: MaterialEntry[];
  current_build: CurrentBuild;
  build_queue: QueueEntry[];
  build_options: BuildOption[];
};

export const BSFabricator = () => {
  const { act, data } = useBackend<Data>();
  const {
    functional,
    category,
    categories = [],
    material_storage = [],
    current_build,
    build_queue = [],
    build_options = [],
  } = data;

  return (
    <Window width={780} height={580}>
      <Window.Content scrollable>
        {!functional ? (
          <NoticeBox danger>
            FABRICATOR OFFLINE. CONTACT SYSTEM ADMINISTRATOR.
          </NoticeBox>
        ) : (
          <Stack fill>
            <Stack.Item width="55%">
              <Section title="Materials">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Resource</Table.Cell>
                    <Table.Cell>Storage</Table.Cell>
                    <Table.Cell>Options</Table.Cell>
                  </Table.Row>
                  {material_storage.map((mat) => (
                    <Table.Row key={mat.name} className="candystripe">
                      <Table.Cell>{mat.name}</Table.Cell>
                      <Table.Cell>
                        {mat.stored}/{mat.max}
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          onClick={() =>
                            act('eject_mat', { eject_mat: mat.eject_key })
                          }
                        >
                          {mat.eject_label}
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>

              <Section title="Category">
                <Box>
                  {['All', ...categories].map((cat) => (
                    <Button
                      key={cat}
                      selected={category === cat}
                      mr={0.5}
                      mb={0.5}
                      onClick={() =>
                        act('change_category', { category: cat })
                      }
                    >
                      {cat}
                    </Button>
                  ))}
                </Box>
              </Section>

              <Section title="Build Options">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Design</Table.Cell>
                    <Table.Cell>Cost</Table.Cell>
                    <Table.Cell>Queue</Table.Cell>
                  </Table.Row>
                  {build_options.map((opt) => (
                    <Table.Row key={opt.reference} className="candystripe">
                      <Table.Cell color={opt.illegal ? 'bad' : undefined}>
                        {opt.name}
                      </Table.Cell>
                      <Table.Cell>{opt.cost}</Table.Cell>
                      <Table.Cell>
                        {opt.unavailable ? (
                          <Box color="average" fontSize="0.8em">
                            Insufficient resources.
                          </Box>
                        ) : (
                          <Stack wrap>
                            <Stack.Item>
                              <Button
                                onClick={() =>
                                  act('make', {
                                    make: opt.reference,
                                    multiplier: 1,
                                  })
                                }
                              >
                                x1
                              </Button>
                            </Stack.Item>
                            {opt.multipliers?.map((m) => (
                              <Stack.Item key={m.multiplier}>
                                <Button
                                  onClick={() =>
                                    act('make', {
                                      make: opt.reference,
                                      multiplier: m.multiplier,
                                    })
                                  }
                                >
                                  {m.label}
                                </Button>
                              </Stack.Item>
                            ))}
                          </Stack>
                        )}
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>
            </Stack.Item>

            <Stack.Item width="45%">
              <Section title="Current Build">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Design</Table.Cell>
                    <Table.Cell>Units</Table.Cell>
                    <Table.Cell>Progress</Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell>{current_build?.name}</Table.Cell>
                    <Table.Cell>{current_build?.multiplier}</Table.Cell>
                    <Table.Cell>{current_build?.progress}</Table.Cell>
                  </Table.Row>
                </Table>
              </Section>

              <Section title="Build Queue">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Design</Table.Cell>
                    <Table.Cell>Units</Table.Cell>
                    <Table.Cell>Cancel</Table.Cell>
                  </Table.Row>
                  {build_queue.map((entry, i) => (
                    <Table.Row key={i} className="candystripe">
                      <Table.Cell>{entry.name}</Table.Cell>
                      <Table.Cell>{entry.multiplier}</Table.Cell>
                      <Table.Cell>
                        {entry.reference ? (
                          <Button
                            icon="times"
                            color="bad"
                            onClick={() =>
                              act('cancel', { cancel: entry.reference })
                            }
                          >
                            Cancel
                          </Button>
                        ) : (
                          '-'
                        )}
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
