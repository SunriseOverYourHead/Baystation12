import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  faillink: BooleanLike;
  calibration: number[];
  cal_count: number;
  overmapdir: number;
  t_x: number;
  t_y: number;
  t_z: number;
  coordinates: BooleanLike;
  cal_accuracy: number;
  strength: number;
  range: number;
  next_shot: number;
  nopower: BooleanLike;
  skill: BooleanLike;
  chargeload: string;
};

const COMPASS = [
  [{ label: '↖', dir: 9 }, { label: '↑', dir: 1 }, { label: '↗', dir: 5 }],
  [{ label: '←', dir: 8 }, { label: '○', dir: 0 }, { label: '→', dir: 4 }],
  [{ label: '↙', dir: 10 }, { label: '↓', dir: 2 }, { label: '↘', dir: 6 }],
];

export const DisperserConsole = () => {
  const { act, data } = useBackend<Data>();
  const {
    faillink,
    calibration = [],
    cal_count = 4,
    overmapdir,
    t_x,
    t_y,
    t_z,
    coordinates,
    cal_accuracy,
    strength,
    range,
    next_shot,
    nopower,
    skill,
    chargeload,
  } = data;

  return (
    <Window title="Obstruction Field Disperser Control" width={440} height={580}>
      <Window.Content scrollable>
        {faillink ? (
          <NoticeBox danger>
            ERROR: Machine is incomplete, out of range, or misaligned!
          </NoticeBox>
        ) : (
          <>
            <Flex gap={1}>
              <Flex.Item width="50%">
                <Section title="Targeting">
                  <Table>
                    {COMPASS.map((row, ri) => (
                      <Table.Row key={ri}>
                        {row.map((cell) => (
                          <Table.Cell key={cell.dir} textAlign="center">
                            <Button
                              selected={overmapdir === cell.dir}
                              onClick={() =>
                                act('choose', { dir: cell.dir })
                              }
                            >
                              {cell.label}
                            </Button>
                          </Table.Cell>
                        ))}
                      </Table.Row>
                    ))}
                  </Table>
                  <Box mt={1}>
                    {coordinates ? (
                      <LabeledList>
                        <LabeledList.Item label="X">
                          <Button.Input
                            buttonText={String(t_x)}
                            onCommit={(val) => act('setx', { value: val })}
                          />
                        </LabeledList.Item>
                        <LabeledList.Item label="Y">
                          <Button.Input
                            buttonText={String(t_y)}
                            onCommit={(val) => act('sety', { value: val })}
                          />
                        </LabeledList.Item>
                        <LabeledList.Item label="Z">
                          <Button.Input
                            buttonText={String(t_z)}
                            onCommit={(val) => act('setz', { value: val })}
                          />
                        </LabeledList.Item>
                      </LabeledList>
                    ) : (
                      <LabeledList>
                        <LabeledList.Item label="X">
                          <Button.Input
                            buttonText="Set"
                            onCommit={(val) => act('setx', { value: val })}
                          />
                        </LabeledList.Item>
                        <LabeledList.Item label="Y">
                          <Button.Input
                            buttonText="Set"
                            onCommit={(val) => act('sety', { value: val })}
                          />
                        </LabeledList.Item>
                        <LabeledList.Item label="Z">
                          <Button.Input
                            buttonText="Set"
                            onCommit={(val) => act('setz', { value: val })}
                          />
                        </LabeledList.Item>
                      </LabeledList>
                    )}
                    {!!coordinates && (
                      <Button mt={0.5} onClick={() => act('reset')}>
                        Reset Coordinates
                      </Button>
                    )}
                  </Box>
                </Section>
              </Flex.Item>
              <Flex.Item width="50%">
                <Section title="Charge">
                  {!!nopower && (
                    <NoticeBox>
                      At least one part of the machine is unpowered.
                    </NoticeBox>
                  )}
                  <LabeledList>
                    <LabeledList.Item label="Charge Load Type">
                      {chargeload}
                    </LabeledList.Item>
                    <LabeledList.Item label="Cooldown">
                      {next_shot === 0 ? (
                        <Box color="good">Ready</Box>
                      ) : (
                        <>
                          <Box color="average">{next_shot} seconds</Box>
                          <Box italic color="bad">
                            Warning: Do not fire during cooldown.
                          </Box>
                        </>
                      )}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
            </Flex>

            <Flex gap={1}>
              <Flex.Item width="50%">
                <Section title="Calibration">
                  <Box mb={0.5}>
                    <Box inline bold>
                      Accuracy: {cal_accuracy}%
                    </Box>
                    <Button
                      ml={1}
                      disabled={!skill}
                      onClick={() => act('skill_calibration')}
                    >
                      Pre-Calibration
                    </Button>
                  </Box>
                  <Flex gap={0.5} wrap="wrap">
                    {calibration.slice(0, cal_count).map((val, i) => (
                      <Flex.Item key={i}>
                        <Box color="label" fontSize="0.85em">
                          #{i + 1}
                        </Box>
                        <Button.Input
                          buttonText={String(val)}
                          onCommit={(v) =>
                            act('set_calibration', { index: i, value: v })
                          }
                        />
                      </Flex.Item>
                    ))}
                  </Flex>
                </Section>
              </Flex.Item>
              <Flex.Item width="50%">
                <Section title="Setup">
                  <LabeledList>
                    <LabeledList.Item label="Strength">
                      <Flex gap={0.5}>
                        {[1, 2, 3, 4, 5].map((v) => (
                          <Button
                            key={v}
                            selected={v === strength}
                            onClick={() =>
                              act('set_strength', { value: v })
                            }
                          >
                            {v}
                          </Button>
                        ))}
                      </Flex>
                    </LabeledList.Item>
                    <LabeledList.Item label="Radius">
                      <Flex gap={0.5}>
                        {[1, 2, 3, 4, 5].map((v) => (
                          <Button
                            key={v}
                            selected={v === range}
                            onClick={() =>
                              act('set_range', { value: v })
                            }
                          >
                            {v}
                          </Button>
                        ))}
                      </Flex>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
            </Flex>

            <Box textAlign="center" mt={1}>
              <Button
                color="bad"
                fontSize="1.2em"
                onClick={() => act('fire')}
              >
                Fire
              </Button>
            </Box>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
