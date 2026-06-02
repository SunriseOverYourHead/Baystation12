import { Button, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type PowerChannel = {
  title: string;
  powerLoad: number;
  status: number;
  key: string;
};

type Data = {
  locked: BooleanLike;
  isOperating: BooleanLike;
  externalPower: number;
  powerCellStatus: number | null;
  chargeMode: BooleanLike;
  chargingStatus: number;
  totalLoad: number;
  totalCharging: number;
  coverLocked: BooleanLike;
  failTime: number;
  siliconUser: BooleanLike;
  powerChannels: PowerChannel[];
  pChan_Off: number;
  pChan_Off_T: number;
  pChan_Off_A: number;
  pChan_On: number;
  pChan_On_A: number;
};

const CHAN_OFF = 0;
const CHAN_OFF_T = 1;
const CHAN_OFF_A = 2;
const CHAN_ON = 3;
const CHAN_ON_A = 4;

const externalPowerLabel = (v: number) => {
  if (v === 2) return { text: 'Good', color: 'good' };
  if (v === 1) return { text: 'Low', color: 'average' };
  return { text: 'None', color: 'bad' };
};

const chargingLabel = (v: number) => {
  if (v > 1) return { text: 'Fully Charged', color: 'good' };
  if (v === 1) return { text: 'Charging', color: 'average' };
  return { text: 'Not Charging', color: 'bad' };
};

const chanIsOn = (status: number) => status >= CHAN_ON;
const chanIsAuto = (status: number) =>
  status === CHAN_OFF_A || status === CHAN_ON_A;

export const Apc = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    locked,
    isOperating,
    externalPower,
    powerCellStatus,
    chargeMode,
    chargingStatus,
    totalLoad,
    totalCharging,
    coverLocked,
    failTime,
    siliconUser,
    powerChannels,
  } = data;

  const extLabel = externalPowerLabel(externalPower);
  const chrgLabel = chargingLabel(chargingStatus);
  const canControl = !locked || siliconUser;

  const height = siliconUser ? 465 : 440;

  if (failTime) {
    return (
      <Window title="APC" width={520} height={height}>
        <Window.Content>
          <Section>
            <b>SYSTEM FAILURE</b>
            <br />
            I/O regulators malfunction detected! Waiting for system reboot...
            <br />
            Automatic reboot in {failTime} seconds...
            <br />
            <Button icon="sync" onClick={() => act('reboot')}>
              Reboot Now
            </Button>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title="APC" width={520} height={height}>
      <Window.Content>
        {siliconUser ? (
          <Section title="Interface Lock">
            <Button
              selected={!!locked}
              icon="lock"
              onClick={() => act('toggleaccess')}
            >
              {locked ? 'Engaged' : 'Disengaged'}
            </Button>
          </Section>
        ) : (
          <Section>
            {locked
              ? 'Swipe an ID card to unlock this interface'
              : 'Swipe an ID card to lock this interface'}
          </Section>
        )}

        <Section title="Power Status">
          <LabeledList>
            <LabeledList.Item label="Main Breaker">
              {canControl ? (
                <>
                  <Button
                    selected={!!isOperating}
                    icon="power-off"
                    onClick={() => act('breaker')}
                  >
                    On
                  </Button>
                  <Button
                    selected={!isOperating}
                    icon="times"
                    onClick={() => act('breaker')}
                  >
                    Off
                  </Button>
                </>
              ) : (
                <span style={{ color: isOperating ? 'green' : 'red' }}>
                  {isOperating ? 'On' : 'Off'}
                </span>
              )}
            </LabeledList.Item>

            <LabeledList.Item label="External Power">
              <span style={{ color: extLabel.color }}>{extLabel.text}</span>
            </LabeledList.Item>

            <LabeledList.Item label="Power Cell">
              {powerCellStatus === null ? (
                <span style={{ color: 'red' }}>Power cell removed.</span>
              ) : (
                <>
                  <ProgressBar
                    value={powerCellStatus / 100}
                    color={
                      powerCellStatus >= 50
                        ? 'good'
                        : powerCellStatus >= 25
                          ? 'average'
                          : 'bad'
                    }
                  />
                  &nbsp;{Math.round(powerCellStatus * 10) / 10}%
                </>
              )}
            </LabeledList.Item>

            {powerCellStatus !== null && (
              <LabeledList.Item label="Charge Mode">
                {canControl ? (
                  <>
                    <Button
                      selected={!!chargeMode}
                      icon="sync"
                      onClick={() => act('cmode')}
                    >
                      Auto
                    </Button>
                    <Button
                      selected={!chargeMode}
                      icon="times"
                      onClick={() => act('cmode')}
                    >
                      Off
                    </Button>
                  </>
                ) : (
                  <span style={{ color: chargeMode ? 'green' : 'red' }}>
                    {chargeMode ? 'Auto' : 'Off'}
                  </span>
                )}
                &nbsp;[<span style={{ color: chrgLabel.color }}>{chrgLabel.text}</span>]
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        <Section title="Power Channels">
          <LabeledList>
            {powerChannels.map((chan) => (
              <LabeledList.Item key={chan.title} label={chan.title}>
                <span style={{ color: chanIsOn(chan.status) ? 'green' : 'red' }}>
                  {chanIsOn(chan.status) ? 'On' : 'Off'}
                </span>
                &nbsp;&nbsp;
                {locked && !siliconUser ? (
                  <span>{chanIsAuto(chan.status) ? 'Auto' : 'Manual'}</span>
                ) : (
                  <>
                    <Button
                      selected={chanIsAuto(chan.status)}
                      icon="sync"
                      onClick={() => act('channel', { chan: chan.key, mode: 'auto' })}
                    >
                      Auto
                    </Button>
                    <Button
                      selected={
                        chan.status === CHAN_OFF_T || chan.status === CHAN_ON
                      }
                      icon="power-off"
                      onClick={() => act('channel', { chan: chan.key, mode: 'on' })}
                    >
                      On
                    </Button>
                    <Button
                      selected={chan.status === CHAN_OFF}
                      icon="times"
                      onClick={() => act('channel', { chan: chan.key, mode: 'off' })}
                    >
                      Off
                    </Button>
                  </>
                )}
                &nbsp;&nbsp;{chan.powerLoad} W
              </LabeledList.Item>
            ))}

            <LabeledList.Item label="Total Load">
              <b>
                {totalLoad} W
                {totalCharging ? ` (+ ${totalCharging} W Charging)` : ''}
              </b>
            </LabeledList.Item>

            <LabeledList.Item label="Cover Lock">
              {canControl ? (
                <>
                  <Button
                    selected={!!coverLocked}
                    icon="lock"
                    onClick={() => act('lock')}
                  >
                    Engaged
                  </Button>
                  <Button
                    selected={!coverLocked}
                    icon="lock-open"
                    onClick={() => act('lock')}
                  >
                    Disengaged
                  </Button>
                </>
              ) : (
                <span style={{ color: coverLocked ? 'green' : 'red' }}>
                  {coverLocked ? 'Engaged' : 'Disengaged'}
                </span>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        {!!siliconUser && (
          <Section title="System Overrides">
            <Button icon="lightbulb" onClick={() => act('overload')}>
              Overload Lighting Circuit
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
