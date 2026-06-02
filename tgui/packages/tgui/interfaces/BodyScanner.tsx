import { Box, Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type Data = {
  scanEnabled: BooleanLike;
  isCompatible: BooleanLike;
  printEnabled: BooleanLike;
  eraseEnabled: BooleanLike;
  pushEnabled: BooleanLike;
  html_scan_header: string;
  html_scan_health: string;
  html_scan_body: string;
};

export const BodyScanner = () => {
  const { act, data } = useBackend<Data>();
  const {
    scanEnabled,
    isCompatible,
    printEnabled,
    eraseEnabled,
    pushEnabled,
    html_scan_header,
    html_scan_health,
    html_scan_body,
  } = data;

  return (
    <Window title="Body Scanner" width={600} height={800}>
      <Window.Content scrollable>
        <Section>
          <Button
            icon="search"
            disabled={!scanEnabled || !isCompatible}
            color={scanEnabled && isCompatible ? 'default' : 'bad'}
            onClick={() => act('scan')}
          >
            {!scanEnabled
              ? 'Scanner Empty'
              : !isCompatible
                ? 'Incompatible Lifeform'
                : 'Scan Occupant'}
          </Button>
          <Button
            icon="print"
            disabled={!printEnabled}
            onClick={() => act('print')}
          >
            Print Scan
          </Button>
          <Button
            icon="eraser"
            disabled={!eraseEnabled}
            onClick={() => act('erase')}
          >
            Erase Scan
          </Button>
          <Button
            icon="share-square"
            disabled={!pushEnabled}
            onClick={() => act('push')}
          >
            Push Scan to Displays
          </Button>
        </Section>
        {!!html_scan_header && (
          <Section>
            <Box dangerouslySetInnerHTML={{ __html: sanitizeText(html_scan_header) }} />
          </Section>
        )}
        {!!html_scan_health && (
          <Section>
            <Box dangerouslySetInnerHTML={{ __html: sanitizeText(html_scan_health) }} />
          </Section>
        )}
        {!!html_scan_body && (
          <Section>
            <Box dangerouslySetInnerHTML={{ __html: sanitizeText(html_scan_body) }} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
