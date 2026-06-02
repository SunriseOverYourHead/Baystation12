import { Box, Button, NoticeBox, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FileEntry = {
  name: string;
  size: number;
};

type Data = {
  error: string | null;
  browsing: BooleanLike;
  files: FileEntry[];
  usbconnected: BooleanLike;
  usbfiles: FileEntry[];
  filename: string;
  filedata: string;
};

export const WordProcessor = () => {
  const { act, data } = useBackend<Data>();
  const { error, browsing } = data;

  return (
    <Window title="Word Processor" width={575} height={700}>
      <Window.Content scrollable>
        {error ? (
          <ErrorView act={act} error={error} />
        ) : browsing ? (
          <FileBrowserView act={act} data={data} />
        ) : (
          <EditorView act={act} data={data} />
        )}
      </Window.Content>
    </Window>
  );
};

function ErrorView(props: { act: Function; error: string }) {
  const { act, error } = props;
  return (
    <Section fill>
      <NoticeBox danger>
        An error has occurred: {error}
        <Box italic mt={1} color="label">
          Please try again. If the problem persists, contact your system administrator.
        </Box>
      </NoticeBox>
      <Button mt={1} onClick={() => act('PRG_backtomenu')}>Back to Menu</Button>
    </Section>
  );
}

function FileBrowserView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { files = [], usbconnected, usbfiles = [] } = data;
  return (
    <Section
      title="Open Document"
      buttons={<Button onClick={() => act('PRG_closebrowser')}>Back to Editor</Button>}
    >
      <Box bold mb={1}>Available documents (local):</Box>
      <FileTable files={files} act={act} />
      {!!usbconnected && (
        <>
          <Box bold mt={2} mb={1}>Available documents (portable device):</Box>
          <FileTable files={usbfiles} act={act} />
        </>
      )}
    </Section>
  );
}

function FileTable(props: { files: FileEntry[]; act: Function }) {
  const { files, act } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Name</Table.Cell>
        <Table.Cell collapsing>Size (GQ)</Table.Cell>
        <Table.Cell collapsing />
      </Table.Row>
      {files.map((f) => (
        <Table.Row key={f.name} className="candystripe">
          <Table.Cell>{f.name}</Table.Cell>
          <Table.Cell collapsing>{f.size} GQ</Table.Cell>
          <Table.Cell collapsing>
            <Button onClick={() => act('PRG_openfile', { PRG_openfile: f.name })}>Open</Button>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}

function EditorView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { filename, filedata } = data;
  return (
    <Section title={`Document: ${filename}`}>
      <Stack mb={1}>
        <Stack.Item>
          <Button onClick={() => act('PRG_newfile')}>New</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('PRG_loadmenu')}>Load</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('PRG_savefile')}>Save</Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('PRG_saveasfile')}>Save As</Button>
        </Stack.Item>
      </Stack>
      <Stack mb={1}>
        <Stack.Item>
          <Button icon="pencil-alt" onClick={() => act('PRG_editfile')}>Edit</Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!filedata}
            onClick={() => act('PRG_txtrpeview')}
          >
            Preview
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('PRG_taghelp')}>Formatting Help</Button>
        </Stack.Item>
        <Stack.Item>
          <Button icon="print" onClick={() => act('PRG_printfile')}>Print</Button>
        </Stack.Item>
      </Stack>
      <Box
        style={{ border: '1px solid #444', padding: '8px', minHeight: '200px' }}
        dangerouslySetInnerHTML={{ __html: filedata || '' }}
      />
    </Section>
  );
}
