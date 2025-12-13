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
Container.Size = UDim2.new(0, 420, 0, 105)
Container.Position = UDim2.new(0.5, -210, 0.03, 0)
Container.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
Container.BackgroundTransparency = 0.4
Container.BorderSizePixel = 0
Container.ClipsDescendants = true
Container.Parent = ScreenGui

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 10)
ContainerCorner.Parent = Container

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(152, 181, 255)
ContainerStroke.Thickness = 1.5
ContainerStroke.Transparency = 0.5
ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ContainerStroke.Parent = Container

-- Animated background gradient
local BackgroundGradient = Instance.new("Frame")
BackgroundGradient.Name = "BackgroundGradient"
BackgroundGradient.Size = UDim2.new(2, 0, 2, 0)
BackgroundGradient.Position = UDim2.new(-0.5, 0, -0.5, 0)
BackgroundGradient.BackgroundTransparency = 0.7
BackgroundGradient.BorderSizePixel = 0
BackgroundGradient.ZIndex = 0
BackgroundGradient.Parent = Container

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(0, 10)
BGCorner.Parent = BackgroundGradient

local BGGradient = Instance.new("UIGradient")
BGGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 66, 89)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(32, 48, 78)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 66, 89))
}
BGGradient.Rotation = 45
BGGradient.Parent = BackgroundGradient

-- Animate background gradient rotation
task.spawn(function()
    while true do
        TweenService:Create(BGGradient, TweenInfo.new(8, Enum.EasingStyle.Linear), {
            Rotation = BGGradient.Rotation + 360
        }):Play()
        task.wait(8)
    end
end)

-- Animated border glow
task.spawn(function()
    while true do
        TweenService:Create(ContainerStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.2,
            Color = Color3.fromRGB(180, 200, 255)
        }):Play()
        task.wait(2)
        TweenService:Create(ContainerStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.6,
            Color = Color3.fromRGB(152, 181, 255)
        }):Play()
        task.wait(2)
    end
end)

-- Accent line at top
local AccentLine = Instance.new("Frame")
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 0)
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 2
AccentLine.Parent = Container

local AccentGradient = Instance.new("UIGradient")
AccentGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(152, 181, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
}
AccentGradient.Parent = AccentLine

-- Animate accent line
task.spawn(function()
    while true do
        TweenService:Create(AccentGradient, TweenInfo.new(3, Enum.EasingStyle.Linear), {
            Offset = Vector2.new(1, 0)
        }):Play()
        task.wait(3)
        AccentGradient.Offset = Vector2.new(-1, 0)
    end
end)

-- Brand Label
local BrandLabel = Instance.new("TextLabel")
BrandLabel.Name = "BrandLabel"
BrandLabel.Size = UDim2.new(0, 380, 0, 22)
BrandLabel.Position = UDim2.new(0, 18, 0, 15)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "Metan Hub - AutoPrestige3"
BrandLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
BrandLabel.TextSize = 15
BrandLabel.TextColor3 = Color3.fromRGB(152, 181, 255)
BrandLabel.TextTransparency = 0.2
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
BrandLabel.ZIndex = 2
BrandLabel.Parent = Container

local BrandGradient = Instance.new("UIGradient")
BrandGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
BrandGradient.Parent = BrandLabel

-- Subtle text glow animation
task.spawn(function()
    while true do
        TweenService:Create(BrandLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0.1
        }):Play()
        task.wait(2)
        TweenService:Create(BrandLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0.3
        }):Play()
        task.wait(2)
    end
end)

-- Status Title
local StatusTitle = Instance.new("TextLabel")
StatusTitle.Name = "StatusTitle"
StatusTitle.Size = UDim2.new(0, 100, 0, 16)
StatusTitle.Position = UDim2.new(0, 18, 0, 45)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS"
StatusTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
StatusTitle.TextSize = 12
StatusTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.ZIndex = 2
StatusTitle.Parent = Container

-- Status Container
local StatusBox = Instance.new("Frame")
StatusBox.Name = "StatusBox"
StatusBox.Size = UDim2.new(1, -36, 0, 30)
StatusBox.Position = UDim2.new(0, 18, 0, 65)
StatusBox.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
StatusBox.BackgroundTransparency = 0.1
StatusBox.BorderSizePixel = 0
StatusBox.ZIndex = 2
StatusBox.Parent = Container

local StatusBoxCorner = Instance.new("UICorner")
StatusBoxCorner.CornerRadius = UDim.new(0, 5)
StatusBoxCorner.Parent = StatusBox

local StatusBoxStroke = Instance.new("UIStroke")
StatusBoxStroke.Color = Color3.fromRGB(52, 66, 89)
StatusBoxStroke.Transparency = 0.7
StatusBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
StatusBoxStroke.Parent = StatusBox

-- Status Text
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusText"
StatusLabel.Size = UDim2.new(1, -55, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Initializing..."
StatusLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.ZIndex = 3
StatusLabel.Parent = StatusBox

local StatusGradient = Instance.new("UIGradient")
StatusGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.85, 0),
    NumberSequenceKeypoint.new(1, 0.6)
}
StatusGradient.Parent = StatusLabel

-- Loading Dots
local LoadingDots = Instance.new("TextLabel")
LoadingDots.Name = "LoadingDots"
LoadingDots.Size = UDim2.new(0, 35, 1, 0)
LoadingDots.Position = UDim2.new(1, -40, 0, 0)
LoadingDots.BackgroundTransparency = 1
LoadingDots.Text = "..."
LoadingDots.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
LoadingDots.TextSize = 16
LoadingDots.TextColor3 = Color3.fromRGB(152, 181, 255)
LoadingDots.ZIndex = 3
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
Container.BackgroundTransparency = 1
ContainerStroke.Transparency = 1

task.wait(0.3)

local entranceTween = TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 105),
    Position = UDim2.new(0.5, -210, 0.03, 0),
    BackgroundTransparency = 0.4
})
entranceTween:Play()

TweenService:Create(ContainerStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Transparency = 0.5
}):Play()

_G.UpdateStatus = updateStatus

return {
    UpdateStatus = updateStatus,
    GUI = ScreenGui
}
