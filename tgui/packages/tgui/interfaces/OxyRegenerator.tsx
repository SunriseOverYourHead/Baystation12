import { Button, LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: number;
  powerSetting: number;
  phase: 'filling' | 'processing' | 'releasing';
  gasProcessed: number;
  air1Pressure: number;
  air2Pressure: number;
  tankPressure: number;
  targetPressure: number;
  co2: number;
  o2: number;
};

const POWER_LEVELS = [1, 2, 3, 4, 5];

export const OxyRegenerator = () => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    powerSetting,
    phase,
    gasProcessed,
    air1Pressure,
    air2Pressure,
    tankPressure,
    targetPressure,
    co2,
    o2,
  } = data;

  return (
    <Window title="Oxygen Regeneration System" width={440} height={300}>
      <Window.Content>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                content="On"
                selected={!!on}
                onClick={() => act('toggleStatus')}
              />
              <Button
                content="Off"
                selected={!on}
                onClick={() => act('toggleStatus')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power Level">
              {POWER_LEVELS.map((lvl) => (
                <Button
                  key={lvl}
                  content={String(lvl)}
                  selected={powerSetting === lvl}
                  onClick={() => act('setPower', { value: lvl })}
                />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {phase === 'filling' && (
          <Section title="Processing Phase: Filling Inner Tank">
            <LabeledList>
              <LabeledList.Item label="Input Pressure">
                {air1Pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item label="Tank Pressure">
                {tankPressure} kPa
              </LabeledList.Item>
              <LabeledList.Item label="Target Tank Pressure">
                {targetPressure} kPa
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        {phase === 'processing' && (
          <Section title="Processing Phase: Processing Gas Mix">
            <LabeledList>
              <LabeledList.Item label="Processing Rate">
                {gasProcessed} moles
              </LabeledList.Item>
              <LabeledList.Item label="Tank Pressure">
                {tankPressure} kPa
              </LabeledList.Item>
              <LabeledList.Item label="CO2 Content">
                {co2} %
              </LabeledList.Item>
              <LabeledList.Item label="O2 Content">
                {o2} %
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        {phase === 'releasing' && (
          <Section title="Processing Phase: Releasing Processed Gas Mix">
            <LabeledList>
              <LabeledList.Item label="Tank Pressure">
                {tankPressure} kPa
              </LabeledList.Item>
              <LabeledList.Item label="Output Pressure">
                {air2Pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item label="Target Release Pressure">
                {targetPressure} kPa
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
