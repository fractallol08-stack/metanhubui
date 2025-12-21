--[[
    March UI Library v2.0
    Полностью переписанная UI библиотека для Roblox
    
    Особенности:
    - Модульная система с панелью настроек
    - Color Picker с HSV выбором
    - Все стандартные компоненты
    - Сохранение конфигурации
    - Drag & Drop интерфейс
]]

-- Глобальные переменные
getgenv().MarchUI = getgenv().MarchUI or {}

-- Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Утилиты для работы с цветом
local ColorUtils = {}

function ColorUtils.HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

function ColorUtils.RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v
    
    v = max
    local d = max - min
    
    if max == 0 then
        s = 0
    else
        s = d / max
    end
    
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

-- Менеджер конфигурации
local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new()
    local self = setmetatable({}, ConfigManager)
    self.Flags = {}
    self.ConfigFolder = "MarchUI"
    
    if not isfolder(self.ConfigFolder) then
        makefolder(self.ConfigFolder)
    end
    
    return self
end

function ConfigManager:Save(name)
    local success, err = pcall(function()
        local data = HttpService:JSONEncode(self.Flags)
        writefile(self.ConfigFolder .. "/" .. name .. ".json", data)
    end)
    
    if not success then
        warn("Failed to save config:", err)
    end
end

function ConfigManager:Load(name)
    local path = self.ConfigFolder .. "/" .. name .. ".json"
    
    if not isfile(path) then
        return false
    end
    
    local success, result = pcall(function()
        local data = readfile(path)
        return HttpService:JSONDecode(data)
    end)
    
    if success and result then
        for flag, value in pairs(result) do
            self.Flags[flag] = value
        end
        return true
    end
    
    return false
end

function ConfigManager:SetFlag(flag, value)
    self.Flags[flag] = value
end

function ConfigManager:GetFlag(flag, default)
    return self.Flags[flag] or default
end

-- Главный класс библиотеки
local Library = {}
Library.__index = Library

function Library.new(config)
    local self = setmetatable({}, Library)
    
    config = config or {}
    self.Title = config.Title or "March UI"
    self.ConfigName = config.ConfigName or game.GameId
    
    self.Config = ConfigManager.new()
    self.Config:Load(self.ConfigName)
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.SettingsPanel = nil
    self.CurrentModule = nil
    self.ActiveColorPicker = nil
    self.SettingsPanelPosition = nil -- Сохраненная позиция панели
    
    self:CreateUI()
    self:SetupDragging()
    self:SetupToggle()
    
    return self
end

function Library:CreateUI()
    -- Удаляем старый UI если есть
    local oldUI = CoreGui:FindFirstChild("MarchUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Создаем ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MarchUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui
    
    -- Главный контейнер
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 700, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 15)  -- March UI стиль
    self.MainFrame.BackgroundTransparency = 0.05  -- March UI прозрачность
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = false
    self.MainFrame.Parent = self.ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = self.MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(52, 66, 89)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.5
    MainStroke.Parent = self.MainFrame
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = self.MainFrame
    
    -- Иконка
    local TitleIcon = Instance.new("ImageLabel")
    TitleIcon.Name = "Icon"
    TitleIcon.Size = UDim2.new(0, 18, 0, 18)
    TitleIcon.Position = UDim2.new(0, 18, 0, 26)
    TitleIcon.AnchorPoint = Vector2.new(0, 0.5)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Image = "rbxassetid://107819132007001"
    TitleIcon.ImageColor3 = Color3.fromRGB(152, 181, 255)
    TitleIcon.ScaleType = Enum.ScaleType.Fit
    TitleIcon.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "ClientName"
    TitleLabel.Size = UDim2.new(0, 200, 0, 13)
    TitleLabel.Position = UDim2.new(0, 42, 0, 26)
    TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Title
    TitleLabel.TextColor3 = Color3.fromRGB(152, 181, 255)
    TitleLabel.TextTransparency = 0.2
    TitleLabel.TextSize = 13
    TitleLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Градиент для заголовка
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    TitleGradient.Parent = TitleLabel
    
    -- Контейнер для табов (слева)
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, -50)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 45)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 4
    self.TabContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabContainer.Parent = self.MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = self.TabContainer
    
    -- Разделитель
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(0, 1, 1, -50)
    Divider.Position = UDim2.new(0, 170, 0, 45)
    Divider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Divider.BackgroundTransparency = 0.5
    Divider.BorderSizePixel = 0
    Divider.Parent = self.MainFrame
    
    -- Pin (индикатор активного таба)
    self.TabPin = Instance.new("Frame")
    self.TabPin.Name = "Pin"
    self.TabPin.Size = UDim2.new(0, 2, 0, 16)
    self.TabPin.Position = UDim2.new(0, 10, 0, 65)
    self.TabPin.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    self.TabPin.BorderSizePixel = 0
    self.TabPin.Parent = self.MainFrame
    
    local PinCorner = Instance.new("UICorner")
    PinCorner.CornerRadius = UDim.new(1, 0)
    PinCorner.Parent = self.TabPin
    
    -- Контейнер для контента (справа)
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -190, 1, -50)
    self.ContentContainer.Position = UDim2.new(0, 180, 0, 45)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.ClipsDescendants = true
    self.ContentContainer.Parent = self.MainFrame
end

function Library:SetupDragging()
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:SetupToggle()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightShift then
            self.MainFrame.Visible = not self.MainFrame.Visible
            if self.SettingsPanel then
                self.SettingsPanel.Visible = self.MainFrame.Visible and self.SettingsPanel.Visible
            end
        end
    end)
end

