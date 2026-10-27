"""Read-only atlas analysis: locate dark pupil components inside the face ROIs."""
from pathlib import Path
import json
from collections import deque
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
for entry in json.loads((ROOT/'video_work/eye_regions.json').read_text()):
    x,y,w,h=map(int,entry['rect'])
    pixels=np.array(Image.open(ROOT/entry['path']).convert('RGBA'))[y:y+h,x:x+w]
    eyes=[]
    for left,right in [(.15,.45),(.46,.78)]:
        mask=(pixels[:,:,:3].max(axis=2)<25)&(pixels[:,:,3]>200)
        roi=np.zeros_like(mask);roi[int(h*.28):int(h*.48),int(w*left):int(w*right)]=True
        mask &= roi
        components=[]
        for yy,xx in zip(*np.where(mask)):
            if not mask[yy,xx]:continue
            queue=deque([(yy,xx)]);mask[yy,xx]=False;points=[]
            while queue:
                py,px=queue.popleft();points.append((py,px))
                for dy,dx in [(1,0),(-1,0),(0,1),(0,-1)]:
                    sy,sx=py+dy,px+dx
                    if 0<=sy<h and 0<=sx<w and mask[sy,sx]:mask[sy,sx]=False;queue.append((sy,sx))
            if len(points)>15:components.append(points)
        p=max(components,key=len)
        yy,xx=np.array(p).T
        eyes.append([round((xx.min()+xx.max())/2/w,4),round((yy.min()+yy.max())/2/h,4)])
    print(entry['kind'],eyes)
