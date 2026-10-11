import { useBackend } from 'tgui/backend';
import { Box, Button, Dropdown, Section, Stack } from 'tgui-core/components';

import type { Language, LanguageLevel, PreferencesMenuData } from '../types';

const levelLabel = (level: LanguageLevel) =>
  `${level.name} — ${level.description}`;

/**
 * Regional variants of one tongue arrive as separate languages that share a `group`. The picker collapses each
 * group back into a single card with a variant selector, so "Spanish" reads as one choice rather than three
 * near-duplicate entries. Ungrouped languages are a group of one and render the same way minus the selector.
 */
type LanguageGroup = {
  key: string;
  variants: Language[];
};

function groupLanguages(languages: Language[]): LanguageGroup[] {
  const groups: LanguageGroup[] = [];
  const byKey = new Map<string, LanguageGroup>();

  for (const language of languages) {
    const key = language.group ?? language.name;
    let group = byKey.get(key);
    if (!group) {
      group = { key, variants: [] };
      byKey.set(key, group);
      groups.push(group);
    }
    group.variants.push(language);
  }
  return groups;
}

function FlagBadge(props: Readonly<{ language: Language }>) {
  const { icon } = props.language;
  if (!icon?.endsWith('.png')) {
    return null;
  }
  return (
    <img
      alt=""
      src={icon}
      style={{
        verticalAlign: 'middle',
        marginRight: '6px',
        imageRendering: 'pixelated',
      }}
    />
  );
}

/**
 * A language the character knows: variant and proficiency are both editable, and it can be given up.
 *
 * Rendered one card per known language rather than grouped. Each entry is already a single specific variant, so
 * grouping would buy nothing here -- and would actively hide a second variant of the same tongue behind the first,
 * leaving no way to remove it.
 */
function KnownLanguage(props: Readonly<{ language: Language }>) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { language } = props;
  const siblings = data.unselected_languages.filter(
    (candidate) => !!language.group && candidate.group === language.group,
  );
  // Only worth offering a selector when there is somewhere else to switch to.
  const variantOptions = [language, ...siblings].map((v) => v.variant_name);

  return (
    <Stack.Item>
      <Section
        title={
          <Box inline>
            <FlagBadge language={language} />
            {language.group ?? language.name}
          </Box>
        }
      >
        <Box mb="4px" color="label">
          {language.description}
        </Box>
        {!!language.warning && (
          <Box mb="4px" italic color="bad">
            {language.warning}
          </Box>
        )}
        <Stack>
          {variantOptions.length > 1 && (
            <Stack.Item>
              <Dropdown
                width="140px"
                options={variantOptions}
                selected={language.variant_name}
                onSelected={(value: string) => {
                  const picked = [language, ...siblings].find(
                    (v) => v.variant_name === value,
                  );
                  if (picked) {
                    act('set_language_variant', {
                      language_name: language.name,
                      variant_name: picked.name,
                    });
                  }
                }}
              />
            </Stack.Item>
          )}
          <Stack.Item>
            <Dropdown
              width="220px"
              options={data.language_levels.map(levelLabel)}
              selected={
                data.language_levels.find(
                  (level) => level.value === language.level,
                )
                  ? levelLabel(
                      data.language_levels.find(
                        (level) => level.value === language.level,
                      )!,
                    )
                  : language.level_name
              }
              onSelected={(value: string) => {
                const picked = data.language_levels.find(
                  (level) => levelLabel(level) === value,
                );
                if (picked) {
                  act('set_language_level', {
                    language_name: language.name,
                    level: picked.value,
                  });
                }
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              color="bad"
              icon="times"
              onClick={() =>
                act('forget_understand_language', {
                  language_name: language.name,
                })
              }
            >
              Forget
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
}

/** A language on offer. Picking a grouped one means picking which regional variant you grew up with. */
function UnknownLanguage(props: Readonly<{ group: LanguageGroup }>) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { variants } = props.group;
  const first = variants[0];
  const atCapacity =
    data.selected_languages.length >= data.total_language_points;

  return (
    <Stack.Item>
      <Section
        title={
          <Box inline>
            <FlagBadge language={first} />
            {first.group ?? first.name}
          </Box>
        }
      >
        <Box mb="4px" color="label">
          {first.description}
        </Box>
        <Stack wrap>
          {variants.map((variant) => (
            <Stack.Item key={variant.name} mb="4px">
              <Button
                color={atCapacity ? 'grey' : 'good'}
                icon="plus"
                disabled={atCapacity}
                tooltip={
                  atCapacity
                    ? `You can only learn ${data.total_language_points} languages.`
                    : `Learn ${variant.name}.`
                }
                onClick={() =>
                  act('speak_language', {
                    language_name: variant.name,
                    level: 6, // LANGUAGE_LEVEL_C2 — tune it down afterwards if you want a learner.
                  })
                }
              >
                {variants.length > 1 ? variant.variant_name : 'Learn'}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
}

/** Culture-granted languages. Free, always native, and shown only so players can see what they already have. */
function NativeLanguage(props: Readonly<{ language: Language }>) {
  const { language } = props;
  return (
    <Stack.Item>
      <Section
        title={
          <Box inline>
            <FlagBadge language={language} />
            {language.name}
          </Box>
        }
      >
        <Box mb="4px" color="label">
          {language.description}
        </Box>
        <Box color="good">Native ({language.level_name}) — granted by your background.</Box>
      </Section>
    </Stack.Item>
  );
}

export function LanguagesPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const natives = data.native_languages ?? [];

  // A group you already speak a variant of does not belong in the available column -- switching between variants of
  // one tongue is what the variant dropdown on the known card is for, and learning two of them twice over would
  // spend two slots on what is effectively the same language.
  const knownKeys = new Set(
    data.selected_languages.map((language) => language.group ?? language.name),
  );
  const availableGroups = groupLanguages(data.unselected_languages).filter(
    (group) => !knownKeys.has(group.key),
  );

  return (
    <>
      <Section textAlign="center">
        You can learn up to <b>{data.total_language_points}</b> languages on top
        of whatever your cultural background grants you for free. Proficiency
        runs from A1 (a few words) to C2 (native). Below B1 you will struggle to
        make yourself understood, and will only catch fragments of what others
        say.
      </Section>
      {natives.length > 0 && (
        <Section title="Native">
          <Stack vertical>
            {natives.map((language) => (
              <NativeLanguage key={language.name} language={language} />
            ))}
          </Stack>
        </Section>
      )}
      <Stack>
        <Stack.Item minWidth="50%">
          <Section
            title={<Box fontSize="150%">{availableGroups.length} available</Box>}
          >
            <Stack vertical>
              {availableGroups.map((group) => (
                <UnknownLanguage key={group.key} group={group} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.selected_languages.length}/{data.total_language_points}{' '}
                learned
              </Box>
            }
          >
            <Stack vertical>
              {data.selected_languages.map((language) => (
                <KnownLanguage key={language.name} language={language} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
}
