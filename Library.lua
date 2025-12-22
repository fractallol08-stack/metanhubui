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

    self.Collapsed = false
    self.Watermark = nil
    self._collapseTween = nil
    self._watermarkConn = nil

    self.UiScale = 1
    self._baseMainSize = UDim2.new(0, 700, 0, 500)
    self._collapsedMainSize = UDim2.new(0, 104, 0, 52)
    self.ToggleKey = Enum.KeyCode.RightShift
    self.ThemeName = "Basic"
    self._themeAccent = Color3.fromRGB(152, 181, 255)
    self._themeStroke = Color3.fromRGB(52, 66, 89)
    self._themeBg = Color3.fromRGB(12, 13, 15)
    self._titleLabel = nil
    self._titleIcon = nil
    self._mainStroke = nil
    self._watermarkStroke = nil
    self._watermarkRestoreIcon = nil
    self._settingsPanelStroke = nil
    self._settingsPanelIcon = nil
    self._settingsPanelTitle = nil
    self._settingsPanelTitleGradient = nil

    self._dragRenderConn = nil
    self._settingsTween = nil

    self._settingsContentTween = nil
    self._settingsSwitching = false
    self._pendingSettingsModule = nil
    
    self:CreateUI()
    self:SetupDragging()
    self:SetupToggle()
    
    return self
end

function Library:_getScaledSize(size)
    local xs = math.floor(size.X.Offset * self.UiScale)
    local ys = math.floor(size.Y.Offset * self.UiScale)
    return UDim2.new(size.X.Scale, xs, size.Y.Scale, ys)
end

function Library:GetMainSize()
    return self:_getScaledSize(self._baseMainSize)
end

function Library:GetCollapsedSize()
    return self:_getScaledSize(self._collapsedMainSize)
end

function Library:SetTransparency(alpha)
    alpha = math.clamp(alpha, 0, 1)

    if self.MainFrame then
        self.MainFrame.BackgroundTransparency = alpha
    end
    if self.Watermark then
        self.Watermark.BackgroundTransparency = alpha
    end
    if self.SettingsPanel then
        self.SettingsPanel.BackgroundTransparency = alpha
    end
end

function Library:SetScale(scale)
    self.UiScale = math.clamp(scale, 0.6, 1.6)

    if self.Collapsed then
        if self.MainFrame then
            self.MainFrame.Size = self:GetCollapsedSize()
        end
    else
        if self.MainFrame then
            self.MainFrame.Size = self:GetMainSize()
        end
    end
end

function Library:ApplyTheme(themeName)
    local themes = {
        Basic = {
            Accent = Color3.fromRGB(152, 181, 255),
            Stroke = Color3.fromRGB(52, 66, 89),
            Bg = Color3.fromRGB(12, 13, 15)
        },
        Blood = {
            Accent = Color3.fromRGB(255, 70, 90),
            Stroke = Color3.fromRGB(120, 45, 55),
            Bg = Color3.fromRGB(12, 13, 15)
        },
        Cosmic = {
            Accent = Color3.fromRGB(187, 140, 255),
            Stroke = Color3.fromRGB(76, 58, 110),
            Bg = Color3.fromRGB(12, 13, 15)
        },
        Solar = {
            Accent = Color3.fromRGB(255, 200, 90),
            Stroke = Color3.fromRGB(120, 95, 55),
            Bg = Color3.fromRGB(12, 13, 15)
        },
        Black = {
            Accent = Color3.fromRGB(210, 210, 210),
            Stroke = Color3.fromRGB(70, 70, 70),
            Bg = Color3.fromRGB(10, 10, 10)
        },
        Water = {
            Accent = Color3.fromRGB(90, 200, 255),
            Stroke = Color3.fromRGB(45, 90, 120),
            Bg = Color3.fromRGB(12, 13, 15)
        }
    }

    local t = themes[themeName] or themes.Basic
    self.ThemeName = themeName
    self._themeAccent = t.Accent
    self._themeStroke = t.Stroke
    self._themeBg = t.Bg

    if self.MainFrame then
        self.MainFrame.BackgroundColor3 = self._themeBg
    end
    if self.Watermark then
        self.Watermark.BackgroundColor3 = self._themeBg
    end
    if self.SettingsPanel then
        self.SettingsPanel.BackgroundColor3 = self._themeBg
    end

    if self._mainStroke then
        self._mainStroke.Color = self._themeStroke
    end
    if self._watermarkStroke then
        self._watermarkStroke.Color = self._themeStroke
    end
    if self._settingsPanelStroke then
        self._settingsPanelStroke.Color = self._themeStroke
    end

    if self._titleIcon then
        self._titleIcon.ImageColor3 = self._themeAccent
    end
    if self._watermarkRestoreIcon then
        self._watermarkRestoreIcon.ImageColor3 = self._themeAccent
    end
    if self._settingsPanelIcon then
        self._settingsPanelIcon.ImageColor3 = self._themeAccent
    end
    if self._settingsPanelTitle then
        self._settingsPanelTitle.TextColor3 = self._themeAccent
    end
end