function Library:CreateTab(name, icon)
    local Tab = {}
    Tab.Name = name
    Tab.Modules = {}
    Tab.Active = false
    
    -- Кнопка таба
    Tab.Button = Instance.new("TextButton")
    Tab.Button.Name = name
    Tab.Button.Size = UDim2.new(1, -10, 0, 38)
    Tab.Button.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    Tab.Button.BackgroundTransparency = 1
    Tab.Button.BorderSizePixel = 0
    Tab.Button.Text = ""
    Tab.Button.AutoButtonColor = false
    Tab.Button.Parent = self.TabContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 5)
    ButtonCorner.Parent = Tab.Button
    
    local ButtonLabel = Instance.new("TextLabel")
    ButtonLabel.Size = UDim2.new(0, 100, 0, 16)
    ButtonLabel.Position = UDim2.new(0.24, 0, 0.5, 0)
    ButtonLabel.AnchorPoint = Vector2.new(0, 0.5)
    ButtonLabel.BackgroundTransparency = 1
    ButtonLabel.Text = name
    ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonLabel.TextTransparency = 0.7
    ButtonLabel.TextSize = 13
    ButtonLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
    ButtonLabel.Parent = Tab.Button
    
    -- Добавляем градиент как в LibraryMarch
    local LabelGradient = Instance.new("UIGradient")
    LabelGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(155, 155, 155)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58))
    }
    LabelGradient.Offset = Vector2.new(0, 0)
    LabelGradient.Parent = ButtonLabel
    
    if icon then
        local IconLabel = Instance.new("ImageLabel")
        IconLabel.Size = UDim2.new(0, 12, 0, 12)
        IconLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
        IconLabel.AnchorPoint = Vector2.new(0, 0.5)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Image = icon
        IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
        IconLabel.ImageTransparency = 0.8
        IconLabel.ScaleType = Enum.ScaleType.Fit
        IconLabel.Parent = Tab.Button
    end
    
    -- Контейнер для модулей (сетка 2 колонки)
    Tab.Container = Instance.new("ScrollingFrame")
    Tab.Container.Name = name .. "Container"
    Tab.Container.Size = UDim2.new(1, 0, 1, 0)
    Tab.Container.BackgroundTransparency = 1
    Tab.Container.BorderSizePixel = 0
    Tab.Container.ScrollBarThickness = 4
    Tab.Container.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    Tab.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tab.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Tab.Container.Visible = false
    Tab.Container.Parent = self.ContentContainer
    
    -- UIGridLayout для 2 колонок
    local ContainerLayout = Instance.new("UIGridLayout")
    ContainerLayout.CellSize = UDim2.new(0, 241, 0, 93)
    ContainerLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ContainerLayout.Parent = Tab.Container
    
    local ContainerPadding = Instance.new("UIPadding")
    ContainerPadding.PaddingTop = UDim.new(0, 10)
    ContainerPadding.PaddingBottom = UDim.new(0, 10)
    ContainerPadding.PaddingLeft = UDim.new(0, 10)
    ContainerPadding.PaddingRight = UDim.new(0, 10)
    ContainerPadding.Parent = Tab.Container
    
    -- Обработчик клика
    Tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(Tab)
    end)
    
    -- Hover эффект - только для неактивных табов
    Tab.Button.MouseEnter:Connect(function()
        if not Tab.Active then
            TweenService:Create(Tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.7
            }):Play()
        end
    end)
    
    Tab.Button.MouseLeave:Connect(function()
        if not Tab.Active then
            TweenService:Create(Tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)
    
    table.insert(self.Tabs, Tab)
    
    -- Активируем первый таб
    if #self.Tabs == 1 then
        self:SelectTab(Tab)
    end
    
    return setmetatable(Tab, {__index = function(t, k)
        if k == "CreateModule" then
            return function(_, ...)
                return self:CreateModule(Tab, ...)
            end
        end
    end})
end

function Library:SelectTab(tab)
    -- Деактивируем все табы
    for _, t in ipairs(self.Tabs) do
        t.Active = false
        t.Container.Visible = false
        
        -- Возвращаем неактивный стиль
        TweenService:Create(t.Button, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
        
        local label = t.Button:FindFirstChildOfClass("TextLabel")
        if label then
            TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0.7,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            
            local gradient = label:FindFirstChildOfClass("UIGradient")
            if gradient then
                TweenService:Create(gradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Offset = Vector2.new(0, 0)
                }):Play()
            end
        end
        
        local icon = t.Button:FindFirstChildOfClass("ImageLabel")
        if icon then
            TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                ImageTransparency = 0.8,
                ImageColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end
    
    -- Активируем выбранный таб
    tab.Active = true
    tab.Container.Visible = true
    
    TweenService:Create(tab.Button, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.5
    }):Play()
    
    local label = tab.Button:FindFirstChildOfClass("TextLabel")
    if label then
        TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextTransparency = 0.2,
            TextColor3 = Color3.fromRGB(152, 181, 255)
        }):Play()
        
        local gradient = label:FindFirstChildOfClass("UIGradient")
        if gradient then
            TweenService:Create(gradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Offset = Vector2.new(1, 0)
            }):Play()
        end
    end
    
    local icon = tab.Button:FindFirstChildOfClass("ImageLabel")
    if icon then
        TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            ImageTransparency = 0.2,
            ImageColor3 = Color3.fromRGB(152, 181, 255)
        }):Play()
    end
    
    -- Анимация Pin (индикатора)
    if self.TabPin then
        local tabIndex = 0
        for i, t in ipairs(self.Tabs) do
            if t == tab then
                tabIndex = i - 1
                break
            end
        end
        
        local offset = tabIndex * (38 + 5) -- 38 высота таба + 5 padding
        TweenService:Create(self.TabPin, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 10, 0, 65 + offset)
        }):Play()
    end
    
    self.CurrentTab = tab
    
    -- Закрываем панель настроек при смене таба
    if self.SettingsPanel then
        self:HideSettingsPanel()
    end
end

