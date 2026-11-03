local G = require "geometry"
local scene = {objects = {}}
local function box(x,y,z,w,h,d,front,side,top)
    scene.objects[#scene.objects+1] = {x=x,y=y,z=z,mesh=G.box(w,h,d,front,side,top)}
end

scene.floor = {x=0,y=0,z=0,mesh=G.mesh()}
G.quad(scene.floor.mesh, {-4,0,-5}, {-4,0,5}, {4,0,5}, {4,0,-5}, 35)
G.quad(scene.floor.mesh, {-1.25,.01,-2.5}, {-1.25,.01,2.5}, {1.25,.01,2.5}, {1.25,.01,-2.5}, 23)
box(0,1.5,5.1,8,3,.2,13,37,36)
box(-4.1,1.5,0,.2,3,10,13,36,37)
box(0,.22,4.96,8,.44,.12,41,40,42)
box(3,1.15,4.95,1.35,2.3,.1,43,41,44)
for _,x in ipairs({-2.6,0}) do
    box(x,1.95,4.94,1.1,1.25,.12,5,4,12)
    box(x,1.95,4.86,.85,1,.08,6,11,1)
end
box(-2.5,.7,.3,1.6,1.4,2.9,42,41,43)
box(-2.5,1.44,.3,1.66,.12,2.95,43,42,44)
box(3.15,1.7,1.8,.16,3.4,.16,4,2,5)
box(2.94,3.4,1.8,.58,.15,.24,4,2,15)
return scene
