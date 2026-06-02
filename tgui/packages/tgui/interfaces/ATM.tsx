import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const SCREEN_HOME = 0;
const SCREEN_SECURITY = 1;
const SCREEN_TRANSFER = 2;
const SCREEN_LOGS = 3;

type Transaction = {
  date: string;
  time: string;
  target: string;
  purpose: string;
  amount: number;
  source: string;
};

type Data = {
  machine_id: string;
  emagged: BooleanLike;
  is_locked: BooleanLike;
  has_card: BooleanLike;
  card_name: string | null;
  authenticated: BooleanLike;
  currency: string;
  account_security_level: number;
  view_screen: number;
  attempts_remaining: number;
  account_name?: string;
  account_number?: number;
  balance?: number;
  account_suspended?: BooleanLike;
  security_level?: number;
  transaction_logs?: Transaction[];
};

export const ATM = () => {
  const { act, data } = useBackend<Data>();
  const {
    machine_id,
    emagged,
    is_locked,
    has_card,
    card_name,
    authenticated,
    currency,
    account_security_level,
    view_screen,
    attempts_remaining,
    account_name,
    balance = 0,
    account_suspended,
    security_level,
    transaction_logs = [],
  } = data;

  const [accountNum, setAccountNum] = useState('');
  const [pin, setPin] = useState('');
  const [withdrawAmount, setWithdrawAmount] = useState('');
  const [transferTarget, setTransferTarget] = useState('');
  const [transferAmount, setTransferAmount] = useState('');
  const [transferPurpose, setTransferPurpose] = useState('Funds transfer');

  return (
    <Window title={machine_id} width={400} height={520}>
      <Window.Content scrollable>
        <Section title="Card Slot">
          {emagged ? (
            <NoticeBox danger>
              LOCKED — Unauthorized terminal access detected.
            </NoticeBox>
          ) : (
            <Stack align="center">
              <Stack.Item grow>
                {has_card ? card_name : 'No card inserted'}
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={has_card ? 'eject' : 'credit-card'}
                  onClick={() => act('insert_card')}
                >
                  {has_card ? 'Eject' : 'Insert Card'}
                </Button>
              </Stack.Item>
            </Stack>
          )}
        </Section>

        {!!is_locked && (
          <NoticeBox danger>
            Maximum PIN attempts exceeded. ATM temporarily disabled.
          </NoticeBox>
        )}

        {!authenticated && !emagged && !is_locked && (
          <Section title="Login">
            {account_security_level === 2 && (
              <NoticeBox>
                High security: card, account number, and PIN required.
              </NoticeBox>
            )}
            <LabeledList>
              <LabeledList.Item label="Account #">
                <Input
                  fluid
                  value={accountNum}
                  placeholder="Account number"
                  onChange={(val) => setAccountNum(val)}
                />
              </LabeledList.Item>
              {account_security_level > 0 && (
                <LabeledList.Item label="PIN">
                  <Input
                    fluid
                    value={pin}
                    placeholder="PIN"
                    onChange={(val) => setPin(val)}
                  />
                </LabeledList.Item>
              )}
            </LabeledList>
            <Box mt={1}>
              <Button
                fluid
                icon="sign-in-alt"
                disabled={!accountNum && !has_card}
                onClick={() =>
                  act('attempt_auth', {
                    account_num: accountNum,
                    account_pin: pin,
                  })
                }
              >
                Login ({attempts_remaining} attempt
                {attempts_remaining !== 1 ? 's' : ''} remaining)
              </Button>
            </Box>
          </Section>
        )}

        {!!authenticated && !!account_suspended && (
          <Section title={`Welcome, ${account_name}`}>
            <NoticeBox danger>
              This account has been suspended and its funds frozen.
            </NoticeBox>
            <Button icon="sign-out-alt" onClick={() => act('logout')}>
              Logout
            </Button>
          </Section>
        )}

        {!!authenticated && !account_suspended && view_screen === SCREEN_HOME && (
          <Section
            title={`Welcome, ${account_name}`}
            buttons={
              <Button icon="sign-out-alt" onClick={() => act('logout')}>
                Logout
              </Button>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Balance">
                <Box bold>
                  {currency}
                  {balance}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Amount">
                <Input
                  value={withdrawAmount}
                  placeholder="0"
                  onChange={(val) => setWithdrawAmount(val)}
                />
              </LabeledList.Item>
            </LabeledList>
            <Stack mt={1} mb={2}>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="coins"
                  disabled={!withdrawAmount || Number(withdrawAmount) <= 0}
                  onClick={() => act('withdraw', { amount: withdrawAmount })}
                >
                  Withdraw Cash
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="credit-card"
                  disabled={!withdrawAmount || Number(withdrawAmount) <= 0}
                  onClick={() => act('e_withdraw', { amount: withdrawAmount })}
                >
                  Withdraw Chargecard
                </Button>
              </Stack.Item>
            </Stack>
            <Stack vertical>
              <Stack.Item>
                <Button
                  fluid
                  icon="exchange-alt"
                  onClick={() => act('set_view', { screen: SCREEN_TRANSFER })}
                >
                  Transfer Funds
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="shield-alt"
                  onClick={() => act('set_view', { screen: SCREEN_SECURITY })}
                >
                  Change Security Level
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="list-alt"
                  onClick={() => act('set_view', { screen: SCREEN_LOGS })}
                >
                  View Transaction Log
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="print"
                  onClick={() => act('balance_statement')}
                >
                  Print Balance Statement
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        )}

        {!!authenticated && !account_suspended && view_screen === SCREEN_SECURITY && (
          <Section
            title="Account Security Level"
            buttons={
              <Button
                icon="arrow-left"
                onClick={() => act('set_view', { screen: SCREEN_HOME })}
              >
                Back
              </Button>
            }
          >
            {([0, 1, 2] as const).map((level) => (
              <Box key={level} mb={1}>
                <Button
                  fluid
                  selected={security_level === level}
                  onClick={() => act('change_security_level', { level })}
                >
                  {level === 0 &&
                    'Minimum — Account number or card required'}
                  {level === 1 &&
                    'Moderate — Account number and PIN required'}
                  {level === 2 &&
                    'Maximum — Card, account number, and PIN required'}
                </Button>
              </Box>
            ))}
          </Section>
        )}

        {!!authenticated && !account_suspended && view_screen === SCREEN_TRANSFER && (
          <Section
            title="Transfer Funds"
            buttons={
              <Button
                icon="arrow-left"
                onClick={() => act('set_view', { screen: SCREEN_HOME })}
              >
                Back
              </Button>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Balance">
                {currency}
                {balance}
              </LabeledList.Item>
              <LabeledList.Item label="Target Acct #">
                <Input
                  fluid
                  value={transferTarget}
                  placeholder="Account number"
                  onChange={(val) => setTransferTarget(val)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Amount">
                <Input
                  fluid
                  value={transferAmount}
                  placeholder="0"
                  onChange={(val) => setTransferAmount(val)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Purpose">
                <Input
                  fluid
                  value={transferPurpose}
                  onChange={(val) => setTransferPurpose(val)}
                />
              </LabeledList.Item>
            </LabeledList>
            <Box mt={1}>
              <Button
                fluid
                icon="paper-plane"
                disabled={!transferTarget || !transferAmount || Number(transferAmount) <= 0}
                onClick={() =>
                  act('transfer', {
                    target: transferTarget,
                    amount: transferAmount,
                    purpose: transferPurpose,
                  })
                }
              >
                Transfer {currency}
                {transferAmount || 0}
              </Button>
            </Box>
          </Section>
        )}

        {!!authenticated && !account_suspended && view_screen === SCREEN_LOGS && (
          <Section
            title="Transaction Logs"
            buttons={
              <>
                <Button icon="print" onClick={() => act('print_transaction')}>
                  Print
                </Button>
                <Button
                  icon="arrow-left"
                  onClick={() => act('set_view', { screen: SCREEN_HOME })}
                >
                  Back
                </Button>
              </>
            }
          >
            {transaction_logs.length === 0 ? (
              <NoticeBox>No transactions on record.</NoticeBox>
            ) : (
              transaction_logs.map((log, i) => (
                <Box
                  key={i}
                  mb={1}
                  p={1}
                  style={{ background: 'rgba(0,0,0,0.2)' }}
                >
                  <Stack>
                    <Stack.Item grow>
                      <Box bold>{log.purpose}</Box>
                      <Box color="label">
                        {log.date} {log.time}
                      </Box>
                      <Box color="label">Target: {log.target}</Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box bold>
                        {currency}
                        {log.amount}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Box>
              ))
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
