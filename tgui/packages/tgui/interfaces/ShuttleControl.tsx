import {
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  shuttle_tag: string;
  shuttle_status: string;
  shuttle_state: 'idle' | 'warmup' | 'in_transit';
  has_docking: BooleanLike;
  docking_status: string | null;
  docking_override: BooleanLike | null;
  can_launch: BooleanLike;
  can_cancel: BooleanLike;
  can_force: BooleanLike;
  timeleft: number;
  docking_codes: string;
  // explore console fields (optional)
  destination_name?: string;
  can_pick?: BooleanLike;
  fuel_usage?: number;
  remaining_fuel?: number;
  fuel_span?: string;
};

const STATE_COLORS: Record<string, string> = {
  idle: 'good',
  warmup: 'average',
  in_transit: 'yellow',
};

const STATE_LABELS: Record<string, string> = {
  idle: 'Idle',
  warmup: 'Warming Up',
  in_transit: 'In Transit',
};

export function ShuttleControl(props) {
  const { act, data } = useBackend<Data>();
  const {
    shuttle_tag,
    shuttle_status,
    shuttle_state,
    has_docking,
    docking_status,
    docking_override,
    can_launch,
    can_cancel,
    can_force,
    timeleft,
    docking_codes,
    destination_name,
    can_pick,
    fuel_usage,
    remaining_fuel,
    fuel_span,
  } = data;

  return (
    <Window title={`${shuttle_tag} Shuttle Control`} width={470} height={360}>
      <Window.Content>
        <Section title="Shuttle Status">
          <LabeledList>
            <LabeledList.Item label="Status">{shuttle_status}</LabeledList.Item>
            <LabeledList.Item label="State">
              <Box color={STATE_COLORS[shuttle_state] ?? 'label'}>
                {STATE_LABELS[shuttle_state] ?? shuttle_state}
              </Box>
            </LabeledList.Item>
            {timeleft > 0 && (
              <LabeledList.Item label="ETA">{timeleft}s</LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        {!!has_docking && (
          <Section title="Docking">
            <LabeledList>
              <LabeledList.Item label="Status">
                {docking_status ?? 'Unknown'}
              </LabeledList.Item>
              <LabeledList.Item label="Override">
                {docking_override ? 'Yes' : 'No'}
              </LabeledList.Item>
              <LabeledList.Item label="Codes">
                <Box inline>{docking_codes || '—'}</Box>
                <Button ml={1} icon="pencil-alt" onClick={() => act('set_codes')}>
                  Change
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}

        {destination_name !== undefined && (
          <Section title="Navigation">
            <LabeledList>
              <LabeledList.Item label="Destination">
                {destination_name}
              </LabeledList.Item>
              {fuel_usage !== undefined && (
                <>
                  <LabeledList.Item label="Fuel remaining">
                    <Box inline color={fuel_span}>
                      {remaining_fuel} m/s
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Fuel per trip">
                    {fuel_usage} m/s
                  </LabeledList.Item>
                </>
              )}
            </LabeledList>
            <Button
              mt={1}
              icon="map-marker-alt"
              disabled={!can_pick}
              onClick={() => act('pick')}
            >
              Choose Destination
            </Button>
          </Section>
        )}

        <Section title="Controls">
          <Button
            color="good"
            icon="rocket"
            disabled={!can_launch}
            onClick={() => act('move')}
          >
            Launch
          </Button>
          <Button
            color="average"
            icon="forward"
            disabled={!can_force}
            onClick={() => act('force')}
          >
            Force Launch
          </Button>
          <Button
            color="bad"
            icon="times-circle"
            disabled={!can_cancel}
            onClick={() => act('cancel')}
          >
            Cancel
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
}
