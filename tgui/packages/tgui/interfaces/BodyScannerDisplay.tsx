import { Box, Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type Scan = {
  name: string;
  time: string;
};

type Data = {
  scans: Scan[];
  selected: number;
  scan_header: string;
  scan_health: string;
  scan_body: string;
};

export const BodyScannerDisplay = () => {
  const { act, data } = useBackend<Data>();
  const { scans, selected, scan_header, scan_health, scan_body } = data;

  return (
    <Window title="Body Scan Display Console" width={600} height={800}>
      <Window.Content scrollable>
        <Section title="Scans">
          <Table>
            <Table.Row header>
              <Table.Cell>Patient Name</Table.Cell>
              <Table.Cell>Scan Time</Table.Cell>
              <Table.Cell>Action</Table.Cell>
            </Table.Row>
            {scans.length === 0 ? (
              <Table.Row>
                <Table.Cell colSpan={3} textAlign="center">
                  There are no scans available.
                </Table.Cell>
              </Table.Row>
            ) : (
              scans.map((scan, index) => (
                <Table.Row key={index}>
                  <Table.Cell>{scan.name}</Table.Cell>
                  <Table.Cell>{scan.time}</Table.Cell>
                  <Table.Cell>
                    <Button
                      icon="eye"
                      selected={selected === index + 1}
                      onClick={() => act('view', { view: index + 1 })}
                    >
                      View
                    </Button>
                    <Button
                      icon="trash"
                      color="bad"
                      onClick={() => act('delete', { delete: index + 1 })}
                    />
                  </Table.Cell>
                </Table.Row>
              ))
            )}
          </Table>
        </Section>
        {selected > 0 && (
          <>
            {!!scan_header && (
              <Section>
                <Box dangerouslySetInnerHTML={{ __html: sanitizeText(scan_header) }} />
              </Section>
            )}
            {!!scan_health && (
              <Section>
                <Box dangerouslySetInnerHTML={{ __html: sanitizeText(scan_health) }} />
              </Section>
            )}
            {!!scan_body && (
              <Section>
                <Box dangerouslySetInnerHTML={{ __html: sanitizeText(scan_body) }} />
              </Section>
            )}
          </>
        )}
      </Window.Content>
    </Window>
  );
};