function Library:ToggleCollapse(forceState)
    local target = forceState
    if target == nil then
        target = not self.Collapsed
    end

    if self._collapseTween then
        pcall(function()
            self._collapseTween:Cancel()
        end)
        self._collapseTween = nil
    end

    self.Collapsed = target

    if self.Collapsed then
        if self.SettingsPanel then
            self.SettingsPanel.Visible = false
        end

        if self.Watermark then
            self.Watermark.Visible = true
        end

        local goal = {
            Size = self:GetCollapsedSize()
        }
        self._collapseTween = TweenService:Create(self.MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goal)
        self._collapseTween:Play()
        self._collapseTween.Completed:Once(function()
            if self.Collapsed then
                self.MainFrame.Visible = false
            end
        end)
    else
        self.MainFrame.Visible = true
        if self.Watermark then
            self.Watermark.Visible = false
        end

        self.MainFrame.Size = self:GetCollapsedSize()
        local goal = {
            Size = self:GetMainSize()
        }
        self._collapseTween = TweenService:Create(self.MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goal)
        self._collapseTween:Play()
    end
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
    self.MainFrame.Size = self:GetMainSize()
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    self.MainFrame.BackgroundColor3 = self._themeBg  -- March UI стиль
    self.MainFrame.BackgroundTransparency = 0.05  -- March UI прозрачность
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = false
    self.MainFrame.Parent = self.ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = self.MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = self._themeStroke
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.5
    MainStroke.Parent = self.MainFrame
    self._mainStroke = MainStroke
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = self.MainFrame
    
    -- Иконка
    local TitleIcon = Instance.new("ImageButton")
    TitleIcon.Name = "Icon"
    TitleIcon.Size = UDim2.new(0, 18, 0, 18)
    TitleIcon.Position = UDim2.new(0, 18, 0, 26)
    TitleIcon.AnchorPoint = Vector2.new(0, 0.5)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Image = "rbxassetid://107819132007001"
    TitleIcon.ImageColor3 = self._themeAccent
    TitleIcon.ScaleType = Enum.ScaleType.Fit
    TitleIcon.AutoButtonColor = false
    TitleIcon.Parent = TitleBar
    self._titleIcon = TitleIcon
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "ClientName"
    TitleLabel.Size = UDim2.new(0, 200, 0, 13)
    TitleLabel.Position = UDim2.new(0, 42, 0, 26)
    TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Title
    TitleLabel.TextColor3 = self._themeAccent
    TitleLabel.TextTransparency = 0.2
    TitleLabel.TextSize = 13
    TitleLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    self._titleLabel = TitleLabel
    
    -- macOS-style Close Button (красный кружок)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 12, 0, 12)
    CloseButton.Position = UDim2.new(1, -20, 0, 23)
    CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 95, 86)  -- macOS red
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton
    
    -- Hover эффект для кнопки закрытия
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 115, 106)
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 95, 86)
        }):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = false
        if self.SettingsPanel then
            self.SettingsPanel.Visible = false
        end
    end)
    
    -- Градиент для заголовка
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    TitleGradient.Parent = TitleLabel

    local TitleDivider = Instance.new("Frame")
    TitleDivider.Name = "TitleDivider"
    TitleDivider.Size = UDim2.new(0, 129, 0, 1)
    TitleDivider.Position = UDim2.new(0, 18, 0, 40)
    TitleDivider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    TitleDivider.BackgroundTransparency = 0.5
    TitleDivider.BorderSizePixel = 0
    TitleDivider.Parent = self.MainFrame

    self.Watermark = Instance.new("Frame")
    self.Watermark.Name = "Watermark"
    self.Watermark.Size = UDim2.new(0, 360, 0, 30)
    self.Watermark.Position = UDim2.new(0, 10, 0, 10)
    self.Watermark.BackgroundColor3 = self._themeBg
    self.Watermark.BackgroundTransparency = 0.05
    self.Watermark.BorderSizePixel = 0
    self.Watermark.Visible = false
    self.Watermark.Parent = self.ScreenGui

    local WatermarkCorner = Instance.new("UICorner")
    WatermarkCorner.CornerRadius = UDim.new(0, 10)
    WatermarkCorner.Parent = self.Watermark

    local WatermarkStroke = Instance.new("UIStroke")
    WatermarkStroke.Color = self._themeStroke
    WatermarkStroke.Thickness = 1
    WatermarkStroke.Transparency = 0.5
    WatermarkStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    WatermarkStroke.Parent = self.Watermark
    self._watermarkStroke = WatermarkStroke

    local WatermarkRestore = Instance.new("TextButton")
    WatermarkRestore.Name = "Restore"
    WatermarkRestore.Size = UDim2.new(0, 30, 0, 30)
    WatermarkRestore.Position = UDim2.new(0, 0, 0, 0)
    WatermarkRestore.BackgroundTransparency = 1
    WatermarkRestore.BorderSizePixel = 0
    WatermarkRestore.Text = ""
    WatermarkRestore.AutoButtonColor = false
    WatermarkRestore.Parent = self.Watermark

    local WatermarkRestoreIcon = Instance.new("ImageLabel")
    WatermarkRestoreIcon.Name = "Icon"
    WatermarkRestoreIcon.BackgroundTransparency = 1
    WatermarkRestoreIcon.Size = UDim2.new(0, 18, 0, 18)
    WatermarkRestoreIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    WatermarkRestoreIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    WatermarkRestoreIcon.Image = "rbxassetid://107819132007001"
    WatermarkRestoreIcon.ImageColor3 = self._themeAccent
    WatermarkRestoreIcon.ImageTransparency = 0.15
    WatermarkRestoreIcon.ScaleType = Enum.ScaleType.Fit
    WatermarkRestoreIcon.Parent = WatermarkRestore
    self._watermarkRestoreIcon = WatermarkRestoreIcon

    local WatermarkText = Instance.new("TextLabel")
    WatermarkText.Name = "Text"
    WatermarkText.BackgroundTransparency = 1
    WatermarkText.Position = UDim2.new(0, 34, 0, 0)
    WatermarkText.Size = UDim2.new(1, -38, 1, 0)
    WatermarkText.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    WatermarkText.TextSize = 12
    WatermarkText.TextXAlignment = Enum.TextXAlignment.Left
    WatermarkText.TextColor3 = Color3.fromRGB(210, 210, 210)
    WatermarkText.TextTransparency = 0.15
    WatermarkText.Text = "Metan Hub | Ping: -- | FPS: --"
    WatermarkText.Parent = self.Watermark

    self:SetupWatermarkDragging()
    
    -- Контейнер для табов (слева)
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 129, 0, 401)
    self.TabContainer.Position = UDim2.new(0.026, 0, 0.111, 0)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 0
    self.TabContainer.ScrollBarImageTransparency = 1
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    self.TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.XY
    self.TabContainer.Selectable = false
    self.TabContainer.Parent = self.MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = self.TabContainer

    self.SystemTabContainer = Instance.new("Frame")
    self.SystemTabContainer.Name = "SystemTabContainer"
    self.SystemTabContainer.Size = UDim2.new(0, 129, 0, 46)
    self.SystemTabContainer.Position = UDim2.new(0.026, 0, 1, -52)
    self.SystemTabContainer.BackgroundTransparency = 1
    self.SystemTabContainer.BorderSizePixel = 0
    self.SystemTabContainer.Parent = self.MainFrame

    local SystemDivider = Instance.new("Frame")
    SystemDivider.Name = "SystemDivider"
    SystemDivider.Size = UDim2.new(1, 0, 0, 1)
    SystemDivider.Position = UDim2.new(0, 0, 0, -4)
    SystemDivider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    SystemDivider.BackgroundTransparency = 0.5
    SystemDivider.BorderSizePixel = 0
    SystemDivider.Parent = self.SystemTabContainer
    
    -- Разделитель между табами и контентом
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(0, 1, 0, 479)
    Divider.Position = UDim2.new(0.235, 0, 0.042, 0)  -- Начинается ниже заголовка
    Divider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Divider.BackgroundTransparency = 0.5
    Divider.BorderSizePixel = 0
    Divider.Parent = self.MainFrame
    
    -- Pin (индикатор активного таба)
    self.TabPin = Instance.new("Frame")
    self.TabPin.Name = "Pin"
    self.TabPin.Size = UDim2.new(0, 2, 0, 16)
    self.TabPin.Position = UDim2.new(0.026, 0, 0.136, 0)
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
    self.ContentContainer.Position = UDim2.new(0.259, 0, 0, 0)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.ClipsDescendants = true
    self.ContentContainer.Parent = self.MainFrame

    TitleIcon.MouseButton1Click:Connect(function()
        self:ToggleCollapse()
    end)

    WatermarkRestore.MouseButton1Click:Connect(function()
        self:ToggleCollapse(false)
    end)

    if self._watermarkConn then
        pcall(function()
            self._watermarkConn:Disconnect()
        end)
        self._watermarkConn = nil
    end

    do
        local lastFpsUpdate = 0
        local fps = 0
        local frames = 0

        self._watermarkConn = RunService.RenderStepped:Connect(function(dt)
            frames += 1
            lastFpsUpdate += dt
            if lastFpsUpdate < 1 then
                return
            end

            fps = frames
            frames = 0
            lastFpsUpdate = 0

            local pingText = "--"
            local pingOk, pingValue = pcall(function()
                return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            end)
            if pingOk and typeof(pingValue) == "string" then
                pingText = pingValue
            end

            if WatermarkText then
                WatermarkText.Text = "Metan Hub | Ping: " .. tostring(pingText) .. " | FPS: " .. tostring(fps)
            end
        end)
    end

    do
        local savedScale = tonumber(self.Config:GetFlag("ui_scale", 100)) or 100
        self.UiScale = math.clamp(savedScale / 100, 0.6, 1.6)

        local savedTransparency = tonumber(self.Config:GetFlag("ui_transparency", 5)) or 5
        self:SetTransparency(math.clamp(savedTransparency / 100, 0, 1))

        local savedKeyName = self.Config:GetFlag("clickgui_key", "RightShift")
        local key = Enum.KeyCode[savedKeyName]
        if key then
            self.ToggleKey = key
        end

        local savedTheme = tostring(self.Config:GetFlag("ui_theme", "Basic"))
        self:ApplyTheme(savedTheme)

        local savedTitle = tostring(self.Config:GetFlag("clickgui_name", self.Title))
        self.Title = savedTitle
        if self._titleLabel then
            self._titleLabel.Text = self.Title
        end
    end

    self.SystemTab = self:CreateTab("UI Settings", "rbxassetid://10734950309", {System = true})

    do
        local UiModule = self.SystemTab:CreateModule({
            Name = "UI",
            Description = "Interface settings"
        })

        UiModule:AddSection({Name = "Appearance"})
        UiModule:AddSlider({
            Name = "Transparency",
            Min = 0,
            Max = 25,
            Default = 5,
            Increment = 1,
            Flag = "ui_transparency",
            Callback = function(v)
                self:SetTransparency(v / 100)
            end
        })

        UiModule:AddSlider({
            Name = "Size",
            Min = 60,
            Max = 140,
            Default = 100,
            Increment = 1,
            Flag = "ui_scale",
            Callback = function(v)
                self:SetScale(v / 100)
            end
        })

        UiModule:AddSection({Name = "Click GUI"})
        UiModule:AddTextbox({
            Name = "Name",
            Default = self.Title,
            Flag = "clickgui_name",
            Callback = function(v)
                self.Title = tostring(v)
                if self._titleLabel then
                    self._titleLabel.Text = self.Title
                end
            end
        })
        UiModule:AddKeybind({
            Name = "Keybind",
            Default = self.ToggleKey,
            Flag = "clickgui_key",
            Callback = function(key)
                if typeof(key) == "EnumItem" then
                    self.ToggleKey = key
                end
            end
        })

        UiModule:AddSection({Name = "Theme"})
        UiModule:AddDropdown({
            Name = "Theme",
            Options = {"Basic", "Blood", "Cosmic", "Solar", "Black", "Water"},
            Default = self.ThemeName,
            Flag = "ui_theme",
            Callback = function(v)
                self:ApplyTheme(tostring(v))
            end
        })

        UiModule:AddSection({Name = "Info"})
        UiModule:AddLabel({Text = "Dev: Raw4.exe"})
        UiModule:AddLabel({Text = "Design: Raw4.exe"})
        UiModule:AddLabel({Text = "Build: Metan Hub"})
        UiModule:AddLabel({Text = "Owner: Raw4.exe"})
    end
