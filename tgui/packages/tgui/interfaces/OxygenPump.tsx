import { Box, Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  tankInstalled: BooleanLike;
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  maxReleasePressure: number;
  maskConnected: BooleanLike;
};

export const OxygenPump = () => {
  const { act, data } = useBackend<Data>();
  const {
    tankInstalled,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    maxReleasePressure,
    maskConnected,
  } = data;

  return (
    <Window title="Emergency Oxygen Pump" width={500} height={300}>
      <Window.Content>
        <Section>
          {maskConnected ? (
            <Box color="good">This pump is connected to a person.</Box>
          ) : (
            <Box color="average">This pump is NOT connected to a person.</Box>
          )}
        </Section>
        {tankInstalled ? (
          <Section title="Tank Status">
            <LabeledList>
              <LabeledList.Item label="Tank Pressure">
                <ProgressBar
                  value={tankPressure}
                  minValue={0}
                  maxValue={1013}
                  color={
                    tankPressure > 200
                      ? 'good'
                      : tankPressure > 100
                        ? 'average'
                        : 'bad'
                  }
                >
                  {tankPressure} kPa
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Mask Release Pressure">
                <ProgressBar
                  value={releasePressure}
                  minValue={0}
                  maxValue={maxReleasePressure}
                  color={
                    releasePressure >= 23
                      ? 'good'
                      : releasePressure >= 17
                        ? 'average'
                        : 'bad'
                  }
                >
                  {releasePressure} kPa
                </ProgressBar>
                <Button
                  disabled={releasePressure <= 0}
                  onClick={() => act('adjust_pressure', { dist_p: -10 })}
                >
                  --
                </Button>
                <Button
                  disabled={releasePressure <= 0}
                  onClick={() => act('adjust_pressure', { dist_p: -1 })}
                >
                  -
                </Button>
                <Button
                  disabled={releasePressure >= maxReleasePressure}
                  onClick={() => act('adjust_pressure', { dist_p: 1 })}
                >
                  +
                </Button>
                <Button
                  disabled={releasePressure >= maxReleasePressure}
                  onClick={() => act('adjust_pressure', { dist_p: 10 })}
                >
                  ++
                </Button>
                <Button
                  disabled={releasePressure >= maxReleasePressure}
                  onClick={() => act('adjust_pressure', { dist_p: 'max' })}
                >
                  Max
                </Button>
                <Button
                  disabled={releasePressure === defaultReleasePressure}
                  onClick={() => act('adjust_pressure', { dist_p: 'reset' })}
                >
                  Reset
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ) : (
          <Section>
            <Box color="average">This pump has no tank installed.</Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
