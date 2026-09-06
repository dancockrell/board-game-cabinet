"""Inspect exported GLB material/rig evidence without importing vendor code."""
import argparse, hashlib, json, pathlib, struct

def inspect(path):
    raw = path.read_bytes()
    magic, version, length = struct.unpack_from('<III', raw)
    if magic != 0x46546C67 or version != 2 or length != len(raw):
        raise ValueError('Invalid GLB 2 header or length')
    chunk_length, chunk_type = struct.unpack_from('<II', raw, 12)
    if chunk_type != 0x4E4F534A:
        raise ValueError('First GLB chunk must be JSON')
    doc = json.loads(raw[20:20 + chunk_length])
    materials = []
    for mat in doc.get('materials', []):
        pbr = mat.get('pbrMetallicRoughness', {})
        materials.append({'name': mat.get('name'), 'basecolor_texture': 'baseColorTexture' in pbr,
                          'metallic_roughness_texture': 'metallicRoughnessTexture' in pbr,
                          'normal_texture': 'normalTexture' in mat,
                          'occlusion_texture': 'occlusionTexture' in mat,
                          'metallic_factor': pbr.get('metallicFactor', 1),
                          'roughness_factor': pbr.get('roughnessFactor', 1)})
    return {'file': path.name, 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(),
            'generator': doc.get('asset', {}).get('generator'),
            'skins': [len(s.get('joints', [])) for s in doc.get('skins', [])],
            'animations': [a.get('name', '<unnamed>') for a in doc.get('animations', [])],
            'materials': materials, 'embedded_images': len(doc.get('images', [])),
            'note': 'Structural inventory only; does not establish visual quality or license.'}

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('models', nargs='+', type=pathlib.Path)
    parser.add_argument('--output', required=True, type=pathlib.Path)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps([inspect(p) for p in args.models], indent=2), encoding='utf-8')
