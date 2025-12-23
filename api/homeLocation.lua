local movement = require("/api/movement")
local config = require("/api/config")

function setHome()
    local coordinates = movement.getCurrentCoordinates()

    local f = fs.open(config.STATE_DIR .. "/home", "w")
    f.write(textutils.serializeJSON(coordinates))
    f.close()
end

function getHome()
    local fExists = fs.exists(config.STATE_DIR .. "/home")
    if not fExists then
        logger("Warning home location missing!")
        return
    end

    local f = fs.open(config.STATE_DIR .. "/home", "r")
    local content = f.readAll()
    f.close()

    local json = textutils.unserializeJSON(content)

    return json
end

return { setHome = setHome, getHome = getHome }