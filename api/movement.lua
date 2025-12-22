local logger = require("/api/logger").getLogger("Movement")
local utils = require("/api/utils")
local config = require("/api/config")

local rX = 0
local rY = 0
local rZ = 0
local facing = 0
-- facing NESW -> 01234
-- north = -z east = +x south = +z west = -x

function setTransaction(action)
    local fuelLevel = turtle.getFuelLevel()
    
    local transaction = {}
    transaction.fuelLevel = fuelLevel
    transaction.action = action
    
    local f = fs.open(config.STATE_DIR .. "/currentTransaction.json", "w")
    f.write(textutils.serializeJSON(transaction))
    f.close()
end

function getNewCoordinates(action)
    local fExists = fs.exists(config.STATE_DIR .. "/dir")
    if not fExists then
        utils.calibrateOrientation()
    end

    local f = fs.open(config.STATE_DIR .. "/dir", "r")
    local dir = tonumber(f.readAll())
    f.close()

    local jExists = fs.exists(config.STATE_DIR .. "/coordinates.json", "r")
    if not jExists then
        logger("Error: Current coordinates unknown!")
        return
    end

    local j = fs.open(config.STATE_DIR .. "/coordinates.json", "r")
    local contents = j.readAll()
    j.close()

    local json = textutils.unserializeJSON(contents)
    if json == nil or json[1] == nil or json[2] == nil or json[3] == nil then
        logger("Warning: Couldn't read coordinates from JSON: `" .. contents .. "`!")
        return
    end

    local x = json[1]
    local y = json[2]
    local z = json[3]

    if action == "up" then
        y = y + 1
    elseif action == "down" then
        y = y - 1
    elseif action == "forward" then
        if dir == 1 then
            z = z - 1
        elseif dir == 2 then
            x = x + 1
        elseif dir == 3 then
            z = z + 1
        elseif dir == 4 then
            x = x - 1
        end
    elseif action == "back" then
        if dir == 1 then
            z = z + 1
        elseif dir == 2 then
            x = x - 1
        elseif dir == 3 then
            z = z - 1
        elseif dir == 4 then
            x = x + 1
        end
    else
        logger("Warning: Unknown Action!") -- fatal
        return {-99999999, -99999999, -99999999}
    end

    return {x, y, z}
end

function handleHangingTransaction()
    local fExists = fs.exists(config.STATE_DIR .. "/currentTransaction.json")
    if not fExists then
        return
    end

    local f = fs.open(config.STATE_DIR .. "/currentTransaction.json", "r")
    local contents = f.readAll()
    f.close()
    local json = textutils.unserializeJSON(contents)
    
    if json == nil then
        logger("Warning: Couldn't read transaction: `" .. contents .. "`, Unknown behavior!")
        fs.delete(config.STATE_DIR .. "/currentTransaction.json")
        return
    end

    if json["fuelLevel"] == nil then
        logger("Warning: Couldn't read fuelLevel from transaction! Cannot validate location!")
        fs.delete(config.STATE_DIR .. "/currentTransaction.json")
        return
    end

    local currentFuelLevel = turtle.getFuelLevel()
    local transactionFuelLevel = json["fuelLevel"]

    local action = json["action"]
    if action == nil then
        logger("Warning: Transaction action couldn't be read!")
        if transactionFuelLevel ~= currentFuelLevel then
            logger("Warning: Cannot read action, and fuel levels don't match! Lost location!")
            fs.delete(config.STATE_DIR .. "/currentTransaction.json")
            return
        end
    end

    if currentFuelLevel == transactionFuelLevel then
        logger("Info: Did not lose location!")
        fs.delete(config.STATE_DIR .. "/currentTransaction.json")
        return
    end

    logger("Info: Lost location, correcting!")

    local newCoordinates = {-99999999, -99999999, -99999999}
    if action == "forward" then
        newCoordinates = getNewCoordinates("forward")
    elseif action == "back" then 
        newCoordinates = getNewCoordinates("back")
    elseif action == "up" then
        newCoordinates = getNewCoordinates("up")
    elseif action == "down" then
        newCoordinates = getNewCoordinates("down")
    end
    updateCoordinates(newCoordinates)
    fs.delete(config.STATE_DIR .. "/currentTransaction.json")
end

function updateCoordinates(newCoordinates)
    if fs.exists(config.STATE_DIR .. "/coordinates.json") then
        if fs.exists(config.STATE_DIR .. "/coordinates.json.copy") then
            fs.delete(config.STATE_DIR .. "/coordinates.json.copy")
        end
        fs.copy(config.STATE_DIR .. "/coordinates.json", config.STATE_DIR .. "/coordinates.json.copy")
    end
    local f = fs.open(config.STATE_DIR .. "/coordinates.json", "w")
    f.write(textutils.serializeJSON(newCoordinates))
    f.close()    
end

function up()
    utils.doRefuelIfNeeded()
    setTransaction("up")
    local worked = turtle.up()
    if worked then
        updateCoordinates(getNewCoordinates("up"))
    end
    fs.delete(config.STATE_DIR .. "/currentTransaction.json")

    return worked
end

function down()
    utils.doRefuelIfNeeded()
    setTransaction("down")
    local worked = turtle.down()
    if worked then
        updateCoordinates(getNewCoordinates("down"))
    end
    fs.delete(config.STATE_DIR .. "/currentTransaction.json")

    return worked
end

function forceForward()
    local worked = false
    while not worked do
        if turtle.detect() then
            turtle.dig()
        end
        worked = forward()
        if not worked then
            turtle.attack()
        end
    end
end


