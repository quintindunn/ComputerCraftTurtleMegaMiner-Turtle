local movement = require("/api/movement")
local config = require("/api/config")

write("X: ")
local x = tonumber(read())
write("Y: ")
local y = tonumber(read())
write("Z: ")
local z = tonumber(read())


write("Direction (N/E/S/W): ")
local dir = string.lower(read())

if dir == "n" then
    movement.setDir(1)
elseif dir == "e" then
    movement.setDir(2)
elseif dir == "s" then
    movement.setDir(3)
elseif dir == "w" then
    movement.setDir(4)
else
    error("Invalid direction!")
end

write("Role: (miner/loader): ")
local role = string.lower(read())

if role ~= "miner" and role ~= "loader" then
    error("Invalid role!")
end

local f = fs.open(config.STATE_DIR .. "/role", "w")
f.write(role)
f.close()

movement.updateCoordinates({x, y, z})