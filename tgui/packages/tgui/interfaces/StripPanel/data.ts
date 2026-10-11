export type StripSlot = {
  name: string;
  slot: string;
  item_name: string | null;
  holder_ref: string | null;
  accessories: string[];
};

export type StripHand = {
  name: string;
  slot: string;
  item_name: string | null;
};

export type StripUnderwear = {
  name: string;
  ref: string;
};

export type StripPanelData = {
  target_name: string;
  can_act: boolean;
  slots: StripSlot[];
  has_pockets: boolean;
  hands?: StripHand[];
  can_internals: boolean;
  has_internals_tank: boolean;
  internals_active: boolean;
  has_uniform: boolean;
  has_sensor?: number;
  sensor_locked?: boolean;
  can_lock_sensors?: boolean;
  handcuffed: boolean;
  handcuffed_slot: string;
  webbed: boolean;
  underwear: StripUnderwear[];
};
