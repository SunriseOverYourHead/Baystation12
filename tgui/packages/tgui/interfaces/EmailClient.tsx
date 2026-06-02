import { Box, Button, NoticeBox, ProgressBar, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type EmailMessage = {
  title: string;
  body: string;
  source: string;
  timestamp: string;
  uid: number;
};

type Data = {
  error: string | null;
  downloading: BooleanLike;
  down_filename: string;
  down_progress: number;
  down_size: number;
  down_speed: number;
  current_account: string | null;
  notification_mute: BooleanLike;
  addressbook: BooleanLike;
  accounts: Array<{ name: string; job: string; login: string }>;
  new_message: BooleanLike;
  msg_title: string;
  msg_body: string;
  msg_recipient: string;
  msg_hasattachment: BooleanLike;
  msg_attachment_filename: string;
  msg_attachment_size: number;
  cur_title: string | null;
  cur_body: string;
  cur_source: string;
  cur_timestamp: string;
  cur_uid: number;
  cur_hasattachment: BooleanLike;
  cur_attachment_filename: string;
  cur_attachment_size: number;
  folder: string;
  source_label: string;
  label_inbox: string;
  label_outbox: string;
  label_spam: string;
  label_deleted: string;
  messages: EmailMessage[];
  messagecount: number;
  stored_login: string;
  stored_password: string;
};

export const EmailClient = () => {
  const { act, data } = useBackend<Data>();
  const { error, downloading, current_account } = data;

  return (
    <Window title="Email Client" width={600} height={450}>
      <Window.Content scrollable>
        {error ? (
          <ErrorView act={act} error={error} />
        ) : downloading ? (
          <DownloadView act={act} data={data} />
        ) : current_account ? (
          <AccountView act={act} data={data} />
        ) : (
          <LoginView act={act} data={data} />
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
      <Button mt={1} onClick={() => act('reset')}>Return</Button>
    </Section>
  );
}

function DownloadView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  return (
    <Section title="Downloading Attachment">
      <Box mb={1}>File: {data.down_filename}</Box>
      <ProgressBar value={data.down_progress} minValue={0} maxValue={data.down_size} mb={1}>
        {data.down_progress} / {data.down_size} GQ
      </ProgressBar>
      <Box mb={1}>Speed: {data.down_speed} GQ/s</Box>
      <Button color="bad" onClick={() => act('canceldownload')}>Cancel Download</Button>
    </Section>
  );
}

function AccountView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const {
    current_account, notification_mute, addressbook, new_message,
    cur_title, folder,
  } = data;

  return (
    <>
      <Section
        title={`Logged in as: ${current_account}`}
        buttons={
          <>
            <Button icon="envelope" onClick={() => act('new_message')}>New Message</Button>
            <Button icon="lock" onClick={() => act('changepassword')}>Change Password</Button>
            <Button
              icon={notification_mute ? 'volume-mute' : 'volume-up'}
              onClick={() => act('mute')}
            >
              {notification_mute ? 'Unmute' : 'Mute'}
            </Button>
            <Button icon="bell" onClick={() => act('set_notification')}>Notification</Button>
            <Button icon="sign-out-alt" color="bad" onClick={() => act('logout')}>Log Out</Button>
          </>
        }
      />
      {addressbook ? (
        <AddressBook act={act} data={data} />
      ) : new_message ? (
        <ComposeView act={act} data={data} />
      ) : cur_title ? (
        <MessageView act={act} data={data} />
      ) : (
        <FolderView act={act} data={data} />
      )}
    </>
  );
}

function AddressBook(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { accounts = [] } = data;
  return (
    <Section
      title="Address Book"
      buttons={
        <>
          <Button onClick={() => act('close_addressbook')}>Back</Button>
          <Button icon="pencil-alt" onClick={() => act('edit_recipient')}>Enter Email</Button>
        </>
      }
    >
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Job</Table.Cell>
          <Table.Cell>Email</Table.Cell>
        </Table.Row>
        {accounts.map((acc) => (
          <Table.Row key={acc.login} className="candystripe">
            <Table.Cell>{acc.name}</Table.Cell>
            <Table.Cell>{acc.job}</Table.Cell>
            <Table.Cell>
              <Button color="transparent" onClick={() => act('set_recipient', { set_recipient: acc.login })}>
                {acc.login}
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

function ComposeView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const {
    msg_title, msg_body, msg_recipient,
    msg_hasattachment, msg_attachment_filename, msg_attachment_size,
  } = data;
  return (
    <Section
      title="New Message"
      buttons={
        <>
          <Button icon="paper-plane" color="good" onClick={() => act('send')}>Send</Button>
          <Button onClick={() => act('cancel')}>Cancel</Button>
        </>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item width="100px" bold color="label">Title:</Stack.Item>
            <Stack.Item grow>
              <Box>{msg_title || <Box color="average">(none)</Box>}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button icon="pencil-alt" onClick={() => act('edit_title')} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item width="100px" bold color="label">Recipient:</Stack.Item>
            <Stack.Item grow>
              <Box>{msg_recipient || <Box color="average">(none)</Box>}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button icon="address-book" onClick={() => act('addressbook')} />
              <Button icon="pencil-alt" onClick={() => act('edit_recipient')} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack align="baseline">
            <Stack.Item width="100px" bold color="label">Message:</Stack.Item>
            <Stack.Item grow>
              <Box
                style={{ minHeight: '80px', border: '1px solid #444', padding: '4px' }}
                dangerouslySetInnerHTML={{ __html: msg_body || '' }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button icon="pencil-alt" onClick={() => act('edit_body')} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {!!msg_hasattachment && (
          <Stack.Item>
            <Box bold color="label">Attachment: <Box as="span" color="white">{msg_attachment_filename} ({msg_attachment_size} GQ)</Box></Box>
          </Stack.Item>
        )}
        <Stack.Item>
          <Button onClick={() => act('addattachment')}>Add Attachment</Button>
          {!!msg_hasattachment && (
            <Button color="bad" onClick={() => act('remove_attachment')}>Remove Attachment</Button>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function MessageView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const {
    cur_title, cur_body, cur_source, cur_timestamp, cur_uid,
    cur_hasattachment, cur_attachment_filename, cur_attachment_size,
  } = data;
  return (
    <Section
      title={cur_title}
      buttons={
        <>
          <Button onClick={() => act('reply', { reply: cur_uid })}>Reply</Button>
          <Button onClick={() => act('forward', { forward: cur_uid })}>Forward</Button>
          <Button onClick={() => act('save', { save: cur_uid })}>Save to Disk</Button>
          {!!cur_hasattachment && (
            <Button onClick={() => act('downloadattachment')}>Save Attachment</Button>
          )}
          <Button color="bad" onClick={() => act('delete', { delete: cur_uid })}>Delete</Button>
          <Button onClick={() => act('cancel', { cancel: cur_uid })}>Close</Button>
        </>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Box><Box as="span" bold color="label">From: </Box>{cur_source}</Box>
        </Stack.Item>
        <Stack.Item>
          <Box><Box as="span" bold color="label">Received: </Box>{cur_timestamp}</Box>
        </Stack.Item>
        {!!cur_hasattachment && (
          <Stack.Item>
            <Box><Box as="span" bold color="label">Attachment: </Box>{cur_attachment_filename} ({cur_attachment_size} GQ)</Box>
          </Stack.Item>
        )}
        <Stack.Item>
          <Box
            mt={1}
            style={{ border: '1px solid #444', padding: '6px' }}
            dangerouslySetInnerHTML={{ __html: cur_body }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function FolderView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const {
    folder, label_inbox, label_outbox, label_spam, label_deleted,
    messages = [], messagecount, source_label,
  } = data;
  return (
    <Section
      title="Mailbox"
      buttons={
        <>
          <Button selected={folder === 'Inbox'} onClick={() => act('set_folder', { set_folder: 'Inbox' })}>{label_inbox}</Button>
          <Button selected={folder === 'Sent'} onClick={() => act('set_folder', { set_folder: 'Sent' })}>{label_outbox}</Button>
          <Button selected={folder === 'Spam'} onClick={() => act('set_folder', { set_folder: 'Spam' })}>{label_spam}</Button>
          <Button selected={folder === 'Deleted'} onClick={() => act('set_folder', { set_folder: 'Deleted' })}>{label_deleted}</Button>
        </>
      }
    >
      {messagecount ? (
        <Table>
          <Table.Row header>
            <Table.Cell>{source_label}</Table.Cell>
            <Table.Cell>Title</Table.Cell>
            <Table.Cell>Received at</Table.Cell>
            <Table.Cell collapsing />
          </Table.Row>
          {messages.map((msg) => (
            <Table.Row key={msg.uid} className="candystripe">
              <Table.Cell>{msg.source}</Table.Cell>
              <Table.Cell>{msg.title}</Table.Cell>
              <Table.Cell>{msg.timestamp}</Table.Cell>
              <Table.Cell collapsing>
                <Button icon="trash" color="bad" onClick={() => act('delete', { delete: msg.uid })} />
                <Button icon="reply" onClick={() => act('reply', { reply: msg.uid })} />
                <Button icon="share" onClick={() => act('forward', { forward: msg.uid })} />
                <Button icon="eye" onClick={() => act('view', { view: msg.uid })} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Box bold color="average">No messages found in selected folder.</Box>
      )}
    </Section>
  );
}

function LoginView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { stored_login, stored_password } = data;
  return (
    <Section title="NTNet Email System">
      <Box bold mb={1}>Welcome. Please log in.</Box>
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item width="140px" bold color="label">Email Address:</Stack.Item>
            <Stack.Item grow>{stored_login || <Box color="average">(none)</Box>}</Stack.Item>
            <Stack.Item>
              <Button icon="pencil-alt" onClick={() => act('edit_login')}>Edit</Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item width="140px" bold color="label">Password:</Stack.Item>
            <Stack.Item grow>{stored_password || <Box color="average">(none)</Box>}</Stack.Item>
            <Stack.Item>
              <Button icon="pencil-alt" onClick={() => act('edit_password')}>Edit</Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button icon="sign-in-alt" color="good" onClick={() => act('login')}>Log In</Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
