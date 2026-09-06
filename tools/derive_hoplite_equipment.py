"""REJECTED EXPERIMENT: reproduces shield rim deformation; not a production converter."""
import json,struct,sys,hashlib
from pathlib import Path
source=Path(sys.argv[1]);target=Path(sys.argv[2])
if source.resolve()==target.resolve(): raise ValueError('Never overwrite source')
b=source.read_bytes();n=struct.unpack_from('<I',b,12)[0];j=json.loads(b[20:20+n]);binary=bytearray(b[28+n:])
p=j['meshes'][0]['primitives'][0]
def field(key):
 a=j['accessors'][p['attributes'][key]];v=j['bufferViews'][a['bufferView']]
 return a,v,v.get('byteOffset',0)+a.get('byteOffset',0)
a,v,offset=field('POSITION');count=0
for i in range(a['count']):
 at=offset+i*v.get('byteStride',12);x,y,z=struct.unpack_from('<3f',binary,at)
 # Front shield shell is ahead of the arm in the preserved +X-facing bind mesh.
 if z < -.29:
  blend=min(1.0,max(0.0,(-z-.29)/.04));factor=1.0+.45*blend
  y=.655+(y-.655)*factor;z=-.407+(z+.407)*factor
  struct.pack_into('<3f',binary,at,x,y,z);count+=1
# Refresh position accessor bounds after enlargement.
points=[struct.unpack_from('<3f',binary,offset+i*v.get('byteStride',12)) for i in range(a['count'])]
a['min']=[min(p[d] for p in points) for d in range(3)];a['max']=[max(p[d] for p in points) for d in range(3)]
encoded=json.dumps(j,separators=(',',':')).encode();encoded+=b' '*((-len(encoded))%4)
target.parent.mkdir(parents=True,exist_ok=True)
target.write_bytes(struct.pack('<III',0x46546c67,2,28+len(encoded)+len(binary))+struct.pack('<II',len(encoded),0x4e4f534a)+encoded+struct.pack('<II',len(binary),0x004e4942)+binary)
print(json.dumps({'source_sha256':hashlib.sha256(b).hexdigest(),'shield_vertices':count,'output':str(target),'status':'review_candidate_not_runtime'}))
