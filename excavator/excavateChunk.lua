local logger = require("/api/logger").getLogger("excavateChunk")
local movement = require("/api/movement")
local utils = require("/api/utils")

function excavateCurrentChunk(maxY, minY)
    local chunkSize = 16 -- HERE FOR DEBUGGING, CANNOT BE > 16
    movement.goToChunkSWCorner()

    local currentCoordinates = movement.getCurrentCoordinates()
    
    local left = false
    for i = 1, (maxY-minY)+1 do
        movement.goTo(currentCoordinates[1], maxY - (i-1), currentCoordinates[3])
        movement.faceDir(1)
        for j = 1, chunkSize do
            for k = 1, chunkSize-1 do
                turtle.dig()
                movement.forceForward()
            end
            local changeDir = nil
            if left then
                changeDir = movement.left
                left = false
            else
                changeDir = movement.right
                left = true
            end
            if j ~= chunkSize then
                changeDir()
                turtle.dig()
                movement.forceForward()
                changeDir()
            end
        end
        movement.faceDir(4)
        utils.dumpInventory()
    end
    movement.goToChunkSWCorner()
end


return { excavateCurrentChunk = excavateCurrentChunk }