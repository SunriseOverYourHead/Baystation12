import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Location = {
  name: string;
  x: number;
  y: number;
  reference: string;
};

type Data = {
  sector: string;
  sector_info: string;
  landed: string;
  s_x: number;
  s_y: number;
  dest: BooleanLike;
  d_x: number;
  d_y: number;
  speedlimit: number | string;
  accel: number;
  heading: number;
  autopilot: BooleanLike;
  manual_control: BooleanLike;
  canburn: BooleanLike;
  accellimit: number;
  speed: number;
  speed_color: string | null;
  ETAnext: string;
  locations: Location[];
  viewing_silicon: BooleanLike;
};

const DIR_MAP: [number, string][] = [
  [9, 'nw'],
  [1, 'n'],
  [5, 'ne'],
  [8, 'w'],
  [0, 'stop'],
  [4, 'e'],
  [10, 'sw'],
  [2, 's'],
  [6, 'se'],
];

export const HelmControl = () => {
  const { act, data } = useBackend<Data>();
  const {
    sector,
    sector_info,
    landed,
    s_x,
    s_y,
    dest,
    d_x,
    d_y,
    speedlimit,
    accel,
    heading,
    autopilot,
    manual_control,
    canburn,
    accellimit,
    speed,
    speed_color,
    ETAnext,
    locations,
    viewing_silicon,
  } = data;

  return (
    <Window title="Helm Control" width={565} height={545}>
      <Window.Content scrollable>
        {!!viewing_silicon && (
          <NoticeBox color="bad">
            Remote AI systems detected. Firewall protections forbid remote AI
            control.
          </NoticeBox>
        )}
        <Stack>
          <Stack.Item width="45%">
            <Section title="Flight data" fill>
              <LabeledList>
                <LabeledList.Item label="ETA to next grid">
                  {ETAnext}
                </LabeledList.Item>
                <LabeledList.Item label="Speed">
                  <Box inline color={speed_color ?? undefined}>
                    {speed} Gm/h
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Acceleration">
                  {accel} Gm/h
                </LabeledList.Item>
                <LabeledList.Item label="Heading">{heading}&deg;</LabeledList.Item>
                <LabeledList.Item label="Accel limit">
                  <Button onClick={() => act('accellimit')}>
                    {accellimit} Gm/h
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item width="25%">
            <Section title="Manual control" fill>
              <Stack vertical align="center">
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="arrow-up-left"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 9 })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-up"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 1 })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-up-right"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 5 })}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="arrow-left"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 8 })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="times"
                        disabled={!canburn}
                        onClick={() => act('brake')}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-right"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 4 })}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="arrow-down-left"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 10 })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-down"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 2 })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-down-right"
                        disabled={!canburn}
                        onClick={() => act('move', { move: 6 })}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Box bold color="white">
                    Direct control
                  </Box>
                  <Button
                    color={manual_control ? 'good' : 'default'}
                    onClick={() => act('manual')}
                  >
                    {manual_control ? 'Engaged' : 'Disengaged'}
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="30%">
            <Section title="Autopilot" fill>
              <LabeledList>
                <LabeledList.Item label="Target">
                  {dest ? (
                    <>
                      <Button onClick={() => act('setx')}>{d_x}</Button>{' '}
                      <Button onClick={() => act('sety')}>{d_y}</Button>
                    </>
                  ) : (
                    <Button onClick={() => act('setx')}>None</Button>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Speed limit">
                  <Button onClick={() => act('speedlimit')}>
                    {speedlimit} Gm/h
                  </Button>
                </LabeledList.Item>
              </LabeledList>
              <Button
                icon="cog"
                color={autopilot ? 'good' : 'default'}
                disabled={!dest}
                mt={1}
                onClick={() => act('apilot')}
              >
                {autopilot ? 'Engaged' : 'Disengaged'}
              </Button>
            </Section>
          </Stack.Item>
        </Stack>
        <Section title="Navigation data">
          <LabeledList>
            <LabeledList.Item label="Location">{sector}</LabeledList.Item>
            <LabeledList.Item label="Coordinates">
              {s_x} : {s_y}
            </LabeledList.Item>
            <LabeledList.Item label="Scan data">
              {sector_info}
            </LabeledList.Item>
            <LabeledList.Item label="Status">{landed}</LabeledList.Item>
          </LabeledList>
          <Stack mt={1} mb={1}>
            <Stack.Item>
              <Button icon="save" onClick={() => act('add', { add: 'current' })}>
                Save current position
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file"
                onClick={() => act('add', { add: 'new' })}
              >
                Add new entry
              </Button>
            </Stack.Item>
          </Stack>
          <Table>
            <Table.Row header>
              <Table.Cell width="40%">Name</Table.Cell>
              <Table.Cell>Coordinates</Table.Cell>
              <Table.Cell>Actions</Table.Cell>
            </Table.Row>
            {locations.map((loc) => (
              <Table.Row key={loc.reference} className="candystripe">
                <Table.Cell>{loc.name}</Table.Cell>
                <Table.Cell>
                  {loc.x} : {loc.y}
                </Table.Cell>
                <Table.Cell>
                  <Button
                    icon="location-arrow"
                    onClick={() => act('setcoords', { x: loc.x, y: loc.y })}
                  >
                    Plot course
                  </Button>
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() => act('remove', { remove: loc.reference })}
                  >
                    Remove
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
