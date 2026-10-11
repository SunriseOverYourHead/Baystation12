#!/usr/bin/env python3
"""
DMI Tool - read, list, extract, and combine BYOND .dmi files.

Usage:
  python dmi_tool.py list <file.dmi>
      Print all icon state names.

  python dmi_tool.py extract <src.dmi> <dst.dmi> <state1> [state2 ...]
      Copy named states from src into dst (creating or appending).

  python dmi_tool.py combine <dst.dmi> <src1.dmi>[:<state1,state2,...>] ...
      Build a new DMI from one or more sources.
      If :states is omitted, all states are taken from that source.
"""

import sys
import re
import struct
import zlib
import io
from pathlib import Path

# ---------------------------------------------------------------------------
# PNG / DMI parsing
# ---------------------------------------------------------------------------

PNG_SIG = b'\x89PNG\r\n\x1a\n'

def _read_chunks(data: bytes):
    """Yield (type, data) for every PNG chunk."""
    assert data[:8] == PNG_SIG, "Not a PNG file"
    pos = 8
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8].decode('latin-1')
        chunk_data = data[pos+8:pos+8+length]
        # crc = data[pos+8+length:pos+12+length]
        pos += 12 + length
        yield chunk_type, chunk_data

def _make_chunk(chunk_type: str, data: bytes) -> bytes:
    t = chunk_type.encode('latin-1')
    crc = zlib.crc32(t + data) & 0xFFFFFFFF
    return struct.pack('>I', len(data)) + t + data + struct.pack('>I', crc)

def _parse_dmi_meta(text: str):
    """
    Parse the DMI description block.
    Returns (width, height, list_of_state_dicts).
    Each state dict has: name, dirs, frames, delays, rewind, loop, movement.
    """
    lines = text.strip().splitlines()
    width = height = 32
    states = []
    cur = None
    for line in lines:
        line = line.strip()
        if line.startswith('version'):
            pass
        elif line.startswith('width'):
            width = int(line.split('=')[1].strip())
        elif line.startswith('height'):
            height = int(line.split('=')[1].strip())
        elif line.startswith('state'):
            name = re.search(r'"(.*)"', line).group(1)
            cur = {'name': name, 'dirs': 1, 'frames': 1,
                   'delays': None, 'rewind': 0, 'loop': 0, 'movement': 0}
            states.append(cur)
        elif cur is not None:
            if line.startswith('dirs'):
                cur['dirs'] = int(line.split('=')[1].strip())
            elif line.startswith('frames'):
                cur['frames'] = int(line.split('=')[1].strip())
            elif line.startswith('delay'):
                cur['delays'] = line.split('=')[1].strip()
            elif line.startswith('rewind'):
                cur['rewind'] = int(line.split('=')[1].strip())
            elif line.startswith('loop'):
                cur['loop'] = int(line.split('=')[1].strip())
            elif line.startswith('movement'):
                cur['movement'] = int(line.split('=')[1].strip())
    return width, height, states

def _state_frame_count(state):
    return state['dirs'] * state['frames']

def _build_dmi_meta(width, height, states):
    lines = ['# BEGIN DMI',
             f'version = 4.0',
             f'\twidth = {width}',
             f'\theight = {height}']
    for s in states:
        lines.append(f'state = "{s["name"]}"')
        lines.append(f'\tdirs = {s["dirs"]}')
        lines.append(f'\tframes = {s["frames"]}')
        if s['delays']:
            lines.append(f'\tdelay = {s["delays"]}')
        if s['rewind']:
            lines.append(f'\trewind = {s["rewind"]}')
        if s['loop']:
            lines.append(f'\tloop = {s["loop"]}')
        if s['movement']:
            lines.append(f'\tmovement = {s["movement"]}')
    lines.append('# END DMI')
    return '\n'.join(lines)

def load_dmi(path: str):
    """Load a DMI file. Returns (raw_bytes, width, height, states, image_rgba)."""
    from PIL import Image
    data = Path(path).read_bytes()

    # Extract DMI description text
    meta_text = None
    for ctype, cdata in _read_chunks(data):
        if ctype == 'tEXt':
            key, _, val = cdata.partition(b'\x00')
            if key == b'Description':
                meta_text = val.decode('latin-1')
                break
        elif ctype == 'zTXt':
            # keyword\0 compress_method(1) compressed_text
            null1 = cdata.index(b'\x00')
            key = cdata[:null1].decode('latin-1')
            if key == 'Description':
                compressed = cdata[null1+2:]  # skip null + method byte
                meta_text = zlib.decompress(compressed).decode('latin-1')
                break
        elif ctype == 'iTXt':
            # keyword\0compress_flag\0compress_method\0lang\0translated_kw\0text
            null1 = cdata.index(b'\x00')
            key = cdata[:null1].decode('latin-1')
            if key == 'Description':
                rest = cdata[null1+1:]
                compress_flag = rest[0]
                rest2 = rest[2:]
                lang_end = rest2.index(b'\x00')
                rest3 = rest2[lang_end+1:]
                tkw_end = rest3.index(b'\x00')
                text_bytes = rest3[tkw_end+1:]
                if compress_flag:
                    text_bytes = zlib.decompress(text_bytes)
                meta_text = text_bytes.decode('utf-8')
                break

    if meta_text is None:
        raise ValueError(f"No DMI Description chunk found in {path}")

    w, h, states = _parse_dmi_meta(meta_text)
    img = Image.open(path).convert('RGBA')
    return w, h, states, img

