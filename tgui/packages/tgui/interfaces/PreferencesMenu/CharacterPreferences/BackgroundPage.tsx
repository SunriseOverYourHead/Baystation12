import { useState } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { CulturalPage } from './CulturalPage';
import { ErpDirectoryPage } from './ErpDirectoryPage';
import { FlavorTextPage } from './FlavorTextPage';
import { IdentityMediaPage } from './IdentityMediaPage';
import { LawsPage } from './LawsPage';
import { RecordsPage } from './RecordsPage';

type BackgroundTab =
  | 'descriptions'
  | 'records'
  | 'identity_media'
  | 'erp_directory'
  | 'culture'
  | 'laws';

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
              selected={tab === 'identity_media'}
              onClick={() => setTab('identity_media')}
            >
              Identity Media
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={tab === 'erp_directory'}
              onClick={() => setTab('erp_directory')}
            >
              ERP &amp; Directory
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
        {tab === 'identity_media' && <IdentityMediaPage />}
        {tab === 'erp_directory' && <ErpDirectoryPage />}
        {tab === 'culture' && <CulturalPage />}
        {tab === 'laws' && <LawsPage />}
      </Stack.Item>
    </Stack>
  );
}
