import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type GasEntry = {
  percent: number;
  symbol: string;
};

type SensorInfo = {
  long_name: string;
  pressure?: number;
  temperature?: number;
};

type Data = {
  screen: number;
  systemname: string;
  sensors?: SensorInfo[];
  gasses?: GasEntry[];
  control: BooleanLike;
  automation: number;
  input_present: BooleanLike;
  in_power: BooleanLike;
  atmos_volume: number;
  input_flow_setting: number;
  output_present: BooleanLike;
  out_power: BooleanLike;
  max_pump_pressure: number;
  out_pressure_setting: number;
  external_pressure: number;
  out_pressure_mode: BooleanLike;
  frequency: number | string;
  input_tag: string;
  output_tag: string;
  sensor_tag: string;
  sensor_name: string;
};

export const AtmosConsole = () => {
  const { act, data } = useBackend<Data>();
  const { screen, systemname } = data;

  return (
    <Window title={systemname || 'Atmospherics Console'} width={800} height={800}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={screen === 1}
            onClick={() => act('set_screen', { set_screen: 1 })}
          >
            Data
          </Tabs.Tab>
          <Tabs.Tab
            selected={screen === 2}
            icon="cog"
            onClick={() => act('set_screen', { set_screen: 2 })}
          >
            Settings
          </Tabs.Tab>
        </Tabs>
        {screen === 1 && <AtmosConsoleData />}
        {screen === 2 && <AtmosConsoleSettings />}
      </Window.Content>
    </Window>
  );
};

function AtmosConsoleData() {
  const { act, data } = useBackend<Data>();
  const {
    sensors,
    gasses,
    control,
    automation,
    input_present,
    in_power,
    atmos_volume,
    input_flow_setting,
    output_present,
    out_power,
    max_pump_pressure,
    out_pressure_setting,
    external_pressure,
    out_pressure_mode,
  } = data;

  return (
    <>
      <Section title="Sensor Readings">
        {sensors && sensors.length > 0 ? (
          sensors.map((sensor, i) => (
            <Box key={i} mb={1}>
              <Box bold>{sensor.long_name}</Box>
              {sensor.pressure !== undefined && (
                <Box>Pressure: {sensor.pressure} kPa</Box>
              )}
              {sensor.temperature !== undefined && (
                <Box>Temperature: {sensor.temperature} K</Box>
              )}
              {gasses && gasses.length > 0 && (
                <Box mt={0.5}>
                  <Box bold>Gas Composition:</Box>
                  {gasses.map((gas, gi) => (
                    <Box key={gi}>
                      {gas.percent}% {gas.symbol}
                    </Box>
                  ))}
                </Box>
              )}
              {gasses && gasses.length === 0 && <Box>No gasses detected.</Box>}
            </Box>
          ))
        ) : (
          <Box color="label">There are no connected sensors.</Box>
        )}
      </Section>
      {!!control && (
        <Section title="Tank Control System">
          <Table>
            {automation === 1 && (
              <Table.Row>
                <Table.Cell>Automation Status:</Table.Cell>
                <Table.Cell color="good">Online</Table.Cell>
                <Table.Cell>
                  <Button onClick={() => act('toggle_automation')}>
                    Toggle Automation
                  </Button>
                </Table.Cell>
              </Table.Row>
            )}
            {automation === 0 && (
              <Table.Row>
                <Table.Cell>Automation Status:</Table.Cell>
                <Table.Cell color="bad">Offline</Table.Cell>
                <Table.Cell>
                  <Button onClick={() => act('toggle_automation')}>
                    Toggle Automation
                  </Button>
                </Table.Cell>
              </Table.Row>
            )}
            {input_present ? (
              <>
                <Table.Row>
                  <Table.Cell bold>Input:</Table.Cell>
                  <Table.Cell color={in_power ? 'good' : 'bad'}>
                    {in_power ? 'Injecting' : 'On Hold'}
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Flow Rate Limit:</Table.Cell>
                  <Table.Cell>{atmos_volume} L/s</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Flow Rate:</Table.Cell>
                  <Table.Cell>{input_flow_setting} L/s</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Command:</Table.Cell>
                  <Table.Cell>
                    <Button icon="power-off" onClick={() => act('in_toggle_injector')}>
                      Toggle Power
                    </Button>
                    <Button onClick={() => act('in_set_flowrate')}>
                      Set Flow Rate
                    </Button>
                    <Button onClick={() => act('in_set_max')}>Max Flow</Button>
                    <Button onClick={() => act('in_refresh_status')}>
                      Refresh
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </>
            ) : (
              <>
                <Table.Row>
                  <Table.Cell color="bad">ERROR: Cannot find input port</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Command:</Table.Cell>
                  <Table.Cell>
                    <Button disabled icon="power-off">Toggle Power</Button>
                    <Button disabled>Set Flow Rate</Button>
                    <Button disabled>Max Flow</Button>
                    <Button onClick={() => act('in_refresh_status')}>
                      Refresh
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </>
            )}
            {!!out_pressure_mode ? (
              output_present ? (
                <>
                  <Table.Row>
                    <Table.Cell bold>Output:</Table.Cell>
                    <Table.Cell color={out_power ? 'good' : 'bad'}>
                      {out_power ? 'Open' : 'On Hold'}
                    </Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell bold>Min Chamber Pressure:</Table.Cell>
                    <Table.Cell>{external_pressure} kPa</Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell bold>Command:</Table.Cell>
                    <Table.Cell>
                      <Button icon="power-off" onClick={() => act('out_toggle_power')}>
                        Toggle Power
                      </Button>
                      <Button onClick={() => act('s_out_set_pressure')}>
                        Set Pressure
                      </Button>
                      <Button onClick={() => act('s_set_default')}>
                        Default Pressure
                      </Button>
                      <Button onClick={() => act('out_refresh_status')}>
                        Refresh
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                </>
              ) : null
            ) : output_present ? (
              <>
                <Table.Row>
                  <Table.Cell bold>Output:</Table.Cell>
                  <Table.Cell color={out_power ? 'good' : 'bad'}>
                    {out_power ? 'Open' : 'On Hold'}
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Max Output Pressure:</Table.Cell>
                  <Table.Cell>{max_pump_pressure} kPa</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Output Pressure:</Table.Cell>
                  <Table.Cell>{out_pressure_setting} kPa</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Command:</Table.Cell>
                  <Table.Cell>
                    <Button icon="power-off" onClick={() => act('out_toggle_power')}>
                      Toggle Power
                    </Button>
                    <Button onClick={() => act('out_set_pressure')}>
                      Set Pressure
                    </Button>
                    <Button onClick={() => act('out_set_max')}>
                      Max Pressure
                    </Button>
                    <Button onClick={() => act('out_refresh_status')}>
                      Refresh
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </>
            ) : (
              <>
                <Table.Row>
                  <Table.Cell color="bad">ERROR: Cannot find output port</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Command:</Table.Cell>
                  <Table.Cell>
                    <Button disabled icon="power-off">Toggle Power</Button>
                    <Button disabled>Set Pressure</Button>
                    <Button disabled>Default Pressure</Button>
                    <Button onClick={() => act('out_refresh_status')}>
                      Refresh
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </>
            )}
          </Table>
        </Section>
      )}
    </>
  );
}

