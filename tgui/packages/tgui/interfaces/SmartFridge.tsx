import { Box, Button, NumberInput, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FridgeItem = {
  display_name: string;
  vend: number;
  quantity: number;
};

type Data = {
  contents: FridgeItem[] | null;
  electrified: BooleanLike;
  shoot_inventory: BooleanLike;
  locked: number;
  secure: BooleanLike;
};

export const SmartFridge = (props) => {
  const { act, data } = useBackend<Data>();
  const { contents, electrified, shoot_inventory, locked, secure } = data;

  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        {!!electrified && (
          <Box color="bad" mb={1}>
            Warning: Machine is electrified!
          </Box>
        )}
        {!!shoot_inventory && (
          <Box color="bad" mb={1}>
            Warning: Shoot inventory mode active!
          </Box>
        )}
        {secure && (
          <Box color="average" mb={1}>
            {locked === -1
              ? 'Security bypassed.'
              : locked
                ? 'Locked — Access required.'
                : 'Unlocked.'}
          </Box>
        )}
        <Section title="Contents">
          {!contents || contents.length === 0 ? (
            <Box color="average">Empty.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell>Qty</Table.Cell>
                <Table.Cell />
              </Table.Row>
              {contents.map((item) => (
                <Table.Row key={item.vend}>
                  <Table.Cell>{item.display_name}</Table.Cell>
                  <Table.Cell>{item.quantity}</Table.Cell>
                  <Table.Cell>
                    <Stack>
                      <Stack.Item>
                        <Button
                          icon="hand-paper"
                          content="Take 1"
                          onClick={() =>
                            act('vend', { vend: item.vend, amount: 1 })
                          }
                        />
                      </Stack.Item>
                      {item.quantity > 1 && (
                        <Stack.Item>
                          <Button
                            icon="hand-rock"
                            content={`Take All (${item.quantity})`}
                            onClick={() =>
                              act('vend', {
                                vend: item.vend,
                                amount: item.quantity,
                              })
                            }
                          />
                        </Stack.Item>
                      )}
                    </Stack>
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
