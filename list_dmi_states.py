import struct, zlib, re, os, sys

def get_dmi_states(path):
    try:
        with open(path, 'rb') as f:
            data = f.read()
    except:
        return []
    chunks = []
    i = 8
    while i < len(data):
        length = struct.unpack('>I', data[i:i+4])[0]
        chunk_type = data[i+4:i+8].decode('ascii', errors='ignore')
        chunk_data = data[i+8:i+8+length]
        chunks.append((chunk_type, chunk_data))
        i += 12 + length
    states = []
    for chunk_type, chunk_data in chunks:
        text = None
        if chunk_type == 'tEXt':
            parts = chunk_data.split(b'\x00', 1)
            if len(parts) == 2 and parts[0] == b'Description':
                text = parts[1].decode('utf-8', errors='ignore')
        elif chunk_type == 'zTXt':
            parts = chunk_data.split(b'\x00', 2)
            if len(parts) == 3 and parts[0] == b'Description':
                text = zlib.decompress(parts[2]).decode('utf-8', errors='ignore')
        if text:
            states = re.findall(r'state = "([^"]+)"', text)
    return states

if len(sys.argv) > 1:
    # Single file mode
    for path in sys.argv[1:]:
        states = get_dmi_states(path)
        print(f'{os.path.basename(path)}: {states}')
else:
    # List all onmob/items DMIs
    base = r'c:/Users/PoderosoVitao/Documents/GitHub/Baystation12SOYH'
    onmob_dir = base + '/icons/mob/onmob/items'
    for fname in sorted(os.listdir(onmob_dir)):
        if fname.endswith('.dmi'):
            states = get_dmi_states(onmob_dir + '/' + fname)
            print(f'{fname}: {states}')
