import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ShieldMode = {
  name: string;
  desc: string;
  flag: number;
  status: BooleanLike;
  hacked: BooleanLike;
  multiplier: number;
};

type Data = {
  running: number;
  overloaded: BooleanLike;
  offline_for: number;
  modes: ShieldMode[];
  mitigation_max: number;
  mitigation_physical: number;
  mitigation_em: number;
  mitigation_heat: number;
  field_integrity: number;
  max_energy: number;
  current_energy: number;
  percentage_energy: number;
  total_segments: number;
  functional_segments: number;
  field_radius: number;
  target_radius: number;
  input_cap_kw: number;
  upkeep_power_usage: number;
  power_usage: number;
  hacked: BooleanLike;
  idle_multiplier: number;
  idle_valid_values: number[];
  mode_changes_locked: BooleanLike;
};

const SHIELD_OFF = 0;
const SHIELD_DISCHARGING = 1;
const SHIELD_RUNNING = 2;
const SHIELD_IDLE = 3;
const SHIELD_SPINNING_UP = 4;

function runningLabel(running: number, overloaded: BooleanLike) {
  switch (running) {
    case SHIELD_RUNNING:
      return overloaded ? 'Recovering' : 'Active';
    case SHIELD_DISCHARGING:
      return 'Shutting Down';
    case SHIELD_IDLE:
      return 'Inactive';
    case SHIELD_SPINNING_UP:
      return 'Spinning Up';
    default:
      return 'Offline';
  }
}

export const ShieldGenerator = () => {
  const { act, data } = useBackend<Data>();
  const {
    running,
    overloaded,
    offline_for,
    modes = [],
    mitigation_max,
    mitigation_physical,
    mitigation_em,
    mitigation_heat,
    field_integrity,
    max_energy,
    current_energy,
    percentage_energy,
    total_segments,
    functional_segments,
    field_radius,
    target_radius,
    input_cap_kw,
    upkeep_power_usage,
    power_usage,
    hacked,
    idle_multiplier,
    idle_valid_values = [],
    mode_changes_locked,
  } = data;

  const isOnline = running >= SHIELD_RUNNING;

  return (
    <Window title="Shield Generator" width={500} height={800}>
      <Window.Content scrollable>
        {offline_for > 0 ? (
          <Section>
            <NoticeBox danger>EMERGENCY SHUTDOWN</NoticeBox>
            <Box bold>
              An emergency shutdown has been initiated — generator cooling down.
            </Box>
            <Box mt={1}>
              Please wait until the generator cools down before resuming
              operation. Estimated time left: {offline_for} seconds.
            </Box>
          </Section>
        ) : (
          <>
            <Section title="System Status">
              <LabeledList>
                <LabeledList.Item label="Generator">
                  {runningLabel(running, overloaded)}
                </LabeledList.Item>
                <LabeledList.Item label="Energy Storage">
                  {current_energy}/{max_energy} MJ ({percentage_energy}%)
                </LabeledList.Item>
                <LabeledList.Item label="Shield Integrity">
                  {field_integrity}%
                </LabeledList.Item>
                <LabeledList.Item label="Mitigation">
                  {mitigation_em}% EM / {mitigation_physical}% PH /{' '}
                  {mitigation_heat}% HE / {mitigation_max}% MAX
                </LabeledList.Item>
                <LabeledList.Item label="Upkeep Energy Use">
                  {upkeep_power_usage} kW
                </LabeledList.Item>
                <LabeledList.Item label="Total Energy Use">
                  {input_cap_kw ? (
                    <>
                      {power_usage} / {input_cap_kw} kW
                    </>
                  ) : (
                    <>{power_usage} kW (No Limit)</>
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Field Size">
                  {functional_segments} / {total_segments} m² (radius{' '}
                  {field_radius}, target {target_radius})
                </LabeledList.Item>
              </LabeledList>
            </Section>

            <Section title="Controls">
              <Box mb={1}>
                {isOnline ? (
                  <>
                    <Button.Confirm
                      color="bad"
                      confirmContent="Confirm shutdown?"
                      onClick={() => act('begin_shutdown')}
                    >
                      Turn Off
                    </Button.Confirm>
                    <Button
                      ml={1}
                      onClick={() =>
                        act('toggle_idle', {
                          value: running === SHIELD_IDLE ? 0 : 1,
                        })
                      }
                    >
                      {running === SHIELD_IDLE ? 'Activate' : 'Deactivate'}
                    </Button>
                  </>
                ) : (
                  <Button
                    color="good"
                    disabled={!!offline_for}
                    onClick={() => act('start_generator')}
                  >
                    Turn On
                  </Button>
                )}
                {!!running && !!hacked && (
                  <Button.Confirm
                    ml={1}
                    color="bad"
                    confirmContent="Emergency shutdown will instantly drop shields and may cause an EMP. Proceed?"
                    onClick={() => act('emergency_shutdown')}
                  >
                    Emergency Shutdown
                  </Button.Confirm>
                )}
              </Box>
              <Box mb={1}>
                <Button.Input
                  disabled={!!mode_changes_locked}
                  buttonText="Set Field Range"
                  onCommit={(val) => act('set_range', { value: val })}
                />
                <Button.Input
                  ml={1}
                  disabled={!!mode_changes_locked}
                  buttonText="Set Input Cap (kW)"
                  onCommit={(val) => act('set_input_cap', { value: val })}
                />
              </Box>
              <Box>
                Set inactive power use intensity:{' '}
                {idle_valid_values.map((val) => (
                  <Button
                    key={val}
                    ml={0.5}
                    disabled={
                      !!mode_changes_locked || running === SHIELD_SPINNING_UP
                    }
                    selected={val === idle_multiplier}
                    onClick={() => act('switch_idle', { value: val })}
                  >
                    {val}
                  </Button>
                ))}
              </Box>
            </Section>

            <Section title="Field Calibration">
              {modes.map((mode) => (
                <Section key={mode.flag} title={mode.name}>
                  <LabeledList>
                    <LabeledList.Item label="Description">
                      {mode.desc}
                    </LabeledList.Item>
                    <LabeledList.Item label="Status">
                      <Box inline color={mode.status ? 'good' : 'bad'}>
                        {mode.status ? 'Enabled' : 'Disabled'}
                      </Box>
                      <Button
                        ml={1}
                        disabled={!!mode_changes_locked}
                        onClick={() =>
                          act('toggle_mode', { flag: mode.flag })
                        }
                      >
                        Toggle
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Multiplier">
                      {mode.multiplier}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ))}
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
