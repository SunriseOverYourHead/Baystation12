import { Button, LabeledList, NoticeBox, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type UplinkCategory = {
  name: string;
  ref: string;
};

type UplinkItem = {
  name: string;
  description: string;
  can_buy: BooleanLike;
  cost: string | number;
  ref: string;
};

type ExploitRecord = {
  Name: string;
  id: number;
  exploit: BooleanLike;
};

type ExploitField = {
  name: string;
  value: string;
};

type Data = {
  welcome: string;
  crystals: number;
  menu: number;
  discount_category: string;
  discount_name: string;
  discount_amount: number;
  offer_expiry: string;
  categories?: UplinkCategory[];
  items?: UplinkItem[];
  exploit_records?: ExploitRecord[];
  exploit?: { fields: ExploitField[] };
  exploit_exists?: BooleanLike;
};

export const Uplink = () => {
  const { act, data } = useBackend<Data>();
  const {
    welcome,
    crystals,
    menu,
    discount_category,
    discount_name,
    discount_amount,
    offer_expiry,
    categories,
    items,
    exploit_records,
    exploit,
    exploit_exists,
  } = data;

  return (
    <Window title="Remote Uplink" width={450} height={600}>
      <Window.Content scrollable>
        <Section>
          <Stack justify="space-between" align="center">
            <Stack.Item bold color="bad">
              {welcome}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="arrow-left"
                onClick={() => act('return')}
                disabled={menu === 0}
              >
                Return
              </Button>
              <Button
                icon="lock"
                color="bad"
                onClick={() => act('lock')}
              >
                Close
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section>
          <Stack wrap>
            <Stack.Item>
              <Button
                icon="shopping-cart"
                selected={menu === 0 || menu === 1}
                onClick={() => act('menu', { menu: 0 })}
              >
                Request Items
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-alt"
                selected={menu === 2 || menu === 21}
                onClick={() => act('menu', { menu: 2 })}
              >
                Exploitable Information
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        {(menu === 0 || menu === 1) && (
          <Section title="Telecrystals">
            <LabeledList>
              <LabeledList.Item label="Available">
                {crystals} TC
              </LabeledList.Item>
              {discount_amount < 100 && (
                <LabeledList.Item label="Current Discount">
                  {discount_category} - {discount_name}
                  <br />
                  {discount_amount}% off. Offer expires: {offer_expiry}
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        )}
        {menu === 0 && (
          <Section title="Categories">
            {categories && categories.map((cat) => (
              <Button
                key={cat.ref}
                fluid
                icon="chevron-right"
                onClick={() =>
                  act('menu', { menu: 1, category: cat.ref })
                }
              >
                {cat.name}
              </Button>
            ))}
          </Section>
        )}
        {menu === 1 && (
          <Section title="Request Items">
            <NoticeBox>
              Each item costs a number of tele-crystals as indicated.
            </NoticeBox>
            {items && items.map((item) => (
              <Section key={item.ref} title={`${item.name} - ${item.cost} TC`}>
                <Stack justify="space-between">
                  <Stack.Item grow color="label">
                    {item.description}
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="shopping-cart"
                      color={item.can_buy ? 'good' : undefined}
                      disabled={!item.can_buy}
                      onClick={() =>
                        act('buy_item', { buy_item: item.ref })
                      }
                    >
                      Buy
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            ))}
          </Section>
        )}
        {menu === 2 && (
          <Section title="Information Record List">
            {exploit_records && exploit_records.map((rec) => (
              <Button
                key={rec.id}
                fluid
                icon={rec.exploit ? 'exclamation-circle' : 'file'}
                color={rec.exploit ? 'bad' : undefined}
                onClick={() =>
                  act('menu', { menu: 21, id: rec.id })
                }
              >
                {rec.Name}
              </Button>
            ))}
          </Section>
        )}
        {menu === 21 && (
          <Section title="Information Record">
            {exploit_exists && exploit ? (
              <Table>
                {exploit.fields.map((field) => (
                  <Table.Row key={field.name}>
                    <Table.Cell bold color="good">
                      {field.name}:
                    </Table.Cell>
                    <Table.Cell color="average">{field.value}</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            ) : (
              <NoticeBox>No record found.</NoticeBox>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
