import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

const BODY_FIELDS = [
  {
    key: 'general',
    label: 'General',
    desc: 'Shown when examined regardless of clothing.',
  },
  { key: 'head', label: 'Head', desc: 'Description of your head.' },
  { key: 'face', label: 'Face', desc: 'Description of your face.' },
  { key: 'eyes', label: 'Eyes', desc: 'Description of your eyes.' },
  {
    key: 'torso',
    label: 'Body',
    desc: 'Description of your torso/body.',
  },
  { key: 'arms', label: 'Arms', desc: 'Description of your arms.' },
  { key: 'hands', label: 'Hands', desc: 'Description of your hands.' },
  { key: 'legs', label: 'Legs', desc: 'Description of your legs.' },
  { key: 'feet', label: 'Feet', desc: 'Description of your feet.' },
];

type FlavorTab = 'body' | 'robot';

export function FlavorTextPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const flavorTexts = data.character_preferences.flavor_texts || {};
  const robotFlavorTexts =
    data.character_preferences.robot_flavor_texts || {};
  const robotModules = data.character_preferences.robot_module_names || [];
  const allRobotFields = ['Default', ...robotModules];

  const [tab, setTab] = useState<FlavorTab>('body');

  // Body tab state
  const [bodySelected, setBodySelected] = useState('general');
  const [bodyText, setBodyText] = useState(flavorTexts['general'] || '');

  // Robot tab state
  const [robotSelected, setRobotSelected] = useState('Default');
  const [robotText, setRobotText] = useState(
    robotFlavorTexts['Default'] || '',
  );

  function switchBodyField(key: string) {
    if (key === bodySelected) return;
    act('set_flavor_text', { field: bodySelected, value: bodyText });
    setBodySelected(key);
    setBodyText(flavorTexts[key] || '');
  }

  function saveBody() {
    act('set_flavor_text', { field: bodySelected, value: bodyText });
  }

  function switchRobotField(key: string) {
    if (key === robotSelected) return;
    act('set_robot_flavor_text', { module: robotSelected, value: robotText });
    setRobotSelected(key);
    setRobotText(robotFlavorTexts[key] || '');
  }

  function saveRobot() {
    act('set_robot_flavor_text', { module: robotSelected, value: robotText });
  }

  const currentBody =
    BODY_FIELDS.find((f) => f.key === bodySelected) ?? BODY_FIELDS[0];
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
              selected={tab === 'body'}
              onClick={() => setTab('body')}
            >
              Body
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
        {tab === 'body' ? (
          <Stack fill>
            <Stack.Item width="110px">
              <Stack vertical fill>
                {BODY_FIELDS.map((field) => (
                  <Stack.Item key={field.key}>
                    <Button
                      fluid
                      selected={bodySelected === field.key}
                      onClick={() => switchBodyField(field.key)}
                    >
                      {field.label}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Section
                fill
                title={currentBody.label}
                buttons={
                  <Button icon="save" onClick={saveBody}>
                    Save
                  </Button>
                }
              >
                <Box italic mb={1} color="label">
                  {currentBody.desc}
                </Box>
                <TextArea
                  key={bodySelected}
                  fluid
                  height="calc(100% - 28px)"
                  value={bodyText}
                  maxLength={1000}
                  onChange={(value: string) => setBodyText(value)}
                  onBlur={saveBody}
                />
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
