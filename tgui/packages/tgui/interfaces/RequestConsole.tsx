import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const RCS_MAINMENU = 0;
const RCS_RQASSIST = 1;
const RCS_RQSUPPLY = 2;
const RCS_SENDINFO = 3;
const RCS_SENTPASS = 4;
const RCS_SENTFAIL = 5;
const RCS_VIEWMSGS = 6;
const RCS_MESSAUTH = 7;
const RCS_ANNOUNCE = 8;

type Message = string;

type Data = {
  department: string;
  screen: number;
  message_log: Message[];
  newmessagepriority: number;
  silent: BooleanLike;
  announcementConsole: BooleanLike;
  assist_dept: string[];
  supply_dept: string[];
  info_dept: string[];
  message: string;
  recipient: string;
  priortiy: number;
  msgStamped: string;
  msgVerified: string;
  announceAuth: BooleanLike;
};

export const RequestConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    department,
    screen,
    message_log,
    newmessagepriority,
    silent,
    announcementConsole,
    assist_dept,
    supply_dept,
    info_dept,
    message,
    recipient,
    msgStamped,
    msgVerified,
    announceAuth,
  } = data;

  const newMessageColor =
    newmessagepriority === 2
      ? 'bad'
      : newmessagepriority === 1
        ? 'average'
        : 'default';

  const renderScreen = () => {
    switch (screen) {
      case RCS_MAINMENU:
        return (
          <Section title="Main Menu">
            <Stack vertical>
              {!!assist_dept.length && (
                <Stack.Item>
                  <Button
                    fluid
                    icon="hand-paper"
                    content="Request Assistance"
                    onClick={() => act('setScreen', { setScreen: RCS_RQASSIST })}
                  />
                </Stack.Item>
              )}
              {!!supply_dept.length && (
                <Stack.Item>
                  <Button
                    fluid
                    icon="box"
                    content="Request Supplies"
                    onClick={() => act('setScreen', { setScreen: RCS_RQSUPPLY })}
                  />
                </Stack.Item>
              )}
              {!!info_dept.length && (
                <Stack.Item>
                  <Button
                    fluid
                    icon="info-circle"
                    content="Relay Information"
                    onClick={() => act('setScreen', { setScreen: RCS_SENDINFO })}
                  />
                </Stack.Item>
              )}
              <Stack.Item>
                <Button
                  fluid
                  icon={newmessagepriority ? 'envelope' : 'envelope-open'}
                  color={newMessageColor}
                  content={
                    newmessagepriority
                      ? `View Messages (${newmessagepriority === 2 ? 'High Priority' : 'New'})`
                      : 'View Messages'
                  }
                  onClick={() => act('setScreen', { setScreen: RCS_VIEWMSGS })}
                />
              </Stack.Item>
              {!!announcementConsole && (
                <Stack.Item>
                  <Button
                    fluid
                    icon="bullhorn"
                    content="Send Announcement"
                    onClick={() =>
                      act('setScreen', { setScreen: RCS_ANNOUNCE })
                    }
                  />
                </Stack.Item>
              )}
              <Stack.Item>
                <Button
                  fluid
                  icon={silent ? 'volume-mute' : 'volume-up'}
                  content={silent ? 'Unmute Alerts' : 'Mute Alerts'}
                  onClick={() => act('toggleSilent')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        );

      case RCS_RQASSIST:
        return (
          <Section
            title="Request Assistance"
            buttons={
              <Button
                icon="arrow-left"
                content="Back"
                onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
              />
            }
          >
            <Stack vertical>
              {assist_dept.map((dept) => (
                <Stack.Item key={dept}>
                  <Button
                    fluid
                    content={dept}
                    onClick={() =>
                      act('write', { write: dept, priority: '2' })
                    }
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        );

      case RCS_RQSUPPLY:
        return (
          <Section
            title="Request Supplies"
            buttons={
              <Button
                icon="arrow-left"
                content="Back"
                onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
              />
            }
          >
            <Stack vertical>
              {supply_dept.map((dept) => (
                <Stack.Item key={dept}>
                  <Button
                    fluid
                    content={dept}
                    onClick={() =>
                      act('write', { write: dept, priority: '1' })
                    }
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        );

      case RCS_SENDINFO:
        return (
          <Section
            title="Relay Information"
            buttons={
              <Button
                icon="arrow-left"
                content="Back"
                onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
              />
            }
          >
            <Stack vertical>
              {info_dept.map((dept) => (
                <Stack.Item key={dept}>
                  <Button
                    fluid
                    content={dept}
                    onClick={() =>
                      act('write', { write: dept, priority: '0' })
                    }
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        );

      case RCS_MESSAUTH:
        return (
          <Section
            title="Message Authentication"
            buttons={
              <Button
                icon="arrow-left"
                content="Back"
                onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
              />
            }
          >
            <LabeledList>
              <LabeledList.Item label="To">{recipient}</LabeledList.Item>
              <LabeledList.Item label="Message">{message}</LabeledList.Item>
              <LabeledList.Item label="Verified">
                {msgVerified ? (
                  <Box
                    dangerouslySetInnerHTML={{ __html: msgVerified }}
                  />
                ) : (
                  'Swipe an ID card to verify'
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Stamped">
                {msgStamped ? (
                  <Box
                    dangerouslySetInnerHTML={{ __html: msgStamped }}
                  />
                ) : (
                  'Use a stamp to stamp this message'
                )}
              </LabeledList.Item>
            </LabeledList>
            <Button
              mt={1}
              icon="paper-plane"
              content="Send Message"
              onClick={() => act('department', { department: recipient })}
            />
          </Section>
        );

      case RCS_SENTPASS:
        return (
          <Section title="Message Sent">
            <Box color="good">Message sent successfully.</Box>
            <Button
              mt={1}
              icon="home"
              content="Return to Main Menu"
              onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
            />
          </Section>
        );

      case RCS_SENTFAIL:
        return (
          <Section title="Send Failed">
            <Box color="bad">Failed to send message. No server detected.</Box>
            <Button
              mt={1}
              icon="home"
              content="Return to Main Menu"
              onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
            />
          </Section>
        );

      case RCS_VIEWMSGS:
        return (
          <Section
            title="Message Log"
            buttons={
              <Button
                icon="arrow-left"
                content="Back"
                onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
              />
            }
          >
            {message_log.length === 0 ? (
              <Box color="average">No messages.</Box>
            ) : (
              <Stack vertical>
                {message_log.map((msg, i) => (
                  <Stack.Item key={i}>
                    <Box
                      dangerouslySetInnerHTML={{ __html: msg }}
                      mb={0.5}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            )}
          </Section>
        );

      case RCS_ANNOUNCE:
        return (
          <Section
            title="Department Announcement"
            buttons={
              <Button
                icon="arrow-left"
                content="Back"
                onClick={() => act('setScreen', { setScreen: RCS_MAINMENU })}
              />
            }
          >
            {!announceAuth ? (
              <Box color="average">
                Swipe an authorized ID card to authenticate.
              </Box>
            ) : (
              <Stack vertical>
                <Stack.Item>
                  <Box>{message || 'No message written yet.'}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="edit"
                    content="Write Announcement"
                    onClick={() => act('writeAnnouncement')}
                  />
                  <Button
                    icon="bullhorn"
                    content="Send Announcement"
                    color="bad"
                    disabled={!message}
                    onClick={() => act('sendAnnouncement')}
                  />
                </Stack.Item>
              </Stack>
            )}
          </Section>
        );

      default:
        return null;
    }
  };

  return (
    <Window title={`${department} Request Console`} width={520} height={410}>
      <Window.Content scrollable>{renderScreen()}</Window.Content>
    </Window>
  );
};
