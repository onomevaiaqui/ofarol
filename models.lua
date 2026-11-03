-- Real itch.io meshes converted offline. No FBX/GLB loader runs on the console.
local G=require "geometry"
local Data=require "asset_meshes"
local Full=require "asset_meshes_full"
local M={original=false}
function M.prop(name) return (M.original and Full or Data)[name] end
local function armor()
    local mesh,groups=G.mesh(),{}
    local function part(w,h,d,x,y,z,color,group)
        local first=#mesh.v/3+1
        G.append(mesh,G.box(w,h,d,color,4,12),x,y,z)
        for i=first,#mesh.v/3 do groups[i]=group end
    end
    part(.52,.55,.30,0,1.12,0,11,0)
    part(.32,.35,.30,0,1.57,0,5,0)
    part(.22,.08,.045,0,1.60,.16,10,0)
    part(.16,.62,.18,-.36,1.10,.08,4,3)
    part(.16,.62,.18,.36,1.10,.08,4,4)
    part(.19,.75,.24,-.14,.39,.02,11,1)
    part(.19,.75,.24,.14,.39,.02,11,2)
    mesh.groups=groups
    return mesh
end
local guard=armor()
function M.actor(infected)
    local source=infected and guard or (M.original and Full or Data).player
    local mesh={v={},f=source.f};local bind={}
    for i,x in ipairs(source.v) do mesh.v[i]=x;bind[i]=x end
    return {mesh=mesh,bind=bind,groups=source.groups,phase=0,infected=infected,angles={},cs={},sn={}}
end
function M.animate(rig,distance,stunned)
    if M.original and not rig.infected then return end
    rig.phase=rig.phase+distance*7
    local swing=distance>0 and math.sin(rig.phase)*0.40 or 0
    local angles=rig.angles;angles[1],angles[2],angles[3],angles[4]=swing,-swing,-swing,swing
    if stunned then angles[3],angles[4]=-0.8,-0.8 end
    local cs,sn=rig.cs,rig.sn
    for g=1,4 do cs[g],sn[g]=math.cos(angles[g]),math.sin(angles[g]) end
    local minimum=0
    for i=1,#rig.bind,3 do
        local x,y,z=rig.bind[i],rig.bind[i+1],rig.bind[i+2]
        local group=rig.groups[(i+2)/3]
        if group>0 then
            local pivot=group<=2 and 0.86 or 1.42
            local dy=y-pivot
            y,z=pivot+dy*cs[group]-z*sn[group],dy*sn[group]+z*cs[group]
        end
        rig.mesh.v[i],rig.mesh.v[i+1],rig.mesh.v[i+2]=x,y,z
        if y<minimum then minimum=y end
    end
    -- A long source foot can cross the plane when the whole leg swings.
    -- Lift the pose just enough to keep all geometry above the floor.
    if minimum<0 then for i=2,#rig.mesh.v,3 do rig.mesh.v[i]=rig.mesh.v[i]-minimum end end
end
return M