function forward()
    utils.doRefuelIfNeeded()
    setTransaction("forward")
    local worked = turtle.forward()
    if worked then
        updateCoordinates(getNewCoordinates("forward"))
    end
    fs.delete(config.STATE_DIR .. "/currentTransaction.json")

    return worked
end

function back()
    utils.doRefuelIfNeeded()
    setTransaction("back")
    local worked = turtle.back()
    if worked then
        updateCoordinates(getNewCoordinates("back"))
    end
    fs.delete(config.STATE_DIR .. "/currentTransaction.json")

    return worked
end

function setDir(dir)
    local f = fs.open(config.STATE_DIR .. "/dir", "w")
    f.write(dir)
    f.close()
end

function right()
    local f = fs.open(config.STATE_DIR .. "/dir", "r")
    local dir = tonumber(f.readAll()) + 1
    f.close()

    if dir == 5 then
        dir = 1
    end

    local f = fs.open(config.STATE_DIR .. "/dir", "w")
    f.write(dir)
    f.close()
    return turtle.turnRight()
end

function left()
    local f = fs.open(config.STATE_DIR .. "/dir", "r")
    local dir = tonumber(f.readAll()) - 1
    f.close()

    if dir == 0 then
        dir = 4
    end

    local f = fs.open(config.STATE_DIR .. "/dir", "w")
    f.write(dir)
    f.close()
    return turtle.turnLeft()
end

function getCurrentCoordinates()
    local fExists = fs.exists(config.STATE_DIR .. "/coordinates.json", "r")
    if not fExists then
        logger("Error: Current coordinates unknown!")
        return {-99999999, -99999999, -99999999}
    end

    local f = fs.open(config.STATE_DIR .. "/coordinates.json", "r")
    local contents = f.readAll()
    f.close()

    local json = textutils.unserializeJSON(contents)
    if json == nil or json[1] == nil or json[2] == nil or json[3] == nil then
        logger("Warning: Couldn't read coordinates from JSON: `" .. contents .. "`!")
        return {-99999999, -99999999, -99999999}
    end
    
    return { json[1], json[2], json[3] }
end

function faceDir(dir) -- TODO: OPTIMIZE
    local leftDir = utils.getDir() - 1
    if leftDir == 0 then
        leftDir = 4
    end

    if leftDir == dir then
        left()
        return
    end
    
    while utils.getDir() ~= dir do
        right()
    end
end

function goTo(nx, ny, nz)
    local cur = getCurrentCoordinates()
    local cx = cur[1]
    local cy = cur[2]
    local cz = cur[3]

    local dx = nx - cx
    local dy = ny - cy
    local dz = nz - cz

    -- Move for Y movement
    if dy > 0 then
        dy = math.abs(dy)
        local i = 0
        while i < dy do
            if turtle.detectUp() then
                turtle.digUp()
            end
            if not up() then
                i = i - 1
            end
            i = i + 1
        end
    elseif dy < 0 then
        dy = math.abs(dy)
        local i = 0
        while i < dy do
            if turtle.detectDown() then
                turtle.digDown()
            end
            if not down() then
                i = i - 1
            end
            i = i + 1
        end
    end

    -- Face direction for x movement
    if dx > 0 then
        faceDir(2)
    elseif dx < 0 then
        faceDir(4)
    end

    -- Move for x movement
    dx = math.abs(dx)
    local i = 0
    while i < dx do
        if turtle.detect() then
            turtle.dig()
        end
        if not forward() then
            i = i - 1
        end
        i = i + 1
    end

    -- Face direction for z movement
    if dz > 0 then
        faceDir(3)
    elseif dz < 0 then
        faceDir(1)
    end

    -- Move for z movement
    dz = math.abs(dz)
    local i = 0
    while i < dz do
        if turtle.detect() then
            turtle.dig()
        end
        if not forward() then
            i = i - 1
        end
        i = i + 1
    end
end

function getChunkSWCoordinates()
    local coordinates = getCurrentCoordinates()
    local cx = coordinates[1]
    local cz = coordinates[3]

    local nx = math.floor(cx / 16) * 16
    local nz = math.floor(cz / 16) * 16 + 15

    return {nx, coordinates[2], nz}

    -- if cx > 0 and cz > 0 then
    --     return getChunkSWCoordinatesPXPZ()
    -- elseif cx < 0 and cz < 0 then
    --     return getChunkSWCoordinatesNXNZ()
    -- end
    
end

function getChunkSWCoordinatesPXPZ()
    print("+X+Z")
    local coordinates = getCurrentCoordinates()
    local cx = coordinates[1]
    local ny = coordinates[2]
    local cz = coordinates[3]
    
    local nx = math.floor(cx / 16) * 16
    local nz = math.floor(cz / 16) * 16

    return { nx, ny, nz}
end

function getChunkSWCoordinatesNXNZ()
    print("-X-Z")
    local coordinates = getCurrentCoordinates()
    local cx = coordinates[1]
    local ny = coordinates[2]
    local cz = coordinates[3]
    
    local nx = math.floor(cx / 16) * 16 - 16
    local nz = math.floor(cz / 16) * 16 - 1

    return { nx, ny, nz}
end

function goToChunkSWCorner()
   local target = getChunkSWCoordinates()
   goTo(target[1], target[2], target[3]) 
end


return { setDir = setDir, forceForward = forceForward, faceDir = faceDir, getCurrentCoordinates = getCurrentCoordinates, goToChunkSWCorner = goToChunkSWCorner, goTo = goTo, back = back, forward = forward, up = up, down = down, right = right, left = left, handleHangingTransaction = handleHangingTransaction, updateCoordinates = updateCoordinates }