function Library:CreateModule(tab, config)
    local Module = {}
    Module.Name = config.Name or "Module"
    Module.Description = config.Description or ""
    Module.Components = {}
    Module.Expanded = false
    
    -- Контейнер модуля (карточка) - размер точно как в LibraryMarch
    Module.Frame = Instance.new("Frame")
    Module.Frame.Name = Module.Name
    Module.Frame.Size = UDim2.new(0, 241, 0, 93)
    Module.Frame.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    Module.Frame.BorderSizePixel = 0
    Module.Frame.Parent = tab.Container
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 5)
    FrameCorner.Parent = Module.Frame
    
    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(52, 66, 89)
    FrameStroke.Thickness = 1
    FrameStroke.Transparency = 0.5
    FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    FrameStroke.Parent = Module.Frame
    
    -- Заголовок модуля (Header)
    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 93)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.Parent = Module.Frame
    
    -- Иконка
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 15, 0, 15)
    Icon.Position = UDim2.new(0.071, 0, 0.82, 0)
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://79095934438045"
    Icon.ImageColor3 = Color3.fromRGB(152, 181, 255)
    Icon.ImageTransparency = 0.7
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.Parent = Header
    
    -- Название модуля
    local ModuleName = Instance.new("TextLabel")
    ModuleName.Name = "ModuleName"
    ModuleName.Size = UDim2.new(0, 205, 0, 13)
    ModuleName.Position = UDim2.new(0.073, 0, 0.24, 0)
    ModuleName.AnchorPoint = Vector2.new(0, 0.5)
    ModuleName.BackgroundTransparency = 1
    ModuleName.Text = Module.Name
    ModuleName.TextColor3 = Color3.fromRGB(152, 181, 255)
    ModuleName.TextTransparency = 0.2
    ModuleName.TextSize = 13
    ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ModuleName.TextXAlignment = Enum.TextXAlignment.Left
    ModuleName.Parent = Header
    
    -- Описание модуля
    local Description = Instance.new("TextLabel")
    Description.Name = "Description"
    Description.Size = UDim2.new(0, 205, 0, 13)
    Description.Position = UDim2.new(0.073, 0, 0.42, 0)
    Description.AnchorPoint = Vector2.new(0, 0.5)
    Description.BackgroundTransparency = 1
    Description.Text = Module.Description
    Description.TextColor3 = Color3.fromRGB(152, 181, 255)
    Description.TextTransparency = 0.7
    Description.TextSize = 10
    Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Header
    
    -- Toggle переключатель
    local Toggle = Instance.new("Frame")
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 25, 0, 12)
    Toggle.Position = UDim2.new(0.82, 0, 0.757, 0)
    Toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Toggle.BackgroundTransparency = 0.7
    Toggle.BorderSizePixel = 0
    Toggle.Parent = Header
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle
    
    local Circle = Instance.new("Frame")
    Circle.Name = "Circle"
    Circle.Size = UDim2.new(0, 12, 0, 12)
    Circle.Position = UDim2.new(0, 0, 0.5, 0)
    Circle.AnchorPoint = Vector2.new(0, 0.5)
    Circle.BackgroundColor3 = Color3.fromRGB(66, 80, 115)
    Circle.BackgroundTransparency = 0.2
    Circle.BorderSizePixel = 0
    Circle.Parent = Toggle
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    -- Keybind
    local Keybind = Instance.new("Frame")
    Keybind.Name = "Keybind"
    Keybind.Size = UDim2.new(0, 33, 0, 15)
    Keybind.Position = UDim2.new(0.15, 0, 0.735, 0)
    Keybind.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Keybind.BackgroundTransparency = 0.7
    Keybind.BorderSizePixel = 0
    Keybind.Parent = Header
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 3)
    KeybindCorner.Parent = Keybind
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(0, 25, 0, 13)
    KeybindLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    KeybindLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = "None"
    KeybindLabel.TextColor3 = Color3.fromRGB(209, 222, 255)
    KeybindLabel.TextSize = 10
    KeybindLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = Keybind
    
    -- УДАЛЯЕМ DIVIDERS - их не должно быть!
    
    -- Обработчик клика - открывает панель настроек
    Header.MouseButton1Click:Connect(function()
        print("=== КЛИК ПО МОДУЛЮ ===")
        print("Модуль:", Module.Name)
        print("Текущий модуль:", self.CurrentModule and self.CurrentModule.Name or "nil")
        print("Компонентов:", #Module.Components)
        
        -- Если кликнули на тот же модуль - закрываем
        if self.CurrentModule == Module then
            print("Закрываем текущий модуль")
            self:HideSettingsPanel()
        else
            -- Открываем новый модуль (мгновенно, без debounce)
            print("Открываем новый модуль")
            self:ShowSettingsPanel(Module)
        end
    end)
    
    -- Hover эффект
    Header.MouseEnter:Connect(function()
        TweenService:Create(Module.Frame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(32, 38, 51)
        }):Play()
    end)
    
    Header.MouseLeave:Connect(function()
        TweenService:Create(Module.Frame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        }):Play()
    end)
    
    table.insert(tab.Modules, Module)
    
    return setmetatable(Module, {__index = function(t, k)
        -- Создаем методы для добавления компонентов
        if k == "AddSlider" then
            return function(_, ...) return self:AddSlider(Module, ...) end
        elseif k == "AddToggle" then
            return function(_, ...) return self:AddToggle(Module, ...) end
        elseif k == "AddDropdown" then
            return function(_, ...) return self:AddDropdown(Module, ...) end
        elseif k == "AddTextbox" then
            return function(_, ...) return self:AddTextbox(Module, ...) end
        elseif k == "AddColorPicker" then
            return function(_, ...) return self:AddColorPicker(Module, ...) end
        elseif k == "AddKeybind" then
            return function(_, ...) return self:AddKeybind(Module, ...) end
        elseif k == "AddLabel" then
            return function(_, ...) return self:AddLabel(Module, ...) end
        elseif k == "AddDivider" then
            return function(_, ...) return self:AddDivider(Module, ...) end
        end
    end})
end

