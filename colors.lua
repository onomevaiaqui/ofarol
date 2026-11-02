local cfg=require "config"
-- Cool concrete, warm targets and brighter upper faces. Same 32-entry budget.
local rgb={{0,0,0},{96,144,176},{40,40,40},{47,47,47},{88,88,88},{154,176,180},{64,88,104},{208,64,40},{248,176,48},{232,232,208},{16,16,16},{73,100,118},{176,200,208},{104,80,56},{112,168,72},{248,224,144}}
local M={palette={},index={}}
for shade=0,1 do for _,c in ipairs(rgb) do
    local factor=shade==0 and 1 or 0.78
    local r,g,b=math.floor(c[1]*factor/8),math.floor(c[2]*factor/8),math.floor(c[3]*factor/8)
    M.palette[#M.palette+1]=b*1024+g*32+r
    M.index[#M.palette-1]=#M.palette-1
end end
-- Extra neutral bone/wood shades sampled for faithful source face colours.
local extra={{40,36,24},{60,56,44},{80,76,60},{104,100,80},{128,124,100},{152,148,124},{176,172,144},{208,204,172},{24,16,8},{48,32,16},{72,48,24},{96,64,32},{120,88,48},{144,112,72},{184,152,104},{216,188,144}}
for _,c in ipairs(extra) do
    local r,g,b=math.floor(c[1]/8),math.floor(c[2]/8),math.floor(c[3]/8)
    M.palette[#M.palette+1]=b*1024+g*32+r;M.index[#M.palette-1]=#M.palette-1
end
-- Remap actor colour IDs to the palette actually assigned to PNG assets.
M.source=M.palette
pcall(require,"palette")
local target=type(Palette)=="table" and type(Palette[1])=="number" and Palette or require "background_palette"
local lookup={};for i,c in ipairs(target) do lookup[c]=i-1 end
for id,c in ipairs(M.source) do
    local mapped=lookup[c]
    if mapped==nil then
        local best=math.huge
        for i,v in ipairs(target) do
            local r=(c%32)-(v%32);local g=(math.floor(c/32)%32)-(math.floor(v/32)%32);local b=math.floor(c/1024)-math.floor(v/1024)
            local d=r*r+g*g+b*b;if d<best then best=d;mapped=i-1 end
        end
    end
    M.index[id-1]=mapped
end
M.palette=target
function M.register()
    for i,c in ipairs(M.palette) do
        if cfg.platform=="hardware" then c=(c%32)*1024+(math.floor(c/32)%32)*32+math.floor(c/1024)%32 end
        ui.palset(i-1,c)
    end
end
return M



