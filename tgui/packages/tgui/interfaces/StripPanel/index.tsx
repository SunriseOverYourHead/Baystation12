import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import type { StripPanelData } from './data';

export function StripPanel(props) {
  const { act, data } = useBackend<StripPanelData>();
  const {
    target_name,
    can_act,
    slots,
    has_pockets,
    hands,
    can_internals,
    has_internals_tank,
    internals_active,
    has_uniform,
    has_sensor,
    sensor_locked,
    can_lock_sensors,
    handcuffed,
    handcuffed_slot,
    webbed,
    underwear,
  } = data;

  return (
    <Window title={`Strip: ${target_name}`} width={420} height={560}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {!can_act && (
            <Stack.Item>
              <Box color="bad">
                You can't interact with {target_name} right now.
              </Box>
            </Stack.Item>
          )}
          <Stack.Item>
            <Section title="Worn Items">
              <LabeledList>
                {slots.map((slot) => (
                  <LabeledList.Item key={slot.slot} label={slot.name}>
                    <Button
                      fluid
                      disabled={!can_act || !slot.item_name}
                      onClick={() => act('strip', { slot: slot.slot })}
                    >
                      {slot.item_name || 'Empty'}
                    </Button>
                    {slot.accessories.map((accessory) => (
                      <Button
                        key={accessory}
                        ml={1}
                        icon="ribbon"
                        disabled={!can_act}
                        tooltip={`Remove ${accessory}`}
                        onClick={() =>
                          act('strip', {
                            slot: 'tie',
                            holder: slot.holder_ref,
                          })
                        }
                      >
                        {accessory}
                      </Button>
                    ))}
                  </LabeledList.Item>
                ))}
                {!!has_pockets && (
                  <LabeledList.Item label="Pockets">
                    <Button
                      fluid
                      disabled={!can_act}
                      onClick={() => act('strip', { slot: 'pockets' })}
                    >
                      Empty Pockets
                    </Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>
          {!!hands?.length && (
            <Stack.Item>
              <Section title="Hands">
                <LabeledList>
                  {hands.map((hand) => (
                    <LabeledList.Item key={hand.slot} label={hand.name}>
                      <Button
                        fluid
                        disabled={!can_act || !hand.item_name}
                        onClick={() => act('strip', { slot: hand.slot })}
                      >
                        {hand.item_name || 'Empty'}
                      </Button>
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
          {!!underwear.length && (
            <Stack.Item>
              <Section title="Underwear">
                <LabeledList>
                  {underwear.map((item) => (
                    <LabeledList.Item key={item.ref} label={item.name}>
                      <Button
                        fluid
                        color="bad"
                        disabled={!can_act}
                        onClick={() => act('strip', { slot: item.ref })}
                      >
                        Remove
                      </Button>
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item>
            <Section title="Miscellaneous">
              <LabeledList>
                {!!has_uniform && (
                  <LabeledList.Item label="Suit Sensors">
                    <Button
                      disabled={!can_act}
                      onClick={() => act('strip', { slot: 'sensors' })}
                    >
                      {has_sensor ? 'Cycle Mode' : 'No Sensors'}
                    </Button>
                    {!!has_sensor && (
                      <Button
                        ml={1}
                        icon={sensor_locked ? 'lock' : 'lock-open'}
                        selected={sensor_locked}
                        disabled={!can_act || !can_lock_sensors}
                        onClick={() => act('strip', { slot: 'lock_sensors' })}
                      >
                        {sensor_locked ? 'Locked' : 'Lock'}
                      </Button>
                    )}
                  </LabeledList.Item>
                )}
                {!!can_internals && (
                  <LabeledList.Item label="Internals">
                    <Button
                      selected={internals_active}
                      disabled={
                        !can_act || (!internals_active && !has_internals_tank)
                      }
                      onClick={() => act('strip', { slot: 'internals' })}
                    >
                      {internals_active ? 'Disable' : 'Enable'}
                    </Button>
                  </LabeledList.Item>
                )}
                {!!handcuffed && (
                  <LabeledList.Item label="Handcuffs">
                    <Button
                      color="bad"
                      disabled={!can_act}
                      onClick={() =>
                        act('strip', { slot: handcuffed_slot })
                      }
                    >
                      Remove
                    </Button>
                  </LabeledList.Item>
                )}
                {!!webbed && (
                  <LabeledList.Item label="Webbing">
                    <Button
                      color="bad"
                      disabled={!can_act}
                      onClick={() => act('remove_webbing')}
                    >
                      Remove
                    </Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
