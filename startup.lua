shell.run("clear")
print("Running calibration!")
local utils = require("/api/utils")
local movement = require("/api/movement")

local orientation = utils.calibrateOrientation()
local strOrientation = utils.numericalOrientationToString(orientation)

movement.handleHangingTransaction()


local state = utils.dumpState()

print(state)

--shell.run("/update.lua")
shell.run("/main.lua")
