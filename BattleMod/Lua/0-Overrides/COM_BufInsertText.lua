-- OVERRIDE FILE
-- This should replace `COM_BufInsertText` with a version that accounts for many netxcmd buffer commands.

local cons_queue = "cmd_queue"     -- Name of the console command
local queue = {}         -- Commands to execute
local received = true         -- Whether we received the last command sent
local function execute_next()
    if not received or #queue == 0 then return end

    COM_BufAddText(consoleplayer, table.remove(queue, 1))
    COM_BufAddText(consoleplayer, cons_queue)
    received = false
end

local function command_queue(player, cmd)
    table.insert(queue, cmd)
    execute_next()
end
rawset(_G, "COM_BufInsertText", command_queue)

COM_AddCommand(cons_queue, function(p)
    if (p ~= consoleplayer) and (p ~= server) then return end
    received = true
    execute_next()
end)

addHook("GameQuit", function(quit)
    if quit then return end
    queue = {}
end)