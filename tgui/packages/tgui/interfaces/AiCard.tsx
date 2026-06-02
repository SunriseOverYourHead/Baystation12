import { Box, Button, LabeledList, NoticeBox, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type AiLaw = {
  index: string;
  law: string;
};

type Data = {
  has_ai: BooleanLike;
  name?: string;
  hardware_integrity?: number;
  backup_capacitor?: number;
  radio?: BooleanLike;
  wireless?: BooleanLike;
  operational?: BooleanLike;
  flushing?: BooleanLike;
  laws?: AiLaw[];
  has_laws?: BooleanLike;
};

export const AiCard = () => {
  const { act, data } = useBackend<Data>();
  const {
    has_ai,
    name,
    hardware_integrity,
    backup_capacitor,
    radio,
    wireless,
    operational,
    flushing,
    laws,
    has_laws,
  } = data;

  return (
    <Window title="inteliCard" width={600} height={400}>
      <Window.Content scrollable>
        {has_ai ? (
          <>
            <Section title={name}>
              <LabeledList>
                <LabeledList.Item label="Hardware Integrity">
                  {hardware_integrity}%
                </LabeledList.Item>
                <LabeledList.Item label="Backup Capacitor">
                  {backup_capacitor}%
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Laws">
              {has_laws ? (
                <Table>
                  <Table.Row header>
                    <Table.Cell collapsing>Index</Table.Cell>
                    <Table.Cell>Law</Table.Cell>
                  </Table.Row>
                  {laws &&
                    laws.map((law) => (
                      <Table.Row key={law.index}>
                        <Table.Cell collapsing>{law.index}.</Table.Cell>
                        <Table.Cell>{law.law}</Table.Cell>
                      </Table.Row>
                    ))}
                </Table>
              ) : (
                <NoticeBox>No laws found.</NoticeBox>
              )}
            </Section>
            {!!operational && (
              <Section title="Controls">
                <LabeledList>
                  <LabeledList.Item label="Radio Subspace Transceiver">
                    <Button
                      selected={!!radio}
                      onClick={() => act('radio', { radio: 0 })}
                    >
                      Enabled
                    </Button>
                    <Button
                      selected={!radio}
                      color={!radio ? 'bad' : undefined}
                      onClick={() => act('radio', { radio: 1 })}
                    >
                      Disabled
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Wireless Interface">
                    <Button
                      selected={!!wireless}
                      onClick={() => act('wireless', { wireless: 0 })}
                    >
                      Enabled
                    </Button>
                    <Button
                      selected={!wireless}
                      color={!wireless ? 'bad' : undefined}
                      onClick={() => act('wireless', { wireless: 1 })}
                    >
                      Disabled
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Wipe AI">
                    {flushing ? (
                      <Box color="average">AI wipe in progress...</Box>
                    ) : (
                      <Button
                        icon="radiation"
                        color="bad"
                        onClick={() => act('wipe')}
                      >
                        Wipe
                      </Button>
                    )}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            )}
          </>
        ) : (
          <Section>
            <NoticeBox>No AI detected.</NoticeBox>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
