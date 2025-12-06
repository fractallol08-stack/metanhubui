--[[
    Custom UI Library
    Вдохновлено March UI, но уникальный стиль
    Тёмно-синяя тема с голубым акцентом
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Library = {}
Library.__index = Library
Library.ToggleKey = Enum.KeyCode.Insert

-- Шрифты GothamSSm
Library.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Library.FontBold = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

-- Цвета (морские бело-голубые прозрачные тона)
local Colors = {
    Background = Color3.fromRGB(15, 25, 40),
    Secondary = Color3.fromRGB(20, 35, 55),
    Tertiary = Color3.fromRGB(30, 50, 75),
    Accent = Color3.fromRGB(100, 180, 255),
    AccentDark = Color3.fromRGB(60, 120, 180),
    Border = Color3.fromRGB(80, 140, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 220, 240),
    Success = Color3.fromRGB(100, 255, 200),
    Error = Color3.fromRGB(255, 120, 150)
}

-- Утилиты
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

local function Tween(obj, props, duration, style)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

-- Создание библиотеки
function Library.new(title)
    local self = setmetatable({}, Library)
    
    -- Удаляем старый UI
    local old = CoreGui:FindFirstChild("CustomUI")
    if old then Debris:AddItem(old, 0) end
    
    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "CustomUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Главный контейнер (размер как в March UI)
    self.Container = Create("Frame", {
        Name = "Container",
        Parent = self.ScreenGui,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        Active = true
    })
    
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Container })
    Create("UIStroke", { Color = Colors.Border, Transparency = 0.5, Parent = self.Container })
    
    -- Handler (внутренний контейнер)
    self.Handler = Create("Frame", {
        Name = "Handler",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 650, 0, 450),
        BorderSizePixel = 0
    })
    
    -- Заголовок (жирный)
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = self.Handler,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.026, 0, 0.04, 0),
        Size = UDim2.new(0, 130, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Text = title or "Metan Hub",
        TextColor3 = Colors.Accent,
        TextTransparency = 0,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Разделитель после заголовка (горизонтальный)
    Create("Frame", {
        Name = "TitleDivider",
        Parent = self.Handler,
        BackgroundColor3 = Colors.Border,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0.026, 0, 0.075, 0),
        Size = UDim2.new(0, 130, 0, 1),
        BorderSizePixel = 0
    })
    
    -- Индикатор активного таба (Pin)
    self.Pin = Create("Frame", {
        Name = "Pin",
        Parent = self.Handler,
        BackgroundColor3 = Colors.Accent,
        Position = UDim2.new(0.026, 0, 0.12, 0),
        Size = UDim2.new(0, 2, 0, 16),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Pin })
    
    -- Контейнер табов (боковая панель)
    self.TabsContainer = Create("ScrollingFrame", {
        Name = "Tabs",
        Parent = self.Handler,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.026, 0, 0.1, 0),
        Size = UDim2.new(0, 129, 0, 390),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0.5, 0),
        Selectable = false
    })
    
    Create("UIListLayout", {
        Parent = self.TabsContainer,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Разделитель
    Create("Frame", {
        Name = "Divider",
        Parent = self.Handler,
        BackgroundColor3 = Colors.Border,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0.235, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0
    })
    
    -- Контейнер секций
    self.SectionsContainer = Create("Folder", {
        Name = "Sections",
        Parent = self.Handler
    })
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.TabIndex = 0
    self.Visible = true
    self._dragging = false
    self._sliderDragging = false  -- Флаг для блокировки drag при слайдере
    
    -- Drag функционал (только по заголовку)
    local dragStart, startPos
    
    -- Создаем зону для перетаскивания (только верхняя часть)
    local dragZone = Create("Frame", {
        Name = "DragZone",
        Parent = self.Handler,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    dragZone.InputBegan:Connect(function(input)
        if self._sliderDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            dragStart = input.Position
            startPos = self.Container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self._dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self._dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Tween(self.Container, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.2)
        end
    end)
    
    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Library.ToggleKey then
            self.Visible = not self.Visible
            self:ChangeVisibility(self.Visible)
        end
    end)
    
    -- Автоматическая загрузка UI
    task.spawn(function()
        task.wait(0.1)
        Tween(self.Container, {Size = UDim2.fromOffset(650, 450)}, 0.5)
    end)
    
    return self
end


-- Изменение видимости
function Library:ChangeVisibility(state)
    if state then
        Tween(self.Container, {Size = UDim2.fromOffset(650, 450)}, 0.5)
    else
        Tween(self.Container, {Size = UDim2.fromOffset(100, 50)}, 0.5)
    end
end

-- Загрузка UI
function Library:Load()
    Tween(self.Container, {Size = UDim2.fromOffset(650, 450)}, 0.5)
end

-- Обновление табов
function Library:UpdateTabs(selectedTab)
    for i, tab in ipairs(self.Tabs) do
        if tab.Button == selectedTab then
            local offset = tab.LayoutOrder * (0.087)
            Tween(self.Pin, {Position = UDim2.fromScale(0.026, 0.135 + offset)}, 0.5)
            Tween(tab.Button, {BackgroundTransparency = 0.5}, 0.5)
            Tween(tab.TextLabel, {TextTransparency = 0.2, TextColor3 = Colors.Accent}, 0.5)
            Tween(tab.Icon, {ImageTransparency = 0.2, ImageColor3 = Colors.Accent}, 0.5)
        else
            Tween(tab.Button, {BackgroundTransparency = 1}, 0.5)
            Tween(tab.TextLabel, {TextTransparency = 0.7, TextColor3 = Colors.Text}, 0.5)
            Tween(tab.Icon, {ImageTransparency = 0.8, ImageColor3 = Colors.Text}, 0.5)
        end
    end
end

-- Обновление секций
function Library:UpdateSections(leftSection, rightSection)
    for _, obj in self.SectionsContainer:GetChildren() do
        obj.Visible = (obj == leftSection or obj == rightSection)
    end
end

-- Создание таба
function Library:CreateTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.LayoutOrder = self.TabIndex
    
    local isFirst = #self.Tabs == 0
    
    -- Кнопка таба
    tab.Button = Create("TextButton", {
        Name = "Tab",
        Parent = self.TabsContainer,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = isFirst and 0.5 or 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 129, 0, 36),
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = self.TabIndex
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = tab.Button })
    
    -- Иконка таба
    tab.Icon = Create("ImageLabel", {
        Name = "Icon",
        Parent = tab.Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.1, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = icon or "rbxassetid://79095934438045",
        ImageColor3 = isFirst and Colors.Accent or Colors.Text,
        ImageTransparency = isFirst and 0.2 or 0.8,
        ScaleType = Enum.ScaleType.Fit
    })
    
    -- Текст таба
    tab.TextLabel = Create("TextLabel", {
        Name = "TextLabel",
        Parent = tab.Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.24, 0, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.FontBold,
        Text = name,
        TextColor3 = isFirst and Colors.Accent or Colors.Text,
        TextTransparency = isFirst and 0.2 or 0.7,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("UIGradient", {
        Parent = tab.TextLabel,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(155, 155, 155)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58))
        }
    })
    
    -- Левая секция
    tab.LeftSection = Create("ScrollingFrame", {
        Name = "LeftSection",
        Parent = self.SectionsContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.26, 0, 0.5, 0),
        Size = UDim2.new(0, 230, 0, 420),
        AnchorPoint = Vector2.new(0, 0.5),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0.5, 0),
        Visible = isFirst
    })
    
    Create("UIListLayout", {
        Parent = tab.LeftSection,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 5), Parent = tab.LeftSection })
    
    -- Правая секция
    tab.RightSection = Create("ScrollingFrame", {
        Name = "RightSection",
        Parent = self.SectionsContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.63, 0, 0.5, 0),
        Size = UDim2.new(0, 230, 0, 420),
        AnchorPoint = Vector2.new(0, 0.5),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0.5, 0),
        Visible = isFirst
    })
    
    Create("UIListLayout", {
        Parent = tab.RightSection,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 5), Parent = tab.RightSection })
    
    self.TabIndex += 1
    table.insert(self.Tabs, tab)
    
    if isFirst then
        self.CurrentTab = tab
    end
    
    tab.Button.MouseButton1Click:Connect(function()
        self:UpdateTabs(tab.Button)
        self:UpdateSections(tab.LeftSection, tab.RightSection)
        self.CurrentTab = tab
    end)
    
    return tab
