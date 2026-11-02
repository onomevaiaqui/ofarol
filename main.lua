local G=require "geometry"
local R=require "renderer"
local C=require "colors"
local Models=require "models"
Game={state="menu",fps=60}
local camera={x=9,y=12,z=-14,yaw=-math.atan(9,14),pitch=-math.atan(12/math.sqrt(277))}
local scene={}
local obstacles={{x=-2.3,z=0,w=1.3,d=2},{x=2.1,z=1.7,w=1.5,d=1.2}}
local function object(mesh,x,y,z) return {mesh=mesh,x=x or 0,y=y or 0,z=z or 0} end
local function box(w,h,d,x,y,z,a,b,c)
    return object(G.box(w,h,d,a or 3,b or 2,c or 4),x,y,z)
end
local floor=G.mesh()
-- Tile only along depth: reduces painter overlap at the feet of actors.
for z=-5,4 do G.quad(floor,{-4,0,z},{-4,0,z+1},{4,0,z+1},{4,0,z},z%2==0 and 2 or 3) end
scene[1]=object(floor)
scene[#scene+1]=box(8,2.6,0.18,0,1.3,5.1,3,2,4)
scene[#scene+1]=box(0.18,2.6,10,-4.1,1.3,0,3,2,4)
for _,b in ipairs(obstacles) do scene[#scene+1]=object(Models.table(b.w,b.d),b.x,0,b.z) end
local door=box(1.3,2.1,0.13,2.5,1.05,4.95,14,2,14)
local key=box(0.36,0.15,0.2,-2.7,0.35,3.5,8,13,15)
local playerRig=Models.actor(false)
local enemyRig=Models.actor(true)
local player=object(playerRig.mesh)
local enemy=object(enemyRig.mesh)
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
    local now={up=held(UP),down=held(DOWN),left=held(LEFT),right=held(RIGHT),run=held(BTN_Z),act=held(BTN_G),fire=held(BTN_E),reset=held(BTN_F)}
    local function pressed(k) return now[k] and not previous[k] end
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
            if not Game.key and dist(player,key)<1.1 then Game.key=true;message("CHAVE ENCONTRADA - PROCURE A PORTA VERDE")
            elseif dist(player,door)<1.2 then
                if Game.key then Game.state="win" else message("PORTA TRANCADA - PRECISA DE CHAVE") end
            else message("NADA AO ALCANCE") end
        end
        if pressed("fire") then
            if Game.ammo>0 then
                Game.ammo=Game.ammo-1;Game.flash=0.12
                local d=dist(player,enemy)
                local dot=(enemy.x-player.x)*math.sin(player.yaw)+(enemy.z-player.z)*math.cos(player.yaw)
                -- Line of sight: crates stop both the enemy and the shot.
                local clear=true
                if d>0.001 then for _,b in ipairs(obstacles) do
                    if G.rayBox({minx=b.x-b.w/2,maxx=b.x+b.w/2,miny=0,maxy=0.85,minz=b.z-b.d/2,maxz=b.z+b.d/2},player.x,0.7,player.z,(enemy.x-player.x)/d,0,(enemy.z-player.z)/d,d) then clear=false end
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
            Game.health=Game.health-1;Game.invulnerable=1.8;message("FERIDO! AFASTE-SE")
            if Game.health<=0 then Game.state="dead" end
        end
    end
    previous=now
end
local function text(s,x,y,c) ui.print(s,x,y,C.index[c or 9]) end
local function rect(x,y,w,h,c) ui.rectfill(x,y,x+w,y+h,C.index[c]) end
function Game.draw()
    C.register();rect(0,0,479,269,10)
    if Game.state=="menu" then
        text("ULTIMA SAIDA",182,52,15);text("SURVIVAL HORROR 3D - PROTOTIPO 0.2",105,80,9)
        text("UM DEPOSITO. UMA CHAVE. UMA CHANCE.",105,113,5)
        text("CRUZ: ANDAR / GIRAR    B: CORRER",111,145,9)
        text("A: INTERAGIR    R: DISPARAR    Y: REINICIAR",77,164,9)
        text("B: INICIAR",203,200,15)
        text("AUDIO AINDA NAO VALIDADO NO CONSOLE",106,239,11)
        return
    end
    R.begin(camera)
    for _,o in ipairs(scene) do R.submit(o) end
    R.submit(door)
    if not Game.key then R.submit(key) end
    if Game.invulnerable==0 or tick%4<2 then R.submit(player) end
    R.submit(enemy);R.flush()
    Game.triangles=R.triangles
    rect(0,0,479,19,0);rect(0,228,479,41,0)
    text("VIDA "..Game.health.."  TIROS "..Game.ammo.."  CHAVE "..(Game.key and "SIM" or "NAO"),8,5,9)
    text("FPS "..math.floor(Game.fps).." TRI "..R.triangles,340,5,5)
    if Game.timer>0 then text(Game.message,12,237,15) end
    text("A INTERAGIR  R TIRO  B CORRER  Y REINICIAR",12,255,11)
    if Game.flash>0 then rect(232,117,16,8,15) end
    if Game.stun>0 then text("ATORDOADO",200,26,8) end
    if Game.state=="win" or Game.state=="dead" then
        rect(95,88,290,75,10)
        text(Game.state=="win" and "VOCE ESCAPOU" or "VOCE NAO SOBREVIVEU",155,105,Game.state=="win" and 14 or 7)
        text("B OU Y: TENTAR NOVAMENTE",141,138,9)
    end
end