function Library:ShowSettingsPanel(module)
    -- Создаем панель если её нет
    if not self.SettingsPanel then
        self.SettingsPanel = Instance.new("Frame")
        self.SettingsPanel.Name = "SettingsPanel"
        self.SettingsPanel.Size = UDim2.new(0, 280, 0, 500)
        self.SettingsPanel.Position = UDim2.new(0, 720, 0, 0)
        self.SettingsPanel.BackgroundColor3 = Color3.fromRGB(12, 13, 15)
        self.SettingsPanel.BackgroundTransparency = 0.05
        self.SettingsPanel.BorderSizePixel = 0
        self.SettingsPanel.ClipsDescendants = false
        self.SettingsPanel.Visible = false
        self.SettingsPanel.ZIndex = 10
        self.SettingsPanel.Parent = self.ScreenGui
        
        local PanelCorner = Instance.new("UICorner")
        PanelCorner.CornerRadius = UDim.new(0, 10)
        PanelCorner.Parent = self.SettingsPanel
        
    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Color3.fromRGB(52, 66, 89)
    PanelStroke.Thickness = 1
    PanelStroke.Transparency = 0.5
    PanelStroke.Parent = self.SettingsPanel
        
        -- Заголовок панели (для перетаскивания)
        local PanelTitle = Instance.new("TextLabel")
        PanelTitle.Name = "PanelTitle"
        PanelTitle.Size = UDim2.new(1, -60, 0, 40)
        PanelTitle.Position = UDim2.new(0, 15, 0, 10)
        PanelTitle.BackgroundTransparency = 1
        PanelTitle.Text = "Settings"
        PanelTitle.TextColor3 = Color3.fromRGB(152, 181, 255)
        PanelTitle.TextSize = 16
        PanelTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
        PanelTitle.ZIndex = 11
        PanelTitle.Parent = self.SettingsPanel
        
        -- Добавляем перетаскивание для панели настроек
        local panelDragging = false
        local panelDragStart, panelStartPos
        
        PanelTitle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                panelDragging = true
                panelDragStart = input.Position
                panelStartPos = self.SettingsPanel.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        panelDragging = false
                    end
                end)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if panelDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - panelDragStart
                local newPos = UDim2.new(
                    panelStartPos.X.Scale,
                    panelStartPos.X.Offset + delta.X,
                    panelStartPos.Y.Scale,
                    panelStartPos.Y.Offset + delta.Y
                )
                self.SettingsPanel.Position = newPos
                -- Сохраняем позицию
                self.SettingsPanelPosition = newPos
            end
        end)
        
        -- Кнопка закрытия
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -40, 0, 10)
        CloseButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        CloseButton.BorderSizePixel = 0
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Color3.fromRGB(200, 200, 220)
        CloseButton.TextSize = 20
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.ZIndex = 11
        CloseButton.Parent = self.SettingsPanel
        
        local CloseCorner = Instance.new("UICorner")
        CloseCorner.CornerRadius = UDim.new(0, 6)
        CloseCorner.Parent = CloseButton
        
        CloseButton.MouseButton1Click:Connect(function()
            self:HideSettingsPanel()
        end)
        
        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 40, 40)
            }):Play()
        end)
        
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(22, 28, 38)
            }):Play()
        end)
        
        -- Контейнер для компонентов
        self.SettingsContent = Instance.new("ScrollingFrame")
        self.SettingsContent.Name = "SettingsContent"
        self.SettingsContent.Size = UDim2.new(1, -20, 1, -60)
        self.SettingsContent.Position = UDim2.new(0, 10, 0, 50)
        self.SettingsContent.BackgroundTransparency = 1
        self.SettingsContent.BorderSizePixel = 0
        self.SettingsContent.ScrollBarThickness = 4
        self.SettingsContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
        self.SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        self.SettingsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        self.SettingsContent.ZIndex = 11
        self.SettingsContent.Parent = self.SettingsPanel
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ContentLayout.Parent = self.SettingsContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 5)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
        ContentPadding.Parent = self.SettingsContent
    end
    
    print("ShowSettingsPanel вызван для модуля:", module.Name)
    print("Компонентов в модуле:", #module.Components)
    
    -- Отсоединяем предыдущие компоненты (НЕ уничтожаем!)
    for _, child in ipairs(self.SettingsContent:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child.Parent = nil  -- Просто отсоединяем, не уничтожаем
        end
    end
    
    -- Обновляем заголовок
    local titleLabel = self.SettingsPanel:FindFirstChild("PanelTitle")
    if titleLabel then
        titleLabel.Text = module.Name .. " Settings"
    end
    
    -- Добавляем компоненты модуля в панель
    for i, component in ipairs(module.Components) do
        if component.Element then
            print("Добавляем компонент", i, "в панель")
            component.Element.Parent = self.SettingsContent
            component.Element.ZIndex = 11
        end
    end
    
    -- Показываем панель
    self.SettingsPanel.Visible = true
    
    -- Используем сохраненную позицию или вычисляем новую
    if self.SettingsPanelPosition then
        self.SettingsPanel.Position = self.SettingsPanelPosition
    else
        local mainPos = self.MainFrame.AbsolutePosition
        local mainSize = self.MainFrame.AbsoluteSize
        self.SettingsPanel.Position = UDim2.new(0, mainPos.X + mainSize.X + 10, 0, mainPos.Y)
        self.SettingsPanelPosition = self.SettingsPanel.Position
    end
    
    print("Панель показана на позиции:", self.SettingsPanel.Position)
    
    self.CurrentModule = module
end

function Library:HideSettingsPanel()
    if not self.SettingsPanel or not self.SettingsPanel.Visible then return end
    
    print("HideSettingsPanel вызван")
    
    -- Сохраняем текущую позицию перед скрытием
    self.SettingsPanelPosition = self.SettingsPanel.Position
    
    self.SettingsPanel.Visible = false
    self.CurrentModule = nil
end

-- Компонент: Slider
function Library:AddSlider(module, config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local increment = config.Increment or 1
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    
    local value = self.Config:GetFlag(flag, default)
    
    local Slider = {}
    Slider.Value = value
    
    -- Контейнер
    Slider.Element = Instance.new("Frame")
    Slider.Element.Name = name
    Slider.Element.Size = UDim2.new(0, 207, 0, 60)
    Slider.Element.BackgroundTransparency = 1
    Slider.Element.BorderSizePixel = 0
    
    -- Название
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 153, 0, 13)
    NameLabel.Position = UDim2.new(0, 10, 0, 8)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextTransparency = 0.2
    NameLabel.TextSize = 11
    NameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Slider.Element
    
    -- Значение
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 42, 0, 13)
    ValueLabel.Position = UDim2.new(1, -52, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.TextTransparency = 0.2
    ValueLabel.TextSize = 10
    ValueLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Slider.Element
    
    -- Трек слайдера
    local Track = Instance.new("Frame")
    Track.Name = "Track"
    Track.Size = UDim2.new(0, 207, 0, 4)
    Track.Position = UDim2.new(0, 10, 0, 38)
    Track.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Track.BackgroundTransparency = 0.9
    Track.BorderSizePixel = 0
    Track.Parent = Slider.Element
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track
    
    -- Заполнение
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Fill.BackgroundTransparency = 0.5
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill
    
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 79, 79))
    }
    FillGradient.Parent = Fill
    
    -- Ползунок (Circle)
    local Thumb = Instance.new("Frame")
    Thumb.Name = "Circle"
    Thumb.Size = UDim2.new(0, 6, 0, 6)
    Thumb.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
    Thumb.AnchorPoint = Vector2.new(1, 0.5)
    Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Thumb.BorderSizePixel = 0
    Thumb.Parent = Fill
    
    local ThumbCorner = Instance.new("UICorner")
    ThumbCorner.CornerRadius = UDim.new(1, 0)
    ThumbCorner.Parent = Thumb
    
    -- Функция обновления значения
    function Slider:SetValue(newValue)
        newValue = math.clamp(newValue, min, max)
        newValue = math.floor(newValue / increment + 0.5) * increment
        
        self.Value = newValue
        ValueLabel.Text = tostring(newValue)
        
        local percent = (newValue - min) / (max - min)
        local sliderSize = math.clamp(percent, 0.02, 1) * Track.AbsoluteSize.X
        
        TweenService:Create(Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, sliderSize, 1, 0)
        }):Play()
        
        Library.Config:SetFlag(flag, newValue)
        Library.Config:Save(Library.ConfigName)
        
        callback(newValue)
    end
    
    -- Обработка перетаскивания
    local dragging = false
    
    local function updateSlider()
        local mousePos = (Mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
        local percent = math.clamp(mousePos, 0, 1)
        local newValue = min + (max - min) * percent
        Slider:SetValue(newValue)
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider()
            
            local moveConnection
            moveConnection = Mouse.Move:Connect(function()
                if dragging then
                    updateSlider()
                end
            end)
            
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    moveConnection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end
    end)
    
    table.insert(module.Components, Slider)
    return Slider
