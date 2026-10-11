import struct, zlib, os

def read_png_chunks(data):
    assert data[:8] == b'\x89PNG\r\n\x1a\n'
    chunks = []
    pos = 8
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        ctype  = data[pos+4:pos+8]
        cdata  = data[pos+8:pos+8+length]
        pos += 12 + length
        chunks.append((ctype, cdata))
    return chunks

def parse_dmi_desc(data):
    chunks = read_png_chunks(data)
    for ctype, cdata in chunks:
        if ctype == b'zTXt':
            null = cdata.index(0)
            return zlib.decompress(cdata[null+2:]).decode()
        if ctype == b'tEXt':
            null = cdata.index(0)
            return cdata[null+1:].decode()
    return ''

def get_state_names(desc):
    names = []
    for line in desc.split('\n'):
        line = line.strip()
        if line.startswith('state = "'):
            names.append(line[9:line.index('"', 9)])
    return names

folder = 'NewAmmo'
for fname in sorted(os.listdir(folder)):
    if not fname.endswith('.dmi'):
        continue
    path = os.path.join(folder, fname)
    data = open(path, 'rb').read()
    desc = parse_dmi_desc(data)
    states = get_state_names(desc)
    print(f"\n{fname}: {states}")
