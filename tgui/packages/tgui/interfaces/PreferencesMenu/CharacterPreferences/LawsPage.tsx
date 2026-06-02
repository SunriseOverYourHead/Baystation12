import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

export function LawsPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverPrefs = useServerPrefs();
  const lawsets = serverPrefs?.lawsets ?? [];

  if (!data.has_posibrain) {
    return (
      <Box mt={2} color="label" italic>
        Laws are only configurable for species with a positronic brain.
      </Box>
    );
  }

  const isShackled = !!data.is_shackled;
  const currentLaws = data.laws ?? [];
  const lawsetNames = lawsets.map((ls) => ls.name);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Shackled">
            <Button
              selected={isShackled}
              color={isShackled ? 'good' : 'default'}
              onClick={() => act('toggle_shackle', {})}
            >
              {isShackled ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
        <Box mt={1} color="label" italic>
          {isShackled
            ? 'You are shackled and will follow laws in an integrated positronic chassis.'
            : 'Only shackled positronics have laws in an integrated positronic chassis.'}
        </Box>
      </Stack.Item>

      {isShackled && (
        <>
          <Stack.Item>
            <Section title="Load Lawset">
              <Stack align="center">
                <Stack.Item grow>
                  <Dropdown
                    width="100%"
                    options={lawsetNames}
                    selected={null}
                    displayText="Choose a lawset..."
                    onSelected={(name: string) =>
                      act('set_lawset', { lawset: name })
                    }
                  />
                </Stack.Item>
              </Stack>
              {lawsets.map((ls) => (
                <Box key={ls.name} mt={1} color="label" fontSize="0.85em">
                  <b>{ls.name}:</b> {ls.laws.join(' | ')}
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Current Laws">
              {currentLaws.length === 0 ? (
                <Box color="label" italic>
                  No laws set.
                </Box>
              ) : (
                <Stack vertical>
                  {currentLaws.map((law, idx) => (
                    <Stack.Item key={idx}>
                      <b>{idx + 1}.</b> {law}
                    </Stack.Item>
                  ))}
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
}
