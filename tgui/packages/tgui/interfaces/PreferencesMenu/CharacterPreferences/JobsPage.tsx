import { sortBy } from 'es-toolkit';
import type { PropsWithChildren, ReactNode } from 'react';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Dropdown, Section, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { JobSkillsPanel, SkillsPage } from './SkillsPage';

import {
  createSetPreference,
  type Job,
  JoblessRole,
  JobPriority,
  type PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

function sortJobs(entries: [string, Job][], head?: string) {
  return sortBy(entries, [
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key,
  ]);
}

const PRIORITY_BUTTON_SIZE = '18px';

type PriorityButtonProps = {
  name: string;
  color: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
};

function PriorityButton(props: PriorityButtonProps) {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    // NOVA EDIT START
    <Button
      className={classes([
        className,
        props.modifier && `${className}--${props.modifier}`,
      ])}
      color={props.enabled ? props.color : 'white'}
      circular
      onClick={props.onClick}
      tooltip={props.name}
      tooltipPosition="bottom"
      height={PRIORITY_BUTTON_SIZE}
      width={PRIORITY_BUTTON_SIZE}
    />
    // NOVA EDIT END
  );
}

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

function createCreateSetPriorityFromName(jobName: string): CreateSetPriority {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  function createSetPriority(priority: JobPriority | null) {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    function setPriority() {
      const { act } = useBackend<PreferencesMenuData>();

      act('set_job_preference', {
        job: jobName,
        level: priority,
      });
    }

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  }

  createSetPriorityCache[jobName] = createSetPriority;

  return createSetPriority;
}

function PriorityHeaders() {
  const className = 'PreferencesMenu__Jobs__PriorityHeader';

  return (
    <Stack>
      <Stack.Item grow />

      <Stack.Item className={className}>Off</Stack.Item>

      <Stack.Item className={className}>Low</Stack.Item>

      <Stack.Item className={className}>Medium</Stack.Item>

      <Stack.Item className={className}>High</Stack.Item>
    </Stack>
  );
}

type PriorityButtonsProps = {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority;
};

