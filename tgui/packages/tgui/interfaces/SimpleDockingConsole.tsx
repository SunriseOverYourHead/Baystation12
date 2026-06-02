import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  docking_status: string;
  override_enabled: BooleanLike;
  door_state: string;
  door_lock: string;
};

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

function hatchStatusColor(
  docking_status: string,
  door_state: string,
  door_lock: string,
): string {
  if (docking_status === 'docked') {
    return 'good';
  }
  if (docking_status === 'docking') {
    if (door_state === 'open') return 'good';
    if (door_lock === 'locked') return 'good';
    return 'good';
  }
  if (docking_status === 'undocking') {
    if (door_state === 'open') return 'average';
    if (door_lock === 'unlocked') return 'average';
    return 'good';
  }
  if (docking_status === 'undocked') {
    if (door_state === 'open') return 'bad';
    if (door_lock === 'unlocked') return 'bad';
    return 'good';
  }
  return 'bad';
}

function hatchStatusText(
  docking_status: string,
  door_state: string,
  door_lock: string,
): string {
  if (door_state === 'open') return 'OPEN';
  if (door_state === 'closed') {
    if (door_lock === 'locked') return 'SECURED';
    if (door_lock === 'unlocked') return 'UNSECURED';
  }
  return 'ERROR';
}

export function SimpleDockingConsole(props) {
  const { act, data } = useBackend<Data>();
  const { docking_status, override_enabled, door_state, door_lock } = data;

  const isDocked = docking_status === 'docked';

  return (
    <Window title="Docking Hatch Controller" width={470} height={290}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Docking Port">
              <Box color={dockingStatusColor(docking_status, override_enabled)}>
                {dockingStatusText(docking_status, override_enabled)}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Docking Hatch">
              <Box
                color={hatchStatusColor(docking_status, door_state, door_lock)}
              >
                {hatchStatusText(docking_status, door_state, door_lock)}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          <Button
            icon="exclamation-triangle"
            disabled={!override_enabled}
            color={isDocked ? undefined : override_enabled ? 'bad' : undefined}
            onClick={() => act('force_door')}
          >
            Force Exterior Door
          </Button>
          <Button
            icon="exclamation-triangle"
            color={override_enabled ? 'bad' : 'yellow'}
            selected={!!override_enabled}
            onClick={() => act('toggle_override')}
          >
            Override
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
}
