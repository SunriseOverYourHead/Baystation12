import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { CharacterPreview } from '../../common/CharacterPreview';
import { LoadingScreen } from '../../common/LoadingScreen';
import {
  createSetPreference,
  Food,
  type Perk,
  type PreferencesMenuData,
  type ServerData,
  type Species,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

// Species that share a parent group and are shown in a sub-menu
const SPECIES_GROUPS: Record<string, string[]> = {
  Human: ['Human', 'Vat-Grown Human', 'Mule', 'Tritonian', 'Space-Adapted Human', 'Grav-Adapted Human'],
  Unathi: ['Unathi', "Yeosa'Unathi"],
};

const FOOD_ICONS = {
  [Food.Bugs]: 'bug',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'bacon',
  [Food.Fruit]: 'apple-alt',
  [Food.Gore]: 'skull',
  [Food.Grain]: 'bread-slice',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'hamburger',
  [Food.Nuts]: 'seedling',
  [Food.Raw]: 'drumstick-bite',
  [Food.Seafood]: 'fish',
  [Food.Stone]: 'gem',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
};

const FOOD_NAMES: Record<keyof typeof FOOD_ICONS, string> = {
  [Food.Bugs]: 'Bugs',
  [Food.Cloth]: 'Clothing',
  [Food.Dairy]: 'Dairy',
  [Food.Fried]: 'Fried food',
  [Food.Fruit]: 'Fruit',
  [Food.Gore]: 'Gore',
  [Food.Grain]: 'Grain',
  [Food.Gross]: 'Gross food',
  [Food.Junkfood]: 'Junk food',
  [Food.Meat]: 'Meat',
  [Food.Nuts]: 'Nuts',
  [Food.Raw]: 'Raw',
  [Food.Seafood]: 'Seafood',
  [Food.Stone]: 'Rocks',
  [Food.Sugar]: 'Sugar',
  [Food.Toxic]: 'Toxic food',
  [Food.Vegetables]: 'Vegetables',
};

const IGNORE_UNLESS_LIKED: Set<Food> = new Set([
  Food.Bugs,
  Food.Cloth,
  Food.Gross,
  Food.Toxic,
]);

function notIn<T>(set: Set<T>) {
  return (value: T) => {
    return !set.has(value);
  };
}

type FoodListProps = {
  food: Food[];
  icon: string;
  name: string;
  className: string;
};

function FoodList(props: Readonly<FoodListProps>) {
  const { food = [], icon, name, className } = props;

  if (food.length === 0) {
    return null;
  }

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Icon name={icon} /> <b>{name}</b>
          <Divider />
          <Box>
            {food
              .reduce((names, food) => {
                const foodName = FOOD_NAMES[food];
                return foodName ? names.concat(foodName) : names;
              }, [])
              .join(', ')}
          </Box>
        </Box>
      }
    >
      <Stack ml={2}>
        {food.map((food) => {
          return (
            FOOD_ICONS[food] && (
              <Stack.Item>
                <Icon
                  className={className}
                  size={1.4}
                  key={food}
                  name={FOOD_ICONS[food]}
                />
              </Stack.Item>
            )
          );
        })}
      </Stack>
    </Tooltip>
  );
}

type DietProps = {
  diet: Species['diet'];
};

function Diet(props: Readonly<DietProps>) {
  const { diet } = props;
  if (!diet) {
    return null;
  }

  const { liked_food, disliked_food, toxic_food } = diet;

  return (
    <Stack>
      <Stack.Item>
        <FoodList
          food={liked_food}
          icon="heart"
          name="Liked food"
          className="color-pink"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={disliked_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="thumbs-down"
          name="Disliked food"
          className="color-red"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={toxic_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="biohazard"
          name="Toxic food"
          className="color-olive"
        />
      </Stack.Item>
    </Stack>
  );
}

type SpeciesPerkProps = {
  className: string;
  perk: Perk;
};

function SpeciesPerk(props: Readonly<SpeciesPerkProps>) {
  const { className, perk } = props;

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Box as="b">{perk.name}</Box>
          <Divider />
          <Box>{perk.description}</Box>
        </Box>
      }
    >
      <Box className={className} width="32px" height="32px">
        <Icon
          name={perk.ui_icon}
          size={1.5}
          ml={0}
          mt={1}
          style={{
            textAlign: 'center',
            height: '100%',
            width: '100%',
          }}
        />
      </Box>
    </Tooltip>
  );
}

