local G = require "geometry"
local rooms = {}

local function room(name,camera)
    local r={name=name,camera=camera,objects={},walls={},obstacles={}}
    r.floor={x=0,y=0,z=0,mesh=G.mesh()}
    G.quad(r.floor.mesh,{-4,0,-5},{-4,0,5},{4,0,5},{4,0,-5},35)
    return r
end

local function box(r,x,y,z,w,h,d,front,side,top,solid)
    r.objects[#r.objects+1]={x=x,y=y,z=z,mesh=G.box(w,h,d,front,side,top)}
    if solid then r.obstacles[#r.obstacles+1]={x=x,z=z,w=w,d=d,h=y+h/2} end
end

local hall=room("HALL",{x=6,y=6,z=-10,yaw=-.5404195,pitch=-.426566})
local library=room("BIBLIOTECA",{x=-6,y=6,z=-10,yaw=.5404195,pitch=-.426566})
rooms[1],rooms[2]=hall,library

for _,r in ipairs(rooms) do
    box(r,0,1.55,5.1,8,3.1,.2,13,37,36)
    box(r,0,.25,4.97,8,.5,.13,41,40,42)
    r.rug={x=0,y=0,z=0,mesh=G.mesh()}
    G.quad(r.rug.mesh,{-1.2,.01,-2.8},{-1.2,.01,3.2},{1.2,.01,3.2},{1.2,.01,-2.8},23)
end
box(hall,-4.1,1.55,0,.2,3.1,10,13,36,37)
box(hall,3,1.15,4.95,1.35,2.3,.1,43,41,44)
box(hall,0,1.15,4.95,1.35,2.3,.1,14,4,14)
box(hall,-2.5,.7,.3,1.6,1.4,2.9,42,41,43,true)
box(hall,-2.5,1.44,.3,1.66,.12,2.95,43,42,44)
box(hall,1.8,1.98,4.92,.85,1.08,.12,5,41,44)
box(hall,1.8,1.98,4.84,.66,.86,.05,6,11,1)

box(library,4.1,1.55,0,.2,3.1,10,13,36,37)
box(library,3,1.15,4.95,1.35,2.3,.1,43,41,44)
library.obstacles[#library.obstacles+1]={x=-2.25,z=4.45,w=2.5,d=.8,h=2.6}
box(library,-2.25,1.3,4.78,2.5,2.6,.14,40,41,42)
for _,x in ipairs({-3.43,-1.07}) do
    box(library,x,1.3,4.45,.14,2.6,.8,42,41,44)
end
box(library,-2.25,2.55,4.45,2.5,.1,.8,43,41,44)
for _,y in ipairs({.55,1.22,1.89}) do
    box(library,-2.25,y,4.45,2.5,.1,.8,43,41,44)
    box(library,-2.65,y+.23,4.28,.72,.36,.34,6,11,5)
    box(library,-1.78,y+.25,4.28,.65,.4,.34,7,23,13)
end
box(library,2.4,.65,1.1,1.4,1.3,1,42,41,43,true)
box(library,2.4,1.34,1.1,1.5,.12,1.1,43,42,44)
-- The shell sits behind every walkable position. Draw it before furniture.
for _,r in ipairs(rooms) do
    r.walls[1]=table.remove(r.objects,1)
    r.walls[2]=table.remove(r.objects,2)
end
return rooms
