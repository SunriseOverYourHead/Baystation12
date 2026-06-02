import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

type JobEntry = {
  title: string;
  slots_left: number; // -1 = infinite
  ref: string;
};

type SubmapEntry = {
  name: string;
  archetype: string;
  jobs: JobEntry[];
};

type Data = {
  submaps: SubmapEntry[];
};

export const GhostRoles = (props) => {
  const { act, data } = useBackend<Data>();
  const { submaps = [] } = data;

  const [expanded, setExpanded] = useState<string | null>(null);

  if (submaps.length === 0) {
    return (
      <Window title="Ghost Roles" width={480} height={200}>
        <Window.Content>
          <Box color="label" italic textAlign="center" mt={3}>
            No off-station roles are currently available.
          </Box>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title="Ghost Roles" width={520} height={560}>
      <Window.Content scrollable>
        <Stack vertical>
          {submaps.map((submap) => {
            const isExpanded = expanded === submap.name;
            return (
              <Stack.Item key={submap.name}>
                <Section
                  title={submap.name}
                  buttons={
                    <Button
                      icon={isExpanded ? 'chevron-up' : 'chevron-down'}
                      onClick={() =>
                        setExpanded(isExpanded ? null : submap.name)
                      }
                    >
                      {isExpanded ? 'Collapse' : 'View Roles'}
                    </Button>
                  }
                >
                  <Box color="label" fontSize="11px">
                    {submap.archetype}
                  </Box>

                  {isExpanded && (
                    <Box mt={1}>
                      {submap.jobs.map((job) => (
                        <Stack key={job.title} align="center" mb={0.5}>
                          <Stack.Item grow>
                            <Box bold>{job.title}</Box>
                            <Box color="label" fontSize="11px">
                              {job.slots_left === -1
                                ? 'Unlimited slots'
                                : `${job.slots_left} slot${job.slots_left !== 1 ? 's' : ''} remaining`}
                            </Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              tooltip="Teleport to this role's spawn area to observe."
                              onClick={() =>
                                act('jump', {
                                  ref: job.ref,
                                  job: job.title,
                                })
                              }
                            >
                              Jump
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button.Confirm
                              color="good"
                              tooltip="Join this role. You will leave your ghost and spawn as this character."
                              confirmContent="Are you sure? You will leave ghost mode."
                              onClick={() =>
                                act('join', {
                                  ref: job.ref,
                                  job: job.title,
                                })
                              }
                            >
                              Join
                            </Button.Confirm>
                          </Stack.Item>
                        </Stack>
                      ))}
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};