type SpeciesPerksProps = {
  perks: Species['perks'];
};

function SpeciesPerks(props: Readonly<SpeciesPerksProps>) {
  const { positive, negative, neutral } = props.perks;

  return (
    <Stack fill justify="space-between">
      <Stack.Item>
        <Stack>
          {positive.map((perk) => {
            return (
              <Stack.Item key={perk.name}>
                <SpeciesPerk className="color-bg-green" perk={perk} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Stack.Item>

      <Stack>
        {neutral.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-grey" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>

      <Stack>
        {negative.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-red" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>
    </Stack>
  );
}

type SpeciesPageInnerProps = {
  handleClose: () => void;
  species: ServerData['species'];
};

function SpeciesPageInner(props: Readonly<SpeciesPageInnerProps>) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const setSpecies = createSetPreference(act, 'species');
  const [subGroup, setSubGroup] = useState<string | null>(null);

  const species: [string, Species][] = Object.entries(props.species).map(
    ([key, sp]) => [key, sp],
  );

  // Humans are always the top of the list (BS12 uses 'Human', not 'human')
  const humanIndex = species.findIndex(([key]) => key === 'Human');
  if (humanIndex > 0) {
    const swapWith = species[0];
    species[0] = species[humanIndex];
    species[humanIndex] = swapWith;
  }

  const currentKey = data.character_preferences.misc.species;

  const currentSpecies =
    species.find(([key]) => key === currentKey)?.[1] ?? species[0]?.[1];

  if (!currentSpecies) {
    return null;
  }

  // Renders a single species button (used in both top-level and sub-group views)
  const renderSpeciesBtn = (key: string, sp: Species) => {
    let btn = (
      <Button
        key={key}
        onClick={() => {
          if (sp.nova_stars_only && !data.is_nova_star) return;
          setSpecies(key);
        }}
        selected={currentKey === key}
        tooltip={sp.name}
        style={{ display: 'block', height: '64px', width: '64px', padding: '2px' }}
      >
        {sp.icon ? (
          <img
            alt={sp.name}
            src={sp.icon}
            style={{ width: '100%', height: '100%', objectFit: 'contain' }}
          />
        ) : (
          <Box style={{ lineHeight: '56px', textAlign: 'center' }}>
            {sp.name.charAt(0)}
          </Box>
        )}
      </Button>
    );
    if (sp.nova_stars_only && !data.is_nova_star) {
      btn = (
        <Tooltip
          key={key}
          content={`${sp.name} - You need to be a Nova star to select this race, apply today!`}
        >
          {btn}
        </Tooltip>
      );
    }
    return btn;
  };

  // Left panel: sub-group view (Back button + group members)
  // or top-level view (group header buttons + standalone species)
  // Pre-compute the top-level list: one entry per group (using the first member's
  // icon as representative), plus standalone species in their original order.
  type TopEntry =
    | { kind: 'group'; name: string; repKey: string; repData: Species }
    | { kind: 'species'; key: string; data: Species };

  const topEntries: TopEntry[] = [];
  const seenGroups = new Set<string>();
  for (const [key, sp] of species) {
    const groupName = Object.keys(SPECIES_GROUPS).find((g) =>
      SPECIES_GROUPS[g].includes(key),
    );
    if (groupName) {
      if (!seenGroups.has(groupName)) {
        seenGroups.add(groupName);
        topEntries.push({ kind: 'group', name: groupName, repKey: key, repData: sp });
      }
      // subsequent members of the same group are intentionally skipped
    } else {
      topEntries.push({ kind: 'species', key, data: sp });
    }
  }

  let leftPanel: React.ReactNode;
  if (subGroup === null) {
    leftPanel = topEntries.map((entry) => {
      if (entry.kind === 'group') {
        const { name: groupName, repData: sp } = entry;
        const groupSelected = SPECIES_GROUPS[groupName].includes(currentKey);
        return (
          <Button
            key={groupName}
            onClick={() => setSubGroup(groupName)}
            selected={groupSelected}
            tooltip={`${groupName} (${SPECIES_GROUPS[groupName].length} variants) — click to expand`}
            style={{ display: 'block', height: '64px', width: '64px', padding: '2px' }}
          >
            <Box style={{ position: 'relative', width: '100%', height: '100%' }}>
              {sp.icon ? (
                <img
                  alt={groupName}
                  src={sp.icon}
                  style={{ width: '100%', height: '100%', objectFit: 'contain' }}
                />
              ) : (
                <Box style={{ lineHeight: '56px', textAlign: 'center' }}>
                  {groupName.charAt(0)}
                </Box>
              )}
              <Icon
                name="chevron-right"
                style={{
                  position: 'absolute',
                  bottom: '6px',
                  right: '1px',
                  fontSize: '11px',
                  color: 'rgba(255,255,255,0.85)',
                  textShadow: '0 0 3px rgba(0,0,0,0.9)',
                  pointerEvents: 'none',
                }}
              />
            </Box>
          </Button>
        );
      }
      return renderSpeciesBtn(entry.key, entry.data);
    });
  } else {
    const members = SPECIES_GROUPS[subGroup] ?? [];
    const subSpecies = species.filter(([key]) => members.includes(key));
    leftPanel = (
      <>
        <Button fluid icon="arrow-left" mb={1} onClick={() => setSubGroup(null)}>
          Back
        </Button>
        {subSpecies.map(([key, sp]) => renderSpeciesBtn(key, sp))}
      </>
    );
  }

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Button icon="arrow-left" onClick={props.handleClose}>
          Go Back
        </Button>
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <Box height="calc(100vh - 170px)" overflowY="auto" pr={3}>
              {leftPanel}
            </Box>
          </Stack.Item>

          <Stack.Item grow>
            <Box>
              <Box>
                <Stack fill>
                  <Stack.Item width="70%">
                    <Section
                      title={currentSpecies.name}
                      buttons={
                        currentSpecies.diet && (
                          <Diet diet={currentSpecies.diet} />
                        )
                      }
                    >
                      <Section title="Description" maxHeight="25vh" scrollable>
                        {currentSpecies.desc}
                      </Section>

                      <Section title="Features">
                        <SpeciesPerks perks={currentSpecies.perks} />
                      </Section>
                    </Section>
                  </Stack.Item>

                  <Stack.Item width="30%">
                    <CharacterPreview
                      id={data.character_preview_view}
                      height="100%"
                    />
                  </Stack.Item>
                </Stack>
              </Box>

              <Box mt={1}>
                <Section title="Lore">
                  <BlockQuote /* NOVA EDIT START - scrollable lore */
                    overflowY="auto"
                    maxHeight="45vh"
                    mr={-1} /* NOVA EDIT END */
                  >
                    {currentSpecies.lore.map((text, index) => (
                      <Box key={text} maxWidth="100%">
                        {text}
                        {index !== currentSpecies.lore.length - 1 && (
                          <>
                            <br />
                            <br />
                          </>
                        )}
                      </Box>
                    ))}
                  </BlockQuote>
                </Section>
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

type SpeciesPageProps = {
  closeSpecies: () => void;
};

export function SpeciesPage(props: Readonly<SpeciesPageProps>) {
  const serverData = useServerPrefs();
  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <SpeciesPageInner
      handleClose={props.closeSpecies}
      species={serverData.species}
    />
  );
}
