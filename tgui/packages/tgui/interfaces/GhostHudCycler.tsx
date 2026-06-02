import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { BooleanLike } from 'tgui-core/react';
import { Button, Section, Stack } from 'tgui-core/components';

type Data = {
  med_hud: BooleanLike;
  antag_hud: BooleanLike;
  sec_hud: BooleanLike;
  ghost_vision: BooleanLike;
  see_darkness: BooleanLike;
  antag_hud_allowed: BooleanLike;
};

type HudOption = {
  label: string;
  key: keyof Data;
  action: string;
  desc: string;
};

const HUD_OPTIONS: HudOption[] = [
  {
    label: 'Medical HUD',
    key: 'med_hud',
    action: 'toggle_med_hud',
    desc: 'Shows health and status indicators above nearby crew.',
  },
  {
    label: 'Antagonist HUD',
    key: 'antag_hud',
    action: 'toggle_antag_hud',
    desc: 'Reveals antagonist role icons above suspects nearby.',
  },
  {
    label: 'Security HUD',
    key: 'sec_hud',
    action: 'toggle_sec_hud',
    desc: 'Shows ID status and security flags above nearby crew.',
  },
  {
    label: 'Ghost Vision',
    key: 'ghost_vision',
    action: 'toggle_ghost_vision',
    desc: 'Lets you see other ghosts and ghost-only objects.',
  },
  {
    label: 'See Darkness',
    key: 'see_darkness',
    action: 'toggle_darkness',
    desc: 'Toggles whether you perceive darkness as a ghost.',
  },
];

export const GhostHudCycler = (props) => {
  const { act, data } = useBackend<Data>();
  const { antag_hud_allowed } = data;

  return (
    <Window title="HUD Cycler" width={340} height={300}>
      <Window.Content>
        <Section title="Toggle HUDs & Vision">
          <Stack vertical>
            {HUD_OPTIONS.map((opt) => {
              // Antag HUD disabled when not allowed
              if (opt.action === 'toggle_antag_hud' && !antag_hud_allowed) {
                return (
                  <Stack.Item key={opt.action}>
                    <Button
                      fluid
                      disabled
                      icon="times"
                      color="bad"
                      tooltip="Antagonist HUD is disabled for this round."
                    >
                      {opt.label}
                    </Button>
                  </Stack.Item>
                );
              }

              const enabled = !!data[opt.key];
              return (
                <Stack.Item key={opt.action}>
                  <Button
                    fluid
                    icon={enabled ? 'check' : 'times'}
                    color={enabled ? 'good' : 'bad'}
                    tooltip={opt.desc}
                    onClick={() => act(opt.action)}
                  >
                    {opt.label}
                  </Button>
                </Stack.Item>
              );
            })}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
