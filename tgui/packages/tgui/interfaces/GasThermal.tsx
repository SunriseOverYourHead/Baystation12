import { Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: number;
  gasPressure: number;
  gasTemperature: number;
  minGasTemperature: number;
  maxGasTemperature: number;
  targetGasTemperature: number;
  powerSetting: number;
  gasTemperatureClass: string;
};

const POWER_LEVELS = [20, 40, 60, 80, 100];

export const GasThermal = () => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    gasPressure,
    gasTemperature,
    minGasTemperature,
    maxGasTemperature,
    targetGasTemperature,
    powerSetting,
    gasTemperatureClass,
  } = data;

  const tempColor =
    gasTemperatureClass === 'bad'
      ? 'bad'
      : gasTemperatureClass === 'average'
        ? 'average'
        : 'good';

  return (
    <Window title="Gas Thermal System" width={440} height={300}>
      <Window.Content>
        <Section title="Status">
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
              {POWER_LEVELS.map((lvl, i) => (
                <Button
                  key={lvl}
                  content={String(i + 1)}
                  selected={powerSetting === lvl}
                  onClick={() => act('setPower', { value: lvl })}
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Gas Pressure">
              {gasPressure} kPa
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Gas Temperature">
          <LabeledList>
            <LabeledList.Item label="Current">
              <ProgressBar
                value={gasTemperature}
                minValue={minGasTemperature}
                maxValue={maxGasTemperature}
                color={tempColor}
              />
              &nbsp;{gasTemperature} K
            </LabeledList.Item>
            <LabeledList.Item label="Target">
              <ProgressBar
                value={targetGasTemperature}
                minValue={minGasTemperature}
                maxValue={maxGasTemperature}
              />
              <Button
                content="-100"
                disabled={targetGasTemperature <= minGasTemperature}
                onClick={() => act('temp', { value: -100 })}
              />
              <Button
                content="-10"
                disabled={targetGasTemperature <= minGasTemperature}
                onClick={() => act('temp', { value: -10 })}
              />
              <Button
                content="-1"
                disabled={targetGasTemperature <= minGasTemperature}
                onClick={() => act('temp', { value: -1 })}
              />
              &nbsp;{targetGasTemperature} K&nbsp;
              <Button
                content="+1"
                disabled={targetGasTemperature >= maxGasTemperature}
                onClick={() => act('temp', { value: 1 })}
              />
              <Button
                content="+10"
                disabled={targetGasTemperature >= maxGasTemperature}
                onClick={() => act('temp', { value: 10 })}
              />
              <Button
                content="+100"
                disabled={targetGasTemperature >= maxGasTemperature}
                onClick={() => act('temp', { value: 100 })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
