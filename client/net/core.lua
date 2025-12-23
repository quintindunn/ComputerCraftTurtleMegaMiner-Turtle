local config = require("/api/config")
local movement = require("/api/movement")
local getName = require("/api/getName")

ws = nil

function connect()
    ws = http.websocket(config.WS_URL)
    if not ws then
        print("Couldn't connect to websocket!")
    end
    return ws
end

function verifyConnected()
    if not ws then
        error("Not connected to websocket server!")
    end
end

function sendJSON(packet)
    verifyConnected()
    local serialized = textutils.serializeJSON(packet)

    ws.send(serialized)
end

function sendIterationStart()
    local packet = {
        type = "iterationStart"
    }
    sendJSON(packet)
end

function sendIterationEnd()
    local packet = {
        type = "iterationEnd"
    }
    sendJSON(packet)
end

function sendState()
    local coordinates = movement.getCurrentCoordinates()
    local packet = {
        role = "slave",
        type = "sendState",
        x = coordinates[1],
        y = coordinates[2],
        z = coordinates[3],
        direction = movement.getDir(),
        name = getName.getName(),
        hash = getName.getHash()
    }
    sendJSON(packet)
end

function getWS()
    return ws
end

function disconnect()
    verifyConnected()
    ws.close()
end

function clearWS()
    ws = nil
end

return { clearWS = clearWS, sendIterationStart = sendIterationStart, sendIterationEnd = sendIterationEnd, getWS = getWS, sendState = sendState, disconnect = disconnect, connect = connect, verifyConnected = verifyConnected, sendJSON = sendJSON }