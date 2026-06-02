import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Command = {
  name: string;
  command: string;
  active: BooleanLike;
  enabled: string;
  disabled: string;
  danger: BooleanLike;
  act: BooleanLike;
};

type Data = {
  main_power_loss: number;
  backup_power_loss: number;
  electrified: number;
  open: BooleanLike;
  commands: Command[];
};

const powerLabel = (loss: number) => {
  if (loss === 0) return 'Online';
  if (loss === -1) return 'Offline';
  return `Offline (${loss}s remaining)`;
};

export const DoorControl = () => {
  const { act, data } = useBackend<Data>();
  const { main_power_loss, backup_power_loss, electrified, commands } = data;

  return (
    <Window title="Door Controls" width={450} height={350}>
      <Window.Content>
        <Section title="Power">
          <LabeledList>
            <LabeledList.Item label="Main Power">
              {powerLabel(main_power_loss)}
              {main_power_loss === 0 && (
                <Button color="bad" ml={1} onClick={() => act('main_power')}>
                  Disable
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Backup Power">
              {powerLabel(backup_power_loss)}
              {backup_power_loss === 0 && (
                <Button color="bad" ml={1} onClick={() => act('backup_power')}>
                  Disable
                </Button>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Electrification">
          <Stack>
            <Stack.Item>
              <Button
                selected={electrified === 0}
                onClick={() => act('electrify_permanently', { activate: 0 })}
              >
                Offline
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                color={electrified > 0 ? 'bad' : undefined}
                onClick={() => act('electrify_temporary', { activate: 1 })}
              >
                {electrified > 0 ? `Temporary (${electrified}s)` : 'Temporary (30s)'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                color={electrified === -1 ? 'bad' : undefined}
                onClick={() => act('electrify_permanently', { activate: 1 })}
              >
                Permanent
              </Button>
            </Stack.Item>
          </Stack>
        </Section>

        <Section title="Controls">
          <LabeledList>
            {commands.map((cmd) => (
              <LabeledList.Item key={cmd.command} label={cmd.name}>
                <Button
                  selected={!!cmd.active}
                  onClick={() => act(cmd.command, { activate: cmd.act ? 1 : 0 })}
                >
                  {cmd.enabled}
                </Button>
                <Button
                  color={!cmd.active && cmd.danger ? 'bad' : undefined}
                  selected={!cmd.active}
                  onClick={() => act(cmd.command, { activate: cmd.act ? 0 : 1 })}
                >
                  {cmd.disabled}
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
