import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  jump_cooldown_remaining: number;
  jumping: BooleanLike;
  jump_remaining: number;
  nuke_found: BooleanLike;
  nuke_timing: number;
  nuke_remaining: number;
  evac_found: BooleanLike;
  evac_state: number;
  evac_emergency: BooleanLike;
  evac_remaining: number;
};

const EVAC_IDLE = 0;
const EVAC_PREPPING = 1;
const EVAC_LAUNCHING = 2;
const EVAC_IN_TRANSIT = 3;
const EVAC_COOLDOWN = 4;
const EVAC_COMPLETE = 5;

const evacStateText = (state: number) => {
  switch (state) {
    case EVAC_IDLE:
      return 'Idle';
    case EVAC_PREPPING:
      return 'Prepping';
    case EVAC_LAUNCHING:
      return 'Launching';
    case EVAC_IN_TRANSIT:
      return 'In Transit';
    case EVAC_COOLDOWN:
      return 'Cooldown';
    case EVAC_COMPLETE:
      return 'Complete';
    default:
      return 'Unknown';
  }
};

const nukeStateText = (timing: number) => {
  if (timing > 0) return 'Counting Down';
  if (timing < 0) return 'Exploding/Exploded';
  return 'Idle';
};

// A labeled row pairing a NumberInput (seconds) with an action button - shared shape for every "set/start
// with a timer" control on this panel, since they're all the same seconds-in, act-on-click pattern.
const TimerRow = (props: {
  label: string;
  buttonText: string;
  initialValue: number;
  disabled?: boolean;
  onSubmit: (seconds: number) => void;
}) => {
  const { label, buttonText, initialValue, disabled, onSubmit } = props;
  const [value, setValue] = useState(initialValue);
  return (
    <LabeledList.Item label={label}>
      <NumberInput
        value={value}
        minValue={0}
        maxValue={9999}
        step={1}
        width="70px"
        unit="s"
        disabled={disabled}
        onChange={(v) => setValue(v)}
      />
      <Button ml={1} disabled={disabled} onClick={() => onSubmit(value)}>
        {buttonText}
      </Button>
    </LabeledList.Item>
  );
};

export const StarmapDebugPanel = () => {
  const { act, data } = useBackend<Data>();
  const {
    jump_cooldown_remaining = 0,
    jumping,
    jump_remaining = 0,
    nuke_found,
    nuke_timing = 0,
    nuke_remaining = 0,
    evac_found,
    evac_state = EVAC_IDLE,
    evac_emergency,
    evac_remaining = 0,
  } = data;

  const nukeArmed = nuke_timing > 0;
  const evacIdle = evac_state === EVAC_IDLE;

  return (
    <Window title="Starmap Debug Panel" width={480} height={430}>
      <Window.Content scrollable>
        <Section title="Bluespace Jump (SEV Torch)">
          <LabeledList>
            <LabeledList.Item label="Cooldown remaining">
              <Box inline mr={1}>
                {jump_cooldown_remaining}s
              </Box>
            </LabeledList.Item>
            <TimerRow
              label="Set cooldown to"
              buttonText="Set"
              initialValue={jump_cooldown_remaining}
              onSubmit={(seconds) => act('set_jump_cooldown', { value: seconds })}
            />
            <LabeledList.Item label="Jump in progress">
              <Box inline mr={1}>
                {jumping ? `Yes (${jump_remaining}s remaining)` : 'No'}
              </Box>
            </LabeledList.Item>
            <TimerRow
              label="Set jump remaining to"
              buttonText="Set"
              initialValue={jump_remaining}
              disabled={!jumping}
              onSubmit={(seconds) => act('set_jump_remaining', { value: seconds })}
            />
          </LabeledList>
        </Section>
        <Section title="Self-Destruct">
          {!nuke_found ? (
            <Box color="bad">No self-destruct terminal found on the map.</Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box inline mr={1} color={nukeArmed ? 'bad' : 'label'}>
                  {nukeStateText(nuke_timing)}
                  {nukeArmed && ` (${nuke_remaining}s remaining)`}
                </Box>
              </LabeledList.Item>
              <TimerRow
                label="Force arm with"
                buttonText="Arm"
                initialValue={300}
                disabled={nukeArmed}
                onSubmit={(seconds) => act('force_arm_nuke', { value: seconds })}
              />
              <TimerRow
                label="Set remaining to"
                buttonText="Set"
                initialValue={nuke_remaining}
                disabled={!nukeArmed}
                onSubmit={(seconds) => act('set_nuke_remaining', { value: seconds })}
              />
              <LabeledList.Item label="Force disarm">
                <Button
                  color="bad"
                  disabled={!nukeArmed}
                  onClick={() => act('force_disarm_nuke')}
                >
                  Disarm
                </Button>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
        <Section title="Evacuation / Return to Port">
          {!evac_found ? (
            <Box color="bad">No evacuation controller found.</Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box inline mr={1}>
                  {evacStateText(evac_state)}
                  {!evacIdle &&
                    ` (${evac_emergency ? 'Emergency Evac' : 'Return to Port'}, ${evac_remaining}s remaining)`}
                </Box>
              </LabeledList.Item>
              <TimerRow
                label="Start emergency evac with"
                buttonText="Start"
                initialValue={300}
                disabled={!evacIdle}
                onSubmit={(seconds) => act('start_evac', { value: seconds })}
              />
              <LabeledList.Item label="Return to port">
                <Button disabled={!evacIdle} onClick={() => act('return_to_port')}>
                  Initiate
                </Button>
              </LabeledList.Item>
              <TimerRow
                label="Set remaining to"
                buttonText="Set"
                initialValue={evac_remaining}
                disabled={evacIdle}
                onSubmit={(seconds) => act('set_evac_remaining', { value: seconds })}
              />
              <LabeledList.Item label="Cancel">
                <Button
                  color="bad"
                  disabled={evacIdle}
                  onClick={() => act('cancel_evac')}
                >
                  Cancel Evac / Return to Port
                </Button>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
