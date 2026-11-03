local L=require "background_layout"
local C=require "colors"
pcall(require,"sprites")
local B={layout=L,status="PRE-RENDER"}
local pixels
local indices={}
for i,c in ipairs(C.palette) do indices[c]=i-1 end
local function embedded(name,x,y)
    pixels=pixels or require "background_pixels"
    local r=pixels[name]
    for i=1,#r,5 do
        ui.rectfill(x+r[i],y+r[i+1],x+r[i+2],y+r[i+3],indices[r[i+4]] or C.index[10])
    end
    return true
end
local function sprite(name)
    return type(Sprites)=="table" and type(Sprites.backgrounds)=="table" and Sprites.backgrounds[name] or nil
end
local function draw(name,x,y)
    local s=sprite(name)
    if type(ui.spr)~="function" or type(s)~="table" then return embedded(name,x,y) end
    ui.spr(s,x,y);return true
end
function B.draw()
    local ok=draw("alley",0,20)
    B.status=ok and "PRE-RENDER" or "FUNDO NAO IMPORTADO"
    if not ok then
        ui.print("FUNDO NAO IMPORTADO PELO CATALOGO",90,108,C.index[9])
        ui.print("USE O PACOTE COM LUPI_MANIFEST.TXT",85,126,C.index[9])
    end
    return ok
end
function B.occlude(actor)
    local cam=L.camera
    local depth=(actor.x-cam.x)*math.sin(cam.yaw)+(actor.z-cam.z)*math.cos(cam.yaw)
    if depth>L.mask.depth then draw("dumpster",L.mask.x,L.mask.y) end
end
return B

