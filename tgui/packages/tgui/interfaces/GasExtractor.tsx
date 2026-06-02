import { Button, LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: number;
  id: string | null;
  target_pressure: number;
  pressure_check: number;
  frequency: number;
  last_flow_rate: number;
};

export const GasExtractor = () => {
  const { act, data } = useBackend<Data>();
  const { on, id, target_pressure, pressure_check, frequency, last_flow_rate } = data;

  return (
    <Window title="Gas Extractor" width={480} height={240}>
      <Window.Content>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                content={on ? 'On' : 'Off'}
                selected={!!on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="ID">
              <Button content="Set ID" onClick={() => act('settag')} />
              &nbsp;{id ?? '(none)'}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure Check">
              <Button
                content={pressure_check ? 'External' : 'Internal'}
                onClick={() => act('toggle_mode')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Target Pressure">
              <Button content="Max" onClick={() => act('setpressure', { value: 'max' })} />
              <Button content="Set" onClick={() => act('setpressure', { value: 'set' })} />
              &nbsp;{(target_pressure / 100).toFixed(0)} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Frequency">
              <Button content="Set Frequency" onClick={() => act('setfreq')} />
              &nbsp;{(frequency / 10).toFixed(1)}
            </LabeledList.Item>
            <LabeledList.Item label="Flow Rate">
              {(last_flow_rate / 10).toFixed(1)} L/s
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
