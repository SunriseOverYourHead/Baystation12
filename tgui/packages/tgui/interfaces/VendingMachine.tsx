import { Box, Button, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Product = {
  key: number;
  name: string;
  price: number;
  color: string;
  amount: number;
};

type Data = {
  mode: BooleanLike;
  product?: string;
  price?: number;
  message?: string;
  message_err?: BooleanLike;
  products?: Product[];
  coin?: string;
  panel?: BooleanLike;
  speaker?: BooleanLike;
};

export const VendingMachine = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    mode,
    product,
    price,
    message,
    message_err,
    products,
    coin,
    panel,
    speaker,
  } = data;

  return (
    <Window width={440} height={600}>
      <Window.Content scrollable>
        {!!coin && (
          <Section title="Coin Inserted">
            <Stack align="center">
              <Stack.Item grow>{coin}</Stack.Item>
              <Stack.Item>
                <Button
                  icon="eject"
                  content="Remove Coin"
                  onClick={() => act('remove_coin')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        )}
        {!!panel && (
          <Section title="Maintenance">
            <Button
              icon={speaker ? 'volume-up' : 'volume-mute'}
              content={speaker ? 'Speaker: On' : 'Speaker: Off'}
              selected={!!speaker}
              onClick={() => act('togglevoice')}
            />
          </Section>
        )}
        {mode ? (
          <Section title="Purchase">
            <Box mb={1}>
              <strong>Item:</strong> {product}
            </Box>
            <Box mb={1}>
              <strong>Price:</strong>{' '}
              {price !== undefined && price > 0 ? `${price} cr` : 'Free'}
            </Box>
            {!!message && (
              <Box color={message_err ? 'bad' : 'average'} mb={1}>
                {message}
              </Box>
            )}
            <Button
              icon="times"
              content="Cancel"
              color="bad"
              onClick={() => act('cancelpurchase')}
            />
          </Section>
        ) : (
          <Section title="Products">
            {!products || products.length === 0 ? (
              <Box color="average">No products available.</Box>
            ) : (
              <Table>
                <Table.Row header>
                  <Table.Cell>Item</Table.Cell>
                  <Table.Cell>Price</Table.Cell>
                  <Table.Cell>Stock</Table.Cell>
                  <Table.Cell />
                </Table.Row>
                {products.map((p) => (
                  <Table.Row key={p.key}>
                    <Table.Cell>
                      <Box color={p.color || 'default'}>{p.name}</Box>
                    </Table.Cell>
                    <Table.Cell>
                      {p.price > 0 ? `${p.price} cr` : 'Free'}
                    </Table.Cell>
                    <Table.Cell>{p.amount}</Table.Cell>
                    <Table.Cell>
                      <Button
                        icon="shopping-cart"
                        content="Vend"
                        disabled={p.amount === 0}
                        onClick={() => act('vend', { vend: p.key })}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
