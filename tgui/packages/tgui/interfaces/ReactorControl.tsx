import {
  Box,
  Button,
  Chart,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RodData = {
  ref: string;
  name: string;
  integrity: number;
};

type Data = {
  connected: BooleanLike;
  slagged: BooleanLike;
  isCritical: BooleanLike;
  loaded: BooleanLike;
  canUnload: BooleanLike;
  insertion: number;
  effectiveInsertion: number;
  criticalThreshold: number;
  power: number;
  thermalOutputMW: number;
  pressure: number;
  vesselIntegrity: number;
  fuelRods: RodData[];
  controlRods: RodData[];
  thermalOutputData: number[];
  pressureData: number[];
  coolantInData: number[];
  coolantOutData: number[];
};

const Graph = (props: {
  title: string;
  data: number[];
  color: string;
  unit?: string;
}) => {
  const { title, data, color, unit } = props;
  const points = data.map((value, i) => [i, value]);
  const maxValue = Math.max(10, ...data);
  const latest = data.length ? data[data.length - 1] : 0;

  return (
    <Stack.Item grow basis="0">
      <Section
        title={`${title} (${latest.toFixed(1)}${unit || ''})`}
        position="relative"
        fill
      >
        {points.length > 1 && (
          <Chart.Line
            fillPositionedParent
            data={points}
            rangeX={[0, points.length - 1]}
            rangeY={[0, maxValue]}
            strokeColor={color}
            fillColor={color.replace('1)', '0.25)')}
          />
        )}
      </Section>
    </Stack.Item>
  );
};

export const ReactorControl = () => {
  const { act, data } = useBackend<Data>();
  const {
    connected,
    slagged,
    isCritical,
    loaded,
    canUnload,
    insertion = 100,
    effectiveInsertion = 100,
    criticalThreshold = 0,
    power = 0,
    thermalOutputMW = 0,
    pressure = 0,
    vesselIntegrity = 100,
    fuelRods = [],
    controlRods = [],
    thermalOutputData = [],
    pressureData = [],
    coolantInData = [],
    coolantOutData = [],
  } = data;

  const degraded = effectiveInsertion < insertion;

  return (
    <Window title="Reactor Control" width={840} height={620}>
      <Window.Content>
        {!connected ? (
          <NoticeBox>No reactor linked - check the console's id_tag.</NoticeBox>
        ) : (
          <Stack fill>
            {!!slagged && (
              <NoticeBox danger>
                Reactor has melted down and is no longer operational.
              </NoticeBox>
            )}
            <Stack.Item grow basis="0">
              <Stack vertical fill>
                <Stack.Item>
                  <Section title="Reactivity">
                    <Stack vertical>
                      <Stack.Item>
                        <Box bold fontSize="1.1em">
                          Thermal output: {thermalOutputMW.toFixed(1)} MW
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <ProgressBar
                          value={power}
                          minValue={0}
                          maxValue={100}
                          color={power >= 90 ? 'bad' : power >= 60 ? 'average' : 'good'}
                        >
                          Core heat: {power.toFixed(0)}%
                        </ProgressBar>
                      </Stack.Item>
                      <Stack.Item>
                        <ProgressBar
                          value={vesselIntegrity}
                          minValue={0}
                          maxValue={100}
                          color={
                            vesselIntegrity <= 25
                              ? 'bad'
                              : vesselIntegrity <= 60
                                ? 'average'
                                : 'good'
                          }
                        >
                          Vessel integrity: {vesselIntegrity}%
                        </ProgressBar>
                      </Stack.Item>
                      <Stack.Item>
                        <Box color={isCritical ? 'bad' : 'good'} bold>
                          {isCritical ? 'CRITICAL' : 'Subcritical'}
                        </Box>
                        <Box color="label" fontSize="0.9em">
                          Critical below {criticalThreshold}% effective insertion
                        </Box>
                      </Stack.Item>
                      {!!degraded && (
                        <Stack.Item>
                          <NoticeBox danger>
                            Control rods degraded - dial shows {insertion}%, only{' '}
                            {effectiveInsertion}% is actually being delivered.
                          </NoticeBox>
                        </Stack.Item>
                      )}
                      <Stack.Item>
                        <Box mb={0.5}>
                          Control rod insertion: {insertion.toFixed(0)}%{' '}
                          <Box inline color="label">
                            (100% = fully inserted - 0% = fully withdrawn)
                          </Box>
                        </Box>
                        <Slider
                          value={insertion}
                          minValue={0}
                          maxValue={100}
                          step={1}
                          stepPixelSize={3}
                          disabled={!!slagged}
                          onChange={(e: Event, value: number) =>
                            act('set_insertion', { target: value })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          fluid
                          icon={loaded ? 'arrow-down' : 'arrow-up'}
                          color={loaded ? 'bad' : 'good'}
                          disabled={!!slagged || (!!loaded && !canUnload)}
                          onClick={() => act('toggle_loaded')}
                        >
                          {loaded
                            ? 'Unload Fuel Chamber'
                            : 'Load Fuel Chamber'}
                        </Button>
                        {!!loaded && !canUnload && (
                          <Box color="label" fontSize="0.85em" mt={0.3}>
                            Too hot to unload - wait for output to drop.
                          </Box>
                        )}
                        {!loaded && (
                          <Box color="label" fontSize="0.85em" mt={0.3}>
                            Chamber unloaded - no fission is occurring.
                          </Box>
                        )}
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>

                <Stack.Item grow>
                  <Section title="Fuel Rods" fill scrollable>
                    {fuelRods.length === 0 && (
                      <Box color="label">No fuel rods loaded.</Box>
                    )}
                    {fuelRods.map((rod) => (
                      <Stack key={rod.ref} mb={0.5}>
                        <Stack.Item grow>{rod.name}</Stack.Item>
                        <Stack.Item width="90px">
                          <ProgressBar value={rod.integrity} minValue={0} maxValue={100}>
                            {rod.integrity}%
                          </ProgressBar>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="eject"
                            disabled={!!loaded}
                            onClick={() => act('eject_fuel', { ref: rod.ref })}
                          />
                        </Stack.Item>
                      </Stack>
                    ))}
                  </Section>
                </Stack.Item>

                <Stack.Item grow>
                  <Section
                    title="Control Rods"
                    fill
                    scrollable
                    buttons={
                      <Box color="label" fontSize="0.85em">
                        hot-swappable
                      </Box>
                    }
                  >
                    {controlRods.length === 0 && (
                      <Box color="label">No control rods loaded.</Box>
                    )}
                    {controlRods.map((rod) => (
                      <Stack key={rod.ref} mb={0.5}>
                        <Stack.Item grow>{rod.name}</Stack.Item>
                        <Stack.Item width="90px">
                          <ProgressBar value={rod.integrity} minValue={0} maxValue={100}>
                            {rod.integrity}%
                          </ProgressBar>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="eject"
                            onClick={() => act('eject_control', { ref: rod.ref })}
                          />
                        </Stack.Item>
                      </Stack>
                    ))}
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item grow basis="0">
              <Stack vertical fill>
                <Stack.Item>
                  <Box bold fontSize="1.1em">
                    Thermal output: {thermalOutputMW.toFixed(1)} MW - Pressure: {pressure.toFixed(0)} kPa
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Stack fill>
                    <Graph
                      title="Thermal Output"
                      data={thermalOutputData}
                      color="rgba(224, 57, 151, 1)"
                      unit=" MW"
                    />
                    <Graph
                      title="Pressure"
                      data={pressureData}
                      color="rgba(230, 196, 0, 1)"
                      unit=" kPa"
                    />
                  </Stack>
                </Stack.Item>
                <Stack.Item grow>
                  <Stack fill>
                    <Graph
                      title="Coolant In"
                      data={coolantInData}
                      color="rgba(0, 181, 173, 1)"
                      unit="°C"
                    />
                    <Graph
                      title="Coolant Out"
                      data={coolantOutData}
                      color="rgba(211, 56, 41, 1)"
                      unit="°C"
                    />
                  </Stack>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
