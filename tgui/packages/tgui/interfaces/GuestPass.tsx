import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const MODE_ISSUE = 0;
const MODE_LOGS = 1;

type AccessEntry = {
  desc: string;
  access: number;
  selected: BooleanLike;
};

type Data = {
  mode: number;
  internal_log: string[];
  reason: string;
  duration: number;
  giver?: BooleanLike;
  giver_name?: string;
  giv_name?: string;
  giver_access?: AccessEntry[];
};

export const GuestPass = () => {
  const { act, data } = useBackend<Data>();
  const {
    mode,
    internal_log = [],
    reason,
    duration,
    giver,
    giver_name,
    giv_name,
    giver_access = [],
  } = data;

  const [localName, setLocalName] = useState(giv_name || '');
  const [localReason, setLocalReason] = useState(reason || '');
  const [localDuration, setLocalDuration] = useState(duration || 5);

  const selectedCount = giver_access.filter((a) => a.selected).length;

  return (
    <Window title="Guest Pass Terminal" width={520} height={600}>
      <Window.Content scrollable>
        <Section
          title="ID Card"
          buttons={
            <Button
              icon={giver ? 'eject' : 'id-card'}
              onClick={() => act('toggle_id')}
            >
              {giver ? `Eject (${giver_name})` : 'Insert ID'}
            </Button>
          }
        >
          {!giver && (
            <NoticeBox>Insert an ID card to issue guest passes.</NoticeBox>
          )}
        </Section>

        <Stack mb={1}>
          <Stack.Item>
            <Button
              selected={mode === MODE_ISSUE}
              onClick={() => act('set_mode', { mode: MODE_ISSUE })}
            >
              Issue Pass
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={mode === MODE_LOGS}
              onClick={() => act('set_mode', { mode: MODE_LOGS })}
            >
              Activity Log
            </Button>
          </Stack.Item>
        </Stack>

        {mode === MODE_ISSUE && !!giver && (
          <>
            <Section title="Pass Details">
              <LabeledList>
                <LabeledList.Item label="Issued To">
                  <Input
                    fluid
                    value={localName}
                    placeholder="Recipient name"
                    onChange={(val) => setLocalName(val)}
                    onEnter={() => act('set_giv_name', { name: localName })}
                    onBlur={() => act('set_giv_name', { name: localName })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Reason">
                  <Input
                    fluid
                    value={localReason}
                    placeholder="Reason for pass"
                    onChange={(val) => setLocalReason(val)}
                    onEnter={() => act('set_reason', { reason: localReason })}
                    onBlur={() => act('set_reason', { reason: localReason })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Duration (min)">
                  <NumberInput
                    value={localDuration}
                    minValue={1}
                    maxValue={60}
                    step={1}
                    onChange={(val) => {
                      setLocalDuration(val);
                      act('set_duration', { duration: val });
                    }}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>

            <Section title="Access Permissions">
              {giver_access.length === 0 ? (
                <NoticeBox>No access permissions on issuing ID.</NoticeBox>
              ) : (
                giver_access.map((entry) => (
                  <Button
                    key={entry.access}
                    selected={!!entry.selected}
                    onClick={() =>
                      act('toggle_access', { access: entry.access })
                    }
                    mr={0.5}
                    mb={0.5}
                  >
                    {entry.desc}
                  </Button>
                ))
              )}
            </Section>

            <Box mt={1}>
              <Button
                fluid
                icon="id-card"
                color="good"
                disabled={!selectedCount || !localName}
                onClick={() => act('issue')}
              >
                Issue Pass ({selectedCount} access
                {selectedCount !== 1 ? 'es' : ''} granted,{' '}
                {localDuration} min)
              </Button>
            </Box>
          </>
        )}

        {mode === MODE_LOGS && (
          <Section
            title="Activity Log"
            buttons={
              <Button icon="print" onClick={() => act('print')}>
                Print
              </Button>
            }
          >
            {internal_log.length === 0 ? (
              <NoticeBox>No activity on record.</NoticeBox>
            ) : (
              internal_log.map((entry, i) => (
                <Box
                  key={i}
                  mb={1}
                  p={1}
                  style={{ background: 'rgba(0,0,0,0.2)' }}
                >
                  {entry}
                </Box>
              ))
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
