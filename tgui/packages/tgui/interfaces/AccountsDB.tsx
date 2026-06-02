import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Account = {
  account_number: number;
  owner_name: string;
  suspended: BooleanLike;
  account_index: number;
};

type Transaction = {
  date: string;
  time: string;
  target_name: string;
  purpose: string;
  amount: number;
  source_terminal: string;
};

type Data = {
  machine_id: string;
  id_inserted: BooleanLike;
  id_card: string | null;
  access_level: BooleanLike;
  creating_new_account: BooleanLike;
  detailed_account_view: BooleanLike;
  station_account_number: number;
  accounts: Account[];
  // Detailed view fields
  account_number?: number;
  owner_name?: string;
  money?: number;
  suspended?: BooleanLike;
  transactions?: Transaction[];
};

export const AccountsDB = () => {
  const { act, data } = useBackend<Data>();
  const {
    machine_id,
    id_inserted,
    id_card,
    access_level,
    creating_new_account,
    detailed_account_view,
    station_account_number,
    accounts = [],
    account_number,
    owner_name,
    money,
    suspended,
    transactions = [],
  } = data;

  const [holderName, setHolderName] = useState('');
  const [startingFunds, setStartingFunds] = useState('0');

  return (
    <Window title="Accounts Uplink Terminal" width={400} height={640}>
      <Window.Content scrollable>
        <Section title="Terminal">
          <LabeledList>
            <LabeledList.Item label="Machine">{machine_id}</LabeledList.Item>
            <LabeledList.Item label="ID Card">
              <Stack align="center">
                <Stack.Item grow>{id_card || '-----'}</Stack.Item>
                <Stack.Item>
                  <Button
                    icon={id_inserted ? 'eject' : 'id-card'}
                    onClick={() => act('insert_card')}
                  >
                    {id_inserted ? 'Eject' : 'Insert'}
                  </Button>
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
          </LabeledList>
        </Section>

        {!access_level ? (
          <NoticeBox>
            {id_inserted
              ? 'Insufficient access level.'
              : 'Insert an authorized ID card to access records.'}
          </NoticeBox>
        ) : creating_new_account ? (
          <Section title="Create Account">
            <LabeledList>
              <LabeledList.Item label="Account Holder">
                <Input
                  fluid
                  value={holderName}
                  placeholder="Name..."
                  onChange={(val) => setHolderName(val)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Initial Deposit">
                <Input
                  fluid
                  value={startingFunds}
                  placeholder="0"
                  onChange={(val) => setStartingFunds(val)}
                />
              </LabeledList.Item>
            </LabeledList>
            <Box mt={1}>
              <Button
                icon="check"
                color="good"
                onClick={() =>
                  act('finalise_create_account', {
                    holder_name: holderName,
                    starting_funds: startingFunds,
                  })
                }
              >
                Create
              </Button>
              <Button
                icon="times"
                ml={1}
                onClick={() => act('view_accounts_list')}
              >
                Cancel
              </Button>
            </Box>
          </Section>
        ) : detailed_account_view ? (
          <>
            <Section title="Account Details">
              <Stack mb={1}>
                <Stack.Item>
                  <Button
                    icon="home"
                    onClick={() => act('view_accounts_list')}
                  >
                    Home
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button icon="print" onClick={() => act('print')}>
                    Print
                  </Button>
                </Stack.Item>
              </Stack>
              <LabeledList>
                <LabeledList.Item label="Account Number">
                  #{account_number}
                </LabeledList.Item>
                <LabeledList.Item label="Holder">
                  {owner_name}
                </LabeledList.Item>
                <LabeledList.Item label="Balance">${money}</LabeledList.Item>
                <LabeledList.Item label="Status">
                  <Box inline color={suspended ? 'bad' : 'good'}>
                    {suspended ? 'Suspended' : 'Active'}
                  </Box>
                  <Button
                    ml={1}
                    icon="ban"
                    color={suspended ? 'good' : 'bad'}
                    onClick={() => act('toggle_suspension')}
                  >
                    {suspended ? 'Unsuspend' : 'Suspend'}
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            {account_number !== station_account_number && (
              <Section title="CentCom Administrator">
                <LabeledList>
                  <LabeledList.Item label="Payroll">
                    <Button
                      icon="exchange-alt"
                      color="bad"
                      onClick={() => act('revoke_payroll')}
                    >
                      Revoke
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            )}
            <Section title="Transactions">
              {transactions.length === 0 ? (
                <NoticeBox>No transactions on record for today.</NoticeBox>
              ) : (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Timestamp</Table.Cell>
                    <Table.Cell>Target</Table.Cell>
                    <Table.Cell>Reason</Table.Cell>
                    <Table.Cell>Value</Table.Cell>
                    <Table.Cell>Terminal</Table.Cell>
                  </Table.Row>
                  {transactions.map((t, i) => (
                    <Table.Row key={i} className="candystripe">
                      <Table.Cell>
                        {t.date} {t.time}
                      </Table.Cell>
                      <Table.Cell>{t.target_name}</Table.Cell>
                      <Table.Cell>{t.purpose}</Table.Cell>
                      <Table.Cell>{t.amount}</Table.Cell>
                      <Table.Cell>{t.source_terminal}</Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </>
        ) : (
          <Section title="NanoTrasen Accounts">
            <Stack mb={1}>
              <Stack.Item>
                <Button
                  icon="plus"
                  onClick={() => act('create_account')}
                >
                  New Account
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button icon="print" onClick={() => act('print')}>
                  Print List
                </Button>
              </Stack.Item>
            </Stack>
            {accounts.length === 0 ? (
              <NoticeBox>No accounts available.</NoticeBox>
            ) : (
              <Table>
                <Table.Row header>
                  <Table.Cell>Account #</Table.Cell>
                  <Table.Cell>Holder</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                </Table.Row>
                {accounts.map((acc) => (
                  <Table.Row
                    key={acc.account_index}
                    className="candystripe"
                  >
                    <Table.Cell>
                      <Button
                        color="transparent"
                        onClick={() =>
                          act('view_account_detail', {
                            account_index: acc.account_index,
                          })
                        }
                      >
                        #{acc.account_number}
                      </Button>
                    </Table.Cell>
                    <Table.Cell>{acc.owner_name}</Table.Cell>
                    <Table.Cell color={acc.suspended ? 'bad' : undefined}>
                      {acc.suspended ? 'SUSPENDED' : ''}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
