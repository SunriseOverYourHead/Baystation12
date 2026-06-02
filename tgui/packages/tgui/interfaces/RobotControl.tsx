import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const STATUS_COLOR: Record<string, string> = {
  Operational: 'good',
  Lockdown: 'average',
  'Not Responding': 'bad',
};

type Robot = {
  name: string;
  location: string;
  status: string;
  cell: BooleanLike;
  cell_capacity?: number;
  cell_current?: number;
  cell_percentage?: number;
  module: string;
  master_ai: string;
  hackable?: BooleanLike;
  hacked?: BooleanLike;
};

type Data = {
  robots: Robot[];
  is_ai: BooleanLike;
};

export const RobotControl = () => {
  const { act, data } = useBackend<Data>();
  const { robots } = data;

  return (
    <Window title="Robotic Control Console" width={700} height={500}>
      <Window.Content scrollable>
        {robots.length === 0 ? (
          <Box color="label">No synthetics detected.</Box>
        ) : (
          robots.map((robot) => (
            <Section
              key={robot.name}
              title={robot.name}
              color={STATUS_COLOR[robot.status]}
            >
              <LabeledList>
                <LabeledList.Item label="Location">
                  {robot.location}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Status"
                  color={STATUS_COLOR[robot.status] ?? 'average'}
                >
                  {robot.status}
                  {!!robot.hacked && ' (Hacked)'}
                </LabeledList.Item>
                <LabeledList.Item label="Cell">
                  {robot.cell ? (
                    <ProgressBar
                      value={robot.cell_percentage! / 100}
                      color={robot.cell_percentage! > 25 ? 'good' : 'bad'}
                    >
                      {round(robot.cell_current!, 0)} /{' '}
                      {round(robot.cell_capacity!, 0)}
                    </ProgressBar>
                  ) : (
                    <Box color="bad">No Cell</Box>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Module">
                  {robot.module}
                </LabeledList.Item>
                <LabeledList.Item label="Linked AI">
                  {robot.master_ai}
                </LabeledList.Item>
                <LabeledList.Item label="Actions">
                  <Button
                    icon={robot.status === 'Lockdown' ? 'lock-open' : 'lock'}
                    color={robot.status === 'Lockdown' ? 'good' : 'bad'}
                    onClick={() => act('lockdown', { name: robot.name })}
                  >
                    {robot.status === 'Lockdown' ? 'Release' : 'Lockdown'}
                  </Button>
                  <Button
                    icon="comment"
                    onClick={() => act('message', { name: robot.name })}
                  >
                    Message
                  </Button>
                  {!!robot.hackable && (
                    <Button
                      icon="bug"
                      color="bad"
                      onClick={() => act('hack', { name: robot.name })}
                    >
                      Hack
                    </Button>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))
        )}
      </Window.Content>
    </Window>
  );
};
