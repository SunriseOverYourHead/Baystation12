import { Box, Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  copyitem: string | null;
  copies: number;
  toner: number;
  maxcopies: number;
  is_silicon: BooleanLike;
};

export function Photocopier(props) {
  const { act, data } = useBackend<Data>();
  const { copyitem, copies, toner, maxcopies, is_silicon } = data;

  return (
    <Window title="Photocopier" width={310} height={270}>
      <Window.Content>
        <Section title="Photocopier">
          <LabeledList>
            <LabeledList.Item label="Item">
              {copyitem ? (
                <Box>
                  {copyitem}
                  <Button ml={1} icon="eject" onClick={() => act('remove')}>
                    Remove
                  </Button>
                </Box>
              ) : (
                <Box color="label">Nothing inserted.</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Toner">
              <Box color={toner > 10 ? 'good' : toner > 0 ? 'average' : 'bad'}>
                {toner}
              </Box>
            </LabeledList.Item>
          </LabeledList>
          {!toner && (
            <NoticeBox danger>Please insert a new toner cartridge!</NoticeBox>
          )}
          {copyitem && toner > 0 && (
            <Box mt={1}>
              <Box mb={1}>
                <Box inline color="label" mr={1}>
                  Copies:
                </Box>
                <Button
                  icon="minus"
                  disabled={copies <= 1}
                  onClick={() => act('min')}
                />
                <Box inline mx={1}>
                  {copies}
                </Box>
                <Button
                  icon="plus"
                  disabled={copies >= maxcopies}
                  onClick={() => act('add')}
                />
              </Box>
              <Button icon="copy" onClick={() => act('copy')}>
                Copy
              </Button>
            </Box>
          )}
          {!copyitem && toner > 0 && (
            <Box mt={1} color="label">
              Please insert something to copy.
            </Box>
          )}
          {!!is_silicon && (
            <Box mt={1}>
              <Button
                icon="camera"
                disabled={toner < 5}
                onClick={() => act('aipic')}
              >
                Print photo from database
              </Button>
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
}
