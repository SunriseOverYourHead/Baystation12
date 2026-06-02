import { Box, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type CircData = {
  dir: string;
  output: number;
  flowCapacity: number;
  inletPressure: number;
  inletTemperature: number;
  outletPressure: number;
  outletTemperature: number;
};

type Data = {
  totalOutput: number;
  maxTotalOutput: number;
  thermalOutput: number;
  circConnected: BooleanLike;
  primary: CircData | null;
  secondary: CircData | null;
};

function CirculatorSection(props: { circ: CircData; label: string }) {
  const { circ, label } = props;
  return (
    <Section title={label}>
      <LabeledList>
        <LabeledList.Item label="Turbine Output">
          {circ.output.toFixed(1)} kW
        </LabeledList.Item>
        <LabeledList.Item label="Flow Capacity">
          {circ.flowCapacity.toFixed(1)} %
        </LabeledList.Item>
        <LabeledList.Item label="Inlet Pressure">
          {circ.inletPressure.toFixed(1)} kPa
        </LabeledList.Item>
        <LabeledList.Item label="Inlet Temperature">
          {circ.inletTemperature.toFixed(1)} K
        </LabeledList.Item>
        <LabeledList.Item label="Outlet Pressure">
          {circ.outletPressure.toFixed(1)} kPa
        </LabeledList.Item>
        <LabeledList.Item label="Outlet Temperature">
          {circ.outletTemperature.toFixed(1)} K
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

export const ThermoelectricGenerator = (props) => {
  const { data } = useBackend<Data>();
  const {
    totalOutput,
    maxTotalOutput,
    thermalOutput,
    circConnected,
    primary,
    secondary,
  } = data;

  return (
    <Window title="Thermoelectric Generator" width={450} height={500}>
      <Window.Content>
        <Section title="Output">
          <LabeledList>
            <LabeledList.Item label="Total Output">
              <ProgressBar value={maxTotalOutput > 0 ? totalOutput / maxTotalOutput : 0} />
              &nbsp;{totalOutput.toFixed(1)} kW
            </LabeledList.Item>
            <LabeledList.Item label="Thermal Output">
              {thermalOutput.toFixed(1)} kW
            </LabeledList.Item>
          </LabeledList>
        </Section>

        {circConnected ? (
          <Stack>
            <Stack.Item grow>
              {primary && (
                <CirculatorSection
                  circ={primary}
                  label={`Primary Circulator (${primary.dir})`}
                />
              )}
            </Stack.Item>
            <Stack.Item grow>
              {secondary && (
                <CirculatorSection
                  circ={secondary}
                  label={`Secondary Circulator (${secondary.dir})`}
                />
              )}
            </Stack.Item>
          </Stack>
        ) : (
          <Box color="bad" bold>
            ERROR: Both circulators must be connected!
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
