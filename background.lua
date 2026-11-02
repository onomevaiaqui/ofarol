local L=require "background_layout"
local C=require "colors"
pcall(require,"sprites")
local B={layout=L,status="FUNDO NAO IMPORTADO"}
local function sprite(name)
    return type(Sprites)=="table" and type(Sprites.backgrounds)=="table" and Sprites.backgrounds[name] or nil
end
local function draw(name,x,y)
    local s=sprite(name)
    if type(ui.spr)~="function" or type(s)~="table" then return false end
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
