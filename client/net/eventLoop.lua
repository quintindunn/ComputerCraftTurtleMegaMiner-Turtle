local core = require("/api/net/core")

local msgSendBuffer = {}
local msgRecvBuffer = {}



function runLoop()
    local ws = core.getWS()
    while true do
        local msg = ws.receive(1)
        if msg then
            print(msg)
        end
    end
end

return { runLoop = runLoop }