import { Button, LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: number;
  input_pressure: number;
  output_pressure: number;
  last_flow_rate: number;
  regulate_mode: number;
  pressure_set: number;
  set_flow_rate: number;
};

export const PressureRegulator = () => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    input_pressure,
    output_pressure,
    last_flow_rate,
    regulate_mode,
    pressure_set,
    set_flow_rate,
  } = data;

  return (
    <Window title="Pressure Regulator" width={470} height={370}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Input Pressure">
              {(input_pressure / 100).toFixed(0)} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Output Pressure">
              {(output_pressure / 100).toFixed(0)} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Flow Rate">
              {(last_flow_rate / 10).toFixed(1)} L/s
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Valve">
              <Button
                content={on ? 'Unlocked' : 'Closed'}
                selected={!!on}
                onClick={() => act('toggle_valve')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Pressure Regulation">
              <Button
                content="Off"
                selected={regulate_mode === 0}
                onClick={() => act('regulate_mode', { value: 'off' })}
              />
              <Button
                content="Input"
                selected={regulate_mode === 1}
                onClick={() => act('regulate_mode', { value: 'input' })}
              />
              <Button
                content="Output"
                selected={regulate_mode === 2}
                onClick={() => act('regulate_mode', { value: 'output' })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Target Pressure">
              <Button content="MAX" onClick={() => act('set_press', { value: 'max' })} />
              <Button content="SET" onClick={() => act('set_press', { value: 'set' })} />
              &nbsp;{(pressure_set / 100).toFixed(0)} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Flow Rate Limit">
              <Button content="MAX" onClick={() => act('set_flow_rate', { value: 'max' })} />
              <Button content="SET" onClick={() => act('set_flow_rate', { value: 'set' })} />
              &nbsp;{(set_flow_rate / 10).toFixed(1)} L/s
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
