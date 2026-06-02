import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';

type AreaEntry = {
  name: string;
  ref: string;
  z: number;
};

type SectorEntry = {
  sector: string;
  areas: AreaEntry[];
};

type Data = {
  sectors: SectorEntry[];
};

export const GhostTeleport = (props) => {
  const { act, data } = useBackend<Data>();
  const { sectors = [] } = data;

  const [selectedSector, setSelectedSector] = useState<string>(
    sectors[0]?.sector ?? '',
  );
  const [search, setSearch] = useState('');

  const sectorNames = sectors.map((s) => s.sector);
  const activeSector = sectorNames.includes(selectedSector)
    ? selectedSector
    : (sectorNames[0] ?? '');

  const currentSector = sectors.find((s) => s.sector === activeSector);
  const areas = currentSector?.areas ?? [];

  const filtered = search
    ? areas.filter((a) => a.name.toLowerCase().includes(search.toLowerCase()))
    : areas;

  // Group areas by z-level within the active sector
  const byZ: Record<number, AreaEntry[]> = {};
  for (const area of filtered) {
    if (!byZ[area.z]) byZ[area.z] = [];
    byZ[area.z].push(area);
  }
  const zLevels = Object.keys(byZ)
    .map(Number)
    .sort((a, b) => a - b);

  return (
    <Window title="Teleport" width={480} height={560}>
      <Window.Content>
        <Stack vertical fill>
          {/* Sector dropdown — only shown when there are multiple sectors */}
          {sectors.length > 1 && (
            <Stack.Item>
              <Dropdown
                fluid
                options={sectorNames}
                selected={activeSector}
                onSelected={(s: string) => {
                  setSelectedSector(s);
                  setSearch('');
                }}
              />
            </Stack.Item>
          )}

          {/* Area search */}
          <Stack.Item>
            <Input
              fluid
              placeholder="Search areas..."
              value={search}
              onInput={(_, val) => setSearch(val)}
            />
          </Stack.Item>

          {/* Areas grouped by z-level, each group collapsible */}
          <Stack.Item grow>
            <Section fill scrollable>
              {zLevels.length === 0 && (
                <Box color="label" italic>
                  No areas found.
                </Box>
              )}
              {zLevels.map((z, i) => (
                <Collapsible key={z} title={`Z-Level ${z}`} open={i === 0}>
                  {byZ[z].map((area) => (
                    <Stack key={area.ref} align="center" mb={0.25} ml={1}>
                      <Stack.Item grow>
                        <Box>{area.name}</Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          onClick={() => act('teleport', { ref: area.ref })}
                        >
                          Go
                        </Button>
                      </Stack.Item>
                    </Stack>
                  ))}
                </Collapsible>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
