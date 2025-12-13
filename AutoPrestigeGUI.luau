-- Metan Status GUI - Library Style
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MetanStatusGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Main Container
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(0, 350, 0, 90)
Container.Position = UDim2.new(0.5, -175, 0.03, 0)
Container.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
Container.BackgroundTransparency = 0.5
Container.BorderSizePixel = 0
Container.Parent = ScreenGui

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 10)
ContainerCorner.Parent = Container

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(52, 66, 89)
ContainerStroke.Transparency = 0.5
ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ContainerStroke.Parent = Container

-- Animated border glow
task.spawn(function()
    while true do
        TweenService:Create(ContainerStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.2
        }):Play()
        task.wait(2)
        TweenService:Create(ContainerStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.6
        }):Play()
        task.wait(2)
    end
end)

-- Brand Label
local BrandLabel = Instance.new("TextLabel")
BrandLabel.Name = "BrandLabel"
BrandLabel.Size = UDim2.new(0, 200, 0, 20)
BrandLabel.Position = UDim2.new(0, 15, 0, 12)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "Metan Hub"
BrandLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
BrandLabel.TextSize = 14
BrandLabel.TextColor3 = Color3.fromRGB(152, 181, 255)
BrandLabel.TextTransparency = 0.2
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
BrandLabel.Parent = Container

local BrandGradient = Instance.new("UIGradient")
BrandGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
BrandGradient.Parent = BrandLabel

-- Status Title
local StatusTitle = Instance.new("TextLabel")
StatusTitle.Name = "StatusTitle"
StatusTitle.Size = UDim2.new(0, 100, 0, 15)
StatusTitle.Position = UDim2.new(0, 15, 0, 38)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS"
StatusTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
StatusTitle.TextSize = 11
StatusTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = Container

-- Status Container
local StatusBox = Instance.new("Frame")
StatusBox.Name = "StatusBox"
StatusBox.Size = UDim2.new(1, -30, 0, 25)
StatusBox.Position = UDim2.new(0, 15, 0, 57)
StatusBox.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
StatusBox.BackgroundTransparency = 0.1
StatusBox.BorderSizePixel = 0
StatusBox.Parent = Container

local StatusBoxCorner = Instance.new("UICorner")
StatusBoxCorner.CornerRadius = UDim.new(0, 4)
StatusBoxCorner.Parent = StatusBox

-- Status Text
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusText"
StatusLabel.Size = UDim2.new(1, -50, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Initializing..."
StatusLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = StatusBox

local StatusGradient = Instance.new("UIGradient")
StatusGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.8, 0),
    NumberSequenceKeypoint.new(1, 0.5)
}
StatusGradient.Parent = StatusLabel

-- Loading Dots
local LoadingDots = Instance.new("TextLabel")
LoadingDots.Name = "LoadingDots"
LoadingDots.Size = UDim2.new(0, 30, 1, 0)
LoadingDots.Position = UDim2.new(1, -35, 0, 0)
LoadingDots.BackgroundTransparency = 1
LoadingDots.Text = "..."
LoadingDots.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
LoadingDots.TextSize = 14
LoadingDots.TextColor3 = Color3.fromRGB(152, 181, 255)
LoadingDots.Parent = StatusBox

-- Animated dots
task.spawn(function()
    local dots = {".", "..", "..."}
    local index = 1
    while true do
        LoadingDots.Text = dots[index]
        index = index % 3 + 1
        task.wait(0.5)
    end
end)

-- Update status function
local function updateStatus(text)
    local fadeOut = TweenService:Create(StatusLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        TextTransparency = 1
    })
    fadeOut:Play()
    fadeOut.Completed:Wait()
    
    StatusLabel.Text = text
    
    local fadeIn = TweenService:Create(StatusLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        TextTransparency = 0
    })
    fadeIn:Play()
    
    -- Flash effect
    TweenService:Create(StatusBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(42, 50, 66)
    }):Play()
    task.wait(0.2)
    TweenService:Create(StatusBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    }):Play()
end

-- Entrance animation
Container.Size = UDim2.new(0, 0, 0, 0)
Container.Position = UDim2.new(0.5, 0, 0.03, 0)

task.wait(0.3)

TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 350, 0, 90),
    Position = UDim2.new(0.5, -175, 0.03, 0)
}):Play()

_G.UpdateStatus = updateStatus

return {
    UpdateStatus = updateStatus,
    GUI = ScreenGui
}
