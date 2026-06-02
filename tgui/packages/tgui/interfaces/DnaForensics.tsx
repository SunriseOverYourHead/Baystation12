import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  scan_progress: number;
  scanning: BooleanLike;
  bloodsamp: string;
  bloodsamp_desc: string;
  lidstate: BooleanLike;
};

export const DnaForensics = () => {
  const { act, data } = useBackend<Data>();
  const { scan_progress, scanning, bloodsamp, bloodsamp_desc, lidstate } =
    data;

  return (
    <Window title="QuikScan DNA Analyzer" width={540} height={326}>
      <Window.Content>
        <Section title="Sample">
          <LabeledList>
            <LabeledList.Item label="Lid">
              <Button
                icon={lidstate ? 'lock' : 'lock-open'}
                selected={!!lidstate}
                disabled={!!scanning}
                onClick={() => act('toggleLid')}
              >
                {lidstate ? 'Closed' : 'Open'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Sample">
              {bloodsamp ? (
                <>
                  <Box inline>{bloodsamp}</Box>
                  <Button
                    icon="eject"
                    ml={1}
                    disabled={!!scanning}
                    onClick={() => act('ejectItem')}
                  >
                    Eject
                  </Button>
                </>
              ) : (
                <Box color="label">No sample loaded</Box>
              )}
            </LabeledList.Item>
            {!!bloodsamp && (
              <LabeledList.Item label="Info">
                <Box color="label">{bloodsamp_desc}</Box>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section title="Scan">
          {!bloodsamp && (
            <NoticeBox>Insert a DNA sample swab to begin scanning.</NoticeBox>
          )}
          {!!bloodsamp && (
            <>
              <ProgressBar
                value={scan_progress}
                maxValue={100}
                ranges={{
                  good: [75, 100],
                  average: [25, 75],
                  bad: [0, 25],
                }}
                mb={1}
              >
                {scan_progress}%
              </ProgressBar>
              <Button
                icon={scanning ? 'stop' : 'play'}
                selected={!!scanning}
                color={scanning ? 'bad' : 'good'}
                disabled={!lidstate && !scanning}
                onClick={() => act('scanItem')}
              >
                {scanning ? 'Stop Scan' : 'Start Scan'}
              </Button>
              {!lidstate && !scanning && (
                <Box color="average" mt={1}>
                  Close the lid before scanning.
                </Box>
              )}
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
