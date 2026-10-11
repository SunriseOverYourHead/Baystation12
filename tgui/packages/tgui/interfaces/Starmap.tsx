import { useEffect, useMemo, useRef, useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type StarSystem = {
  ref: string;
  name: string;
  is_current: BooleanLike;
  adjacent: BooleanLike;
  explored: BooleanLike;
  cached: BooleanLike;
  connections: string[];
};

type ReturnToPortState =
  | 'idle'
  | 'can_cancel'
  | 'in_progress'
  | 'emergency_active'
  | 'controller_cooldown'
  | 'unavailable';

type Data = {
  drive_status: string;
  jumping: BooleanLike;
  in_transit: BooleanLike;
  current_ref: string;
  cooldown_remaining: number;
  cooldown_total: number;
  jump_target_name: string | null;
  jump_time_remaining: number;
  jump_phase_total: number;
  systems: StarSystem[];
  return_to_port_state: ReturnToPortState;
  return_to_port_button_cooldown_remaining: number;
  return_to_port_button_cooldown_total: number;
  return_to_port_locked_remaining: number;
};

const statusColor = (status: string) => {
  if (status === 'READY') return 'good';
  if (status === 'DAMAGED') return 'average';
  return 'bad';
};

const systemStatus = (system: StarSystem) => {
  if (system.is_current) return 'Current position';
  if (!system.explored) return 'Unexplored';
  if (system.cached) return 'Charted (dormant)';
  return 'Charted';
};

const formatDuration = (seconds: number) => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
};

// --- Graph layout / pathfinding -------------------------------------------------------------
// The backend only tells us who's connected to whom, not where anything "is" - there's no
// concept of coordinates for a star system. So positions are computed here: current system in
// the centre, everything else arranged in concentric rings by how many hops away it is (plain
// BFS), evenly spaced around each ring. Nodes can still be dragged afterwards (see dragOffsets
// in Starmap()) - this is only the starting/"Center" layout.

type Point = { x: number; y: number };

type Interaction =
  | { kind: 'node'; ref: string; lastX: number; lastY: number }
  | {
      kind: 'pan';
      startX: number;
      startY: number;
      lastX: number;
      lastY: number;
      moved: boolean;
    };

const RING_SPACING = 90;
const CANVAS_PAD = 70;
const VIEWPORT_WIDTH = 540;
const VIEWPORT_HEIGHT = 560;
const NODE_R = 11;
const MIN_ZOOM = 0.35;
const MAX_ZOOM = 2.5;

const clamp = (value: number, min: number, max: number) =>
  Math.min(max, Math.max(min, value));

function buildEdges(systems: StarSystem[]): Record<string, string[]> {
  const edges: Record<string, string[]> = {};
  for (const system of systems) {
    edges[system.ref] = system.connections || [];
  }
  return edges;
}

function bfsLayers(
  edges: Record<string, string[]>,
  startRef: string,
): Record<string, number> {
  const layer: Record<string, number> = { [startRef]: 0 };
  const queue = [startRef];
  while (queue.length) {
    const ref = queue.shift()!;
    for (const next of edges[ref] || []) {
      if (layer[next] === undefined) {
        layer[next] = layer[ref] + 1;
        queue.push(next);
      }
    }
  }
  return layer;
}

function shortestPath(
  edges: Record<string, string[]>,
  from: string,
  to: string,
): string[] {
  if (!from || !to) return [];
  if (from === to) return [from];
  const prev: Record<string, string> = {};
  const visited = new Set([from]);
  const queue = [from];
  while (queue.length) {
    const ref = queue.shift()!;
    if (ref === to) break;
    for (const next of edges[ref] || []) {
      if (!visited.has(next)) {
        visited.add(next);
        prev[next] = ref;
        queue.push(next);
      }
    }
  }
  if (!visited.has(to)) return [];
  const path = [to];
  let cur = to;
  while (cur !== from) {
    cur = prev[cur];
    path.push(cur);
  }
  return path.reverse();
}

type Layout = {
  positions: Record<string, Point>;
  size: number;
  maxLayer: number;
};

