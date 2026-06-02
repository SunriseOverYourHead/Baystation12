import { Box, Button, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type CrewMember = {
  name: string;
  assignment: string;
  sensor_type: number;
  pulse: string;
  pulse_span: string;
  true_pulse: number;
  charge: number;
  charge_span: string;
  pressure: string;
  oxygenation: string;
  oxygenation_span: string;
  bodytemp: string;
  area: string;
  x: number;
  y: number;
  z: number;
  alert: BooleanLike;
  ref: string;
};

type Data = {
  isAI: BooleanLike;
  crewmembers: CrewMember[];
};

export const CrewMonitor = () => {
  const { act, data } = useBackend<Data>();
  const { isAI, crewmembers } = data;

  return (
    <Window title="Crew Monitoring Computer" width={1050} height={800}>
      <Window.Content scrollable>
        <Section fill>
          <Table>
            <Table.Row header>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Vitals</Table.Cell>
              <Table.Cell>Blood Pressure</Table.Cell>
              <Table.Cell>Temperature</Table.Cell>
              <Table.Cell>Location</Table.Cell>
              {!!isAI && <Table.Cell collapsing>Track</Table.Cell>}
            </Table.Row>
            {crewmembers.map((member, i) => (
              <Table.Row key={i} className="candystripe">
                <Table.Cell>
                  {member.name} ({member.assignment})
                </Table.Cell>
                <Table.Cell>
                  {member.sensor_type >= 2 ? (
                    member.pulse !== 'N/A' ? (
                      <Box>
                        <Box as="span" color="white">Pulse </Box>
                        <Box as="span" color={member.pulse_span}>
                          {member.pulse}
                          {member.true_pulse !== -1 && ' bpm'}
                        </Box>
                      </Box>
                    ) : member.charge_span !== 'N/A' ? (
                      <Box>
                        <Box as="span" color="white">Charge </Box>
                        <Box as="span" color={member.charge_span}>{member.charge}%</Box>
                      </Box>
                    ) : (
                      <Box>
                        <Box as="span" color="white">Pulse </Box>
                        <Box as="span" color="white">N/A</Box>
                      </Box>
                    )
                  ) : member.alert ? (
                    <Box color="bad">Medical issue detected</Box>
                  ) : (
                    'No issues detected'
                  )}
                </Table.Cell>
                <Table.Cell>
                  {member.sensor_type >= 2 && (
                    <Box>
                      <Box as="span" color="white">BP </Box>
                      {member.pressure}
                      {member.oxygenation && (
                        <Box as="span"> (
                          <Box as="span" color={member.oxygenation_span}>{member.oxygenation}</Box>
                          {' oxygenation)'}
                        </Box>
                      )}
                    </Box>
                  )}
                </Table.Cell>
                <Table.Cell>
                  {member.sensor_type >= 2 && (
                    <Box>
                      <Box as="span" color="white">Temp </Box>
                      {member.bodytemp} C
                    </Box>
                  )}
                </Table.Cell>
                <Table.Cell>
                  {member.sensor_type >= 3 ? (
                    <Box>
                      <Box as="span" color="white">Location </Box>
                      {member.area} ({member.x}, {member.y}, {member.z})
                    </Box>
                  ) : member.sensor_type === 2 ? (
                    <Box>
                      <Box as="span" color="white">Location </Box>
                      Not Available
                    </Box>
                  ) : null}
                </Table.Cell>
                {!!isAI && (
                  <Table.Cell collapsing>
                    <Button
                      disabled={member.sensor_type < 3}
                      onClick={() => act('track', { track: member.ref })}
                    >
                      Track
                    </Button>
                  </Table.Cell>
                )}
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
