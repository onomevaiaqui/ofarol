local G=require "geometry"
local R=require "renderer"
local C=require "colors"
local Models=require "models"
local Diagnostic=require "diagnostic"
local Audio=require "audio"
local Alley=require "alley"
Game={state="menu",fps=60,build="1.3-BECO"}
local camera={x=6,y=6,z=-10,yaw=-0.5404195002705842,pitch=-0.42656599364032893}
local obstacles={{x=-2.5,z=0.3,w=1.6,d=2.9,h=1.5},{x=3.15,z=1.8,w=0.25,d=0.25,h=4.5}}
local function object(mesh,x,y,z) return {mesh=mesh,x=x or 0,y=y or 0,z=z or 0} end
local function box(w,h,d,x,y,z,a,b,c)
    return object(G.box(w,h,d,a or 3,b or 2,c or 4),x,y,z)
end
local door={x=3,y=0,z=4.7}
local key=box(0.36,0.15,0.2,-2.7,0.35,3.5,8,13,15)
local playerRig=Models.actor(false)
local enemyRig=Models.actor(true)
local player=object(playerRig.mesh)
local enemy=object(enemyRig.mesh)
function Game.setOriginal(value)
    Models.original=value
    playerRig,enemyRig=Models.actor(false),Models.actor(true)
    player.mesh,enemy.mesh=playerRig.mesh,enemyRig.mesh

end
local previous={}
local tick=0
local function held(k)
    if k==nil then return false end
    local v=ui.btn(k,0)
    return v==true or type(v)=="number" and v>0
end
local function dist(a,b) local x,z=a.x-b.x,a.z-b.z;return math.sqrt(x*x+z*z) end
local function blocked(x,z)
    if x< -3.7 or x>3.7 or z< -4.7 or z>4.7 then return true end
    for _,b in ipairs(obstacles) do if math.abs(x-b.x)<b.w/2+0.25 and math.abs(z-b.z)<b.d/2+0.25 then return true end end
    return false
end
local function move(o,x,z)
    local oldx,oldz=o.x,o.z
    if not blocked(o.x+x,o.z) then o.x=o.x+x end
    if not blocked(o.x,o.z+z) then o.z=o.z+z end
    local dx,dz=o.x-oldx,o.z-oldz;return math.sqrt(dx*dx+dz*dz)
end
function Game.start()
    Game.state="play";Game.health=3;Game.ammo=3;Game.key=false;Game.message="ENCONTRE A CHAVE E A SAIDA";Game.timer=3
    Game.invulnerable=0;Game.stun=0;Game.flash=0
    player.x,player.z,player.yaw=0,-3.5,0
    enemy.x,enemy.z,enemy.yaw=2,2.8,math.pi
    playerRig.phase,enemyRig.phase=0,0;Models.animate(playerRig,0);Models.animate(enemyRig,0)
