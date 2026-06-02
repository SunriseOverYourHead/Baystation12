import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Screen constants matching DM defines
const SCREEN_MAIN = 1;
const SCREEN_VENT = 2;
const SCREEN_SCRUB = 3;
const SCREEN_MODE = 4;
const SCREEN_SENSORS = 5;

// Rcon constants
const RCON_NO = 1;
const RCON_AUTO = 2;
const RCON_YES = 3;

type EnvEntry = {
  name: string;
  value: number;
  unit: string;
  danger_level: number;
};

type Vent = {
  id_tag: string;
  long_name: string;
  power: BooleanLike;
  checks: number;
  direction: string;
  external: number;
};

type ScrubberFilter = {
  name: string;
  id: string;
  val: BooleanLike;
};

type Scrubber = {
  id_tag: string;
  long_name: string;
  power: BooleanLike;
  scrubbing: string;
  panic: BooleanLike;
  filters: ScrubberFilter[];
};

type Mode = {
  name: string;
  mode: number;
  selected: BooleanLike;
  danger: BooleanLike;
};

type ThresholdSetting = {
  env: string;
  val: number;
  selected: number;
};

type Threshold = {
  name: string;
  settings: ThresholdSetting[];
};

type BreachData = {
  selected: number;
};

type Data = {
  locked: BooleanLike;
  remote_connection: BooleanLike;
  remote_access: BooleanLike;
  rcon: number;
  screen: number;
  mode: number;
  has_environment: BooleanLike;
  environment: EnvEntry[];
  total_danger: number;
  atmos_alarm: BooleanLike;
  fire_alarm: BooleanLike;
  target_temperature: string;
  // Screen-specific
  vents?: Vent[];
  scrubbers?: Scrubber[];
  modes?: Mode[];
  thresholds?: Threshold[];
  breach_data?: BreachData;
};

function dangerColor(level: number): string {
  if (level === 2) return 'bad';
  if (level === 1) return 'average';
  return 'good';
}

