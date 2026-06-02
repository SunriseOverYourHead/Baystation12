import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type KnownContact = {
  name: string;
  color: string;
  ref: string;
  bearing: number;
};

type UnknownContact = {
  name: string;
  bearing: number;
  variability: number;
  progress: number;
};

type LastScan = {
  name: string;
  location: string;
  data: string[];
};

type Data = {
  on: BooleanLike;
  range: number | string;
  heat: number;
  critical_heat: number;
  health: number;
  max_health: number;
  status: string;
  muted: BooleanLike;
  sound_off: BooleanLike;
  viewing: BooleanLike;
  viewing_silicon: BooleanLike;
  known_contacts?: KnownContact[];
  unknown_contacts?: UnknownContact[];
  last_scan?: LastScan;
};

export const ShipSensors = () => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    range,
    heat,
    critical_heat,
    health,
    max_health,
    status,
    muted,
    sound_off,
    viewing,
    viewing_silicon,
    known_contacts,
    unknown_contacts,
    last_scan,
  } = data;

  const heatRatio = heat / critical_heat;
  const heatColor =
    heatRatio < 0.5 ? 'good' : heatRatio < 0.75 ? 'average' : 'bad';
  const heatLabel =
    heatRatio < 0.5
      ? 'Temperature low.'
      : heatRatio < 0.75
        ? 'Sensor temperature high!'
        : 'TEMPERATURE CRITICAL: Disable or reduce power immediately!';

  return (
    <Window title="Sensors Control" width={420} height={530}>
      <Window.Content scrollable>
        {!!viewing_silicon && (
          <Box color="bad" bold mb={1}>
            Remote AI systems detected. Firewall protections forbid remote AI
            control.
          </Box>
        )}
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon="power-off"
                color={on ? 'good' : 'default'}
                disabled={status === 'MISSING'}
                onClick={() => act('toggle')}
              >
                {on ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Range">
              <Button onClick={() => act('range')}>{range}</Button>
            </LabeledList.Item>
            <LabeledList.Item label="Sector map view">
              <Button
                color={viewing ? 'good' : 'default'}
                onClick={() => act('viewing')}
              >
                {viewing ? 'Engaged' : 'Disengaged'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Contact readout">
              <Button
                icon={muted ? 'volume-mute' : 'volume-up'}
                onClick={() => act('mute')}
              >
                {muted ? 'Disabled' : 'Enabled'}
              </Button>
              <Button
                icon="volume-mute"
                color={sound_off ? 'bad' : 'default'}
                onClick={() => act('sound_off')}
              >
                Sound {sound_off ? 'Off' : 'On'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Status">{status}</LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <Stack>
                <Stack.Item grow>
                  <ProgressBar value={heat} minValue={0} maxValue={critical_heat} color={heatColor} />
                </Stack.Item>
                <Stack.Item>
                  <Box color={heatColor}>{heatLabel}</Box>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Contacts">
          {(!known_contacts || known_contacts.length === 0) &&
          (!unknown_contacts || unknown_contacts.length === 0) ? (
            <Box color="label">None</Box>
          ) : (
            <Table>
              {known_contacts?.map((contact) => (
                <Table.Row key={contact.ref}>
                  <Table.Cell>
                    <Button
                      icon="search"
                      onClick={() => act('scan', { scan: contact.ref })}
                    >
                      Scan
                    </Button>
                  </Table.Cell>
                  <Table.Cell>
                    <Box as="span" style={{ color: contact.color }}>
                      {contact.name}
                    </Box>
                    {', bearing '}
                    {contact.bearing}
                  </Table.Cell>
                </Table.Row>
              ))}
              {unknown_contacts?.map((contact, i) => (
                <Table.Row key={i}>
                  <Table.Cell>
                    <Box>
                      {contact.progress}% - {contact.name}, bearing{' '}
                      {contact.bearing} +/- {contact.variability}
                    </Box>
                    <ProgressBar
                      value={contact.progress}
                      minValue={0}
                      maxValue={100}
                      color="good"
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
        <Section title="Scan data">
          {last_scan ? (
            <>
              <Stack mb={1}>
                <Stack.Item>
                  <Button icon="print" onClick={() => act('print')}>
                    Print
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Box as="b">{last_scan.name}</Box> at {last_scan.location}
                </Stack.Item>
              </Stack>
              {last_scan.data.map((entry, i) => (
                <Box key={i} mb={1}>
                  {entry}
                </Box>
              ))}
            </>
          ) : (
            <Box color="label">N/A</Box>
          )}
        </Section>
        {status === 'MISSING' && (
          <Button icon="cog" onClick={() => act('link')}>
            Link up with the sensor suite
          </Button>
        )}
      </Window.Content>
    </Window>
  );
};
