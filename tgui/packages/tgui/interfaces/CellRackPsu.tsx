import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const PSU_OFFLINE = 0;
const PSU_OUTPUT = 1;
const PSU_INPUT = 2;
const PSU_AUTO = 3;

type CellEntry = {
  slot: number;
  used: BooleanLike;
  percentage?: number;
};

type Data = {
  mode: number;
  transfer_max: number;
  output_load: number;
  input_load: number;
  equalise: BooleanLike;
  blink_tick: BooleanLike;
  cells_max: number;
  cells_cur: number;
  cells_list: CellEntry[];
};

const modeLabel = (mode: number) => {
  switch (mode) {
    case PSU_OUTPUT:
      return 'OUTPUT ONLY';
    case PSU_INPUT:
      return 'INPUT ONLY';
    case PSU_AUTO:
      return 'INPUT AND OUTPUT';
    default:
      return 'OFFLINE';
  }
};

export const CellRackPsu = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    mode,
    transfer_max,
    output_load,
    input_load,
    equalise,
    blink_tick,
    cells_list,
  } = data;

  return (
    <Window title="Cell Rack PSU" width={500} height={430}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Current Mode">
              {modeLabel(mode)}
            </LabeledList.Item>
            <LabeledList.Item label="Input">
              {input_load} / {transfer_max} W
            </LabeledList.Item>
            <LabeledList.Item label="Output">
              {output_load} / {transfer_max} W
            </LabeledList.Item>
            <LabeledList.Item label="Control">
              <Button
                disabled={mode === PSU_OFFLINE}
                onClick={() => act('disable')}
              >
                OFF
              </Button>
              <Button
                disabled={mode === PSU_OUTPUT}
                onClick={() => act('enable', { enable: PSU_OUTPUT })}
              >
                OUT
              </Button>
              <Button
                disabled={mode === PSU_INPUT}
                onClick={() => act('enable', { enable: PSU_INPUT })}
              >
                IN
              </Button>
              <Button
                disabled={mode === PSU_AUTO}
                onClick={() => act('enable', { enable: PSU_AUTO })}
              >
                IN/OUT
              </Button>
              <Button
                color={equalise ? (blink_tick ? 'yellow' : 'red') : undefined}
                onClick={() => act(equalise ? 'equaliseoff' : 'equaliseon')}
              >
                EQ
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Cells">
          <Table>
            {cells_list.map((cell) => (
              <Table.Row key={cell.slot} className="candystripe">
                <Table.Cell>Cell {cell.slot}</Table.Cell>
                <Table.Cell width="180px">
                  {cell.used ? (
                    <ProgressBar
                      value={(cell.percentage ?? 0) / 100}
                      color="good"
                    />
                  ) : (
                    <Box color="bad">N/C</Box>
                  )}
                </Table.Cell>
                <Table.Cell>
                  {cell.used ? `${cell.percentage?.toFixed(2)} %` : ''}
                </Table.Cell>
                <Table.Cell>
                  <Button
                    disabled={!cell.used}
                    icon="eject"
                    onClick={() => act('ejectcell', { ejectcell: cell.slot })}
                  >
                    E
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
