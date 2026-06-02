import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  panelopen: BooleanLike;
  open: BooleanLike;
  locked: BooleanLike;
  uv: BooleanLike;
  superuv: BooleanLike;
  safeties: BooleanLike;
  helmet: string | null;
  suit: string | null;
  boots: string | null;
  tank: string | null;
  mask: string | null;
};

export const SuitStorageUnit = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    panelopen,
    open,
    locked,
    uv,
    superuv,
    safeties,
    helmet,
    suit,
    boots,
    tank,
    mask,
  } = data;

  return (
    <Window title="Suit Storage Unit" width={400} height={500}>
      <Window.Content>
        <Section title="Storage">
          <LabeledList>
            <LabeledList.Item label="Helmet">
              {helmet ? (
                <Button
                  icon="hard-hat"
                  content={helmet}
                  onClick={() => act('dispense_helmet')}
                />
              ) : (
                'Empty'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Suit">
              {suit ? (
                <Button
                  icon="tshirt"
                  content={suit}
                  onClick={() => act('dispense_suit')}
                />
              ) : (
                'Empty'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Boots">
              {boots ? (
                <Button
                  icon="shoe-prints"
                  content={boots}
                  onClick={() => act('dispense_boots')}
                />
              ) : (
                'Empty'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Tank">
              {tank ? (
                <Button
                  icon="flask"
                  content={tank}
                  onClick={() => act('dispense_tank')}
                />
              ) : (
                'Empty'
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Mask">
              {mask ? (
                <Button
                  icon="mask"
                  content={mask}
                  onClick={() => act('dispense_mask')}
                />
              ) : (
                'Empty'
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          <Stack>
            <Stack.Item>
              <Button
                icon={open ? 'door-open' : 'door-closed'}
                content={open ? 'Close Door' : 'Open Door'}
                color={open ? 'average' : 'default'}
                onClick={() => act('toggle_open')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon={locked ? 'lock' : 'lock-open'}
                content={locked ? 'Unlock' : 'Lock'}
                color={locked ? 'bad' : 'default'}
                onClick={() => act('toggle_lock')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="radiation"
                content={uv ? 'UV Running' : 'Start UV Cycle'}
                disabled={!!uv}
                color={uv ? 'average' : 'default'}
                onClick={() => act('start_UV')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="person-booth"
                content="Eject Occupant"
                onClick={() => act('eject_guy')}
              />
            </Stack.Item>
          </Stack>
        </Section>
        {!!panelopen && (
          <Section title="Maintenance Panel">
            <Stack>
              <Stack.Item>
                <Button
                  icon={superuv ? 'sun' : 'moon'}
                  content={superuv ? 'Super UV: On' : 'Super UV: Off'}
                  selected={!!superuv}
                  onClick={() => act('toggleUV')}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="shield-alt"
                  content={safeties ? 'Safeties: On' : 'Safeties: Off'}
                  selected={!!safeties}
                  color={safeties ? 'good' : 'bad'}
                  onClick={() => act('togglesafeties')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
