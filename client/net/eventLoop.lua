local core = require("/client/net/core")
local handler = require("/client/net/handler")

function runLoop()
    local ws = core.connect()

    while true do
        local ok, msg = pcall(function()
            return ws.receive(1)
        end)
        if not ok then
            repeat
                ws = core.connect()
                sleep(1)
            until ws ~= nil
        elseif msg then
            handler.handle(msg)
        end
    end
end

return { runLoop = runLoop }