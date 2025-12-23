local core = require("/client/net/core")
local handler = require("/client/net/handler")

function runLoop()
    local ws = core.connect()
    core.sendState()

    while true do
        local ok, msg = pcall(ws.receive, ws, 1)
        if not ok then
            core.clearWS()
            repeat
                ws = core.connect()
            until ws
        elseif msg then
            handler.handle(msg)
        end
    end
end

return { runLoop = runLoop }