end

-- Компонент: Toggle (Checkbox)
function Library:AddToggle(module, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    
    local value = self.Config:GetFlag(flag, default)
    
    local Toggle = {}
    Toggle.Value = value
    
    -- Контейнер
    Toggle.Element = Instance.new("Frame")
    Toggle.Element.Name = name
    Toggle.Element.Size = UDim2.new(0, 207, 0, 35)
    Toggle.Element.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    Toggle.Element.BackgroundTransparency = 0.1
    Toggle.Element.BorderSizePixel = 0
    
    local ElementCorner = Instance.new("UICorner")
    ElementCorner.CornerRadius = UDim.new(0, 4)
    ElementCorner.Parent = Toggle.Element
    
    -- Кнопка
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Toggle.Element
    
    -- Название
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -50, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    NameLabel.TextSize = 13
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Toggle.Element
    
    -- Переключатель
    local Switch = Instance.new("Frame")
    Switch.Name = "Switch"
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Position = UDim2.new(1, -40, 0.5, -10)
    Switch.BackgroundColor3 = value and Color3.fromRGB(152, 181, 255) or Color3.fromRGB(52, 66, 89)
    Switch.BorderSizePixel = 0
    Switch.Parent = Toggle.Element
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    -- Ползунок переключателя
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Switch
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    -- Функция переключения
    function Toggle:SetValue(newValue)
        self.Value = newValue
        
        TweenService:Create(Switch, TweenInfo.new(0.2), {
            BackgroundColor3 = newValue and Color3.fromRGB(152, 181, 255) or Color3.fromRGB(52, 66, 89)
        }):Play()
        
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = newValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        Library.Config:SetFlag(flag, newValue)
        Library.Config:Save(Library.ConfigName)
        
        callback(newValue)
    end
    
    Button.MouseButton1Click:Connect(function()
        Toggle:SetValue(not Toggle.Value)
    end)
    
    table.insert(module.Components, Toggle)
    return Toggle
end

-- Компонент: Dropdown
function Library:AddDropdown(module, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2"}
    local default = config.Default or options[1]
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    
    local value = self.Config:GetFlag(flag, default)
    
    local Dropdown = {}
    Dropdown.Value = value
    Dropdown.Open = false
    
    -- Контейнер
    Dropdown.Element = Instance.new("Frame")
    Dropdown.Element.Name = name
    Dropdown.Element.Size = UDim2.new(0, 207, 0, 70)
    Dropdown.Element.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    Dropdown.Element.BackgroundTransparency = 0.1
    Dropdown.Element.BorderSizePixel = 0
    
    local ElementCorner = Instance.new("UICorner")
    ElementCorner.CornerRadius = UDim.new(0, 4)
    ElementCorner.Parent = Dropdown.Element
    
    -- Название
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -20, 0, 20)
    NameLabel.Position = UDim2.new(0, 10, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextTransparency = 0.2
    NameLabel.TextSize = 11
    NameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Dropdown.Element
    
    -- Кнопка выбора
    local SelectButton = Instance.new("TextButton")
    SelectButton.Name = "SelectButton"
    SelectButton.Size = UDim2.new(1, 0, 0, 35)
    SelectButton.Position = UDim2.new(0, 0, 0, 25)
    SelectButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    SelectButton.BorderSizePixel = 0
    SelectButton.Text = ""
    SelectButton.AutoButtonColor = false
    SelectButton.Parent = Dropdown.Element
    
    local SelectCorner = Instance.new("UICorner")
    SelectCorner.CornerRadius = UDim.new(0, 6)
    SelectCorner.Parent = SelectButton
    
    -- Текст выбранного значения
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(1, -40, 1, 0)
    ValueLabel.Position = UDim2.new(0, 10, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = value
    ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    ValueLabel.TextSize = 12
    ValueLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValueLabel.Parent = SelectButton
    
    -- Стрелка
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -25, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Color3.fromRGB(150, 150, 170)
    Arrow.TextSize = 10
    Arrow.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Arrow.Parent = SelectButton
    
    -- Список опций
    local OptionsList = Instance.new("Frame")
    OptionsList.Name = "OptionsList"
    OptionsList.Size = UDim2.new(1, 0, 0, 0)
    OptionsList.Position = UDim2.new(0, 0, 0, 65)
    OptionsList.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    OptionsList.BorderSizePixel = 0
    OptionsList.ClipsDescendants = true
    OptionsList.Visible = false
    OptionsList.ZIndex = 10
    OptionsList.Parent = Dropdown.Element
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = OptionsList
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Parent = OptionsList
    
    -- Создаем опции
    for _, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = option
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        OptionButton.BorderSizePixel = 0
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(180, 180, 200)
        OptionButton.TextSize = 12
        OptionButton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = OptionsList
        
        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            Dropdown:SetValue(option)
            Dropdown:Toggle()
        end)
    end
    
    -- Функция переключения
    function Dropdown:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            OptionsList.Visible = true
            local targetHeight = #options * 30
            
            TweenService:Create(OptionsList, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            }):Play()
            
            TweenService:Create(Arrow, TweenInfo.new(0.2), {
                Rotation = 180
            }):Play()
            
            Dropdown.Element.Size = UDim2.new(1, -10, 0, 70 + targetHeight)
        else
            TweenService:Create(OptionsList, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            TweenService:Create(Arrow, TweenInfo.new(0.2), {
                Rotation = 0
            }):Play()
            
            task.wait(0.2)
            OptionsList.Visible = false
            Dropdown.Element.Size = UDim2.new(1, -10, 0, 70)
        end
    end
    
    function Dropdown:SetValue(newValue)
        self.Value = newValue
        ValueLabel.Text = newValue
        
        Library.Config:SetFlag(flag, newValue)
        Library.Config:Save(Library.ConfigName)
        
        callback(newValue)
    end
    
    SelectButton.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end)
    
    table.insert(module.Components, Dropdown)
    return Dropdown
end

-- Компонент: Textbox
function Library:AddTextbox(module, config)
    config = config or {}
    local name = config.Name or "Textbox"
    local default = config.Default or ""
    local placeholder = config.Placeholder or "Enter text..."
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    
    local value = self.Config:GetFlag(flag, default)
    
    local Textbox = {}
    Textbox.Value = value
    
    -- Контейнер
    Textbox.Element = Instance.new("Frame")
    Textbox.Element.Name = name
    Textbox.Element.Size = UDim2.new(0, 207, 0, 50)
    Textbox.Element.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    Textbox.Element.BackgroundTransparency = 0.1
    Textbox.Element.BorderSizePixel = 0
    
    local ElementCorner = Instance.new("UICorner")
    ElementCorner.CornerRadius = UDim.new(0, 4)
    ElementCorner.Parent = Textbox.Element
    
    -- Название
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -20, 0, 20)
    NameLabel.Position = UDim2.new(0, 10, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextTransparency = 0.2
    NameLabel.TextSize = 11
    NameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Textbox.Element
    
    -- Поле ввода
    local Input = Instance.new("TextBox")
    Input.Name = "Input"
    Input.Size = UDim2.new(1, 0, 0, 35)
    Input.Position = UDim2.new(0, 0, 0, 25)
    Input.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    Input.BorderSizePixel = 0
    Input.Text = value
    Input.PlaceholderText = placeholder
    Input.TextColor3 = Color3.fromRGB(200, 200, 220)
    Input.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    Input.TextSize = 12
    Input.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Input.ClearTextOnFocus = false
    Input.Parent = Textbox.Element
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = Input
    
    local InputPadding = Instance.new("UIPadding")
    InputPadding.PaddingLeft = UDim.new(0, 10)
    InputPadding.PaddingRight = UDim.new(0, 10)
    InputPadding.Parent = Input
    
    -- Функция обновления
    function Textbox:SetValue(newValue)
        self.Value = newValue
        Input.Text = newValue
        
        Library.Config:SetFlag(flag, newValue)
        Library.Config:Save(Library.ConfigName)
        
        callback(newValue)
    end
    
    Input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            Textbox:SetValue(Input.Text)
        end
    end)
    
    table.insert(module.Components, Textbox)
    return Textbox
