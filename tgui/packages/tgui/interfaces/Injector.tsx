import { Button, LabeledList, NumberInput, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: number;
  id: string | null;
  frequency: number;
  flow_rate: number;
  last_flow_rate: number;
};

export const Injector = () => {
  const { act, data } = useBackend<Data>();
  const { on, id, frequency, flow_rate, last_flow_rate } = data;

  return (
    <Window title="Injector" width={480} height={240}>
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
            <LabeledList.Item label="Maximum Flow Rate">
              <Button content="Max" onClick={() => act('set_flow_rate', { value: 'max' })} />
              <Button content="Set" onClick={() => act('set_flow_rate', { value: 'set' })} />
              &nbsp;{flow_rate} L/s
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
