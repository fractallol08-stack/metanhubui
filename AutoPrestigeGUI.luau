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

-- Main Container with shadow
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 420, 0, 105)
MainContainer.Position = UDim2.new(0.5, -210, 0.03, 0)
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = ScreenGui

-- Shadow Frame
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, 5)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.7
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 1
Shadow.Parent = MainContainer

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 15)
ShadowCorner.Parent = Shadow

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

-- Gradient overlay
local GradientFrame = Instance.new("Frame")
GradientFrame.Size = UDim2.new(1, 0, 1, 0)
GradientFrame.BackgroundTransparency = 0.5
GradientFrame.BorderSizePixel = 0
GradientFrame.ZIndex = 3
GradientFrame.Parent = MainFrame

local GradientCorner = Instance.new("UICorner")
GradientCorner.CornerRadius = UDim.new(0, 15)
GradientCorner.Parent = GradientFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 230, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 220, 255))
}
Gradient.Rotation = 45
Gradient.Parent = GradientFrame

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

-- Particle effect container
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.BorderSizePixel = 0
ParticleContainer.ZIndex = 4
ParticleContainer.ClipsDescendants = true
ParticleContainer.Parent = MainFrame

local ParticleCorner = Instance.new("UICorner")
ParticleCorner.CornerRadius = UDim.new(0, 15)
ParticleCorner.Parent = ParticleContainer

-- Create realistic snowflakes
task.spawn(function()
    while true do
        -- Create snowflake container
        local snowflake = Instance.new("Frame")
        local size = math.random(4, 8)
        snowflake.Size = UDim2.new(0, size, 0, size)
        snowflake.Position = UDim2.new(math.random(10, 90) / 100, 0, 0, -10)
        snowflake.BackgroundTransparency = 1
        snowflake.BorderSizePixel = 0
        snowflake.ZIndex = 4
        snowflake.Rotation = math.random(0, 360)
        snowflake.Parent = ParticleContainer
        
        -- Center dot
        local center = Instance.new("Frame")
        center.Size = UDim2.new(0, 2, 0, 2)
        center.Position = UDim2.new(0.5, -1, 0.5, -1)
        center.BackgroundColor3 = Color3.fromRGB(240, 250, 255)
        center.BackgroundTransparency = 0.1
        center.BorderSizePixel = 0
        center.ZIndex = 5
        center.Parent = snowflake
        
        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1, 0)
        centerCorner.Parent = center
        
        -- Create 6 arms for realistic snowflake
        for i = 0, 5 do
            local angle = i * 60
            local arm = Instance.new("Frame")
            arm.Size = UDim2.new(0, size / 2, 0, 1)
            arm.Position = UDim2.new(0.5, 0, 0.5, 0)
            arm.AnchorPoint = Vector2.new(0, 0.5)
            arm.BackgroundColor3 = Color3.fromRGB(240, 250, 255)
            arm.BackgroundTransparency = 0.2
            arm.BorderSizePixel = 0
            arm.Rotation = angle
            arm.ZIndex = 5
            arm.Parent = snowflake
            
            -- Small branches on arms
            local branch1 = Instance.new("Frame")
            branch1.Size = UDim2.new(0, size / 4, 0, 1)
            branch1.Position = UDim2.new(0.6, 0, 0.5, 0)
            branch1.AnchorPoint = Vector2.new(0, 0.5)
            branch1.BackgroundColor3 = Color3.fromRGB(240, 250, 255)
            branch1.BackgroundTransparency = 0.3
            branch1.BorderSizePixel = 0
            branch1.Rotation = -30
            branch1.ZIndex = 5
            branch1.Parent = arm
            
            local branch2 = Instance.new("Frame")
            branch2.Size = UDim2.new(0, size / 4, 0, 1)
            branch2.Position = UDim2.new(0.6, 0, 0.5, 0)
            branch2.AnchorPoint = Vector2.new(0, 0.5)
            branch2.BackgroundColor3 = Color3.fromRGB(240, 250, 255)
            branch2.BackgroundTransparency = 0.3
            branch2.BorderSizePixel = 0
            branch2.Rotation = 30
            branch2.ZIndex = 5
            branch2.Parent = arm
        end
        
        local duration = math.random(5, 8)
        local drift = math.random(-15, 15) / 100
        local endX = math.clamp(snowflake.Position.X.Scale + drift, 0.1, 0.9)
        
        -- Falling animation with gentle rotation and drift
        local tween = TweenService:Create(snowflake, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Position = UDim2.new(endX, 0, 1, 10),
            BackgroundTransparency = 1,
            Rotation = snowflake.Rotation + math.random(90, 180)
        })
        tween:Play()
        
        -- Fade out all children
        for _, child in pairs(snowflake:GetDescendants()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                    BackgroundTransparency = 1
                }):Play()
            end
        end
        
        task.delay(duration, function()
            snowflake:Destroy()
        end)
        
        task.wait(0.15)
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
