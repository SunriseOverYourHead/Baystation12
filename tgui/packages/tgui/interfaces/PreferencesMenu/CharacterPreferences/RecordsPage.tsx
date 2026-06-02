import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

const RECORD_FIELDS = [
  {
    key: 'public_record',
    label: 'Public',
    desc: 'General public record. Visible to anyone who looks you up.',
  },
  {
    key: 'med_record',
    label: 'Medical',
    desc: 'Medical history. Visible to medical staff.',
  },
  {
    key: 'sec_record',
    label: 'Security',
    desc: 'Security record. Visible to security staff.',
  },
  {
    key: 'gen_record',
    label: 'Employment',
    desc: 'Employment history. Visible to command staff.',
  },
  {
    key: 'memory',
    label: 'Memory',
    desc: 'Personal notes only visible to you in-game.',
  },
];

export function RecordsPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const records = data.character_preferences.records || ({} as any);

  const [selected, setSelected] = useState('public_record');
  const [localText, setLocalText] = useState(records[selected] || '');
  const [emailAddr, setEmailAddr] = useState(records.email_addr || '');
  const [emailPass, setEmailPass] = useState(records.email_pass || '');

  function switchField(key: string) {
    if (key === selected) return;
    act('set_record', { field: selected, value: localText });
    setSelected(key);
    setLocalText(records[key] || '');
  }

  function save() {
    act('set_record', { field: selected, value: localText });
  }

  function saveEmail() {
    act('set_record', { field: 'email_addr', value: emailAddr });
  }

  function saveEmailPass() {
    act('set_email_pass', { value: emailPass });
  }

  const current = RECORD_FIELDS.find((f) => f.key === selected) ?? RECORD_FIELDS[0];

  return (
    <Stack fill>
      <Stack.Item width="110px">
        <Stack vertical fill>
          {RECORD_FIELDS.map((field) => (
            <Stack.Item key={field.key}>
              <Button
                fluid
                selected={selected === field.key}
                onClick={() => switchField(field.key)}
              >
                {field.label}
              </Button>
            </Stack.Item>
          ))}
          <Stack.Item mt={2}>
            <Section title="Email" fitted>
              <LabeledList>
                <LabeledList.Item label="Address">
                  <Input
                    fluid
                    value={emailAddr}
                    placeholder="username"
                    maxLength={24}
                    onChange={(value: string) => setEmailAddr(value)}
                    onBlur={saveEmail}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Password">
                  <Input
                    fluid
                    value={emailPass}
                    placeholder="(random)"
                    maxLength={16}
                    onChange={(value: string) => setEmailPass(value)}
                    onBlur={saveEmailPass}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          title={current.label}
          buttons={
            <Button icon="save" onClick={save}>
              Save
            </Button>
          }
        >
          <Box italic mb={1} color="label">
            {current.desc}
          </Box>
          <TextArea
            key={selected}
            fluid
            height="calc(100% - 28px)"
            value={localText}
            maxLength={6144}
            onChange={(value: string) => setLocalText(value)}
            onBlur={save}
          />
        </Section>
      </Stack.Item>
    </Stack>
  );
}
