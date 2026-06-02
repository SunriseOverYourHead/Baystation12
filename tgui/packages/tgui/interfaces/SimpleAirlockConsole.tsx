import { Box, Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DoorStatus = {
  state: string;
};

type Data = {
  chamber_pressure: number;
  exterior_status: DoorStatus;
  interior_status: DoorStatus;
  processing: BooleanLike;
};

function pressureColor(pressure: number): string {
  if (pressure < 80 || pressure > 120) return 'bad';
  if (pressure < 95 || pressure > 110) return 'average';
  return 'good';
}

export function SimpleAirlockConsole(props) {
  const { act, data } = useBackend<Data>();
  const { chamber_pressure, exterior_status, interior_status, processing } =
    data;

  const interiorOpen = interior_status?.state === 'open';
  const exteriorOpen = exterior_status?.state === 'open';

  return (
    <Window title="Airlock Console" width={470} height={290}>
      <Window.Content>
        <Section title="Pressure">
          <LabeledList>
            <LabeledList.Item label="Chamber">
              <ProgressBar
                value={chamber_pressure}
                minValue={0}
                maxValue={200}
                color={pressureColor(chamber_pressure)}
              >
                {chamber_pressure} kPa
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          <Box mb={1}>
            <Button
              icon="arrow-left"
              disabled={!!processing}
              onClick={() => act('cycle_ext')}
            >
              Cycle to Exterior
            </Button>
            <Button
              icon="arrow-right"
              disabled={!!processing}
              onClick={() => act('cycle_int')}
            >
              Cycle to Interior
            </Button>
          </Box>
          <Box mb={1}>
            <Button
              icon="exclamation-triangle"
              color={interiorOpen ? 'bad' : processing ? 'yellow' : undefined}
              onClick={() => act('force_ext')}
            >
              Force Exterior Door
            </Button>
            <Button
              icon="exclamation-triangle"
              color={exteriorOpen ? 'bad' : processing ? 'yellow' : undefined}
              onClick={() => act('force_int')}
            >
              Force Interior Door
            </Button>
          </Box>
          <Button
            icon="times-circle"
            color="bad"
            disabled={!processing}
            onClick={() => act('abort')}
          >
            Abort
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
}
