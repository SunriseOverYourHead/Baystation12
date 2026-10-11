import type { BooleanLike } from 'tgui-core/react';

import type { sendAct } from '../../events/act';
import type {
  LoadoutCategory,
  LoadoutList,
  typePath,
} from './CharacterPreferences/loadout/base';
import type { Gender } from './preferences/gender';

export enum Food {
  Alcohol = 'ALCOHOL',
  Breakfast = 'BREAKFAST',
  Bugs = 'BUGS',
  Cloth = 'CLOTH',
  Dairy = 'DAIRY',
  Fried = 'FRIED',
  Fruit = 'FRUIT',
  Gore = 'GORE',
  Grain = 'GRAIN',
  Gross = 'GROSS',
  Junkfood = 'JUNKFOOD',
  Meat = 'MEAT',
  Nuts = 'NUTS',
  Oranges = 'ORANGES',
  Pineapple = 'PINEAPPLE',
  Raw = 'RAW',
  Seafood = 'SEAFOOD',
  Stone = 'STONE',
  Sugar = 'SUGAR',
  Toxic = 'TOXIC',
  Vegetables = 'VEGETABLES',
  Bloody = 'BLOODY', // NOVA EDIT ADDITION - Hemophage Food
}

export enum JobPriority {
  Low = 1,
  Medium = 2,
  High = 3,
}

export type Name = {
  can_randomize: BooleanLike;
  explanation: string;
  group: string;
  prefixes?: string[]; // NOVA EDIT ADDITION - Drone Prefixes
};

export type Species = {
  name: string;
  desc: string;
  lore: string[];
  icon: string;

  use_skintones: BooleanLike;
  sexes: BooleanLike;

  enabled_features: string[];

  nova_stars_only: boolean; // NOVA EDIT - Nova star quirks

  perks: {
    positive: Perk[];
    negative: Perk[];
    neutral: Perk[];
  };

  diet?: {
    liked_food: Food[];
    disliked_food: Food[];
    toxic_food: Food[];
  };
};

export type Perk = {
  ui_icon: string;
  name: string;
  description: string;
};

export type Department = {
  head?: string;
};

export type Job = {
  description: string;
  department: string;
  // NOVA EDIT
  nova_star?: boolean;
  alt_titles?: string[];
  // NOVA EDIT END
  // BS12: branch name → available rank names (empty array = branch has no rank system)
  branch_rank?: Record<string, string[]>;
  // BS12: which map(s) this job appears on (empty = available everywhere)
  maps?: string[];
};

export type Quirk = {
  description: string;
  icon: string;
  name: string;
  value: number;
  customizable: boolean;
  customization_options?: string[];
  nova_stars_only: boolean; // NOVA EDIT ADDITION - Nova star quirks
  erp_quirk: boolean; // NOVA EDIT ADDITION - Purple ERP quirks
};

// NOVA EDIT START
export type Language = {
  description: string;
  name: string;
  /** RSC name of the language's flag badge, or null where none has been drawn. */
  icon: string | null;
  speaking: boolean;
  /** Non-null for regional variants of one tongue; variants sharing a group collapse into a single UI entry. */
  group: string | null;
  /** The variant's short label within its group ("Britain"), falling back to `name` when ungrouped. */
  variant_name: string;
  shorthand: string;
  /** LANGUAGE_LEVEL_* — 0 when merely offered, 1 (A1) through 6 (C2) when known. */
  level: number;
  level_name: string;
  /** Granted by the character's culture: always native, never counted against the slot limit, not editable. */
  native: boolean;
  warning: string;
};

export type LanguageLevel = {
  value: number;
  name: string;
  description: string;
};

export type Marking = {
  name: string;
  color: string;
  marking_id: string;
};

export type MarkingData = {
  marking_choices: string[];
  markings_list: Marking[];
};

export type Limb = {
  slot: string;
  name: string;
  can_augment: boolean;
  chosen_aug: string;
  chosen_style: string;
  aug_choices: Record<string, string>;
  costs: Record<string, number>;
  markings: MarkingData;
};

export type Organ = {
  slot: string;
  name: string;
  chosen_organ: string;
  organ_choices: Record<string, string>;
  costs: Record<string, number>;
};

