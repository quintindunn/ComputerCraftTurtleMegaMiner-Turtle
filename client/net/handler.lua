local movement = require("/api/movement")
local netCore = require("/client/net/core")
local excavator = require("/excavator/groupMine")
local utils = require("/api/utils")

function moveForwardHandler()
    movement.forward()
end

function moveBackHandler()
    movement.back()
end

function iterateHandler()
    excavator.iteration()
end

function dumpUpHandler()
    utils.dumpInventory()
end


function handle(msg)
    local json = textutils.unserializeJSON(msg)

    local err = json["error"]

    if err then
        print(err)
        return
    end

    local msgType = json["type"]

    if msgType == "moveForward" then
        moveForwardHandler(msg)
        netCore.sendState()
    elseif msgType == "moveBack" then
        moveBackHandler(msg)
        netCore.sendState()
    elseif msgType == "iterate" then
        iterateHandler(msg)
        netCore.sendState()
    elseif msgType == "dumpUp" then
        dumpUpHandler(msg)
    end

end

return { handle = handle }