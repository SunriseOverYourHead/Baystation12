import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type Reagent = {
  name: string;
  amount: number;
};

type Data = {
  power: BooleanLike;
  occupant: string | BooleanLike;
  beaker: number;
  filtering: BooleanLike;
  pump: BooleanLike;
  stasis: number;
  skill_check: BooleanLike;
  reagents: Reagent[];
};

const STASIS_OPTIONS = [
  { label: 'Off', value: 1 },
  { label: '2x', value: 2 },
  { label: '5x', value: 5 },
  { label: '10x', value: 10 },
];

export const Sleeper = () => {
  const { act, data } = useBackend<Data>();
  const { power, occupant, beaker, filtering, pump, stasis, skill_check, reagents } = data;

  return (
    <Window title="Sleeper UI" width={600} height={600}>
      <Window.Content scrollable>
        {!power ? (
          <Section title="NO POWER" color="bad">
            {!!occupant && (
              <Button icon="sign-out-alt" onClick={() => act('eject')}>
                Eject Occupant
              </Button>
            )}
          </Section>
        ) : (
          <>
            <Section title="Occupant">
              {occupant ? (
                <>
                  <Box
                    dangerouslySetInnerHTML={{ __html: sanitizeText(occupant as string) }}
                    mb={1}
                  />
                  {!!skill_check && (
                    <LabeledList>
                      <LabeledList.Item label="Dialysis">
                        <Button
                          icon={filtering ? 'tint' : 'tint-slash'}
                          color={filtering ? 'good' : 'default'}
                          onClick={() => act('filter', { filter: filtering ? 0 : 1 })}
                        >
                          {filtering ? 'Dialysis Active' : 'Dialysis Inactive'}
                        </Button>
                      </LabeledList.Item>
                      <LabeledList.Item label="Stomach Pump">
                        <Button
                          icon={pump ? 'compress-arrows-alt' : 'compress-arrows-alt'}
                          color={pump ? 'good' : 'default'}
                          onClick={() => act('pump', { pump: pump ? 0 : 1 })}
                        >
                          {pump ? 'Stomach Pump Active' : 'Stomach Pump Inactive'}
                        </Button>
                      </LabeledList.Item>
                    </LabeledList>
                  )}
                  <Button
                    mt={1}
                    icon="sign-out-alt"
                    onClick={() => act('eject')}
                  >
                    Eject Occupant
                  </Button>
                </>
              ) : (
                <Box>No occupant.</Box>
              )}
            </Section>
            <Section title="Stasis Setting">
              {STASIS_OPTIONS.map(({ label, value }) => (
                <Button
                  key={value}
                  selected={stasis === value}
                  onClick={() => act('stasis', { stasis: value })}
                >
                  {label}
                </Button>
              ))}
            </Section>
            <Section title="Chemicals">
              <LabeledList>
                {reagents.map((reagent) => (
                  <LabeledList.Item key={reagent.name} label={reagent.name}>
                    {!!occupant && (
                      <Box as="span" mr={1}>
                        Occupant: {reagent.amount} units
                      </Box>
                    )}
                    <Button
                      disabled={!occupant}
                      onClick={() => act('chemical', { chemical: reagent.name, amount: 5 })}
                    >
                      Inject 5
                    </Button>
                    <Button
                      disabled={!occupant}
                      onClick={() => act('chemical', { chemical: reagent.name, amount: 10 })}
                    >
                      Inject 10
                    </Button>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
            <Section title="Beaker">
              {beaker !== -1 ? (
                <LabeledList>
                  <LabeledList.Item label="Free Space">
                    {beaker} units of free space remaining.
                    <Button
                      ml={1}
                      icon="eject"
                      onClick={() => act('beaker')}
                    >
                      Eject
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              ) : (
                <NoticeBox>No beaker inserted.</NoticeBox>
              )}
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
