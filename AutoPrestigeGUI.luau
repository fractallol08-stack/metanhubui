-- Metan Status GUI with Effects
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MetanStatusGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Main Container
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 420, 0, 105)
MainContainer.Position = UDim2.new(0.5, -210, 0.03, 0)
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = ScreenGui

-- Main Frame with gradient
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.Position = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 2
MainFrame.Parent = MainContainer

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Gradient overlay on MainFrame
local GradientOverlay = Instance.new("Frame")
GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
GradientOverlay.BackgroundTransparency = 0.5
GradientOverlay.BorderSizePixel = 0
GradientOverlay.ZIndex = 3
GradientOverlay.Parent = MainFrame

local GradientOverlayCorner = Instance.new("UICorner")
GradientOverlayCorner.CornerRadius = UDim.new(0, 15)
GradientOverlayCorner.Parent = GradientOverlay

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 230, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 220, 255))
}
Gradient.Rotation = 45
Gradient.Parent = GradientOverlay

-- Animated gradient rotation
task.spawn(function()
    while true do
        local tween = TweenService:Create(Gradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = Gradient.Rotation + 360})
        tween:Play()
        task.wait(3)
    end
end)

-- Border glow effect
local BorderGlow = Instance.new("UIStroke")
BorderGlow.Color = Color3.fromRGB(180, 220, 255)
BorderGlow.Thickness = 2
BorderGlow.Transparency = 0.3
BorderGlow.Parent = MainFrame

-- Animated border glow
task.spawn(function()
    while true do
        local tween1 = TweenService:Create(BorderGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0,
            Color = Color3.fromRGB(200, 230, 255)
        })
        tween1:Play()
        task.wait(1.5)
        local tween2 = TweenService:Create(BorderGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.5,
            Color = Color3.fromRGB(150, 200, 255)
        })
        tween2:Play()
        task.wait(1.5)
    end
end)

-- Logo/Brand
local BrandLabel = Instance.new("TextLabel")
BrandLabel.Size = UDim2.new(0, 380, 0, 30)
BrandLabel.Position = UDim2.new(0, 20, 0, 12)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "Metan Hub - AutoPrestige3"
BrandLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
BrandLabel.TextSize = 16
BrandLabel.TextColor3 = Color3.fromRGB(152, 181, 255)
BrandLabel.TextTransparency = 0.2
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
BrandLabel.ZIndex = 6
BrandLabel.Parent = MainFrame

local BrandGradient = Instance.new("UIGradient")
BrandGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
BrandGradient.Parent = BrandLabel

-- Status Title
local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -40, 0, 20)
StatusTitle.Position = UDim2.new(0, 20, 0, 45)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS"
StatusTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
StatusTitle.TextSize = 12
StatusTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.ZIndex = 6
StatusTitle.Parent = MainFrame

-- Status Text with container
local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(1, -40, 0, 32)
StatusContainer.Position = UDim2.new(0, 20, 0, 65)
StatusContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
StatusContainer.BackgroundTransparency = 0.3
StatusContainer.BorderSizePixel = 0
StatusContainer.ZIndex = 5
StatusContainer.Parent = MainFrame

local StatusContainerCorner = Instance.new("UICorner")
StatusContainerCorner.CornerRadius = UDim.new(0, 8)
StatusContainerCorner.Parent = StatusContainer

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusText"
StatusLabel.Size = UDim2.new(1, -50, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Initializing..."
StatusLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.ZIndex = 6
StatusLabel.Parent = StatusContainer

-- Loading indicator dots
local LoadingDots = Instance.new("TextLabel")
LoadingDots.Size = UDim2.new(0, 30, 1, 0)
LoadingDots.Position = UDim2.new(1, -40, 0, 0)
LoadingDots.BackgroundTransparency = 1
LoadingDots.Text = "..."
LoadingDots.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
LoadingDots.TextSize = 14
LoadingDots.TextColor3 = Color3.fromRGB(152, 181, 255)
LoadingDots.ZIndex = 6
LoadingDots.Parent = StatusContainer

-- Animated loading dots
task.spawn(function()
    local dots = {".", "..", "..."}
    local index = 1
    while true do
        LoadingDots.Text = dots[index]
        index = index % 3 + 1
        task.wait(0.5)
    end
end)



-- Update status function with animation
local function updateStatus(text)
    -- Fade out
    local fadeOut = TweenService:Create(StatusLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1
    })
    fadeOut:Play()
    fadeOut.Completed:Wait()
    
    -- Update text
    StatusLabel.Text = text
    
    -- Fade in
    local fadeIn = TweenService:Create(StatusLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 0
    })
    fadeIn:Play()
    
    -- Flash effect on container
    local flash = TweenService:Create(StatusContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0
    })
    flash:Play()
    task.wait(0.2)
    local flashBack = TweenService:Create(StatusContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.3
    })
    flashBack:Play()
end

-- Entrance animation
MainContainer.Position = UDim2.new(0.5, -210, -0.2, 0)
MainContainer.Size = UDim2.new(0, 0, 0, 0)

task.wait(0.5)

local entranceTween = TweenService:Create(MainContainer, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -210, 0.03, 0),
    Size = UDim2.new(0, 420, 0, 105)
})
entranceTween:Play()

-- Export function
_G.UpdateStatus = updateStatus

return {
    UpdateStatus = updateStatus,
    GUI = ScreenGui
}