function computeLayout(
  systems: StarSystem[],
  edges: Record<string, string[]>,
  currentRef: string,
): Layout {
  const positions: Record<string, Point> = {};
  if (!systems.length || !currentRef) {
    return { positions, size: VIEWPORT_WIDTH, maxLayer: 0 };
  }

  const layer = bfsLayers(edges, currentRef);
  let maxLayer = 0;
  for (const system of systems) {
    if (layer[system.ref] !== undefined) {
      maxLayer = Math.max(maxLayer, layer[system.ref]);
    }
  }
  // Anything unreachable from current (shouldn't normally happen) gets stranded one ring out.
  for (const system of systems) {
    if (layer[system.ref] === undefined) {
      layer[system.ref] = maxLayer + 1;
    }
  }
  maxLayer = Math.max(
    maxLayer,
    ...systems.map((system) => layer[system.ref]),
  );

  const size = Math.max(
    VIEWPORT_WIDTH,
    VIEWPORT_HEIGHT,
    maxLayer * RING_SPACING * 2 + CANVAS_PAD * 2,
  );
  const centre = size / 2;

  const byLayer: Record<number, string[]> = {};
  for (const system of systems) {
    const l = layer[system.ref];
    (byLayer[l] ??= []).push(system.ref);
  }

  for (const [layerKey, refs] of Object.entries(byLayer)) {
    const l = Number(layerKey);
    if (l === 0) {
      positions[refs[0]] = { x: centre, y: centre };
      continue;
    }
    const radius = l * RING_SPACING;
    refs.forEach((ref, i) => {
      const angle = (2 * Math.PI * i) / refs.length - Math.PI / 2;
      positions[ref] = {
        x: centre + radius * Math.cos(angle),
        y: centre + radius * Math.sin(angle),
      };
    });
  }

  return { positions, size, maxLayer };
}

// --- Edges ---------------------------------------------------------------------------------
// Plain straight lines, trimmed to end exactly on each node's circumference facing the other
// node - not the tgui-core `Connections` component, which curves everything as if it were a
// left-to-right dependency graph (fine for e.g. MCDependencyDebug, wrong here: with nodes in
// every direction from each other, that curve made every line appear to enter from the left
// regardless of where the other node actually was).

function trimToEdge(from: Point, to: Point): { from: Point; to: Point } {
  const dx = to.x - from.x;
  const dy = to.y - from.y;
  const dist = Math.sqrt(dx * dx + dy * dy) || 1;
  const ux = dx / dist;
  const uy = dy / dist;
  return {
    from: { x: from.x + ux * NODE_R, y: from.y + uy * NODE_R },
    to: { x: to.x - ux * NODE_R, y: to.y - uy * NODE_R },
  };
}

function EdgeLines(props: { edges: { from: Point; to: Point; color: string }[] }) {
  return (
    <svg
      width="100%"
      height="100%"
      style={{
        position: 'absolute',
        pointerEvents: 'none',
        overflow: 'visible',
      }}
    >
      {props.edges.map((edge, i) => (
        <line
          key={i}
          x1={edge.from.x}
          y1={edge.from.y}
          x2={edge.to.x}
          y2={edge.to.y}
          className={`color-stroke-${edge.color}`}
          strokeWidth={1.5}
        />
      ))}
    </svg>
  );
}

// --- Graph node --------------------------------------------------------------------------

type GraphNodeProps = {
  system: StarSystem;
  point: Point;
  color: 'blue' | 'green' | 'grey';
  dimmed: boolean;
  selected: boolean;
  onSelect: () => void;
  onDragStart: (ref: string, event: any) => void;
};

function GraphNode(props: GraphNodeProps) {
  const { system, point, color, dimmed, selected, onSelect, onDragStart } =
    props;

  return (
    <Box
      position="absolute"
      left={`${point.x - NODE_R}px`}
      top={`${point.y - NODE_R}px`}
      width={`${NODE_R * 2}px`}
      textAlign="center"
      style={{
        cursor: 'grab',
        opacity: dimmed ? 0.5 : 1,
        userSelect: 'none',
        zIndex: selected ? 2 : 1,
      }}
      title={system.name}
      onMouseDown={(event: any) => {
        event.stopPropagation();
        onSelect();
        onDragStart(system.ref, event);
      }}
    >
      <svg
        width={NODE_R * 2}
        height={NODE_R * 2}
        style={{ display: 'block', margin: '0 auto' }}
      >
        <circle
          cx={NODE_R}
          cy={NODE_R}
          r={selected ? NODE_R - 2 : NODE_R - 3}
          className={`color-fill-${color}`}
          stroke={selected ? 'white' : 'rgba(0, 0, 0, 0.5)'}
          strokeWidth={selected ? 2.5 : 1}
        />
      </svg>
      <Box
        fontSize="0.8em"
        color={selected ? 'white' : 'label'}
        style={{
          whiteSpace: 'nowrap',
          transform: 'translateX(-50%)',
          marginLeft: `${NODE_R}px`,
        }}
      >
        {system.name}
      </Box>
    </Box>
  );
}

