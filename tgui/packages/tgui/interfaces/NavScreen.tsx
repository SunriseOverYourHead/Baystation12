import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  sector: string;
  sector_info: string;
  s_x: number;
  s_y: number;
  speed: number;
  accel: number;
  heading: number;
  ETAnext: string;
  viewing: BooleanLike;
  viewing_silicon: BooleanLike;
};

export const NavScreen = () => {
  const { act, data } = useBackend<Data>();
  const {
    sector,
    sector_info,
    s_x,
    s_y,
    speed,
    accel,
    heading,
    ETAnext,
    viewing,
    viewing_silicon,
  } = data;

  return (
    <Window title="Navigation Screen" width={380} height={530}>
      <Window.Content scrollable>
        <Box bold fontSize="1.1em" mb={1}>
          Navigation
        </Box>
        {!!viewing_silicon && (
          <NoticeBox color="bad">
            Remote AI systems detected. Firewall protections forbid remote AI
            control.
          </NoticeBox>
        )}
        <Section>
          <Button
            color={viewing ? 'good' : 'default'}
            onClick={() => act('viewing')}
          >
            Map view: {viewing ? 'Engaged' : 'Disengaged'}
          </Button>
        </Section>
        <Stack>
          <Stack.Item width="50%">
            <Section title="Sector information">
              <Box bold>{sector}</Box>
              <Box color="average">
                Coordinates: {s_x} : {s_y}
              </Box>
              <Box color="average" mt={1}>
                Additional information:
              </Box>
              <Box>{sector_info}</Box>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section title="Flight data">
              <LabeledList>
                <LabeledList.Item label="ETA to next grid">
                  {ETAnext}
                </LabeledList.Item>
                <LabeledList.Item label="Speed">
                  {speed} Gm/h
                </LabeledList.Item>
                <LabeledList.Item label="Acceleration">
                  {accel} Gm/h
                </LabeledList.Item>
                <LabeledList.Item label="Heading">
                  {heading}&deg;
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
