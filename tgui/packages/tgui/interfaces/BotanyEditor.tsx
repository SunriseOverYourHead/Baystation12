import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  activity: BooleanLike;
  disk: BooleanLike;
  sourceName: string | null;
  degradation: number;
  locus: string | null;
  loaded: string | null;
};

export const BotanyEditor = () => {
  const { act, data } = useBackend<Data>();
  const { activity, disk, sourceName, degradation, locus, loaded } = data;

  const tooDecayed = degradation > 100;

  return (
    <Window title="Bioballistic Delivery System" width={470} height={450}>
      <Window.Content scrollable>
        {activity ? (
          <NoticeBox>Processing...</NoticeBox>
        ) : (
          <>
            <Section title="Buffered Genetic Data">
              {disk ? (
                <>
                  <LabeledList>
                    <LabeledList.Item label="Source">
                      {sourceName}
                    </LabeledList.Item>
                    <LabeledList.Item label="Gene decay">
                      {tooDecayed ? (
                        <Box color="bad">FURTHER AMENDMENTS NONVIABLE</Box>
                      ) : (
                        `${degradation}%`
                      )}
                    </LabeledList.Item>
                    <LabeledList.Item label="Locus">{locus}</LabeledList.Item>
                  </LabeledList>
                  <Button
                    icon="eject"
                    mt={1}
                    onClick={() => act('eject_disk')}
                  >
                    Eject Disk
                  </Button>
                </>
              ) : (
                <NoticeBox>No disk loaded.</NoticeBox>
              )}
            </Section>
            <Section title="Loaded Material">
              {loaded ? (
                <>
                  <LabeledList>
                    <LabeledList.Item label="Target">
                      {loaded}
                    </LabeledList.Item>
                  </LabeledList>
                  <Box mt={1}>
                    {!tooDecayed && (
                      <Button
                        icon="cog"
                        onClick={() => act('apply_gene')}
                      >
                        Apply Gene Mods
                      </Button>
                    )}
                    <Button
                      icon="eject"
                      ml={!tooDecayed ? 1 : 0}
                      onClick={() => act('eject_packet')}
                    >
                      Eject Target
                    </Button>
                  </Box>
                </>
              ) : (
                <NoticeBox>No target seed packet loaded.</NoticeBox>
              )}
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
