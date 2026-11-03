-- PC-only checks; intentionally reproduces the firmware's missing libraries.
local root=arg[1] or "."
local cache={}
function require(name)
    if cache[name] then return cache[name] end
    local f=assert(loadfile(root.."/"..name..".lua"));local v=f();cache[name]=v or true;return cache[name]
end
UP,DOWN,LEFT,RIGHT,BTN_Z,BTN_G,BTN_E,BTN_F,BTN_X,BTN_Q=1,2,3,4,5,6,7,8,9,10
local buttons={};local output,palette
local count=0
ui={spr=function(s,x,y)
    assert(type(s.path)=="string" and s.width>0 and s.height>0)
    if output then output:write(string.format("spr,%d,%d,%s\n",x,y,s.path)) end
end,btn=function(k) return buttons[k] or 0 end,stat=function() return 24 end,
    palset=function(i,c) if palette then palette:write(i,",",c,"\n") end end,
    rectfill=function(a,b,c,d,e) if output then output:write(string.format("rect,%d,%d,%d,%d,%d\n",a,b,c,d,e)) end end,
    print=function(s,x,y,c) s=s:gsub("^FPS %d+ TRI","PC TRI");if output then output:write(string.format("text,%d,%d,%d,%s\n",x,y,c,s)) end end,
    trisfill=function(a,b,c,d,e,f,k)
        for _,n in ipairs({a,b,c,d,e,f,k}) do assert(n==math.floor(n),"non integer") end
        assert(a>=0 and a<=479 and c>=0 and c<=479 and e>=0 and e<=479)
        assert(b>=20 and b<=227 and d>=20 and d<=227 and f>=20 and f<=227)
        assert((c-a)*(f-b)-(d-b)*(e-a)>0,"winding")
        count=count+1
        if output then output:write(string.format("tri,%d,%d,%d,%d,%d,%d,%d\n",a,b,c,d,e,f,k)) end
    end}
require "game"
local function find(fn,name)
    for i=1,100 do local n,v=debug.getupvalue(fn,i);if n==name then return v end;if not n then break end end
end
local player=find(Game.step,"player");local enemy=find(Game.step,"enemy")
assert(player and enemy)
local rooms=require "mansion"
local open=io.open
package,io,os,debug,collectgarbage,sfx,music=nil,nil,nil,nil,nil,nil,nil
local function tap(k) buttons[k]=1;Game.step(1/24);buttons[k]=0;Game.step(1/24) end
local function snapshot(name,draw)
    output=assert(open(root.."/tools/"..name..".csv","w"));palette=assert(open(root.."/tools/palette.csv","w"))
    local callback=draw or Game.draw;callback();output:close();palette:close();output=nil;palette=nil
end
snapshot("menu");assert(#player.mesh.f/4==180);tap(BTN_Q);assert(#player.mesh.f/4==402);tap(BTN_X);assert(Game.colorTest);snapshot("color-test");tap(BTN_X);assert(not Game.colorTest);tap(BTN_Z);assert(Game.state=="play")
snapshot("room")
-- This is the normal gameplay camera; only actor positions set for the scene.
player.x,player.z=0,-0.8;enemy.x,enemy.z=1,1.8
Game.step(1/24);snapshot("encounter")
Game.start();player.x,player.z=-2.5,2.4;snapshot("occlusion")
Game.start()
local max=0
for i=1,240 do buttons[RIGHT]=1;Game.step(1/24);Game.draw();max=math.max(max,Game.triangles);assert(require("renderer").dropped==0) end
buttons={}
Game.start();player.x,player.z=0,-2
local before={};for i,v in ipairs(player.mesh.v) do before[i]=v end
buttons[UP]=1;Game.step(1/24);buttons={}
local changed=false;for i,v in ipairs(player.mesh.v) do if before[i]~=v then changed=true end end
assert(not changed,"original mesh must not be deformed")
Game.setOriginal(false);local original=player.mesh.v[1];buttons[UP]=1;Game.step(1/24);buttons={};assert(#player.mesh.f/4==180);Game.setOriginal(true);assert(#player.mesh.f/4==402)
snapshot("walking")
local renderer=require "renderer"
-- Feet must remain above ground for a full stride, not just the rest pose.
local Models=require "models";local rig=Models.actor(false)
for i=1,80 do Models.animate(rig,0.04);for j=2,#rig.mesh.v,3 do assert(rig.mesh.v[j]>=0,"vertex below floor") end end
for x=-3,3,1.5 do for z=-4,4,2 do for yaw=0,5 do
        player.x,player.z,player.yaw=x,z,yaw;Game.draw()
    local low,high=10000,-10000
    for _,y in ipairs(player.sy) do low=math.min(low,y);high=math.max(high,y) end
    assert(high-low>=20 and high-low<=170,"gameplay silhouette size")
    max=math.max(max,Game.triangles);assert(require("renderer").dropped==0,"pool overflow")
end end end
Game.setOriginal(false);Game.start();local lightMax=0
for x=-3,3,1.5 do for z=-4,4,2 do
    player.x,player.z=x,z;Game.draw();lightMax=math.max(lightMax,Game.triangles);assert(renderer.dropped==0)
end end
Game.start();snapshot("room-light");Game.setOriginal(true)
Game.start()
player.x,player.z=3,4
tap(BTN_G)
assert(Game.room==2 and Game.state=="play","enter library")
assert(rooms[1].camera.yaw~=rooms[2].camera.yaw,"camera angle must change")
Game.setOriginal(false)
enemy.x,enemy.z=0,1.5
snapshot("library")
for x=-3,3,1.5 do for z=-4,4,2 do
    player.x,player.z=x,z
    Game.draw()
    lightMax=math.max(lightMax,Game.triangles)
    assert(renderer.dropped==0)
end end
player.x,player.z=-2.7,3.5;tap(BTN_G);assert(Game.key,"key")
player.x,player.z=3,4;tap(BTN_G)
assert(Game.room==1 and Game.key,"return to hall with key")
player.x,player.z=0,4.3;tap(BTN_G);assert(Game.state=="win","escape");snapshot("escape")
Game.start();Game.room=2;player.x,player.z=0,-2;player.yaw=0;enemy.x,enemy.z=0,0
tap(BTN_E);assert(Game.ammo==2 and Game.stun>0,"shot stun")
Game.start();Game.room=2;enemy.x,enemy.z=player.x,player.z;Game.step(0.05);assert(Game.health==2,"damage")
for i=1,3 do Game.invulnerable=0;enemy.x,enemy.z=player.x,player.z;Game.step(0.05) end
assert(Game.state=="dead");tap(BTN_F);assert(Game.state=="play" and Game.health==3)
Game.start();player.x,player.z=-2.5,-2.1;player.yaw=0;buttons[UP]=1
for i=1,20 do Game.step(1/24) end
assert(player.z<=-1.4,"crate collision")
buttons={};Game.start()
snapshot("mask-detail",function()
    require("colors").register();ui.rectfill(0,0,479,269,10)
    renderer.begin({x=2,y=0.85,z=-0.6,yaw=0,pitch=0})
    renderer.submit(enemy);renderer.flush()
    ui.print("DETALHE DA MALHA 3D - CAMERA DE INSPECAO",70,250,9)
end)
print("PASS: restricted loader, clipping, winding, rotation, key, exit, stun, damage, restart, collision")
print("Peak native triangles in sampled fixed view: ORIGINAL "..max.." / LEVE "..lightMax)
