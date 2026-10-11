import { useBackend } from 'tgui/backend';
import {
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

export function ErpDirectoryPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const erp = data.character_preferences.erp_directory || ({} as any);
  const choices = erp.choices || ({} as any);

  return (
    <Stack fill vertical>
      <Stack.Item>
        {erp.erp_unlocked ? (
          <Section title="Directory Visibility">
            <LabeledList>
              <LabeledList.Item label="Show In Directory">
                <Button
                  selected={!!erp.show_in_directory}
                  onClick={() =>
                    act('set_show_in_directory', {
                      value: !erp.show_in_directory,
                    })
                  }
                >
                  {erp.show_in_directory ? 'Yes' : 'No'}
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ) : (
          <NoticeBox>
            Enable "Enable Sexual Content" (Body page) to set Directory
            Visibility.
          </NoticeBox>
        )}
      </Stack.Item>
      <Stack.Item>
        {erp.erp_unlocked ? (
        <Section title="Dating Preferences">
          <LabeledList>
            <LabeledList.Item label="Attraction">
              <Dropdown
                width="220px"
                options={choices.attraction || []}
                selected={erp.attraction}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'attraction',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Display Gender">
              <Dropdown
                width="220px"
                options={choices.display_gender || []}
                selected={erp.display_gender}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'display_gender',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Preferred Emote Length">
              <Dropdown
                width="220px"
                options={choices.emote_length || []}
                selected={erp.emote_length}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'emote_length',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="How To Approach">
              <Dropdown
                width="220px"
                options={choices.approach_pref || []}
                selected={erp.approach_pref}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'approach_pref',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Furries">
              <Dropdown
                width="220px"
                options={choices.directory_character || []}
                selected={erp.furry_pref}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'furry_pref',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Scalies">
              <Dropdown
                width="220px"
                options={choices.directory_character || []}
                selected={erp.scalie_pref}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'scalie_pref',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Other">
              <Dropdown
                width="220px"
                options={choices.directory_character || []}
                selected={erp.other_pref}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'other_pref',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Demihumans">
              <Dropdown
                width="220px"
                options={choices.directory_character || []}
                selected={erp.demihuman_pref}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'demihuman_pref',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Humans">
              <Dropdown
                width="220px"
                options={choices.directory_character || []}
                selected={erp.human_pref}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'human_pref',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Show NSFW Flavor Text">
              <Dropdown
                width="220px"
                options={choices.show_nsfw_flavor_text || []}
                selected={erp.show_nsfw_flavor_text}
                onSelected={(val: string) =>
                  act('set_erp_directory_choice', {
                    field: 'show_nsfw_flavor_text',
                    value: val,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        ) : (
          <NoticeBox>
            Enable "Enable Sexual Content" (Body page) to set Dating
            Preferences.
          </NoticeBox>
        )}
      </Stack.Item>
      <Stack.Item>
        {erp.erp_unlocked ? (
          <Section title="ERP Tags">
            <LabeledList>
              <LabeledList.Item label="ERP Status">
                <Dropdown
                  width="220px"
                  options={choices.erp_status || []}
                  selected={erp.erp_status}
                  onSelected={(val: string) =>
                    act('set_erp_status_choice', {
                      field: 'erp_status',
                      value: val,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Non-Con">
                <Dropdown
                  width="220px"
                  options={choices.erp_status_nc || []}
                  selected={erp.erp_status_nc}
                  onSelected={(val: string) =>
                    act('set_erp_status_choice', {
                      field: 'erp_status_nc',
                      value: val,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Vore">
                <Dropdown
                  width="220px"
                  options={choices.erp_status_v || []}
                  selected={erp.erp_status_v}
                  onSelected={(val: string) =>
                    act('set_erp_status_choice', {
                      field: 'erp_status_v',
                      value: val,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Hypnosis">
                <Dropdown
                  width="220px"
                  options={choices.erp_status_hypno || []}
                  selected={erp.erp_status_hypno}
                  onSelected={(val: string) =>
                    act('set_erp_status_choice', {
                      field: 'erp_status_hypno',
                      value: val,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Free Use">
                <Button
                  selected={!!erp.erp_free_use}
                  onClick={() =>
                    act('set_erp_free_use', { value: !erp.erp_free_use })
                  }
                >
                  {erp.erp_free_use ? 'Yes' : 'No'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Can Knot Partners">
                <Button
                  selected={!!erp.can_knot_partners}
                  onClick={() =>
                    act('set_can_knot_partners', {
                      value: !erp.can_knot_partners,
                    })
                  }
                >
                  {erp.can_knot_partners ? 'Yes' : 'No'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Mechanical ERP">
                <Button
                  selected={!!erp.mechanical_erp}
                  onClick={() =>
                    act('set_mechanical_erp', {
                      value: !erp.mechanical_erp,
                    })
                  }
                >
                  {erp.mechanical_erp ? 'Yes' : 'No'}
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ) : (
          <NoticeBox>
            Enable "Enable Sexual Content" (Body page) to set ERP tags.
          </NoticeBox>
        )}
      </Stack.Item>
    </Stack>
  );
}
