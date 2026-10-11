import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

type FlavorTab = 'character' | 'robot';

export function FlavorTextPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const erp = data.character_preferences.erp_directory || ({} as any);
  const robotFlavorTexts =
    data.character_preferences.robot_flavor_texts || {};
  const robotModules = data.character_preferences.robot_module_names || [];
  const allRobotFields = ['Default', ...robotModules];

  const [tab, setTab] = useState<FlavorTab>('character');

  const [characterAd, setCharacterAd] = useState(erp.character_ad || '');
  const [customSpecies, setCustomSpecies] = useState(
    erp.custom_species || '',
  );
  const [customSpeciesLore, setCustomSpeciesLore] = useState(
    erp.custom_species_lore || '',
  );
  const [flavorText, setFlavorText] = useState(
    erp.character_flavor_text || '',
  );
  const [flavorTextNsfw, setFlavorTextNsfw] = useState(
    erp.flavor_text_nsfw || '',
  );
  const [oocNotes, setOocNotes] = useState(erp.ooc_notes || '');

  // Robot tab state
  const [robotSelected, setRobotSelected] = useState('Default');
  const [robotText, setRobotText] = useState(
    robotFlavorTexts['Default'] || '',
  );

  function switchRobotField(key: string) {
    if (key === robotSelected) return;
    act('set_robot_flavor_text', { module: robotSelected, value: robotText });
    setRobotSelected(key);
    setRobotText(robotFlavorTexts[key] || '');
  }

  function saveRobot() {
    act('set_robot_flavor_text', { module: robotSelected, value: robotText });
  }

  const robotDesc =
    robotSelected === 'Default'
      ? 'Shown for any robot module without its own description set.'
      : `Shown when playing as a ${robotSelected} cyborg.`;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Button
              selected={tab === 'character'}
              onClick={() => setTab('character')}
            >
              Character
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={tab === 'robot'}
              onClick={() => setTab('robot')}
            >
              Robot
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {tab === 'character' ? (
          <Stack fill vertical>
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item grow basis={0}>
                  <Section fill title="Custom Species">
                    <Input
                      fluid
                      mb={1}
                      placeholder="Leave blank to use your real species name"
                      value={customSpecies}
                      onChange={(value: string) => setCustomSpecies(value)}
                      onBlur={() =>
                        act('set_custom_species', { value: customSpecies })
                      }
                    />
                    <TextArea
                      fluid
                      height="calc(100% - 52px)"
                      placeholder="Leave blank to use your real species description"
                      value={customSpeciesLore}
                      maxLength={4096}
                      onChange={(value: string) =>
                        setCustomSpeciesLore(value)
                      }
                      onBlur={() =>
                        act('set_custom_species_lore', {
                          value: customSpeciesLore,
                        })
                      }
                    />
                  </Section>
                </Stack.Item>
                <Stack.Item grow basis={0}>
                  <Section fill title="Character Advert">
                    <Stack fill vertical>
                      <Stack.Item>
                        <Box italic mb={1} color="label">
                          Shown on the Character Advert tab of your Examine
                          Panel, along with a summary of your Dating
                          Preferences.
                        </Box>
                      </Stack.Item>
                      <Stack.Item grow>
                        <TextArea
                          fluid
                          height="100%"
                          value={characterAd}
                          maxLength={4096}
                          onChange={(value: string) => setCharacterAd(value)}
                          onBlur={() =>
                            act('set_character_ad', { value: characterAd })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item grow basis={0}>
                  <Section fill title="Flavor Text">
                    <TextArea
                      fluid
                      height="100%"
                      value={flavorText}
                      maxLength={4096}
                      onChange={(value: string) => setFlavorText(value)}
                      onBlur={() =>
                        act('set_character_flavor_text', {
                          value: flavorText,
                        })
                      }
                    />
                  </Section>
                </Stack.Item>
                <Stack.Item grow basis={0}>
                  <Section fill title="Flavor Text (NSFW)">
                    <Stack fill vertical>
                      {!erp.erp_unlocked && (
                        <Stack.Item>
                          <Box italic mb={1} color="label">
                            Enable "Enable Sexual Content" (Body page) to
                            set Flavor Text (NSFW).
                          </Box>
                        </Stack.Item>
                      )}
                      <Stack.Item grow>
                        <TextArea
                          fluid
                          disabled={!erp.erp_unlocked}
                          height="100%"
                          value={flavorTextNsfw}
                          maxLength={4096}
                          onChange={(value: string) =>
                            setFlavorTextNsfw(value)
                          }
                          onBlur={() =>
                            act('set_flavor_text_nsfw', {
                              value: flavorTextNsfw,
                            })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill title="OOC Notes">
                <Stack fill vertical>
                  <Stack.Item>
                    <Box italic mb={1} color="label">
                      Out-of-character notes about your character, visible
                      to anyone who examines you closely.
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <TextArea
                      fluid
                      height="100%"
                      value={oocNotes}
                      maxLength={6144}
                      onChange={(value: string) => setOocNotes(value)}
                      onBlur={() =>
                        act('set_record', {
                          field: 'ooc_notes',
                          value: oocNotes,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        ) : (
          <Stack fill>
            <Stack.Item width="110px">
              <Stack vertical fill>
                {allRobotFields.map((module) => (
                  <Stack.Item key={module}>
                    <Button
                      fluid
                      selected={robotSelected === module}
                      onClick={() => switchRobotField(module)}
                    >
                      {module}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Section
                fill
                title={robotSelected}
                buttons={
                  <Button icon="save" onClick={saveRobot}>
                    Save
                  </Button>
                }
              >
                <Box italic mb={1} color="label">
                  {robotDesc}
                </Box>
                <TextArea
                  key={robotSelected}
                  fluid
                  height="calc(100% - 28px)"
                  value={robotText}
                  maxLength={1000}
                  onChange={(value: string) => setRobotText(value)}
                  onBlur={saveRobot}
                />
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Stack.Item>
    </Stack>
  );
}
