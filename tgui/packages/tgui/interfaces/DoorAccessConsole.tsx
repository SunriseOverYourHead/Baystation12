import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DoorStatus = {
  state: string;
};

type Data = {
  exterior_status: DoorStatus;
  interior_status: DoorStatus;
  processing: BooleanLike;
};

export function DoorAccessConsole(props) {
  const { act, data } = useBackend<Data>();
  const { exterior_status, interior_status, processing } = data;

  const exteriorOpen = exterior_status?.state === 'open';
  const interiorOpen = interior_status?.state === 'open';

  return (
    <Window title="Access Controller" width={330} height={220}>
      <Window.Content>
        <Section title="Door Status">
          <LabeledList>
            <LabeledList.Item label="Exterior Door">
              <Box color={exteriorOpen ? 'good' : undefined}>
                {exteriorOpen ? 'Open' : 'Locked'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Interior Door">
              <Box color={interiorOpen ? 'good' : undefined}>
                {interiorOpen ? 'Open' : 'Locked'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          {exteriorOpen ? (
            <Button
              icon="exclamation-triangle"
              disabled={!!processing}
              onClick={() => act('force_ext')}
            >
              Lock Exterior Door
            </Button>
          ) : (
            <Button
              icon="arrow-left"
              disabled={!!processing}
              onClick={() => act('cycle_ext_door')}
            >
              Cycle to Exterior
            </Button>
          )}
          {interiorOpen ? (
            <Button
              icon="exclamation-triangle"
              disabled={!!processing}
              onClick={() => act('force_int')}
            >
              Lock Interior Door
            </Button>
          ) : (
            <Button
              icon="arrow-right"
              disabled={!!processing}
              onClick={() => act('cycle_int_door')}
            >
              Cycle to Interior
            </Button>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
}