// --- Main interface ------------------------------------------------------------------------

export const Starmap = () => {
  const { act, data } = useBackend<Data>();
  const {
    drive_status,
    jumping,
    in_transit,
    current_ref,
    cooldown_remaining = 0,
    cooldown_total = 0,
    jump_target_name,
    jump_time_remaining = 0,
    jump_phase_total = 0,
    systems = [],
    return_to_port_state,
    return_to_port_button_cooldown_remaining = 0,
    return_to_port_locked_remaining = 0,
  } = data;

  const onCooldown = cooldown_remaining > 0;
  const readiness = cooldown_total - cooldown_remaining;
  const onButtonCooldown = return_to_port_button_cooldown_remaining > 0;
  const returnToPortLocked = return_to_port_locked_remaining > 0;

  const [search, setSearch] = useState('');
  const [selectedRef, setSelectedRef] = useState<string | null>(null);
  const [dragOffsets, setDragOffsets] = useState<Record<string, Point>>({});
  // Pan (screen pixels) + zoom (scale factor) applied to the whole canvas via a single CSS transform - lets the
  // background be dragged to look around, and the wheel to zoom, independent of node positions themselves.
  const [view, setView] = useState<{ zoom: number; pan: Point }>({
    zoom: 1,
    pan: { x: 0, y: 0 },
  });

  const viewportRef = useRef<HTMLDivElement | null>(null);
  // Mirrors `view` for the mousemove/wheel handlers below, which are attached once on mount and would otherwise
  // close over a stale zoom value.
  const viewRef = useRef(view);
  viewRef.current = view;

  const interaction = useRef<Interaction | null>(null);

  const systemByRef = useMemo(() => {
    const map: Record<string, StarSystem> = {};
    for (const system of systems) map[system.ref] = system;
    return map;
  }, [systems]);

  const edges = useMemo(() => buildEdges(systems), [systems]);

  const layout = useMemo(
    () => computeLayout(systems, edges, current_ref),
    [systems, edges, current_ref],
  );

  const centerView = () => {
    setDragOffsets({});
    const base = layout.positions[current_ref];
    setView({
      zoom: 1,
      pan: base
        ? { x: VIEWPORT_WIDTH / 2 - base.x, y: VIEWPORT_HEIGHT / 2 - base.y }
        : { x: 0, y: 0 },
    });
  };

  // Follow the ship: re-centre automatically whenever we actually arrive somewhere new (a fresh
  // jump target, a Return to Port arrival, or just opening the console for the first time).
  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(centerView, [current_ref]);

  const selectedSystem = selectedRef ? systemByRef[selectedRef] : null;

  const pathToSelected = useMemo(
    () =>
      selectedRef ? shortestPath(edges, current_ref, selectedRef) : [],
    [edges, current_ref, selectedRef],
  );
  const pathSet = useMemo(() => new Set(pathToSelected), [pathToSelected]);

  const query = search.trim().toLowerCase();
  const isVisible = (system: StarSystem) => {
    if (!query) return true;
    if (system.name.toLowerCase().includes(query)) return true;
    if (system.ref === selectedRef) return true;
    if (pathSet.has(system.ref)) return true;
    return false;
  };

  const nodeColor = (system: StarSystem): 'blue' | 'green' | 'grey' => {
    if (system.is_current) return 'blue';
    if (system.adjacent) return 'green';
    return 'grey';
  };

  const visibleSystems = systems.filter(isVisible);
  const visibleRefs = new Set(visibleSystems.map((system) => system.ref));

  // Rendered position of a node = its base ring-layout position plus whatever it's been dragged by. Used for
  // both the nodes themselves and the edges between them, so edges always follow a dragged node instead of
  // staying anchored to its pre-drag position.
  const pointFor = (ref: string): Point | null => {
    const base = layout.positions[ref];
    if (!base) return null;
    const offset = dragOffsets[ref] || { x: 0, y: 0 };
    return { x: base.x + offset.x, y: base.y + offset.y };
  };

  const edgeLines = useMemo(() => {
    const drawn = new Set<string>();
    const lines: { from: Point; to: Point; color: string }[] = [];
    for (const system of visibleSystems) {
      const from = pointFor(system.ref);
      if (!from) continue;
      for (const otherRef of system.connections || []) {
        if (!visibleRefs.has(otherRef)) continue;
        const key = [system.ref, otherRef].sort().join('|');
        if (drawn.has(key)) continue;
        drawn.add(key);
        const to = pointFor(otherRef);
        if (!to) continue;
        const onSelectedPath =
          pathSet.has(system.ref) && pathSet.has(otherRef);
        lines.push({
          ...trimToEdge(from, to),
          color: onSelectedPath ? 'yellow' : 'grey',
        });
      }
    }
    return lines;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [visibleSystems, layout, dragOffsets, pathSet]);

  const handleNodeDragStart = (ref: string, event: any) => {
    interaction.current = { kind: 'node', ref, lastX: event.screenX, lastY: event.screenY };
  };

  const handleBackgroundMouseDown = (event: any) => {
    interaction.current = {
      kind: 'pan',
      startX: event.screenX,
      startY: event.screenY,
      lastX: event.screenX,
      lastY: event.screenY,
      moved: false,
    };
  };

  // A JSX onWheel prop is attached passively by React (for scroll perf), so preventDefault()
  // there is silently ignored and the wheel gesture still scrolls the outer window. Attaching a
  // real, non-passive listener directly to the viewport (see the effect below) is the only way
  // to actually stop that.
  const handleWheel = (event: WheelEvent) => {
    event.preventDefault();
    event.stopPropagation();
    const rect = viewportRef.current?.getBoundingClientRect();
    if (!rect) return;
    const mx = event.clientX - rect.left;
    const my = event.clientY - rect.top;
    setView((prev) => {
      const newZoom = clamp(
        prev.zoom * (event.deltaY > 0 ? 0.9 : 1.1),
        MIN_ZOOM,
        MAX_ZOOM,
      );
      const cx = (mx - prev.pan.x) / prev.zoom;
      const cy = (my - prev.pan.y) / prev.zoom;
      return {
        zoom: newZoom,
        pan: { x: mx - cx * newZoom, y: my - cy * newZoom },
      };
    });
  };

  useEffect(() => {
    const el = viewportRef.current;
    if (!el) return;
    el.addEventListener('wheel', handleWheel, { passive: false });
    return () => el.removeEventListener('wheel', handleWheel);
  }, []);

  const zoomBy = (factor: number) => {
    setView((prev) => {
      const newZoom = clamp(prev.zoom * factor, MIN_ZOOM, MAX_ZOOM);
      const cx = VIEWPORT_WIDTH / 2 / prev.zoom - prev.pan.x / prev.zoom;
      const cy = VIEWPORT_HEIGHT / 2 / prev.zoom - prev.pan.y / prev.zoom;
      return {
        zoom: newZoom,
        pan: {
          x: VIEWPORT_WIDTH / 2 - cx * newZoom,
          y: VIEWPORT_HEIGHT / 2 - cy * newZoom,
        },
      };
    });
  };

  useEffect(() => {
    const onMouseMove = (event: MouseEvent) => {
      const drag = interaction.current;
      if (!drag) return;
      const dx = event.screenX - drag.lastX;
      const dy = event.screenY - drag.lastY;
      if (drag.kind === 'node') {
        const zoom = viewRef.current.zoom;
        interaction.current = { ...drag, lastX: event.screenX, lastY: event.screenY };
        setDragOffsets((prev) => {
          const current = prev[drag.ref] || { x: 0, y: 0 };
          return {
            ...prev,
            [drag.ref]: {
              x: current.x + dx / zoom,
              y: current.y + dy / zoom,
            },
          };
        });
      } else {
        const moved =
          drag.moved ||
          Math.abs(event.screenX - drag.startX) > 3 ||
          Math.abs(event.screenY - drag.startY) > 3;
        interaction.current = {
          ...drag,
          lastX: event.screenX,
          lastY: event.screenY,
          moved,
        };
        setView((prev) => ({
          ...prev,
          pan: { x: prev.pan.x + dx, y: prev.pan.y + dy },
        }));
      }
    };
    const onMouseUp = () => {
      const drag = interaction.current;
      if (drag?.kind === 'pan' && !drag.moved) {
        // No real dragging happened - treat it as a plain click on empty background.
        setSelectedRef(null);
      }
      interaction.current = null;
    };
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);
    return () => {
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }, []);

  const canJump =
    !!selectedSystem &&
    !selectedSystem.is_current &&
    !!selectedSystem.adjacent &&
    !jumping &&
    drive_status === 'READY' &&
    !onCooldown;

  const routeHint =
    selectedSystem && !selectedSystem.is_current && !selectedSystem.adjacent
      ? pathToSelected.length > 1
        ? `No direct route - ${pathToSelected.length - 1} hops via ${pathToSelected
            .slice(1, -1)
            .map((ref) => systemByRef[ref]?.name || '?')
            .join(', ') || systemByRef[pathToSelected[1]]?.name}`
        : 'No known route to this system.'
      : null;

  return (
    <Window title="Galaxy Map" width={980} height={720}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="380px">
            <Box style={{ overflowY: 'auto', overscrollBehavior: 'contain' }} height="100%">
              <Section title="Bluespace Drive">
                <LabeledList>
                  <LabeledList.Item label="Status">
                    <Box color={statusColor(drive_status)} bold>
                      {drive_status}
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Sequencer">
                    {jumping ? (
                      <ProgressBar
                        value={jump_phase_total - jump_time_remaining}
                        minValue={0}
                        maxValue={jump_phase_total || 1}
                      >
                        {in_transit ? 'In transit' : 'Spooling up'}
                        {jump_target_name ? ` — ${jump_target_name}` : ''} (
                        {formatDuration(jump_time_remaining)})
                      </ProgressBar>
                    ) : (
                      <Box color="good">Idle</Box>
                    )}
                  </LabeledList.Item>
                  {!!jumping && !in_transit && (
                    <LabeledList.Item label="Abort">
                      <Button
                        icon="ban"
                        color="bad"
                        onClick={() => act('cancel_jump')}
                      >
                        Cancel Jump
                      </Button>
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item label="Recharge">
                    <ProgressBar
                      value={readiness}
                      minValue={0}
                      maxValue={cooldown_total}
                      ranges={{
                        bad: [0, cooldown_total * 0.5],
                        good: [cooldown_total * 0.5, cooldown_total],
                      }}
                    >
                      {onCooldown
                        ? formatDuration(cooldown_remaining)
                        : 'Ready'}
                    </ProgressBar>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
              <Section title="Known Systems">
                <Input
                  fluid
                  placeholder="Search systems..."
                  value={search}
                  onChange={setSearch}
                />
                <Box mt={1} bold color="label">
                  System List
                </Box>
                {/* A plain scrolling div, not Section's own `scrollable` (which wasn't
                    actually producing a scrollbar nested this deep) - overscrollBehavior
                    stops a scroll that hits the top/bottom of this list from chaining into
                    the window behind it. */}
                <Box
                  style={{
                    overflowY: 'auto',
                    overscrollBehavior: 'contain',
                    border: '1px solid rgba(255, 255, 255, 0.15)',
                    background: 'rgba(0, 0, 0, 0.1)',
                  }}
                  height="260px"
                >
                  {visibleSystems.map((system) => (
                    <Box
                      key={system.ref}
                      p={0.5}
                      style={{
                        cursor: 'pointer',
                        background:
                          system.ref === selectedRef
                            ? 'rgba(255, 255, 255, 0.1)'
                            : undefined,
                      }}
                      onClick={() => setSelectedRef(system.ref)}
                    >
                      <Box
                        bold={!!system.is_current}
                        color={nodeColor(system)}
                      >
                        {system.name}
                      </Box>
                      <Box color="label" fontSize="0.85em">
                        {systemStatus(system)}
                      </Box>
                    </Box>
                  ))}
                  {!visibleSystems.length && (
                    <Box color="label" p={0.5}>
                      No systems match your search.
                    </Box>
                  )}
                </Box>
                <Box mt={1}>
                  <LabeledList>
                    <LabeledList.Item label="Selected">
                      {selectedSystem ? selectedSystem.name : '—'}
                    </LabeledList.Item>
                    {selectedSystem && (
                      <LabeledList.Item label="Status">
                        {systemStatus(selectedSystem)}
                      </LabeledList.Item>
                    )}
                    {routeHint && (
                      <LabeledList.Item label="Route">
                        <Box color="label">{routeHint}</Box>
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                  <Stack mt={1}>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="bolt"
                        disabled={!canJump}
                        onClick={() =>
                          selectedRef && act('jump', { target: selectedRef })
                        }
                      >
                        Jump
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Box>
              </Section>
              <Section title="Return to Port">
                {return_to_port_state === 'emergency_active' && (
                  <Box color="bad">
                    Unavailable - an emergency evacuation is already in
                    progress.
                  </Box>
                )}
                {return_to_port_state === 'controller_cooldown' && (
                  <Box color="average">
                    The return to port sequencer is still resetting from a
                    prior attempt. Try again shortly.
                  </Box>
                )}
                {return_to_port_state === 'unavailable' && (
                  <Box color="bad">No evacuation controller detected.</Box>
                )}
                {(return_to_port_state === 'idle' ||
                  return_to_port_state === 'can_cancel' ||
                  return_to_port_state === 'in_progress') && (
                  <Box>
                    {return_to_port_state === 'idle' && (
                      <Button
                        icon="flag-checkered"
                        disabled={onButtonCooldown || returnToPortLocked}
                        onClick={() => act('return_to_port')}
                      >
                        Initiate Return to Port
                      </Button>
                    )}
                    {return_to_port_state === 'idle' && returnToPortLocked && (
                      <Box color="label">
                        Locked - available in{' '}
                        {formatDuration(return_to_port_locked_remaining)}.
                      </Box>
                    )}
                    {return_to_port_state === 'can_cancel' && (
                      <Button
                        icon="ban"
                        color="bad"
                        disabled={onButtonCooldown}
                        onClick={() => act('cancel_return_to_port')}
                      >
                        Cancel Return to Port
                      </Button>
                    )}
                    {return_to_port_state === 'in_progress' && (
                      <Box color="average">
                        Return to port under way - past the point of no
                        return.
                      </Box>
                    )}
                    {onButtonCooldown && (
                      <Box inline ml={1} color="label">
                        (
                        {formatDuration(
                          return_to_port_button_cooldown_remaining,
                        )}
                        )
                      </Box>
                    )}
                  </Box>
                )}
              </Section>
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Star Chart"
              fill
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="search-minus"
                      onClick={() => zoomBy(1 / 1.3)}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="search-plus" onClick={() => zoomBy(1.3)} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="crosshairs" onClick={centerView}>
                      Center
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            >
              <Box
                ref={viewportRef}
                style={{
                  position: 'relative',
                  overflow: 'hidden',
                  overscrollBehavior: 'contain',
                  border: '1px solid rgba(255, 255, 255, 0.15)',
                  background: 'rgba(0, 0, 0, 0.2)',
                  cursor: 'move',
                }}
                width={`${VIEWPORT_WIDTH}px`}
                height={`${VIEWPORT_HEIGHT}px`}
                onMouseDown={handleBackgroundMouseDown}
              >
                <Box
                  style={{
                    position: 'relative',
                    transform: `translate(${view.pan.x}px, ${view.pan.y}px) scale(${view.zoom})`,
                    transformOrigin: '0 0',
                  }}
                  width={`${layout.size}px`}
                  height={`${layout.size}px`}
                >
                  <EdgeLines edges={edgeLines} />
                  {visibleSystems.map((system) => {
                    const point = pointFor(system.ref);
                    if (!point) return null;
                    const isPathNode =
                      pathSet.has(system.ref) &&
                      !system.is_current &&
                      !system.adjacent;
                    return (
                      <GraphNode
                        key={system.ref}
                        system={system}
                        point={point}
                        color={nodeColor(system)}
                        dimmed={isPathNode}
                        selected={system.ref === selectedRef}
                        onSelect={() => setSelectedRef(system.ref)}
                        onDragStart={handleNodeDragStart}
                      />
                    );
                  })}
                </Box>
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
