import { useState } from 'react';
import {
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RosterEntry = {
  ref: string;
  name: string;
  species: string;
  attraction: string;
  display_gender: string;
  erp_status: string;
  erp_status_v: string;
  erp_status_hypno: string;
  erp_status_nc: string;
};

type Controls = {
  show_in_directory: boolean;
  attraction: string;
  display_gender: string;
  erp_status: string;
  erp_status_v: string;
  erp_status_hypno: string;
  erp_status_nc: string;
};

type CharacterDirectoryData = {
  roster: RosterEntry[];
  controls: Controls;
};

// Row background color, keyed on the row's own ERP status only -- matches Bubberstation's own erpTagColor map
// exactly (ZubbersCharacterDirectory.jsx).
const erpTagColor: Record<string, string> = {
  Unset: '#000000',
  'Top - Dom': '#410308',
  'Top - Switch': '#410308',
  'Top - Sub': '#410308',
  'Verse-Top - Dom': '#3d003b',
  'Verse-Top - Switch': '#3d003b',
  'Verse-Top - Sub': '#3d003b',
  'Verse - Dom': '#310042',
  'Verse - Switch': '#310042',
  'Verse - Sub': '#310042',
  'Verse-Bottom - Dom': '#29084b',
  'Verse-Bottom - Switch': '#29084b',
  'Verse-Bottom - Sub': '#29084b',
  'Bottom - Dom': '#002f51',
  'Bottom - Switch': '#002f51',
  'Bottom - Sub': '#002f51',
  'Check OOC Notes': '#333333',
  'Ask (L)OOC': '#333333',
  No: '#131313',
  Yes: '#002901',
};

// Custom sort priority for the ERP column -- matches Bubberstation's own erpOrder (not alphabetical).
const erpOrder = [
  'Top - Dom',
  'Top - Switch',
  'Top - Sub',
  'Verse-Top - Dom',
  'Verse-Top - Switch',
  'Verse-Top - Sub',
  'Verse - Dom',
  'Verse - Switch',
  'Verse - Sub',
  'Verse-Bottom - Dom',
  'Verse-Bottom - Switch',
  'Verse-Bottom - Sub',
  'Bottom - Dom',
  'Bottom - Switch',
  'Bottom - Sub',
  'Yes',
  'Check OOC Notes',
  'Ask (L)OOC',
  'No',
  'Unset',
];

type SortColumn = 'name' | 'species' | 'attraction' | 'display_gender' | 'erp_status';

export function CharacterDirectory(props) {
  const { act, data } = useBackend<CharacterDirectoryData>();
  const { roster = [], controls = {} as Controls } = data;
  const [search, setSearch] = useState('');
  const [sortColumn, setSortColumn] = useState<SortColumn>('name');
  const [sortDesc, setSortDesc] = useState(false);

  const filtered = roster.filter((entry) => {
    const needle = search.toLowerCase();
    return (
      !needle ||
      entry.name?.toLowerCase().includes(needle) ||
      entry.species?.toLowerCase().includes(needle)
    );
  });

  const sorted = [...filtered].sort((a, b) => {
    let result: number;
    if (sortColumn === 'erp_status') {
      result = erpOrder.indexOf(a.erp_status) - erpOrder.indexOf(b.erp_status);
    } else {
      result = (a[sortColumn] || '').localeCompare(b[sortColumn] || '');
    }
    return sortDesc ? -result : result;
  });

  function sortBy(column: SortColumn) {
    if (column === sortColumn) {
      setSortDesc(!sortDesc);
    } else {
      setSortColumn(column);
      setSortDesc(false);
    }
  }

  function iFeelLucky() {
    if (!filtered.length) return;
    const pick = filtered[Math.floor(Math.random() * filtered.length)];
    act('view', { ref: pick.ref });
  }

  return (
    <Window title="Character Directory" width={720} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Controls">
              <LabeledList>
                <LabeledList.Item label="Visibility">
                  {controls.show_in_directory ? 'Shown' : 'Not Shown'}
                </LabeledList.Item>
                <LabeledList.Item label="Attraction">
                  {controls.attraction}
                </LabeledList.Item>
                <LabeledList.Item label="Gender">
                  {controls.display_gender}
                </LabeledList.Item>
                <LabeledList.Item label="ERP">
                  {controls.erp_status}
                </LabeledList.Item>
                <LabeledList.Item label="Vore">
                  {controls.erp_status_v}
                </LabeledList.Item>
                <LabeledList.Item label="Hypno">
                  {controls.erp_status_hypno}
                </LabeledList.Item>
                <LabeledList.Item label="Noncon">
                  {controls.erp_status_nc}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={`Directory (${sorted.length})`}
              buttons={
                <>
                  <Input
                    mr={1}
                    placeholder="Search..."
                    value={search}
                    onChange={(value: string) => setSearch(value)}
                  />
                  <Button icon="sync" onClick={() => act('refresh')}>
                    Refresh
                  </Button>
                  <Button
                    icon="random"
                    tooltip="Display a random player's advert. Click if you dare."
                    onClick={iFeelLucky}
                  >
                    I Feel Lucky
                  </Button>
                </>
              }
            >
              <Table>
                <Table.Row header>
                  <Table.Cell onClick={() => sortBy('name')}>Name</Table.Cell>
                  <Table.Cell onClick={() => sortBy('species')}>
                    Species
                  </Table.Cell>
                  <Table.Cell onClick={() => sortBy('attraction')}>
                    Attraction
                  </Table.Cell>
                  <Table.Cell onClick={() => sortBy('display_gender')}>
                    Gender
                  </Table.Cell>
                  <Table.Cell onClick={() => sortBy('erp_status')}>
                    ERP
                  </Table.Cell>
                  <Table.Cell>Vore</Table.Cell>
                  <Table.Cell>Hypno</Table.Cell>
                  <Table.Cell>Noncon</Table.Cell>
                  <Table.Cell>Advert</Table.Cell>
                </Table.Row>
                {sorted.map((entry) => (
                  <Table.Row
                    key={entry.ref}
                    style={{
                      backgroundColor: erpTagColor[entry.erp_status],
                    }}
                  >
                    <Table.Cell>{entry.name}</Table.Cell>
                    <Table.Cell>{entry.species}</Table.Cell>
                    <Table.Cell>{entry.attraction}</Table.Cell>
                    <Table.Cell>{entry.display_gender}</Table.Cell>
                    <Table.Cell>{entry.erp_status}</Table.Cell>
                    <Table.Cell>{entry.erp_status_v}</Table.Cell>
                    <Table.Cell>{entry.erp_status_hypno}</Table.Cell>
                    <Table.Cell>{entry.erp_status_nc}</Table.Cell>
                    <Table.Cell>
                      <Button
                        icon="sticky-note"
                        onClick={() => act('view', { ref: entry.ref })}
                      >
                        View
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
