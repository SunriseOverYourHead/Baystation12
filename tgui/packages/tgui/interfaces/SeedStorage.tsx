import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Seed = {
  id: number;
  name: string;
  variety: string;
  amount: number;
  traits: Record<string, string | number>;
  binary_traits: string[];
};

type Data = {
  seeds: Seed[];
  scanner: string[];
};

const TRAIT_LABELS: Record<string, string> = {
  endurance: 'Endurance',
  yield: 'Yield',
  maturation: 'Maturation',
  production: 'Production',
  potency: 'Potency',
  harvest: 'Harvest Type',
  ideal_heat: 'Ideal Heat (K)',
  ideal_light: 'Ideal Light',
  nutrient_consumption: 'Nutrients',
  water_consumption: 'Water',
};

export function SeedStorage(props) {
  const { act, data } = useBackend<Data>();
  const { seeds = [], scanner = [] } = data;
  const [search, setSearch] = useState('');

  const filtered = seeds.filter((s) =>
    s.name.toLowerCase().includes(search.toLowerCase()),
  );

  return (
    <Window title="Seed Storage" width={520} height={600}>
      <Window.Content scrollable>
        <Section>
          <Input
            fluid
            placeholder="Search seeds..."
            value={search}
            onChange={setSearch}
          />
        </Section>
        {filtered.length === 0 ? (
          <NoticeBox>No seeds found.</NoticeBox>
        ) : (
          filtered.map((seed) => (
            <Collapsible
              key={seed.id}
              title={
                <Stack>
                  <Stack.Item grow>{seed.name}</Stack.Item>
                  <Stack.Item>
                    <Box inline color="label" mr={1}>
                      x{seed.amount}
                    </Box>
                  </Stack.Item>
                </Stack>
              }
              buttons={
                <>
                  <Button
                    icon="leaf"
                    disabled={seed.amount === 0}
                    onClick={() => act('vend', { id: seed.id })}
                  >
                    Take
                  </Button>
                  <Button.Confirm
                    icon="trash"
                    color="bad"
                    onClick={() => act('purge', { id: seed.id })}
                  >
                    Purge
                  </Button.Confirm>
                </>
              }
            >
              <Box pl={2}>
                {scanner.length > 0 &&
                  Object.keys(seed.traits).length > 0 && (
                    <LabeledList>
                      {Object.entries(seed.traits).map(([key, val]) => (
                        <LabeledList.Item
                          key={key}
                          label={TRAIT_LABELS[key] ?? key.replace(/_/g, ' ')}
                        >
                          {val}
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  )}
                {seed.binary_traits?.length > 0 && (
                  <Box mt={1}>
                    {seed.binary_traits.map((trait) => (
                      <Box key={trait} inline mr={1} color="label">
                        {trait}
                      </Box>
                    ))}
                  </Box>
                )}
              </Box>
            </Collapsible>
          ))
        )}
      </Window.Content>
    </Window>
  );
}
