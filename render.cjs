const fs = require('node:fs');
const dir = __dirname;
const W=480,H=270;
let pixels;
function box(x,y,w,h,c) {
  for(let j=Math.max(0,y);j<Math.min(H,y+h);j++)
    pixels.fill(c,j*W+Math.max(0,x),j*W+Math.min(W,x+w));
}
function poly(points,c) {
  for(let y=0;y<H;y++){
    const cuts=[];
    for(let i=0;i<points.length;i++){
      const [x1,y1]=points[i], [x2,y2]=points[(i+1)%points.length];
      if((y1<=y&&y<y2)||(y2<=y&&y<y1)) cuts.push(x1+(x2-x1)*(y-y1)/(y2-y1));
    }
    cuts.sort((a,b)=>a-b);
    for(let i=0;i<cuts.length;i+=2) box(Math.ceil(cuts[i]),y,Math.ceil(cuts[i+1])-Math.ceil(cuts[i]),1,c);
  }
}
function house(x,y,w,h,lit) {
  box(x,y,w,h,5);
  poly([[x+w,y],[x+w+20,y-16],[x+w+20,y+h-9],[x+w,y+h]],3);
  poly([[x-12,y+3],[x+w*.48,y-h*.53],[x+w+22,y-16],[x+w+4,y+3]],2);
  for(let row=y+11;row<y+h;row+=9) box(x,row,w,1,4);
  box(x+Math.floor(w*.18),y+13,Math.floor(w*.23),Math.floor(h*.26),2);
  box(x+Math.floor(w*.18)+3,y+16,Math.floor(w*.23)-6,Math.floor(h*.26)-6,lit?10:6);
  box(x+Math.floor(w*.68),y+Math.floor(h*.48),Math.floor(w*.17),Math.ceil(h*.52),2);
}
function tree(x,y,s){
  box(x-3,y-s,6,s,3);
  poly([[x,y-s*2],[x-s*.46,y-s*.6],[x+s*.4,y-s*.55]],3);
  poly([[x-4,y-s*1.85],[x-s*.36,y-s*.77],[x+3,y-s*.71]],4);
}
function outside(horizon){
  box(0,0,W,H,2);
  for(let y=12;y<horizon;y+=12) box(0,y,W,10,y<horizon/2?2:3);
  box(0,horizon,W,H-horizon,4);
}
const scenes={
  rua(){
    outside(108);
    for(let i=0;i<13;i++) tree(i*38,121,25+(i*13)%29);
    house(22,88,76,57,false); house(111,78,63,52,false);
    house(298,81,113,67,true);
    poly([[183,130],[289,130],[452,270],[45,270]],6);
    poly([[191,134],[278,134],[411,270],[72,270]],7);
    poly([[190,138],[197,139],[107,270],[96,270]],8);
    for(let y=150;y<245;y+=25) box(234,y,3+Math.floor(y/60),6,6);
    box(125,92,4,95,2); box(125,92,23,5,2); box(140,97,8,3,10);
    for(let i=0;i<22;i++) box(183+i*4,124,2,12,5);
    box(183,126,86,2,5);
  },
  parque(){
    outside(107);
    for(let i=0;i<12;i++) tree(i*45,134,34+i%4*9);
    poly([[35,153],[380,129],[478,227],[46,256]],6);
    poly([[35,162],[377,137],[449,216],[53,242]],7);
    poly([[76,193],[119,75],[132,75],[101,193]],5);
    poly([[213,194],[180,75],[192,75],[231,194]],5);
    box(116,75,79,6,8);
    poly([[326,100],[337,100],[337,177],[326,186]],5);
    poly([[337,105],[350,104],[404,173],[423,181],[414,190],[396,183]],8);
    for(let y=112;y<178;y+=11) box(309,y,21,3,5);
    box(307,103,3,76,5);
  },
  casa(){
    outside(126);
    tree(36,152,56); tree(450,150,51);
    house(86,80,280,95,true);
    box(263,125,52,52,3); box(270,130,37,48,5);
    box(276,135,25,24,4); box(298,160,3,3,10);
    box(322,147,5,8,8);
    poly([[256,171],[315,171],[427,270],[109,270]],6);
    for(let y=172;y<=190;y+=6) box(244-(y-172),y,85+(y-172)*2,3,8);
    box(116,99,35,26,10); box(131,99,4,26,5); box(116,109,35,3,5);
  },
  interior(){
    box(0,0,W,H,3);
    poly([[0,0],[174,58],[174,178],[0,270]],4);
    poly([[480,0],[313,58],[313,178],[480,270]],2);
    poly([[0,270],[174,178],[313,178],[480,270]],6);
    for(let x=35;x<480;x+=55) poly([[x,270],[x*.28+174,178],[x*.28+175,178],[x+2,270]],5);
    box(198,83,87,95,2); box(208,92,65,86,1);
    box(48,159,82,29,5); box(59,148,61,19,5);
    box(71,139,15,11,10);
  }
};
let id=0, manifest='';
for(const [name,draw] of Object.entries(scenes)){
  pixels=Buffer.alloc(W*H,1);
  draw();
  for(let i=0;i<pixels.length;i++){
    if((i*32719%65537)<1850 && pixels[i]>=3 && pixels[i]<=8) pixels[i]--;
  }
  const file='img/'+name;
  fs.writeFileSync(dir+'/'+file,pixels);
  manifest+= ++id+' '+pixels.length+' '+file+' {"type":"bitmap","width":480,"height":270}\n';
}
fs.writeFileSync(dir+'/lupi_manifest.txt',manifest);

