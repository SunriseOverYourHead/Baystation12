import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const T0C = 273.15;

const STAT_COLOR: Record<string, string> = {
  Dead: 'bad',
  Conscious: 'bad',
  Unconscious: 'good',
};

type Occupant = {
  name: string;
  stat: string;
  bodyTemperature: number;
  health: number;
  maxHealth: number;
  bruteLoss: number;
  oxyLoss: number;
  toxLoss: number;
  fireLoss: number;
};

type BeakerContent = {
  name: string;
  volume: number;
};

type Beaker = {
  label: string;
  currentVolume: number;
  maxVolume: number;
  contents: BeakerContent[];
};

type Data = {
  isOperating: BooleanLike;
  cellTemperature: number;
  occupant?: Occupant;
  beaker?: Beaker;
  stasisMode: 'fast' | 'normal' | 'slow';
  fastStasisMult: number;
  slowStasisMult: number;
};

export const CryoCell = () => {
  const { act, data } = useBackend<Data>();
  const {
    isOperating,
    cellTemperature,
    occupant,
    beaker,
    stasisMode,
    fastStasisMult,
    slowStasisMult,
  } = data;

  return (
    <Window title="Cryo Cell Control System" width={400} height={500}>
      <Window.Content scrollable>
        <Section title="Occupant">
          <LabeledList>
            <LabeledList.Item label="Occupant">
              {occupant?.name || 'No Occupant'}
            </LabeledList.Item>
            {!!occupant && (
              <>
                <LabeledList.Item
                  label="State"
                  color={STAT_COLOR[occupant.stat] ?? 'average'}
                >
                  {occupant.stat}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Temperature"
                  color={occupant.bodyTemperature < T0C ? 'good' : 'bad'}
                >
                  <AnimatedNumber value={round(occupant.bodyTemperature, 0)} />{' '}
                  K
                </LabeledList.Item>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    value={occupant.health / occupant.maxHealth}
                    color={occupant.health > 0 ? 'good' : 'average'}
                  >
                    <AnimatedNumber value={round(occupant.health, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Brute">
                  <ProgressBar value={occupant.bruteLoss / 100}>
                    <AnimatedNumber value={round(occupant.bruteLoss, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Respiratory">
                  <ProgressBar value={occupant.oxyLoss / 100}>
                    <AnimatedNumber value={round(occupant.oxyLoss, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Toxin">
                  <ProgressBar value={occupant.toxLoss / 100}>
                    <AnimatedNumber value={round(occupant.toxLoss, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Burn">
                  <ProgressBar value={occupant.fireLoss / 100}>
                    <AnimatedNumber value={round(occupant.fireLoss, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Eject">
                  <Button icon="sign-out-alt" onClick={() => act('eject_occupant')}>
                    Eject
                  </Button>
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Section>
        <Section title="Cell">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={isOperating ? 'power-off' : 'times'}
                color={isOperating ? 'green' : undefined}
                onClick={() => act('power')}
              >
                {isOperating ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <AnimatedNumber value={round(cellTemperature, 0)} /> K
            </LabeledList.Item>
            <LabeledList.Item label="Stasis Speed">
              <Button
                selected={stasisMode === 'fast'}
                onClick={() => act('set_stasis', { mode: 'fast' })}
              >
                Fast ({round((1 - fastStasisMult) * 100, 0)}%)
              </Button>
              <Button
                selected={stasisMode === 'normal'}
                onClick={() => act('set_stasis', { mode: 'normal' })}
              >
                Normal
              </Button>
              <Button
                selected={stasisMode === 'slow'}
                onClick={() => act('set_stasis', { mode: 'slow' })}
              >
                Slow (+{round((slowStasisMult - 1) * 100, 0)}%)
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Beaker"
          buttons={
            !!beaker && (
              <Button icon="eject" onClick={() => act('eject_beaker')}>
                Eject
              </Button>
            )
          }
        >
          {beaker ? (
            <LabeledList>
              <LabeledList.Item label={beaker.label}>
                <AnimatedNumber value={round(beaker.currentVolume, 0)} /> /{' '}
                {beaker.maxVolume} units
              </LabeledList.Item>
              {beaker.contents.map((reagent) => (
                <LabeledList.Item key={reagent.name} label={reagent.name}>
                  <AnimatedNumber value={round(reagent.volume, 0)} /> units
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <Box color="label">No beaker loaded.</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
