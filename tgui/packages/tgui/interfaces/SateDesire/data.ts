export type SexActionEntry = {
  path: string;
  name: string;
  active: boolean;
};

export type SateDesireData = {
  arousal: number;
  max_arousal: number;
  charge: number;
  max_charge: number;
  speed: number;
  force: number;
  manual_arousal: number;
  do_until_finished: boolean;
  bottom_exposed: boolean;
  hide_genital_visuals: boolean;
  freeuse: boolean;
  do_subtle_action: boolean;
  action_category: number;
  target_name: string | null;
  self_targeted: boolean;
  current_action: string | null;
  can_use_penis: boolean;
  can_use_vagina: boolean;
  can_knot_partners: boolean;
  do_knot_action: boolean;
  knotted: boolean;
  knot_partner_name: string | null;
  actions: SexActionEntry[];
};
