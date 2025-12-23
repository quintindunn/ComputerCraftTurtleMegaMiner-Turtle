local movement = require("/api/movement")
local netCore = require("/client/net/core")
local excavator = require("/excavator/groupMine")
local utils = require("/api/utils")
local homeUtils = require("/api/homeLocation")
local logger = require("/api/logger").getLogger("Handler")

function moveForwardHandler()
    logger("Moving forward")
    movement.forward()
end

function moveUpHandler()
    logger("Moving up")
    movement.up()
end

function moveDownHandler()
    logger("Moving down")
    movement.down()
end

function moveBackHandler()
    logger("Moving back")
    movement.back()
end

function iterateHandler()
    logger("Running iteration")
    excavator.iteration()
end

function dumpUpHandler()
    logger("Dumping inventory")
    utils.dumpInventory()
end

function setHomeHandler()
    logger("Setting home")
    homeUtils.setHome()
end

function rebootHandler()
    logger("Rebooting!")
    netCore.disconnect()
    shell.run("reboot")
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
    elseif msgType == "moveUp" then
        moveUpHandler(msg)
        netCore.sendState()
    elseif msgType == "moveDown" then
        moveDownHandler(msg)
        netCore.sendState()
    elseif msgType == "moveBack" then
        moveBackHandler(msg)
        netCore.sendState()
    elseif msgType == "iterate" then
        iterateHandler(msg)
        netCore.sendState()
    elseif msgType == "dumpUp" then
        dumpUpHandler(msg)
    elseif msgType == "setHome" then
        setHomeHandler(msg)
    elseif msgType == "reboot" then
        rebootHandler(msg)
    end

end

return { handle = handle }