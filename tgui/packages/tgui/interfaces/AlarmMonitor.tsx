import {
  Box,
  Button,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Camera = {
  name: string;
  camera: string;
  deact: BooleanLike;
};

type Alarm = {
  name: string;
  origin_lost: BooleanLike;
  has_cameras: BooleanLike;
  cameras: Camera[];
  lost_sources: string;
};

type Category = {
  category: string;
  alarms: Alarm[];
};

type Data = {
  categories: Category[];
};

export const AlarmMonitor = () => {
  const { act, data } = useBackend<Data>();
  const { categories } = data;

  return (
    <Window title="Alarm Monitoring Console" width={800} height={800}>
      <Window.Content scrollable>
        {categories.map((cat) => (
          <Section key={cat.category} title={cat.category}>
            {cat.alarms.length === 0 ? (
              <Box color="white">--All Systems Nominal</Box>
            ) : (
              cat.alarms.map((alarm, i) => (
                <Box key={i} mb={1}>
                  <Stack align="center">
                    <Stack.Item>
                      {alarm.name}
                      {!!alarm.origin_lost && (
                        <Box as="span" color="average" ml={1}>
                          Alarm Origin Lost
                        </Box>
                      )}
                    </Stack.Item>
                  </Stack>
                  {(!!alarm.has_cameras || alarm.lost_sources !== '') && (
                    <Box ml={2} mt={0.5}>
                      {!!alarm.has_cameras && (
                        <Box>
                          {alarm.cameras.map((cam, ci) =>
                            cam.deact ? (
                              <Button key={ci} disabled color="average">
                                {cam.name} (deactivated)
                              </Button>
                            ) : (
                              <Button
                                key={ci}
                                onClick={() =>
                                  act('switchTo', { switchTo: cam.camera })
                                }
                              >
                                {cam.name}
                              </Button>
                            ),
                          )}
                        </Box>
                      )}
                      {alarm.lost_sources !== '' && (
                        <Box color="average" bold>
                          Lost Alarm Sources: {alarm.lost_sources}
                        </Box>
                      )}
                    </Box>
                  )}
                </Box>
              ))
            )}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
