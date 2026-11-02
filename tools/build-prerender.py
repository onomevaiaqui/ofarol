import json,re,shutil,hashlib,time
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parent.parent;out=root/'.build/prerender-release';out.mkdir(parents=True,exist_ok=True)
pal=list(map(int,re.findall(r'\d+', (root/'background_palette.lua').read_text())));assert pal[0]==0 and len(pal)<=256
lookup={c:i for i,c in enumerate(pal)}
def color(c):return (c[2]>>3)*1024+(c[1]>>3)*32+(c[0]>>3)
entries=[]
for p in sorted(root.glob('*.lua')):
 shutil.copy2(p,out/p.name);entries.append((p.name,{'type':'lua_code'}))
for name in ['alley','dumpster']:
 image=Image.open(root/'backgrounds'/f'{name}.png').convert('RGBA')
 data=bytes(0 if c[3]==0 else lookup[color(c)] for c in image.getdata())
 assert len(data)==image.width*image.height
 if name=='alley':assert image.size==(480,208) and 0 not in data and color(image.getpixel((0,0)))!=8456
 (out/'backgrounds').mkdir(exist_ok=True);(out/'backgrounds'/name).write_bytes(data)
 entries.append(('backgrounds/'+name,{'type':'bitmap','width':image.width,'height':image.height}))
(out/'palette.lua').write_text('Palette={'+','.join(map(str,pal))+'}\nreturn Palette\n');entries.append(('palette.lua',{'type':'lua_code'}))
(out/'music').mkdir(exist_ok=True)
for p in sorted((root/'music').glob('*.fur')):shutil.copy2(p,out/'music'/p.name);entries.append(('music/'+p.name,{}))
for name in ['lupi.yaml','ASSETS.md','README.md']:shutil.copy2(root/name,out/name)
manifest=[];hashes=[];stamp=int(time.time())*10000
for i,(name,meta) in enumerate(entries):
 data=(out/name).read_bytes();manifest.append(f'{stamp+i} {len(data)} {name} '+json.dumps(meta,separators=(',',':')))
 hashes.append({'file':name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'metadata':meta})
(out/'lupi_manifest.txt').write_text('\n'.join(manifest)+'\n');(root/'.build/prerender-build.json').write_text(json.dumps(hashes,indent=2))
# Validate mask colours against the exact opaque pixels in the background.
bg=Image.open(root/'backgrounds/alley.png').convert('RGB');mask=Image.open(root/'backgrounds/dumpster.png').convert('RGBA')
layout=(root/'background_layout.lua').read_text();x=int(re.search(r'mask=\{x=(\d+)',layout)[1]);y=int(re.search(r'mask=\{x=\d+,y=(\d+)',layout)[1])-20
for my in range(mask.height):
 for mx in range(mask.width):
  c=mask.getpixel((mx,my))
  if c[3]:assert c[:3]==bg.getpixel((x+mx,y+my))
print(f'PASS: {len(pal)} colours, native indexed background/mask, transparency, pixel alignment, manifest and {len(entries)} runtime entries')
print(out)
