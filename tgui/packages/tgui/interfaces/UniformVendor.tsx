import {
  Box,
  Button,
  Collapsible,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type UniformItem = {
  name: string;
  path: string;
  selected: BooleanLike;
  can_issue: BooleanLike;
};

type UniformCategory = {
  name: string;
  items: UniformItem[];
};

type Data = {
  has_id: BooleanLike;
  id_info: string | null;
  categories: UniformCategory[];
  selected_count: number;
};

export const UniformVendor = () => {
  const { act, data } = useBackend<Data>();
  const { has_id, id_info, categories, selected_count } = data;

  return (
    <Window title="Uniform Vendor" width={320} height={600}>
      <Window.Content scrollable>
        <Section title="Identification">
          {has_id ? (
            <Stack align="center">
              <Stack.Item grow>{id_info}</Stack.Item>
              <Stack.Item>
                <Button icon="eject" onClick={() => act('toggle_id')}>
                  Eject
                </Button>
              </Stack.Item>
            </Stack>
          ) : (
            <Button fluid icon="id-card" onClick={() => act('toggle_id')}>
              Insert ID Card
            </Button>
          )}
        </Section>
        {!!has_id && (
          <>
            {categories.map((cat) => (
              <Collapsible
                key={cat.name}
                title={cat.name}
                buttons={
                  <Button
                    icon="check-double"
                    onClick={() => act('select_category', { name: cat.name })}
                  >
                    Select All
                  </Button>
                }
              >
                {cat.items.map((item) => (
                  <Box key={item.path}>
                    <Button
                      fluid
                      icon={
                        item.selected
                          ? 'check-square'
                          : item.can_issue
                            ? 'square'
                            : 'ban'
                      }
                      color={
                        item.selected
                          ? 'green'
                          : !item.can_issue
                            ? 'transparent'
                            : undefined
                      }
                      disabled={!item.can_issue && !item.selected}
                      onClick={() =>
                        act('toggle_item', {
                          path: item.path,
                          add: !item.selected,
                        })
                      }
                    >
                      {item.name}
                      {!item.can_issue && !item.selected && ' (Issued)'}
                    </Button>
                  </Box>
                ))}
              </Collapsible>
            ))}
            <Section>
              <Button
                fluid
                icon="box-open"
                disabled={selected_count === 0}
                color={selected_count > 0 ? 'green' : undefined}
                onClick={() => act('vend')}
              >
                Dispense ({selected_count} item
                {selected_count !== 1 ? 's' : ''})
              </Button>
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
