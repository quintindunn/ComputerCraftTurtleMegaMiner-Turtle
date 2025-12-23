local externalInventoryUtils = require("/api/externalInventoryUtils")
local inventoryUtils = require("/api/inventoryUtils")
local logger = require("/api/logger").getLogger("Utils")
local config = require("/api/config")

function numericalOrientationToString(orientation)
    if orientation == 1 then
        return "north"
    elseif orientation == 2 then
        return "east"
    elseif orientation == 3 then
        return "south"
    elseif orientation == 4 then
        return "west"
    else
        return "ORIENTATION UNKNOWN!"
    end
end

function calibrateOrientation()
    logger("Direction calibration offline!")
end

function dumpInventory()
    local initialSlot = turtle.getSelectedSlot()

    for i = 2, 16 do
        turtle.select(i)
        turtle.drop(64)
    end

    turtle.select(initialSlot)
end

function doRefuel() 
    logger("Warning: Refueling not implemented!")
end

function doRefuelIfNeeded()
    if turtle.getFuelLevel() < config.MIN_FUEL_LEVEL then
        doRefuel()
    end
end

function getDir()
    local dirFileExists = fs.exists(config.STATE_DIR .. "/dir")
    if dirFileExists then
        local fdir = fs.open(config.STATE_DIR .. "/dir", "r")
        local dir = tonumber(fdir.readAll())
        return dir
    end
    logger("Warning: Dir file missing!")
    return
end

function dumpState()
    local dirFileExists = fs.exists(config.STATE_DIR .. "/dir")
    local coordinateFileExists = fs.exists(config.STATE_DIR .. "/coordinates.json")

    local output = "Fuel Level: " .. turtle.getFuelLevel() .. "\n"
    if dirFileExists then
        local fdir = fs.open(config.STATE_DIR .. "/dir", "r")
        local dir = tonumber(fdir.readAll())
        output = output .. "Facing: " .. numericalOrientationToString(dir) .. "\n"
    end

    if coordinateFileExists then
        local fcoordinates = fs.open(config.STATE_DIR .. "/coordinates.json", "r")
        local contents = fcoordinates.readAll()
        fcoordinates.close()

        local json = textutils.unserializeJSON(contents)

        if json == nil then
            output = output .. "Error reading coordinates!\n"
        else
            output = output .. "X: " .. json[1] .. "\n" .. "Y: " .. json[2] .. "\n" .. "Z: " .. json[3] .. "\n"
        end
    else
        output = output .. "Error reading coordinates!\n"
    end

    return output
end

return { dumpInventory = dumpInventory, getDir = getDir, dumpState = dumpState, calibrateOrientation = calibrateOrientation, numericalOrientationToString = numericalOrientationToString, doRefuel = doRefuel, doRefuelIfNeeded = doRefuelIfNeeded }

