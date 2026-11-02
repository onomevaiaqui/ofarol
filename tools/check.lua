-- PC-only checks; intentionally reproduces the firmware's missing libraries.
local root=arg[1] or "."
local cache={}
function require(name)
    if cache[name] then return cache[name] end
    local f=assert(loadfile(root.."/"..name..".lua"));local v=f();cache[name]=v or true;return cache[name]
end
UP,DOWN,LEFT,RIGHT,BTN_Z,BTN_G,BTN_E,BTN_F=1,2,3,4,5,6,7,8
local buttons={};local output,palette
local count=0
ui={btn=function(k) return buttons[k] or 0 end,stat=function() return 24 end,
    palset=function(i,c) if palette then palette:write(i,",",c,"\n") end end,
    rectfill=function(a,b,c,d,e) if output then output:write(string.format("rect,%d,%d,%d,%d,%d\n",a,b,c,d,e)) end end,
    print=function(s,x,y,c) if output then output:write(string.format("text,%d,%d,%d,%s\n",x,y,c,s)) end end,
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
local open=io.open
package,io,os,debug,collectgarbage,sfx,music=nil,nil,nil,nil,nil,nil,nil
local function tap(k) buttons[k]=1;Game.step(1/24);buttons[k]=0;Game.step(1/24) end
local function snapshot(name)
    output=assert(open(root.."/tools/"..name..".csv","w"));palette=assert(open(root.."/tools/palette.csv","w"))
    Game.draw();output:close();palette:close();output=nil;palette=nil
end
snapshot("menu");tap(BTN_Z);assert(Game.state=="play")
snapshot("room")
local max=0
for i=1,240 do buttons[RIGHT]=1;Game.step(1/24);Game.draw();max=math.max(max,Game.triangles);assert(require("renderer").dropped==0) end
buttons={};Game.start();player.x,player.z=-2.7,3.5;tap(BTN_G);assert(Game.key,"key")
player.x,player.z=2.5,4.3;tap(BTN_G);assert(Game.state=="win","escape");snapshot("escape")
Game.start();player.x,player.z=0,-2;player.yaw=0;enemy.x,enemy.z=0,0
tap(BTN_E);assert(Game.ammo==2 and Game.stun>0,"shot stun")
Game.start();enemy.x,enemy.z=player.x,player.z;Game.step(0.05);assert(Game.health==2,"damage")
for i=1,3 do Game.invulnerable=0;enemy.x,enemy.z=player.x,player.z;Game.step(0.05) end
assert(Game.state=="dead");tap(BTN_F);assert(Game.state=="play" and Game.health==3)
Game.start();player.x,player.z=-2.3,-1.4;player.yaw=0;buttons[UP]=1
for i=1,20 do Game.step(1/24) end
assert(player.z<=-1.25,"crate collision")
print("PASS: restricted loader, clipping, winding, rotation, key, exit, stun, damage, restart, collision")
print("Peak native triangles in sampled fixed view: "..max)
