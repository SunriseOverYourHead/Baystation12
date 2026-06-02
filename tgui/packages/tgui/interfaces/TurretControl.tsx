import { Box, Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Setting = {
  category: string;
  setting: string;
  value: BooleanLike;
};

type Data = {
  access: BooleanLike;
  locked: BooleanLike;
  enabled: BooleanLike;
  lethal: BooleanLike;
  settings?: Setting[];
};

export const TurretControl = () => {
  const { act, data } = useBackend<Data>();
  const { access, locked, enabled, lethal, settings = [] } = data;

  return (
    <Window title="Turret Controls" width={420} height={300}>
      <Window.Content>
        {!!locked && !access && (
          <NoticeBox>Access denied. ID required.</NoticeBox>
        )}
        <Section title="Power & Mode">
          <LabeledList>
            <LabeledList.Item label="Turret Status">
              <Button
                icon={enabled ? 'power-off' : 'times'}
                selected={!!enabled}
                disabled={!access}
                onClick={() =>
                  act('toggle', { command: 'enable', value: enabled ? 0 : 1 })
                }
              >
                {enabled ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Turret Mode">
              <Button
                icon={lethal ? 'exclamation-triangle' : 'minus-circle'}
                color={lethal ? 'bad' : 'average'}
                disabled={!access}
                onClick={() =>
                  act('toggle', { command: 'lethal', value: lethal ? 0 : 1 })
                }
              >
                {lethal ? 'Lethal' : 'Stun'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {settings.length > 0 && (
          <Section title="Detection Settings">
            <LabeledList>
              {settings.map((s) => (
                <LabeledList.Item key={s.setting} label={s.category}>
                  <Button
                    icon={s.value ? 'check' : 'times'}
                    selected={!!s.value}
                    disabled={!access}
                    onClick={() =>
                      act('toggle', {
                        command: s.setting,
                        value: s.value ? 0 : 1,
                      })
                    }
                  >
                    {s.value ? 'Enabled' : 'Disabled'}
                  </Button>
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        )}
        {!!locked && <Box color="average">This terminal is locked.</Box>}
      </Window.Content>
    </Window>
  );
};
