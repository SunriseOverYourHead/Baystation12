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

type GeneMask = {
  mask: string;
  tag: string;
};

type Data = {
  activity: BooleanLike;
  geneMasks: GeneMask[];
  degradation: number;
  disk: BooleanLike;
  loaded: string | null;
  hasGenetics: BooleanLike;
  sourceName: string | null;
};

export const BotanyIsolator = () => {
  const { act, data } = useBackend<Data>();
  const {
    activity,
    geneMasks = [],
    degradation,
    disk,
    loaded,
    hasGenetics,
    sourceName,
  } = data;

  return (
    <Window title="Lysis-isolation Centrifuge" width={470} height={450}>
      <Window.Content scrollable>
        {activity ? (
          <NoticeBox>Processing...</NoticeBox>
        ) : (
          <>
            <Section title="Buffered Genetic Data">
              {hasGenetics ? (
                <>
                  <LabeledList>
                    <LabeledList.Item label="Source">
                      {sourceName}
                    </LabeledList.Item>
                    <LabeledList.Item label="Gene decay">
                      {degradation}%
                    </LabeledList.Item>
                  </LabeledList>
                  {disk ? (
                    <>
                      {geneMasks.length === 0 ? (
                        <NoticeBox>
                          Data error. Genetic record corrupt.
                        </NoticeBox>
                      ) : (
                        <LabeledList mt={1}>
                          {geneMasks.map((gene) => (
                            <LabeledList.Item key={gene.tag} label={gene.mask}>
                              <Button
                                icon="arrow-down"
                                onClick={() =>
                                  act('get_gene', { get_gene: gene.tag })
                                }
                              >
                                Extract
                              </Button>
                            </LabeledList.Item>
                          ))}
                        </LabeledList>
                      )}
                      <Box mt={1}>
                        <Button
                          icon="eject"
                          onClick={() => act('eject_disk')}
                        >
                          Eject Loaded Disk
                        </Button>
                        <Button
                          icon="times"
                          ml={1}
                          onClick={() => act('clear_buffer')}
                        >
                          Clear Genetic Buffer
                        </Button>
                      </Box>
                    </>
                  ) : (
                    <NoticeBox mt={1}>No disk inserted.</NoticeBox>
                  )}
                </>
              ) : (
                <>
                  <NoticeBox>No data buffered.</NoticeBox>
                  {disk && (
                    <Button icon="eject" mt={1} onClick={() => act('eject_disk')}>
                      Eject Loaded Disk
                    </Button>
                  )}
                </>
              )}
            </Section>
            <Section title="Loaded Material">
              {loaded ? (
                <>
                  <LabeledList>
                    <LabeledList.Item label="Packet loaded">
                      {loaded}
                    </LabeledList.Item>
                  </LabeledList>
                  <Box mt={1}>
                    <Button
                      icon="cog"
                      onClick={() => act('scan_genome')}
                    >
                      Process Genome
                    </Button>
                    <Button
                      icon="eject"
                      ml={1}
                      onClick={() => act('eject_packet')}
                    >
                      Eject Packet
                    </Button>
                  </Box>
                </>
              ) : (
                <NoticeBox>No seeds loaded.</NoticeBox>
              )}
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
