import json,math
from PIL import Image
from pathlib import Path
root=Path(__file__).resolve().parent.parent;build=root/'.build/alley';dest=root/'backgrounds';dest.mkdir(exist_ok=True)
base=[int(x) for x in (build/'source-palette.txt').read_text().split()]
def rgb(c): return ((c&31)*255//31,((c>>5)&31)*255//31,((c>>10)&31)*255//31)
def pack(c):return (int(c[2])>>3)*1024+(int(c[1])>>3)*32+(int(c[0])>>3)
original=Image.open(build/'alley-rgba.png').convert('RGB')
quant=original.quantize(colors=64,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert('RGB')
values=[max(1,pack(c)) for c in quant.getdata()];master=list(dict.fromkeys([0]+base+values));assert len(master)<=256
pixels=[rgb(c) for c in values];quant.putdata(pixels);quant.save(dest/'alley.png')
a=Image.open(build/'dumpster-rgba.png').getchannel('A');bbox=a.point(lambda x:255 if x>=128 else 0).getbbox();mask=Image.new('RGBA',quant.size);mask.putdata([(*c,255 if alpha>=128 else 0) for c,alpha in zip(pixels,a.getdata())]);mask.crop(bbox).save(dest/'dumpster.png')
swatch=Image.new('RGB',(len(base),1));swatch.putdata([rgb(c) for c in base]);swatch.save(dest/'swatches.png')
(root/'background_palette.lua').write_text('return {'+','.join(map(str,master))+'}\n')
lookup={c:i for i,c in enumerate(master)}
(dest/'alley').write_bytes(bytes(lookup[v] for v in values))
maskvals=[lookup[max(1,pack(c[:3]))] if c[3] else 0 for c in mask.crop(bbox).getdata()];(dest/'dumpster').write_bytes(bytes(maskvals))
layout=json.loads((build/'layout.json').read_text());cam=layout['camera'];cx,cy,x1,y1=bbox
# Foreground plane for the caçamba: front-most horizontal support point.
sy,co=math.sin(cam['yaw']),math.cos(cam['yaw']);depth=(-2.5-cam['x'])*sy+(.3-cam['z'])*co-(abs(sy)*.8+abs(co)*1.45)
probes=json.loads((build/'probes.json').read_text())
text='return {camera={'+','.join(k+'='+repr(v) for k,v in cam.items())+'},mask={x='+str(cx)+',y='+str(cy+20)+',width='+str(x1-cx)+',height='+str(y1-cy)+',depth='+str(depth)+'},probes={'+','.join('{'+','.join(map(str,p))+'}' for p in probes)+'}}\n'
(root/'background_layout.lua').write_text(text)
(build/'palette.json').write_text(json.dumps(master));(build/'layout-complete.json').write_text(json.dumps(layout|{'bbox':bbox,'palette_size':len(master)},indent=2))
print('palette',len(master),'background bytes',len(values),'mask',bbox,'mask bytes',len(maskvals))



