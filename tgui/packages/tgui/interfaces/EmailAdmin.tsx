import { Box, Button, NoticeBox, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type EmailAccount = {
  login: string;
  uid: number;
};

type EmailMessage = {
  title: string;
  source: string;
  recipient: string;
  timestamp: string;
  uid: number;
};

type SkillFail = {
  key: string;
  value: string;
};

type Data = {
  error: string | null;
  skill_fail: SkillFail[] | null;
  msg_title: string | null;
  msg_body: string;
  msg_timestamp: string;
  msg_source: string;
  msg_recipient: string;
  current_account: string | null;
  cur_suspended: BooleanLike;
  messages: EmailMessage[];
  messagecount: number;
  accounts: EmailAccount[];
  accountcount: number;
  terminal: BooleanLike;
};

export const EmailAdmin = () => {
  const { act, data } = useBackend<Data>();
  const {
    error, skill_fail, msg_title, current_account, terminal,
  } = data;

  return (
    <Window title="Email Administration Utility" width={600} height={450}>
      <Window.Content scrollable>
        {error ? (
          <ErrorView act={act} error={error} />
        ) : skill_fail ? (
          <SkillFailView data={data} />
        ) : msg_title ? (
          <MessageDetail act={act} data={data} />
        ) : current_account ? (
          <AccountDetail act={act} data={data} />
        ) : (
          <AccountList act={act} data={data} />
        )}
        {!!terminal && (
          <Box mt={1}>
            <Button onClick={() => act('PC_terminal')}>Activate Terminal</Button>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

function ErrorView(props: { act: Function; error: string }) {
  const { act, error } = props;
  return (
    <Section fill>
      <NoticeBox danger>{error}</NoticeBox>
      <Button mt={1} onClick={() => act('back')}>Return</Button>
    </Section>
  );
}

function SkillFailView(props: { data: Data }) {
  const { skill_fail = [] } = props.data;
  return (
    <Section fill title="System Data">
      {skill_fail.map((item, i) => (
        <Stack key={i} mb={0.5}>
          <Stack.Item width="200px" bold color="label">{item.key}</Stack.Item>
          <Stack.Item grow>{item.value}</Stack.Item>
        </Stack>
      ))}
    </Section>
  );
}

function MessageDetail(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { msg_title, msg_body, msg_source, msg_recipient, msg_timestamp } = data;
  return (
    <Section
      title={msg_title}
      buttons={<Button onClick={() => act('back')}>Return</Button>}
    >
      <Stack vertical>
        <Stack.Item>
          <Box><Box as="span" bold color="label">From: </Box>{msg_source}</Box>
        </Stack.Item>
        <Stack.Item>
          <Box><Box as="span" bold color="label">To: </Box>{msg_recipient}</Box>
        </Stack.Item>
        <Stack.Item>
          <Box><Box as="span" bold color="label">Received: </Box>{msg_timestamp}</Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            mt={1}
            style={{ border: '1px solid #444', padding: '6px' }}
            dangerouslySetInnerHTML={{ __html: msg_body }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function AccountDetail(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { current_account, cur_suspended, messages = [], messagecount } = data;
  return (
    <>
      <Section
        title={`Account: ${current_account}`}
        buttons={
          <>
            <Button
              color={cur_suspended ? 'good' : 'bad'}
              onClick={() => act('ban')}
            >
              {cur_suspended ? 'Unsuspend' : 'Suspend'}
            </Button>
            <Button onClick={() => act('changepass')}>Set Password</Button>
            <Button onClick={() => act('back')}>Return</Button>
          </>
        }
      >
        <Box>Status: <Box as="span" bold color={cur_suspended ? 'bad' : 'good'}>{cur_suspended ? 'Suspended' : 'Normal'}</Box></Box>
      </Section>
      <Section title="Messages">
        {messagecount ? (
          <Table>
            <Table.Row header>
              <Table.Cell>Source</Table.Cell>
              <Table.Cell>Recipient</Table.Cell>
              <Table.Cell>Title</Table.Cell>
              <Table.Cell>Received at</Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {messages.map((msg) => (
              <Table.Row key={msg.uid} className="candystripe">
                <Table.Cell>{msg.source}</Table.Cell>
                <Table.Cell>{msg.recipient}</Table.Cell>
                <Table.Cell>{msg.title}</Table.Cell>
                <Table.Cell>{msg.timestamp}</Table.Cell>
                <Table.Cell collapsing>
                  <Button onClick={() => act('viewmail', { viewmail: msg.uid })}>View</Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        ) : (
          <Box bold color="average">No messages found in selected account.</Box>
        )}
      </Section>
    </>
  );
}

function AccountList(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { accounts = [] } = data;
  return (
    <Section
      title="NTNet Email Administration System"
      buttons={
        <Button icon="plus" onClick={() => act('newaccount')}>Create New Account</Button>
      }
    >
      <Box italic mb={1} color="label">SECURE SYSTEM - Have your identification ready</Box>
      <Table>
        <Table.Row header>
          <Table.Cell>Email Address</Table.Cell>
        </Table.Row>
        {accounts.map((acc) => (
          <Table.Row key={acc.uid} className="candystripe">
            <Table.Cell>
              <Button
                color="transparent"
                fluid
                onClick={() => act('viewaccount', { viewaccount: acc.uid })}
              >
                {acc.login}
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}