export function AirAlarm(props) {
  const { act, data } = useBackend<Data>();
  const {
    locked,
    remote_connection,
    remote_access,
    rcon,
    screen,
    has_environment,
    environment = [],
    total_danger,
    atmos_alarm,
    fire_alarm,
    target_temperature,
  } = data;

  const isLocked =
    (locked && !remote_connection) || (remote_connection && !remote_access);

  return (
    <Window title="Air Alarm" width={325} height={625}>
      <Window.Content scrollable>
        {/* Air Status */}
        <Section title="Air Status">
          {has_environment ? (
            <LabeledList>
              {environment.map((entry, i) => (
                <LabeledList.Item key={i} label={entry.name}>
                  <Box color={dangerColor(entry.danger_level)}>
                    {parseFloat(entry.value.toFixed(1))} {entry.unit}
                  </Box>
                </LabeledList.Item>
              ))}
              <LabeledList.Item label="Local Status">
                <Box color={dangerColor(total_danger)}>
                  {total_danger === 2
                    ? 'DANGER: Internals Required'
                    : total_danger === 1
                      ? 'Caution'
                      : 'Optimal'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Area Status">
                {atmos_alarm ? (
                  <Box color="bad">Atmosphere alert in area</Box>
                ) : fire_alarm ? (
                  <Box color="bad">Fire alarm in area</Box>
                ) : (
                  'No alerts'
                )}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <NoticeBox danger>
              Warning: Cannot obtain air sample for analysis.
            </NoticeBox>
          )}
        </Section>

        {/* Remote Control & Thermostat */}
        <Section title="Remote Control">
          <Stack>
            <Stack.Item grow>
              <Box inline mr={1} color="label">
                Remote Control:
              </Box>
              <Button
                selected={rcon === RCON_NO}
                onClick={() => act('rcon', { rcon: RCON_NO })}
              >
                Off
              </Button>
              <Button
                selected={rcon === RCON_AUTO}
                onClick={() => act('rcon', { rcon: RCON_AUTO })}
              >
                Auto
              </Button>
              <Button
                selected={rcon === RCON_YES}
                onClick={() => act('rcon', { rcon: RCON_YES })}
              >
                On
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Box inline mr={1} color="label">
                Thermostat:
              </Box>
              <Button onClick={() => act('temperature')}>
                {target_temperature}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>

        {/* Locked notice or controls */}
        {isLocked ? (
          <NoticeBox>
            {remote_connection
              ? 'Current remote control settings and alarm status restricts access.'
              : 'Swipe ID card to unlock interface.'}
          </NoticeBox>
        ) : (
          <AlarmControls />
        )}
      </Window.Content>
    </Window>
  );
}

function AlarmControls(props) {
  const { act, data } = useBackend<Data>();
  const { screen, mode, atmos_alarm } = data;

  return (
    <>
      {/* Navigation tabs */}
      <Tabs>
        <Tabs.Tab
          selected={screen === SCREEN_MAIN}
          onClick={() => act('screen', { screen: SCREEN_MAIN })}
        >
          Main
        </Tabs.Tab>
        <Tabs.Tab
          selected={screen === SCREEN_VENT}
          onClick={() => act('screen', { screen: SCREEN_VENT })}
        >
          Vents
        </Tabs.Tab>
        <Tabs.Tab
          selected={screen === SCREEN_SCRUB}
          onClick={() => act('screen', { screen: SCREEN_SCRUB })}
        >
          Scrubbers
        </Tabs.Tab>
        <Tabs.Tab
          selected={screen === SCREEN_MODE}
          onClick={() => act('screen', { screen: SCREEN_MODE })}
        >
          Modes
        </Tabs.Tab>
        <Tabs.Tab
          selected={screen === SCREEN_SENSORS}
          onClick={() => act('screen', { screen: SCREEN_SENSORS })}
        >
          Sensors
        </Tabs.Tab>
      </Tabs>

      {screen === SCREEN_MAIN && <MainScreen />}
      {screen === SCREEN_VENT && <VentScreen />}
      {screen === SCREEN_SCRUB && <ScrubberScreen />}
      {screen === SCREEN_MODE && <ModeScreen />}
      {screen === SCREEN_SENSORS && <SensorScreen />}
    </>
  );
}

function MainScreen(props) {
  const { act, data } = useBackend<Data>();
  const { mode, atmos_alarm } = data;

  const PANIC_MODE = 3;

  return (
    <Section title="Main Controls">
      <Box mb={1}>
        {atmos_alarm ? (
          <Button
            icon="bell-slash"
            onClick={() => act('atmos_reset', { atmos_reset: 1 })}
          >
            Reset - Area Atmospheric Alarm
          </Button>
        ) : (
          <Button
            icon="bell"
            onClick={() => act('atmos_alarm', { atmos_alarm: 1 })}
          >
            Activate - Area Atmospheric Alarm
          </Button>
        )}
      </Box>
      <Box mb={1}>
        <Button onClick={() => act('screen', { screen: SCREEN_SCRUB })}>
          Scrubbers Control
        </Button>
        <Button onClick={() => act('screen', { screen: SCREEN_VENT })}>
          Vents Control
        </Button>
        <Button onClick={() => act('screen', { screen: SCREEN_MODE })}>
          Set Environmental Mode
        </Button>
        <Button onClick={() => act('screen', { screen: SCREEN_SENSORS })}>
          Sensor Settings
        </Button>
      </Box>
      {mode === PANIC_MODE ? (
        <Button
          color="bad"
          icon="wind"
          onClick={() => act('mode', { mode: 1 })}
        >
          PANIC SIPHON ACTIVE - Turn siphoning off
        </Button>
      ) : (
        <Button
          color="yellow"
          icon="wind"
          onClick={() => act('mode', { mode: PANIC_MODE })}
        >
          ACTIVATE PANIC SIPHON IN AREA
        </Button>
      )}
    </Section>
  );
}

function VentScreen(props) {
  const { act, data } = useBackend<Data>();
  const { vents = [] } = data;

  if (vents.length === 0) {
    return (
      <Section title="Vents">
        <Box color="label">No vents connected.</Box>
      </Section>
    );
  }

  return (
    <>
      {vents.map((vent) => (
        <Section key={vent.id_tag} title={vent.long_name}>
          <LabeledList>
            <LabeledList.Item label="Operating">
              <Button
                icon={vent.power ? 'power-off' : 'times'}
                color={vent.power ? 'good' : 'bad'}
                onClick={() =>
                  act('command', {
                    id_tag: vent.id_tag,
                    command: 'set_power',
                    val: vent.power ? 0 : 1,
                  })
                }
              >
                {vent.power ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Operation Mode">
              {vent.direction === 'siphon' ? 'Siphoning' : 'Pressurizing'}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure Checks">
              <Button
                selected={!!(vent.checks & 1)}
                icon={vent.checks & 1 ? 'check-square' : 'square'}
                onClick={() =>
                  act('command', {
                    id_tag: vent.id_tag,
                    command: 'set_checks',
                    val: vent.checks ^ 1,
                  })
                }
              >
                External
              </Button>
              <Button
                selected={!!(vent.checks & 2)}
                icon={vent.checks & 2 ? 'check-square' : 'square'}
                onClick={() =>
                  act('command', {
                    id_tag: vent.id_tag,
                    command: 'set_checks',
                    val: vent.checks ^ 2,
                  })
                }
              >
                Internal
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="External Pressure Bound">
              <Button
                onClick={() =>
                  act('command', {
                    id_tag: vent.id_tag,
                    command: 'set_external_pressure',
                  })
                }
              >
                {parseFloat(vent.external?.toFixed(2) ?? '0')}
              </Button>
              <Button
                onClick={() =>
                  act('command', {
                    id_tag: vent.id_tag,
                    command: 'reset_external_pressure',
                  })
                }
              >
                Reset
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
}

function ScrubberScreen(props) {
  const { act, data } = useBackend<Data>();
  const { scrubbers = [] } = data;

  if (scrubbers.length === 0) {
    return (
      <Section title="Scrubbers">
        <Box color="label">No scrubbers connected.</Box>
      </Section>
    );
  }

  return (
    <>
      {scrubbers.map((scrubber) => (
        <Section key={scrubber.id_tag} title={scrubber.long_name}>
          <LabeledList>
            <LabeledList.Item label="Operating">
              <Button
                icon={scrubber.power ? 'power-off' : 'times'}
                color={scrubber.power ? 'good' : 'bad'}
                onClick={() =>
                  act('command', {
                    id_tag: scrubber.id_tag,
                    command: 'set_power',
                    val: scrubber.power ? 0 : 1,
                  })
                }
              >
                {scrubber.power ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Operation Mode">
              <Button
                selected={scrubber.scrubbing === 'scrub'}
                onClick={() =>
                  act('command', {
                    id_tag: scrubber.id_tag,
                    command: 'set_scrubbing',
                    scrub_mode: 'scrub',
                  })
                }
              >
                Scrub
              </Button>
              <Button
                selected={scrubber.scrubbing === 'exchange'}
                onClick={() =>
                  act('command', {
                    id_tag: scrubber.id_tag,
                    command: 'set_scrubbing',
                    scrub_mode: 'exchange',
                  })
                }
              >
                Exchange
              </Button>
              <Button
                color={scrubber.scrubbing === 'siphon' ? 'bad' : undefined}
                selected={scrubber.scrubbing === 'siphon'}
                onClick={() =>
                  act('command', {
                    id_tag: scrubber.id_tag,
                    command: 'set_scrubbing',
                    scrub_mode: 'siphon',
                  })
                }
              >
                Siphon
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Filters">
              {(scrubber.filters || []).map((filter) => (
                <Button
                  key={filter.id}
                  selected={!!filter.val}
                  onClick={() =>
                    act('command', {
                      id_tag: scrubber.id_tag,
                      command: 'set_scrub_gas',
                      gas_id: filter.id,
                      val: filter.val ? 0 : 1,
                    })
                  }
                >
                  {filter.name}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
}

function ModeScreen(props) {
  const { act, data } = useBackend<Data>();
  const { modes = [] } = data;

  return (
    <Section title="Environmental Modes">
      {modes.map((m) => (
        <Box key={m.mode} mb={0.5}>
          <Button
            fluid
            color={
              m.selected ? (m.danger ? 'bad' : undefined) : undefined
            }
            selected={!!m.selected && !m.danger}
            onClick={() => act('mode', { mode: m.mode })}
          >
            {m.name}
          </Button>
        </Box>
      ))}
    </Section>
  );
}

function SensorScreen(props) {
  const { act, data } = useBackend<Data>();
  const { breach_data, thresholds = [] } = data;

  return (
    <>
      <Section title="Breach Threshold">
        <Box mb={0.5} color="label">
          Under this pressure, vents will be turned off.
        </Box>
        <Button onClick={() => act('command', { command: 'set_breach' })}>
          {breach_data && breach_data.selected >= 0
            ? parseFloat(breach_data.selected.toFixed(2))
            : 'Off'}
        </Button>
        {' kPa'}
      </Section>
      <Section title="Alarm Threshold">
        <Box mb={0.5} color="label">
          Partial pressure for gases.
        </Box>
        <Table>
          <Table.Row header>
            <Table.Cell />
            <Table.Cell color="bad">min2</Table.Cell>
            <Table.Cell color="average">min1</Table.Cell>
            <Table.Cell color="average">max1</Table.Cell>
            <Table.Cell color="bad">max2</Table.Cell>
          </Table.Row>
          {thresholds.map((threshold) => (
            <Table.Row key={threshold.name}>
              <Table.Cell>{threshold.name}</Table.Cell>
              {(threshold.settings || []).map((setting, j) => (
                <Table.Cell key={j}>
                  <Button
                    onClick={() =>
                      act('command', {
                        command: 'set_threshold',
                        env: setting.env,
                        var: setting.val,
                      })
                    }
                  >
                    {setting.selected >= 0
                      ? parseFloat(setting.selected.toFixed(2))
                      : 'Off'}
                  </Button>
                </Table.Cell>
              ))}
            </Table.Row>
          ))}
        </Table>
      </Section>
    </>
  );
}
