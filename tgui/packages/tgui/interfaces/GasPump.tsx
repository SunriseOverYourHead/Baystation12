import { Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: number;
  pressure_set: number;
  max_pressure: number;
  last_flow_rate: number;
  last_power_draw: number;
  max_power_draw: number;
};

export const GasPump = () => {
  const { act, data } = useBackend<Data>();
  const { on, pressure_set, last_flow_rate, last_power_draw, max_power_draw } = data;

  return (
    <Window title="Gas Pump" width={470} height={290}>
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
            <LabeledList.Item label="Desirable Output Pressure">
              <Button content="MAX" onClick={() => act('set_press', { value: 'max' })} />
              <Button content="SET" onClick={() => act('set_press', { value: 'set' })} />
              &nbsp;{(pressure_set / 100).toFixed(0)} kPa
            </LabeledList.Item>
            <LabeledList.Item label="Load">
              <ProgressBar
                value={last_power_draw}
                minValue={0}
                maxValue={max_power_draw}
                color={last_power_draw < max_power_draw - 5 ? 'good' : 'average'}
              />
              {last_power_draw} W
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
