local movement = require("/api/movement")

write("X: ")
local x = tonumber(read())
write("Y: ")
local y = tonumber(read())
write("Z: ")
local z = tonumber(read())

movement.updateCoordinates({x, y, z})
