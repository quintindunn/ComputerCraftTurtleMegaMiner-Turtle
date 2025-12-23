local core = require("/client/net/core")
local handler = require("/client/net/handler")

local msgSendBuffer = {}
local msgRecvBuffer = {}



function runLoop()
    local ws = core.getWS()
    while true do
        local msg = ws.receive(1)
        if msg then
            handler.handle(msg)
        end
    end
end

return { runLoop = runLoop }