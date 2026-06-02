import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Dropdown,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import type { PreferencesMenuData, SkillEntry } from '../types';
import { useServerPrefs } from '../useServerPrefs';

const SKILL_NAMES = ['Unskilled', 'Basic', 'Trained', 'Experienced', 'Master'];

type SkillRowProps = {
  jobName: string;
  skill: SkillEntry;
  skillData: Record<string, { min: number; max: number; current: number }>;
  pointsRemaining: number;
  indent?: boolean;
};

function prerequisitesMet(
  skill: SkillEntry,
  skillData: Record<string, { min: number; max: number; current: number }>,
): boolean {
  for (const [prereqType, minLevel] of Object.entries(skill.prerequisites)) {
    const prereqData = skillData[prereqType];
    const current = prereqData?.current ?? 1;
    if (current < minLevel) return false;
  }
  return true;
}

function costToReach(skill: SkillEntry, from: number, to: number): number {
  let cost = 0;
  for (let i = from + 1; i <= to; i++) {
    cost += skill.levels[i - 1]?.cost ?? 0;
  }
  return cost;
}

function SkillRow(props: Readonly<SkillRowProps>) {
  const { act } = useBackend<PreferencesMenuData>();
  const { jobName, skill, skillData, pointsRemaining, indent } = props;

  const entry = skillData[skill.type];
  const min = entry?.min ?? 1;
  const max = entry?.max ?? 1;
  const current = entry?.current ?? min;
  const prereqsMet = prerequisitesMet(skill, skillData);

  const levelButtons = [];
  for (let lvl = min; lvl <= max; lvl++) {
    const levelName = skill.levels[lvl - 1]?.name ?? SKILL_NAMES[lvl - 1] ?? String(lvl);
    const costToThis = costToReach(skill, current, lvl);
    const costFromThis = costToReach(skill, lvl, current);
    const canAfford = lvl <= current || costToThis <= pointsRemaining;
    const isActive = lvl === current;
    const isMin = lvl === min;

    levelButtons.push(
      <Stack.Item key={lvl}>
        <Tooltip
          content={
            isMin
              ? 'Minimum required level'
              : isActive
                ? 'Current level'
                : lvl < current
                  ? `Refund ${costFromThis} pts`
                  : canAfford
                    ? `Cost: ${costToThis} pts`
                    : `Need ${costToThis} pts`
          }
          position="bottom"
        >
          <Button
            selected={isActive}
            disabled={!prereqsMet || (!canAfford && lvl > current)}
            color={
              isMin
                ? 'transparent'
                : isActive
                  ? 'green'
                  : lvl < current
                    ? 'average'
                    : 'default'
            }
            onClick={() =>
              act('set_skill_level', {
                job: jobName,
                skill: skill.type,
                level: lvl,
              })
            }
          >
            {levelName}
          </Button>
        </Tooltip>
      </Stack.Item>,
    );
  }

  return (
    <Stack mb={0.5} align="center">
      <Stack.Item width={indent ? '25%' : '30%'} pl={indent ? 3 : 0}>
        <Tooltip content={skill.desc} position="right">
          <Box
            inline
            style={{
              cursor: 'help',
              opacity: prereqsMet ? 1 : 0.5,
            }}
          >
            {skill.name}
          </Box>
        </Tooltip>
      </Stack.Item>
      <Stack.Item grow>
        <Stack wrap>{levelButtons}</Stack>
      </Stack.Item>
    </Stack>
  );
}

type JobSkillsProps = {
  jobName: string;
};

export function JobSkillsPanel(props: Readonly<JobSkillsProps>) {
  const { data } = useBackend<PreferencesMenuData>();
  const serverPrefs = useServerPrefs();
  const { jobName } = props;

  const jobData = data.skill_jobs?.[jobName];
  if (!jobData) return null;

  const { points_remaining: pointsRemaining, skills: skillData } = jobData;
  const skillTree = serverPrefs?.skill_tree ?? [];

  return (
    <Box>
      <Box bold mb={1}>
        Points remaining:{' '}
        <Box
          inline
          color={pointsRemaining === 0 ? 'average' : 'good'}
        >
          {pointsRemaining}
        </Box>
      </Box>
      {skillTree.map((category) => (
        <Section key={category.id} title={category.name}>
          {category.skills.map((skill) => (
            <Box key={skill.id}>
              <SkillRow
                jobName={jobName}
                skill={skill}
                skillData={skillData}
                pointsRemaining={pointsRemaining}
              />
              {skill.children.map((perk) => (
                <SkillRow
                  key={perk.id}
                  jobName={jobName}
                  skill={perk}
                  skillData={skillData}
                  pointsRemaining={pointsRemaining}
                  indent
                />
              ))}
            </Box>
          ))}
        </Section>
      ))}
    </Box>
  );
}

export function SkillsPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const serverPrefs = useServerPrefs();
  const [selectedJob, setSelectedJob] = useState('');

  const skillJobs = data.skill_jobs ?? {};
  const jobNames = Object.keys(skillJobs);

  if (jobNames.length === 0 || !serverPrefs?.skill_tree?.length) {
    return (
      <Box color="label" mt={2} textAlign="center">
        No skill-enabled jobs available.
      </Box>
    );
  }

  const currentJob =
    jobNames.includes(selectedJob) ? selectedJob : jobNames[0];

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Box color="label">Job:</Box>
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              width="200px"
              options={jobNames}
              selected={currentJob}
              onSelected={(val: string) => setSelectedJob(val)}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <JobSkillsPanel jobName={currentJob} />
      </Stack.Item>
    </Stack>
  );
}
