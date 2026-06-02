import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FrozenItem = {
  name: string;
  ref: string;
};

type Data = {
  storage_name: string;
  storage_type: string;
  allow_items: BooleanLike;
  frozen_crew: string[];
  frozen_items: FrozenItem[];
};

export const CryoControl = () => {
  const { act, data } = useBackend<Data>();
  const { storage_name, storage_type, allow_items, frozen_crew, frozen_items } =
    data;

  return (
    <Window title={storage_name} width={420} height={500}>
      <Window.Content scrollable>
        <Section title={`Stored ${storage_type}`}>
          {frozen_crew.length === 0 ? (
            <NoticeBox>No {storage_type} in storage.</NoticeBox>
          ) : (
            <LabeledList>
              {frozen_crew.map((name, i) => (
                <LabeledList.Item key={i} label={String(i + 1)}>
                  {name}
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
        {!!allow_items && (
          <Section
            title="Stored Objects"
            buttons={
              frozen_items.length > 0 && (
                <Button.Confirm
                  icon="box-open"
                  onClick={() => act('recover_all')}
                >
                  Recover All
                </Button.Confirm>
              )
            }
          >
            {frozen_items.length === 0 ? (
              <NoticeBox>No objects in storage.</NoticeBox>
            ) : (
              <LabeledList>
                {frozen_items.map((item) => (
                  <LabeledList.Item
                    key={item.ref}
                    label={item.name}
                    buttons={
                      <Button
                        icon="hand-sparkles"
                        onClick={() =>
                          act('recover_item', { ref: item.ref })
                        }
                      >
                        Recover
                      </Button>
                    }
                  />
                ))}
              </LabeledList>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
