-- Playback requests only: success of pcall is NOT proof of audible output.
local A={desired="horror_menu",current=nil,hold=0,status="NAO TESTADO"}
local function request(name)
    if type(music)=="table" and type(music.loop)=="function" then
        if type(music.volume)=="function" then pcall(music.volume,0.7,type(CH_ALL)=="number" and CH_ALL or 31,0) end
        local ok,value,reason=pcall(music.loop,"music/"..name,0.1)
        if not ok or value==false or value==nil and type(reason)=="string" then A.status="ERRO FUR";A.error=tostring(reason or value):sub(1,65)
        else A.status="FUR SOLICITADO - NAO CONFIRMADO";A.error=nil end
    elseif type(sfx)=="table" and type(sfx.fx)=="function" then
        if type(sfx.volume)=="function" then pcall(sfx.volume,0.7) end
        local ok,value=pcall(sfx.fx,name=="shot" and 3 or 62,name=="shot" and 40 or 60,0.5)
        A.status=ok and "SFX SOLICITADO - NAO CONFIRMADO" or "ERRO SFX";A.error=not ok and tostring(value):sub(1,65) or nil
    else A.status="SEM API" end
    A.current=name
end
function A.scene(state) A.desired=state=="menu" and "horror_menu" or "horror_room" end
function A.event(name) request(name);A.hold=name=="shot" and 0.3 or 0.8 end
function A.update(dt)
    A.hold=math.max(0,A.hold-dt)
    if A.hold==0 and A.current~=A.desired then request(A.desired) end
end
return A