end


-- Создание модуля (как в March UI - с заголовком, описанием и toggle)
function Library:CreateModule(tab, settings)
    local module = {}
    module._state = false
    module._size = 0
    module._multiplier = 0
    
    local parent = (settings.section == "right") and tab.RightSection or tab.LeftSection
    
    -- Основной фрейм модуля (уменьшенный размер - только заголовок и описание)
    module.Frame = Create("Frame", {
        Name = "Module",
        Parent = parent,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 220, 0, 45),
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = module.Frame })
    Create("UIStroke", { Color = Colors.Border, Transparency = 0.5, Parent = module.Frame })
    
    Create("UIListLayout", {
        Parent = module.Frame,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Header модуля (компактный)
    module.Header = Create("Frame", {
        Name = "Header",
        Parent = module.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 220, 0, 45),
        BorderSizePixel = 0
    })
    
    -- Название модуля
    Create("TextLabel", {
        Name = "ModuleName",
        Parent = module.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 10),
        Size = UDim2.new(0, 196, 0, 14),
        FontFace = Library.FontBold,
        Text = settings.title or "Module",
        TextColor3 = Colors.Accent,
        TextTransparency = 0.2,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Описание модуля
    Create("TextLabel", {
        Name = "Description",
        Parent = module.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(0, 196, 0, 12),
        FontFace = Library.Font,
        Text = settings.description or "",
        TextColor3 = Colors.TextDim,
        TextTransparency = 0.3,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Разделитель между заголовком и элементами
    Create("Frame", {
        Name = "ModuleDivider",
        Parent = module.Header,
        BackgroundColor3 = Colors.Border,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0.5, 0, 1, -2),
        Size = UDim2.new(0, 200, 0, 1),
        AnchorPoint = Vector2.new(0.5, 0),
        BorderSizePixel = 0
    })
    
    -- Options контейнер
    module.Options = Create("Frame", {
        Name = "Options",
        Parent = module.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(0, 220, 0, 0),
        BorderSizePixel = 0
    })
    
    Create("UIPadding", { PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 8), Parent = module.Options })
    Create("UIListLayout", {
        Parent = module.Options,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Функция обновления размера модуля
    function module:UpdateSize()
        local newSize = 45 + self._size + self._multiplier
        Tween(module.Frame, {Size = UDim2.fromOffset(220, newSize)}, 0.3)
    end

    
    -- Создание Toggle внутри модуля (как в March UI)
    function module:CreateToggle(toggleSettings)
        local toggle = { Value = false, Keybind = toggleSettings.keybind, _waiting = false }
        
        if self._size == 0 then self._size = 5 end
        self._size += 18
        
        module.Frame.Size = UDim2.fromOffset(220, 45 + self._size)
        module.Options.Size = UDim2.fromOffset(220, self._size)
        
        local toggleFrame = Create("Frame", {
            Name = "Toggle",
            Parent = module.Options,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 195, 0, 14)
        })
        
        Create("TextLabel", {
            Name = "Title",
            Parent = toggleFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 110, 0, 12),
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Library.Font,
            Text = toggleSettings.title or "Toggle",
            TextColor3 = Colors.Text,
            TextTransparency = 0.2,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Keybind кнопка
        local keybindBtn = Create("TextButton", {
            Name = "KeybindBtn",
            Parent = toggleFrame,
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 0.7,
            Position = UDim2.new(1, -55, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 12),
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Library.Font,
            Text = toggleSettings.keybind and toggleSettings.keybind.Name or "...",
            TextColor3 = Colors.Text,
            TextSize = 8,
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = keybindBtn })
        
        -- Toggle switch
        local switch = Create("Frame", {
            Name = "Switch",
            Parent = toggleFrame,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 22, 0, 12),
            AnchorPoint = Vector2.new(1, 0.5),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })
        
        local circle = Create("Frame", {
            Name = "Circle",
            Parent = switch,
            BackgroundColor3 = Colors.AccentDark,
            BackgroundTransparency = 0.2,
            Position = UDim2.new(0, 1, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 10),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })
        
        local function toggleFunc()
            toggle.Value = not toggle.Value
            if toggle.Value then
                Tween(switch, {BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0.3})
                Tween(circle, {BackgroundColor3 = Colors.Accent, Position = UDim2.new(1, -11, 0.5, 0)})
            else
                Tween(switch, {BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.5})
                Tween(circle, {BackgroundColor3 = Colors.AccentDark, Position = UDim2.new(0, 1, 0.5, 0)})
            end
            if toggleSettings.callback then toggleSettings.callback(toggle.Value) end
        end
        
        -- Клик по switch
        local switchBtn = Create("TextButton", {
            Parent = switch,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = ""
        })
        switchBtn.MouseButton1Click:Connect(toggleFunc)
        
        -- Keybind установка
        keybindBtn.MouseButton1Click:Connect(function()
            if toggle._waiting then return end
            toggle._waiting = true
            keybindBtn.Text = "..."
            
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, processed)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        toggle.Keybind = nil
                        keybindBtn.Text = "..."
                    else
                        toggle.Keybind = input.KeyCode
                        keybindBtn.Text = input.KeyCode.Name
                    end
                    toggle._waiting = false
                    conn:Disconnect()
                end
            end)
        end)
        
        -- Keybind активация
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed or toggle._waiting then return end
            if toggle.Keybind and input.KeyCode == toggle.Keybind then
                toggleFunc()
            end
        end)
        
        return toggle
    end
    
    -- Создание Slider внутри модуля
    function module:CreateSlider(sliderSettings)
        local slider = {}
        
        if self._size == 0 then self._size = 5 end
        self._size += 26
        
        module.Frame.Size = UDim2.fromOffset(220, 45 + self._size)
        module.Options.Size = UDim2.fromOffset(220, self._size)
        
        local sliderFrame = Create("TextButton", {
            Name = "Slider",
            Parent = module.Options,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 195, 0, 21),
            Text = "",
            AutoButtonColor = false
        })
        
        Create("TextLabel", {
            Name = "Title",
            Parent = sliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.05, 0),
            Size = UDim2.new(0, 140, 0, 13),
            FontFace = Library.FontBold,
            Text = sliderSettings.title or "Slider",
            TextColor3 = Colors.Text,
            TextTransparency = 0.2,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local valueLabel = Create("TextLabel", {
            Name = "Value",
            Parent = sliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 40, 0, 13),
            AnchorPoint = Vector2.new(1, 0),
            FontFace = Library.FontBold,
            Text = tostring(sliderSettings.default or sliderSettings.min),
            TextColor3 = Colors.Text,
            TextTransparency = 0.2,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        
        local drag = Create("Frame", {
            Name = "Drag",
            Parent = sliderFrame,
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 0.9,
            Position = UDim2.new(0.5, 0, 0.95, 0),
            Size = UDim2.new(0, 195, 0, 4),
            AnchorPoint = Vector2.new(0.5, 1),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = drag })
        
        local fill = Create("Frame", {
            Name = "Fill",
            Parent = drag,
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 97, 0, 4),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = fill })
        
        Create("UIGradient", {
            Parent = fill,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 79, 79))
            }
        })
        
        local circle = Create("Frame", {
            Name = "Circle",
            Parent = fill,
            BackgroundColor3 = Colors.Text,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 6, 0, 6),
            AnchorPoint = Vector2.new(1, 0.5),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })
        
        local min = sliderSettings.min or 0
        local max = sliderSettings.max or 100
        slider.Value = sliderSettings.default or min
        
        function slider:SetPercentage(percentage)
            local rounded = sliderSettings.round and math.floor(percentage) or math.floor(percentage * 10) / 10
            percentage = (percentage - min) / (max - min)
            local sliderSize = math.clamp(percentage, 0.02, 1) * drag.Size.X.Offset
            local value = math.clamp(rounded, min, max)
            
            self.Value = value
            valueLabel.Text = tostring(value)
            Tween(fill, {Size = UDim2.fromOffset(sliderSize, drag.Size.Y.Offset)}, 0.5)
            
            if sliderSettings.callback then
                sliderSettings.callback(value)
            end
        end
        
        local mouse = Players.LocalPlayer:GetMouse()
        local dragging = false
        
        local function update()
            local pos = (mouse.X - drag.AbsolutePosition.X) / drag.Size.X.Offset
            local percentage = min + (max - min) * pos
            slider:SetPercentage(percentage)
        end
        
        sliderFrame.MouseButton1Down:Connect(function()
            dragging = true
            update()
            
            local moveConn, releaseConn
            moveConn = mouse.Move:Connect(update)
            releaseConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    moveConn:Disconnect()
                    releaseConn:Disconnect()
                end
            end)
        end)
        
        slider:SetPercentage(slider.Value)
        
        return slider
    end

    
    -- Создание Dropdown внутри модуля
    function module:CreateDropdown(dropSettings)
        local dropdown = { _state = false, _size = 0 }
        
        if self._size == 0 then self._size = 5 end
        self._size += 40
        
        module.Frame.Size = UDim2.fromOffset(220, 45 + self._size)
        module.Options.Size = UDim2.fromOffset(220, self._size)
        
        local dropFrame = Create("TextButton", {
            Name = "Dropdown",
            Parent = module.Options,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 195, 0, 35),
            Text = "",
            AutoButtonColor = false
        })
        
        Create("TextLabel", {
            Name = "Title",
            Parent = dropFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 195, 0, 13),
            FontFace = Library.FontBold,
            Text = dropSettings.title or "Dropdown",
            TextColor3 = Colors.Text,
            TextTransparency = 0.2,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local box = Create("Frame", {
            Name = "Box",
            Parent = dropFrame,
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 0.9,
            Position = UDim2.new(0.5, 0, 1.2, 0),
            Size = UDim2.new(0, 195, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0),
            BorderSizePixel = 0,
            ClipsDescendants = true
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = box })
        
        local currentOption = Create("TextLabel", {
            Name = "CurrentOption",
            Parent = box,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.05, 0, 0.5, 0),
            Size = UDim2.new(0, 150, 0, 13),
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Library.FontBold,
            Text = dropSettings.options[1] or "Select",
            TextColor3 = Colors.Text,
            TextTransparency = 0.2,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Create("UIGradient", {
            Parent = currentOption,
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.7, 0),
                NumberSequenceKeypoint.new(0.87, 0.36),
                NumberSequenceKeypoint.new(1, 1)
            }
        })
        
        local arrow = Create("ImageLabel", {
            Name = "Arrow",
            Parent = box,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.91, 0, 0.5, 0),
            Size = UDim2.new(0, 8, 0, 8),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = "rbxassetid://84232453189324"
        })
        
        local optionsList = Create("ScrollingFrame", {
            Name = "Options",
            Parent = box,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(0, 195, 0, 0),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0.5, 0)
        })
        
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = optionsList })
        Create("UIPadding", { PaddingTop = UDim.new(0, -1), PaddingLeft = UDim.new(0, 10), Parent = optionsList })
        
        dropdown.Value = dropSettings.options[1]
        
        -- Создаем опции
        local maxOptions = dropSettings.maxOptions or 5
        for i, opt in ipairs(dropSettings.options) do
            local optBtn = Create("TextButton", {
                Name = "Option",
                Parent = optionsList,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 175, 0, 15),
                FontFace = Library.FontBold,
                Text = opt,
                TextColor3 = Colors.Text,
                TextTransparency = 0.6,
                TextSize = 9,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })
            
            Create("UIGradient", {
                Parent = optBtn,
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(0.7, 0),
                    NumberSequenceKeypoint.new(0.87, 0.36),
                    NumberSequenceKeypoint.new(1, 1)
                }
            })
            
            optBtn.MouseButton1Click:Connect(function()
                dropdown.Value = opt
                currentOption.Text = opt
                
                for _, o in optionsList:GetChildren() do
                    if o.Name == "Option" then
                        o.TextTransparency = (o.Text == opt) and 0.2 or 0.6
                    end
                end
                
                if dropSettings.callback then
                    dropSettings.callback(opt)
                end
            end)
            
            if i <= maxOptions then
                dropdown._size += 15
            end
        end
        
        optionsList.Size = UDim2.fromOffset(195, dropdown._size)
        
        function dropdown:Unfold()
            self._state = not self._state
            if self._state then
                module._multiplier += self._size
                Tween(module.Frame, {Size = UDim2.fromOffset(220, 45 + module._size + module._multiplier)}, 0.5)
                Tween(module.Options, {Size = UDim2.fromOffset(220, module._size + module._multiplier)}, 0.5)
                Tween(dropFrame, {Size = UDim2.fromOffset(195, 35 + self._size)}, 0.5)
                Tween(box, {Size = UDim2.fromOffset(195, 20 + self._size)}, 0.5)
                Tween(arrow, {Rotation = 180}, 0.5)
            else
                module._multiplier -= self._size
                Tween(module.Frame, {Size = UDim2.fromOffset(220, 45 + module._size + module._multiplier)}, 0.5)
                Tween(module.Options, {Size = UDim2.fromOffset(220, module._size + module._multiplier)}, 0.5)
                Tween(dropFrame, {Size = UDim2.fromOffset(195, 35)}, 0.5)
                Tween(box, {Size = UDim2.fromOffset(195, 20)}, 0.5)
                Tween(arrow, {Rotation = 0}, 0.5)
            end
        end
        
        dropFrame.MouseButton1Click:Connect(function()
            dropdown:Unfold()
        end)
        
        return dropdown
    end
    
    -- Создание TextBox внутри модуля
    function module:CreateTextBox(textSettings)
        local textbox = { Value = "" }
        
        if self._size == 0 then self._size = 5 end
        self._size += 30
        
        module.Frame.Size = UDim2.fromOffset(220, 45 + self._size)
        module.Options.Size = UDim2.fromOffset(220, self._size)
        
        Create("TextLabel", {
            Name = "Label",
            Parent = module.Options,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 195, 0, 13),
            FontFace = Library.FontBold,
            Text = textSettings.title or "TextBox",
            TextColor3 = Colors.Text,
            TextTransparency = 0.2,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local input = Create("TextBox", {
            Name = "Input",
            Parent = module.Options,
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 0.9,
            Size = UDim2.new(0, 195, 0, 14),
            FontFace = Library.Font,
            PlaceholderText = textSettings.placeholder or "Enter...",
            Text = "",
            TextColor3 = Colors.Text,
            PlaceholderColor3 = Colors.TextDim,
            TextSize = 9,
            ClearTextOnFocus = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = input })
        
        input.FocusLost:Connect(function()
            textbox.Value = input.Text
            if textSettings.callback then
                textSettings.callback(textbox.Value)
            end
        end)
        
        return textbox
    end
    
    -- Создание Button внутри модуля
    function module:CreateButton(btnSettings)
        if self._size == 0 then self._size = 5 end
        self._size += 22
        
        module.Frame.Size = UDim2.fromOffset(220, 45 + self._size)
        module.Options.Size = UDim2.fromOffset(220, self._size)
        
        local btn = Create("TextButton", {
            Name = "Button",
            Parent = module.Options,
            BackgroundColor3 = Colors.Tertiary,
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 195, 0, 17),
            FontFace = Library.FontBold,
            Text = "    " .. (btnSettings.title or "Button"),
            TextColor3 = Colors.TextDim,
            TextTransparency = 0.2,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(42, 50, 66)}, 0.3)
        end)
        
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.Tertiary}, 0.3)
        end)
        
        btn.MouseButton1Click:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.Accent}, 0.1)
            task.wait(0.1)
            Tween(btn, {BackgroundColor3 = Colors.Tertiary}, 0.1)
            
            if btnSettings.callback then
                btnSettings.callback()
            end
        end)
        
        return btn
    end
    
    return module
