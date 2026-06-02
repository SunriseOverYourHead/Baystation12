import { Box, Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
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
  rate: number;
  minrate: number;
  maxrate: number;
  on: BooleanLike;
};

const cellChargeColor = (charge: number, max: number): string => {
  const ratio = charge / max;
  if (ratio > 0.5) return 'good';
  if (ratio > 0.25) return 'average';
  return 'bad';
};

export const PortableScrubber = () => {
  const { act, data } = useBackend<Data>();
  const {
    tankPressure,
    portConnected,
    powerDraw,
    cellCharge,
    cellMaxCharge,
    hasHoldingTank,
    holdingTank,
    rate,
    minrate,
    maxrate,
    on,
  } = data;

  return (
    <Window title="Portable Scrubber" width={480} height={400}>
      <Window.Content>
        <Section title="Scrubber Status">
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
                color={cellChargeColor(cellCharge, cellMaxCharge)}
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
            <LabeledList.Item label="Volume Rate">
              <ProgressBar
                value={rate}
                minValue={minrate}
                maxValue={maxrate}
              />
              <Button
                disabled={rate <= minrate}
                onClick={() => act('adjust_volume', { volume_adj: -1000 })}
              >
                ---
              </Button>
              <Button
                disabled={rate <= minrate}
                onClick={() => act('adjust_volume', { volume_adj: -100 })}
              >
                --
              </Button>
              <Button
                disabled={rate <= minrate}
                onClick={() => act('adjust_volume', { volume_adj: -10 })}
              >
                -
              </Button>
              <Button
                disabled={rate <= minrate}
                onClick={() => act('adjust_volume', { volume_adj: -1 })}
              >
                &minus;
              </Button>
              <Box inline mx={1}>
                {rate} L/s
              </Box>
              <Button
                disabled={rate >= maxrate}
                onClick={() => act('adjust_volume', { volume_adj: 1 })}
              >
                +
              </Button>
              <Button
                disabled={rate >= maxrate}
                onClick={() => act('adjust_volume', { volume_adj: 10 })}
              >
                ++
              </Button>
              <Button
                disabled={rate >= maxrate}
                onClick={() => act('adjust_volume', { volume_adj: 100 })}
              >
                +++
              </Button>
              <Button
                disabled={rate >= maxrate}
                onClick={() => act('adjust_volume', { volume_adj: 1000 })}
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
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
