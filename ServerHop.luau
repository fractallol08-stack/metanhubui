local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local PlaceID = game.PlaceId
local Player = Players.LocalPlayer

local function ServerHop()
    TeleportService:Teleport(PlaceID, Player)
end

TeleportService.TeleportInitFailed:Connect(function()
    task.wait(2)
    TeleportService:Teleport(PlaceID, Player)
end)

return ServerHop
