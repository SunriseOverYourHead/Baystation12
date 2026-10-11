import { Box, Button, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Layout } from '../layouts/Layout';

type Data = {
  station_name: string;
  background_image: string;
  has_wiki: BooleanLike;
  has_rules: BooleanLike;
  has_lore: BooleanLike;
  multi_character: BooleanLike;
  ready: BooleanLike;
  round_started: BooleanLike;
  character_name: string;
  character_job: string | null;
  player_count: number;
  ready_count: number;
  time_to_start: number | null;
};

const formatDuration = (seconds: number) => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
};

// The lobby sits "inside" the game view the way CM13/NovaStation's start menus do - full-bleed background art
// superimposed directly over the map, with no separate floating window, title bar, or drag/resize handles.
// This is achieved DM-side (code/modules/mob/new_player/lobby_tgui.dm's initialize_lobby_screen()) by
// rendering into the pre-existing "lobbybrowser" pane (interface/skin.dmf), which is permanently anchored to
// cover the exact same rect as the game's own "map" element - not by resizing/repositioning a normal tgui
// popup window. That pane is a fixed-size BROWSER control, so there's no window geometry to compute here; this
// component just needs to fill 100% of it. The shared Window component (tgui/packages/tgui/layouts/Window.tsx)
// always renders a draggable TitleBar plus resize handles with no way to opt out, so this bypasses it entirely
// and composes straight from Layout/Layout.Content - the same building blocks Window itself uses underneath.
// Reusing Window.scss's own ".Window" class gives identical full-viewport coverage and theming
// (position:fixed; inset:0), just without the 32px offset its sibling ".Window__rest" reserves for the title
// bar.
export const Lobby = () => {
  const { act, data, suspended } = useBackend<Data>();
  const {
    station_name,
    background_image,
    has_wiki,
    has_rules,
    has_lore,
    multi_character,
    ready,
    round_started,
    character_name,
    character_job,
    player_count = 0,
    ready_count = 0,
    time_to_start,
  } = data;

  if (suspended) {
    return null;
  }

  const showStartCountdown =
    !round_started && typeof time_to_start === 'number' && time_to_start > 0;

  return (
    <Layout className="Window">
      <Layout.Content>
        <Box
          style={{
            position: 'relative',
            width: '100%',
            height: '100%',
            overflow: 'hidden',
            backgroundImage: `url(${resolveAsset(background_image || 'default_lobby.png')})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        >
          {/* Dark scrim so text/buttons stay legible over whatever art is showing. */}
          <Box
            style={{
              position: 'absolute',
              inset: 0,
              background:
                'linear-gradient(180deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.55) 55%, rgba(0,0,0,0.88) 100%)',
            }}
          />
          <Box
            style={{
              position: 'relative',
              height: '100%',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              textAlign: 'center',
            }}
          >
            <Box
              fontSize="2.2em"
              bold
              style={{ letterSpacing: '2px', textShadow: '0 2px 10px black' }}
            >
              {station_name}
            </Box>
            <Box mt={1} fontSize="1.2em" style={{ textShadow: '0 1px 6px black' }}>
              Welcome, {character_name}
              {character_job ? ` — ${character_job}` : ''}
            </Box>
            <Box mt={0.5} color="label" fontSize="0.9em">
              {player_count} in lobby · {ready_count} ready
              {showStartCountdown
                ? ` · starting in ${formatDuration(time_to_start as number)}`
                : ''}
            </Box>

            <Stack vertical mt={3} width="300px">
              <Stack.Item>
                {!round_started ? (
                  <Button
                    fluid
                    icon={ready ? 'check-circle' : 'circle'}
                    color={ready ? 'good' : undefined}
                    onClick={() => act('ready')}
                  >
                    {ready ? 'Ready' : 'Not Ready'}
                  </Button>
                ) : (
                  <Button fluid icon="door-open" onClick={() => act('late_join')}>
                    Join the Crew
                  </Button>
                )}
              </Stack.Item>
              <Stack.Item>
                <Button fluid icon="user-edit" onClick={() => act('preferences')}>
                  Setup Character
                </Button>
              </Stack.Item>
              {!!multi_character && (
                <Stack.Item>
                  <Button fluid icon="users" onClick={() => act('manage_characters')}>
                    Manage Characters
                  </Button>
                </Stack.Item>
              )}
              {!!round_started && (
                <Stack.Item>
                  <Button fluid icon="clipboard-list" onClick={() => act('manifest')}>
                    Crew Manifest
                  </Button>
                </Stack.Item>
              )}
              <Stack.Item>
                <Button fluid icon="binoculars" onClick={() => act('observe')}>
                  Observe
                </Button>
              </Stack.Item>
            </Stack>

            {(!!has_wiki || !!has_rules || !!has_lore) && (
              <Stack mt={2}>
                {!!has_wiki && (
                  <Stack.Item>
                    <Button icon="book" onClick={() => act('wiki')}>
                      Wiki
                    </Button>
                  </Stack.Item>
                )}
                {!!has_rules && (
                  <Stack.Item>
                    <Button icon="gavel" onClick={() => act('rules')}>
                      Rules
                    </Button>
                  </Stack.Item>
                )}
                {!!has_lore && (
                  <Stack.Item>
                    <Button icon="scroll" onClick={() => act('lore')}>
                      Lore
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            )}

            <Box mt={2}>
              <Button icon="music" onClick={() => act('next_track')}>
                Next Track
              </Button>
            </Box>
          </Box>
        </Box>
      </Layout.Content>
    </Layout>
  );
};