def _state_tiles(img, width, height, states, index):
    """Return a list of PIL Image tiles for the state at given index."""
    cols = img.width // width
    frame_offset = sum(_state_frame_count(states[i]) for i in range(index))
    count = _state_frame_count(states[index])
    tiles = []
    for k in range(count):
        n = frame_offset + k
        col = n % cols
        row = n // cols
        x = col * width
        y = row * height
        tiles.append(img.crop((x, y, x + width, y + height)))
    return tiles

def save_dmi(path: str, width: int, height: int, states: list, tiles_per_state: list):
    """
    Write a DMI file.
    tiles_per_state: list of lists of PIL images, parallel to states.
    """
    from PIL import Image

    total_frames = sum(len(t) for t in tiles_per_state)
    # BYOND uses a power-of-two wide sprite sheet (or at least multiples of width)
    # Just lay them out in a single row for simplicity; BYOND reads them back fine.
    cols = total_frames if total_frames > 0 else 1
    sheet = Image.new('RGBA', (cols * width, height))
    x = 0
    for tiles in tiles_per_state:
        for tile in tiles:
            sheet.paste(tile, (x, 0))
            x += width

    meta = _build_dmi_meta(width, height, states)

    # Save PNG to buffer
    buf = io.BytesIO()
    sheet.save(buf, format='PNG', optimize=False)
    raw = buf.getvalue()

    # Insert tEXt chunk with Description right after IHDR
    out = bytearray(PNG_SIG)
    chunks = list(_read_chunks(raw))
    ihdr_done = False
    for ctype, cdata in chunks:
        out += _make_chunk(ctype, cdata)
        if ctype == 'IHDR' and not ihdr_done:
            text_payload = b'Description\x00' + meta.encode('latin-1')
            out += _make_chunk('tEXt', text_payload)
            ihdr_done = True

    Path(path).write_bytes(bytes(out))


def cmd_list(args):
    if len(args) < 1:
        print("Usage: dmi_tool.py list <file.dmi>")
        sys.exit(1)
    w, h, states, img = load_dmi(args[0])
    print(f"Size: {w}x{h}  Sheet: {img.width}x{img.height}  States: {len(states)}")
    for s in states:
        print(f"  [{s['dirs']}dir {s['frames']}fr] {s['name']!r}")


def cmd_extract(args):
    if len(args) < 3:
        print("Usage: dmi_tool.py extract <src.dmi> <dst.dmi> <state1> [...]")
        sys.exit(1)
    src, dst = args[0], args[1]
    want = set(args[2:])
    w, h, states, img = load_dmi(src)
    out_states, out_tiles = [], []
    for i, s in enumerate(states):
        if s['name'] in want:
            out_states.append(s)
            out_tiles.append(_state_tiles(img, w, h, states, i))
            want.discard(s['name'])
    if want:
        print(f"WARNING: states not found: {want}", file=sys.stderr)
    save_dmi(dst, w, h, out_states, out_tiles)
    print(f"Wrote {len(out_states)} states to {dst}")


def cmd_combine(args):
    """
    combine <dst.dmi> <src1.dmi>[:<spec>] ...

    <spec> is a comma-separated list of entries, each being either:
      state_name          — include as-is
      state_name>new_name — include and rename
    Omit :<spec> to copy all states.
    """
    if len(args) < 2:
        print("Usage: dmi_tool.py combine <dst.dmi> <src.dmi>[:<states>] ...")
        sys.exit(1)
    dst = args[0]
    sources = args[1:]

    out_states, out_tiles = [], []
    global_w, global_h = None, None

    for spec in sources:
        if ':' in spec:
            src_path, state_spec = spec.split(':', 1)
            # Build mapping: original_name -> new_name (or same if no '>')
            rename = {}
            for entry in state_spec.split(','):
                if '>' in entry:
                    old, new = entry.split('>', 1)
                    rename[old] = new
                else:
                    rename[entry] = entry
        else:
            src_path = spec
            rename = None  # take all, no rename

        w, h, states, img = load_dmi(src_path)
        if global_w is None:
            global_w, global_h = w, h
        elif (w, h) != (global_w, global_h):
            print(f"WARNING: {src_path} has size {w}x{h}, expected {global_w}x{global_h}", file=sys.stderr)

        for i, s in enumerate(states):
            if rename is None or s['name'] in rename:
                new_name = rename[s['name']] if rename is not None else s['name']
                out_s = dict(s)
                out_s['name'] = new_name
                out_states.append(out_s)
                out_tiles.append(_state_tiles(img, w, h, states, i))
                if rename is not None:
                    rename.pop(s['name'])

        if rename:
            print(f"WARNING: states not found in {src_path}: {set(rename.keys())}", file=sys.stderr)

    save_dmi(dst, global_w or 32, global_h or 32, out_states, out_tiles)
    print(f"Wrote {len(out_states)} states to {dst}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    cmd = sys.argv[1]
    rest = sys.argv[2:]
    if cmd == 'list':
        cmd_list(rest)
    elif cmd == 'extract':
        cmd_extract(rest)
    elif cmd == 'combine':
        cmd_combine(rest)
    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)
        sys.exit(1)
