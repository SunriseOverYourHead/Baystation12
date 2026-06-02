import { Box, Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  mode: number; // -1=unscrewed, 0=off, 1=pressurizing, 2=ready
  flush: BooleanLike;
  flushing: BooleanLike;
  pressure: number;
  is_ai: BooleanLike;
};

export function WasteDisposalUnit(props) {
  const { act, data } = useBackend<Data>();
  const { mode, flush, flushing, pressure, is_ai } = data;

  const pumpOn = mode >= 1;
  const pumpLabel =
    mode === 1 ? 'On (Pressurizing)' : mode === 2 ? 'On (Ready)' : 'Off';
  const disabled = !!flushing;

  return (
    <Window title="Waste Disposal Unit" width={320} height={220}>
      <Window.Content>
        <Section title="Disposal Controls">
          {mode === -1 && (
            <NoticeBox>
              Power disconnected. Only ejection is permitted.
            </NoticeBox>
          )}
          <LabeledList>
            <LabeledList.Item label="Pump">
              <Button
                selected={pumpOn}
                onClick={() => act('pump', { value: pumpOn ? 0 : 1 })}
                disabled={disabled || mode === -1}
              >
                {pumpLabel}
              </Button>
            </LabeledList.Item>
            {!is_ai && (
              <LabeledList.Item label="Flush Handle">
                <Button
                  selected={!!flush}
                  color={flush ? 'good' : undefined}
                  onClick={() => act('handle', { value: flush ? 0 : 1 })}
                  disabled={disabled || mode === -1}
                >
                  {flush ? 'Engaged' : 'Disengaged'}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Pressure">
              <Box color={pressure >= 100 ? 'good' : 'average'}>
                {pressure.toFixed(1)}%
              </Box>
            </LabeledList.Item>
          </LabeledList>
          {!is_ai && (
            <Box mt={1}>
              <Button
                icon="eject"
                onClick={() => act('eject')}
                disabled={disabled}
              >
                Eject Contents
              </Button>
            </Box>
          )}
          {flushing && (
            <Box mt={1} color="average">
              Flushing in progress...
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
}
