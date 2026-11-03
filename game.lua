local backgrounds = assert(require("sprites").img)
local palette = {
    0x0808, 0x1410, 0x1c72, 0x2165, 0x29a9, 0x316d,
    0x294a, 0x3dcc, 0x3c8d, 0x2b7d, 0x53df, 0x18b8,
    0x2e39, 0x2527, 0x77bd, 0x4e73
}
local views = {
    rua = {top = 143, title = "RUA SEM SAIDA"},
    parque = {top = 196, title = "PARQUINHO"},
    casa = {top = 182, title = "CASA 37"},
    interior = {top = 189, title = "CASA 37 / INTERIOR"}
}
local scene, x, y, age, cut, phase, key, facing, walking, step, message, timer
local function say(text, duration)
    message, timer = text, duration or 240
end

local function enter(name, px, py)
    scene, x, y, cut = name, px, py, 8
end

local function reset()
    phase, key, facing, walking, step = 0, false, 1, false, 0
    enter("rua", 235, 219)
    say("23h47. Entrega de pizza para a casa 37.")
end

local function near(px, py)
    return math.abs(x - px) <= 24 and math.abs(y - py) <= 18
end

local function interact()
    if scene == "parque" and near(399, 201) and not key then
        key = true
        say("Uma chave fria. A etiqueta diz 37.")
    elseif scene == "casa" and near(294, 183) then
        if phase == 0 then
            phase = 1
            say("TRIM. Uma sombra cruza a janela. Ninguem atende.")
        elseif phase == 1 then
            phase = 2
            say("Voce liga para o cliente. O toque vem de dentro.")
        elseif not key then
            say("A porta esta trancada. Algo brilha no parquinho.")
        else
            phase = 3
            enter("interior", 234, 225)
            say("A porta se fecha. A entrega ja estava paga.", 360)
        end
    end
end

local function move()
    local dx = (ui.btn(RIGHT) and 1 or 0) - (ui.btn(LEFT) and 1 or 0)
    local dy = (ui.btn(DOWN) and 1 or 0) - (ui.btn(UP) and 1 or 0)
    walking = dx ~= 0 or dy ~= 0
    if dx ~= 0 then facing = dx end
    local speed = dx ~= 0 and dy ~= 0 and 1.25 or 1.75
    x = math.max(18, math.min(462, x + dx * speed))
    y = math.max(views[scene].top, math.min(230, y + dy * speed))
    if walking then step = step + 1 end
    if scene == "rua" and y <= 144 and x >= 172 and x <= 293 then
        enter("parque", 30, 218)
        if phase >= 1 and not key then say("O balanco se move sozinho.") end
    elseif scene == "parque" and x >= 461 then
        enter("casa", 30, 218)
    elseif scene == "parque" and x <= 19 then
        enter("rua", 233, 161)
    elseif scene == "casa" and x <= 19 then
        enter("parque", 444, 218)
    end
end

local function rect(x1, y1, x2, y2, color)
    ui.rectfill(math.max(0, math.floor(x1)), math.floor(y1), math.min(479, math.floor(x2)), math.floor(y2), color)
end

local function courier()
    local scale = 0.75 + (y - 145) / 180
    local function part(left, top, right, bottom, color)
        rect(x + left * scale, y + top * scale, x + right * scale, y + bottom * scale, color)
    end
    local stride = walking and (math.floor(step / 7) % 2) * 4 - 2 or 0
    part(-12, -1, 12, 1, 3)
    part(-7, -13, -2, -2 - stride, 14)
    part(2, -13, 7, -2 + stride, 14)
    part(-7, -3 - stride, -1, -1 - stride, 2)
    part(2, -3 + stride, 8, -1 + stride, 2)
    part(-8, -25, 8, -12, 12)
    part(-6, -33, 6, -25, 13)
    part(-7, -35, 7, -31, 12)
    part(facing * 6 - 4, -32, facing * 6 + 4, -30, 12)
    part(facing * 7 - 10, -21, facing * 7 + 10, -16, 11)
    part(facing * 7 - 10, -17, facing * 7 + 10, -16, 10)
end

local function draw()
    ui.spr(backgrounds[scene], 0, 0)
    local prompt
    if scene == "rua" then
        ui.print("PARQUINHO ^", 201, 130, 15)
    elseif scene == "parque" then
        local sway = math.floor(math.sin(age / 24) * (phase > 0 and 17 or 4))
        for i = 0, 1 do
            local anchor = 147 + 13 * i
            ui.line(anchor, 81, anchor + sway, 151, 8)
        end
        rect(144 + sway, 151, 163 + sway, 154, 5)
        if not key then
            rect(396, 198, 402, 201, age % 32 < 16 and 11 or 8)
            if near(399, 201) then prompt = "M / OESTE: PEGAR CHAVE" end
        end
        ui.print("< RUA", 8, 184, 15)
        ui.print("CASA 37 >", 399, 184, 15)
    elseif scene == "casa" then
        ui.print("37", 318, 132, 11)
        if phase == 1 and timer > 180 then
            local shadow = 117 + math.min(24, math.floor((240 - timer) / 2))
            rect(shadow, 103, shadow + 5, 123, 2)
        end
        if near(294, 183) then
            prompt = ({"TOCAR CAMPAINHA", "LIGAR PARA O CLIENTE", "TENTAR A PORTA"})[phase + 1]
            prompt = "M / OESTE: " .. prompt
        end
        ui.print("< PARQUINHO", 8, 164, 15)
    else
        ui.print("FIM DO PROLOGO", 172, 39, 11)
        prompt = "L / NORTE: RECOMECAR"
    end
    courier()
    if prompt then ui.print(prompt, 12, 225, 11) end
    rect(0, 240, 479, 269, 1)
    ui.print(views[scene].title .. (key and "  /  CHAVE 37" or ""), 12, 243, 16)
    ui.print(timer > 0 and message or "WASD / DIRECIONAL   M / OESTE: INTERAGIR", 12, 256, 15)
end

age = 0
function update()
    if age == 0 then
        for index, color in ipairs(palette) do ui.palset(index, color) end
        reset()
    end
    age = age + 1
    if scene == "interior" and ui.btnp(BTN_Q) then reset() end
    if cut > 0 then
        cut = cut - 1
        ui.cls(1)
        return
    end
    if timer > 0 then timer = timer - 1 end
    move()
    if cut == 0 and ui.btnp(BTN_E) then interact() end
    if cut > 0 then ui.cls(1) else draw() end
end

