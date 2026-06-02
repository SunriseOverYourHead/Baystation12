import { Box, Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  external_pressure: number;
  chamber_pressure: number;
  internal_pressure: number;
  processing: BooleanLike;
  purge: BooleanLike;
  secure: BooleanLike;
};

function pressureColor(pressure: number): string {
  if (pressure < 80 || pressure > 120) return 'bad';
  if (pressure < 95 || pressure > 110) return 'average';
  return 'good';
}

export function AdvancedAirlockConsole(props) {
  const { act, data } = useBackend<Data>();
  const {
    external_pressure,
    chamber_pressure,
    internal_pressure,
    processing,
    purge,
    secure,
  } = data;

  return (
    <Window title="Advanced Airlock Console" width={470} height={290}>
      <Window.Content>
        <Section title="Pressure">
          <LabeledList>
            <LabeledList.Item label="External">
              <ProgressBar
                value={external_pressure}
                minValue={0}
                maxValue={200}
                color={pressureColor(external_pressure)}
              >
                {external_pressure} kPa
              </ProgressBar>
            </LabeledList.Item>
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
            <LabeledList.Item label="Internal">
              <ProgressBar
                value={internal_pressure}
                minValue={0}
                maxValue={200}
                color={pressureColor(internal_pressure)}
              >
                {internal_pressure} kPa
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
              color="yellow"
              onClick={() => act('force_ext')}
            >
              Force Exterior Door
            </Button>
            <Button
              icon="exclamation-triangle"
              color="yellow"
              onClick={() => act('force_int')}
            >
              Force Interior Door
            </Button>
          </Box>
          <Box mb={1}>
            <Button
              icon="sync"
              selected={!!purge}
              disabled={!!processing}
              onClick={() => act('purge')}
            >
              Purge
            </Button>
            <Button
              icon={secure ? 'lock' : 'lock-open'}
              selected={!!secure}
              disabled={!!processing}
              onClick={() => act('secure')}
            >
              Secure
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
