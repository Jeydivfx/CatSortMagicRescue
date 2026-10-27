"""Measure transparent sprite gutters; writes frame coordinates, never edits art."""
from pathlib import Path
import json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]

def cuts(values,length):
    smooth=np.convolve(values,np.ones(5)/5,'same')
    return [0]+[int(length*k/4)-45+int(np.argmin(smooth[int(length*k/4)-45:int(length*k/4)+46])) for k in (1,2,3)]+[length]

frames={}
for path in sorted((ROOT/'assets/cats').glob('breeds_*.png')):
    alpha=np.asarray(Image.open(path))[:,:,3]>90
    h,w=alpha.shape
    columns=cuts(alpha.sum(axis=0),w)
    entries={}
    for col in range(4):
        left,right=columns[col:col+2]
        rows=cuts(alpha[:,left:right].sum(axis=1),h)
        for row in range(4):
            top,bottom=rows[row:row+2]
            tile=alpha[top:bottom,left:right]
            y,x=np.nonzero(tile)
            assert len(x)>200
            entries[f'{col},{row}']=[left+int(x.min()),top+int(y.min()),int(x.max()-x.min()+1),int(y.max()-y.min()+1)]
    frames['res://'+path.relative_to(ROOT).as_posix()]=entries
(ROOT/'assets/cats/frames.json').write_text(json.dumps(frames,indent=2))
print('Indexed 48 expression frames without modifying original artwork')
