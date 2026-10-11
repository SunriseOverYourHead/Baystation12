import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Modal, Section, Stack } from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

type ConfirmTarget = 'noncanon' | 'erp' | null;

const CONFIRM_TEXT: Record<'noncanon' | 'erp', string> = {
  noncanon:
    'You are allowed to customize your character with body parts that belong to other species. Avoid choosing parts that are unrealistic and/or do not match your chosen species. If you do, avoid mentioning those non-canon parts outside of private IC, or OOC contexts.',
  erp: 'Sexual Content is allowed but this server offers no special meta protections outside of protected areas like the Lower Dormitories. Avoid neglecting your duties for ERP, or clock off and head to the Lower Dormitories first to free up your job slot.',
};

// Both toggles start disabled and require a one-time confirmation popup (OK/Cancel) the moment a player turns
// them ON -- turning back off needs no confirmation. Deliberately NOT part of the generic auto-registered
// Feature/PreferenceList grid -- that grid renders data.character_preferences.secondary_features IN FULL, with no
// filtering, so any key there needs a matching Feature export or PreferenceList prints "Feature ... is not
// recognized"; these two are read from `misc` instead (preferences_tgui.dm), which PreferenceList never touches.
// The set_preference act is otherwise identical to any other checkbox preference.
export function CharacterAlteringToggles() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const misc = data.character_preferences.misc;
  const noncanon = !!misc.allow_noncanon_bodyparts;
  const erpEnabled = !!misc.master_erp_preferences;

  const [confirming, setConfirming] = useState<ConfirmTarget>(null);

  function toggle(preference: 'allow_noncanon_bodyparts' | 'master_erp_preferences', current: boolean) {
    if (current) {
      act('set_preference', { preference, value: false });
      return;
    }
    setConfirming(preference === 'allow_noncanon_bodyparts' ? 'noncanon' : 'erp');
  }

  function confirm() {
    if (!confirming) return;
    const preference =
      confirming === 'noncanon' ? 'allow_noncanon_bodyparts' : 'master_erp_preferences';
    act('set_preference', { preference, value: true });
    setConfirming(null);
  }

  return (
    <>
      {!!confirming && (
        <Modal>
          <Stack vertical textAlign="center" align="center">
            <Stack.Item maxWidth="380px">
              <Box>{CONFIRM_TEXT[confirming]}</Box>
            </Stack.Item>
            <Stack.Item>
              <Stack fill>
                <Stack.Item>
                  <Button width="80px" onClick={confirm}>
                    OK
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button width="80px" onClick={() => setConfirming(null)}>
                    Cancel
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Modal>
      )}
      <Section title="Character-Altering Settings">
        <Stack fill>
          <Stack.Item grow basis={0}>
            <Button
              fluid
              selected={noncanon}
              onClick={() => toggle('allow_noncanon_bodyparts', noncanon)}
            >
              Allow Non-Canon Bodyparts
            </Button>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Button
              fluid
              selected={erpEnabled}
              onClick={() => toggle('master_erp_preferences', erpEnabled)}
            >
              Enable Sexual Content
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
}