end

function Library:SetupDragging()
    local dragging = false
    local dragInput, dragStart, startPos
    local targetPos = self.MainFrame.Position

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function lerpUDim2(a, b, t)
        return UDim2.new(
            lerp(a.X.Scale, b.X.Scale, t),
            math.floor(lerp(a.X.Offset, b.X.Offset, t)),
            lerp(a.Y.Scale, b.Y.Scale, t),
            math.floor(lerp(a.Y.Offset, b.Y.Offset, t))
        )
    end

    local function update(input)
        local delta = input.Position - dragStart
        targetPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    if self._dragRenderConn then
        pcall(function()
            self._dragRenderConn:Disconnect()
        end)
        self._dragRenderConn = nil
    end

    self._dragRenderConn = RunService.RenderStepped:Connect(function()
        if not self.MainFrame then return end
        self.MainFrame.Position = lerpUDim2(self.MainFrame.Position, targetPos, 0.25)
    end)

    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            targetPos = self.MainFrame.Position

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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

function Library:SetupWatermarkDragging()
    if not self.Watermark then return end

    local dragging = false
    local dragStart
    local startPos

    self.Watermark.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Watermark.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Watermark.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:SetupToggle()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == self.ToggleKey then
            self.MainFrame.Visible = not self.MainFrame.Visible
            if self.SettingsPanel then
                self.SettingsPanel.Visible = self.MainFrame.Visible and self.SettingsPanel.Visible
            end
        end
    end)
end

