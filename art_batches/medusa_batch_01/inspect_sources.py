import json,hashlib
from pathlib import Path
from PIL import Image
import numpy as np
root=Path(__file__).parent
sources={"south":"exec-adba0b69-a74d-4aac-bba3-859ae2cfa52e.png","north":"exec-7c3a836b-28c8-45a4-9c16-123afa7e43db.png","east":"exec-cf8184aa-729c-4692-989d-7a37a4c2b369.png","west":"exec-147a0abc-e243-43c7-9aac-a83ef6655c74.png"}
rows={"south":[0,234,456,674,887],"north":[0,228,450,668,887],"east":[0,230,455,674,887],"west":[0,228,450,670,887]}
actions=["walk","gaze_attack","hurt","defeat"]
notes={
"south":["Walk mostly repeats the same leading leg; requires a new gait row.","Hands and snakes progress through brace/extension/recovery; return has a pose jump.","Readable flinch/recovery; end and start intentionally similar.","Progressive knees/hands/side fall; candidate for native admission."],
"north":["Alternating heels visible but toe-off/passing phases need playback scrutiny.","Clear arms and snake extension; fast late return.","Flinch/braced stance changes readable; late recovery similar.","Forward fall has eight progressive drawings."],
"east":["Eight drawings retain near-identical leading leg; not a valid complete gait.","Brace/extend/recover progression; frame eight remains braced.","Recoil and recovery sequence; final frames similar.","Knees/hands/side fall progression, consistent right-facing identity."],
"west":["Contacts/passing vary but opposite-leg stride still weak.","Distinct reach/peak; abrupt return at column seven.","Guard/flinch/knee/recovery sequence; last poses similar.","Clear progressive knee/floor/side collapse, left-facing identity."]
}
manifest={"schema_version":1,"status":"candidate_not_runtime_admitted","character":"medusa","generator":"built-in image_gen","calls":4,"requested_cells":128,"visible_occupied_cells":128,"accepted_runtime_frames":0,"unique_motion_pose_count":"not claimed; occupied cells include similar and deliberately returning poses","raster_processing":"none; original PNG copied unchanged","reference":"assets/olympus_arena/sprites/medusa-v1.png","sheets":[]}
for direction,source in sources.items():
    path=root/f"medusa-{direction}-32.png"
    im=Image.open(path)
    w,h=im.size
    pixels=np.asarray(im.convert("RGB")).astype(int)
    occupied=(np.minimum(pixels[:,:,0],pixels[:,:,2])-pixels[:,:,1]<80)|(np.minimum(pixels[:,:,0],pixels[:,:,2])<128)
    cols=[round(i*w/8) for i in range(9)]
    sheet={"direction":direction,"file":path.name,"source":f"C:/Users/Admin/.codex/generated_images/01a0801a-5f6c-76c1-91a0-ee69c0400058/{source}","sha256":hashlib.sha256(path.read_bytes()).hexdigest(),"dimensions":[w,h],"mode":im.mode,"requested_grid":[8,4],"observed_grid":[8,4],"visible_occupied_cells":32,"column_boundaries":cols,"row_boundaries":rows[direction],"prompt_file":f"prompt-{direction}.txt","rows":[]}
    for r,action in enumerate(actions):
        bounds=[]
        y0,y1=rows[direction][r:r+2]
        columns=occupied[y0:y1].sum(axis=0)>2
        intervals=[]
        start=None
        for x,value in enumerate(columns):
            if value and start is None: start=x
            if not value and start is not None:
                if x-start>8: intervals.append([start,x])
                start=None
        if start is not None: intervals.append([start,w])
        assert len(intervals)==8, (direction,action,intervals)
        for x0,x1 in intervals:
            bounds.append([max(0,x0-2),y0,min(w,x1+2)-max(0,x0-2),y1-y0])
        sheet["rows"].append({"action":action,"frame_order":list(range(8)),"regions":bounds,"duration_seconds_per_cell":0.12 if r==0 else 0.10,"looping":r==0,"review":notes[direction][r]})
    sheet["region_method"]="Read-only foreground column measurement per row, two pixels padding; no raster edits. Equal grid has silhouette bleed in falling poses."
    manifest["sheets"].append(sheet)
(root/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
print(json.dumps({s["direction"]:{"size":s["dimensions"],"sha256":s["sha256"]} for s in manifest["sheets"]},indent=2))
