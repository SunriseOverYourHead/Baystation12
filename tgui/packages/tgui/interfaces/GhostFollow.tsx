import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Box,
  Button,
  Collapsible,
  Icon,
  Input,
  Stack,
} from 'tgui-core/components';

// Department display priority (matches crew manifest order)
const DEPT_ORDER = [
  'Command',
  'Command Support',
  'Security',
  'Medical',
  'Engineering',
  'Research',
  'Supply',
  'Infantry',
  'Service',
  'Civilian',
  'Miscellaneous',
];

// Medium-dark department colors — readable with white button text
const DEPT_COLORS: Record<string, string> = {
  'Command': '#b59400',
  'Command Support': '#9a7200',
  'Security': '#aa2222',
  'Medical': '#1155aa',
  'Engineering': '#cc6600',
  'Research': '#7733aa',
  'Supply': '#228844',
  'Infantry': '#445522',
  'Service': '#1a7a45',
  'Civilian': '#2266cc',
  'Miscellaneous': '#555566',
};

// Scale the icon2html img to 80x80 so the 8x8 content area fills the 20x20 clip box.
function sizeIcon(html: string): string {
  return html
    .replace(/\s*style="[^"]*"/i, '')
    .replace(/<img/i, '<img style="width:80px;height:80px;max-width:none;display:block;image-rendering:pixelated;"');
}

// Button color based on blood oxygenation and brain health.
// Grey overrides if the player has no client (ghosted).
function chipColor(oxy_pct: number, brain_pct: number, has_client: boolean): string {
  if (!has_client) return '#555555';
  const min = Math.min(oxy_pct, brain_pct);
  if (min < 40) return '#7a1010';
  if (min < 80) return '#8a4a00';
  return '#1a5c1a';
}

type MobEntry = {
  ref: string;
  name: string;
  job: string;
  job_color: string;
  job_icon: string;
  department: string;
  is_head: number;
  oxy_pct: number;
  brain_pct: number;
  has_client: number;
  orbiters: number;
};

type SimplemobEntry = {
  ref: string;
  name: string;
  type: 'animal' | 'mech';
};

type GhostEntry = {
  ref: string;
  name: string;
  orbiters: number;
};

type FactionEntry = {
  name: string;
  color: string;
  members: MobEntry[];
};

type Data = {
  factions: FactionEntry[];
  simplemobs: SimplemobEntry[];
  dead: MobEntry[];
  ghosts: GhostEntry[];
};

function OrbiterBadge(props: Readonly<{ count: number }>) {
  const { count } = props;
  if (!count) return null;
  return (
    <Box inline color="label" fontSize="10px" ml={0.4}>
      <Icon name="ghost" mr={0.2} />
      {count}
    </Box>
  );
}

// Renders the job icon from icon2html HTML. Falls back to colored square if missing.
function JobIcon(props: Readonly<{ html: string; color: string }>) {
  const { html, color } = props;
  if (html) {
    return (
      <span
        dangerouslySetInnerHTML={{ __html: sizeIcon(html) }}
        style={{
          display: 'inline-block',
          width: '20px',
          height: '20px',
          overflow: 'hidden',
          marginRight: '3px',
          flexShrink: 0,
          verticalAlign: 'middle',
        }}
      />
    );
  }
  if (color) {
    return (
      <Box
        inline
        mr={0.4}
        style={{
          width: '14px',
          height: '14px',
          background: color,
          border: '1px solid rgba(255,255,255,0.2)',
          flexShrink: 0,
          display: 'inline-block',
          verticalAlign: 'middle',
        }}
      />
    );
  }
  return null;
}

function MobChip(props: Readonly<{
  name: string;
  job?: string;
  job_icon?: string;
  job_color?: string;
  oxy_pct?: number;
  brain_pct?: number;
  has_client?: number;
  orbiters?: number;
  onFollow: () => void;
}>) {
  const {
    name,
    job,
    job_icon = '',
    job_color = '',
    oxy_pct = 100,
    brain_pct = 100,
    has_client = 1,
    orbiters = 0,
    onFollow,
  } = props;
  return (
    <Box
      inline
      m={0.3}
      style={{ verticalAlign: 'middle', display: 'inline-flex', alignItems: 'center' }}
    >
      <JobIcon html={job_icon} color={job_color} />
      <Button
        tooltip={job || undefined}
        onClick={onFollow}
        style={{
          padding: '1px 5px',
          fontSize: '12px',
          background: chipColor(oxy_pct, brain_pct, !!has_client),
        }}
      >
        {name}
        <OrbiterBadge count={orbiters} />
      </Button>
    </Box>
  );
}

function SimplemobChip(props: Readonly<{
  name: string;
  type: string;
  onFollow: () => void;
}>) {
  const { name, type, onFollow } = props;
  return (
    <Box inline m={0.3} style={{ display: 'inline-flex', alignItems: 'center' }}>
      <Button
        tooltip={type === 'mech' ? 'Exosuit' : 'Animal'}
        onClick={onFollow}
        style={{ padding: '1px 5px', fontSize: '12px' }}
      >
        {name}
      </Button>
    </Box>
  );
}