function Library:CreateTab(name, icon, opts)
    local Tab = {}
    Tab.Name = name
    Tab.Modules = {}
    Tab.Active = false
    Tab.IsSystem = opts and opts.System or false
    
    -- Кнопка таба
    Tab.Button = Instance.new("TextButton")
    Tab.Button.Name = name
    Tab.Button.Size = UDim2.new(1, -10, 0, 38)
    Tab.Button.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    Tab.Button.BackgroundTransparency = 1
    Tab.Button.BorderSizePixel = 0
    Tab.Button.Text = ""
    Tab.Button.AutoButtonColor = false
    if Tab.IsSystem then
        Tab.Button.Parent = self.SystemTabContainer
        Tab.Button.Position = UDim2.new(0, 0, 0, 4)
        Tab.Button.Size = UDim2.new(0, 129, 0, 38)
    else
        Tab.Button.Parent = self.TabContainer
    end
    
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
    Tab.Container.Size = UDim2.new(0, 492, 0, 439)  -- Уменьшено на 40px для поиска
    Tab.Container.Position = UDim2.new(0, 0, 0, 40)  -- Сдвинуто вниз на 40px
    Tab.Container.BackgroundTransparency = 1
    Tab.Container.BorderSizePixel = 0
    Tab.Container.ScrollBarThickness = 0
    Tab.Container.ScrollBarImageTransparency = 1
    Tab.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tab.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Tab.Container.Visible = false
    Tab.Container.Selectable = false
    Tab.Container.Parent = self.ContentContainer
    
    -- Поле поиска модулей
    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchContainer"
    SearchContainer.Size = UDim2.new(0, 492, 0, 30)
    SearchContainer.Position = UDim2.new(0, 0, 0, 5)
    SearchContainer.BackgroundTransparency = 1
    SearchContainer.BorderSizePixel = 0
    SearchContainer.Visible = false
    SearchContainer.Parent = self.ContentContainer
    
    local SearchBox = Instance.new("Frame")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -10, 1, 0)
    SearchBox.Position = UDim2.new(0, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    SearchBox.BackgroundTransparency = 0.9
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchContainer
    
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 4)
    SearchCorner.Parent = SearchBox
    
    -- Иконка лупы
    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.Position = UDim2.new(0, 10, 0.5, 0)
    SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://7072707198"  -- Magnifying glass icon
    SearchIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    SearchIcon.ImageTransparency = 0.5
    SearchIcon.Parent = SearchBox
    
    -- Текстовое поле
    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "SearchInput"
    SearchInput.Size = UDim2.new(1, -40, 1, 0)
    SearchInput.Position = UDim2.new(0, 35, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Search modules..."
    SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchInput.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
    SearchInput.TextTransparency = 0.2
    SearchInput.TextSize = 11
    SearchInput.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.Parent = SearchBox
    
    -- Функция фильтрации модулей
    local function FilterModules(query)
        query = query:lower()
        for _, module in ipairs(Tab.Modules) do
            if query == "" then
                module.Frame.Visible = true
            else
                local moduleName = module.Name:lower()
                module.Frame.Visible = moduleName:find(query, 1, true) ~= nil
            end
        end
    end
    
    -- Обработчик изменения текста
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        FilterModules(SearchInput.Text)
    end)
    
    Tab.SearchContainer = SearchContainer
    
    -- UIGridLayout для 2 колонок
    local ContainerLayout = Instance.new("UIGridLayout")
    ContainerLayout.CellSize = UDim2.new(0, 241, 0, 85)
    ContainerLayout.CellPadding = UDim2.new(0, 9, 0, 9)  -- Отступы между модулями
    ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ContainerLayout.Parent = Tab.Container
    
    local ContainerPadding = Instance.new("UIPadding")
    ContainerPadding.PaddingTop = UDim.new(0, 8)  -- Отступ сверху
    ContainerPadding.PaddingBottom = UDim.new(0, 10)
    ContainerPadding.PaddingLeft = UDim.new(0, 0)
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

    if not Tab.IsSystem then
        if not self.CurrentTab or (self.CurrentTab and self.CurrentTab.IsSystem) then
            self:SelectTab(Tab)
        end
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
        if t.SearchContainer then
            t.SearchContainer.Visible = false
        end
        
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
    if tab.SearchContainer then
        tab.SearchContainer.Visible = true
    end
    
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
    
    if self.TabPin and tab.Button then
        local mainAbs = self.MainFrame.AbsolutePosition
        local btnAbs = tab.Button.AbsolutePosition
        local btnSize = tab.Button.AbsoluteSize
        local targetY = (btnAbs.Y - mainAbs.Y) + math.floor((btnSize.Y - self.TabPin.AbsoluteSize.Y) / 2)

        TweenService:Create(self.TabPin, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(self.TabPin.Position.X.Scale, self.TabPin.Position.X.Offset, 0, targetY)
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
    local moduleKeybindEnabled = (config.KeybindEnabled == true) or (config.Keybind ~= nil)
    local moduleKeybindFlag = config.KeybindFlag or Module.Name
    
    -- Контейнер модуля (карточка) - размер 85px (оптимизированный)
    Module.Frame = Instance.new("Frame")
    Module.Frame.Name = Module.Name
    Module.Frame.Size = UDim2.new(0, 241, 0, 85)
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
    Header.Size = UDim2.new(1, 0, 0, 85)
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
    Toggle.Position = UDim2.new(0.82, 0, 0.8, 0)  -- Adjusted for 85px height
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

    if moduleKeybindEnabled then
        -- Keybind
        local Keybind = Instance.new("Frame")
        Keybind.Name = "Keybind"
        Keybind.Size = UDim2.new(0, 33, 0, 15)
        Keybind.Position = UDim2.new(0.15, 0, 0.78, 0)  -- Adjusted for 85px height
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
        
        -- Keybind система
        Module.Keybind = nil
        Module.KeybindConnection = nil
        local listeningForKey = false
        
        -- Функция авто-ресайза кейбинда
        local function AutoResizeKeybind(text)
            local textSize = game:GetService("TextService"):GetTextSize(
                text,
                10,
                Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Vector2.new(1000, 13)
            )
            local newWidth = math.clamp(textSize.X + 8, 33, 60)
            Keybind.Size = UDim2.new(0, newWidth, 0, 15)
            KeybindLabel.Size = UDim2.new(0, newWidth - 8, 0, 13)
        end
        
        -- Функция установки кейбинда
        function Module:SetKeybind(keyCode)
            if self.KeybindConnection then
                self.KeybindConnection:Disconnect()
                self.KeybindConnection = nil
            end
            
            self.Keybind = keyCode
            
            if keyCode then
                local keyName = keyCode.Name
                KeybindLabel.Text = keyName
                AutoResizeKeybind(keyName)
                
                -- Сохраняем в конфиг
                if not Library.Config.Flags._keybinds then
                    Library.Config.Flags._keybinds = {}
                end
                Library.Config.Flags._keybinds[moduleKeybindFlag] = keyName
                Library.Config:Save(Library.ConfigName)
                
                -- Глобальный обработчик для переключения модуля
                self.KeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.KeyCode == keyCode then
                        Module.Expanded = not Module.Expanded
                        
                        -- Анимация toggle
                        TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Position = Module.Expanded and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 0, 0.5, 0),
                            BackgroundColor3 = Module.Expanded and Color3.fromRGB(152, 181, 255) or Color3.fromRGB(66, 80, 115)
                        }):Play()
                        
                        TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Module.Expanded and Color3.fromRGB(152, 181, 255) or Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = Module.Expanded and 0.7 or 0.7
                        }):Play()
                    end
                end)
            else
                KeybindLabel.Text = "None"
                AutoResizeKeybind("None")
                
                -- Удаляем из конфига
                if Library.Config.Flags._keybinds then
                    Library.Config.Flags._keybinds[moduleKeybindFlag] = nil
                    Library.Config:Save(Library.ConfigName)
                end
            end
        end
        
        -- RMB для установки кейбинда
        Keybind.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                if not listeningForKey then
                    listeningForKey = true
                    KeybindLabel.Text = "..."
                    AutoResizeKeybind("...")
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(keyInput, gameProcessed)
                        if gameProcessed then return end
                        
                        -- Backspace для очистки
                        if keyInput.KeyCode == Enum.KeyCode.Backspace then
                            Module:SetKeybind(nil)
                            listeningForKey = false
                            connection:Disconnect()
                        -- Любая другая клавиша
                        elseif keyInput.KeyCode ~= Enum.KeyCode.Unknown then
                            Module:SetKeybind(keyInput.KeyCode)
                            listeningForKey = false
                            connection:Disconnect()
                        end
                    end)
                end
            end
        end)
        
        -- Загружаем сохраненный кейбинд или стартовый из конфига
        if Library.Config.Flags._keybinds and Library.Config.Flags._keybinds[moduleKeybindFlag] then
            local savedKeyName = Library.Config.Flags._keybinds[moduleKeybindFlag]
            local keyCode = Enum.KeyCode[savedKeyName]
            if keyCode then
                Module:SetKeybind(keyCode)
            end
        elseif typeof(config.Keybind) == "EnumItem" then
            Module:SetKeybind(config.Keybind)
        elseif type(config.Keybind) == "string" and Enum.KeyCode[config.Keybind] then
            Module:SetKeybind(Enum.KeyCode[config.Keybind])
        end
    else
        Module.Keybind = nil
        Module.KeybindConnection = nil
    end
    
    -- Единственный Divider под заголовком (Y: 0.55)
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(0, 241, 0, 1)
    Divider.Position = UDim2.new(0.5, 0, 0.55, 0)
    Divider.AnchorPoint = Vector2.new(0.5, 0)
    Divider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Divider.BackgroundTransparency = 0.5
    Divider.BorderSizePixel = 0
    Divider.Parent = Header
    
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
        elseif k == "AddSection" then
            return function(_, ...) return self:AddSection(Module, ...) end
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
        self.SettingsPanel.BackgroundColor3 = self._themeBg
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
    PanelStroke.Color = self._themeStroke
    PanelStroke.Thickness = 1
    PanelStroke.Transparency = 0.5
    PanelStroke.Parent = self.SettingsPanel
    self._settingsPanelStroke = PanelStroke
        
        -- Иконка панели
        local PanelIcon = Instance.new("ImageLabel")
        PanelIcon.Name = "Icon"
        PanelIcon.Size = UDim2.new(0, 18, 0, 18)
        PanelIcon.Position = UDim2.new(0, 18, 0, 26)
        PanelIcon.AnchorPoint = Vector2.new(0, 0.5)
        PanelIcon.BackgroundTransparency = 1
        PanelIcon.Image = "rbxassetid://107819132007001"
        PanelIcon.ImageColor3 = self._themeAccent
        PanelIcon.ScaleType = Enum.ScaleType.Fit
        PanelIcon.ZIndex = 11
        PanelIcon.Parent = self.SettingsPanel
        self._settingsPanelIcon = PanelIcon
        
        -- Заголовок панели (для перетаскивания)
        local PanelTitle = Instance.new("TextLabel")
        PanelTitle.Name = "PanelTitle"
        PanelTitle.Size = UDim2.new(0, 200, 0, 13)
        PanelTitle.Position = UDim2.new(0, 42, 0, 26)
        PanelTitle.AnchorPoint = Vector2.new(0, 0.5)
        PanelTitle.BackgroundTransparency = 1
        PanelTitle.Text = "Settings"
        PanelTitle.TextColor3 = self._themeAccent
        PanelTitle.TextTransparency = 0.2
        PanelTitle.TextSize = 13
        PanelTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
        PanelTitle.ZIndex = 11
        PanelTitle.Parent = self.SettingsPanel
        self._settingsPanelTitle = PanelTitle
        
        -- Градиент для заголовка панели
        local PanelTitleGradient = Instance.new("UIGradient")
        PanelTitleGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }
        PanelTitleGradient.Parent = PanelTitle
        self._settingsPanelTitleGradient = PanelTitleGradient
        
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
        CloseButton.Size = UDim2.new(0, 24, 0, 24)
        CloseButton.Position = UDim2.new(0, 14, 0, 14)
        CloseButton.BackgroundTransparency = 1
        CloseButton.BorderSizePixel = 0
        CloseButton.Text = ""
        CloseButton.AutoButtonColor = false
        CloseButton.ZIndex = 11
        CloseButton.Parent = self.SettingsPanel
        
        -- Иконка закрытия (крестик)
        local CloseIcon = Instance.new("ImageLabel")
        CloseIcon.Size = UDim2.new(1, 0, 1, 0)
        CloseIcon.BackgroundTransparency = 1
        CloseIcon.Image = "rbxassetid://10747384394"
        CloseIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        CloseIcon.ImageTransparency = 0.7
        CloseIcon.ScaleType = Enum.ScaleType.Fit
        CloseIcon.ZIndex = 11
        CloseIcon.Parent = CloseButton
        
        CloseButton.MouseButton1Click:Connect(function()
            self:HideSettingsPanel()
        end)
        
        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseIcon, TweenInfo.new(0.2), {
                ImageTransparency = 0.2
            }):Play()
        end)
        
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseIcon, TweenInfo.new(0.2), {
                ImageTransparency = 0.7
            }):Play()
        end)

        self.SettingsGroup = Instance.new("CanvasGroup")
        self.SettingsGroup.Name = "SettingsGroup"
        self.SettingsGroup.Size = UDim2.new(1, 0, 1, 0)
        self.SettingsGroup.Position = UDim2.new(0, 0, 0, 0)
        self.SettingsGroup.BackgroundTransparency = 1
        self.SettingsGroup.BorderSizePixel = 0
        self.SettingsGroup.GroupTransparency = 0
        self.SettingsGroup.ZIndex = 11
        self.SettingsGroup.Parent = self.SettingsPanel

        -- Контейнер для компонентов
        self.SettingsContent = Instance.new("ScrollingFrame")
        self.SettingsContent.Name = "SettingsContent"
        self.SettingsContent.Size = UDim2.new(0, 260, 0, 445)
        self.SettingsContent.Position = UDim2.new(0, 10, 0, 45)
        self.SettingsContent.BackgroundTransparency = 1
        self.SettingsContent.BorderSizePixel = 0
        self.SettingsContent.ScrollBarThickness = 0
        self.SettingsContent.ScrollBarImageTransparency = 1
        self.SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        self.SettingsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        self.SettingsContent.Selectable = false
        self.SettingsContent.ZIndex = 11
        self.SettingsContent.Parent = self.SettingsGroup
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ContentLayout.Parent = self.SettingsContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 8)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
        ContentPadding.Parent = self.SettingsContent
    end

    if self._settingsSwitching then
        self._pendingSettingsModule = module
        return
    end
    
    print("ShowSettingsPanel вызван для модуля:", module.Name)
    print("Компонентов в модуле:", #module.Components)
    
    local function setTitle()
        local titleLabel = self.SettingsPanel:FindFirstChild("PanelTitle")
        if titleLabel then
            titleLabel.Text = module.Name .. " Settings"
        end
    end

    local function detachChildren()
        for _, child in ipairs(self.SettingsContent:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child.Parent = nil
            end
        end
    end

    local function attachChildren()
        for i, component in ipairs(module.Components) do
            if component.Element then
                print("Добавляем компонент", i, "в панель")
                component.Element.Parent = self.SettingsContent
                component.Element.ZIndex = 11
            end
        end
    end

    local function playContentIn()
        if self._settingsContentTween then
            pcall(function()
                self._settingsContentTween:Cancel()
            end)
            self._settingsContentTween = nil
        end

        if self.SettingsGroup then
            self.SettingsGroup.GroupTransparency = 1
            self.SettingsContent.Position = UDim2.new(0, 10, 0, 51)
            local tweenA = TweenService:Create(self.SettingsGroup, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                GroupTransparency = 0
            })
            local tweenB = TweenService:Create(self.SettingsContent, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 10, 0, 45)
            })
            self._settingsContentTween = tweenA
            tweenA:Play()
            tweenB:Play()
        end
    end

    local function playContentOut(onDone)
        if self._settingsContentTween then
            pcall(function()
                self._settingsContentTween:Cancel()
            end)
            self._settingsContentTween = nil
        end

        if self.SettingsGroup then
            local tweenA = TweenService:Create(self.SettingsGroup, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                GroupTransparency = 1
            })
            local tweenB = TweenService:Create(self.SettingsContent, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 10, 0, 51)
            })
            self._settingsContentTween = tweenA
            tweenA:Play()
            tweenB:Play()
            tweenA.Completed:Once(function()
                if onDone then
                    onDone()
                end
            end)
        else
            if onDone then
                onDone()
            end
        end
    end

    local switching = (self.CurrentModule ~= nil and self.CurrentModule ~= module and self.SettingsPanel.Visible)
    if switching then
        self._settingsSwitching = true
        playContentOut(function()
            setTitle()
            detachChildren()
            attachChildren()
            playContentIn()
            self._settingsSwitching = false

            if self._pendingSettingsModule then
                local pending = self._pendingSettingsModule
                self._pendingSettingsModule = nil
                self:ShowSettingsPanel(pending)
            end
        end)
    else
        setTitle()
        detachChildren()
        attachChildren()
        playContentIn()
    end
    
    if self._settingsTween then
        pcall(function()
            self._settingsTween:Cancel()
        end)
        self._settingsTween = nil
    end

    local targetPos
    if self.SettingsPanelPosition then
        targetPos = self.SettingsPanelPosition
    else
        local mainPos = self.MainFrame.AbsolutePosition
        local mainSize = self.MainFrame.AbsoluteSize
        targetPos = UDim2.new(0, mainPos.X + mainSize.X + 10, 0, mainPos.Y)
        self.SettingsPanelPosition = targetPos
    end

    self.SettingsPanel.Position = UDim2.new(targetPos.X.Scale, targetPos.X.Offset + 20, targetPos.Y.Scale, targetPos.Y.Offset)
    self.SettingsPanel.Visible = true

    self._settingsTween = TweenService:Create(self.SettingsPanel, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = targetPos
    })
    self._settingsTween:Play()
    
    print("Панель показана на позиции:", self.SettingsPanel.Position)
    
    self.CurrentModule = module