end

-- Компонент: Color Picker
function Library:AddColorPicker(module, config)
    config = config or {}
    local name = config.Name or "Color"
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    
    local savedColor = self.Config:GetFlag(flag)
    local value = default
    
    if savedColor and type(savedColor) == "table" then
        value = Color3.fromRGB(savedColor.R or 255, savedColor.G or 255, savedColor.B or 255)
    end
    
    local h, s, v = ColorUtils.RGBtoHSV(value)
    
    local ColorPicker = {}
    ColorPicker.Value = value
    ColorPicker.Hue = h
    ColorPicker.Saturation = s
    ColorPicker.Brightness = v
    ColorPicker.Open = false
    
    -- Контейнер
    ColorPicker.Element = Instance.new("Frame")
    ColorPicker.Element.Name = name
    ColorPicker.Element.Size = UDim2.new(0, 207, 0, 35)
    ColorPicker.Element.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    ColorPicker.Element.BackgroundTransparency = 0.1
    ColorPicker.Element.BorderSizePixel = 0
    
    local ElementCorner = Instance.new("UICorner")
    ElementCorner.CornerRadius = UDim.new(0, 4)
    ElementCorner.Parent = ColorPicker.Element
    
    -- Название
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -60, 1, 0)
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextTransparency = 0.2
    NameLabel.TextSize = 11
    NameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = ColorPicker.Element
    
    -- Кнопка с цветом
    local ColorButton = Instance.new("TextButton")
    ColorButton.Name = "ColorButton"
    ColorButton.Size = UDim2.new(0, 40, 0, 25)
    ColorButton.Position = UDim2.new(1, -40, 0.5, -12.5)
    ColorButton.BackgroundColor3 = value
    ColorButton.BorderSizePixel = 0
    ColorButton.Text = ""
    ColorButton.AutoButtonColor = false
    ColorButton.Parent = ColorPicker.Element
    
    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 6)
    ColorCorner.Parent = ColorButton
    
    local ColorStroke = Instance.new("UIStroke")
    ColorStroke.Color = Color3.fromRGB(52, 66, 89)
    ColorStroke.Thickness = 1
    ColorStroke.Transparency = 0.5
    ColorStroke.Parent = ColorButton
    
    -- Создаем окно выбора цвета
    local PickerWindow = Instance.new("Frame")
    PickerWindow.Name = "PickerWindow"
    PickerWindow.Size = UDim2.new(0, 220, 0, 200)
    PickerWindow.Position = UDim2.new(0.5, -110, 0.5, -100)
    PickerWindow.BackgroundColor3 = Color3.fromRGB(12, 13, 15)
    PickerWindow.BorderSizePixel = 0
    PickerWindow.Visible = false
    PickerWindow.ZIndex = 1000
    PickerWindow.Parent = self.ScreenGui
    
    local PickerCorner = Instance.new("UICorner")
    PickerCorner.CornerRadius = UDim.new(0, 10)
    PickerCorner.Parent = PickerWindow
    
    local PickerStroke = Instance.new("UIStroke")
    PickerStroke.Color = Color3.fromRGB(52, 66, 89)
    PickerStroke.Thickness = 1
    PickerStroke.Transparency = 0.5
    PickerStroke.Parent = PickerWindow
    
    -- Палитра SV (Saturation/Value)
    local SVPicker = Instance.new("ImageButton")
    SVPicker.Name = "SVPicker"
    SVPicker.Size = UDim2.new(0, 160, 0, 160)
    SVPicker.Position = UDim2.new(0, 10, 0, 10)
    SVPicker.BackgroundColor3 = ColorUtils.HSVtoRGB(h, 1, 1)
    SVPicker.BorderSizePixel = 0
    SVPicker.AutoButtonColor = false
    SVPicker.ZIndex = 1001
    SVPicker.Parent = PickerWindow
    
    local SVCorner = Instance.new("UICorner")
    SVCorner.CornerRadius = UDim.new(0, 6)
    SVCorner.Parent = SVPicker
    
    -- Белый градиент (Saturation)
    local WhiteGradient = Instance.new("UIGradient")
    WhiteGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    WhiteGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    WhiteGradient.Parent = SVPicker
    
    -- Черный оверлей (Value)
    local BlackOverlay = Instance.new("Frame")
    BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
    BlackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackOverlay.BorderSizePixel = 0
    BlackOverlay.ZIndex = 1002
    BlackOverlay.Parent = SVPicker
    
    local BlackCorner = Instance.new("UICorner")
    BlackCorner.CornerRadius = UDim.new(0, 6)
    BlackCorner.Parent = BlackOverlay
    
    local BlackGradient = Instance.new("UIGradient")
    BlackGradient.Rotation = 90
    BlackGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),  -- Верх: непрозрачный черный (темный)
        NumberSequenceKeypoint.new(1, 1)   -- Низ: прозрачный (яркий)
    }
    BlackGradient.Parent = BlackOverlay
    
    -- Курсор выбора
    local SVCursor = Instance.new("Frame")
    SVCursor.Name = "SVCursor"
    SVCursor.Size = UDim2.new(0, 12, 0, 12)
    SVCursor.Position = UDim2.new(s, -6, v, -6)  -- ИСПРАВЛЕНО: убрал инверсию
    SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SVCursor.BorderSizePixel = 0
    SVCursor.ZIndex = 1003
    SVCursor.Parent = SVPicker
    
    local CursorCorner = Instance.new("UICorner")
    CursorCorner.CornerRadius = UDim.new(1, 0)
    CursorCorner.Parent = SVCursor
    
    local CursorStroke = Instance.new("UIStroke")
    CursorStroke.Color = Color3.fromRGB(0, 0, 0)
    CursorStroke.Thickness = 2
    CursorStroke.Parent = SVCursor
    
    -- Слайдер Hue
    local HueSlider = Instance.new("ImageButton")
    HueSlider.Name = "HueSlider"
    HueSlider.Size = UDim2.new(0, 30, 0, 160)
    HueSlider.Position = UDim2.new(0, 180, 0, 10)
    HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueSlider.BorderSizePixel = 0
    HueSlider.AutoButtonColor = false
    HueSlider.ZIndex = 1001
    HueSlider.Parent = PickerWindow
    
    local HueCorner = Instance.new("UICorner")
    HueCorner.CornerRadius = UDim.new(0, 6)
    HueCorner.Parent = HueSlider
    
    local HueGradient = Instance.new("UIGradient")
    HueGradient.Rotation = 90
    HueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    HueGradient.Parent = HueSlider
    
    -- Курсор Hue
    local HueCursor = Instance.new("Frame")
    HueCursor.Name = "HueCursor"
    HueCursor.Size = UDim2.new(1, 4, 0, 4)
    HueCursor.Position = UDim2.new(0.5, -2, h, -2)
    HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueCursor.BorderSizePixel = 0
    HueCursor.ZIndex = 1002
    HueCursor.Parent = HueSlider
    
    local HueCursorCorner = Instance.new("UICorner")
    HueCursorCorner.CornerRadius = UDim.new(0, 2)
    HueCursorCorner.Parent = HueCursor
    
    local HueCursorStroke = Instance.new("UIStroke")
    HueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    HueCursorStroke.Thickness = 1
    HueCursorStroke.Parent = HueCursor
    
    -- Превью цвета
    local ColorPreview = Instance.new("Frame")
    ColorPreview.Name = "ColorPreview"
    ColorPreview.Size = UDim2.new(1, -20, 0, 20)
    ColorPreview.Position = UDim2.new(0, 10, 1, -25)
    ColorPreview.BackgroundColor3 = value
    ColorPreview.BorderSizePixel = 0
    ColorPreview.ZIndex = 1001
    ColorPreview.Parent = PickerWindow
    
    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(0, 6)
    PreviewCorner.Parent = ColorPreview
    
    -- Функция обновления цвета
    local function updateColor()
        local newColor = ColorUtils.HSVtoRGB(ColorPicker.Hue, ColorPicker.Saturation, ColorPicker.Brightness)
        ColorPicker.Value = newColor
        
        ColorButton.BackgroundColor3 = newColor
        ColorPreview.BackgroundColor3 = newColor
        SVPicker.BackgroundColor3 = ColorUtils.HSVtoRGB(ColorPicker.Hue, 1, 1)
        
        Library.Config:SetFlag(flag, {
            R = math.floor(newColor.R * 255),
            G = math.floor(newColor.G * 255),
            B = math.floor(newColor.B * 255)
        })
        Library.Config:Save(Library.ConfigName)
        
        callback(newColor)
    end
    
    -- Обработка SV Picker
    local svDragging = false
    
    local function updateSVPicker(inputPos)
        -- Учитываем GUI inset (36 пикселей сверху для топбара Roblox)
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        local adjustedPos = Vector2.new(inputPos.X, inputPos.Y - guiInset.Y)
        
        local relativePos = adjustedPos - SVPicker.AbsolutePosition
        local pos = relativePos / SVPicker.AbsoluteSize
        pos = Vector2.new(math.clamp(pos.X, 0, 1), math.clamp(pos.Y, 0, 1))
        
        ColorPicker.Saturation = pos.X
        ColorPicker.Brightness = pos.Y  -- ИСПРАВЛЕНО: убрал инверсию, градиент уже инвертирован
        
        SVCursor.Position = UDim2.new(pos.X, -6, pos.Y, -6)
        updateColor()
    end
    
    SVPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
            updateSVPicker(input.Position)
        end
    end)
    
    SVPicker.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            updateSVPicker(mousePos)
        end
    end)
    
    -- Обработка Hue Slider
    local hueDragging = false
    
    local function updateHueSlider(inputPos)
        -- Учитываем GUI inset
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        local adjustedY = inputPos.Y - guiInset.Y
        
        local relativePos = adjustedY - HueSlider.AbsolutePosition.Y
        local pos = relativePos / HueSlider.AbsoluteSize.Y
        pos = math.clamp(pos, 0, 1)
        
        ColorPicker.Hue = pos
        HueCursor.Position = UDim2.new(0.5, -2, pos, -2)
        updateColor()
    end
    
    HueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            updateHueSlider(input.Position)
        end
    end)
    
    HueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            updateHueSlider(mousePos)
        end
    end)
    
    -- Открытие/закрытие окна
    function ColorPicker:Toggle()
        self.Open = not self.Open
        PickerWindow.Visible = self.Open
        
        if self.Open then
            -- Закрываем другие color picker'ы
            if Library.ActiveColorPicker and Library.ActiveColorPicker ~= self then
                Library.ActiveColorPicker:Toggle()
            end
            Library.ActiveColorPicker = self
        else
            Library.ActiveColorPicker = nil
        end
    end
    
    ColorButton.MouseButton1Click:Connect(function()
        ColorPicker:Toggle()
    end)
    
    -- Закрытие при клике вне окна
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorPicker.Open then
            local mousePos = UserInputService:GetMouseLocation()
            local pickerPos = PickerWindow.AbsolutePosition
            local pickerSize = PickerWindow.AbsoluteSize
            local buttonPos = ColorButton.AbsolutePosition
            local buttonSize = ColorButton.AbsoluteSize
            
            local outsidePicker = mousePos.X < pickerPos.X or mousePos.X > pickerPos.X + pickerSize.X or
                                 mousePos.Y < pickerPos.Y or mousePos.Y > pickerPos.Y + pickerSize.Y
            local outsideButton = mousePos.X < buttonPos.X or mousePos.X > buttonPos.X + buttonSize.X or
                                 mousePos.Y < buttonPos.Y or mousePos.Y > buttonPos.Y + buttonSize.Y
            
            if outsidePicker and outsideButton then
                task.defer(function()
                    ColorPicker:Toggle()
                end)
            end
        end
    end)
    
    table.insert(module.Components, ColorPicker)
    return ColorPicker
