import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  fire: BooleanLike;
  timing: BooleanLike;
  time: number;
  detecting: BooleanLike;
  security_level: string;
};

export function FireAlarm(props) {
  const { act, data } = useBackend<Data>();
  const { fire, timing, time, security_level } = data;

  const minutes = Math.floor(time / 60);
  const seconds = time % 60;
  const timeStr =
    minutes > 0
      ? `${minutes}:${String(seconds).padStart(2, '0')}`
      : `${seconds}s`;

  return (
    <Window title="Fire Alarm" width={300} height={230}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Alert Level">
              <Box color={fire ? 'bad' : 'good'}>{security_level}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Fire Detected">
              <Box color={fire ? 'bad' : 'good'}>{fire ? 'Yes' : 'No'}</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          {fire ? (
            <Button icon="times-circle" color="good" onClick={() => act('reset')}>
              Reset Alarm
            </Button>
          ) : (
            <Button icon="fire" color="bad" onClick={() => act('alarm')}>
              Trigger Alarm
            </Button>
          )}
        </Section>
        <Section title="Time Lock">
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                icon={timing ? 'stop' : 'clock'}
                color={timing ? 'bad' : 'default'}
                onClick={() => act('toggle_timing')}
              >
                {timing ? 'Stop Timer' : 'Start Timer'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Time Remaining">
              <Box inline mr={1}>
                {timeStr}
              </Box>
              <Button icon="minus" onClick={() => act('adjust_time', { amount: -30 })}>
                -30
              </Button>
              <Button icon="minus" onClick={() => act('adjust_time', { amount: -1 })}>
                -1
              </Button>
              <Button icon="plus" onClick={() => act('adjust_time', { amount: 1 })}>
                +1
              </Button>
              <Button icon="plus" onClick={() => act('adjust_time', { amount: 30 })}>
                +30
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
}
