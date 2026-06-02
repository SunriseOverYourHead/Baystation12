import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import type { Language, PreferencesMenuData } from '../types';

function KnownLanguage(props: Readonly<{ language: Language }>) {
  const { act } = useBackend<PreferencesMenuData>();
  return (
    <Stack.Item>
      <Section title={<Box inline>{props.language.name}</Box>}>
        <Box mb="4px" color="label">
          {props.language.description}
        </Box>
        <Button
          color="bad"
          icon="times"
          onClick={() =>
            act('forget_understand_language', {
              language_name: props.language.name,
            })
          }
        >
          Forget
        </Button>
      </Section>
    </Stack.Item>
  );
}

function UnknownLanguage(props: Readonly<{ language: Language }>) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const atCapacity =
    data.selected_languages.length >= data.total_language_points;
  return (
    <Stack.Item>
      <Section title={<Box inline>{props.language.name}</Box>}>
        <Box mb="4px" color="label">
          {props.language.description}
        </Box>
        <Button
          color={atCapacity ? 'grey' : 'good'}
          icon="plus"
          disabled={atCapacity}
          tooltip={
            atCapacity
              ? `You can only know ${data.total_language_points} additional languages.`
              : 'Learn this language.'
          }
          onClick={() =>
            act('speak_language', { language_name: props.language.name })
          }
        >
          Learn
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function LanguagesPage() {
  const { data } = useBackend<PreferencesMenuData>();
  return (
    <>
      <Section textAlign="center">
        You can know up to <b>{data.total_language_points}</b> additional
        languages. Cultural background may grant languages for free.
      </Section>
      <Stack>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.unselected_languages.length} available
              </Box>
            }
          >
            <Stack vertical>
              {data.unselected_languages.map((val) => (
                <UnknownLanguage key={val.name} language={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.selected_languages.length}/{data.total_language_points}{' '}
                known
              </Box>
            }
          >
            <Stack vertical>
              {data.selected_languages.map((val) => (
                <KnownLanguage key={val.name} language={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
}
