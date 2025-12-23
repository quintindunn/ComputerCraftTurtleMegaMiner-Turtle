local movement = require("/api/movement")

function moveForwardHandler()
    movement.forward()
end

function moveBackHandler()
    movement.back()
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
    end

    if msgType == "moveBack" then
        moveBackHandler(msg)
    end
end

return { handle = handle }