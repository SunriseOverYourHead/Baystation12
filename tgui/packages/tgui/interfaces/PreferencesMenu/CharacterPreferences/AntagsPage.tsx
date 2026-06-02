import { binaryInsertWith } from 'common/collections';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Divider,
  Section,
  Stack,
  TextArea,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { type Antagonist, Category } from '../antagonists/base';
import type { PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

const requireAntag = require.context(
  '../antagonists/antagonists',
  false,
  /.ts$/,
);

const antagsByCategory = new Map<Category, Antagonist[]>();

function binaryInsertAntag(collection: Antagonist[], value: Antagonist) {
  return binaryInsertWith(collection, value, (antag) => {
    return `${antag.priority}_${antag.name}`;
  });
}

for (const antagKey of requireAntag.keys()) {
  const antag = requireAntag<{
    default?: Antagonist;
  }>(antagKey).default;

  if (!antag) {
    continue;
  }

  antagsByCategory.set(
    antag.category,
    binaryInsertAntag(antagsByCategory.get(antag.category) || [], antag),
  );
}

type AntagSelectionProps = Readonly<{
  antagonists: Antagonist[];
  name: string;
}>;

function AntagSelection(props: AntagSelectionProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const className = 'PreferencesMenu__Antags__antagSelection';

  const [predictedState, setPredictedState] = useState(
    new Set(data.selected_antags),
  );

  function enableAntags(antags: string[]) {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.add(antag);
    }

    setPredictedState(newState);

    act('set_antags', {
      antags,
      toggled: true,
    });
  }

  function disableAntags(antags: string[]) {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.delete(antag);
    }

    setPredictedState(newState);

    act('set_antags', {
      antags,
      toggled: false,
    });
  }

  const antagonistKeys = props.antagonists.map(
    (antagonist) => antagonist.dmId ?? antagonist.key,
  );

  return (
    <Section
      title={props.name}
      buttons={
        <>
          <Button color="good" onClick={() => enableAntags(antagonistKeys)}>
            Enable All
          </Button>

          <Button color="bad" onClick={() => disableAntags(antagonistKeys)}>
            Disable All
          </Button>
        </>
      }
    >
      <Stack className={className} wrap>
        {props.antagonists.map((antagonist) => {
          const dmId = antagonist.dmId ?? antagonist.key;
          const isBanned = data.antag_bans?.includes(dmId);

          const daysLeft = data.antag_days_left?.[dmId] || 0;

          let statusClass: string;
          if (isBanned || daysLeft > 0) {
            statusClass = 'banned';
          } else if (predictedState.has(dmId)) {
            statusClass = 'on';
          } else {
            statusClass = 'off';
          }

          return (
            <Stack.Item
              className={classes([
                `${className}__antagonist`,
                `${className}__antagonist--${statusClass}`,
              ])}
              key={antagonist.key}
            >
              <Stack align="center" vertical>
                <Stack.Item
                  style={{
                    fontWeight: 'bold',
                    marginTop: 'auto',
                    maxWidth: '100px',
                    textAlign: 'center',
                  }}
                >
                  {antagonist.name}
                </Stack.Item>

                <Stack.Item align="center">
                  <Tooltip
                    content={
                      isBanned
                        ? `You are banned from ${antagonist.name}.`
                        : antagonist.description.map((text, index) => {
                            return (
                              <div key={antagonist.key + index}>
                                {text}
                                {index !==
                                  antagonist.description.length - 1 && (
                                  <Divider />
                                )}
                              </div>
                            );
                          })
                    }
                    position="bottom"
                  >
                    <Box
                      className={'antagonist-icon-parent'}
                      onClick={() => {
                        if (isBanned) {
                          return;
                        }

                        if (predictedState.has(dmId)) {
                          disableAntags([dmId]);
                        } else {
                          enableAntags([dmId]);
                        }
                      }}
                    >
                      <Box
                        className={classes([
                          'antagonists96x96',
                          antagonist.key,
                          'antagonist-icon',
                        ])}
                      />

                      {isBanned && <Box className="antagonist-banned-slash" />}

                      {daysLeft > 0 && (
                        <Box className="antagonist-days-left">
                          <b>{daysLeft}</b> days left
                        </Box>
                      )}
                    </Box>
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
}

function AntagSetup() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverPrefs = useServerPrefs();
  const allSources = serverPrefs?.uplink_source_options ?? [];
  const selectedSources = data.uplink_sources ?? [];
  const [exploitText, setExploitText] = useState(data.exploit_record ?? '');

  function saveExploit() {
    act('set_exploit_record', { value: exploitText });
  }

  function toggleSource(name: string) {
    act('toggle_uplink_source', { source: name });
  }

  function moveSource(name: string, direction: 'up' | 'down') {
    act('move_uplink_source', { source: name, direction });
  }

  return (
    <Section title="Traitor Setup">
      <Stack>
        <Stack.Item grow>
          <Section
            title="Exploitable Information"
            buttons={
              <Button icon="save" onClick={saveExploit}>
                Save
              </Button>
            }
          >
            <Box italic mb={1} color="label">
              Information about your character that antagonists may exploit.
            </Box>
            <TextArea
              fluid
              height="80px"
              value={exploitText}
              maxLength={1024}
              onChange={(value: string) => setExploitText(value)}
              onBlur={saveExploit}
            />
          </Section>
        </Stack.Item>
        {allSources.length > 0 && (
          <Stack.Item width="200px">
            <Section title="Uplink Source Priority">
              <Box italic mb={1} color="label">
                Preferred uplink delivery methods, in order.
              </Box>
              <Stack vertical>
                {allSources.map((name) => {
                  const idx = selectedSources.indexOf(name);
                  const isSelected = idx !== -1;
                  return (
                    <Stack.Item key={name}>
                      <Stack align="center">
                        <Stack.Item grow>
                          <Button
                            fluid
                            selected={isSelected}
                            onClick={() => toggleSource(name)}
                          >
                            {isSelected ? `${idx + 1}. ` : ''}
                            {name}
                          </Button>
                        </Stack.Item>
                        {isSelected && (
                          <>
                            <Stack.Item>
                              <Button
                                icon="arrow-up"
                                disabled={idx === 0}
                                onClick={() => moveSource(name, 'up')}
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="arrow-down"
                                disabled={
                                  idx === selectedSources.length - 1
                                }
                                onClick={() => moveSource(name, 'down')}
                              />
                            </Stack.Item>
                          </>
                        )}
                      </Stack>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
}

export function AntagsPage() {
  return (
    <Box className="PreferencesMenu__Antags">
      <AntagSetup />

      {!!antagsByCategory.get(Category.Roundstart)?.length && (
        <AntagSelection
          name="Roundstart"
          antagonists={antagsByCategory.get(Category.Roundstart)!}
        />
      )}

      {!!antagsByCategory.get(Category.Midround)?.length && (
        <AntagSelection
          name="Midround"
          antagonists={antagsByCategory.get(Category.Midround)!}
        />
      )}

      {!!antagsByCategory.get(Category.Latejoin)?.length && (
        <AntagSelection
          name="Latejoin"
          antagonists={antagsByCategory.get(Category.Latejoin)!}
        />
      )}
    </Box>
  );
}
