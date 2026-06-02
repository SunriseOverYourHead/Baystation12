import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  name: string;
  bag: string | null;
  mop: string | null;
  spray: string | null;
  replacer: string | null;
  signs: string | null;
};

export const JanitorCart = (props) => {
  const { act, data } = useBackend<Data>();
  const { name, bag, mop, spray, replacer, signs } = data;

  return (
    <Window title={name} width={240} height={160}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Trash Bag">
              {bag ? (
                <Button
                  icon="trash"
                  content={bag}
                  onClick={() => act('take', { item: 'garbage' })}
                />
              ) : (
                'None'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Mop">
              {mop ? (
                <Button
                  icon="water"
                  content={mop}
                  onClick={() => act('take', { item: 'mop' })}
                />
              ) : (
                'None'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Spray Bottle">
              {spray ? (
                <Button
                  icon="spray-can"
                  content={spray}
                  onClick={() => act('take', { item: 'spray' })}
                />
              ) : (
                'None'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Light Replacer">
              {replacer ? (
                <Button
                  icon="lightbulb"
                  content={replacer}
                  onClick={() => act('take', { item: 'replacer' })}
                />
              ) : (
                'None'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Signs">
              {signs ? (
                <Button
                  icon="sign-language"
                  content={signs}
                  onClick={() => act('take', { item: 'sign' })}
                />
              ) : (
                'None'
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
