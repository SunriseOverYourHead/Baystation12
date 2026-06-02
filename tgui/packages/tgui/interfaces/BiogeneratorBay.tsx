import { Box, Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const BG_READY = 0;
const BG_PROCESSING = 1;
const BG_NO_BEAKER = 2;
const BG_COMPLETE = 3;
const BG_EMPTY = 4;

type Product = {
  product_index: number;
  name: string;
  cost: number;
};

type ProductType = {
  type_name: string;
  products: Product[];
};

type Data = {
  state: number;
  points?: number;
  types?: ProductType[];
};

export const BiogeneratorBay = () => {
  const { act, data } = useBackend<Data>();
  const { state, points, types } = data;

  return (
    <Window title="Biogenerator" width={440} height={600}>
      <Window.Content scrollable>
        <Section
          title="Status"
          buttons={
            state !== BG_NO_BEAKER && (
              <Button icon="eject" onClick={() => act('detach')}>
                Eject Beaker
              </Button>
            )
          }
        >
          {state === BG_READY && (
            <Box>
              Available points: <b>{points}</b>
              <Button ml={2} icon="play" onClick={() => act('activate')}>
                Process
              </Button>
            </Box>
          )}
          {state === BG_PROCESSING && (
            <Box color="average">Processing ingredients...</Box>
          )}
          {state === BG_NO_BEAKER && (
            <Box color="bad">No beaker loaded.</Box>
          )}
          {state === BG_COMPLETE && (
            <Box>
              <Box color="good">Product dispensed.</Box>
              <Button mt={1} icon="undo" onClick={() => act('return')}>
                Return
              </Button>
            </Box>
          )}
          {state === BG_EMPTY && (
            <Box color="bad">No ingredients to process.</Box>
          )}
        </Section>
        {state === BG_READY &&
          !!types &&
          types.map((productType) => (
            <Section key={productType.type_name} title={productType.type_name}>
              <Table>
                <Table.Row header>
                  <Table.Cell>Product</Table.Cell>
                  <Table.Cell collapsing>Cost</Table.Cell>
                  <Table.Cell collapsing />
                </Table.Row>
                {productType.products.map((product) => (
                  <Table.Row key={product.product_index}>
                    <Table.Cell>{product.name}</Table.Cell>
                    <Table.Cell
                      collapsing
                      color={points! >= product.cost ? 'good' : 'bad'}
                    >
                      {product.cost}
                    </Table.Cell>
                    <Table.Cell collapsing>
                      <Button
                        disabled={points! < product.cost}
                        onClick={() =>
                          act('create', {
                            type: productType.type_name,
                            product_index: product.product_index,
                          })
                        }
                      >
                        Create
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          ))}
      </Window.Content>
    </Window>
  );
};
