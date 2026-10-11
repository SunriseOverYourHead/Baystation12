import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessConfig, type Region } from './common/AccessConfig';

type Data = {
  storedMatter: number;
  maxStoredMatter: number;
  deconstructMode: BooleanLike;
  rootCategories: string[];
  selectedRoot: string;
  categories: Category[];
  selectedCategory: string;
  selectedDesign: string;
  accesses: string[];
  oneAccess: BooleanLike;
  regions: Region[];
};

type Category = {
  catName: string;
  designs: Design[];
};

type Design = {
  title: string;
  // Full CSS class string (size class + sprite class), from the dynamically-generated
  // /datum/asset/spritesheet/rcd (code/game/objects/items/weapons/RCD.dm) - null if no icon resolved.
  icon: string | null;
};

// Trivial stubs kept only so RapidPlumbingDevice.tsx/RapidTilingDevice.tsx (leftover frontend-only files from
// an earlier bulk tgui import that were never given a DM backend) still resolve their imports of these names.
// They are otherwise unrelated to this RCD - remove once those devices get their own backend/UI.
export const MatterItem = (props) => {
  const { data } = useBackend<Data>();
  const { storedMatter, maxStoredMatter } = data;
  return (
    <LabeledList.Item label="Units Left">
      &nbsp;{storedMatter}/{maxStoredMatter} Units
    </LabeledList.Item>
  );
};

export const SiloItem = (props) => {
  return (
    <LabeledList.Item label="Silo Link">
      <Button content="Silo Offline" color="transparent" disabled />
    </LabeledList.Item>
  );
};

export const InfoSection = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    storedMatter,
    maxStoredMatter,
    deconstructMode,
    rootCategories = [],
    selectedRoot,
  } = data;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Matter Stored">
          <ProgressBar
            value={storedMatter}
            minValue={0}
            maxValue={maxStoredMatter}
          >
            {storedMatter} / {maxStoredMatter} units
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Mode">
          <Button
            icon={deconstructMode ? 'hammer' : 'trowel'}
            color={deconstructMode ? 'bad' : 'good'}
            onClick={() => act('toggle_deconstruct')}
          >
            {deconstructMode ? 'Deconstruct' : 'Construct'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Category">
          {rootCategories.map((root) => (
            <Button
              key={root}
              content={root}
              selected={selectedRoot === root}
              color="transparent"
              onClick={() => act('root_category', { root_category: root })}
            />
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

// Loads the RCD's dynamically-generated design-icon spritesheet CSS once - mirrors the raw
// <script>Byond.loadCss('tgui.bundle.css', true)</script> tag tgui_window.dm injects for the base tgui bundle
// at window-creation time (code/modules/tgui/tgui_window.dm) - there's no per-UI equivalent of that injection
// point, so this replicates it from the interface itself instead. The PNG/CSS asset pair was already sent to
// the client via ui_assets() before this window opened (code/modules/tgui/tgui.dm), so the named file is already
// in the client's local resource cache by the time this runs.
function useSpritesheetCss(filename: string) {
  useEffect(() => {
    // biome-ignore lint/suspicious/noExplicitAny: Byond is a BYOND-injected global, not a bundled module.
    (globalThis as any).Byond?.loadCss(filename, true);
  }, [filename]);
}

const DesignSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], selectedCategory, selectedDesign } = data;
  const [categoryName, setCategoryName] = useState(selectedCategory);
  useSpritesheetCss('spritesheet_rcd-tgui.css');
  const shownCategory =
    categories.find((category) => category.catName === categoryName) ||
    categories[0];

  if (!shownCategory) {
    return (
      <Section fill>
        <Box color="label">No designs available in this category.</Box>
      </Section>
    );
  }

  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            key={category.catName}
            selected={category.catName === shownCategory.catName}
            onClick={() => setCategoryName(category.catName)}
          >
            {category.catName}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory.designs.map((design, i) => (
        <Button
          key={i + 1}
          fluid
          height="28px"
          color="transparent"
          selected={
            design.title === selectedDesign &&
            shownCategory.catName === selectedCategory
          }
          onClick={() =>
            act('design', {
              category: shownCategory.catName,
              index: i + 1,
            })
          }
        >
          {!!design.icon && (
            <Box
              inline
              verticalAlign="middle"
              mr="6px"
              className={design.icon}
            />
          )}
          <span>{design.title}</span>
        </Button>
      ))}
    </Section>
  );
};

const AccessSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { accesses = [], oneAccess, regions = [] } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Access Required">
              <Button
                icon={oneAccess ? 'unlock' : 'lock'}
                onClick={() => act('one_access')}
              >
                {oneAccess ? 'Any One' : 'All'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <AccessConfig
          accesses={regions}
          selectedList={accesses}
          accessMod={(ref) => act('set', { access: ref })}
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={(ref) => act('grant_region', { region: ref })}
          denyDep={(ref) => act('deny_region', { region: ref })}
        />
      </Stack.Item>
    </Stack>
  );
};

const ConfigureSection = (props) => {
  const { data } = useBackend<Data>();
  const { selectedRoot } = data;

  return (
    <Stack.Item grow>
      {selectedRoot === 'Airlock Access' ? <AccessSection /> : <DesignSection />}
    </Stack.Item>
  );
};

export const RapidConstructionDevice = (props) => {
  return (
    <Window width={450} height={590}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <InfoSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <ConfigureSection />
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
