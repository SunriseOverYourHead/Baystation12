import { type ReactNode, useState } from 'react';
import { Box, Button, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CharacterPreview } from '../common/CharacterPreview';
import type { ExaminePanelData } from './data';

function formatURLs(text: string) {
  if (!text) return;
  const parts: ReactNode[] = [];
  const regex = /https?:\/\/[^\s/$.?#].[^\s]*/gi;
  let lastIndex = 0;

  text.replace(regex, (url, index) => {
    parts.push(text.substring(lastIndex, index));
    parts.push(
      <a
        style={{
          color: '#0591e3',
          textDecoration: 'none',
          borderBottom: 'solid 1.25px',
        }}
        href={url}
      >
        {url}
      </a>,
    );
    lastIndex = index + url.length;
    return url;
  });

  parts.push(text.substring(lastIndex));

  return <div>{parts}</div>;
}

type UpperTab = 'flavor_text' | 'nsfw' | 'custom_species';
type LowerTab = 'ooc_notes' | 'character_ad';

export function ExaminePanel(props) {
  const { data } = useBackend<ExaminePanelData>();
  const {
    character_name,
    character_preview_view,
    headshot_url,
    headshot_nsfw_url,
    art_reference_url,
    art_ref_nsfw,
    flavor_text,
    flavor_text_nsfw,
    custom_species,
    custom_species_lore,
    ooc_notes,
    character_ad,
  } = data;

  const [page, setPage] = useState<'main' | 'image'>('main');
  const [upperTab, setUpperTab] = useState<UpperTab>('flavor_text');
  const [lowerTab, setLowerTab] = useState<LowerTab>('ooc_notes');

  const showingNsfw = upperTab === 'nsfw';
  const effectiveHeadshotUrl = showingNsfw
    ? headshot_nsfw_url || headshot_url
    : headshot_url;

  if (page === 'image') {
    return (
      <Window title={character_name} width={700} height={600}>
        <Window.Content>
          <Box height="100%" style={{ position: 'relative' }}>
            <img
              src={art_reference_url}
              style={{
                maxHeight: '600px',
                width: '100%',
                objectFit: 'contain',
              }}
            />
            <Button
              icon="arrow-left"
              style={{ position: 'absolute', bottom: '10px', right: '10px' }}
              onClick={() => setPage('main')}
            >
              Back
            </Button>
          </Box>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title={character_name} width={700} height={610}>
      <Window.Content>
        <Box height="100%" style={{ position: 'relative' }}>
          <Stack fill>
            <Stack.Item width="30%">
              <Stack fill vertical>
                <Stack.Item grow>
                  <Section fill title="Character Preview">
                    <CharacterPreview
                      width="100%"
                      height="100%"
                      id={character_preview_view}
                    />
                  </Section>
                </Stack.Item>
                {!!effectiveHeadshotUrl && (
                  <Stack.Item grow>
                    <Section fill title="Headshot">
                      <img
                        src={effectiveHeadshotUrl}
                        style={{ maxWidth: '100%', maxHeight: '100%' }}
                      />
                    </Section>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack fill vertical>
                <Stack.Item grow>
                  <Section
                    fill
                    scrollable
                    preserveWhitespace
                    title="Flavor Text"
                    buttons={
                      <Tabs>
                        <Tabs.Tab
                          selected={upperTab === 'flavor_text'}
                          onClick={() => setUpperTab('flavor_text')}
                        >
                          Flavor Text
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={upperTab === 'nsfw'}
                          onClick={() => setUpperTab('nsfw')}
                        >
                          NSFW (Warning)
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={upperTab === 'custom_species'}
                          onClick={() => setUpperTab('custom_species')}
                        >
                          {custom_species || 'Unnamed Species'}
                        </Tabs.Tab>
                      </Tabs>
                    }
                  >
                    {upperTab === 'flavor_text' && formatURLs(flavor_text)}
                    {upperTab === 'nsfw' && formatURLs(flavor_text_nsfw)}
                    {upperTab === 'custom_species' &&
                      formatURLs(custom_species_lore)}
                  </Section>
                </Stack.Item>
                <Stack.Item grow>
                  <Section
                    fill
                    scrollable
                    preserveWhitespace
                    title="Notes"
                    buttons={
                      <Tabs>
                        <Tabs.Tab
                          selected={lowerTab === 'ooc_notes'}
                          onClick={() => setLowerTab('ooc_notes')}
                        >
                          OOC Notes
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={lowerTab === 'character_ad'}
                          onClick={() => setLowerTab('character_ad')}
                        >
                          Character Advert
                        </Tabs.Tab>
                      </Tabs>
                    }
                  >
                    {lowerTab === 'ooc_notes' && formatURLs(ooc_notes)}
                    {lowerTab === 'character_ad' && formatURLs(character_ad)}
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
          {!!art_reference_url && (
            <Button
              icon="image"
              color={art_ref_nsfw ? 'pink' : 'green'}
              style={{ position: 'absolute', bottom: '10px', right: '10px' }}
              onClick={() => setPage('image')}
            >
              Art Reference
            </Button>
          )}
        </Box>
      </Window.Content>
    </Window>
  );
}
