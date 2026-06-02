import { Box, Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Floor = {
  index: number;
  label: string;
  name: string;
  queued: BooleanLike;
  current: BooleanLike;
};

type Data = {
  floors: Floor[];
  doors_open: BooleanLike;
};

export function TurboliftPanel(props) {
  const { act, data } = useBackend<Data>();
  const { floors, doors_open } = data;

  return (
    <Window title="Lift Panel" width={240} height={300}>
      <Window.Content scrollable>
        <Section title="Floors">
          {floors.map((floor) => (
            <Box key={floor.index} mb={0.5}>
              <Button
                fluid
                color={
                  floor.current ? 'good' : floor.queued ? 'average' : undefined
                }
                onClick={() => act('move_to_floor', { index: floor.index })}
              >
                <Box bold={!!floor.current}>{floor.label}</Box>
                <Box color={floor.current || floor.queued ? undefined : 'label'} fontSize="0.85em">
                  {floor.name}
                </Box>
              </Button>
            </Box>
          ))}
        </Section>
        <Section>
          {doors_open ? (
            <Button fluid icon="door-open" onClick={() => act('close_doors')}>
              Close Doors
            </Button>
          ) : (
            <Button fluid icon="door-closed" onClick={() => act('open_doors')}>
              Open Doors
            </Button>
          )}
          <Button
            fluid
            mt={0.5}
            icon="hand-paper"
            color="bad"
            onClick={() => act('emergency_stop')}
          >
            Emergency Stop
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
}