function AtmosConsoleSettings() {
  const { act, data } = useBackend<Data>();
  const {
    frequency,
    input_tag,
    output_tag,
    sensor_tag,
    sensor_name,
    out_pressure_mode,
  } = data;

  return (
    <Section title="Console Settings">
      <Table>
        <Table.Row>
          <Table.Cell bold>Frequency:</Table.Cell>
          <Table.Cell>{frequency}</Table.Cell>
          <Table.Cell>
            <Button icon="pencil-alt" onClick={() => act('set_frequency')} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold>Input Tag:</Table.Cell>
          <Table.Cell>{input_tag}</Table.Cell>
          <Table.Cell>
            <Button icon="pencil-alt" onClick={() => act('set_input_tag')} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold>Output Tag:</Table.Cell>
          <Table.Cell>{output_tag}</Table.Cell>
          <Table.Cell>
            <Button icon="pencil-alt" onClick={() => act('set_output_tag')} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold>Sensor Name:</Table.Cell>
          <Table.Cell>{sensor_name}</Table.Cell>
          <Table.Cell>
            <Button icon="pencil-alt" onClick={() => act('set_sensor_name')} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold>Sensor Tag:</Table.Cell>
          <Table.Cell>{sensor_tag}</Table.Cell>
          <Table.Cell>
            <Button icon="pencil-alt" onClick={() => act('set_sensor_tag')} />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell bold>Pressure Mode:</Table.Cell>
          <Table.Cell>{out_pressure_mode ? 'External' : 'Internal'}</Table.Cell>
          <Table.Cell>
            <Button onClick={() => act('toggle_pressure_mode')}>Toggle</Button>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
}