end


-- Создание простой секции (без модуля)
function Library:CreateSection(tab, name, column)
    local section = {}
    local parent = (column == "right") and tab.RightSection or tab.LeftSection
    
    section.Frame = Create("Frame", {
        Name = name,
        Parent = parent,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 220, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = section.Frame })
    Create("UIStroke", { Color = Colors.Border, Transparency = 0.5, Parent = section.Frame })
    
    -- Заголовок секции
    Create("TextLabel", {
        Name = "Title",
        Parent = section.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 18),
        FontFace = Library.FontBold,
        Text = name,
        TextColor3 = Colors.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Контейнер элементов
    section.Container = Create("Frame", {
        Name = "Container",
        Parent = section.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 23),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = section.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    Create("UIPadding", {
        Parent = section.Container,
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    return section
end

-- Создание Toggle (простой)
function Library:CreateToggle(section, name, default, callback, keybind)
    local toggle = { Value = default or false, Keybind = keybind, _waiting = false }
    
    toggle.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22)
    })
    
    toggle.Label = Create("TextLabel", {
        Name = "Label",
        Parent = toggle.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Keybind кнопка
    toggle.KeybindBtn = Create("TextButton", {
        Name = "KeybindBtn",
        Parent = toggle.Frame,
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 0.7,
        Position = UDim2.new(1, -70, 0.5, 0),
        Size = UDim2.new(0, 30, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = keybind and keybind.Name or "...",
        TextColor3 = Colors.Text,
        TextSize = 8,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = toggle.KeybindBtn })
    
    -- Toggle switch
    toggle.Switch = Create("Frame", {
        Name = "Switch",
        Parent = toggle.Frame,
        BackgroundColor3 = toggle.Value and Colors.Accent or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 14),
        AnchorPoint = Vector2.new(1, 0.5),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggle.Switch })
    
    toggle.Circle = Create("Frame", {
        Name = "Circle",
        Parent = toggle.Switch,
        BackgroundColor3 = toggle.Value and Colors.Accent or Colors.AccentDark,
        BackgroundTransparency = 0.2,
        Position = toggle.Value and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggle.Circle })
    
    local function toggleFunc()
        toggle.Value = not toggle.Value
        Tween(toggle.Switch, {BackgroundColor3 = toggle.Value and Colors.Accent or Color3.fromRGB(0, 0, 0)})
        Tween(toggle.Circle, {
            BackgroundColor3 = toggle.Value and Colors.Accent or Colors.AccentDark,
            Position = toggle.Value and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
        })
        if callback then callback(toggle.Value) end
    end
    
    -- Клик по switch
    local switchBtn = Create("TextButton", {
        Parent = toggle.Switch,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    switchBtn.MouseButton1Click:Connect(toggleFunc)
    
    -- Keybind установка
    toggle.KeybindBtn.MouseButton1Click:Connect(function()
        if toggle._waiting then return end
        toggle._waiting = true
        toggle.KeybindBtn.Text = "..."
        Tween(toggle.KeybindBtn, {BackgroundTransparency = 0.3})
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    toggle.Keybind = nil
                    toggle.KeybindBtn.Text = "..."
                else
                    toggle.Keybind = input.KeyCode
                    toggle.KeybindBtn.Text = input.KeyCode.Name
                end
                toggle._waiting = false
                Tween(toggle.KeybindBtn, {BackgroundTransparency = 0.7})
                conn:Disconnect()
            end
        end)
    end)
    
    -- Keybind активация
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or toggle._waiting then return end
        if toggle.Keybind and input.KeyCode == toggle.Keybind then
            toggleFunc()
        end
    end)
    
    if default then
        if callback then callback(true) end
    end
    
    return toggle
end


-- Создание Button (простой)
function Library:CreateButton(section, name, callback, keybind)
    local button = { Keybind = keybind, _waiting = false }
    
    button.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24)
    })
    
    button.Button = Create("TextButton", {
        Name = "Button",
        Parent = button.Frame,
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, -40, 1, 0),
        FontFace = Library.FontBold,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 10,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = button.Button })
    
    -- Keybind кнопка
    button.KeybindBtn = Create("TextButton", {
        Name = "KeybindBtn",
        Parent = button.Frame,
        BackgroundColor3 = Colors.Tertiary,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 35, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        FontFace = Library.Font,
        Text = keybind and keybind.Name or "...",
        TextColor3 = Colors.Accent,
        TextSize = 8,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = button.KeybindBtn })
    
    local function clickFunc()
        Tween(button.Button, {BackgroundColor3 = Colors.Success}, 0.1)
        task.wait(0.1)
        Tween(button.Button, {BackgroundColor3 = Colors.Accent}, 0.1)
        if callback then callback() end
    end
    
    button.Button.MouseButton1Click:Connect(clickFunc)
    
    -- Keybind установка
    button.KeybindBtn.MouseButton1Click:Connect(function()
        if button._waiting then return end
        button._waiting = true
        button.KeybindBtn.Text = "..."
        Tween(button.KeybindBtn, {BackgroundColor3 = Colors.Accent})
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    button.Keybind = nil
                    button.KeybindBtn.Text = "..."
                else
                    button.Keybind = input.KeyCode
                    button.KeybindBtn.Text = input.KeyCode.Name
                end
                button._waiting = false
                Tween(button.KeybindBtn, {BackgroundColor3 = Colors.Tertiary})
                conn:Disconnect()
            end
        end)
    end)
    
    -- Keybind активация
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or button._waiting then return end
        if button.Keybind and input.KeyCode == button.Keybind then
            clickFunc()
        end
    end)
    
    return button
