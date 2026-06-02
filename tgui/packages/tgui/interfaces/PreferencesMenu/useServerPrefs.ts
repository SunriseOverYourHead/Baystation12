import { createContext, useContext } from 'react';

import type { ServerData } from './types';

export const ServerPrefs = createContext<ServerData | undefined>({
  jobs: {
    departments: {},
    jobs: {},
  },
  names: {
    types: {},
  },
  quirks: {
    max_positive_quirks: -1,
    quirk_info: {},
    quirk_blacklist: [],
    points_enabled: false,
  },
  personality: {
    personalities: [],
    personality_incompatibilities: {},
  },
  random: {
    randomizable: [],
  },
  loadout: {
    loadout_tabs: [],
  },
  species: {},
  spawnpoints: [], // BS12
  mil_branches: {}, // BS12
  rank_shorts: {}, // BS12
  uplink_source_options: [], // BS12
  available_maps: [], // BS12
  lawsets: [], // BS12
  backpack_options: { choices: [], icons: {} }, // BS12
  underwear_options: {}, // BS12
  cultural_options: {}, // BS12
  cultural_tag_labels: {}, // BS12
  uniform_options: {}, // BS12
  skill_tree: [], // BS12
});

export function useServerPrefs() {
  return useContext(ServerPrefs);
}
