from PIL import Image
from pathlib import Path
out=[]
for name,step in [('alley',4),('dumpster',2)]:
 im=Image.open('backgrounds/'+name+'.png').convert('RGBA')
 w,h=im.size
 a=im.resize(((w+step-1)//step,(h+step-1)//step),Image.Resampling.NEAREST)
 rows=[]
 for y in range(a.height):
  x=0
  while x<a.width:
   c=a.getpixel((x,y)); end=x+1
   while end<a.width and a.getpixel((end,y))==c:end+=1
   if c[3]:rows.extend([x*step,y*step,min(w,end*step),min(h,(y+1)*step),(c[2]>>3)*1024+(c[1]>>3)*32+(c[0]>>3)])
   x=end
 out.append(name+'={'+','.join(map(str,rows))+'}')
Path('background_pixels.lua').write_text('return {'+','.join(out)+'}\n')