end

-- Создание Slider (простой)
function Library:CreateSlider(section, name, min, max, default, callback)
    local slider = { Value = default or min }
    
    slider.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    slider.Label = Create("TextLabel", {
        Name = "Label",
        Parent = slider.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -45, 0, 14),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    slider.ValueLabel = Create("TextLabel", {
        Name = "Value",
        Parent = slider.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -45, 0, 0),
        Size = UDim2.new(0, 45, 0, 14),
        FontFace = Library.FontBold,
        Text = tostring(slider.Value),
        TextColor3 = Colors.Accent,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    slider.SliderBG = Create("Frame", {
        Name = "SliderBG",
        Parent = slider.Frame,
        BackgroundColor3 = Colors.Tertiary,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(1, 0, 0, 6),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slider.SliderBG })
    
    slider.Fill = Create("Frame", {
        Name = "Fill",
        Parent = slider.SliderBG,
        BackgroundColor3 = Colors.Accent,
        Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slider.Fill })
    
    local dragging = false
    local mouse = Players.LocalPlayer:GetMouse()
    
    local function update(input)
        local pos = math.clamp((input.Position.X - slider.SliderBG.AbsolutePosition.X) / slider.SliderBG.AbsoluteSize.X, 0, 1)
        slider.Value = math.floor(min + (max - min) * pos)
        slider.ValueLabel.Text = tostring(slider.Value)
        Tween(slider.Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
        if callback then callback(slider.Value) end
    end
    
    slider.SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    slider.SliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    return slider
end


-- Создание Dropdown (простой)
function Library:CreateDropdown(section, name, options, default, callback)
    local dropdown = { Value = default or options[1], Open = false }
    
    dropdown.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        ClipsDescendants = false
    })
    
    dropdown.Label = Create("TextLabel", {
        Name = "Label",
        Parent = dropdown.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.45, 0, 0, 22),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    dropdown.Button = Create("TextButton", {
        Name = "Button",
        Parent = dropdown.Frame,
        BackgroundColor3 = Colors.Tertiary,
        Position = UDim2.new(0.45, 0, 0, 0),
        Size = UDim2.new(0.55, 0, 0, 22),
        FontFace = Library.Font,
        Text = dropdown.Value,
        TextColor3 = Colors.Text,
        TextSize = 9,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropdown.Button })
    
    dropdown.OptionsList = Create("Frame", {
        Name = "Options",
        Parent = dropdown.Button,
        BackgroundColor3 = Colors.Tertiary,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 10,
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropdown.OptionsList })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropdown.OptionsList })
    
    for _, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Name = opt,
            Parent = dropdown.OptionsList,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 20),
            FontFace = Library.Font,
            Text = opt,
            TextColor3 = Colors.Text,
            TextSize = 9,
            ZIndex = 11,
            AutoButtonColor = false
        })
        
        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 0})
        end)
        
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 0.5})
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            dropdown.Value = opt
            dropdown.Button.Text = opt
            dropdown.Open = false
            dropdown.OptionsList.Visible = false
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, 0)})
            if callback then callback(opt) end
        end)
    end
    
    dropdown.Button.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        dropdown.OptionsList.Visible = true
        
        if dropdown.Open then
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, #options * 20)})
        else
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, 0)})
            task.wait(0.2)
            dropdown.OptionsList.Visible = false
        end
    end)
    
    return dropdown
