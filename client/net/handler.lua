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
    local role = utils.getRole()

    if role == "miner" then
        excavator.iteration()
    elseif role == "loader" then
        movement.forceForward()
    end
end

function dumpUpHandler()
    local role = utils.getRole()
    if role == "miner" then
        logger("Dumping inventory")
        utils.dumpInventory()
    end
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

function goHomeHandler()
    logger("Going home!")
    excavator.goHome()
end

function restoreHandler()
    excavator.goToRestorePoint()
end

function refuelHandler()
    excavator.refuel()
end

function executeHandler(json)
    local command = json["command"]
    
    local fn, err = loadstring(command)
    if not fn then
       logger(err)
    end

    local ok, err = pcall(fn)
    if not ok then
        logger(err)
    end
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
        moveForwardHandler(json)
        netCore.sendState()
    elseif msgType == "moveUp" then
        moveUpHandler(json)
        netCore.sendState()
    elseif msgType == "moveDown" then
        moveDownHandler(json)
        netCore.sendState()
    elseif msgType == "moveBack" then
        moveBackHandler(json)
        netCore.sendState()
    elseif msgType == "iterate" then
        iterateHandler(json)
        netCore.sendState()
    elseif msgType == "dumpUp" then
        dumpUpHandler(json)
    elseif msgType == "setHome" then
        setHomeHandler(json)
    elseif msgType == "reboot" then
        rebootHandler(json)
    elseif msgType == "execute" then
        executeHandler(json)
    elseif msgType == "home" then
        goHomeHandler(json)
    elseif msgType == "restore" then
        restoreHandler(json)
    elseif msgType == "refuel" then
        refuelHandler(json)
    end

end

return { handle = handle }