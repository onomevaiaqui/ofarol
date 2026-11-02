local root=arg[1] or "."
local calls={}
music={loop=function(path,fade) calls[#calls+1]=path end,volume=function() end}
local A=assert(loadfile(root.."/audio.lua"))()
A.update(0.1);assert(calls[1]=="music/horror_menu")
for i=1,10 do A.update(0.1) end;assert(#calls==1,"must not restart every frame")
A.scene("play");A.update(0.1);assert(calls[2]=="music/horror_room")
A.event("shot");assert(calls[3]=="music/shot");A.update(0.1);assert(#calls==3)
A.update(0.3);assert(calls[4]=="music/horror_room")
music.loop=function() return nil,"missing" end
A.event("hit");assert(A.status=="ERRO FUR" and A.error=="missing")
music=nil;sfx=nil;A.event("hit");assert(A.status=="SEM API")
print("PASS: requests, no frame restarts, effect return, API error and missing API; not an audible hardware test")
