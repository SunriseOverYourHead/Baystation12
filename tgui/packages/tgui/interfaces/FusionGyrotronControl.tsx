import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Gyrotron = {
  id: string;
  ref: string;
  active: BooleanLike;
  firedelay: number;
  energy: number;
};

type Data = {
  id: string;
  name: string;
  gyrotrons: Gyrotron[];
};

export const FusionGyrotronControl = () => {
  const { act, data } = useBackend<Data>();
  const { id, name, gyrotrons = [] } = data;

  return (
    <Window title={name} width={400} height={500}>
      <Window.Content scrollable>
        <Section title={`Fusion Plant: ${id}`}>
          {gyrotrons.length === 0 ? (
            <NoticeBox>No gyrotrons connected.</NoticeBox>
          ) : (
            gyrotrons.map((g) => (
              <Section key={g.ref} title={g.id}>
                <LabeledList>
                  <LabeledList.Item label="Status">
                    <Box inline color={g.active ? 'good' : 'bad'}>
                      {g.active ? 'Online.' : 'Offline.'}
                    </Box>
                    <Button
                      ml={1}
                      color={g.active ? 'bad' : 'good'}
                      onClick={() => act('toggle', { machine: g.ref })}
                    >
                      {g.active ? 'Shut down' : 'Start up'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Fire delay">
                    {g.firedelay} s
                    <Button.Input
                      ml={1}
                      buttonText="Set"
                      tooltip="Enter new delay between 2 and 10 seconds"
                      onCommit={(val) =>
                        act('modifyrate', { machine: g.ref, value: val })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Power output">
                    {g.energy}
                    <Button.Input
                      ml={1}
                      buttonText="Set"
                      tooltip="Enter new emission power level (1 - 50)"
                      onCommit={(val) =>
                        act('modifypower', { machine: g.ref, value: val })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
