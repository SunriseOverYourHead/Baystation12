import { useState } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { CulturalPage } from './CulturalPage';
import { FlavorTextPage } from './FlavorTextPage';
import { LawsPage } from './LawsPage';
import { RecordsPage } from './RecordsPage';

type BackgroundTab = 'descriptions' | 'records' | 'culture' | 'laws';

export function BackgroundPage() {
  const [tab, setTab] = useState<BackgroundTab>('descriptions');

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Button
              selected={tab === 'descriptions'}
              onClick={() => setTab('descriptions')}
            >
              Descriptions
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={tab === 'records'}
              onClick={() => setTab('records')}
            >
              Records
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={tab === 'culture'}
              onClick={() => setTab('culture')}
            >
              Culture
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={tab === 'laws'}
              onClick={() => setTab('laws')}
            >
              Laws
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {tab === 'descriptions' && <FlavorTextPage />}
        {tab === 'records' && <RecordsPage />}
        {tab === 'culture' && <CulturalPage />}
        {tab === 'laws' && <LawsPage />}
      </Stack.Item>
    </Stack>
  );
}
