import { useBackend } from 'tgui/backend';
import { Box, Dropdown, LabeledList, Section } from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

export function CulturalPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverPrefs = useServerPrefs();

  const culturalOptions: Record<string, string[]> =
    (serverPrefs?.cultural_options as Record<string, string[]>) ?? {};
  const culturalDescriptions: Record<string, Record<string, string>> =
    (serverPrefs?.cultural_descriptions as Record<
      string,
      Record<string, string>
    >) ?? {};
  const tagLabels: Record<string, string> =
    (serverPrefs?.cultural_tag_labels as Record<string, string>) ?? {};
  const currentInfo = data.cultural_info ?? {};

  const tags = Object.keys(culturalOptions).filter(
    (tag) => culturalOptions[tag].length > 0,
  );

  if (tags.length === 0) {
    return null;
  }

  return (
    <Section title="Cultural Background">
      <LabeledList>
        {tags.map((tag) => {
          const options = culturalOptions[tag];
          const label = tagLabels[tag] ?? tag;
          const selected = currentInfo[tag] ?? options[0];
          const description = culturalDescriptions[tag]?.[selected];
          return (
            <LabeledList.Item key={tag} label={label}>
              <Dropdown
                width="250px"
                options={options}
                selected={selected}
                onSelected={(val: string) =>
                  act('set_cultural_info', { tag, value: val })
                }
              />
              {!!description && (
                <Box mt={0.5} italic color="label">
                  {description}
                </Box>
              )}
            </LabeledList.Item>
          );
        })}
      </LabeledList>
    </Section>
  );
}
