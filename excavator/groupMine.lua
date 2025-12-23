local movement = require("/api/movement")
local logger = require("/api/logger").getLogger("Main")

function notifyIterationStart()
    logger("Starting Iteration")
end

function notifyIterationEnd()
    logger("Ending iteration")
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

return { iteration = iteration }