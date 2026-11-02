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
    local shirt=infected and 7 or 6
    part(taper(0.30,0.48,0.54,0.24,0.30,shirt,infected and 13 or 11,shirt),0,0.89,0)
    -- Octagonal silhouette head: six vertices, eight faces, no box head.
    local skin=infected and 4 or 15
    local head={v={0,0.22,0, -0.17,0,0, 0,0,-0.16, 0.17,0,0, 0,0,0.18, 0,-0.18,0},
        f={1,3,2,10,1,4,3,10,1,5,4,skin,1,2,5,skin,6,2,3,skin,6,3,4,skin,6,4,5,skin,6,5,2,skin}}
    part(head,0,1.38,infected and 0.06 or 0)
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


