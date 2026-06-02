import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type HoldingTank = {
  name: string;
  tankPressure: number;
};

type Data = {
  tankPressure: number;
  portConnected: BooleanLike;
  powerDraw: number;
  cellCharge: number;
  cellMaxCharge: number;
  hasHoldingTank: BooleanLike;
  holdingTank: HoldingTank | null;
  targetpressure: number;
  minpressure: number;
  maxpressure: number;
  on: BooleanLike;
  pump_dir: BooleanLike;
};

export const PortablePump = () => {
  const { act, data } = useBackend<Data>();
  const {
    tankPressure,
    portConnected,
    powerDraw,
    cellCharge,
    cellMaxCharge,
    hasHoldingTank,
    holdingTank,
    targetpressure,
    minpressure,
    maxpressure,
    on,
    pump_dir,
  } = data;

  return (
    <Window title="Portable Pump" width={480} height={410}>
      <Window.Content>
        <Section title="Pump Status">
          <LabeledList>
            <LabeledList.Item label="Tank Pressure">
              {tankPressure} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Port Status">
              <Box color={portConnected ? 'good' : 'average'}>
                {portConnected ? 'Connected' : 'Disconnected'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Load">{powerDraw} W</LabeledList.Item>
            <LabeledList.Item label="Cell Charge">
              <ProgressBar
                value={cellCharge}
                minValue={0}
                maxValue={cellMaxCharge}
                color={
                  cellCharge / cellMaxCharge > 0.5
                    ? 'good'
                    : cellCharge / cellMaxCharge > 0.25
                      ? 'average'
                      : 'bad'
                }
              />
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
        <Section title="Power Regulator">
          <LabeledList>
            <LabeledList.Item label="Target Pressure">
              <ProgressBar
                value={targetpressure}
                minValue={minpressure}
                maxValue={maxpressure}
              />
              <Button
                disabled={targetpressure <= minpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -1000 })}
              >
                ---
              </Button>
              <Button
                disabled={targetpressure <= minpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -100 })}
              >
                --
              </Button>
              <Button
                disabled={targetpressure <= minpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -10 })}
              >
                -
              </Button>
              <Button
                disabled={targetpressure <= minpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: -1 })}
              >
                &minus;
              </Button>
              <Box inline mx={1}>
                {targetpressure} kPa
              </Box>
              <Button
                disabled={targetpressure >= maxpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 1 })}
              >
                +
              </Button>
              <Button
                disabled={targetpressure >= maxpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 10 })}
              >
                ++
              </Button>
              <Button
                disabled={targetpressure >= maxpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 100 })}
              >
                +++
              </Button>
              <Button
                disabled={targetpressure >= maxpressure}
                onClick={() => act('adjust_pressure', { pressure_adj: 1000 })}
              >
                ++++
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Power Switch">
              <Button
                selected={!!on}
                color={on ? 'good' : 'bad'}
                onClick={() => act('toggle_power')}
              >
                {on ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Pump Direction">
              <Button
                selected={!!pump_dir}
                onClick={() => act('toggle_direction')}
              >
                {pump_dir ? 'Out' : 'In'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
