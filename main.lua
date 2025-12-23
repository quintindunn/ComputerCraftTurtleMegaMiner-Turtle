local netCore = require("/client/net/core")
local eventLoop = require("/client/net/eventLoop")


netCore.connect()
netCore.sendState()
eventLoop.runLoop()