-- Release 1.4 / MANSAO 3D LUA / 2026-11-02.
-- Keep the entry point versioned so importers can detect a changed game.lua.
require "main"
function update(frame)
    Game.step()
    Game.draw()
end
