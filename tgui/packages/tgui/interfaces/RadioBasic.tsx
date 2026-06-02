import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Channel = {
  chan: string;
  display_name: string;
  chan_span: string;
  secure_channel?: BooleanLike;
  sec_channel_listen?: BooleanLike;
};

type Data = {
  power?: BooleanLike;
  mic_status: BooleanLike;
  speaker: BooleanLike;
  freq: string;
  default_freq?: string;
  rawfreq: string;
  charge?: string;
  mic_cut: BooleanLike;
  spk_cut: BooleanLike;
  chan_list?: Channel[];
  chan_list_len?: number;
  useSyndMode?: BooleanLike;
  has_loudspeaker?: BooleanLike;
  loudspeaker?: BooleanLike;
  has_subspace?: BooleanLike;
  subspace?: BooleanLike;
};

export const RadioBasic = () => {
  const { act, data } = useBackend<Data>();
  const {
    power,
    mic_status,
    speaker,
    freq,
    default_freq,
    rawfreq,
    charge,
    mic_cut,
    spk_cut,
    chan_list,
    chan_list_len,
    useSyndMode,
    has_loudspeaker,
    loudspeaker,
    has_subspace,
    subspace,
  } = data;

  return (
    <Window title="Radio" width={400} height={430}>
      <Window.Content scrollable>
        {!!useSyndMode && (
          <Section title="Syndicate Radio" color="bad">
            Syndicate Encrypted Transmission Active
          </Section>
        )}
        <Section>
          <LabeledList>
            {charge !== undefined && (
              <LabeledList.Item label="Power">
                <Button
                  selected={!!power}
                  onClick={() => act('power', { power: power ? 1 : 0 })}
                  color={power ? 'good' : 'bad'}
                >
                  {power ? 'On' : 'Off'}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Microphone">
              {mic_cut ? (
                <>
                  <Button disabled>On</Button>
                  <Button disabled>Off</Button>
                </>
              ) : (
                <>
                  <Button
                    selected={!!mic_status}
                    onClick={() => act('talk', { talk: 0 })}
                  >
                    On
                  </Button>
                  <Button
                    selected={!mic_status}
                    onClick={() => act('talk', { talk: 1 })}
                  >
                    Off
                  </Button>
                </>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Speaker">
              {spk_cut ? (
                <>
                  <Button disabled>On</Button>
                  <Button disabled>Off</Button>
                </>
              ) : (
                <>
                  <Button
                    selected={!!speaker}
                    onClick={() => act('listen', { listen: 0 })}
                  >
                    On
                  </Button>
                  <Button
                    selected={!speaker}
                    onClick={() => act('listen', { listen: 1 })}
                  >
                    Off
                  </Button>
                </>
              )}
            </LabeledList.Item>
            {!!has_subspace && (
              <LabeledList.Item label="Subspace Transmission">
                <Button
                  selected={!!subspace}
                  onClick={() => act('mode', { mode: 1 })}
                >
                  On
                </Button>
                <Button
                  selected={!subspace}
                  onClick={() => act('mode', { mode: 0 })}
                >
                  Off
                </Button>
              </LabeledList.Item>
            )}
            {!!has_loudspeaker && (
              <LabeledList.Item label="Loudspeaker">
                <Button
                  selected={!!loudspeaker}
                  onClick={() => act('shutup', { shutup: 0 })}
                >
                  On
                </Button>
                <Button
                  selected={!loudspeaker}
                  onClick={() => act('shutup', { shutup: 1 })}
                >
                  Off
                </Button>
              </LabeledList.Item>
            )}
            {charge !== undefined && (
              <LabeledList.Item label="Battery charge">
                {charge}
              </LabeledList.Item>
            )}
            <LabeledList.Item label={`Frequency: ${freq}`}>
              <Stack>
                <Stack.Item>
                  <Button onClick={() => act('freq', { freq: -10 })}>
                    --
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('freq', { freq: -2 })}>-</Button>
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('freq', { freq: 2 })}>+</Button>
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('freq', { freq: 10 })}>++</Button>
                </Stack.Item>
                {default_freq && (
                  <Stack.Item>
                    <Button onClick={() => act('default_freq', { default_freq: 1 })}>
                      {default_freq}
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!(chan_list_len && chan_list_len >= 1) && (
          <Section title="Channels">
            <LabeledList>
              {chan_list!.map((ch) => (
                <LabeledList.Item key={ch.chan} label={ch.display_name}>
                  {ch.secure_channel ? (
                    <>
                      <Button
                        selected={!ch.sec_channel_listen}
                        onClick={() =>
                          act('listen', {
                            ch_name: ch.chan,
                            listen: ch.sec_channel_listen,
                          })
                        }
                      >
                        On
                      </Button>
                      <Button
                        selected={!!ch.sec_channel_listen}
                        onClick={() =>
                          act('listen', {
                            ch_name: ch.chan,
                            listen: ch.sec_channel_listen,
                          })
                        }
                      >
                        Off
                      </Button>
                    </>
                  ) : (
                    <Button
                      selected={rawfreq === ch.chan}
                      onClick={() => act('spec_freq', { spec_freq: ch.chan })}
                    >
                      Switch
                    </Button>
                  )}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
