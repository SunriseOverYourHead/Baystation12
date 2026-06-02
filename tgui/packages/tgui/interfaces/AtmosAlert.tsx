import {
  Box,
  Button,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type AlarmEntry = {
  name: string;
  ref: string;
};

type Data = {
  priority_alarms: AlarmEntry[];
  minor_alarms: AlarmEntry[];
};

export const AtmosAlert = () => {
  const { act, data } = useBackend<Data>();
  const { priority_alarms, minor_alarms } = data;

  return (
    <Window title="Atmospheric Alert Computer" width={500} height={500}>
      <Window.Content scrollable>
        <Section title="Priority Alerts">
          {priority_alarms.length === 0 ? (
            <Box color="good">No priority alerts detected.</Box>
          ) : (
            priority_alarms.map((alarm) => (
              <Box key={alarm.ref} mb={0.5}>
                {alarm.name}{' '}
                <Button
                  color="bad"
                  onClick={() => act('clear_alarm', { clear_alarm: alarm.ref })}
                >
                  Reset
                </Button>
              </Box>
            ))
          )}
        </Section>
        <Section title="Minor Alerts">
          {minor_alarms.length === 0 ? (
            <Box color="good">No minor alerts detected.</Box>
          ) : (
            minor_alarms.map((alarm) => (
              <Box key={alarm.ref} mb={0.5}>
                {alarm.name}{' '}
                <Button
                  color="average"
                  onClick={() => act('clear_alarm', { clear_alarm: alarm.ref })}
                >
                  Reset
                </Button>
              </Box>
            ))
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
