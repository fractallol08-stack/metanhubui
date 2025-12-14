local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local PlaceID = game.PlaceId
local Player = Players.LocalPlayer

local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour

local function ServerHop()
    local Site
    local url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'
    
    if foundAnything ~= "" then
        url = url .. '&cursor=' .. foundAnything
    end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if not success then
        TeleportService:Teleport(PlaceID, Player)
        return
    end
    
    Site = result
    
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    
    local bestServer = nil
    local lowestPlayers = math.huge
    
    for _, server in pairs(Site.data) do
        local serverID = tostring(server.id)
        local canJoin = true
        
        if server.id == game.JobId then
            canJoin = false
        end
        
        if server.playing >= server.maxPlayers then
            canJoin = false
        end
        
        for _, blockedID in pairs(AllIDs) do
            if serverID == tostring(blockedID) then
                canJoin = false
                break
            end
        end
        
        if canJoin and server.playing < lowestPlayers then
            lowestPlayers = server.playing
            bestServer = server
        end
    end
    
    if bestServer then
        table.insert(AllIDs, bestServer.id)
        
        pcall(function()
            if writefile then
                writefile("ServerHopBlocker.json", HttpService:JSONEncode(AllIDs))
            end
        end)
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceID, bestServer.id, Player)
        end)
        
        if not success then
            task.wait(2)
            TeleportService:Teleport(PlaceID, Player)
        end
        
        return true
    end
    
    if foundAnything ~= "" then
        return ServerHop()
    end
    
    TeleportService:Teleport(PlaceID, Player)
    return false
end

TeleportService.TeleportInitFailed:Connect(function()
    task.wait(2)
    ServerHop()
end)

if readfile and isfile("ServerHopBlocker.json") then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile("ServerHopBlocker.json"))
    end)
    
    if success and data then
        AllIDs = data
        
        if AllIDs[1] and tonumber(actualHour) ~= tonumber(AllIDs[1]) then
            AllIDs = {}
            table.insert(AllIDs, actualHour)
            if writefile then
                writefile("ServerHopBlocker.json", HttpService:JSONEncode(AllIDs))
            end
        end
    end
else
    table.insert(AllIDs, actualHour)
end

return ServerHop
