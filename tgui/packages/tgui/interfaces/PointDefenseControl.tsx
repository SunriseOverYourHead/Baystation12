import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Turret = {
  id: string;
  ref: string;
  active: BooleanLike;
  effective_range: string;
  reaction_wheel_delay: string;
  recharge_time: string;
};

type Data = {
  id: string;
  name: string;
  turrets: Turret[];
};

export const PointDefenseControl = () => {
  const { act, data } = useBackend<Data>();
  const { id, name, turrets = [] } = data;

  return (
    <Window title={name || 'Fire Assist Mainframe'} width={400} height={600}>
      <Window.Content scrollable>
        <Section title="Network">
          <LabeledList>
            <LabeledList.Item label="Network ID">{id}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Point Defense Batteries">
          {turrets.length === 0 ? (
            <NoticeBox>No batteries linked to network.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Unit</Table.Cell>
                <Table.Cell>Range</Table.Cell>
                <Table.Cell>Delay</Table.Cell>
                <Table.Cell>Recharge</Table.Cell>
                <Table.Cell>Status</Table.Cell>
              </Table.Row>
              {turrets.map((turret) => (
                <Table.Row key={turret.ref} className="candystripe">
                  <Table.Cell bold>{turret.id}</Table.Cell>
                  <Table.Cell>{turret.effective_range}</Table.Cell>
                  <Table.Cell>{turret.reaction_wheel_delay}</Table.Cell>
                  <Table.Cell>{turret.recharge_time}</Table.Cell>
                  <Table.Cell>
                    <Button
                      icon="power-off"
                      selected={!!turret.active}
                      color={turret.active ? 'good' : undefined}
                      onClick={() =>
                        act('toggle_active', { ref: turret.ref })
                      }
                    >
                      {turret.active ? 'Online' : 'Offline'}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
