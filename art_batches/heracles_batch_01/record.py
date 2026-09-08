"""Record unchanged originals and candidate counts; does not edit raster artwork."""
import hashlib, json
from pathlib import Path
from PIL import Image

folder = Path(__file__).parent
sources = {
    'south.png': 'exec-454de524-7695-4870-b211-535cd8a69d8b.png',
    'north.png': 'exec-cf5a5183-a405-4f8a-b440-807448681488.png',
    'east.png': 'exec-28a9369e-7323-4713-bbe8-8322eef38391.png',
    'west-first.png': 'exec-8b0236c7-34f0-4152-906a-273ca599162f.png',
    'west.png': 'exec-8168970e-8b85-4645-96f7-77e44cea5d3e.png',
}
records = []
for name, source in sources.items():
    data = (folder/name).read_bytes()
    with Image.open(folder/name) as im:
        records.append(dict(file=name, sha256=hashlib.sha256(data).hexdigest(),
                            dimensions=list(im.size), mode=im.mode,
                            source='C:/Users/Admin/.codex/generated_images/01a08019-f832-70c3-8861-f5a8bdcceb78/'+source,
                            visible_cells=32, columns=8, rows=4,
                            admission='candidate_only',
                            superseded_attempt=name=='west-first.png'))
manifest = dict(character='heracles', generator='built-in image_gen', date='2026-09-08',
    original_generation_calls=4, whole_sheet_repair_calls=1, requested_action_cells=128,
    visible_current_candidate_cells=128, additional_repair_attempt_cells=32,
    unique_usable_animation_frames=None, runtime_admitted_frames=0,
    rows=[dict(index=i, action=a, frames=8, chronological_order='left_to_right')
          for i,a in enumerate(['walk','run','club_attack','defeat'])],
    images=records, native_preview='outputs/Heracles-Batch-01.mp4',
    findings=['Uniform eight-column slicing clips some club silhouettes and imports neighboring fragments.',
              'West repair improves walk hand continuity but walk column7 loses the club; run retains hand drift.',
              'North walk column6 has no visible club.',
              'Walk poses include repeated-looking phases; 128 visible cells is not 128 proven distinct usable drawings.',
              'Defeat arcs and broad club arcs are candidate improvements requiring per-frame crop, pivot, hand and sequence admission.',
              'Use four columns by eight rows, each action wrapping over two rows, in next broad-weapon batch.'],
    sharing='Local shared candidates only; no public shared-repository publication')
(folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('Recorded four current sheets / 128 visible candidate cells, one repair attempt, zero runtime admitted frames')
