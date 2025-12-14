getgenv().lessPing = true
getgenv().sortOrder = "Asc"

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local PlaceID = game.PlaceId
local Player = Players.LocalPlayer
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour

local function TPReturner()
    local Site
    if foundAnything == "" then
        Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100'))
    else
        Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100&cursor=' .. foundAnything))
    end
    
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    
    local num = 0
    for _, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        pcall(function()
                            delfile("ServerHopBlocker.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                task.wait()
                pcall(function()
                    writefile("ServerHopBlocker.json", HttpService:JSONEncode(AllIDs))
                    task.wait()
                    TeleportService:TeleportToPlaceInstance(PlaceID, ID, Player)
                end)
                task.wait(4)
            end
        end
    end
end

local function ServerHop()
    while task.wait() do
        pcall(function()
            if getgenv().lessPing then
                TeleportService:Teleport(PlaceID, Player)
                
                TeleportService.TeleportInitFailed:Connect(function()
                    TeleportService:Teleport(PlaceID, Player)
                end)
                
                repeat task.wait() until game.JobId ~= game.JobId
            end
            
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

TeleportService.TeleportInitFailed:Connect(function()
    task.wait(2)
    ServerHop()
end)

if readfile and isfile("ServerHopBlocker.json") then
    pcall(function()
        AllIDs = HttpService:JSONDecode(readfile("ServerHopBlocker.json"))
    end)
end

return ServerHop
