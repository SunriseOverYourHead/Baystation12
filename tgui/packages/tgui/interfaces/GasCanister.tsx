import { Box, Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type HoldingTank = {
  name: string;
  tankPressure: number;
};

type Data = {
  name: string;
  canLabel: BooleanLike;
  portConnected: BooleanLike;
  tankPressure: number;
  releasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  valveOpen: BooleanLike;
  hasHoldingTank: BooleanLike;
  holdingTank: HoldingTank | null;
};

export const GasCanister = () => {
  const { act, data } = useBackend<Data>();
  const {
    name,
    canLabel,
    portConnected,
    tankPressure,
    releasePressure,
    minReleasePressure,
    maxReleasePressure,
    valveOpen,
    hasHoldingTank,
    holdingTank,
  } = data;

  return (
    <Window title="Canister" width={480} height={400}>
      <Window.Content>
        <Section title="Tank Status">
          <LabeledList>
            <LabeledList.Item label="Tank Label">
              {name}
              <Button
                ml={1}
                icon="pencil-alt"
                disabled={!canLabel}
                onClick={() => act('relabel')}
              >
                Relabel
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Tank Pressure">
              {tankPressure} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Port Status">
              <Box color={portConnected ? 'good' : 'average'}>
                {portConnected ? 'Connected' : 'Disconnected'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Holding Tank Status"
          buttons={
            !!hasHoldingTank && (
              <Button icon="eject" onClick={() => act('remove_tank')}>
                Eject
              </Button>
            )
          }
        >
          {hasHoldingTank && holdingTank ? (
            <LabeledList>
              <LabeledList.Item label="Tank Label">
                {holdingTank.name}
              </LabeledList.Item>
              <LabeledList.Item label="Tank Pressure">
                {holdingTank.tankPressure} kPa
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="average">
              <i>No holding tank inserted.</i>
            </Box>
          )}
        </Section>
        <Section title="Release Valve Status">
          <LabeledList>
            <LabeledList.Item label="Release Pressure">
              <ProgressBar
                value={releasePressure}
                minValue={minReleasePressure}
                maxValue={maxReleasePressure}
              />
              <Button
                disabled={releasePressure <= minReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -1000 })}
              >
                ---
              </Button>
              <Button
                disabled={releasePressure <= minReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -100 })}
              >
                --
              </Button>
              <Button
                disabled={releasePressure <= minReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -10 })}
              >
                -
              </Button>
              <Button
                disabled={releasePressure <= minReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -1 })}
              >
                &minus;
              </Button>
              <Box inline mx={1}>
                {releasePressure} kPa
              </Box>
              <Button
                disabled={releasePressure >= maxReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 1 })}
              >
                +
              </Button>
              <Button
                disabled={releasePressure >= maxReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 10 })}
              >
                ++
              </Button>
              <Button
                disabled={releasePressure >= maxReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 100 })}
              >
                +++
              </Button>
              <Button
                disabled={releasePressure >= maxReleasePressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 1000 })}
              >
                ++++
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Release Valve">
              <Button
                selected={!!valveOpen}
                color={valveOpen ? 'good' : 'bad'}
                onClick={() => act('toggle_valve')}
              >
                {valveOpen ? 'Open' : 'Closed'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
