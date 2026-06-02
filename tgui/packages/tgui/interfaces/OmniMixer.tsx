import { Button, Section, Stack, Table } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Port = {
  dir: string;
  concentration: number;
  input: number;
  output: number;
  con_lock: number;
};

type Data = {
  power: number;
  config: number;
  ports: Port[];
  set_flow_rate: number;
  last_flow_rate: number;
};

export const OmniMixer = () => {
  const { act, data } = useBackend<Data>();
  const { power, config, ports = [], set_flow_rate, last_flow_rate } = data;

  return (
    <Window title="Omni Mixer Control" width={360} height={330}>
      <Window.Content>
        <Section>
          <Stack>
            <Stack.Item>
              <Button
                content={power ? 'On' : 'Off'}
                selected={!!power}
                disabled={!!config}
                onClick={() => act('power')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content="Configure"
                selected={!!config}
                onClick={() => act('configure')}
              />
            </Stack.Item>
          </Stack>
        </Section>
        <Section>
          {config ? (
            <>
              <Table>
                <Table.Row header>
                  <Table.Cell>Port</Table.Cell>
                  <Table.Cell>Input</Table.Cell>
                  <Table.Cell>Output</Table.Cell>
                  <Table.Cell>Concentration</Table.Cell>
                  <Table.Cell>Lock</Table.Cell>
                </Table.Row>
                {ports.map((port) => (
                  <Table.Row key={port.dir}>
                    <Table.Cell color="average">{port.dir} Port</Table.Cell>
                    <Table.Cell>
                      <Button
                        content=" "
                        selected={!!port.input}
                        disabled={!!port.output}
                        onClick={() =>
                          act('switch_mode', {
                            mode: port.input ? 'none' : 'in',
                            dir: port.dir,
                          })
                        }
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        content=" "
                        selected={!!port.output}
                        disabled={!!port.output}
                        onClick={() =>
                          !port.output &&
                          act('switch_mode', { mode: 'out', dir: port.dir })
                        }
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        content={
                          port.input
                            ? `${Math.round(port.concentration * 100)} %`
                            : '-'
                        }
                        disabled={!port.input}
                        onClick={() => act('switch_con', { dir: port.dir })}
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        content=" "
                        icon={port.con_lock ? 'lock' : 'unlock'}
                        selected={!!port.con_lock}
                        disabled={!port.input}
                        onClick={() => act('switch_conlock', { dir: port.dir })}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
              <Stack mt={1}>
                <Stack.Item>
                  Set Flow Rate Limit: {(set_flow_rate / 10).toFixed(1)} L/s
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content="Set Flow Rate Limit"
                    onClick={() => act('set_flow_rate')}
                  />
                </Stack.Item>
              </Stack>
            </>
          ) : (
            <>
              <Table>
                <Table.Row header>
                  <Table.Cell>Port</Table.Cell>
                  <Table.Cell>Mode</Table.Cell>
                  <Table.Cell>Concentration</Table.Cell>
                </Table.Row>
                {ports.map((port) => (
                  <Table.Row key={port.dir}>
                    <Table.Cell color="average">{port.dir} Port</Table.Cell>
                    <Table.Cell>
                      {port.input ? 'Input' : port.output ? 'Output' : 'Disabled'}
                    </Table.Cell>
                    <Table.Cell>
                      {port.input
                        ? `${Math.round(port.concentration * 100)} %`
                        : '-'}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
              <Stack mt={1}>
                <Stack.Item>
                  Flow Rate: {(last_flow_rate / 10).toFixed(1)} L/s
                </Stack.Item>
              </Stack>
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
