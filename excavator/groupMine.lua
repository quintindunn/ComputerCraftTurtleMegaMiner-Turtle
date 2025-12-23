local movement = require("/api/movement")
local logger = require("/api/logger").getLogger("Main")
local netCore = require("/client/net/core")
local utils = require("/api/utils")
local homeUtils = require("/api/homeLocation")
local config = require("/api/config")

function notifyIterationStart()
    logger("Starting Iteration")
    netCore.sendIterationStart()
end

function notifyIterationEnd()
    logger("Ending iteration")
    netCore.sendIterationEnd()
end

function iteration()
    notifyIterationStart()
    movement.forceForward()

    local startCoordinates = movement.getCurrentCoordinates()

    local failCount = 0
    while true do
        turtle.digDown()
        local worked = movement.down()

        if not worked then
            failCount = failCount + 1
        end

        if failCount > 10 then
            break
        end
    end

    movement.goTo(startCoordinates[1], startCoordinates[2], startCoordinates[3])
    notifyIterationEnd()
end

function moveLinear(nx, ny, nz)
    notifyIterationStart()
    local coordinates = movement.getCurrentCoordinates()
    local cx = coordinates[1]
    local cy = coordinates[2]
    local cz = coordinates[3]

    local dx = nx - cx
    local dy = ny - cy
    local dz = nz - cz


    if cx ~= nx and cz ~= nz then
        logger("Cannot change both X-axis and Z-axis")
        error("Cannot change both X-axis and Z-axis")
    end

    -- Go to correct Y if it needs to go up
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
    end

    local dir = utils.getDir()

    if nx ~= cx then
        local fn = nil
        if dir == 4 and dx > 0 then
            fn = movement.back
        elseif dir == 4 and dx < 0 then
            fn = movement.forward
        elseif dir == 2 and dx > 0 then
            fn = movement.forward
        elseif dir == 2 and dx < 0 then
            fn = movement.back
        end

        dx = math.abs(dx)
        local i = 0
        while i < dx do
            if turtle.detect() then
            end
            if not fn() then
                i = i - 1
                -- Really hope this doesn't happen because it causes instability
                if fn == movement.back then
                    movement.left() 
                    movement.left()
                end
                turtle.dig()
                if fn == movement.back then
                    movement.left()
                    movement.left()
                end
            end
            i = i + 1
        end
    else
        local fn = nil
        if dir == 3 and dz > 0 then
            fn = movement.forward
        elseif dir == 3 and dz < 0 then
            fn = movement.back
        elseif dir == 1 and dz > 0 then
            fn = movement.back
        elseif dir == 1 and dz < 0 then
            fn = movement.forward
        end

        dz = math.abs(dz)
        local i = 0
        while i < dz do
            if turtle.detect() then
            end
            if not fn() then
                i = i - 1
                -- Really hope this doesn't happen because it causes instability
                if fn == movement.back then
                    movement.left() 
                    movement.left()
                end
                turtle.dig()
                if fn == movement.back then
                    movement.left()
                    movement.left()
                end
            end
            i = i + 1
        end
    end

    if dy < 0 then -- Go to correct y if it needs to go down
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
    notifyIterationEnd()
end

function setRestorePoint()
    local coordinates = movement.getCurrentCoordinates()
    local f = fs.open(config.STATE_DIR .. "/restorePoint", "w")
    f.write(textutils.serializeJSON(coordinates))
    f.close()
end

function goToRestorePoint()
    local fExists = fs.exists(config.STATE_DIR .. "/restorePoint")
    
    if not fExists then
        logger("Warning restore point doesn't exist!")
        return
    end

    local f = fs.open(config.STATE_DIR .. "/restorePoint", "r")
    local content = f.readAll()
    f.close()

    local coordinates = textutils.unserializeJSON(content)

    moveLinear(coordinates[1], coordinates[2], coordinates[3])
end

function goHome(SkipSetRestorePoint)
    if not SkipSetRestorePoint then
        setRestorePoint()
    end
    local homeCoordinates = homeUtils.getHome()
    local nx = homeCoordinates[1]
    local ny = homeCoordinates[2]
    local nz = homeCoordinates[3]
    moveLinear(nx, ny, nz)
end

function refuel()
    notifyIterationStart()
    local initialCoordinates = movement.getCurrentCoordinates()
    goHome(true)

    local initialSlot = turtle.getSelectedSlot()

    turtle.select(1)
    while turtle.getFuelLevel() < turtle.getFuelLimit() - 1000 do
        turtle.placeDown()
        turtle.refuel()
    end

    turtle.select(initialSlot)
    movement.goTo(initialCoordinates[1], initialCoordinates[2], initialCoordinates[3])
    notifyIterationEnd()
end

return { goToRestorePoint = goToRestorePoint, iteration = iteration, refuel = refuel, moveLinear = moveLinear, goHome = goHome }