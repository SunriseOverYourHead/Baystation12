import { Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  active: BooleanLike;
  is_ai: BooleanLike;
  output_set: number;
  output_max: number;
  output_safe: number;
  output_watts: number;
  temperature_current: number;
  temperature_max: number;
  temperature_overheat: number;
  fuel_stored: number;
  fuel_capacity: number;
  fuel_usage: number;
  fuel_type: string;
  uses_coolant: BooleanLike;
  coolant_stored: number | null;
  coolant_capacity: number | null;
};

const fuelColor = (stored: number) => {
  if (stored >= 5000) return 'good';
  if (stored >= 1000) return 'average';
  return 'bad';
};

const tempColor = (current: number, max: number) => {
  if (current < max * 0.8) return 'good';
  if (current < max) return 'average';
  return 'bad';
};

const overheatLabel = (pct: number) => {
  if (pct > 90) return { text: 'DANGER: CRITICAL OVERHEAT! Deactivate generator immediately!', color: 'bad' };
  if (pct > 50) return { text: 'WARNING: Overheating!', color: 'average' };
  if (pct > 10) return { text: 'Temperature High', color: 'average' };
  return { text: 'Optimal', color: 'good' };
};

const coolantColor = (stored: number, capacity: number) => {
  const ratio = stored / capacity;
  if (ratio >= 0.4) return 'good';
  if (ratio >= 0.1) return 'average';
  return 'bad';
};

export const Pacman = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    is_ai,
    output_set,
    output_max,
    output_safe,
    output_watts,
    temperature_current,
    temperature_max,
    temperature_overheat,
    fuel_stored,
    fuel_capacity,
    fuel_usage,
    fuel_type,
    uses_coolant,
    coolant_stored,
    coolant_capacity,
  } = data;

  const overLabel = overheatLabel(temperature_overheat);

  return (
    <Window title="Portable Generator" width={500} height={560}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Generator Status">
              <span style={{ color: active ? 'green' : 'orange' }}>
                {active ? 'Online' : 'Offline'}
              </span>
            </LabeledList.Item>
            <LabeledList.Item label="Generator Control">
              {active ? (
                <Button icon="power-off" color="bad" onClick={() => act('disable')}>
                  STOP
                </Button>
              ) : (
                <Button icon="power-off" color="good" onClick={() => act('enable')}>
                  START
                </Button>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Fuel">
          <LabeledList>
            <LabeledList.Item label="Fuel Type">
              <span style={{ color: 'green' }}>{fuel_type}</span>
            </LabeledList.Item>
            <LabeledList.Item label="Fuel Level">
              <ProgressBar
                value={fuel_stored / fuel_capacity}
                color={fuelColor(fuel_stored)}
              />
              <br />
              <span style={{ color: fuelColor(fuel_stored) }}>
                {fuel_stored} / {fuel_capacity} cm3
              </span>
            </LabeledList.Item>
            <LabeledList.Item label="Fuel Usage">
              <span style={{ color: 'green' }}>{fuel_usage} cm3/s</span>
            </LabeledList.Item>
            {!is_ai && (
              <LabeledList.Item label="Control">
                <Button
                  icon="eject"
                  disabled={!!active}
                  onClick={() => act('eject')}
                >
                  EJECT FUEL
                </Button>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        {!!uses_coolant && coolant_stored !== null && coolant_capacity !== null && (
          <Section title="Coolant">
            <LabeledList>
              <LabeledList.Item label="Coolant Level">
                <ProgressBar
                  value={coolant_stored / coolant_capacity}
                  color={coolantColor(coolant_stored, coolant_capacity)}
                />
                <br />
                <span style={{ color: coolantColor(coolant_stored, coolant_capacity) }}>
                  {coolant_stored} / {coolant_capacity} u
                </span>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}

        <Section title="Output">
          <LabeledList>
            <LabeledList.Item label="Power Setting">
              <span style={{ color: output_set > output_safe ? 'red' : 'green' }}>
                {output_set} / {output_max} ({output_watts} W)
              </span>
            </LabeledList.Item>
            <LabeledList.Item label="Control">
              <Button icon="plus" onClick={() => act('higher_power')}>
                +
              </Button>
              <Button icon="minus" onClick={() => act('lower_power')}>
                -
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Temperature">
          <LabeledList>
            <LabeledList.Item label="Temperature">
              <ProgressBar
                value={temperature_current / (temperature_max * 1.5)}
                color={tempColor(temperature_current, temperature_max)}
              />
              <br />
              <span style={{ color: tempColor(temperature_current, temperature_max) }}>
                {temperature_current} C
              </span>
            </LabeledList.Item>
            <LabeledList.Item label="Generator Status">
              <span style={{ color: overLabel.color }}>{overLabel.text}</span>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
