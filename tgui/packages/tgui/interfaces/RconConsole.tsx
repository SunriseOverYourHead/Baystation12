import {
  Box,
  Button,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SmesInfo = {
  RCON_tag: string;
  charge: number;
  input_set: BooleanLike;
  input_val: number;
  input_load: number;
  output_set: BooleanLike;
  output_val: number;
  output_load: number;
};

type BreakerInfo = {
  RCON_tag: string;
  enabled: BooleanLike;
};

type Data = {
  smes_info: SmesInfo[];
  breaker_info: BreakerInfo[];
  hide_smes: BooleanLike;
  hide_smes_details: BooleanLike;
  hide_breakers: BooleanLike;
};

export const RconConsole = () => {
  const { act, data } = useBackend<Data>();
  const { smes_info, breaker_info, hide_smes, hide_smes_details, hide_breakers } =
    data;

  return (
    <Window title="RCON Console" width={600} height={400}>
      <Window.Content scrollable>
        <Stack mb={1}>
          <Stack.Item>
            <Button
              icon="folder"
              onClick={() => act('hide_smes')}
            >
              Show/Hide SMES readings
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="folder"
              onClick={() => act('hide_smes_details')}
            >
              Show/Hide SMES controls
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="folder"
              onClick={() => act('hide_breakers')}
            >
              Show/Hide Breaker readings
            </Button>
          </Stack.Item>
        </Stack>
        {!!hide_smes ? (
          <Box bold mb={1}>
            SMES readings hidden.
          </Box>
        ) : (
          <Section title="Detected SMES units with RCON support">
            {smes_info.length === 0 ? (
              <Box color="label">No connected SMES units detected!</Box>
            ) : (
              smes_info.map((smes) => (
                <Box key={smes.RCON_tag} mb={1} className="candystripe" p={1}>
                  <Stack align="center">
                    <Stack.Item width="30%">{smes.RCON_tag}</Stack.Item>
                    <Stack.Item grow>
                      <ProgressBar
                        value={smes.charge}
                        minValue={0}
                        maxValue={100}
                        color={
                          smes.charge > 50
                            ? 'good'
                            : smes.charge > 25
                              ? 'average'
                              : 'bad'
                        }
                      >
                        {smes.charge}%
                      </ProgressBar>
                      {!hide_smes_details && (
                        <Box mt={0.5}>
                          <Stack>
                            <Stack.Item>
                              Input: {smes.input_val} kW -{' '}
                              {smes.input_set ? 'AUTO' : 'OFF'}
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="power-off"
                                onClick={() =>
                                  act('smes_in_toggle', {
                                    smes_in_toggle: smes.RCON_tag,
                                  })
                                }
                              />
                              <Button
                                icon="pencil-alt"
                                onClick={() =>
                                  act('smes_in_set', {
                                    smes_in_set: smes.RCON_tag,
                                  })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                          <Box>Input Load: {smes.input_load} kW</Box>
                          <Stack>
                            <Stack.Item>
                              Output: {smes.output_val} kW -{' '}
                              {smes.output_set ? 'ONLINE' : 'OFFLINE'}
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="power-off"
                                onClick={() =>
                                  act('smes_out_toggle', {
                                    smes_out_toggle: smes.RCON_tag,
                                  })
                                }
                              />
                              <Button
                                icon="pencil-alt"
                                onClick={() =>
                                  act('smes_out_set', {
                                    smes_out_set: smes.RCON_tag,
                                  })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                          <Box>Output Load: {smes.output_load} kW</Box>
                        </Box>
                      )}
                    </Stack.Item>
                  </Stack>
                </Box>
              ))
            )}
          </Section>
        )}
        {!!hide_breakers ? (
          <Box bold mb={1}>
            Breaker readings hidden.
          </Box>
        ) : (
          <Section title="Detected Breaker Boxes with RCON support">
            {breaker_info.length === 0 ? (
              <Box color="label">No connected Breaker Boxes detected!</Box>
            ) : (
              breaker_info.map((breaker) => (
                <Box key={breaker.RCON_tag} mb={1} className="candystripe" p={1}>
                  <Stack align="center">
                    <Stack.Item width="40%">{breaker.RCON_tag}</Stack.Item>
                    <Stack.Item>
                      <Box
                        as="span"
                        color={breaker.enabled ? 'good' : 'bad'}
                        bold
                      >
                        {breaker.enabled ? '[ENABLED]' : '[DISABLED]'}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="power-off"
                        onClick={() =>
                          act('toggle_breaker', {
                            toggle_breaker: breaker.RCON_tag,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
              ))
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
