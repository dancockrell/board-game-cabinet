"""Candidate metadata only; never modifies generated raster artwork."""
import hashlib, json
from pathlib import Path
from PIL import Image
folder=Path(__file__).parent
sources={
 'south.png':'exec-765575f4-81ec-457f-83d1-d1dcb107a9d5.png',
 'north-first.png':'exec-81c8e137-4c73-49c9-ab29-db1ce095eef0.png',
 'north.png':'exec-a4b9299e-5c54-4933-a8c9-9f978401d40e.png',
 'east.png':'exec-62deab80-a77f-41df-8f0b-33d713f794ab.png',
 'west.png':'exec-15928fad-7ae8-43bd-ab74-1b4d27cfcad3.png',
}
images=[]
for name,source in sources.items():
 with Image.open(folder/name) as im:
  images.append(dict(file=name,sha256=hashlib.sha256((folder/name).read_bytes()).hexdigest(),
   dimensions=list(im.size),mode=im.mode,source='C:/Users/Admin/.codex/generated_images/01a08019-f832-70c3-8861-f5a8bdcceb78/'+source,
   columns=4,rows=8,visible_cells=32,superseded_attempt=name=='north-first.png'))
manifest=dict(character='minotaur',generator='built-in image_gen',date='2026-09-08',
 original_generation_calls=4,whole_sheet_repair_calls=1,requested_action_cells=128,
 visible_current_candidate_cells=128,additional_repair_attempt_cells=32,
 unique_usable_animation_frames=None,runtime_admitted_frames=0,
 layout='Four columns, eight rows; action frames 0-3 in first row then 4-7 in next row',
 actions=[dict(action=a,rows_one_based=[i*2+1,i*2+2],frames=8) for i,a in enumerate(['walk','charge','axe_attack','defeat'])],
 images=images,native_preview='outputs/Minotaur-Batch-01.mp4',
 findings=['North whole-sheet repair visibly restores axehead to screen-left across locomotion.',
 'Native equal-grid slicing still exposes adjacent-row axe fragments and minor tail/weapon clipping.',
 'South defeat early middle poses lose visible axe before it returns; needs continuity correction.',
 'East and west attack sequences jump from raised axe to ready stance before impact; not correctly chronological throughout.',
 'Walk cells contain repeated-looking poses; visible cell count does not prove distinct usable frames.',
 'Portrait 1:2 canvas with 4x8 cells still yields square cells. For wider weapon room use square canvas with 4x8 cells.',
 'No new gameplay or runtime Resource changes. Entire batch excluded from Windows exports.'],
 sharing='Local shared candidates only, no public shared repository push')
(folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('Recorded 128 current candidate cells, 32 repair attempt cells, zero runtime admission')
