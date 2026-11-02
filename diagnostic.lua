-- Native diagnostic: same palette slot, rectangle versus two triangles.
-- Local previews cannot establish which encoding the installed firmware uses.
local M={}
local rgb={{16,16,16},{64,64,64},{128,128,128},{192,192,192},{248,0,0},{0,248,0},{0,0,248},{248,248,248}}
local labels={"16","64","128","192","R","G","B","248"}
function M.draw()
    ui.palset(240,0);ui.palset(241,32767)
    ui.rectfill(0,20,479,227,240)
    ui.print("TESTE NATIVO DE CORES - X: VOLTAR",60,27,241)
    for row=1,3 do
        local y=55+(row-1)*54
        ui.print(row==1 and "BGR555" or row==2 and "RGB555" or "RGB565",3,y+8,241)
        for i,c in ipairs(rgb) do
            local r,g,b=math.floor(c[1]/8),math.floor(c[2]/8),math.floor(c[3]/8)
            local value=row==1 and b*1024+g*32+r or row==2 and r*1024+g*32+b or r*2048+math.floor(c[2]/4)*32+b
            local index=216+(row-1)*8+i-1
            ui.palset(index,value)
            local x=76+(i-1)*49
            ui.rectfill(x,y,x+37,y+12,index)
            ui.trisfill(x,y+16,x+37,y+16,x+37,y+28,index)
            ui.trisfill(x,y+16,x+37,y+28,x,y+28,index)
            ui.print(labels[i],x+5,y+32,241)
        end
    end
    ui.print("EM CADA PAR: RETANGULO EM CIMA / TRIANGULO EMBAIXO",17,218,241)
    ui.print("ENVIE FOTO DO TESTE; NAO E AJUSTE DE BRILHO DA TV",19,247,241)
end
return M