end

-- Создание MultiDropdown (простой)
function Library:CreateMultiDropdown(section, name, options, default, callback)
    local dropdown = { Selected = default or {}, Open = false }
    
    dropdown.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        ClipsDescendants = false
    })
    
    dropdown.Label = Create("TextLabel", {
        Name = "Label",
        Parent = dropdown.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35, 0, 0, 22),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    dropdown.Button = Create("TextButton", {
        Name = "Button",
        Parent = dropdown.Frame,
        BackgroundColor3 = Colors.Tertiary,
        Position = UDim2.new(0.35, 0, 0, 0),
        Size = UDim2.new(0.65, 0, 0, 22),
        FontFace = Library.Font,
        Text = #dropdown.Selected > 0 and table.concat(dropdown.Selected, ", ") or "Select...",
        TextColor3 = Colors.Text,
        TextSize = 9,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropdown.Button })
    
    dropdown.OptionsList = Create("Frame", {
        Name = "Options",
        Parent = dropdown.Button,
        BackgroundColor3 = Colors.Tertiary,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 10,
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropdown.OptionsList })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropdown.OptionsList })
    
    for _, opt in ipairs(options) do
        local optFrame = Create("Frame", {
            Name = opt,
            Parent = dropdown.OptionsList,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 11
        })
        
        local checkBox = Create("Frame", {
            Name = "Check",
            Parent = optFrame,
            BackgroundColor3 = table.find(dropdown.Selected, opt) and Colors.Accent or Colors.Tertiary,
            Position = UDim2.new(0, 5, 0.5, -6),
            Size = UDim2.new(0, 12, 0, 12),
            ZIndex = 12
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = checkBox })
        
        Create("TextLabel", {
            Name = "Label",
            Parent = optFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 22, 0, 0),
            Size = UDim2.new(1, -27, 1, 0),
            FontFace = Library.Font,
            Text = opt,
            TextColor3 = Colors.Text,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 12
        })
        
        local optBtn = Create("TextButton", {
            Parent = optFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 13
        })
        
        optBtn.MouseEnter:Connect(function()
            Tween(optFrame, {BackgroundTransparency = 0})
        end)
        
        optBtn.MouseLeave:Connect(function()
            Tween(optFrame, {BackgroundTransparency = 0.5})
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            local index = table.find(dropdown.Selected, opt)
            if index then
                table.remove(dropdown.Selected, index)
                Tween(checkBox, {BackgroundColor3 = Colors.Tertiary})
            else
                table.insert(dropdown.Selected, opt)
                Tween(checkBox, {BackgroundColor3 = Colors.Accent})
            end
            
            dropdown.Button.Text = #dropdown.Selected > 0 and table.concat(dropdown.Selected, ", ") or "Select..."
            if callback then callback(dropdown.Selected) end
        end)
    end
    
    dropdown.Button.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        dropdown.OptionsList.Visible = true
        
        if dropdown.Open then
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, #options * 20)})
        else
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, 0)})
            task.wait(0.2)
            dropdown.OptionsList.Visible = false
        end
    end)
    
    return dropdown