end

-- Компонент: Keybind (привязка клавиш)
function Library:AddKeybind(module, config)
    config = config or {}
    local name = config.Name or "Keybind"
    local default = config.Default or Enum.KeyCode.E
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    local mode = config.Mode or "Toggle" -- Toggle или Hold
    
    local savedKey = self.Config:GetFlag(flag)
    local value = default
    
    if savedKey and Enum.KeyCode[savedKey] then
        value = Enum.KeyCode[savedKey]
    end
    
    local Keybind = {}
    Keybind.Value = value
    Keybind.Listening = false
    Keybind.Mode = mode
    Keybind.Active = false
    
    -- Контейнер
    Keybind.Element = Instance.new("Frame")
    Keybind.Element.Name = name
    Keybind.Element.Size = UDim2.new(0, 207, 0, 35)
    Keybind.Element.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    Keybind.Element.BackgroundTransparency = 0.1
    Keybind.Element.BorderSizePixel = 0
    
    local ElementCorner = Instance.new("UICorner")
    ElementCorner.CornerRadius = UDim.new(0, 4)
    ElementCorner.Parent = Keybind.Element
    
    -- Название
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -90, 1, 0)
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextTransparency = 0.2
    NameLabel.TextSize = 11
    NameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Keybind.Element
    
    -- Кнопка с клавишей
    local KeyButton = Instance.new("TextButton")
    KeyButton.Name = "KeyButton"
    KeyButton.Size = UDim2.new(0, 70, 0, 25)
    KeyButton.Position = UDim2.new(1, -70, 0.5, -12.5)
    KeyButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    KeyButton.BorderSizePixel = 0
    KeyButton.Text = value.Name
    KeyButton.TextColor3 = Color3.fromRGB(200, 200, 220)
    KeyButton.TextSize = 12
    KeyButton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    KeyButton.AutoButtonColor = false
    KeyButton.Parent = Keybind.Element
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 6)
    KeyCorner.Parent = KeyButton
    
    -- Функция обновления
    function Keybind:SetValue(newKey)
        self.Value = newKey
        KeyButton.Text = newKey.Name
        
        Library.Config:SetFlag(flag, newKey.Name)
        Library.Config:Save(Library.ConfigName)
        
        callback(newKey)
    end
    
    -- Глобальный обработчик нажатий клавиш
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or Keybind.Listening then return end
        
        if input.KeyCode == Keybind.Value then
            if Keybind.Mode == "Toggle" then
                Keybind.Active = not Keybind.Active
                callback(Keybind.Active)
            else
                Keybind.Active = true
                callback(true)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if Keybind.Mode == "Hold" and input.KeyCode == Keybind.Value then
            Keybind.Active = false
            callback(false)
        end
    end)
    
    -- Обработка клика для установки клавиши
    KeyButton.MouseButton1Click:Connect(function()
        if Keybind.Listening then return end
        
        Keybind.Listening = true
        KeyButton.Text = "..."
        KeyButton.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                connection:Disconnect()
                Keybind.Listening = false
                KeyButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
                
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    Keybind:SetValue(input.KeyCode)
                else
                    KeyButton.Text = Keybind.Value.Name
                end
            end
        end)
    end)
    
    -- Hover эффект
    KeyButton.MouseEnter:Connect(function()
        if not Keybind.Listening then
            TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(32, 38, 51)
            }):Play()
        end
    end)
    
    KeyButton.MouseLeave:Connect(function()
        if not Keybind.Listening then
            TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(22, 28, 38)
            }):Play()
        end
    end)
    
    table.insert(module.Components, Keybind)
    return Keybind
end

-- Компонент: Label (текстовая метка)
function Library:AddLabel(module, config)
    config = config or {}
    local text = config.Text or "Label"
    
    local Label = {}
    
    Label.Element = Instance.new("Frame")
    Label.Element.Name = "Label"
    Label.Element.Size = UDim2.new(1, -10, 0, 25)
    Label.Element.BackgroundTransparency = 1
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text
    TextLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    TextLabel.TextSize = 12
    TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextWrapped = true
    TextLabel.Parent = Label.Element
    
    function Label:SetText(newText)
        TextLabel.Text = newText
    end
    
    table.insert(module.Components, Label)
    return Label
end

-- Компонент: Divider (разделитель)
function Library:AddDivider(module, config)
    config = config or {}
    
    local Divider = {}
    
    Divider.Element = Instance.new("Frame")
    Divider.Element.Name = "Divider"
    Divider.Element.Size = UDim2.new(1, -10, 0, 15)
    Divider.Element.BackgroundTransparency = 1
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 0.5, 0)
    Line.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Line.BorderSizePixel = 0
    Line.Parent = Divider.Element
    
    table.insert(module.Components, Divider)
    return Divider
end

-- Финальная функция - возвращаем библиотеку
return Library
