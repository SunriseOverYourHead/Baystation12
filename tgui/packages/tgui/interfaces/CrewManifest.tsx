import { Box, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  crew_manifest: string;
};

export const CrewManifest = () => {
  const { data } = useBackend<Data>();
  const { crew_manifest } = data;

  return (
    <Window title="Crew Manifest" width={450} height={600}>
      <Window.Content scrollable>
        <Section fill>
          <Box
            dangerouslySetInnerHTML={{ __html: crew_manifest }}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
