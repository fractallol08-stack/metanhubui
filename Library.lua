LibraryV2 = {}
LibraryV2.__index = LibraryV2
LibraryV2.Notifications = {}

--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Shortened funcs
local u2 = UDim2.new
local v3 = Vector3.new

-- Outer blur
local Blur = Instance.new("BlurEffect")
Blur.Name = "Xenon_Blur"
Blur.Size = 0
Blur.Parent = game:GetService("Lighting")

-- Utility Functions
function Tween(inst, tType, t, yield, pref)
    local Tween = TweenService:Create(inst, TweenInfo.new(pref and pref or t and t or 1), tType)
    Tween:Play()
    if yield then
        Tween.Completed:Wait()
    end
end

function RoundNumber(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-- Create UI Elements Programmatically
function CreateContainer(name)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = u2(0, 360, 0, 50)  -- Правильный размер!
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.Size = u2(1, -40, 0, 50)
    textLabel.Position = u2(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "ImageLabel"
    arrow.Size = u2(0, 20, 0, 20)
    arrow.Position = u2(1, -30, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://6031094678"
    arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    arrow.Rotation = 0
    arrow.Parent = container
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollingFrame"
    scrollFrame.Size = u2(1, -10, 1, -60)
    scrollFrame.Position = u2(0, 5, 0, 55)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollFrame.CanvasSize = u2(0, 0, 0, 0)
    scrollFrame.Parent = container
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = u2(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    return container
end

function CreateButton(name)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = u2(1, -10, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.BorderSizePixel = 0
    button.Text = "  " .. name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    return button
end

function CreateToggle(name, state)
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = u2(1, -10, 0, 40)
    toggle.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    toggle.BorderSizePixel = 0
    toggle.Text = "  " .. name
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 14
    toggle.Font = Enum.Font.Gotham
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    toggle.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = toggle
    
    local indicator = Instance.new("ImageLabel")
    indicator.Name = "ImageLabel"
    indicator.Size = u2(0, 20, 0, 20)
    indicator.Position = u2(1, -30, 0.5, -10)
    indicator.BackgroundTransparency = 1
    indicator.Image = state and "rbxassetid://6031068426" or "rbxassetid://6031068433"
    indicator.Parent = toggle
    
    return toggle
end

function CreateSlider(name, min, max, value)
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = u2(1, -10, 0, 50)
    slider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    slider.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = slider
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = u2(0.7, 0, 0, 20)
    nameLabel.Position = u2(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Percentage"
    valueLabel.Size = u2(0.3, -10, 0, 20)
    valueLabel.Position = u2(0.7, 0, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider
    
    local sliderWhole = Instance.new("Frame")
    sliderWhole.Name = "Slider_Whole"
    sliderWhole.Size = u2(1, -20, 0, 6)
    sliderWhole.Position = u2(0, 10, 1, -15)
    sliderWhole.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sliderWhole.BorderSizePixel = 0
    sliderWhole.Parent = slider
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = sliderWhole
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Slider"
    sliderFill.Size = u2((value - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderWhole
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = u2(0, 14, 0, 14)
    circle.Position = u2(1, -7, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = sliderFill
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    return slider
end

function LibraryV2.UI(Name)
    if game.CoreGui:FindFirstChild("TUI2") then
        game.CoreGui.TUI2:Destroy()
        game:GetService("Lighting"):FindFirstChild("Xenon_Blur"):Destroy()
    end

    local Library
    Library = {
        _UI = game:GetObjects("rbxassetid://8388979705")[1],
        Name = Name or "Untitled",
        Tabs = {},
        State = false,
        ToggleKey = Enum.KeyCode.LeftControl,
        Debounce = false,

        Show_UI = function()
            local P = Library._UI.Lib.Position
            Tween(Library._UI.Lib, {Position = u2(0.75, P.X.Offset, P.Y.Size, P.Y.Offset)})
        end,
        
        Hide_UI = function()
            local P = Library._UI.Lib.Position
            Tween(Library._UI.Lib, {Position = u2(1, P.X.Offset, P.Y.Size, P.Y.Offset)})
        end,

        Hide_All = function()
            for i,v in pairs(Library._UI.Lib.Holder:GetChildren()) do
                if v.ClassName ~= "UIListLayout" and v.ClassName ~= "Folder" then
                    v.Visible = false
                end
            end
        end,

        Show = function(show_tbl)
            for i,v in pairs(show_tbl) do
                v.Visible = true             
            end
        end,

        Hide = function(hide_tbl)
            for i,v in pairs(hide_tbl) do
                v.Visible = false                
            end
        end,

        Startup = function()
            local TUI = Library._UI
            local Widgets = TUI.Widgets
            local Widget1, Widget2, Widget3, Widget4 = Widgets.Bookmarks, Widgets.Widget, Widgets.Discord, Widgets.Music
            local Tabs = TUI.TabContainer
            local BottomMenu = TUI.BottomMenu
            local TopMenu = TUI.Top
            
            for i,v in pairs(Library._UI:GetChildren()) do
                if v.ClassName ~= "Folder" and v.Name ~= "Darkener" and v.Name ~= "MusicPlayer" then
                    v.Visible = true
                end
            end

            for i,v in pairs(Library._UI.Widgets:GetChildren()) do
                v.Visible = true
            end
            
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        end,

        Update = function()
            if Library.Debounce then return end

            if Library.State == true then
                Library.Debounce = true
                Tween(Blur, {Size = 24}, 0.5)
                Library._UI.Enabled = true
                Library.Startup()
                Library.Debounce = false    
            else
                Library.Debounce = true
                Library._UI.Enabled = false
                Tween(Blur, {Size = 0}, 0.5, true)
                Library.Debounce = false
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
            end
        end
    }
    
    Library._UI.Parent = game.CoreGui
    Library._UI.Enabled = false
    Library._UI:FindFirstChild("Name").Text = Library.Name
    Library._UI.IgnoreGuiInset = true

    UserInputService.InputBegan:Connect(function(Key, IsTyping)
        if IsTyping then return end
        if Key.KeyCode == Library.ToggleKey then
            Library.State = not Library.State
            Library.Update()
        end
    end)

    return setmetatable(Library, LibraryV2)
end

function LibraryV2:Tab(Name, Icon)
    local Tab
    Tab = {
        Name = Name,
        Icon = "rbxassetid://"..Icon,
        Containers = {},
        _UI = self._UI
    }
    table.insert(self.Tabs, Tab)
    
    return setmetatable(Tab, LibraryV2)
end

function LibraryV2:Container(Name)
    local Container
    Container = {
        Name = Name,
        Assets = {},
        Drops = {},
        State = false,
        Container = CreateContainer(Name),  -- Создаем программно!
        
        In = function()
            Tween(Container.Container.ImageLabel, {Rotation = 0}, 0.3)
            Tween(Container.Container, {Size = u2(0, 360, 0, 50)}, 0.3)
        end,

        Out = function()
            Tween(Container.Container.ImageLabel, {Rotation = 180}, 0.3)
            local contentHeight = 65 + (55 * #Container.Assets)
            Tween(Container.Container, {Size = u2(0, 360, 0, contentHeight)}, 0.3)
        end
    }
    
    table.insert(self.Containers, Container.Container)
    Container.Container.Parent = self._UI.Lib.Holder
    
    Container.Container.ImageLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Container.State then
                Container.In()
            else
                Container.Out()
            end
            Container.State = not Container.State
        end
    end)
    
    self._UI.Lib.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self._UI.Lib.Holder.CanvasSize = u2(0,0,0,self._UI.Lib.Holder.UIListLayout.AbsoluteContentSize.Y)
    end)

    return setmetatable(Container, LibraryV2)
end

function LibraryV2:Button(Name, Callback)
    local Button = {
        Name = Name,
        Callback = Callback or function() end,
        Asset = CreateButton(Name),
    }
    
    table.insert(self.Assets, Button.Asset)
    Button.Asset.Parent = self.Container.ScrollingFrame
    
    Button.Asset.MouseButton1Click:Connect(function()
        pcall(Button.Callback)
    end)

    return setmetatable(Button, LibraryV2)
end

function LibraryV2:Toggle(Name, StartingState, Callback, RunOnStart)
    local Toggle = {
        Name = Name,
        State = StartingState,
        Callback = Callback or function() end,
        Asset = CreateToggle(Name, StartingState),
        
        Update = function()
            Toggle.Asset.ImageLabel.Image = Toggle.State and "rbxassetid://6031068426" or "rbxassetid://6031068433"
        end
    }
    
    table.insert(self.Assets, Toggle.Asset)
    Toggle.Asset.Parent = self.Container.ScrollingFrame
    
    Toggle.Asset.MouseButton1Click:Connect(function()
        Toggle.State = not Toggle.State
        Toggle.Update()
        pcall(Toggle.Callback, Toggle.State)
    end)
    
    if Toggle.State == true and RunOnStart then
        pcall(Toggle.Callback, Toggle.State)
    end

    return setmetatable(Toggle, LibraryV2)
end

function LibraryV2:Slider(Name, Min, Max, Start, Callback, Use_Decimals)
    local Slider = {
        Name = Name,
        Min = Min or 0,
        Max = Max or 100,
        Value = Start or 0,
        Callback = Callback or function() end,
        Dragging = false,
        Asset = CreateSlider(Name, Min or 0, Max or 100, Start or 0),
    }
    
    table.insert(self.Assets, Slider.Asset)
    Slider.Asset.Parent = self.Container.ScrollingFrame
    
    local circle = Slider.Asset.Slider_Whole.Slider.Circle
    local sliderFill = Slider.Asset.Slider_Whole.Slider
    local valueLabel = Slider.Asset.Percentage
    
    circle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = true
        end
    end)
    
    circle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderWhole = Slider.Asset.Slider_Whole
            local mousePos = input.Position.X
            local sliderPos = sliderWhole.AbsolutePosition.X
            local sliderSize = sliderWhole.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local newValue = Use_Decimals and RoundNumber(Slider.Min + (percent * (Slider.Max - Slider.Min)), 1) 
                             or math.floor(Slider.Min + (percent * (Slider.Max - Slider.Min)))
            
            Slider.Value = newValue
            sliderFill:TweenSize(u2(percent, 0, 1, 0), "Out", "Sine", 0.1, true)
            valueLabel.Text = tostring(newValue)
            pcall(Slider.Callback, newValue)
        end
    end)

    return setmetatable(Slider, LibraryV2)
end

function LibraryV2:Label(Text)
    local label = Instance.new("TextLabel")
    label.Size = u2(1, -10, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = "  " .. Text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.Container.ScrollingFrame
    
    table.insert(self.Assets, label)
    return label
end

function LibraryV2:SetToggleKey(Key)
    delay(0.05, function()
        self.ToggleKey = Key
    end)
end

return LibraryV2
