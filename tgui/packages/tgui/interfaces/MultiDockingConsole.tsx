import { Box, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Airlock = {
  name: string;
  override_enabled: boolean;
};

type Data = {
  docking_status: string;
  airlocks: Airlock[];
};

function dockingStatusColor(status: string): string {
  if (status === 'docked') return 'good';
  if (status === 'docking' || status === 'undocking') return 'average';
  if (status === 'undocked') return 'label';
  return 'bad';
}

function dockingStatusText(status: string): string {
  if (status === 'docked') return 'DOCKED';
  if (status === 'docking') return 'DOCKING';
  if (status === 'undocking') return 'UNDOCKING';
  if (status === 'undocked') return 'NOT IN USE';
  return 'ERROR';
}

export function MultiDockingConsole(props) {
  const { data } = useBackend<Data>();
  const { docking_status, airlocks = [] } = data;

  return (
    <Window title="Docking Port Controller" width={470} height={290}>
      <Window.Content>
        <Section title="Docking Port Status">
          <Box color={dockingStatusColor(docking_status)}>
            {dockingStatusText(docking_status)}
          </Box>
        </Section>
        {airlocks.map((airlock, i) => (
          <Section key={i} title={airlock.name}>
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box color={airlock.override_enabled ? 'bad' : 'good'}>
                  {airlock.override_enabled ? 'OVERRIDE ENABLED' : 'STATUS OK'}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
}
