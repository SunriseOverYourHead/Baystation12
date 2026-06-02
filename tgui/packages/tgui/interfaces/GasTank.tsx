import { Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  maxReleasePressure: number;
  valveOpen: BooleanLike;
  maskConnected: BooleanLike;
};

export const GasTank = () => {
  const { act, data } = useBackend<Data>();
  const {
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    maxReleasePressure,
    valveOpen,
    maskConnected,
  } = data;

  return (
    <Window title="Tank" width={500} height={300}>
      <Window.Content>
        <Section>
          {maskConnected ? (
            <Section color="good">This tank is connected to a mask.</Section>
          ) : (
            <Section color="average">This tank is NOT connected to a mask.</Section>
          )}
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
                  releasePressure >= 21
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
            <LabeledList.Item label="Mask Release Valve">
              <Button
                selected={!!valveOpen}
                disabled={!maskConnected}
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
