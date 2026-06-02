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

type Injector = {
  id: string;
  ref: string;
  injecting: BooleanLike;
  fueltype: string;
  depletion: string;
  injection_rate: string;
};

type Data = {
  id: string;
  name: string;
  injectors: Injector[];
};

export const FusionFuelControl = () => {
  const { act, data } = useBackend<Data>();
  const { id, name, injectors = [] } = data;

  return (
    <Window title={name} width={400} height={600}>
      <Window.Content scrollable>
        <Section title={`Fusion Plant: ${id}`}>
          <Box mb={1}>
            <Button icon="toggle-on" onClick={() => act('global_toggle')}>
              Toggle All
            </Button>
            <Button.Input
              ml={1}
              buttonText="Set Rate for All"
              tooltip="Enter injection rate 1-100 for all injectors"
              onCommit={(val) => act('global_rate', { value: val })}
            />
          </Box>

          {injectors.length === 0 ? (
            <NoticeBox>No fuel injectors connected.</NoticeBox>
          ) : (
            injectors.map((inj) => (
              <Section key={inj.ref} title={inj.id}>
                <LabeledList>
                  <LabeledList.Item label="Status">
                    <Box inline color={inj.injecting ? 'good' : 'bad'}>
                      {inj.injecting ? 'Online.' : 'Offline.'}
                    </Box>
                    <Button
                      ml={1}
                      color={inj.injecting ? 'bad' : 'good'}
                      onClick={() =>
                        act('toggle_injecting', {
                          toggle_injecting: inj.ref,
                        })
                      }
                    >
                      {inj.injecting ? 'Shut down' : 'Start up'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Injection rate">
                    {inj.injection_rate}
                    <Button.Input
                      ml={1}
                      buttonText="Set"
                      tooltip="Enter rate 1-100"
                      onCommit={(val) =>
                        act('injection_rate', {
                          machine: inj.ref,
                          value: val,
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Fuel material">
                    {inj.fueltype}
                  </LabeledList.Item>
                  <LabeledList.Item label="Fuel depletion">
                    {inj.depletion}
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