end

function Library:HideSettingsPanel()
    if not self.SettingsPanel or not self.SettingsPanel.Visible then return end
    
    print("HideSettingsPanel вызван")
    
    -- Сохраняем текущую позицию перед скрытием
    self.SettingsPanelPosition = self.SettingsPanel.Position
    
    if self._settingsTween then
        pcall(function()
            self._settingsTween:Cancel()
        end)
        self._settingsTween = nil
    end

    local startPos = self.SettingsPanel.Position
    local endPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + 20, startPos.Y.Scale, startPos.Y.Offset)

    self._settingsTween = TweenService:Create(self.SettingsPanel, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = endPos
    })
    self._settingsTween:Play()
    self._settingsTween.Completed:Once(function()
        if self.SettingsPanel then
            self.SettingsPanel.Visible = false
            self.SettingsPanel.Position = startPos
        end
    end)

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

    local LibraryInstance = self
    
    local value = self.Config:GetFlag(flag, default)
    
    local Slider = {}
    Slider.Value = value
    
    -- Контейнер (точно как в LibraryMarch)
    Slider.Element = Instance.new("TextButton")
    Slider.Element.Name = name
    Slider.Element.Size = UDim2.new(0, 207, 0, 22)  -- Точный размер из LibraryMarch
    Slider.Element.BackgroundTransparency = 1
    Slider.Element.BorderSizePixel = 0
    Slider.Element.Text = ""
    Slider.Element.AutoButtonColor = false
    
    -- Название (точно как в LibraryMarch)
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 153, 0, 13)
    NameLabel.Position = UDim2.new(0, 0, 0.05, 0)  -- Точная позиция из LibraryMarch
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextTransparency = 0.2
    NameLabel.TextSize = 11
    NameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Slider.Element
    
    -- Значение (точно как в LibraryMarch)
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Name = "Value"
    ValueLabel.Size = UDim2.new(0, 42, 0, 13)
    ValueLabel.AnchorPoint = Vector2.new(1, 0)
    ValueLabel.Position = UDim2.new(1, 0, 0, 0)  -- Точная позиция из LibraryMarch
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.TextTransparency = 0.2
    ValueLabel.TextSize = 10
    ValueLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Slider.Element
    
    -- Трек слайдера (точно как в LibraryMarch)
    local Drag = Instance.new("Frame")
    Drag.Name = "Drag"
    Drag.Size = UDim2.new(0, 207, 0, 4)  -- Точный размер из LibraryMarch
    Drag.AnchorPoint = Vector2.new(0.5, 1)
    Drag.Position = UDim2.new(0.5, 0, 0.95, 0)  -- Точная позиция из LibraryMarch
    Drag.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Drag.BackgroundTransparency = 0.9
    Drag.BorderSizePixel = 0
    Drag.Parent = Slider.Element
    
    local DragCorner = Instance.new("UICorner")
    DragCorner.CornerRadius = UDim.new(1, 0)
    DragCorner.Parent = Drag
    
    -- Заполнение (точно как в LibraryMarch)
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    local fillSize = math.clamp((value - min) / (max - min), 0, 1) * Drag.Size.X.Offset
    Fill.Size = UDim2.new(0, fillSize, 0, 4)
    Fill.AnchorPoint = Vector2.new(0, 0.5)
    Fill.Position = UDim2.new(0, 0, 0.5, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Fill.BackgroundTransparency = 0.5
    Fill.BorderSizePixel = 0
    Fill.Parent = Drag
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill
    
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 79, 79))
    }
    FillGradient.Parent = Fill
    
    -- Ползунок (Circle) - точно как в LibraryMarch
    local Circle = Instance.new("Frame")
    Circle.Name = "Circle"
    Circle.Size = UDim2.new(0, 6, 0, 6)  -- Точный размер из LibraryMarch
    Circle.AnchorPoint = Vector2.new(1, 0.5)
    Circle.Position = UDim2.new(1, 0, 0.5, 0)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = Fill
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    -- Функция обновления значения
    function Slider:SetValue(newValue)
        newValue = math.clamp(newValue, min, max)
        newValue = math.floor(newValue / increment + 0.5) * increment
        
        self.Value = newValue
        ValueLabel.Text = tostring(newValue)
        
        local percent = (newValue - min) / (max - min)
        local dragWidth = Drag.AbsoluteSize.X
        if dragWidth <= 0 then
            dragWidth = Drag.Size.X.Offset
        end

        local sliderSize = math.clamp(percent, 0, 1) * dragWidth
        
        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, sliderSize, 0, 4)
        }):Play()

        if LibraryInstance and LibraryInstance.Config then
            LibraryInstance.Config:SetFlag(flag, newValue)
            LibraryInstance.Config:Save(LibraryInstance.ConfigName)
        end
        
        callback(newValue)
    end
    
    -- Обработка перетаскивания
    local dragging = false
    
    local function updateSlider()
        local mousePos = (Mouse.X - Drag.AbsolutePosition.X) / Drag.AbsoluteSize.X
        local percent = math.clamp(mousePos, 0, 1)
        local newValue = min + (max - min) * percent
        Slider:SetValue(newValue)
    end
    
    Slider.Element.MouseButton1Down:Connect(function()
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
    local keyFlag = config.KeybindFlag or (tostring(flag) .. "_key")
    local callback = config.Callback or function() end
    
    local value = self.Config:GetFlag(flag, default)
    
    local Toggle = {}
    Toggle.Value = value
    Toggle.Keybind = nil
    Toggle.Listening = false

    do
        local savedKey = self.Config:GetFlag(keyFlag)
        if savedKey and Enum.KeyCode[savedKey] then
            Toggle.Keybind = Enum.KeyCode[savedKey]
        elseif typeof(config.Keybind) == "EnumItem" then
            Toggle.Keybind = config.Keybind
        elseif type(config.Keybind) == "string" and Enum.KeyCode[config.Keybind] then
            Toggle.Keybind = Enum.KeyCode[config.Keybind]
        end
    end
    
    -- Контейнер (точно как в LibraryMarch)
    Toggle.Element = Instance.new("TextButton")
    Toggle.Element.Name = name
    Toggle.Element.Size = UDim2.new(0, 207, 0, 15)  -- Точный размер из LibraryMarch
    Toggle.Element.BackgroundTransparency = 1
    Toggle.Element.BorderSizePixel = 0
    Toggle.Element.Text = ""
    Toggle.Element.AutoButtonColor = false
    
    -- Название (точно как в LibraryMarch)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0, 142, 0, 13)
    TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
    TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = name
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextTransparency = 0.2
    TitleLabel.TextSize = 11
    TitleLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Toggle.Element
    
    -- Box (точно как в LibraryMarch)
    local Box = Instance.new("Frame")
    Box.Name = "Box"
    Box.Size = UDim2.new(0, 15, 0, 15)  -- Точный размер из LibraryMarch
    Box.AnchorPoint = Vector2.new(1, 0.5)
    Box.Position = UDim2.new(1, 0, 0.5, 0)
    Box.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Box.BackgroundTransparency = value and 0.7 or 0.9
    Box.BorderSizePixel = 0
    Box.Parent = Toggle.Element

    local KeybindBox = Instance.new("Frame")
    KeybindBox.Name = "KeybindBox"
    KeybindBox.Size = UDim2.fromOffset(14, 14)
    KeybindBox.Position = UDim2.new(1, -35, 0.5, 0)
    KeybindBox.AnchorPoint = Vector2.new(0, 0.5)
    KeybindBox.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    KeybindBox.BorderSizePixel = 0
    KeybindBox.Parent = Toggle.Element

    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 4)
    KeybindCorner.Parent = KeybindBox

    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "KeybindLabel"
    KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    KeybindLabel.TextScaled = false
    KeybindLabel.TextSize = 10
    KeybindLabel.Font = Enum.Font.SourceSans
    KeybindLabel.Text = Toggle.Keybind and Toggle.Keybind.Name or "None"
    KeybindLabel.Parent = KeybindBox
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box
    
    -- Fill (точно как в LibraryMarch)
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = value and UDim2.fromOffset(9, 9) or UDim2.fromOffset(0, 0)
    Fill.AnchorPoint = Vector2.new(0.5, 0.5)
    Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Fill.BackgroundTransparency = 0.2
    Fill.BorderSizePixel = 0
    Fill.Parent = Box
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill
    
    -- Функция переключения (точно как в LibraryMarch)
    function Toggle:SetValue(newValue)
        self.Value = newValue
        
        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = newValue and 0.7 or 0.9
        }):Play()
        
        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = newValue and UDim2.fromOffset(9, 9) or UDim2.fromOffset(0, 0)
        }):Play()
        
        Library.Config:SetFlag(flag, newValue)
        Library.Config:Save(Library.ConfigName)
        
        callback(newValue)
    end
    
    Toggle.Element.MouseButton1Click:Connect(function()
        Toggle:SetValue(not Toggle.Value)
    end)

    Toggle.Element.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if Toggle.Listening then return end

        Toggle.Listening = true
        KeybindLabel.Text = "..."

        local connection
        connection = UserInputService.InputBegan:Connect(function(keyInput, processed)
            if processed then return end
            if keyInput.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if keyInput.KeyCode == Enum.KeyCode.Unknown then return end

            if keyInput.KeyCode == Enum.KeyCode.Backspace then
                connection:Disconnect()
                Toggle.Listening = false
                Toggle:SetKeybind(nil)
                return
            end

            connection:Disconnect()
            Toggle.Listening = false
            Toggle:SetKeybind(keyInput.KeyCode)
        end)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or Toggle.Listening then return end
        if Toggle.Keybind and input.KeyCode == Toggle.Keybind then
            Toggle:SetValue(not Toggle.Value)
        end
    end)
    
    table.insert(module.Components, Toggle)
    return Toggle
