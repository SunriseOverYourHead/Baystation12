import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  scanned_item: string;
  scanned_item_desc: string;
  last_scan_data: string;
  scan_progress: number;
  scanning: BooleanLike;
  scanner_seal_integrity: number;
  scanner_rpm: number;
  scanner_temperature: number;
  coolant_usage_rate: number;
  unused_coolant_abs: number;
  unused_coolant_per: number;
  coolant_purity: number;
  optimal_wavelength: number;
  maser_wavelength: number;
  maser_efficiency: number;
  radiation: number;
  rad_shield_on: BooleanLike;
};

export const GeoScanner = () => {
  const { act, data } = useBackend<Data>();
  const {
    scanned_item,
    scanned_item_desc,
    last_scan_data,
    scan_progress,
    scanning,
    scanner_seal_integrity,
    scanner_rpm,
    scanner_temperature,
    coolant_usage_rate,
    unused_coolant_abs,
    unused_coolant_per,
    coolant_purity,
    optimal_wavelength,
    maser_wavelength,
    maser_efficiency,
    radiation,
    rad_shield_on,
  } = data;

  const sealColor =
    scanner_seal_integrity < 33
      ? 'bad'
      : scanner_seal_integrity < 66
        ? 'average'
        : 'good';

  const tempColor =
    scanner_temperature > 1000
      ? 'bad'
      : scanner_temperature > 250
        ? 'average'
        : 'good';

  const radColor =
    radiation > 65 ? 'bad' : radiation > 15 ? 'average' : 'good';

  const coolantColor =
    unused_coolant_per < 33
      ? 'bad'
      : unused_coolant_per < 66
        ? 'average'
        : 'good';

  const purityColor =
    coolant_purity < 33 ? 'bad' : coolant_purity < 66 ? 'average' : 'good';

  const maserColor =
    maser_efficiency < 33 ? 'bad' : maser_efficiency < 66 ? 'average' : 'good';

  return (
    <Window title="High Res Radiocarbon Spectrometer" width={900} height={825}>
      <Window.Content scrollable>
        <Section title="Machine Status">
          <Stack mb={1}>
            <Stack.Item>
              <Button
                icon="signal"
                selected={!!scanning}
                onClick={() => act('scanItem')}
              >
                {scanning ? 'Halt Scan' : 'Begin Scan'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="eject"
                disabled={!scanned_item || !!scanning}
                onClick={() => act('ejectItem')}
              >
                Eject Item
              </Button>
            </Stack.Item>
          </Stack>
          <LabeledList>
            <LabeledList.Item label="Item">
              {scanned_item ? (
                <Box inline color="good">
                  {scanned_item}
                </Box>
              ) : (
                <Box inline color="bad">
                  No item inserted
                </Box>
              )}
            </LabeledList.Item>
            {!!scanned_item_desc && (
              <LabeledList.Item label="Heuristic analysis">
                <Box color="average">{scanned_item_desc}</Box>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        <Section title="Scanner">
          <LabeledList>
            <LabeledList.Item label="Scan progress">
              <ProgressBar value={scan_progress} maxValue={100} color="good">
                {scan_progress}%
              </ProgressBar>
              {scan_progress >= 100 && (
                <Box inline color="label" ml={1}>
                  Scan completed successfully.
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Vacuum seal integrity">
              <ProgressBar
                value={scanner_seal_integrity}
                maxValue={100}
                color={sealColor}
              >
                {scanner_seal_integrity}%
              </ProgressBar>
              {scanner_seal_integrity < 25 && (
                <NoticeBox mt={0.5}>
                  Warning! Vacuum seal breach will result in scan failure!
                </NoticeBox>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="MASER">
          <LabeledList>
            <LabeledList.Item label="MASER Efficiency">
              <ProgressBar
                value={maser_efficiency}
                maxValue={100}
                color={maserColor}
              >
                {maser_efficiency}%
              </ProgressBar>
              {maser_efficiency < 50 && (
                <Box inline color="label" ml={1}>
                  Match wavelengths to progress the scan.
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Optimal Wavelength">
              <ProgressBar value={optimal_wavelength} maxValue={10000} color="good">
                {optimal_wavelength} MHz
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Current Wavelength">
              <ProgressBar value={maser_wavelength} maxValue={10000} color="good">
                {maser_wavelength} MHz
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
          <Stack mt={1} justify="space-between">
            <Stack.Item>
              <Button onClick={() => act('maserWavelength', { value: -2 })}>
                -2 GHz
              </Button>
              <Button ml={1} onClick={() => act('maserWavelength', { value: -1 })}>
                -1 GHz
              </Button>
              <Button ml={1} onClick={() => act('maserWavelength', { value: -0.5 })}>
                -0.5 GHz
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('maserWavelength', { value: 0.5 })}>
                +0.5 GHz
              </Button>
              <Button ml={1} onClick={() => act('maserWavelength', { value: 1 })}>
                +1 GHz
              </Button>
              <Button ml={1} onClick={() => act('maserWavelength', { value: 2 })}>
                +2 GHz
              </Button>
            </Stack.Item>
          </Stack>
        </Section>

        <Section title="Environment / Internal">
          <LabeledList>
            <LabeledList.Item label="Centrifuge speed">
              <ProgressBar value={scanner_rpm} maxValue={1000} color="good">
                {scanner_rpm} RPM
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Internal temperature">
              <ProgressBar
                value={scanner_temperature}
                maxValue={1273}
                color={tempColor}
              >
                {scanner_temperature} K
              </ProgressBar>
              {scanner_temperature > 1000 && (
                <NoticeBox mt={0.5}>
                  Warning! Exceeding 1200K will result in scan failure!
                </NoticeBox>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Radiation">
          <LabeledList>
            <LabeledList.Item label="Ambient radiation">
              <ProgressBar value={radiation} maxValue={100} color={radColor}>
                {radiation} mSv
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
          <Stack mt={1} align="center">
            <Stack.Item>
              <Button
                icon="radiation"
                selected={!!rad_shield_on}
                color={rad_shield_on ? 'average' : undefined}
                onClick={() => act('toggle_rad_shield')}
              >
                {rad_shield_on
                  ? 'Disable Radiation Shielding'
                  : 'Enable Radiation Shielding'}
              </Button>
            </Stack.Item>
            {!!rad_shield_on && (
              <Stack.Item>
                <Box color="label">Shield blocking scanner.</Box>
              </Stack.Item>
            )}
          </Stack>
        </Section>

        <Section title="Cooling">
          <LabeledList>
            <LabeledList.Item label="Coolant remaining">
              <ProgressBar
                value={unused_coolant_per}
                maxValue={100}
                color={coolantColor}
              >
                {unused_coolant_abs} u
              </ProgressBar>
              {unused_coolant_per < 20 && (
                <NoticeBox mt={0.5}>Warning! Coolant stocks low!</NoticeBox>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Coolant flow rate">
              <ProgressBar value={coolant_usage_rate} maxValue={10} color="good">
                {coolant_usage_rate} u/s
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Coolant purity">
              <ProgressBar
                value={coolant_purity}
                maxValue={100}
                color={purityColor}
              >
                {coolant_purity}%
              </ProgressBar>
              {coolant_purity < 50 && (
                <NoticeBox mt={0.5}>
                  Warning! Check coolant for contaminants!
                </NoticeBox>
              )}
            </LabeledList.Item>
          </LabeledList>
          <Stack mt={1} justify="space-between">
            <Stack.Item>
              <Button onClick={() => act('coolantRate', { value: -10 })}>
                Min u/s
              </Button>
              <Button ml={1} onClick={() => act('coolantRate', { value: -3 })}>
                -3 u/s
              </Button>
              <Button ml={1} onClick={() => act('coolantRate', { value: -1 })}>
                -1 u/s
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('coolantRate', { value: 1 })}>
                +1 u/s
              </Button>
              <Button ml={1} onClick={() => act('coolantRate', { value: 3 })}>
                +3 u/s
              </Button>
              <Button ml={1} onClick={() => act('coolantRate', { value: 10 })}>
                Max u/s
              </Button>
            </Stack.Item>
          </Stack>
        </Section>

        <Section title="Latest Results">
          {last_scan_data ? (
            <Box
              style={{ whiteSpace: 'pre-wrap' }}
              dangerouslySetInnerHTML={{ __html: last_scan_data }}
            />
          ) : (
            <Box color="label">No scans on record.</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
