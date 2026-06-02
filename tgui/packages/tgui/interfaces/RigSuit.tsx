import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ChargeSlot = {
  caption: string;
  index: string;
};

type RigModule = {
  index: number;
  name: string;
  desc: string;
  can_use: BooleanLike;
  can_select: BooleanLike;
  can_toggle: BooleanLike;
  is_active: BooleanLike;
  engagecost: number;
  activecost: number;
  passivecost: number;
  engagestring: string;
  activatestring: string;
  deactivatestring: string;
  damage: number;
  charges?: ChargeSlot[];
  chargetype?: string;
};

type Data = {
  primarysystem: string | null;
  ai: BooleanLike;
  seals: BooleanLike;
  sealing: BooleanLike;
  helmet: string;
  gauntlets: string;
  boots: string;
  chest: string;
  charge: number;
  maxcharge: number;
  emagged: BooleanLike;
  coverlock: BooleanLike;
  interfacelock: BooleanLike;
  aicontrol: BooleanLike;
  aioverride: BooleanLike;
  securitycheck: BooleanLike;
  malf: number;
  valveOpen: BooleanLike;
  maskConnected: BooleanLike;
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  maxReleasePressure: number;
  tank: BooleanLike;
  modules: RigModule[];
};

export const RigSuit = () => {
  const { act, data } = useBackend<Data>();
  const {
    primarysystem,
    ai,
    seals,
    sealing,
    helmet,
    gauntlets,
    boots,
    chest,
    charge,
    maxcharge,
    emagged,
    coverlock,
    interfacelock,
    aicontrol,
    aioverride,
    securitycheck,
    malf,
    valveOpen,
    maskConnected,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    maxReleasePressure,
    tank,
    modules = [],
  } = data;

  const offline = !!interfacelock || malf > 0;
  const systemsOnline = !seals && !sealing;
  const chargeRatio = maxcharge > 0 ? charge / maxcharge : 0;

  return (
    <Window title="Hardsuit Controller" width={480} height={600}>
      <Window.Content scrollable>
        {offline ? (
          <NoticeBox danger>-- HARDSUIT INTERFACE OFFLINE --</NoticeBox>
        ) : !!aicontrol && !ai ? (
          <NoticeBox danger>-- HARDSUIT CONTROL OVERRIDDEN BY AI --</NoticeBox>
        ) : (
          <>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Power Supply">
                  <ProgressBar
                    value={chargeRatio}
                    color={
                      chargeRatio >= 0.7
                        ? 'good'
                        : chargeRatio >= 0.3
                          ? 'average'
                          : 'bad'
                    }
                  >
                    {charge}/{maxcharge}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="AI Control">
                  <Box inline color={aioverride ? 'good' : 'bad'} bold>
                    {aioverride ? 'ENABLED' : 'DISABLED'}
                  </Box>
                  <Button ml={1} onClick={() => act('toggle_ai_control')}>
                    Toggle
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Suit Status">
                  <Box
                    inline
                    color={sealing ? 'average' : seals ? 'bad' : 'good'}
                    bold
                  >
                    {sealing ? 'PROCESSING' : seals ? 'INACTIVE' : 'ACTIVE'}
                  </Box>
                  <Button ml={1} onClick={() => act('toggle_seals')}>
                    Toggle
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Cover Status">
                  {emagged || !securitycheck ? (
                    <Box inline color="average" bold>
                      ERROR - MAINTENANCE LOCK CONTROL OFFLINE
                    </Box>
                  ) : (
                    <>
                      <Box inline color={coverlock ? 'bad' : 'good'} bold>
                        {coverlock ? 'LOCKED' : 'UNLOCKED'}
                      </Box>
                      <Button
                        ml={1}
                        onClick={() => act('toggle_suit_lock')}
                      >
                        Toggle
                      </Button>
                    </>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>

            <Section title="Suit Pieces">
              <LabeledList>
                {[
                  { label: 'Helmet', key: 'helmet', name: helmet },
                  { label: 'Gauntlets', key: 'gauntlets', name: gauntlets },
                  { label: 'Boots', key: 'boots', name: boots },
                  { label: 'Chestpiece', key: 'chest', name: chest },
                ].map((piece) => (
                  <LabeledList.Item key={piece.key} label={piece.label}>
                    {piece.name}
                    {!sealing && (
                      <Button
                        ml={1}
                        onClick={() =>
                          act('toggle_piece', { piece: piece.key })
                        }
                      >
                        Toggle
                      </Button>
                    )}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>

            <Section title="Life Support System">
              {!systemsOnline ? (
                <NoticeBox danger>HARDSUIT SYSTEMS OFFLINE</NoticeBox>
              ) : !tank ? (
                <NoticeBox danger>INTERNAL TANK NOT FOUND</NoticeBox>
              ) : (
                <LabeledList>
                  <LabeledList.Item label="Tank Pressure">
                    <ProgressBar
                      value={tankPressure}
                      minValue={0}
                      maxValue={1013}
                      color={
                        tankPressure > 200
                          ? 'good'
                          : tankPressure > 100
                            ? 'average'
                            : 'bad'
                      }
                    >
                      {tankPressure} kPa
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label="Release Pressure">
                    <ProgressBar
                      value={releasePressure}
                      minValue={0}
                      maxValue={maxReleasePressure}
                      color={
                        releasePressure >= 21
                          ? 'good'
                          : releasePressure >= 17
                            ? 'average'
                            : 'bad'
                      }
                    >
                      {releasePressure} kPa
                    </ProgressBar>
                    <Flex mt={0.5} gap={0.5} wrap="wrap">
                      {[-10, -1].map((delta) => (
                        <Button
                          key={delta}
                          disabled={releasePressure <= 0}
                          onClick={() =>
                            act('adjust_pressure', { dist_p: delta })
                          }
                        >
                          {delta}
                        </Button>
                      ))}
                      <Box px={1} textAlign="center">
                        {releasePressure} kPa
                      </Box>
                      {[1, 10].map((delta) => (
                        <Button
                          key={delta}
                          disabled={releasePressure >= maxReleasePressure}
                          onClick={() =>
                            act('adjust_pressure', { dist_p: delta })
                          }
                        >
                          +{delta}
                        </Button>
                      ))}
                      <Button
                        disabled={releasePressure >= maxReleasePressure}
                        onClick={() =>
                          act('adjust_pressure', { dist_p: 'max' })
                        }
                      >
                        Max
                      </Button>
                      <Button
                        disabled={releasePressure === defaultReleasePressure}
                        onClick={() =>
                          act('adjust_pressure', { dist_p: 'reset' })
                        }
                      >
                        Reset
                      </Button>
                    </Flex>
                  </LabeledList.Item>
                  <LabeledList.Item label="Release Valve">
                    <Button
                      disabled={!maskConnected}
                      selected={!!valveOpen}
                      onClick={() => act('toggle_valve')}
                    >
                      Open
                    </Button>
                    <Button
                      selected={!valveOpen}
                      onClick={() => act('toggle_valve')}
                    >
                      Close
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Section>

            <Section title="System Modules">
              <Box mb={1}>
                Selected primary system:{' '}
                <Box inline bold>
                  {primarysystem || 'None'}
                </Box>
              </Box>
              {!systemsOnline ? (
                <NoticeBox danger>HARDSUIT SYSTEMS OFFLINE</NoticeBox>
              ) : modules.length === 0 ? (
                <Box color="label">None.</Box>
              ) : (
                modules.map((mod) => (
                  <Section
                    key={mod.index}
                    title={
                      <>
                        {mod.name}
                        {mod.damage === 1 && (
                          <Box inline color="average">
                            {' '}
                            (damaged)
                          </Box>
                        )}
                        {mod.damage >= 2 && (
                          <Box inline color="bad">
                            {' '}
                            (destroyed)
                          </Box>
                        )}
                      </>
                    }
                  >
                    <Flex gap={1}>
                      <Flex.Item width="25%">
                        <Box color="average" fontSize="0.85em">
                          Engage: {mod.engagecost}
                          <br />
                          Activate: {mod.activecost}
                          <br />
                          Passive: {mod.passivecost}
                        </Box>
                      </Flex.Item>
                      <Flex.Item width="30%">{mod.desc}</Flex.Item>
                      <Flex.Item grow={1}>
                        <Flex gap={0.5} wrap="wrap">
                          {!!mod.can_use && (
                            <Button
                              onClick={() =>
                                act('interact_module', {
                                  index: mod.index,
                                  mode: 'engage',
                                })
                              }
                            >
                              {mod.engagestring}
                            </Button>
                          )}
                          {!!mod.can_select && (
                            <Button
                              selected={mod.name === primarysystem}
                              onClick={() =>
                                act('interact_module', {
                                  index: mod.index,
                                  mode: 'select',
                                })
                              }
                            >
                              Select
                            </Button>
                          )}
                          {!!mod.can_toggle && (
                            <Button
                              selected={!!mod.is_active}
                              onClick={() =>
                                act('interact_module', {
                                  index: mod.index,
                                  mode: mod.is_active
                                    ? 'deactivate'
                                    : 'activate',
                                })
                              }
                            >
                              {mod.is_active
                                ? mod.deactivatestring
                                : mod.activatestring}
                            </Button>
                          )}
                        </Flex>
                        {mod.charges && mod.charges.length > 0 && (
                          <Box mt={0.5}>
                            <Box color="average" bold>
                              Stored Charges
                            </Box>
                            <Flex gap={0.5} wrap="wrap" mt={0.25}>
                              {mod.charges.map((slot) => (
                                <Button
                                  key={slot.index}
                                  selected={slot.index === mod.chargetype}
                                  onClick={() =>
                                    act('interact_module', {
                                      index: mod.index,
                                      mode: 'select_charge_type',
                                      charge_type: slot.index,
                                    })
                                  }
                                >
                                  {slot.caption}
                                </Button>
                              ))}
                            </Flex>
                          </Box>
                        )}
                      </Flex.Item>
                    </Flex>
                  </Section>
                ))
              )}
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
