import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Input, NoticeBox, Section, Stack } from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

export function IdentityMediaPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const identityMedia =
    data.character_preferences.identity_media || ({} as any);
  const erpUnlocked = !!data.character_preferences.erp_directory?.erp_unlocked;

  const [headshotUrl, setHeadshotUrl] = useState(
    identityMedia.headshot_url || '',
  );
  const [headshotNsfwUrl, setHeadshotNsfwUrl] = useState(
    identityMedia.headshot_nsfw_url || '',
  );
  const [artReferenceUrl, setArtReferenceUrl] = useState(
    identityMedia.art_reference_url || '',
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="View AI Generated Headshots" fitted>
          <Box p={1}>
            <Box italic mb={1} color="label">
              When off, you won't see headshots or art references flagged by other players as AI generated.
              Note that this isn't 100% and relies on other players properly tagging their art.
            </Box>
            <Button
              selected={!!identityMedia.view_ai_generated_headshots}
              onClick={() =>
                act('set_view_ai_generated_headshots', {
                  value: !identityMedia.view_ai_generated_headshots,
                })
              }
            >
              {identityMedia.view_ai_generated_headshots ? 'Yes' : 'No'}
            </Button>
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          title="Headshot"
          fitted
          buttons={
            <Button
              selected={!!identityMedia.headshot_ai_generated}
              onClick={() =>
                act('set_headshot_ai_generated', {
                  value: !identityMedia.headshot_ai_generated,
                })
              }
            >
              AI Generated?
            </Button>
          }
        >
          <Box p={1}>
            <Box italic mb={1} color="label">
              A direct https:// link to an image (Catbox, Imgbox, Gyazo,
              Lensdump, or F-List). Shown on your 'Examine Closer...'' panel.
              Do not put NSFW Headshots here, this is for a headshot that would show up on your ID.
              Keep it professional!
              We allow AI-Generated headshots, but they must be flagged properly.
            </Box>
            <Input
              fluid
              value={headshotUrl}
              placeholder="https://files.catbox.moe/example.png"
              onChange={(value: string) => setHeadshotUrl(value)}
              onBlur={() => act('set_headshot_url', { value: headshotUrl })}
            />
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item>
        {erpUnlocked ? (
          <Section
            title="Headshot (NSFW)"
            fitted
            buttons={
              <Button
                selected={!!identityMedia.headshot_nsfw_ai_generated}
                onClick={() =>
                  act('set_headshot_nsfw_ai_generated', {
                    value: !identityMedia.headshot_nsfw_ai_generated,
                  })
                }
              >
                AI Generated?
              </Button>
            }
          >
            <Box p={1}>
              <Box italic mb={1} color="label">
                An optional NSFW alternate headshot, only shown per your
                "Show NSFW Flavor Text" privacy setting.
                We allow AI-Generated headshots, but they must be flagged properly.
              </Box>
              <Input
                fluid
                value={headshotNsfwUrl}
                placeholder="https://files.catbox.moe/example.png"
                onChange={(value: string) => setHeadshotNsfwUrl(value)}
                onBlur={() =>
                  act('set_headshot_nsfw_url', { value: headshotNsfwUrl })
                }
              />
            </Box>
          </Section>
        ) : (
          <NoticeBox>
            Enable "Enable Sexual Content" (Body page) to set Headshot
            (NSFW).
          </NoticeBox>
        )}
      </Stack.Item>
      <Stack.Item>
        <Section
          title="Art Reference"
          fitted
          buttons={
            <>
              <Button
                selected={!!identityMedia.art_reference_ai_generated}
                onClick={() =>
                  act('set_art_reference_ai_generated', {
                    value: !identityMedia.art_reference_ai_generated,
                  })
                }
              >
                AI Generated?
              </Button>
              <Button
                selected={!!identityMedia.art_ref_nsfw}
                disabled={!erpUnlocked}
                tooltip={
                  erpUnlocked
                    ? undefined
                    : 'Enable "Enable Sexual Content" (Body page) to flag this NSFW.'
                }
                onClick={() =>
                  act('set_art_ref_nsfw', {
                    value: !identityMedia.art_ref_nsfw,
                  })
                }
              >
                NSFW?
              </Button>
            </>
          }
        >
          <Box p={1}>
            <Box italic mb={1} color="label">
              A single image link (same hosts as above) for a full reference
              of your character. You must flag it as NSFW if it contains nudity.
              We allow AI-Generated references, but they must be flagged properly.
            </Box>
            <Input
              fluid
              value={artReferenceUrl}
              placeholder="https://files.catbox.moe/example.png"
              onChange={(value: string) => setArtReferenceUrl(value)}
              onBlur={() =>
                act('set_art_reference_url', { value: artReferenceUrl })
              }
            />
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
}
