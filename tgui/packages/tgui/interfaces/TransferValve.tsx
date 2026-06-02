import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  attachmentOne: string | null;
  attachmentTwo: string | null;
  valveAttachment: string | null;
  valveOpen: BooleanLike;
  armed: BooleanLike;
};

export const TransferValve = () => {
  const { act, data } = useBackend<Data>();
  const { attachmentOne, attachmentTwo, valveAttachment, valveOpen, armed } =
    data;

  const bothTanks = !!attachmentOne && !!attachmentTwo;

  return (
    <Window title="Tank Transfer Valve" width={460} height={280}>
      <Window.Content>
        <Section title="Attachments">
          <LabeledList>
            <LabeledList.Item label="Attachment One">
              {attachmentOne ?? <i>None</i>}
              <Button
                ml={1}
                icon="eject"
                disabled={!attachmentOne || !!armed}
                onClick={() => act('eject_tank', { tankone: 1 })}
              >
                Remove
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Attachment Two">
              {attachmentTwo ?? <i>None</i>}
              <Button
                ml={1}
                icon="eject"
                disabled={!attachmentTwo || !!armed}
                onClick={() => act('eject_tank', { tanktwo: 1 })}
              >
                Remove
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Valve Attachment">
              {valveAttachment ?? <i>None</i>}
              {!!valveAttachment && (
                <>
                  <Button
                    ml={1}
                    icon="eject"
                    disabled={!!armed}
                    onClick={() => act('remove_device')}
                  >
                    Remove
                  </Button>
                  <Button
                    icon="eye"
                    onClick={() => act('view_device')}
                  >
                    View
                  </Button>
                  <Button
                    icon="bolt"
                    disabled={!armed}
                    color="bad"
                    onClick={() => act('trigger_device')}
                  >
                    Trigger
                  </Button>
                  <Button
                    icon="exclamation-triangle"
                    color={armed ? 'bad' : 'average'}
                    selected={!!armed}
                    onClick={() => act('arm_device')}
                  >
                    {armed ? 'Armed' : 'Arm'}
                  </Button>
                </>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Valve Status">
          <LabeledList>
            <LabeledList.Item label="Valve">
              <Button
                selected={!!valveOpen}
                disabled={!bothTanks}
                color={valveOpen ? 'good' : 'bad'}
                onClick={() => act('toggle_valve')}
              >
                {valveOpen ? 'Open' : 'Closed'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