// NOVA EDIT END
export type QuirkInfo = {
  max_positive_quirks: number;
  quirk_info: Record<string, Quirk>;
  quirk_blacklist: string[][];
  points_enabled: boolean;
};

export type Personality = {
  name: string;
  description: string;
  pos_gameplay_description: string | null;
  neg_gameplay_description: string | null;
  neut_gameplay_description: string | null;
  path: typePath;
  groups: string[] | null;
};

export enum RandomSetting {
  AntagOnly = 1,
  Disabled = 2,
  Enabled = 3,
}

export enum JoblessRole {
  BeOverflow = 1,
  BeRandomJob = 2,
  ReturnToLobby = 3,
}

export enum GamePreferencesSelectedPage {
  Settings,
  Keybindings,
}

export const createSetPreference =
  (act: typeof sendAct, preference: string) => (value: unknown) => {
    act('set_preference', {
      preference,
      value,
    });
  };

export enum PrefsWindow {
  Character = 0,
  Game = 1,
  Keybindings = 2,
}

export type PreferencesMenuData = {
  character_preview_view: string;
  character_profiles: (string | null)[];

  is_nova_star: BooleanLike; // NOVA EDIT - Star status
  erp_pref: BooleanLike; // NOVA EDIT ADDITION

  character_preferences: {
    clothing: Record<string, string>;
    features: Record<string, string>;
    game_preferences: Record<string, unknown>;
    non_contextual: {
      random_body: RandomSetting;
      [otherKey: string]: unknown;
    };
    secondary_features: Record<string, unknown>;
    supplemental_features: Record<string, unknown>;
    manually_rendered_features: Record<string, string>;

    names: Record<string, string>;
    vocals: Record<string, string>; // NOVA EDIT ADDITION

    misc: {
      gender: Gender;
      joblessrole: JoblessRole;
      species: string;
      loadout_lists: LoadoutList; // NOVA EDIT CHANGE - Multiple loadout presets - ORIGINAL: loadout_list: LoadoutList;
      job_clothes: BooleanLike;
      loadout_index: string; // NOVA EDIT ADDITION: Multiple loadout presets
      spawnpoint: string; // BS12
      preview_mode: 'Naked' | 'Naked (Aroused)' | 'Underwear' | 'Loadout' | 'Job'; // BS12
      master_erp_preferences: BooleanLike; // BS12
      allow_noncanon_bodyparts: BooleanLike; // BS12
    };

    // BS12 additions
    robot_flavor_texts: Record<string, string>;
    robot_module_names: string[];
    records: {
      public_record: string;
      med_record: string;
      sec_record: string;
      gen_record: string;
      memory: string;
      email_addr: string;
      email_pass: string;
    };
    identity_media: {
      headshot_url: string;
      headshot_nsfw_url: string;
      art_reference_url: string;
      art_ref_nsfw: BooleanLike;
      headshot_ai_generated: BooleanLike;
      headshot_nsfw_ai_generated: BooleanLike;
      art_reference_ai_generated: BooleanLike;
      view_ai_generated_headshots: BooleanLike;
    };
    erp_directory: {
      show_in_directory: BooleanLike;
      ooc_notes: string;
      attraction: string;
      display_gender: string;
      emote_length: string;
      approach_pref: string;
      furry_pref: string;
      scalie_pref: string;
      other_pref: string;
      demihuman_pref: string;
      human_pref: string;
      character_ad: string;
      erp_status: string;
      erp_status_nc: string;
      erp_status_v: string;
      erp_status_hypno: string;
      erp_free_use: BooleanLike;
      can_knot_partners: BooleanLike;
      mechanical_erp: BooleanLike;
      custom_species: string;
      custom_species_lore: string;
      character_flavor_text: string;
      flavor_text_nsfw: string;
      show_nsfw_flavor_text: string;
      erp_unlocked: BooleanLike;
      choices: {
        attraction: string[];
        display_gender: string[];
        emote_length: string[];
        approach_pref: string[];
        directory_character: string[];
        erp_status: string[];
        erp_status_nc: string[];
        erp_status_v: string[];
        erp_status_hypno: string[];
        show_nsfw_flavor_text: string[];
      };
    };

    randomization: Record<string, RandomSetting>;
  };

  content_unlocked: BooleanLike;

  // BS12: branch/rank system
  map_has_branch: BooleanLike;
  job_branches: Record<string, string>;
  job_ranks: Record<string, string>;

  // BS12: antag setup
  exploit_record: string;
  uplink_sources: string[];
  uplink_source_options?: string[];

  // BS12: map hiding
  hiding_maps: Record<string, boolean>;

  // BS12: cultural info
  cultural_info: Record<string, string>;

  // BS12: AI laws
  laws: string[];
  is_shackled: BooleanLike;
  has_posibrain: BooleanLike;

  // BS12: equipment
  backpack: string;
  sensor_setting: number;
  underwear: Record<string, string>;
  sidebar_icons: {
    hair?: string;
    facial_hair?: string;
    backpack?: string;
    underwear: Record<string, string>;
  };
  uniforms_by_job: Record<string, string[]>;
  skill_jobs: Record<
    string,
    {
      points_remaining: number;
      skills: Record<string, { min: number; max: number; current: number }>;
    }
  >;

  job_bans?: string[];
  job_days_left?: Record<string, number>;
  job_required_experience?: Record<
    string,
    {
      experience_type: string;
      required_playtime: number;
    }
  >;
  job_preferences: Record<string, JobPriority>;

  // NOVA EDIT
  job_alt_titles: Record<string, string>;

  robotic_styles: string[];
  limbs_data: Limb[];
  organs_data: Organ[];
  marking_presets: string[];

  selected_languages: Language[];
  unselected_languages: Language[];
  native_languages: Language[];
  language_levels: LanguageLevel[];
  total_language_points: number;
  quirk_points_enabled: number;
  quirks_balance: number;
  positive_quirk_count: number;
  species_restricted_jobs?: string[];
  ckey: string;
  is_donator: BooleanLike;
  // NOVA EDIT END
  keybindings: Record<string, string[]>;
  overflow_role: string;
  default_quirk_balance: number;
  selected_quirks: string[];
  selected_personalities: typePath[] | null;
  max_personalities: number;
  mood_enabled: BooleanLike;
  species_disallowed_quirks: string[];

  antag_bans?: string[];
  antag_days_left?: Record<string, number>;
  selected_antags: string[];

  active_slot: number;
  name_to_use: string;

  // BS12: static feature/job/species data sent inline instead of preferences.json
  server_data?: ServerData;

  window: PrefsWindow;
};

