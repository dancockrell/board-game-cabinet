"""Read-only GLB connected-component audit; helps find separable rigid equipment."""
import json,struct,sys
from pathlib import Path
b=Path(sys.argv[1]).read_bytes()
n=struct.unpack_from('<I',b,12)[0]
j=json.loads(b[20:20+n]);binary=b[28+n:]
formats={5121:'B',5123:'H',5125:'I',5126:'f'}
widths={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}
def read(idx):
 a=j['accessors'][idx];v=j['bufferViews'][a['bufferView']]
 fmt='<'+formats[a['componentType']]*widths[a['type']]
 size=struct.calcsize(fmt);step=v.get('byteStride',size)
 offset=v.get('byteOffset',0)+a.get('byteOffset',0)
 return [struct.unpack_from(fmt,binary,offset+i*step) for i in range(a['count'])]
p=j['meshes'][0]['primitives'][0];verts=read(p['attributes']['POSITION']);indices=[x[0] for x in read(p['indices'])]
parents=list(range(len(verts)))
def root(i):
 while parents[i]!=i:
  parents[i]=parents[parents[i]];i=parents[i]
 return i
for k in range(0,len(indices),3):
 a,c,d=indices[k:k+3];parents[root(c)]=root(a);parents[root(d)]=root(a)
groups={}
for i in range(len(verts)):groups.setdefault(root(i),[]).append(i)
result=[]
for ids in sorted(groups.values(),key=len,reverse=True):
 result.append({'vertices':len(ids),'min':[min(verts[i][d] for i in ids) for d in range(3)],'max':[max(verts[i][d] for i in ids) for d in range(3)]})
print(json.dumps({'components':len(result),'largest':result[:20]},indent=2))
