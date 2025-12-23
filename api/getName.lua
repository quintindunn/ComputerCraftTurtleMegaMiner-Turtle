local config = require("/api/config")

math.randomseed(os.time())

local adjectives = {
    "Blocky", "Creepy", "Redstone", "Ender", "Pixel",
    "Iron", "Diamond", "Obsidian", "Nether", "Crafty",
    "Ancient", "Swift", "Dark", "Brave", "Lucky",
    "Silent", "Fiery", "Frosty", "Savage", "Epic",
    "Golden", "Shadow", "Glitched", "Mythic", "Rugged",
    "Wild", "Heavy", "Quick", "Arcane", "Hidden"
}

local nouns = {
    "Miner", "Steve", "Alex", "Crafter", "Builder",
    "Creeper", "Zombie", "Skeleton", "Golem", "Dragon",
    "Wither", "Villager", "Pillager", "Warden", "Slime",
    "Enderman", "Ghast", "Blaze", "Piglin", "Hoglin",
    "Shulker", "Phantom", "Guardian", "Ravager", "Strider",
    "Axolotl", "Allay", "Sniffer", "Evoker", "Vindicator"
}

function randomUsername()
    local adj = adjectives[math.random(#adjectives)]
    local noun = nouns[math.random(#nouns)]
    local number = math.random(0, 99999)
    return adj .. noun .. number
end

function setName()
    local name = randomUsername()

    local f = fs.open(config.STATE_DIR .. "/name", "w")
    f.write(name)
    f.close()
end

function setNameIfNotSet()
    local fExists = fs.exists(config.STATE_DIR .. "/name")

    if not fExists then
        setName()
        return
    end

    local f = fs.open(config.STATE_DIR .. "/name", "r")
    local contents = f.readAll()
    f.close()

    if contents == "" then
        setName()
    end
end

function getName()
    setNameIfNotSet()

    local f, x = fs.open(config.STATE_DIR .. "/name", "r")
    local contents = f.readAll()
    f.close()
    return contents
end

function hashUsernameHex(username)
    local hash = 5381
    for i = 1, #username do
        hash = ((hash * 33) + hash) + string.byte(username, i)
        hash = hash % 0x100000000
    end
    return string.format("%08x", hash)
end

function getHash()
    return hashUsernameHex(getName())
end

return { getName = getName, getHash = getHash }