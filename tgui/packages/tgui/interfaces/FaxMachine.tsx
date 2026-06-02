import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  department: string;
  scan_name: string | null;
  authenticated: BooleanLike;
  destination: string | null;
  copyitem: string | null;
  linked_pdas: number;
  departments: string[];
  boss_name: string;
};

export function FaxMachine(props) {
  const { act, data } = useBackend<Data>();
  const {
    department,
    scan_name,
    authenticated,
    destination,
    copyitem,
    linked_pdas,
    departments,
    boss_name,
  } = data;

  return (
    <Window title={`Fax Machine — ${department}`} width={390} height={340}>
      <Window.Content>
        <Section title="Identity">
          <LabeledList>
            <LabeledList.Item label="Linked PDAs">
              {linked_pdas}
            </LabeledList.Item>
            <LabeledList.Item label="ID Card">
              <Box inline>{scan_name || '—'}</Box>
              <Button
                ml={1}
                icon={scan_name ? 'eject' : 'id-card'}
                onClick={() => act('scan')}
              >
                {scan_name ? 'Remove' : 'Scan'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Session">
              {authenticated ? (
                <Button
                  color="bad"
                  icon="sign-out-alt"
                  onClick={() => act('logout')}
                >
                  Log Out
                </Button>
              ) : (
                <Button
                  color={scan_name ? 'good' : undefined}
                  disabled={!scan_name}
                  icon="sign-in-alt"
                  onClick={() => act('auth')}
                >
                  Log In
                </Button>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        {authenticated ? (
          <Section title={`${boss_name} Quantum Entanglement Network`}>
            <LabeledList>
              <LabeledList.Item label="Document">
                {copyitem ? (
                  <Box>
                    {copyitem}
                    <Button
                      ml={1}
                      icon="eject"
                      onClick={() => act('remove')}
                    >
                      Remove
                    </Button>
                  </Box>
                ) : (
                  <Box color="label">Insert paper to send.</Box>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Destination">
                <Dropdown
                  selected={destination ?? ''}
                  options={departments}
                  placeholder="Select destination..."
                  menuWidth={20}
                  onSelected={(value) => act('dept', { destination: value })}
                />
              </LabeledList.Item>
            </LabeledList>
            <Box mt={1}>
              <Button
                icon="paper-plane"
                color="good"
                disabled={!copyitem || !destination}
                onClick={() => act('send')}
              >
                Send Fax
              </Button>
            </Box>
          </Section>
        ) : (
          <Section>
            {copyitem && (
              <Box mb={1}>
                <Box color="label">Document: {copyitem}</Box>
                <Button mt={0.5} icon="eject" onClick={() => act('remove')}>
                  Remove
                </Button>
              </Box>
            )}
            <NoticeBox>
              Authentication required. Insert an ID card and log in to send
              faxes.
            </NoticeBox>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
}
