"""Analyze original PNGs into provisional body rectangles; never edit raster pixels."""
import json
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage
ROOT=Path(__file__).resolve().parent
result={}
for name in ['south_a','north_a','south_b','north_b']:
    pixels=np.asarray(Image.open(ROOT/f'{name}.png').convert('RGB'))
    foreground=~((pixels[:,:,0]>165)&(pixels[:,:,2]>165)&(pixels[:,:,1]<90))
    labels,count=ndimage.label(foreground)
    boxes=ndimage.find_objects(labels)
    sizes=np.bincount(labels.ravel())
    frames=[]
    for row in range(8):
        for column in range(4):
            candidates=[]
            for i,box in enumerate(boxes,1):
                if box is None or sizes[i]<300: continue
                sy,sx=box
                cx,cy=(sx.start+sx.stop)/2,(sy.start+sy.stop)/2
                if int(cx/887*4)==column and int(cy/1774*8)==row: candidates.append((sizes[i],i,box))
            if not candidates: raise ValueError(f'No figure at {name}/{row}/{column}')
            _,label,box=max(candidates,key=lambda item:item[0])
            sy,sx=box
            x0,x1=max(0,sx.start-1),min(887,sx.stop+1)
            y0,y1=max(0,sy.start-1),min(1774,sy.stop+1)
            frames.append(dict(row=row,column=column,region=[x0,y0,x1-x0,y1-y0],body_pixels=int(sizes[label]),status='provisional full-sheet connected body; detached feathers excluded; review required'))
    result[name]=frames
(ROOT/'regions.json').write_text(json.dumps(result,indent=2)+'\n')
print('Analyzed 128 connected figure regions without altering original PNGs')