end


-- Создание TextBox (простой)
function Library:CreateTextBox(section, name, placeholder, callback)
    local textbox = { Value = "" }
    
    textbox.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22)
    })
    
    textbox.Label = Create("TextLabel", {
        Name = "Label",
        Parent = textbox.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35, 0, 1, 0),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    textbox.Input = Create("TextBox", {
        Name = "Input",
        Parent = textbox.Frame,
        BackgroundColor3 = Colors.Tertiary,
        Position = UDim2.new(0.35, 5, 0, 0),
        Size = UDim2.new(0.65, -5, 1, 0),
        FontFace = Library.Font,
        PlaceholderText = placeholder or "Enter...",
        Text = "",
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextDim,
        TextSize = 9
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = textbox.Input })
    
    textbox.Input.FocusLost:Connect(function(enterPressed)
        textbox.Value = textbox.Input.Text
        if callback then callback(textbox.Value, enterPressed) end
    end)
    
    return textbox
end

-- Счётчик уведомлений для стека
Library._notifCount = 0

-- Уведомления (стекаются вверх)
function Library:Notify(title, text, duration)
    Library._notifCount = Library._notifCount + 1
    local notifIndex = Library._notifCount
    local yOffset = -10 - (75 * notifIndex)
    
    local notif = Create("Frame", {
        Name = "Notification",
        Parent = self.ScreenGui,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.15,
        Position = UDim2.new(1, 10, 1, yOffset),
        Size = UDim2.new(0, 240, 0, 65),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = notif })
    Create("UIStroke", { Color = Colors.Border, Transparency = 0.3, Parent = notif })
    
    Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 18),
        FontFace = Library.FontBold,
        Text = title,
        TextColor3 = Colors.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 23),
        Size = UDim2.new(1, -20, 0, 38),
        FontFace = Library.Font,
        Text = text,
        TextColor3 = Colors.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    Tween(notif, {Position = UDim2.new(1, -250, 1, yOffset)})
    
    task.delay(duration or 3, function()
        Tween(notif, {Position = UDim2.new(1, 10, 1, yOffset)})
        task.wait(0.3)
        notif:Destroy()
        Library._notifCount = Library._notifCount - 1
    end)
end

-- Установка клавиши toggle
function Library:SetToggleKey(key)
    Library.ToggleKey = key
end

return Library
