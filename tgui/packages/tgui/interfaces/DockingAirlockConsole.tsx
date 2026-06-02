import { Box, Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DoorStatus = {
  state: string;
};

type Data = {
  name: string;
  docking_status: string;
  override_enabled: BooleanLike;
  chamber_pressure: number;
  exterior_status: DoorStatus;
  interior_status: DoorStatus;
  processing: BooleanLike;
  airlock_disabled: BooleanLike;
};

function pressureColor(pressure: number): string {
  if (pressure < 80 || pressure > 120) return 'bad';
  if (pressure < 95 || pressure > 110) return 'average';
  return 'good';
}

function dockingStatusColor(status: string, override: BooleanLike): string {
  if (override) return 'bad';
  if (status === 'docked') return 'good';
  if (status === 'docking' || status === 'undocking') return 'average';
  if (status === 'undocked') return 'label';
  return 'bad';
}

function dockingStatusText(status: string, override: BooleanLike): string {
  if (status === 'docked') return override ? 'DOCKED - OVERRIDE ENABLED' : 'DOCKED';
  if (status === 'docking') return override ? 'DOCKING - OVERRIDE ENABLED' : 'DOCKING';
  if (status === 'undocking') return override ? 'UNDOCKING - OVERRIDE ENABLED' : 'UNDOCKING';
  if (status === 'undocked') return override ? 'OVERRIDE ENABLED' : 'NOT IN USE';
  return 'ERROR';
}

export function DockingAirlockConsole(props) {
  const { act, data } = useBackend<Data>();
  const {
    name,
    docking_status,
    override_enabled,
    chamber_pressure,
    exterior_status,
    interior_status,
    processing,
    airlock_disabled,
  } = data;

  const interiorOpen = interior_status?.state === 'open';
  const exteriorOpen = exterior_status?.state === 'open';
  const canCycle = !processing && !airlock_disabled;
  const canAbort = !!processing && !airlock_disabled;

  return (
    <Window title="Docking Airlock Console" width={470} height={290}>
      <Window.Content>
        <Section title={name || 'Docking Port'}>
          <LabeledList>
            <LabeledList.Item label="Docking Status">
              <Box
                color={dockingStatusColor(docking_status, override_enabled)}
                inline
              >
                {dockingStatusText(docking_status, override_enabled)}
              </Box>
              {'  '}
              <Button
                icon="exclamation-triangle"
                color={override_enabled ? 'bad' : undefined}
                selected={!!override_enabled}
                onClick={() => act('toggle_override')}
              >
                Override
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Chamber Pressure">
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
        <Section title="Airlock Controls">
          <Box mb={1}>
            <Button
              icon="arrow-left"
              disabled={!canCycle}
              onClick={() => act('cycle_ext')}
            >
              Cycle to Exterior
            </Button>
            <Button
              icon="arrow-right"
              disabled={!canCycle}
              onClick={() => act('cycle_int')}
            >
              Cycle to Interior
            </Button>
          </Box>
          <Box mb={1}>
            <Button
              icon="exclamation-triangle"
              disabled={!!airlock_disabled}
              color={
                airlock_disabled
                  ? undefined
                  : interiorOpen
                    ? 'bad'
                    : processing
                      ? 'yellow'
                      : undefined
              }
              onClick={() => act('force_ext')}
            >
              Force Exterior Door
            </Button>
            <Button
              icon="exclamation-triangle"
              disabled={!!airlock_disabled}
              color={
                airlock_disabled
                  ? undefined
                  : exteriorOpen
                    ? 'bad'
                    : processing
                      ? 'yellow'
                      : undefined
              }
              onClick={() => act('force_int')}
            >
              Force Interior Door
            </Button>
          </Box>
          <Box>
            <Button
              icon="times-circle"
              color="bad"
              disabled={!canAbort}
              onClick={() => act('abort')}
            >
              Abort
            </Button>
            <Button
              icon="anchor"
              disabled={docking_status !== 'undocked'}
              onClick={() => act('dock')}
            >
              Dock
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
}
