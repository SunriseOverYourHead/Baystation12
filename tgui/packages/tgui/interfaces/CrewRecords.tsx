import { Box, Button, NoticeBox, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RecordEntry = {
  name: string;
  rank: string;
  milrank: string;
  id: number;
};

type RecordField = {
  name: string;
  value: string;
  ID: number;
  access: BooleanLike;
  access_edit: BooleanLike;
  needs_big_box: BooleanLike;
};

type Data = {
  message: string | null;
  uid: number | null;
  pic_edit: BooleanLike;
  fields: RecordField[];
  all_records: RecordEntry[];
  creation: BooleanLike;
  dnasearch: BooleanLike;
  fingersearch: BooleanLike;
};

export const CrewRecords = () => {
  const { act, data } = useBackend<Data>();
  const {
    message,
    uid,
    pic_edit,
    fields = [],
    all_records = [],
    creation,
    dnasearch,
    fingersearch,
  } = data;

  return (
    <Window title="Crew Records" width={700} height={540}>
      <Window.Content scrollable>
        {!!message && (
          <NoticeBox>
            <Stack align="center">
              <Stack.Item grow>{message}</Stack.Item>
              <Stack.Item>
                <Button icon="times" onClick={() => act('clear_message')} />
              </Stack.Item>
            </Stack>
          </NoticeBox>
        )}
        {uid ? (
          <RecordDetail
            uid={uid}
            pic_edit={pic_edit}
            fields={fields}
            act={act}
          />
        ) : (
          <RecordList
            all_records={all_records}
            creation={creation}
            dnasearch={dnasearch}
            fingersearch={fingersearch}
            act={act}
          />
        )}
      </Window.Content>
    </Window>
  );
};

function RecordDetail(props: {
  uid: number;
  pic_edit: BooleanLike;
  fields: RecordField[];
  act: (action: string, params?: object) => void;
}) {
  const { uid, pic_edit, fields, act } = props;
  return (
    <Section
      title="Record Detail"
      buttons={
        <>
          <Button onClick={() => act('clear_active')}>Back</Button>
          <Button icon="print" onClick={() => act('print_active')}>
            Print
          </Button>
        </>
      }
    >
      <Stack align="center" justify="center" mb={1}>
        <Stack.Item>
          <img src={`front_${uid}.png`} width="128px" alt="Front" />
        </Stack.Item>
        <Stack.Item>
          <img src={`side_${uid}.png`} width="128px" alt="Side" />
        </Stack.Item>
      </Stack>
      {!!pic_edit && (
        <Stack mb={1}>
          <Stack.Item>
            <Button icon="pencil-alt" onClick={() => act('edit_photo_front')}>
              Edit Front
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button icon="pencil-alt" onClick={() => act('edit_photo_side')}>
              Edit Side
            </Button>
          </Stack.Item>
        </Stack>
      )}
      {fields
        .filter((f) => f.access)
        .map((field) => (
          <Stack key={field.ID} mb={0.5}>
            <Stack.Item width="160px" bold color="label">
              {field.access_edit ? (
                <Button
                  icon="pencil-alt"
                  color="transparent"
                  onClick={() => act('edit_field', { edit_field: field.ID })}
                >
                  {field.name}:
                </Button>
              ) : (
                `${field.name}:`
              )}
            </Stack.Item>
            <Stack.Item grow>
              {field.needs_big_box ? (
                <Box preserveWhitespace>{field.value}</Box>
              ) : (
                field.value
              )}
            </Stack.Item>
          </Stack>
        ))}
    </Section>
  );
}

function RecordList(props: {
  all_records: RecordEntry[];
  creation: BooleanLike;
  dnasearch: BooleanLike;
  fingersearch: BooleanLike;
  act: (action: string, params?: object) => void;
}) {
  const { all_records, creation, dnasearch, fingersearch, act } = props;
  return (
    <Section
      title="Crew Records"
      buttons={
        <>
          {!!creation && (
            <Button icon="file" onClick={() => act('new_record')}>
              New Record
            </Button>
          )}
          <Button icon="search" onClick={() => act('search', { search: 'Name' })}>
            Name Search
          </Button>
          {!!dnasearch && (
            <Button icon="search" onClick={() => act('search', { search: 'DNA' })}>
              DNA Search
            </Button>
          )}
          {!!fingersearch && (
            <Button icon="search" onClick={() => act('search', { search: 'Fingerprint' })}>
              Fingerprint Search
            </Button>
          )}
        </>
      }
    >
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Position</Table.Cell>
          <Table.Cell>Rank</Table.Cell>
        </Table.Row>
        {all_records.map((record) => (
          <Table.Row key={record.id} className="candystripe">
            <Table.Cell>
              <Button
                color="transparent"
                onClick={() => act('set_active', { set_active: record.id })}
              >
                {record.name}
              </Button>
            </Table.Cell>
            <Table.Cell>{record.rank}</Table.Cell>
            <Table.Cell>{record.milrank}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}
