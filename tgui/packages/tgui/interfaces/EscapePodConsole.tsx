import { Box, Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  docking_status: string;
  override_enabled: BooleanLike;
  door_state: string;
  door_lock: string;
  can_force: BooleanLike;
  is_armed: BooleanLike;
};

function dockingStatusColor(status: string): string {
  if (status === 'docked') return 'good';
  if (status === 'docking' || status === 'undocking') return 'average';
  if (status === 'undocked') return 'label';
  return 'bad';
}

function dockingStatusText(status: string): string {
  if (status === 'docked') return 'Docked';
  if (status === 'docking') return 'Docking';
  if (status === 'undocking') return 'Undocking';
  if (status === 'undocked') return 'Not Docked';
  return 'Error';
}

export const EscapePodConsole = () => {
  const { act, data } = useBackend<Data>();
  const {
    docking_status,
    override_enabled,
    door_state,
    door_lock,
    can_force,
    is_armed,
  } = data;

  return (
    <Window title="Escape Pod Console" width={470} height={290}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Docking Status">
              <Box color={dockingStatusColor(docking_status)}>
                {dockingStatusText(docking_status)}
                {!!override_enabled && ' (OVERRIDE)'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Hatch">
              <Box color={door_state === 'open' ? 'good' : undefined}>
                {door_state === 'open'
                  ? 'Open'
                  : door_lock === 'locked'
                    ? 'Secured'
                    : 'Closed'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Arming Status">
              <Box color={is_armed ? 'average' : undefined}>
                {is_armed ? 'Armed' : 'Unarmed'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          {!is_armed && (
            <Button
              icon="exclamation-triangle"
              color="average"
              mb={1}
              onClick={() => act('manual_arm')}
            >
              Arm Pod
            </Button>
          )}
          {!!can_force && (
            <Button
              icon="rocket"
              color={is_armed ? 'bad' : 'average'}
              onClick={() => act('force_launch')}
            >
              {is_armed ? 'Launch Pod' : 'Force Launch'}
            </Button>
          )}
          {!can_force && (
            <NoticeBox>
              Pod cannot be launched at this time.
            </NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