// Group members by department, ordered by DEPT_ORDER, heads first within dept.
function DeptChips(props: Readonly<{ members: MobEntry[]; onFollow: (ref: string) => void }>) {
  const { members, onFollow } = props;
  const groups: Record<string, MobEntry[]> = {};
  for (const m of members) {
    const d = m.department || 'Miscellaneous';
    if (!groups[d]) groups[d] = [];
    groups[d].push(m);
  }
  for (const d of Object.keys(groups)) {
    groups[d].sort((a, b) => b.is_head - a.is_head || a.name.localeCompare(b.name));
  }
  const sorted = Object.entries(groups).sort(([a], [b]) => {
    const ai = DEPT_ORDER.indexOf(a);
    const bi = DEPT_ORDER.indexOf(b);
    return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi);
  });
  return (
    <>
      {sorted.map(([dept, mobs]) => (
        <Box key={dept} mb={0.5}>
          <Collapsible
            title={`${dept} (${mobs.length})`}
            color={DEPT_COLORS[dept] ? undefined : 'label'}
            open
            style={{ borderLeft: DEPT_COLORS[dept] ? `3px solid ${DEPT_COLORS[dept]}` : undefined }}
          >
            <Box style={{ display: 'flex', flexWrap: 'wrap' }}>
              {mobs.map((m) => (
                <MobChip
                  key={m.ref}
                  name={m.name}
                  job={m.job}
                  job_icon={m.job_icon}
                  job_color={m.job_color}
                  oxy_pct={m.oxy_pct}
                  brain_pct={m.brain_pct}
                  has_client={m.has_client}
                  orbiters={m.orbiters}
                  onFollow={() => onFollow(m.ref)}
                />
              ))}
            </Box>
          </Collapsible>
        </Box>
      ))}
    </>
  );
}

export const GhostFollow = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    factions = [],
    simplemobs = [],
    dead = [],
    ghosts = [],
  } = data;

  const [search, setSearch] = useState('');

  const q = search.toLowerCase();

  const filterMobs = (list: MobEntry[]): MobEntry[] =>
    q
      ? list.filter(
          (m) =>
            m.name.toLowerCase().includes(q) ||
            (m.job || '').toLowerCase().includes(q),
        )
      : list;

  const filterSimple = (list: SimplemobEntry[]): SimplemobEntry[] =>
    q ? list.filter((m) => m.name.toLowerCase().includes(q)) : list;

  const filterGhosts = (list: GhostEntry[]): GhostEntry[] =>
    q ? list.filter((m) => m.name.toLowerCase().includes(q)) : list;

  const follow = (ref: string) => act('follow', { ref });

  const filteredFactions = factions
    .map((f) => ({ ...f, members: filterMobs(f.members) }))
    .filter((f) => f.members.length > 0);

  const filteredSimple = filterSimple(simplemobs);
  const filteredDead = filterMobs(dead);
  const filteredGhosts = filterGhosts(ghosts);

  return (
    <Window title="Orbit" width={520} height={580}>
      <Window.Content scrollable>
        <Stack vertical>
          {/* Search bar */}
          <Stack.Item>
            <Input
              fluid
              placeholder="Search name or job..."
              value={search}
              onInput={(_, val) => setSearch(val)}
            />
          </Stack.Item>

          {/* Faction groups */}
          {filteredFactions.map((faction) => (
            <Stack.Item key={faction.name}>
              <Collapsible
                title={`${faction.name} (${faction.members.length})`}
                color={faction.color}
                open
              >
                <Box px={0.5} pb={0.5}>
                  <DeptChips members={faction.members} onFollow={follow} />
                </Box>
              </Collapsible>
            </Stack.Item>
          ))}

          {/* Simplemobs */}
          <Stack.Item>
            <Collapsible title={`Simplemobs (${filteredSimple.length})`}>
              {filteredSimple.length === 0 ? (
                <Box color="label" italic ml={1} mb={0.5}>
                  No simplemobs.
                </Box>
              ) : (
                <Box style={{ display: 'flex', flexWrap: 'wrap', padding: '2px 4px' }}>
                  {filteredSimple.map((m) => (
                    <SimplemobChip
                      key={m.ref}
                      name={m.name}
                      type={m.type}
                      onFollow={() => follow(m.ref)}
                    />
                  ))}
                </Box>
              )}
            </Collapsible>
          </Stack.Item>

          {/* Dead players */}
          <Stack.Item>
            <Collapsible title={`Dead (${filteredDead.length})`} color="bad">
              {filteredDead.length === 0 ? (
                <Box color="label" italic ml={1} mb={0.5}>
                  No dead players.
                </Box>
              ) : (
                <Box style={{ display: 'flex', flexWrap: 'wrap', padding: '2px 4px' }}>
                  {filteredDead.map((m) => (
                    <MobChip
                      key={m.ref}
                      name={m.name}
                      job={m.job}
                      job_icon={m.job_icon}
                      job_color={m.job_color}
                      has_client={0}
                      orbiters={m.orbiters}
                      onFollow={() => follow(m.ref)}
                    />
                  ))}
                </Box>
              )}
            </Collapsible>
          </Stack.Item>

          {/* Active ghosts */}
          <Stack.Item>
            <Collapsible title={`Ghosts (${filteredGhosts.length})`} color="average">
              {filteredGhosts.length === 0 ? (
                <Box color="label" italic ml={1} mb={0.5}>
                  No active ghosts.
                </Box>
              ) : (
                <Box style={{ display: 'flex', flexWrap: 'wrap', padding: '2px 4px' }}>
                  {filteredGhosts.map((m) => (
                    <Box
                      key={m.ref}
                      inline
                      m={0.3}
                      style={{ display: 'inline-flex', alignItems: 'center' }}
                    >
                      <Button
                        onClick={() => follow(m.ref)}
                        style={{ padding: '1px 5px', fontSize: '12px' }}
                      >
                        {m.name}
                        <OrbiterBadge count={m.orbiters} />
                      </Button>
                    </Box>
                  ))}
                </Box>
              )}
            </Collapsible>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