function PriorityButtons(props: PriorityButtonsProps) {
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Box // NOVA EDIT - Originally a stack
      style={{
        display: 'flex', // BS12: ensure buttons are flex-aligned
        alignItems: 'center',
        height: '100%',
        justifyContent: 'flex-end',
        paddingLeft: '0.3em',
        paddingTop: '0.12em', // NOVA EDIT ADDITION - Add some vertical padding
        paddingBottom: '0.12em', // NOVA EDIT ADDITION - To make this look nicer
      }}
    >
      {isOverflow ? (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="On"
            color="green"
            enabled={!!priority}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Low"
            color="red"
            enabled={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name="Medium"
            color="yellow"
            enabled={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name="High"
            color="green"
            enabled={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Box> // NOVA EDIT - Originally a stack
  );
}

type UniformCategoryProps = {
  category: string;
  jobName: string;
  pieces: { ref: string; name: string }[];
  selected: string[];
};

function UniformCategory(props: Readonly<UniformCategoryProps>) {
  const { act } = useBackend<PreferencesMenuData>();
  const { category, jobName, pieces, selected } = props;
  return (
    <Box mb={1}>
      <Box bold mb={0.5}>
        {category}
      </Box>
      <Stack wrap>
        {pieces.map((piece) => (
          <Stack.Item key={piece.ref}>
            <Button
              selected={selected.includes(piece.ref)}
              onClick={() =>
                act('toggle_uniform', { job: jobName, piece: piece.ref })
              }
            >
              {piece.name}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
}

type JobRowProps = {
  className?: string;
  job: Job;
  name: string;
};

function JobRow(props: JobRowProps) {
  const { data, act } = useBackend<PreferencesMenuData>(); // NOVA EDIT CHANGE - Adds act param
  const { className, job, name } = props;
  const [showUniforms, setShowUniforms] = useState(false);
  const [showSkills, setShowSkills] = useState(false); // BS12: per-job skills panel
  const serverPrefs = useServerPrefs();

  const isOverflow = data.overflow_role === name;
  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(name);

  const experienceNeeded = data.job_required_experience?.[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  // NOVA EDIT ADDITION START
  const alt_title_selected = data.job_alt_titles[name]
    ? data.job_alt_titles[name]
    : name;
  // NOVA EDIT ADDITION END

  // BS12: branch/rank selection — driven from dynamic player data, not static server_data
  const showBranchRank = !!data.map_has_branch;
  const currentBranch = showBranchRank ? (data.job_branches[name] ?? '') : '';
  const currentRank = showBranchRank ? (data.job_ranks[name] ?? '') : '';
  const branchDisplay = currentBranch
    ? (serverPrefs?.mil_branches[currentBranch] ?? currentBranch)
    : '—';
  const rankDisplay = currentRank
    ? (serverPrefs?.rank_shorts?.[currentRank] ?? currentRank)
    : '—';
  const branchRank = job.branch_rank;
  const branchOptions = branchRank ? Object.keys(branchRank) : [];
  const rankOptions =
    branchRank && currentBranch ? (branchRank[currentBranch] ?? []) : [];

  let rightSide: ReactNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{hoursNeeded}h</b> as {experience_type}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{daysLeft}</b> day{daysLeft === 1 ? '' : 's'} left
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans?.includes(name)) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>Banned</b>
        </Stack.Item>
      </Stack>
    );
    // NOVA EDIT START
  } else if (job.nova_star && !data.is_nova_star) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>Nova Stars Only</b>
        </Stack.Item>
      </Stack>
    );
  } else if (data.species_restricted_jobs?.includes(name)) {
    rightSide = (
      <Tooltip content="Incompatible Species" position="bottom">
        <Box style={{ opacity: 0.4, pointerEvents: 'none', textDecoration: 'line-through' }}>
          <PriorityButtons
            createSetPriority={createSetPriority}
            isOverflow={isOverflow}
            priority={priority}
          />
        </Box>
      </Tooltip>
    );
    // NOVA EDIT END
  } else {
    rightSide = (
      <PriorityButtons
        createSetPriority={createSetPriority}
        isOverflow={isOverflow}
        priority={priority}
      />
    );
  }

  return (
    <Stack.Item className={className} height="100%" mt={0}>
      <Stack fill align="center">
        {/* BS12: branch abbreviation */}
        {showBranchRank && (
          <Stack.Item width="10%" style={{ paddingLeft: '0.3em' }}>
            {branchOptions.length > 1 ? (
              <Dropdown
                width="100%"
                options={branchOptions}
                selected={currentBranch}
                displayText={branchDisplay}
                onSelected={(branch: string) =>
                  act('set_job_branch', { job: name, branch })
                }
              />
            ) : (
              <Box
                inline
                style={{ opacity: currentBranch ? 1 : 0.4, fontSize: '0.85em' }}
              >
                {branchDisplay}
              </Box>
            )}
          </Stack.Item>
        )}

        {/* BS12: rank */}
        {showBranchRank && (
          <Stack.Item width="20%" style={{ paddingLeft: '0.2em' }}>
            {rankOptions.length > 1 ? (
              <Dropdown
                width="100%"
                options={rankOptions}
                selected={currentRank}
                displayText={rankDisplay}
                onSelected={(rank: string) =>
                  act('set_job_rank', { job: name, rank })
                }
              />
            ) : (
              <Tooltip content={currentRank || ''}>
                <Box
                  style={{
                    opacity: currentRank ? 1 : 0.4,
                    fontSize: '0.85em',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {rankDisplay}
                </Box>
              </Tooltip>
            )}
          </Stack.Item>
        )}

        <Tooltip content={job.description} position="bottom-start">
          <Stack.Item
            className="job-name"
            width={showBranchRank ? '25%' : '50%'}
            style={{
              paddingLeft: '0.3em',
            }}
          >
            {
              // NOVA EDIT CHANGE START - ORIGINAL: {name}
              !job.alt_titles ? (
                name
              ) : (
                <Dropdown
                  width="100%"
                  options={job.alt_titles}
                  selected={alt_title_selected}
                  onSelected={(value) =>
                    act('set_job_title', { job: name, new_title: value })
                  }
                />
              )
              // NOVA EDIT CHANGE END
            }
          </Stack.Item>
        </Tooltip>

        <Stack.Item grow className="options">
          {rightSide}
        </Stack.Item>
        {/* BS12: inline uniform toggle button */}
        {(() => {
          const uniformOptions = (serverPrefs?.uniform_options ?? {}) as Record<
            string,
            Record<string, { ref: string; name: string }[]>
          >;
          if (!uniformOptions[name]) return null;
          return (
            <Stack.Item>
              <Button
                icon="shirt"
                tooltip="Uniform Selection"
                tooltipPosition="bottom"
                selected={showUniforms}
                onClick={() => setShowUniforms(!showUniforms)}
              />
            </Stack.Item>
          );
        })()}
        {/* BS12: inline skills toggle button */}
        {!!data.skill_jobs?.[name] && (
          <Stack.Item>
            <Button
              icon="book"
              tooltip="Skills"
              tooltipPosition="bottom"
              selected={showSkills}
              onClick={() => setShowSkills(!showSkills)}
            />
          </Stack.Item>
        )}
      </Stack>
      {/* BS12: inline uniform panel */}
      {showUniforms &&
        (() => {
          const uniformOptions = (serverPrefs?.uniform_options ?? {}) as Record<
            string,
            Record<string, { ref: string; name: string }[]>
          >;
          const categories = uniformOptions[name];
          if (!categories) return null;
          const selected = data.uniforms_by_job?.[name] ?? [];
          return (
            <Box pt={0.5} pl={1}>
              {Object.entries(categories).map(([cat, pieces]) => (
                <UniformCategory
                  key={cat}
                  category={cat}
                  jobName={name}
                  pieces={pieces}
                  selected={selected}
                />
              ))}
            </Box>
          );
        })()}
      {/* BS12: inline skills panel */}
      {showSkills && (
        <Box pt={0.5} pl={1}>
          <JobSkillsPanel jobName={name} />
        </Box>
      )}
    </Stack.Item>
  );
}

type DepartmentProps = {
  department: string;
} & PropsWithChildren;

function Department(props: DepartmentProps) {
  const { children, department: name } = props;
  const className = `PreferencesMenu__Jobs__departments--${name}`;

  const serverData = useServerPrefs();
  const { data: prefsData } = useBackend<PreferencesMenuData>();
  if (!serverData) return;

  const { departments, jobs } = serverData.jobs;
  const department = departments[name];

  // This isn't necessarily a bug, it's like this
  // so that you can remove entire departments without
  // having to edit the UI.
  // This is used in events, for instance.
  if (!department) {
    return null;
  }

  const hidingMaps = prefsData.hiding_maps ?? {};
  // If any map is explicitly set to TRUE (selected), filter to only those maps.
  // Otherwise (no filter active), show all jobs.
  const selectedMap = Object.keys(hidingMaps).find((m) => !!hidingMaps[m]);
  const jobsForDepartment = sortJobs(
    Object.entries(jobs)
      .filter(([_, job]) => job.department === name)
      .filter(([_, job]) => {
        if (!job.maps || job.maps.length === 0) return true;
        if (!selectedMap) return true;
        return job.maps.includes(selectedMap);
      }),
    department.head,
  );

  return (
    <Box>
      <Stack fill vertical g={0}>
        {jobsForDepartment.map(([name, job]) => {
          return (
            <JobRow
              className={classes([
                className,
                name === department.head && 'head',
              ])}
              key={name}
              job={job}
              name={name}
            />
          );
        })}
      </Stack>

      {children}
    </Box>
  );
}

function JoblessRoleDropdown(props) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.joblessrole;

  const options = [
    {
      displayText: `Join as ${data.overflow_role} if unavailable`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Join as a random job if unavailable`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Return to lobby if unavailable`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const selection = options?.find(
    (option) => option.value === selected,
  )?.displayText;

  return (
    <Box position="absolute" right={0} width="30%">
      <Dropdown
        width="100%"
        selected={selection}
        onSelected={createSetPreference(act, 'joblessrole')}
        options={options}
      />
    </Box>
  );
}

function MapHiding() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverPrefs = useServerPrefs();
  const maps = serverPrefs?.available_maps ?? [];
  if (maps.length <= 1) return null;

  const hiding = data.hiding_maps ?? {};
  // Currently selected map (exclusive), or 'all' if no filter active
  const selectedMap = Object.keys(hiding).find((m) => !!hiding[m]) ?? 'all';

  return (
    <Section title="Map Filter">
      <Stack wrap>
        <Stack.Item>
          <Button
            selected={selectedMap === 'all'}
            onClick={() => act('select_map', { map: 'all' })}
          >
            All Maps
          </Button>
        </Stack.Item>
        {maps.map((mapName) => (
          <Stack.Item key={mapName}>
            <Button
              selected={selectedMap === mapName}
              onClick={() => act('select_map', { map: mapName })}
            >
              {mapName}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function JobPreferences() {
  return (
    <>
      <JoblessRoleDropdown />
      <Stack vertical fill>
        <Stack.Item mt={15}>
          <Stack fill g={1} className="PreferencesMenu__Jobs">
            <Stack.Item>
              <Stack vertical>
                <PriorityHeaders />
                <Department department="Command" />
                <Department department="Support" />
                <Department department="Security" />
                <Department department="Medical" />
                <Department department="Engineering" />
                <Department department="Infantry" />
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <PriorityHeaders />
                <Department department="Science" />
                <Department department="Supply" />
                <Department department="Service" />
                <Department department="Silicon" />
                <Department department="Civilian" />
                <Department department="Exploration" />
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <MapHiding />
        </Stack.Item>
      </Stack>
    </>
  );
}

type JobsTab = 'preferences' | 'skills';

export function JobsPage() {
  const [tab, setTab] = useState<JobsTab>('preferences');

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Button
              selected={tab === 'preferences'}
              onClick={() => setTab('preferences')}
            >
              Jobs
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={tab === 'skills'}
              onClick={() => setTab('skills')}
            >
              Skills
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {tab === 'preferences' && <JobPreferences />}
        {tab === 'skills' && <SkillsPage />}
      </Stack.Item>
    </Stack>
  );
}
