local netCore = require("/api/net/core")
local eventLoop = require("/api/net/eventLoop")


netCore.connect()
netCore.sendState()
eventLoop.runLoop()