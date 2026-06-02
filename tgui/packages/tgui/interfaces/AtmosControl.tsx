import {
  Box,
  Button,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type AlarmEntry = {
  name: string;
  ref: string;
  danger: number;
};

type Data = {
  alarms: AlarmEntry[];
  alarmsAlert: AlarmEntry[];
  alarmsDanger: AlarmEntry[];
};

export const AtmosControl = () => {
  const { act, data } = useBackend<Data>();
  const { alarms, alarmsAlert, alarmsDanger } = data;

  return (
    <Window title="Atmospherics Control" width={625} height={625}>
      <Window.Content scrollable>
        <Section title="Critical Alarms">
          {alarmsAlert.length === 0 ? (
            <Box color="good">No critical alarms.</Box>
          ) : (
            <Stack wrap>
              {alarmsAlert.map((alarm) => (
                <Stack.Item key={alarm.ref}>
                  <Button
                    color="bad"
                    onClick={() => act('alarm', { alarm: alarm.ref })}
                  >
                    {alarm.name}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          )}
        </Section>
        <Section title="Warning Alarms">
          {alarmsDanger.length === 0 ? (
            <Box color="good">No warning alarms.</Box>
          ) : (
            <Stack wrap>
              {alarmsDanger.map((alarm) => (
                <Stack.Item key={alarm.ref}>
                  <Button
                    color="average"
                    onClick={() => act('alarm', { alarm: alarm.ref })}
                  >
                    {alarm.name}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          )}
        </Section>
        <Section title="Normal Alarms">
          {alarms.length === 0 ? (
            <Box color="label">No alarms.</Box>
          ) : (
            <Stack wrap>
              {alarms.map((alarm) => (
                <Stack.Item key={alarm.ref}>
                  <Button onClick={() => act('alarm', { alarm: alarm.ref })}>
                    {alarm.name}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
