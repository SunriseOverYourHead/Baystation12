import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type MaterialEntry = {
  material: string;
  rawamount: number;
  amount: number;
  harvest: BooleanLike;
};

type Data = {
  id: string;
  status: BooleanLike;
  materials: MaterialEntry[];
};

export const KineticHarvester = (props) => {
  const { act, data } = useBackend<Data>();
  const { id, status, materials } = data;

  return (
    <Window title="Kinetic Harvester" width={400} height={600}>
      <Window.Content>
        <Section
          title={`Fusion Plant: ${id}`}
          buttons={
            <Button
              icon={status ? 'power-off' : 'times'}
              color={status ? 'good' : 'bad'}
              onClick={() => act('toggle_power')}
            >
              {status ? 'Online' : 'Offline'}
            </Button>
          }
        >
          {materials.length === 0 ? (
            <Box color="label">No materials available.</Box>
          ) : (
            <LabeledList>
              {materials.map((mat) => (
                <LabeledList.Item
                  key={mat.material}
                  label={`${mat.material} x${mat.rawamount} (${mat.amount} sheet${mat.amount !== 1 ? 's' : ''})`}
                >
                  <Button
                    icon={mat.harvest ? 'check' : 'times'}
                    color={mat.harvest ? 'good' : 'bad'}
                    onClick={() =>
                      act('toggle_harvest', { toggle_harvest: mat.material })
                    }
                  >
                    {mat.harvest ? 'Collecting' : 'Not Collecting'}
                  </Button>
                  {mat.amount > 0 && (
                    <Button
                      icon="eject"
                      onClick={() =>
                        act('remove_mat', { remove_mat: mat.material })
                      }
                    >
                      Remove Sheets
                    </Button>
                  )}
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