end

-- Компонент: Dropdown (точь-в-точь как в LibraryMarch)
function Library:AddDropdown(module, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2"}
    if not table.find(options, "None") then
        table.insert(options, 1, "None")
    end

    local default = config.Default
    if default == nil then
        default = "None"
    end
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    
    local value = self.Config:GetFlag(flag, default)
    if value == nil or value == "" then
        value = "None"
    end
    
    local Dropdown = {}
    Dropdown.Value = value
    Dropdown.Open = false
    Dropdown.Size = 0
    
    -- Контейнер 207x39 (точно как в LibraryMarch)
    Dropdown.Element = Instance.new("Frame")
    Dropdown.Element.Name = name
    Dropdown.Element.Size = UDim2.new(0, 207, 0, 39)
    Dropdown.Element.BackgroundTransparency = 1
    Dropdown.Element.BorderSizePixel = 0
    
    -- Название
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 153, 0, 13)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextTransparency = 0.2
    Label.TextSize = 11
    Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Dropdown.Element
    
    -- Box 207x22 (точно как в LibraryMarch)
    local Box = Instance.new("Frame")
    Box.Name = "Box"
    Box.Size = UDim2.new(0, 207, 0, 22)
    Box.Position = UDim2.new(0, 0, 0, 17)
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 0
    Box.Parent = Dropdown.Element
    
    local BoxLayout = Instance.new("UIListLayout")
    BoxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    BoxLayout.Parent = Box
    
    -- Header (кнопка выбора)
    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size = UDim2.new(0, 207, 0, 22)
    Header.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Header.BackgroundTransparency = 0.9
    Header.BorderSizePixel = 0
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.Parent = Box
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 4)
    HeaderCorner.Parent = Header
    
    -- CurrentOption (текст выбранного значения с градиентом)
    local CurrentOption = Instance.new("TextLabel")
    CurrentOption.Name = "CurrentOption"
    CurrentOption.Size = UDim2.new(0, 161, 0, 13)
    CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
    CurrentOption.Position = UDim2.new(0.05, 0, 0.5, 0)
    CurrentOption.BackgroundTransparency = 1
    CurrentOption.Text = value
    CurrentOption.TextColor3 = Color3.fromRGB(255, 255, 255)
    CurrentOption.TextTransparency = 0.2
    CurrentOption.TextSize = 10
    CurrentOption.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
    CurrentOption.Parent = Header
    
    local CurrentGradient = Instance.new("UIGradient")
    CurrentGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.704, 0),
        NumberSequenceKeypoint.new(0.872, 0.3625),
        NumberSequenceKeypoint.new(1, 1)
    }
    CurrentGradient.Parent = CurrentOption
    
    -- Arrow (стрелка)
    local Arrow = Instance.new("ImageLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 8, 0, 8)
    Arrow.AnchorPoint = Vector2.new(0, 0.5)
    Arrow.Position = UDim2.new(0.91, 0, 0.5, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://84232453189324"
    Arrow.Parent = Header
    
    -- Options (список опций)
    local Options = Instance.new("ScrollingFrame")
    Options.Name = "Options"
    Options.Size = UDim2.new(0, 207, 0, 0)
    Options.Position = UDim2.new(0, 0, 1, 0)
    Options.BackgroundTransparency = 1
    Options.BorderSizePixel = 0
    Options.ScrollBarThickness = 0
    Options.ScrollBarImageTransparency = 1
    Options.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Options.CanvasSize = UDim2.new(0, 0, 0, 0)
    Options.Active = true
    Options.Parent = Box
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Parent = Options
    
    local OptionsPadding = Instance.new("UIPadding")
    OptionsPadding.PaddingTop = UDim.new(0, -1)
    OptionsPadding.PaddingLeft = UDim.new(0, 10)
    OptionsPadding.Parent = Options
    
    -- Создаем опции
    if #options > 0 then
        Dropdown.Size = math.min(#options * 16 + 3, 100)
        
        for _, option in ipairs(options) do
            local Option = Instance.new("TextButton")
            Option.Name = "Option"
            Option.Size = UDim2.new(0, 186, 0, 16)
            Option.AnchorPoint = Vector2.new(0, 0.5)
            Option.BackgroundTransparency = 1
            Option.Text = option
            Option.TextColor3 = Color3.fromRGB(255, 255, 255)
            Option.TextTransparency = option == value and 0.2 or 0.6
            Option.TextSize = 10
            Option.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Option.TextXAlignment = Enum.TextXAlignment.Left
            Option.AutoButtonColor = false
            Option.Active = false
            Option.Selectable = false
            Option.Parent = Options
            
            local OptionGradient = Instance.new("UIGradient")
            OptionGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.704, 0),
                NumberSequenceKeypoint.new(0.872, 0.3625),
                NumberSequenceKeypoint.new(1, 1)
            }
            OptionGradient.Parent = Option
            
            Option.MouseButton1Click:Connect(function()
                Dropdown:SetValue(option)
                Dropdown:Toggle()
            end)
        end
    end
    
    -- Функция переключения
    function Dropdown:Toggle()
        self.Open = not self.Open
        
        if self.Open then
            TweenService:Create(Dropdown.Element, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 207, 0, 39 + self.Size)
            }):Play()
            
            TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 207, 0, 22 + self.Size)
            }):Play()
            
            TweenService:Create(Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 207, 0, self.Size)
            }):Play()
            
            TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Rotation = 180
            }):Play()
        else
            TweenService:Create(Dropdown.Element, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 207, 0, 39)
            }):Play()
            
            TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 207, 0, 22)
            }):Play()
            
            TweenService:Create(Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 207, 0, 0)
            }):Play()
            
            TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Rotation = 0
            }):Play()
        end
    end
    
    function Dropdown:SetValue(newValue)
        self.Value = newValue
        CurrentOption.Text = newValue
        
        -- Обновляем прозрачность опций
        for _, option in ipairs(Options:GetChildren()) do
            if option.Name == "Option" then
                option.TextTransparency = option.Text == newValue and 0.2 or 0.6
            end
        end
        
        Library.Config:SetFlag(flag, newValue)
        Library.Config:Save(Library.ConfigName)
        
        callback(newValue)
    end
    
    Header.MouseButton1Click:Connect(function()
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

    local LibraryInstance = self
    
    local value = self.Config:GetFlag(flag, default)
    
    local Textbox = {}
    Textbox.Value = value
    
    -- Контейнер (точно как в LibraryMarch)
    Textbox.Element = Instance.new("Frame")
    Textbox.Element.Name = name
    Textbox.Element.Size = UDim2.new(0, 207, 0, 32)  -- Точный размер из LibraryMarch (13 + 15 + 4 padding)
    Textbox.Element.BackgroundTransparency = 1
    Textbox.Element.BorderSizePixel = 0
    
    -- Название (точно как в LibraryMarch)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 207, 0, 13)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextTransparency = 0.2
    Label.TextSize = 10
    Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Textbox.Element
    
    -- Поле ввода (точно как в LibraryMarch)
    local Input = Instance.new("TextBox")
    Input.Name = "Textbox"
    Input.Size = UDim2.new(0, 207, 0, 15)  -- Точный размер из LibraryMarch
    Input.Position = UDim2.new(0, 0, 0, 17)  -- Позиция после Label
    Input.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Input.BackgroundTransparency = 0.9
    Input.BorderSizePixel = 0
    Input.Text = value
    Input.PlaceholderText = placeholder
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
    Input.TextTransparency = 0.2
    Input.TextSize = 10
    Input.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Input.ClearTextOnFocus = false
    Input.Parent = Textbox.Element
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 4)
    InputCorner.Parent = Input
    
    -- Функция обновления
    function Textbox:SetValue(newValue)
        self.Value = newValue
        Input.Text = newValue
        
        if LibraryInstance and LibraryInstance.Config then
            LibraryInstance.Config:SetFlag(flag, newValue)
            LibraryInstance.Config:Save(LibraryInstance.ConfigName)
        end
        
        callback(newValue)
    end
    
    Input.FocusLost:Connect(function(enterPressed)
        Textbox:SetValue(Input.Text)
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
        local relativePos = inputPos - SVPicker.AbsolutePosition
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
        local relativePos = inputPos.Y - HueSlider.AbsolutePosition.Y
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
    local default = config.Default
    local flag = config.Flag or name
    local callback = config.Callback or function() end
    
    local savedKey = self.Config:GetFlag(flag)
    local value = nil
    if type(savedKey) == "string" and Enum.KeyCode[savedKey] then
        value = Enum.KeyCode[savedKey]
    elseif typeof(default) == "EnumItem" then
        value = default
    elseif type(default) == "string" and Enum.KeyCode[default] then
        value = Enum.KeyCode[default]
    end
    
    local Keybind = {}
    Keybind.Value = value
    Keybind.Listening = false
    
    -- Контейнер (точно как в LibraryMarch - размер checkbox)
    Keybind.Element = Instance.new("TextButton")
    Keybind.Element.Name = name
    Keybind.Element.Size = UDim2.new(0, 207, 0, 15)  -- Точный размер из LibraryMarch (как checkbox)
    Keybind.Element.BackgroundTransparency = 1
    Keybind.Element.BorderSizePixel = 0
    Keybind.Element.Text = ""
    Keybind.Element.AutoButtonColor = false
    
    -- Название (точно как в LibraryMarch)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0, 142, 0, 13)
    TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
    TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = name
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextTransparency = 0.2
    TitleLabel.TextSize = 11
    TitleLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Keybind.Element
    
    -- Keybind Box (точно как в LibraryMarch)
    local KeybindBox = Instance.new("Frame")
    KeybindBox.Name = "KeybindBox"
    KeybindBox.Size = UDim2.fromOffset(14, 14)  -- Точный размер из LibraryMarch
    KeybindBox.Position = UDim2.new(1, -35, 0.5, 0)
    KeybindBox.AnchorPoint = Vector2.new(0, 0.5)
    KeybindBox.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    KeybindBox.BorderSizePixel = 0
    KeybindBox.Parent = Keybind.Element
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 4)
    KeybindCorner.Parent = KeybindBox
    
    -- Keybind Label (точно как в LibraryMarch)
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "KeybindLabel"
    KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    KeybindLabel.TextScaled = false
    KeybindLabel.TextSize = 10
    KeybindLabel.Font = Enum.Font.SourceSans
    KeybindLabel.Text = (value and value.Name) or "None"
    KeybindLabel.Parent = KeybindBox
    
    -- Функция обновления
    function Keybind:SetValue(newKey)
        self.Value = newKey
        KeybindLabel.Text = (newKey and newKey.Name) or "None"

        if newKey then
            Library.Config:SetFlag(flag, newKey.Name)
        else
            Library.Config:SetFlag(flag, "")
        end
        Library.Config:Save(Library.ConfigName)

        callback(newKey)
    end
    
    -- Обработка клика для установки клавиши (RMB как в LibraryMarch)
    Keybind.Element.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end  -- RMB
        if Keybind.Listening then return end
        
        Keybind.Listening = true
        KeybindLabel.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(keyInput, processed)
            if processed then return end
            if keyInput.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if keyInput.KeyCode == Enum.KeyCode.Unknown then return end
            
            if keyInput.KeyCode == Enum.KeyCode.Backspace then
                Keybind:SetValue(nil)
                connection:Disconnect()
                Keybind.Listening = false
                return
            end
            
            connection:Disconnect()
            Keybind:SetValue(keyInput.KeyCode)
            Keybind.Listening = false
        end)
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

