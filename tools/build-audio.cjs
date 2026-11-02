// Original NES chiptune cues; Furnace format v173, no borrowed music/samples.
const fs=require('node:fs'),path=require('node:path'),zlib=require('node:zlib');
const out=path.resolve(__dirname,'../music');fs.mkdirSync(out,{recursive:true});
class W {constructor(){this.a=[];this.n=0} put(b){this.a.push(b);this.n+=b.length;return this} u8(n){return this.put(Buffer.from([n]))} u16(n){let b=Buffer.alloc(2);b.writeUInt16LE(n);return this.put(b)} u32(n){let b=Buffer.alloc(4);b.writeUInt32LE(n);return this.put(b)} f(n){let b=Buffer.alloc(4);b.writeFloatLE(n);return this.put(b)} str(s){return this.put(Buffer.from(s+'\0'))} zero(n){return this.put(Buffer.alloc(n))} buf(){return Buffer.concat(this.a)}}
function block(id,data){return new W().put(Buffer.from(id)).u32(data.length).put(data).buf()}
function make(name,rows,speed,fn){
  const macros=new W().u16(8)
  .u8(0).u8(1).u8(255).u8(255).u8(0).u8(1).u8(0).u8(1).u8(15)
  .u8(2).u8(1).u8(255).u8(255).u8(0).u8(1).u8(0).u8(1).u8(2)
  .u8(255).buf();
 const ins=block('INS2',new W().u16(173).u16(34).put(Buffer.from('NA')).u16(6).str('Horror')
  .put(Buffer.from('MA')).u16(macros.length).put(macros).put(Buffer.from('EN')).buf());
 const patterns=[];
 for(let ch=0;ch<5;ch++){
  const b=new W().u8(0).u8(ch).u16(0).str('');
  for(let row=0;row<rows;row++){
   const e=fn(ch,row);
   if(e===null||e===undefined)b.u8(0);
   else if(e.off)b.u8(1).u8(180);
   else b.u8(7).u8(e.note+48).u8(0).u8(e.vol??10);
  }
  b.u8(255);patterns.push(block('PATN',b.buf()));
 }
 function info(pointers){
  const w=new W().u8(0).u8(speed).u8(speed).u8(1).f(60).u16(rows).u16(1).u8(4).u8(16).u16(1).u16(0).u16(0).u32(5);
  w.u8(6).zero(31).put(Buffer.alloc(32,64)).zero(32).zero(128).str('Lupi Horror '+name).str('ofarol original').f(440);
  w.zero(20).u32(pointers[0]);for(let i=1;i<6;i++)w.u32(pointers[i]);
  w.zero(5).put(Buffer.alloc(5,1)).zero(10);for(let i=0;i<10;i++)w.str('');
  w.str('Original procedural audio, MIT').f(1).zero(28).u16(1).u16(1).str('').str('').u8(0).zero(3);
  for(let i=0;i<6;i++)w.str('');
  w.f(1).f(0).f(0).u32(2).u32(0x00000000).u32(0x00000001).u8(1).zero(8).u8(1).u8(speed).zero(15).u8(0).u32(pointers[6]||0).u32(pointers[6]||0).u32(pointers[6]||0);
  return block('INFO',w.buf());
 }
 let inf=info([0,0,0,0,0,0]);let cursor=32+inf.length;const pointers=[cursor];cursor+=ins.length;
 for(const p of patterns){pointers.push(cursor);cursor+=p.length}
 pointers.push(cursor);const dir=block("ADIR",new W().u32(0).buf());inf=info(pointers);
 const header=new W().put(Buffer.from('-Furnace module-')).u16(173).u16(0).u32(32).zero(8).buf();
 const data=Buffer.concat([header,inf,ins,...patterns,dir]);
 fs.writeFileSync(path.join(out,name+'.fur'),zlib.deflateSync(data));
}
const note=(note,vol=10)=>({note,vol});
make('horror_menu',32,12,(ch,r)=>{
 if(ch===0&&r%8===0)return note([48,51,47,43][r/8],4);
 if(ch===2&&r%16===0)return note(24,3);
});
make('horror_room',32,12,(ch,r)=>{
 if(ch===2&&r%16===0)return note(r<16?24:25,3);
 if(ch===0&&r%16===8)return note(r<16?43:42,2);
});
for(const [name,pitch] of [['shot',68],['hit',42]]) make(name,24,1,(ch,r)=>{
 if(ch===3&&r<16&&r%2===0)return note(pitch-r*2,Math.max(1,13-r/2));
 if(ch===0&&r<8&&r%2===0)return note(pitch-r*3,7-r/2);
 if((ch===0||ch===3)&&r===18)return {off:true};
});
for(const [name,seq] of [['pickup',[60,63,67]],['win',[48,55,60]],['lose',[43,42,36]]]) make(name,24,3,(ch,r)=>ch===0&&r%4===0?(r/4<seq.length?note(seq[r/4],6):{off:true}):null);
console.log('Generated original horror Furnace tracks');
