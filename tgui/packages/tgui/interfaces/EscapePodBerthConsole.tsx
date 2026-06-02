import { Box, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  docking_status: string;
  override_enabled: BooleanLike;
  armed: BooleanLike | null;
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

export const EscapePodBerthConsole = () => {
  const { data } = useBackend<Data>();
  const { docking_status, override_enabled, armed } = data;

  return (
    <Window title="Escape Pod Berth Console" width={470} height={220}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Docking Status">
              <Box color={dockingStatusColor(docking_status)}>
                {dockingStatusText(docking_status)}
                {!!override_enabled && ' (OVERRIDE)'}
              </Box>
            </LabeledList.Item>
            {armed !== null && (
              <LabeledList.Item label="Berth Status">
                <Box color={armed ? 'bad' : 'good'}>
                  {armed ? 'Armed — Pod Launched' : 'Ready'}
                </Box>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        {!!armed && (
          <NoticeBox danger>
            This berth has been armed. The escape pod has launched.
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};