function Library:AddSection(module, config)
    config = config or {}
    local name = config.Name or "Section"

    local Section = {}

    Section.Element = Instance.new("Frame")
    Section.Element.Name = name
    Section.Element.Size = UDim2.new(0, 207, 0, 26)
    Section.Element.BackgroundTransparency = 1
    Section.Element.BorderSizePixel = 0

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 13)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextTransparency = 0.2
    Title.TextSize = 11
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Section.Element

    local Line = Instance.new("Frame")
    Line.Name = "Divider"
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -1)
    Line.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section.Element

    table.insert(module.Components, Section)
    return Section
end

-- Компонент: Mini-Module (визуальный разделитель)
function Library:AddMiniModule(module, config)
    config = config or {}
    local name = config.Name or "Section"
    
    local MiniModule = {}
    
    -- Контейнер 207x30
    MiniModule.Element = Instance.new("Frame")
    MiniModule.Element.Name = "MiniModule"
    MiniModule.Element.Size = UDim2.new(0, 207, 0, 30)
    MiniModule.Element.BackgroundColor3 = Color3.fromRGB(18, 23, 32)  -- Темнее основного фона
    MiniModule.Element.BackgroundTransparency = 0.3
    MiniModule.Element.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = MiniModule.Element
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(52, 66, 89)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MiniModule.Element
    
    -- Название по центру
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0.5, 0, 0.5, 0)
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(152, 181, 255)
    Title.TextTransparency = 0.4
    Title.TextSize = 11
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = MiniModule.Element
    
    table.insert(module.Components, MiniModule)
    return MiniModule
end

-- Компонент: Divider (разделитель)
function Library:AddDivider(module)
    local Divider = {}
    
    Divider.Element = Instance.new("Frame")
    Divider.Element.Name = "Divider"
    Divider.Element.Size = UDim2.new(0, 207, 0, 1)
    Divider.Element.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Divider.Element.BackgroundTransparency = 0.5
    Divider.Element.BorderSizePixel = 0
    
    table.insert(module.Components, Divider)
    return Divider
end

-- Финальная функция - возвращаем библиотеку
return Library
