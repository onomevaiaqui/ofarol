-- Release 1.1 / BECO PRE-RENDERIZADO / 2026-11-02.
-- Keep the entry point versioned so importers can detect a changed game.lua.
require "main"
function update(frame)
    Game.step()
    Game.draw()
end


