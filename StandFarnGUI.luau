-- ShinyFarm Status GUI
-- Загрузи этот файл В НАЧАЛЕ ShinyFarmSimple.lua после getgenv().ShinyFarm

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Lighting = game:GetService("Lighting")

-- Блюр
local Blur = Instance.new("BlurEffect")
Blur.Name = "ShinyFarmBlur"
Blur.Size = 24
Blur.Parent = Lighting

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShinyFarmStatus"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Name = "StatusFrame"
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Position = UDim2.new(0.5, -150, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ShinyFarm Status"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Frame

local StandLabel = Instance.new("TextLabel")
StandLabel.Name = "Stand"
StandLabel.Size = UDim2.new(1, -20, 0, 25)
StandLabel.Position = UDim2.new(0, 10, 0, 65)
StandLabel.BackgroundTransparency = 1
StandLabel.Text = "Stand: None"
StandLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
StandLabel.TextSize = 14
StandLabel.Font = Enum.Font.Gotham
StandLabel.TextXAlignment = Enum.TextXAlignment.Left
StandLabel.Parent = Frame

local SkinLabel = Instance.new("TextLabel")
SkinLabel.Name = "Skin"
SkinLabel.Size = UDim2.new(1, -20, 0, 25)
SkinLabel.Position = UDim2.new(0, 10, 0, 90)
SkinLabel.BackgroundTransparency = 1
SkinLabel.Text = "Skin: None"
SkinLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
SkinLabel.TextSize = 14
SkinLabel.Font = Enum.Font.Gotham
SkinLabel.TextXAlignment = Enum.TextXAlignment.Left
SkinLabel.Parent = Frame

local RokaLabel = Instance.new("TextLabel")
RokaLabel.Name = "Roka"
RokaLabel.Size = UDim2.new(1, -20, 0, 25)
RokaLabel.Position = UDim2.new(0, 10, 0, 115)
RokaLabel.BackgroundTransparency = 1
RokaLabel.Text = "Rokakaka: 0 | Arrows: 0"
RokaLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
RokaLabel.TextSize = 14
RokaLabel.Font = Enum.Font.Gotham
RokaLabel.TextXAlignment = Enum.TextXAlignment.Left
RokaLabel.Parent = Frame

local PityLabel = Instance.new("TextLabel")
PityLabel.Name = "Pity"
PityLabel.Size = UDim2.new(1, -20, 0, 25)
PityLabel.Position = UDim2.new(0, 10, 0, 140)
PityLabel.BackgroundTransparency = 1
PityLabel.Text = "Pity: 0"
PityLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
PityLabel.TextSize = 14
PityLabel.Font = Enum.Font.Gotham
PityLabel.TextXAlignment = Enum.TextXAlignment.Left
PityLabel.Parent = Frame

-- Функции обновления
getgenv().ShinyFarmGUI = {
    SetStatus = function(text)
        StatusLabel.Text = "Status: " .. text
    end,
    Update = function()
        pcall(function()
            -- Stand
            local stand = Player.PlayerStats.Stand.Value
            StandLabel.Text = "Stand: " .. (stand ~= "None" and stand or "None")
            
            -- Skin
            local skin = "None"
            if Player.Character and Player.Character:FindFirstChild("RemoteFunction") then
                skin = Player.Character.RemoteFunction:InvokeServer("ReturnStandSkin", "Stand") or "None"
            end
            SkinLabel.Text = "Skin: " .. skin
            
            -- Items
            local rokas, arrows = 0, 0
            for _, v in pairs(Player.Backpack:GetChildren()) do
                if v.Name == "Rokakaka" then rokas = rokas + 1 end
                if v.Name == "Mysterious Arrow" then arrows = arrows + 1 end
            end
            RokaLabel.Text = "Rokakaka: " .. rokas .. " | Arrows: " .. arrows
            
            -- Pity
            local pity = Player.PlayerStats.Pity.Value
            PityLabel.Text = "Pity: " .. pity
        end)
    end
}

-- Автообновление
task.spawn(function()
    while task.wait(0.5) do
        getgenv().ShinyFarmGUI.Update()
    end
end)

print("[ShinyFarmGUI] Loaded!")
