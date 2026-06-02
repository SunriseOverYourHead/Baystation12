import { Box, Button, NoticeBox, Section, Stack, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FileEntry = {
  name: string;
  type: string;
  size: number;
  undeletable: BooleanLike;
};

type Data = {
  error: string | null;
  filename: string | null;
  filedata: string | null;
  files: FileEntry[];
  usbconnected: BooleanLike;
  usbfiles: FileEntry[];
};

export const FileManager = () => {
  const { act, data } = useBackend<Data>();
  const { error, filename } = data;

  return (
    <Window title="NTOS File Manager" width={600} height={700}>
      <Window.Content scrollable>
        {error ? (
          <ErrorView act={act} error={error} />
        ) : filename ? (
          <FileView act={act} data={data} />
        ) : (
          <FileListView act={act} data={data} />
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
      <Button mt={1} onClick={() => act('PRG_closefile')}>Back to Menu</Button>
    </Section>
  );
}

function FileView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { filename, filedata } = data;
  return (
    <Section
      title={`Viewing: ${filename}`}
      buttons={
        <>
          <Button onClick={() => act('PRG_closefile')}>Close</Button>
          <Button icon="pencil-alt" onClick={() => act('PRG_edit')}>Edit</Button>
          <Button icon="print" onClick={() => act('PRG_printfile')}>Print</Button>
        </>
      }
    >
      <Box
        style={{ border: '1px solid #444', padding: '8px', minHeight: '200px' }}
        dangerouslySetInnerHTML={{ __html: filedata || '' }}
      />
    </Section>
  );
}

function FileListView(props: { act: Function; data: Data }) {
  const { act, data } = props;
  const { files = [], usbconnected, usbfiles = [] } = data;
  return (
    <>
      <Section
        title="Available Files (Local)"
        buttons={
          <Button icon="file" onClick={() => act('PRG_newtextfile')}>New Data File</Button>
        }
      >
        <FilesTable files={files} act={act} showUsb={usbconnected} isUsb={false} />
      </Section>
      {!!usbconnected && (
        <Section title="Available Files (Portable Device)">
          <FilesTable files={usbfiles} act={act} showUsb={usbconnected} isUsb={true} />
        </Section>
      )}
    </>
  );
}

function FilesTable(props: {
  files: FileEntry[];
  act: Function;
  showUsb: BooleanLike;
  isUsb: boolean;
}) {
  const { files, act, showUsb, isUsb } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>File Name</Table.Cell>
        <Table.Cell collapsing>Type</Table.Cell>
        <Table.Cell collapsing>Size (GQ)</Table.Cell>
        <Table.Cell collapsing>Operations</Table.Cell>
      </Table.Row>
      {files.map((f) => (
        <Table.Row key={f.name} className="candystripe">
          <Table.Cell>{f.name}</Table.Cell>
          <Table.Cell collapsing>.{f.type}</Table.Cell>
          <Table.Cell collapsing>{f.size} GQ</Table.Cell>
          <Table.Cell collapsing>
            {!isUsb && (
              <>
                <Button onClick={() => act('PRG_openfile', { PRG_openfile: f.name })}>View</Button>
                <Button
                  color="bad"
                  disabled={!!f.undeletable}
                  onClick={() => act('PRG_deletefile', { PRG_deletefile: f.name })}
                >
                  Delete
                </Button>
                <Button
                  disabled={!!f.undeletable}
                  onClick={() => act('PRG_rename', { PRG_rename: f.name })}
                >
                  Rename
                </Button>
                <Button
                  disabled={!!f.undeletable}
                  onClick={() => act('PRG_clone', { PRG_clone: f.name })}
                >
                  Clone
                </Button>
                {!!showUsb && (
                  <Button
                    disabled={!!f.undeletable}
                    onClick={() => act('PRG_copytousb', { PRG_copytousb: f.name })}
                  >
                    Export
                  </Button>
                )}
              </>
            )}
            {isUsb && (
              <>
                <Button
                  color="bad"
                  disabled={!!f.undeletable}
                  onClick={() => act('PRG_usbdeletefile', { PRG_usbdeletefile: f.name })}
                >
                  Delete
                </Button>
                <Button
                  disabled={!!f.undeletable}
                  onClick={() => act('PRG_copyfromusb', { PRG_copyfromusb: f.name })}
                >
                  Import
                </Button>
              </>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}
