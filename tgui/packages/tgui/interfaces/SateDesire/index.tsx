import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import type { SateDesireData } from './data';

const SPEED_OPTIONS = [
  { value: 1, label: 'Low' },
  { value: 2, label: 'Mid' },
  { value: 3, label: 'High' },
  { value: 4, label: 'Extreme' },
  { value: 5, label: 'Ludicrous' },
];

const FORCE_OPTIONS = SPEED_OPTIONS;

const MANUAL_AROUSAL_OPTIONS = [
  { value: 1, label: 'Automatic' },
  { value: 2, label: 'Unaroused' },
  { value: 3, label: 'Partially Aroused' },
  { value: 4, label: 'Fully Aroused' },
];

const CATEGORIES = [
  { value: 1, label: 'Misc' },
  { value: 2, label: 'Hands' },
  { value: 4, label: 'Penetrate' },
];

function labelFor(options: { value: number; label: string }[], value: number) {
  return options.find((option) => option.value === value)?.label || '???';
}

export function SateDesire(props) {
  const { act, data } = useBackend<SateDesireData>();
  const {
    arousal,
    max_arousal,
    charge,
    max_charge,
    speed,
    force,
    manual_arousal,
    do_until_finished,
    bottom_exposed,
    hide_genital_visuals,
    freeuse,
    do_subtle_action,
    action_category,
    target_name,
    self_targeted,
    current_action,
    actions,
    can_knot_partners,
    do_knot_action,
    knotted,
    knot_partner_name,
  } = data;

  return (
    <Window title="Sate Desire" width={480} height={560}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Status">
              <LabeledList>
                <LabeledList.Item label="Target">
                  <Box inline color={target_name ? 'good' : 'label'}>
                    {target_name || 'None'}
                    {self_targeted && ' (Self)'}
                  </Box>
                  <Button
                    ml={1}
                    icon="user"
                    onClick={() => act('target_self')}
                  >
                    Target Self
                  </Button>
                  <Button
                    ml={1}
                    icon="crosshairs"
                    onClick={() => act('pick_target')}
                  >
                    Pick Target
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Arousal">
                  <ProgressBar
                    value={arousal}
                    minValue={0}
                    maxValue={max_arousal}
                    color={arousal >= max_arousal * 0.7 ? 'red' : 'purple'}
                  >
                    {arousal} / {max_arousal}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Charge">
                  <ProgressBar
                    value={charge}
                    minValue={0}
                    maxValue={max_charge}
                    color="blue"
                  >
                    {charge} / {max_charge}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Settings">
              <LabeledList>
                <LabeledList.Item label="Speed">
                  <Dropdown
                    width="140px"
                    options={SPEED_OPTIONS.map((option) => option.label)}
                    selected={labelFor(SPEED_OPTIONS, speed)}
                    onSelected={(label: string) =>
                      act('set_speed', {
                        value: SPEED_OPTIONS.find((o) => o.label === label)
                          ?.value,
                      })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Force">
                  <Dropdown
                    width="140px"
                    options={FORCE_OPTIONS.map((option) => option.label)}
                    selected={labelFor(FORCE_OPTIONS, force)}
                    onSelected={(label: string) =>
                      act('set_force', {
                        value: FORCE_OPTIONS.find((o) => o.label === label)
                          ?.value,
                      })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Manual Arousal">
                  <Dropdown
                    width="160px"
                    options={MANUAL_AROUSAL_OPTIONS.map(
                      (option) => option.label,
                    )}
                    selected={labelFor(MANUAL_AROUSAL_OPTIONS, manual_arousal)}
                    onSelected={(label: string) =>
                      act('set_manual_arousal', {
                        value: MANUAL_AROUSAL_OPTIONS.find(
                          (o) => o.label === label,
                        )?.value,
                      })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Toggles">
                  <Button
                    selected={do_until_finished}
                    onClick={() => act('toggle_do_until_finished')}
                  >
                    Until Finished
                  </Button>
                  <Button
                    selected={bottom_exposed}
                    onClick={() => act('toggle_bottom_exposed')}
                  >
                    Bottom Exposed
                  </Button>
                  <Button
                    selected={hide_genital_visuals}
                    onClick={() => act('toggle_hide_genital_visuals')}
                  >
                    Hide Visuals
                  </Button>
                  <Button
                    selected={freeuse}
                    onClick={() => act('toggle_freeuse')}
                  >
                    Free Use
                  </Button>
                  <Button
                    selected={do_subtle_action}
                    onClick={() => act('toggle_subtle')}
                  >
                    Subtle
                  </Button>
                  {!!can_knot_partners && (
                    <Button
                      selected={do_knot_action}
                      onClick={() => act('toggle_knot_action')}
                    >
                      Knot on Climax
                    </Button>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          {!!knotted && (
            <Stack.Item>
              <Section>
                <Stack>
                  <Stack.Item grow>
                    <Box color="bad">
                      Knotted with {knot_partner_name || 'someone'} -- you're
                      tied together until you pull apart or break it.
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="unlink"
                      color="bad"
                      onClick={() => act('break_knot')}
                    >
                      Break Knot
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Actions"
              buttons={
                <Tabs>
                  {CATEGORIES.map((cat) => (
                    <Tabs.Tab
                      key={cat.value}
                      selected={action_category === cat.value}
                      onClick={() => act('set_category', { value: cat.value })}
                    >
                      {cat.label}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              }
            >
              {!actions.length && (
                <Box color="label">
                  No actions available -- target someone (or yourself) and
                  make sure the relevant body part is exposed.
                </Box>
              )}
              {actions.map((action) => (
                <Button
                  key={action.path}
                  fluid
                  selected={action.active}
                  onClick={() =>
                    act('perform_action', { action: action.path })
                  }
                >
                  {action.name}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item grow>
                  <Box color={current_action ? 'good' : 'label'}>
                    {current_action
                      ? `Currently: ${current_action}`
                      : 'Not doing anything.'}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="stop"
                    color="bad"
                    disabled={!current_action}
                    onClick={() => act('stop_action')}
                  >
                    Stop
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
