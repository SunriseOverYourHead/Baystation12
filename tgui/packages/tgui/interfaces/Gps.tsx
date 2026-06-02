import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type GpsSignal = {
  gps_ref: string;
  gps_tag: string;
  is_special_gps_marker: BooleanLike;
  being_tracked: BooleanLike;
  coloured_square: string;
  area_name: string;
  direction: string;
  degrees: number;
  distX: number;
  distY: number;
  distance: number;
  local: BooleanLike;
  x: number;
  y: number;
};

type Data = {
  tracking: BooleanLike;
  gps_tag: string;
  my_area_name: string;
  hide_signal: BooleanLike;
  curr_x: number;
  curr_y: number;
  curr_z: number;
  local_mode: BooleanLike;
  can_hide_signal?: BooleanLike;
  no_signals?: BooleanLike;
  gps_list?: GpsSignal[];
};

export const Gps = () => {
  const { act, data } = useBackend<Data>();
  const {
    tracking,
    gps_tag,
    my_area_name,
    hide_signal,
    curr_x,
    curr_y,
    curr_z,
    local_mode,
    can_hide_signal,
    no_signals,
    gps_list,
  } = data;

  return (
    <Window title="GPS" width={500} height={300}>
      <Window.Content scrollable>
        <Section>
          <Button
            icon={tracking ? 'toggle-on' : 'toggle-off'}
            color={tracking ? 'good' : 'bad'}
            onClick={() => act('toggle_power')}
          >
            {tracking ? 'Switch Off' : 'Switch On'}
          </Button>
        </Section>
        {!!tracking && (
          <>
            <Section title="Location">
              <LabeledList>
                <LabeledList.Item label="Area">
                  {my_area_name} ({curr_x}, {curr_y}, {curr_z})
                </LabeledList.Item>
                <LabeledList.Item label="Broadcasting as">
                  {hide_signal ? `${gps_tag} (hidden)` : gps_tag}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Configuration">
              <Stack wrap>
                <Stack.Item>
                  <Button icon="tag" onClick={() => act('tag')}>
                    Change Tag
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon={local_mode ? 'compress' : 'expand'}
                    onClick={() => act('range')}
                  >
                    {local_mode ? 'Narrow Band' : 'Broad Band'}
                  </Button>
                </Stack.Item>
                {!!can_hide_signal && (
                  <Stack.Item>
                    <Button icon="eye-slash" onClick={() => act('hide')}>
                      Toggle Signal Visibility
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
            <Section title="Signals">
              {no_signals ? (
                <LabeledList>
                  <LabeledList.Item label="Status">
                    No signals detected.
                  </LabeledList.Item>
                </LabeledList>
              ) : (
                gps_list &&
                gps_list.map((gps) => (
                  <Section key={gps.gps_ref} title={`${gps.gps_tag} - ${gps.area_name}`}>
                    <LabeledList>
                      {gps.is_special_gps_marker ? (
                        gps.local ? (
                          <LabeledList.Item label="Position">
                            {gps.direction} Dist: {gps.distance}m
                          </LabeledList.Item>
                        ) : (
                          <LabeledList.Item label="Z-Level">
                            {gps.distY}
                          </LabeledList.Item>
                        )
                      ) : (
                        <LabeledList.Item label="Coordinates">
                          ({gps.x}, {gps.y})
                        </LabeledList.Item>
                      )}
                      {gps.local ? (
                        <LabeledList.Item label="Distance">
                          {gps.distance}m, {gps.direction}
                        </LabeledList.Item>
                      ) : (
                        <LabeledList.Item label="Signal">
                          Non-local signal.
                        </LabeledList.Item>
                      )}
                      <LabeledList.Item label="Tracking">
                        {gps.being_tracked ? (
                          <Stack wrap>
                            <Stack.Item>
                              <Button
                                color="bad"
                                onClick={() =>
                                  act('stop_track', {
                                    stop_track: gps.gps_ref,
                                  })
                                }
                              >
                                Stop Tracking
                              </Button>
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                onClick={() =>
                                  act('track_color', {
                                    track_color: gps.gps_ref,
                                  })
                                }
                              >
                                Color
                              </Button>
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                onClick={() =>
                                  act('track_label', {
                                    track_label: gps.gps_ref,
                                  })
                                }
                              >
                                Show/Hide Label
                              </Button>
                            </Stack.Item>
                          </Stack>
                        ) : (
                          <Button
                            color="good"
                            onClick={() =>
                              act('start_track', {
                                start_track: gps.gps_ref,
                              })
                            }
                          >
                            Start Tracking
                          </Button>
                        )}
                      </LabeledList.Item>
                    </LabeledList>
                  </Section>
                ))
              )}
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
