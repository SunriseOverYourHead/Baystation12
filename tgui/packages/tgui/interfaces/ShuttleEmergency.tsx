import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type AuthEntry = {
  auth_name: string;
  auth_hash: string | null;
};

type Data = {
  shuttle_status: string;
  shuttle_state: 'idle' | 'warmup' | 'in_transit';
  has_docking: BooleanLike;
  docking_status: string | null;
  can_launch: BooleanLike;
  can_cancel: BooleanLike;
  can_force: BooleanLike;
  auth_list: AuthEntry[];
  has_auth: BooleanLike;
};

const STATE_LABELS: Record<string, string> = {
  idle: 'Idle',
  warmup: 'Warming Up',
  in_transit: 'In Transit',
};

export function ShuttleEmergency(props) {
  const { act, data } = useBackend<Data>();
  const {
    shuttle_status,
    shuttle_state,
    has_docking,
    docking_status,
    can_launch,
    can_cancel,
    can_force,
    auth_list,
    has_auth,
  } = data;

  return (
    <Window title="Emergency Shuttle Control" width={470} height={430}>
      <Window.Content>
        <Section title="Shuttle Status">
          <LabeledList>
            <LabeledList.Item label="Status">{shuttle_status}</LabeledList.Item>
            <LabeledList.Item label="State">
              <Box
                color={
                  shuttle_state === 'in_transit'
                    ? 'yellow'
                    : shuttle_state === 'warmup'
                      ? 'average'
                      : 'good'
                }
              >
                {STATE_LABELS[shuttle_state] ?? shuttle_state}
              </Box>
            </LabeledList.Item>
            {!!has_docking && (
              <LabeledList.Item label="Docking">
                {docking_status ?? 'Unknown'}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        <Section title="Authorization">
          <Table>
            <Table.Row header>
              <Table.Cell>Slot</Table.Cell>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Action</Table.Cell>
            </Table.Row>
            {auth_list.map((entry, i) => (
              <Table.Row key={i}>
                <Table.Cell>#{i + 1}</Table.Cell>
                <Table.Cell>
                  {entry.auth_name ? (
                    <Box color="good">{entry.auth_name}</Box>
                  ) : (
                    <Box color="label">Empty</Box>
                  )}
                </Table.Cell>
                <Table.Cell>
                  {entry.auth_hash ? (
                    <Button
                      color="bad"
                      icon="times"
                      onClick={() =>
                        act('removeid', { hash: entry.auth_hash })
                      }
                    >
                      Remove
                    </Button>
                  ) : (
                    <Button icon="id-card" onClick={() => act('scanid')}>
                      Scan ID
                    </Button>
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
          {!has_auth && (
            <NoticeBox mt={1}>
              Insufficient authorizations. Swipe command-level ID cards to
              authorize launch.
            </NoticeBox>
          )}
        </Section>

        <Section title="Controls">
          <Button
            color="good"
            icon="rocket"
            disabled={!can_launch}
            onClick={() => act('move')}
          >
            Launch
          </Button>
          <Button
            color="average"
            icon="forward"
            disabled={!can_force}
            onClick={() => act('force')}
          >
            Force Launch
          </Button>
          <Button
            color="bad"
            icon="times-circle"
            disabled={!can_cancel}
            onClick={() => act('cancel')}
          >
            Cancel
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
}
