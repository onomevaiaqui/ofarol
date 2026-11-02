-- Small articulated meshes. Vertex buffers and bind pose allocated once.
local G=require "geometry"
local M={}
local function taper(w0,w1,h,d0,d1,front,side,top)
    local m=G.box(1,1,1,front,side,top)
    for i=1,#m.v,3 do
        local upper=m.v[i+1]>0
        m.v[i]=m.v[i]*(upper and w1 or w0)
        m.v[i+1]=m.v[i+1]*h
        m.v[i+2]=m.v[i+2]*(upper and d1 or d0)
    end
    return m
end
function M.table(w,d)
    local m=G.mesh()
    local top=G.box(w,0.12,d,13,2,13)
    -- Underside never visible from this fixed upper camera.
    for i=1,8 do top.f[#top.f]=nil end
    G.append(m,top,0,0.85,0)
    local leg=G.box(0.10,0.79,0.10,13,2,13)
    -- Leg caps hidden by floor and tabletop.
    local sides={}
    for i=9,40 do sides[#sides+1]=leg.f[i] end
    leg.f=sides
    for _,x in ipairs({-w/2+0.12,w/2-0.12}) do
        for _,z in ipairs({-d/2+0.12,d/2-0.12}) do G.append(m,leg,x,0.395,z) end
    end
    return m
end
function M.actor(infected)
    local m=G.mesh()
    local limbs={}
    local function part(mesh,x,y,z,pivot)
        local first=#m.v+1
        G.append(m,mesh,x,y,z)
        if pivot then limbs[#limbs+1]={first=first,last=#m.v,x=x,y=pivot,z=z} end
    end
    local shirt=infected and 2 or 6
    part(taper(0.30,0.48,0.54,0.24,0.30,shirt,infected and 10 or 11,shirt),0,0.89,0)
    -- Angular hood/hair, broad forehead and narrow chin: 16 base triangles.
    local skin=infected and 9 or 15
    local head={v={-0.12,-0.13,-0.12, 0.12,-0.13,-0.12, 0.12,-0.13,0.15, -0.12,-0.13,0.15,
        -0.18,0.17,-0.14, 0.18,0.17,-0.14, 0.18,0.17,0.17, -0.18,0.17,0.17,
        0,0.31,0, 0,-0.29,0.07},
        f={1,6,2,10,1,5,6,10, 2,7,3,2,2,6,7,10,
           3,8,4,skin,3,7,8,skin, 4,5,1,2,4,8,5,10,
           5,9,6,10,6,9,7,10,7,9,8,2,8,9,5,10,
           1,2,10,10,2,3,10,2,3,4,10,skin,4,1,10,2}}
    if infected then
        -- Dark diamond eye sockets and a nose mark, geometry rather than textures.
        for _,x in ipairs({-0.085,0.085}) do
            G.quad(head,{x,-0.035,0.176},{x+0.045,0.02,0.176},{x,0.075,0.176},{x-0.045,0.02,0.176},0)
        end
        G.append(head,{v={-0.022,-0.11,0.16,0.022,-0.11,0.16,0,-0.055,0.165},f={1,2,3,0}},0,0,0)
    end
    part(head,0,1.42,infected and 0.06 or 0)
    for _,sign in ipairs({-1,1}) do
        part(taper(0.12,0.16,0.57,0.13,0.18,shirt,shirt,skin),sign*0.31,0.84,0,1.12)
        part(taper(0.12,0.17,0.59,0.19,0.20,10,11,10),sign*0.115,0.31,0,0.60)
    end
    local bind={}
    for i,v in ipairs(m.v) do bind[i]=v end
    return {mesh=m,bind=bind,limbs=limbs,phase=0,infected=infected}
end
function M.animate(rig,distance,stunned)
    rig.phase=rig.phase+distance*7
    local s=math.sin(rig.phase)
    for n,p in ipairs(rig.limbs) do
        local angle=0
        if stunned then angle=n%2==1 and -0.7 or 0
        end
        -- Explicit diagonal pairs: left arm/right leg move together.
        if not stunned and distance>0 then angle=s*((n==1 or n==4) and 0.48 or -0.48) end
        if rig.infected and n%2==1 then angle=angle-0.55 end
        local c,t=math.cos(angle),math.sin(angle)
        for i=p.first,p.last,3 do
            local y,z=rig.bind[i+1]-p.y,rig.bind[i+2]-p.z
            rig.mesh.v[i+1]=p.y+y*c-z*t
            rig.mesh.v[i+2]=p.z+y*t+z*c
        end
    end
end
return M






