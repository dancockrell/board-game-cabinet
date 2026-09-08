"""Read-only raster analysis; writes candidate region metadata, never modifies PNGs."""
import json
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parent
ROWS = dict(south=[0,232,466,693,887], north=[0,224,458,680,887], east=[0,241,489,711,887], west=[0,222,446,669,887])
result = {}
for direction, ys in ROWS.items():
    pixels = np.asarray(Image.open(ROOT / f'{direction}.png').convert('RGB'))
    frames = []
    for row in range(4):
        for column in range(8):
            left, right = round(column * 1774 / 8), round((column+1) * 1774 / 8)
            part = pixels[ys[row]:ys[row+1], left:right]
            foreground = ~((part[:,:,0]>165)&(part[:,:,2]>165)&(part[:,:,1]<90))
            labels, count = ndimage.label(foreground)
            sizes = np.bincount(labels.ravel())
            sizes[0] = 0
            body = int(sizes.argmax())
            y,x = np.where(labels == body)
            x0,x1 = max(0,int(x.min())-1),min(right-left,int(x.max())+2)
            y0,y1 = max(0,int(y.min())-1),min(ys[row+1]-ys[row],int(y.max())+2)
            frames.append(dict(row=row,column=column,region=[left+x0,ys[row]+y0,x1-x0,y1-y0],omitted_foreground_pixels=int(foreground.sum()-sizes[body]),status='provisional dominant connected figure; review required'))
    result[direction] = frames
(ROOT/'regions.json').write_text(json.dumps(result,indent=2)+'\n')
print('Analyzed 128 candidate regions; original PNGs unchanged; no admission claimed')