export type ServerData = {
  jobs: {
    departments: Record<string, Department>;
    jobs: Record<string, Job>;
  };
  names: {
    types: Record<string, Name>;
  };
  quirks: QuirkInfo;
  personality: {
    personalities: Personality[];
    personality_incompatibilities: Record<string, string[]>;
  };
  random: {
    randomizable: string[];
  };
  loadout: {
    loadout_tabs: LoadoutCategory[];
  };
  species: Record<string, Species>;
  spawnpoints: string[]; // BS12
  mil_branches: Record<string, string>; // BS12: branch name → name_short
  rank_shorts: Record<string, string>; // BS12: rank name → abbreviation
  uplink_source_options: string[]; // BS12: available uplink source names
  available_maps: string[]; // BS12: job map names for hiding_maps UI
  lawsets: { name: string; laws: string[] }[]; // BS12: available shackling lawsets
  backpack_options: { choices: string[]; icons: Record<string, string> }; // BS12: backpack catalog
  underwear_options: Record<string, { choices: string[]; icons: Record<string, string> }>; // BS12: category → catalog
  cultural_options: Record<string, string[]>; // BS12: tag → valid values (species-specific)
  cultural_tag_labels: Record<string, string>; // BS12: tag key → display label
  uniform_options: Record<string, Record<string, { ref: string; name: string }[]>>; // BS12: job → category → pieces
  skill_tree: SkillCategory[]; // BS12: static skill hierarchy
  [otherKey: string]: unknown;
};

export type SkillLevel = {
  name: string;
  cost: number;
};

export type SkillEntry = {
  id: string;
  type: string;
  name: string;
  desc: string;
  levels: SkillLevel[];
  prerequisites: Record<string, number>;
  children: SkillEntry[];
};

export type SkillCategory = {
  id: string;
  name: string;
  skills: SkillEntry[];
};
