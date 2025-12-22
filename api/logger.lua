local loggers = {}

function getLogger(name)
    if loggers[name] == nil then
        local function logger(msg)
            log(name, msg)
        end
        loggers[name] = logger
    end
    
    return loggers[name]
end
    
function getDate()
    local unixEpoch = os.epoch("utc")
    -- YYYY-MM-DD
    local format = "%m/%d %H:%M:%S"
    local date = os.date(format)
    return date
end

function log(src, msg)
    print(string.format("%s-%s:%s", getDate(), src, msg))
end

return { getLogger = getLogger }
-- log("Logger", "Hello World!")