end
local function message(s) Game.message=s;Game.timer=2.5 end
function Game.step(dt)
    tick=tick+1
    if tick%15==1 and type(ui.stat)=="function" then
        local ok,n=pcall(ui.stat,7)
        if ok and type(n)=="number" and n==n and n>=1 and n<=240 then Game.fps=n end
    end
    dt=math.max(0,math.min(dt or 1/Game.fps,0.125))
    Audio.scene(Game.state);Audio.update(dt)
    local now={up=held(UP),down=held(DOWN),left=held(LEFT),right=held(RIGHT),run=held(BTN_Z),act=held(BTN_G),fire=held(BTN_E),reset=held(BTN_F),test=held(BTN_X),detail=held(BTN_Q)}
    local function pressed(k) return now[k] and not previous[k] end
    if pressed("detail") then Game.setOriginal(not Models.original) end
    if pressed("test") then Game.colorTest=not Game.colorTest end
    if Game.colorTest then previous=now;return end
    if Game.state~="play" then
        if pressed("run") or pressed("reset") then Game.start() end
    elseif pressed("reset") then Game.start()
    else
        Game.timer=math.max(0,Game.timer-dt);Game.invulnerable=math.max(0,Game.invulnerable-dt)
        Game.stun=math.max(0,Game.stun-dt);Game.flash=math.max(0,Game.flash-dt)
        player.yaw=(player.yaw+((now.right and 1 or 0)-(now.left and 1 or 0))*2.5*dt)%(math.pi*2)
        local amount=((now.up and 1 or 0)-(now.down and 1 or 0))*(now.run and 2.7 or 1.6)*dt
        local walked=move(player,math.sin(player.yaw)*amount,math.cos(player.yaw)*amount)
        Models.animate(playerRig,walked)
        if pressed("act") then
            if not Game.key and dist(player,key)<1.2 then Game.key=true;Audio.event("pickup");message("CHAVE ENCONTRADA - PROCURE A PORTA DE MADEIRA")
            elseif dist(player,door)<1.2 then
                if Game.key then Game.state="win";Audio.event("win") else message("PORTA TRANCADA - PRECISA DE CHAVE") end
            else message("NADA AO ALCANCE") end
        end
        if pressed("fire") then
            if Game.ammo>0 then
                Game.ammo=Game.ammo-1;Game.flash=0.12;Audio.event("shot")
                local d=dist(player,enemy)
                local dot=(enemy.x-player.x)*math.sin(player.yaw)+(enemy.z-player.z)*math.cos(player.yaw)
                -- Line of sight: crates stop both the enemy and the shot.
                local clear=true
                if d>0.001 then for _,b in ipairs(obstacles) do
                    if G.rayBox({minx=b.x-b.w/2,maxx=b.x+b.w/2,miny=0,maxy=b.h or 0.85,minz=b.z-b.d/2,maxz=b.z+b.d/2},player.x,0.7,player.z,(enemy.x-player.x)/d,0,(enemy.z-player.z)/d,d) then clear=false end
                end end
                if d<4.5 and dot>math.max(0,d*0.85) and clear then Game.stun=3;message("INIMIGO ATORDOADO - CORRA!") else message("DISPARO") end
            else message("SEM MUNICAO") end
        end
        local d=dist(player,enemy)
        local ex,ez=enemy.x,enemy.z
        if Game.stun==0 and d>0.001 then
            local dx,dz=(player.x-enemy.x)/d,(player.z-enemy.z)/d
            enemy.yaw=math.atan(dx,dz)
            if d<5.8 then move(enemy,dx*0.85*dt,dz*0.85*dt)
            else move(enemy,math.sin(tick*0.01)*0.3*dt,0) end
        end
        Models.animate(enemyRig,math.sqrt((enemy.x-ex)^2+(enemy.z-ez)^2),Game.stun>0)
        if d<0.62 and Game.stun==0 and Game.invulnerable==0 then
            Game.health=Game.health-1;Audio.event("hit");Game.invulnerable=1.8;message("FERIDO! AFASTE-SE")
            if Game.health<=0 then Game.state="dead";Audio.event("lose") end
        end
    end
    previous=now
end
local function text(s,x,y,c) ui.print(s,x,y,C.index[c or 9]) end
local function rect(x,y,w,h,c) ui.rectfill(x,y,x+w,y+h,C.index[c]) end
function Game.draw()
    if type(ui.camera)=="function" then ui.camera(0,0) end
    if type(ui.clip)=="function" then ui.clip(0,0,480,270) end
    C.register();rect(0,0,479,269,10)
    if Game.colorTest then Diagnostic.draw();text("SOM: "..Audio.status,12,258,9);return end
    if Game.state=="menu" then
        text("BECO 3D LUA - VERSAO 1.3",118,52,15);text("SURVIVAL HORROR 3D - PROTOTIPO 1.3",105,80,9)
        text("UM DEPOSITO. UMA CHAVE. UMA CHANCE.",105,113,5)
        text("CRUZ: ANDAR / GIRAR    B: CORRER",111,145,9)
        text("A: INTERAGIR    R: DISPARAR    Y: REINICIAR",77,164,9)
        text("B: INICIAR",203,200,15)
        text("X: CORES / L: ORIGINAL OU LEVE",106,231,11)
        text("SOM: "..Audio.status,65,248,11)
        return
    end
    R.begin(camera)
    R.submit(Alley.floor)
    R.flush()
    for _,object in ipairs(Alley.objects) do R.submit(object) end
    if not Game.key then R.submit(key) end
    R.submit(enemy)
    if Game.invulnerable==0 or tick%4<2 then R.submit(player) end
    R.flush()
    Game.triangles=R.triangles
    rect(0,0,479,19,0);rect(0,228,479,41,0)
    text("VIDA "..Game.health.."  TIROS "..Game.ammo.."  CHAVE "..(Game.key and "SIM" or "NAO"),8,5,9)
    text(Models.original and "ORIGINAL" or "LEVE",266,5,5)
    text("FPS "..math.floor(Game.fps).." TRI "..R.triangles,340,5,5)
    rect(5,23,91,15,0);text("BECO 1.3",10,27,9)
    if Game.timer>0 then text(Game.message,12,237,15) end
    text("A INTERAGIR  R TIRO  B CORRER  Y REINICIAR  X CORES  L DETALHE",12,255,11)
    if Game.flash>0 then rect(232,117,16,8,15) end
    if Game.stun>0 then text("ATORDOADO",200,26,8) end
    if Game.state=="win" or Game.state=="dead" then
        rect(95,88,290,75,10)
        text(Game.state=="win" and "VOCE ESCAPOU" or "VOCE NAO SOBREVIVEU",155,105,Game.state=="win" and 14 or 7)
        text("B OU Y: TENTAR NOVAMENTE",141,138,9)
    end
end
