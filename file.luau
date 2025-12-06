--[[
    Ocean UI Library
    Светлая морская тема - белые и голубые тона
    Вдохновлено March UI, но уникальный стиль
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Безопасное получение CoreGui
local CoreGui
local success, err = pcall(function()
    CoreGui = game:GetService("CoreGui")
end)
if not success then
    CoreGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Проверка на syn/gethui
local function getParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = CoreGui
        return gui.Parent
    else
        return CoreGui
    end
end

local Library = {}
Library.__index = Library
Library.ToggleKey = Enum.KeyCode.Insert
Library._parent = getParent()

-- Шрифты
Library.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Library.FontBold = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

-- Светлая морская палитра
local Colors = {
    -- Основные фоны (светлые)
    Background = Color3.fromRGB(245, 248, 252),      -- Почти белый с голубым оттенком
    Secondary = Color3.fromRGB(235, 242, 250),       -- Светло-голубой
    Tertiary = Color3.fromRGB(225, 235, 248),        -- Чуть темнее
    Card = Color3.fromRGB(255, 255, 255),            -- Чисто белый для карточек
    
    -- Акценты (морские)
    Accent = Color3.fromRGB(70, 150, 220),           -- Морской голубой
    AccentLight = Color3.fromRGB(100, 175, 235),     -- Светлый акцент
    AccentDark = Color3.fromRGB(50, 120, 190),       -- Тёмный акцент
    
    -- Границы
    Border = Color3.fromRGB(200, 215, 235),          -- Светлая граница
    BorderHover = Color3.fromRGB(150, 180, 220),     -- Граница при наведении
    
    -- Текст
    Text = Color3.fromRGB(40, 55, 75),               -- Тёмно-синий текст
    TextDim = Color3.fromRGB(100, 120, 150),         -- Приглушённый текст
    TextLight = Color3.fromRGB(255, 255, 255),       -- Белый текст
    
    -- Статусы
    Success = Color3.fromRGB(80, 200, 150),          -- Зелёный
    Error = Color3.fromRGB(240, 100, 120),           -- Красный
    Warning = Color3.fromRGB(250, 180, 80)           -- Оранжевый
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
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

-- Создание библиотеки
function Library.new(title)
    local self = setmetatable({}, Library)
    
    -- Удаляем старый UI
    local parent = Library._parent or CoreGui
    local old = parent:FindFirstChild("OceanUI")
    if old then 
        old:Destroy()
    end
    
    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "OceanUI",
        Parent = parent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Защита GUI если доступно
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
    end

    -- Главный контейнер
    self.Container = Create("Frame", {
        Name = "Container",
        Parent = self.ScreenGui,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        Active = true
    })
    
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.Container })
    
    -- Тень (эффект глубины)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 30, 1, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1
    })
    
    -- Граница
    Create("UIStroke", { 
        Color = Colors.Border, 
        Thickness = 1,
        Transparency = 0.3,
        Parent = self.Container 
    })
    
    -- Handler (внутренний контейнер)
    self.Handler = Create("Frame", {
        Name = "Handler",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 680, 0, 480),
        BorderSizePixel = 0
    })
    
    -- Верхняя панель (заголовок)
    local topBar = Create("Frame", {
        Name = "TopBar",
        Parent = self.Handler,
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 50),
        BorderSizePixel = 0
    })
    
    -- Разделитель под заголовком
    Create("Frame", {
        Name = "TopDivider",
        Parent = topBar,
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0
    })
    
    -- Иконка
    Create("Frame", {
        Name = "IconDot",
        Parent = topBar,
        BackgroundColor3 = Colors.Accent,
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.new(0, 8, 0, 8),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0
    }):FindFirstChildOfClass("UICorner") or Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = topBar.IconDot })
    
    -- Заголовок
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0.5, 0),
        Size = UDim2.new(0, 200, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.FontBold,
        Text = title or "Ocean Hub",
        TextColor3 = Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Кнопка минимизации
    local minimizeBtn = Create("TextButton", {
        Name = "Minimize",
        Parent = topBar,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(1, -45, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "−",
        TextColor3 = Colors.TextDim,
        TextSize = 18,
        FontFace = Library.FontBold,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = minimizeBtn })
    
    -- Боковая панель табов
    local sidePanel = Create("Frame", {
        Name = "SidePanel",
        Parent = self.Handler,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 160, 1, -50),
        BorderSizePixel = 0
    })
    
    -- Разделитель справа от боковой панели
    Create("Frame", {
        Name = "SideDivider",
        Parent = sidePanel,
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0
    })
    
    -- Индикатор активного таба
    self.TabIndicator = Create("Frame", {
        Name = "TabIndicator",
        Parent = sidePanel,
        BackgroundColor3 = Colors.Accent,
        Position = UDim2.new(0, 0, 0, 15),
        Size = UDim2.new(0, 3, 0, 32),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = self.TabIndicator })
    
    -- Контейнер табов
    self.TabsContainer = Create("ScrollingFrame", {
        Name = "Tabs",
        Parent = sidePanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 10),
        Size = UDim2.new(1, -16, 1, -20),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Selectable = false
    })
    
    Create("UIListLayout", {
        Parent = self.TabsContainer,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Контейнер секций (основная область)
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = self.Handler,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 50),
        Size = UDim2.new(1, -160, 1, -50),
        BorderSizePixel = 0
    })
    
    self.SectionsContainer = Create("Folder", {
        Name = "Sections",
        Parent = self.ContentArea
    })
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.TabIndex = 0
    self.Visible = true
    self._dragging = false
    
    -- Drag функционал
    local dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
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
            }, 0.15)
        end
    end)
    
    -- Минимизация
    minimizeBtn.MouseButton1Click:Connect(function()
        self.Visible = not self.Visible
        self:ChangeVisibility(self.Visible)
    end)
    
    minimizeBtn.MouseEnter:Connect(function()
        Tween(minimizeBtn, {BackgroundTransparency = 0})
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        Tween(minimizeBtn, {BackgroundTransparency = 0.5})
    end)
    
    -- Toggle visibility по клавише
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
        Tween(self.Container, {Size = UDim2.fromOffset(680, 480)}, 0.4)
    end)
    
    return self
end

-- Изменение видимости
function Library:ChangeVisibility(state)
    if state then
        Tween(self.Container, {Size = UDim2.fromOffset(680, 480)}, 0.4)
    else
        Tween(self.Container, {Size = UDim2.fromOffset(120, 50)}, 0.4)
    end
end

-- Загрузка UI
function Library:Load()
    Tween(self.Container, {Size = UDim2.fromOffset(680, 480)}, 0.4)
end

-- Обновление табов
function Library:UpdateTabs(selectedTab)
    for i, tab in ipairs(self.Tabs) do
        if tab.Button == selectedTab then
            local yPos = 15 + (tab.LayoutOrder * 44)
            Tween(self.TabIndicator, {Position = UDim2.new(0, 0, 0, yPos)}, 0.3)
            Tween(tab.Button, {BackgroundColor3 = Colors.AccentLight, BackgroundTransparency = 0.85})
            Tween(tab.TextLabel, {TextColor3 = Colors.Accent})
            Tween(tab.Icon, {ImageColor3 = Colors.Accent})
        else
            Tween(tab.Button, {BackgroundColor3 = Colors.Card, BackgroundTransparency = 1})
            Tween(tab.TextLabel, {TextColor3 = Colors.TextDim})
            Tween(tab.Icon, {ImageColor3 = Colors.TextDim})
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
        BackgroundColor3 = isFirst and Colors.AccentLight or Colors.Card,
        BackgroundTransparency = isFirst and 0.85 or 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = self.TabIndex
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tab.Button })
    
    -- Иконка таба
    tab.Icon = Create("ImageLabel", {
        Name = "Icon",
        Parent = tab.Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = icon or "rbxassetid://7733960981",
        ImageColor3 = isFirst and Colors.Accent or Colors.TextDim,
        ScaleType = Enum.ScaleType.Fit
    })
    
    -- Текст таба
    tab.TextLabel = Create("TextLabel", {
        Name = "TextLabel",
        Parent = tab.Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0.5, 0),
        Size = UDim2.new(1, -48, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.FontBold,
        Text = name,
        TextColor3 = isFirst and Colors.Accent or Colors.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Левая секция
    tab.LeftSection = Create("ScrollingFrame", {
        Name = "LeftSection",
        Parent = self.SectionsContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(0.5, -22, 1, -30),
        ScrollBarImageColor3 = Colors.Border,
        ScrollBarImageTransparency = 0.5,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = isFirst
    })
    
    Create("UIListLayout", {
        Parent = tab.LeftSection,
        Padding = UDim.new(0, 12),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Правая секция
    tab.RightSection = Create("ScrollingFrame", {
        Name = "RightSection",
        Parent = self.SectionsContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 7, 0, 15),
        Size = UDim2.new(0.5, -22, 1, -30),
        ScrollBarImageColor3 = Colors.Border,
        ScrollBarImageTransparency = 0.5,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = isFirst
    })
    
    Create("UIListLayout", {
        Parent = tab.RightSection,
        Padding = UDim.new(0, 12),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    self.TabIndex += 1
    table.insert(self.Tabs, tab)
    
    if isFirst then
        self.CurrentTab = tab
    end
    
    -- Hover эффект
    tab.Button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tab.Button, {BackgroundTransparency = 0.9})
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tab.Button, {BackgroundTransparency = 1})
        end
    end)
    
    tab.Button.MouseButton1Click:Connect(function()
        self:UpdateTabs(tab.Button)
        self:UpdateSections(tab.LeftSection, tab.RightSection)
        self.CurrentTab = tab
    end)
    
    return tab
end

-- Создание модуля (карточка с элементами)
function Library:CreateModule(tab, settings)
    local module = {}
    module._state = false
    module._size = 0
    module._multiplier = 0
    
    local parent = (settings.section == "right") and tab.RightSection or tab.LeftSection
    
    -- Основной фрейм модуля
    module.Frame = Create("Frame", {
        Name = "Module",
        Parent = parent,
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52),
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = module.Frame })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Transparency = 0.5, Parent = module.Frame })
    
    Create("UIListLayout", {
        Parent = module.Frame,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Header модуля
    module.Header = Create("Frame", {
        Name = "Header",
        Parent = module.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        BorderSizePixel = 0
    })
    
    -- Цветная полоска слева
    Create("Frame", {
        Name = "AccentBar",
        Parent = module.Header,
        BackgroundColor3 = Colors.Accent,
        Position = UDim2.new(0, 0, 0.15, 0),
        Size = UDim2.new(0, 3, 0.7, 0),
        BorderSizePixel = 0
    }):FindFirstChildOfClass("UICorner") or Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = module.Header.AccentBar })
    
    -- Название модуля
    Create("TextLabel", {
        Name = "ModuleName",
        Parent = module.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 12),
        Size = UDim2.new(1, -80, 0, 16),
        FontFace = Library.FontBold,
        Text = settings.title or "Module",
        TextColor3 = Colors.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Описание модуля
    Create("TextLabel", {
        Name = "Description",
        Parent = module.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -80, 0, 14),
        FontFace = Library.Font,
        Text = settings.description or "",
        TextColor3 = Colors.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Options контейнер
    module.Options = Create("Frame", {
        Name = "Options",
        Parent = module.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    Create("UIPadding", { 
        PaddingTop = UDim.new(0, 4), 
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = module.Options 
    })
    Create("UIListLayout", {
        Parent = module.Options,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Функция обновления размера
    function module:UpdateSize()
        local newSize = 52 + self._size + self._multiplier
        Tween(module.Frame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.25)
    end


    -- Создание Toggle
    function module:CreateToggle(toggleSettings)
        local toggle = { Value = toggleSettings.default or false }
        
        if self._size == 0 then self._size = 8 end
        self._size += 28
        
        module.Frame.Size = UDim2.new(1, 0, 0, 52 + self._size)
        module.Options.Size = UDim2.new(1, 0, 0, self._size)
        
        local toggleFrame = Create("Frame", {
            Name = "Toggle",
            Parent = module.Options,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, 24)
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toggleFrame })
        
        Create("TextLabel", {
            Name = "Title",
            Parent = toggleFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(1, -70, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Library.Font,
            Text = toggleSettings.title or "Toggle",
            TextColor3 = Colors.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Toggle switch
        local switch = Create("Frame", {
            Name = "Switch",
            Parent = toggleFrame,
            BackgroundColor3 = toggle.Value and Colors.Accent or Colors.Border,
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(0, 36, 0, 18),
            AnchorPoint = Vector2.new(1, 0.5),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })
        
        local circle = Create("Frame", {
            Name = "Circle",
            Parent = switch,
            BackgroundColor3 = Colors.Card,
            Position = toggle.Value and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })
        
        -- Тень для circle
        Create("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 1, Transparency = 0.9, Parent = circle })
        
        local function toggleFunc()
            toggle.Value = not toggle.Value
            if toggle.Value then
                Tween(switch, {BackgroundColor3 = Colors.Accent})
                Tween(circle, {Position = UDim2.new(1, -16, 0.5, 0)})
            else
                Tween(switch, {BackgroundColor3 = Colors.Border})
                Tween(circle, {Position = UDim2.new(0, 2, 0.5, 0)})
            end
            if toggleSettings.callback then toggleSettings.callback(toggle.Value) end
        end
        
        local switchBtn = Create("TextButton", {
            Parent = switch,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = ""
        })
        switchBtn.MouseButton1Click:Connect(toggleFunc)
        
        -- Hover эффект
        toggleFrame.MouseEnter:Connect(function()
            Tween(toggleFrame, {BackgroundTransparency = 0})
        end)
        toggleFrame.MouseLeave:Connect(function()
            Tween(toggleFrame, {BackgroundTransparency = 0.3})
        end)
        
        if toggle.Value and toggleSettings.callback then
            toggleSettings.callback(true)
        end
        
        return toggle
    end
    
    -- Создание Slider
    function module:CreateSlider(sliderSettings)
        local slider = {}
        
        if self._size == 0 then self._size = 8 end
        self._size += 38
        
        module.Frame.Size = UDim2.new(1, 0, 0, 52 + self._size)
        module.Options.Size = UDim2.new(1, 0, 0, self._size)
        
        local sliderFrame = Create("Frame", {
            Name = "Slider",
            Parent = module.Options,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, 34)
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = sliderFrame })
        
        Create("TextLabel", {
            Name = "Title",
            Parent = sliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 4),
            Size = UDim2.new(1, -60, 0, 14),
            FontFace = Library.Font,
            Text = sliderSettings.title or "Slider",
            TextColor3 = Colors.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local valueLabel = Create("TextLabel", {
            Name = "Value",
            Parent = sliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -10, 0, 4),
            Size = UDim2.new(0, 45, 0, 14),
            AnchorPoint = Vector2.new(1, 0),
            FontFace = Library.FontBold,
            Text = tostring(sliderSettings.default or sliderSettings.min),
            TextColor3 = Colors.Accent,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        
        local track = Create("Frame", {
            Name = "Track",
            Parent = sliderFrame,
            BackgroundColor3 = Colors.Border,
            Position = UDim2.new(0, 10, 0, 22),
            Size = UDim2.new(1, -20, 0, 6),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
        
        local fill = Create("Frame", {
            Name = "Fill",
            Parent = track,
            BackgroundColor3 = Colors.Accent,
            Size = UDim2.new(0.5, 0, 1, 0),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
        
        local knob = Create("Frame", {
            Name = "Knob",
            Parent = fill,
            BackgroundColor3 = Colors.Card,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
        Create("UIStroke", { Color = Colors.Accent, Thickness = 2, Parent = knob })
        
        local min = sliderSettings.min or 0
        local max = sliderSettings.max or 100
        slider.Value = sliderSettings.default or min
        
        function slider:SetValue(value)
            value = math.clamp(value, min, max)
            local rounded = sliderSettings.round and math.floor(value) or math.floor(value * 10) / 10
            local percentage = (rounded - min) / (max - min)
            
            self.Value = rounded
            valueLabel.Text = tostring(rounded)
            Tween(fill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
            
            if sliderSettings.callback then
                sliderSettings.callback(rounded)
            end
        end
        
        local mouse = Players.LocalPlayer:GetMouse()
        local dragging = false
        
        local function update()
            local pos = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * pos
            slider:SetValue(value)
        end
        
        local sliderBtn = Create("TextButton", {
            Parent = sliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 18),
            Size = UDim2.new(1, 0, 0, 16),
            Text = ""
        })
        
        sliderBtn.MouseButton1Down:Connect(function()
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
        
        slider:SetValue(slider.Value)
        
        return slider
    end


    -- Создание Dropdown
    function module:CreateDropdown(dropSettings)
        local dropdown = { _state = false, _size = 0 }
        
        if self._size == 0 then self._size = 8 end
        self._size += 42
        
        module.Frame.Size = UDim2.new(1, 0, 0, 52 + self._size)
        module.Options.Size = UDim2.new(1, 0, 0, self._size)
        
        local dropFrame = Create("Frame", {
            Name = "Dropdown",
            Parent = module.Options,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, 38),
            ClipsDescendants = true
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropFrame })
        
        Create("TextLabel", {
            Name = "Title",
            Parent = dropFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 4),
            Size = UDim2.new(1, -20, 0, 14),
            FontFace = Library.Font,
            Text = dropSettings.title or "Dropdown",
            TextColor3 = Colors.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local selectBox = Create("Frame", {
            Name = "SelectBox",
            Parent = dropFrame,
            BackgroundColor3 = Colors.Card,
            Position = UDim2.new(0, 10, 0, 20),
            Size = UDim2.new(1, -20, 0, 24),
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = selectBox })
        Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = selectBox })
        
        local currentOption = Create("TextLabel", {
            Name = "CurrentOption",
            Parent = selectBox,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(1, -35, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Library.Font,
            Text = dropSettings.options[1] or "Select",
            TextColor3 = Colors.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local arrow = Create("ImageLabel", {
            Name = "Arrow",
            Parent = selectBox,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = "rbxassetid://6031091004",
            ImageColor3 = Colors.TextDim,
            Rotation = 0
        })
        
        local optionsList = Create("Frame", {
            Name = "Options",
            Parent = dropFrame,
            BackgroundColor3 = Colors.Card,
            Position = UDim2.new(0, 10, 0, 48),
            Size = UDim2.new(1, -20, 0, 0),
            ClipsDescendants = true,
            BorderSizePixel = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = optionsList })
        Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = optionsList })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = optionsList })
        
        dropdown.Value = dropSettings.options[1]
        
        -- Создаем опции
        local maxOptions = dropSettings.maxOptions or 4
        for i, opt in ipairs(dropSettings.options) do
            local optBtn = Create("TextButton", {
                Name = "Option",
                Parent = optionsList,
                BackgroundColor3 = Colors.Card,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                FontFace = Library.Font,
                Text = "  " .. opt,
                TextColor3 = (opt == dropdown.Value) and Colors.Accent or Colors.Text,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })
            
            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, {BackgroundTransparency = 0, BackgroundColor3 = Colors.Secondary})
            end)
            
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, {BackgroundTransparency = 1})
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                dropdown.Value = opt
                currentOption.Text = opt
                
                for _, o in optionsList:GetChildren() do
                    if o:IsA("TextButton") then
                        o.TextColor3 = (o.Text == "  " .. opt) and Colors.Accent or Colors.Text
                    end
                end
                
                if dropSettings.callback then
                    dropSettings.callback(opt)
                end
            end)
            
            if i <= maxOptions then
                dropdown._size += 26
            end
        end
        
        function dropdown:Unfold()
            self._state = not self._state
            if self._state then
                module._multiplier += self._size
                Tween(module.Frame, {Size = UDim2.new(1, 0, 0, 52 + module._size + module._multiplier)}, 0.3)
                Tween(module.Options, {Size = UDim2.new(1, 0, 0, module._size + module._multiplier)}, 0.3)
                Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 38 + self._size + 8)}, 0.3)
                Tween(optionsList, {Size = UDim2.new(1, -20, 0, self._size)}, 0.3)
                Tween(arrow, {Rotation = 180}, 0.3)
            else
                module._multiplier -= self._size
                Tween(module.Frame, {Size = UDim2.new(1, 0, 0, 52 + module._size + module._multiplier)}, 0.3)
                Tween(module.Options, {Size = UDim2.new(1, 0, 0, module._size + module._multiplier)}, 0.3)
                Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 38)}, 0.3)
                Tween(optionsList, {Size = UDim2.new(1, -20, 0, 0)}, 0.3)
                Tween(arrow, {Rotation = 0}, 0.3)
            end
        end
        
        local selectBtn = Create("TextButton", {
            Parent = selectBox,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = ""
        })
        selectBtn.MouseButton1Click:Connect(function()
            dropdown:Unfold()
        end)
        
        return dropdown
    end
    
    -- Создание TextBox
    function module:CreateTextBox(textSettings)
        local textbox = { Value = "" }
        
        if self._size == 0 then self._size = 8 end
        self._size += 28
        
        module.Frame.Size = UDim2.new(1, 0, 0, 52 + self._size)
        module.Options.Size = UDim2.new(1, 0, 0, self._size)
        
        local textFrame = Create("Frame", {
            Name = "TextBox",
            Parent = module.Options,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, 24)
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = textFrame })
        
        Create("TextLabel", {
            Name = "Title",
            Parent = textFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0.4, 0, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Library.Font,
            Text = textSettings.title or "Input",
            TextColor3 = Colors.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local input = Create("TextBox", {
            Name = "Input",
            Parent = textFrame,
            BackgroundColor3 = Colors.Card,
            Position = UDim2.new(0.4, 5, 0.5, 0),
            Size = UDim2.new(0.6, -15, 0, 18),
            AnchorPoint = Vector2.new(0, 0.5),
            FontFace = Library.Font,
            PlaceholderText = textSettings.placeholder or "Enter...",
            Text = "",
            TextColor3 = Colors.Text,
            PlaceholderColor3 = Colors.TextDim,
            TextSize = 10,
            ClearTextOnFocus = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = input })
        Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = input })
        
        input.Focused:Connect(function()
            Tween(input.UIStroke, {Color = Colors.Accent})
        end)
        
        input.FocusLost:Connect(function()
            Tween(input.UIStroke, {Color = Colors.Border})
            textbox.Value = input.Text
            if textSettings.callback then
                textSettings.callback(textbox.Value)
            end
        end)
        
        return textbox
    end
    
    -- Создание Button
    function module:CreateButton(btnSettings)
        if self._size == 0 then self._size = 8 end
        self._size += 30
        
        module.Frame.Size = UDim2.new(1, 0, 0, 52 + self._size)
        module.Options.Size = UDim2.new(1, 0, 0, self._size)
        
        local btn = Create("TextButton", {
            Name = "Button",
            Parent = module.Options,
            BackgroundColor3 = Colors.Accent,
            Size = UDim2.new(1, 0, 0, 26),
            FontFace = Library.FontBold,
            Text = btnSettings.title or "Button",
            TextColor3 = Colors.TextLight,
            TextSize = 11,
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.AccentLight})
        end)
        
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.Accent})
        end)
        
        btn.MouseButton1Click:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.AccentDark}, 0.1)
            task.wait(0.1)
            Tween(btn, {BackgroundColor3 = Colors.Accent}, 0.1)
            
            if btnSettings.callback then
                btnSettings.callback()
            end
        end)
        
        return btn
    end
    
    return module
end


-- Создание простой секции
function Library:CreateSection(tab, name, column)
    local section = {}
    local parent = (column == "right") and tab.RightSection or tab.LeftSection
    
    section.Frame = Create("Frame", {
        Name = name,
        Parent = parent,
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = section.Frame })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Transparency = 0.5, Parent = section.Frame })
    
    -- Заголовок секции
    Create("TextLabel", {
        Name = "Title",
        Parent = section.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -28, 0, 18),
        FontFace = Library.FontBold,
        Text = name,
        TextColor3 = Colors.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Контейнер элементов
    section.Container = Create("Frame", {
        Name = "Container",
        Parent = section.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    Create("UIListLayout", {
        Parent = section.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    Create("UIPadding", {
        Parent = section.Container,
        PaddingTop = UDim.new(0, 0),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14)
    })
    
    return section
end

-- Создание Toggle (простой)
function Library:CreateToggle(section, name, default, callback)
    local toggle = { Value = default or false }
    
    toggle.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 28)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toggle.Frame })
    
    toggle.Label = Create("TextLabel", {
        Name = "Label",
        Parent = toggle.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(1, -60, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    toggle.Switch = Create("Frame", {
        Name = "Switch",
        Parent = toggle.Frame,
        BackgroundColor3 = toggle.Value and Colors.Accent or Colors.Border,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggle.Switch })
    
    toggle.Circle = Create("Frame", {
        Name = "Circle",
        Parent = toggle.Switch,
        BackgroundColor3 = Colors.Card,
        Position = toggle.Value and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggle.Circle })
    
    local function toggleFunc()
        toggle.Value = not toggle.Value
        Tween(toggle.Switch, {BackgroundColor3 = toggle.Value and Colors.Accent or Colors.Border})
        Tween(toggle.Circle, {Position = toggle.Value and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
        if callback then callback(toggle.Value) end
    end
    
    local switchBtn = Create("TextButton", {
        Parent = toggle.Switch,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    switchBtn.MouseButton1Click:Connect(toggleFunc)
    
    toggle.Frame.MouseEnter:Connect(function()
        Tween(toggle.Frame, {BackgroundTransparency = 0})
    end)
    toggle.Frame.MouseLeave:Connect(function()
        Tween(toggle.Frame, {BackgroundTransparency = 0.5})
    end)
    
    if default and callback then callback(true) end
    
    return toggle
end

-- Создание Button (простой)
function Library:CreateButton(section, name, callback)
    local button = {}
    
    button.Button = Create("TextButton", {
        Name = name,
        Parent = section.Container,
        BackgroundColor3 = Colors.Accent,
        Size = UDim2.new(1, 0, 0, 30),
        FontFace = Library.FontBold,
        Text = name,
        TextColor3 = Colors.TextLight,
        TextSize = 11,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = button.Button })
    
    button.Button.MouseEnter:Connect(function()
        Tween(button.Button, {BackgroundColor3 = Colors.AccentLight})
    end)
    
    button.Button.MouseLeave:Connect(function()
        Tween(button.Button, {BackgroundColor3 = Colors.Accent})
    end)
    
    button.Button.MouseButton1Click:Connect(function()
        Tween(button.Button, {BackgroundColor3 = Colors.Success}, 0.1)
        task.wait(0.15)
        Tween(button.Button, {BackgroundColor3 = Colors.Accent}, 0.1)
        if callback then callback() end
    end)
    
    return button
end

-- Создание Slider (простой)
function Library:CreateSlider(section, name, min, max, default, callback)
    local slider = { Value = default or min }
    
    slider.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 40)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = slider.Frame })
    
    slider.Label = Create("TextLabel", {
        Name = "Label",
        Parent = slider.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 4),
        Size = UDim2.new(1, -60, 0, 14),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    slider.ValueLabel = Create("TextLabel", {
        Name = "Value",
        Parent = slider.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0, 4),
        Size = UDim2.new(0, 45, 0, 14),
        AnchorPoint = Vector2.new(1, 0),
        FontFace = Library.FontBold,
        Text = tostring(slider.Value),
        TextColor3 = Colors.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    slider.Track = Create("Frame", {
        Name = "Track",
        Parent = slider.Frame,
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(0, 10, 0, 24),
        Size = UDim2.new(1, -20, 0, 6),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slider.Track })
    
    slider.Fill = Create("Frame", {
        Name = "Fill",
        Parent = slider.Track,
        BackgroundColor3 = Colors.Accent,
        Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slider.Fill })
    
    local dragging = false
    local mouse = Players.LocalPlayer:GetMouse()
    
    local function update(input)
        local pos = math.clamp((input.Position.X - slider.Track.AbsolutePosition.X) / slider.Track.AbsoluteSize.X, 0, 1)
        slider.Value = math.floor(min + (max - min) * pos)
        slider.ValueLabel.Text = tostring(slider.Value)
        Tween(slider.Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
        if callback then callback(slider.Value) end
    end
    
    slider.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    slider.Track.InputEnded:Connect(function(input)
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
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 28),
        ClipsDescendants = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropdown.Frame })
    
    dropdown.Label = Create("TextLabel", {
        Name = "Label",
        Parent = dropdown.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0.4, 0, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    dropdown.Button = Create("TextButton", {
        Name = "Button",
        Parent = dropdown.Frame,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0.4, 5, 0.5, 0),
        Size = UDim2.new(0.6, -15, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = "  " .. dropdown.Value,
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = dropdown.Button })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = dropdown.Button })
    
    dropdown.OptionsList = Create("Frame", {
        Name = "Options",
        Parent = dropdown.Button,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 10,
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = dropdown.OptionsList })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = dropdown.OptionsList })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropdown.OptionsList })
    
    for _, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Name = opt,
            Parent = dropdown.OptionsList,
            BackgroundColor3 = Colors.Card,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            FontFace = Library.Font,
            Text = "  " .. opt,
            TextColor3 = Colors.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            AutoButtonColor = false
        })
        
        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 0, BackgroundColor3 = Colors.AccentLight})
            optBtn.TextColor3 = Colors.TextLight
        end)
        
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 1})
            optBtn.TextColor3 = Colors.Text
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            dropdown.Value = opt
            dropdown.Button.Text = "  " .. opt
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
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, math.min(#options * 24, 120))})
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
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 28),
        ClipsDescendants = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropdown.Frame })
    
    dropdown.Label = Create("TextLabel", {
        Name = "Label",
        Parent = dropdown.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0.35, 0, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    dropdown.Button = Create("TextButton", {
        Name = "Button",
        Parent = dropdown.Frame,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0.35, 5, 0.5, 0),
        Size = UDim2.new(0.65, -15, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = #dropdown.Selected > 0 and ("  " .. table.concat(dropdown.Selected, ", ")) or "  Select...",
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = dropdown.Button })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = dropdown.Button })
    
    dropdown.OptionsList = Create("Frame", {
        Name = "Options",
        Parent = dropdown.Button,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 10,
        ClipsDescendants = true
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = dropdown.OptionsList })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = dropdown.OptionsList })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropdown.OptionsList })
    
    for _, opt in ipairs(options) do
        local optFrame = Create("Frame", {
            Name = opt,
            Parent = dropdown.OptionsList,
            BackgroundColor3 = Colors.Card,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 11
        })
        
        local checkBox = Create("Frame", {
            Name = "Check",
            Parent = optFrame,
            BackgroundColor3 = table.find(dropdown.Selected, opt) and Colors.Accent or Colors.Border,
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 12
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = checkBox })
        
        Create("TextLabel", {
            Name = "Label",
            Parent = optFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0, 0),
            Size = UDim2.new(1, -33, 1, 0),
            FontFace = Library.Font,
            Text = opt,
            TextColor3 = Colors.Text,
            TextSize = 10,
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
            Tween(optFrame, {BackgroundTransparency = 0, BackgroundColor3 = Colors.Secondary})
        end)
        
        optBtn.MouseLeave:Connect(function()
            Tween(optFrame, {BackgroundTransparency = 1})
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            local index = table.find(dropdown.Selected, opt)
            if index then
                table.remove(dropdown.Selected, index)
                Tween(checkBox, {BackgroundColor3 = Colors.Border})
            else
                table.insert(dropdown.Selected, opt)
                Tween(checkBox, {BackgroundColor3 = Colors.Accent})
            end
            
            dropdown.Button.Text = #dropdown.Selected > 0 and ("  " .. table.concat(dropdown.Selected, ", ")) or "  Select..."
            if callback then callback(dropdown.Selected) end
        end)
    end
    
    dropdown.Button.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        dropdown.OptionsList.Visible = true
        
        if dropdown.Open then
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, math.min(#options * 26, 130))})
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
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 28)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = textbox.Frame })
    
    textbox.Label = Create("TextLabel", {
        Name = "Label",
        Parent = textbox.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0.35, 0, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    textbox.Input = Create("TextBox", {
        Name = "Input",
        Parent = textbox.Frame,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(0.35, 5, 0.5, 0),
        Size = UDim2.new(0.65, -15, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        PlaceholderText = placeholder or "Enter...",
        Text = "",
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextDim,
        TextSize = 10
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = textbox.Input })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = textbox.Input })
    
    textbox.Input.Focused:Connect(function()
        Tween(textbox.Input.UIStroke, {Color = Colors.Accent})
    end)
    
    textbox.Input.FocusLost:Connect(function(enterPressed)
        Tween(textbox.Input.UIStroke, {Color = Colors.Border})
        textbox.Value = textbox.Input.Text
        if callback then callback(textbox.Value, enterPressed) end
    end)
    
    return textbox
end


-- Счётчик уведомлений
Library._notifCount = 0

-- Уведомления
function Library:Notify(title, text, duration, notifType)
    Library._notifCount = Library._notifCount + 1
    local notifIndex = Library._notifCount
    local yOffset = 20 + (80 * (notifIndex - 1))
    
    local accentColor = Colors.Accent
    if notifType == "success" then
        accentColor = Colors.Success
    elseif notifType == "error" then
        accentColor = Colors.Error
    elseif notifType == "warning" then
        accentColor = Colors.Warning
    end
    
    local notif = Create("Frame", {
        Name = "Notification",
        Parent = self.ScreenGui,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(1, 20, 0, yOffset),
        Size = UDim2.new(0, 280, 0, 70),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notif })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = notif })
    
    -- Тень
    Create("ImageLabel", {
        Name = "Shadow",
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 20, 1, 20),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.9,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1
    })
    
    -- Цветная полоска
    Create("Frame", {
        Name = "AccentBar",
        Parent = notif,
        BackgroundColor3 = accentColor,
        Position = UDim2.new(0, 0, 0.15, 0),
        Size = UDim2.new(0, 4, 0.7, 0),
        BorderSizePixel = 0
    }):FindFirstChildOfClass("UICorner") or Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = notif.AccentBar })
    
    Create("TextLabel", {
        Name = "Title",
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -32, 0, 18),
        FontFace = Library.FontBold,
        Text = title or "Notification",
        TextColor3 = Colors.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("TextLabel", {
        Name = "Text",
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 32),
        Size = UDim2.new(1, -32, 0, 30),
        FontFace = Library.Font,
        Text = text or "",
        TextColor3 = Colors.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true
    })
    
    -- Прогресс бар
    local progressBg = Create("Frame", {
        Name = "ProgressBg",
        Parent = notif,
        BackgroundColor3 = Colors.Border,
        Position = UDim2.new(0, 16, 1, -8),
        Size = UDim2.new(1, -32, 0, 3),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressBg })
    
    local progressFill = Create("Frame", {
        Name = "Fill",
        Parent = progressBg,
        BackgroundColor3 = accentColor,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressFill })
    
    -- Анимация появления
    Tween(notif, {Position = UDim2.new(1, -300, 0, yOffset)}, 0.4)
    
    -- Анимация прогресса и исчезновения
    task.spawn(function()
        local dur = duration or 4
        Tween(progressFill, {Size = UDim2.new(0, 0, 1, 0)}, dur, Enum.EasingStyle.Linear)
        task.wait(dur)
        
        Tween(notif, {Position = UDim2.new(1, 20, 0, yOffset)}, 0.3)
        task.wait(0.35)
        notif:Destroy()
        Library._notifCount = Library._notifCount - 1
        
        -- Сдвигаем остальные уведомления
        for _, child in self.ScreenGui:GetChildren() do
            if child.Name == "Notification" then
                local currentY = child.Position.Y.Offset
                if currentY > yOffset then
                    Tween(child, {Position = UDim2.new(1, -300, 0, currentY - 80)}, 0.3)
                end
            end
        end
    end)
    
    return notif
end

-- Создание Label (информационный текст)
function Library:CreateLabel(section, text)
    local label = {}
    
    label.Label = Create("TextLabel", {
        Name = "Label",
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        FontFace = Library.Font,
        Text = text,
        TextColor3 = Colors.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    function label:SetText(newText)
        label.Label.Text = newText
    end
    
    return label
end

-- Создание Divider (разделитель)
function Library:CreateDivider(section)
    local divider = Create("Frame", {
        Name = "Divider",
        Parent = section.Container,
        BackgroundColor3 = Colors.Border,
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0
    })
    
    return divider
end

-- Создание Keybind
function Library:CreateKeybind(section, name, default, callback)
    local keybind = { Key = default, _waiting = false }
    
    keybind.Frame = Create("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 28)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = keybind.Frame })
    
    keybind.Label = Create("TextLabel", {
        Name = "Label",
        Parent = keybind.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(1, -80, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        FontFace = Library.Font,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    keybind.Button = Create("TextButton", {
        Name = "KeybindBtn",
        Parent = keybind.Frame,
        BackgroundColor3 = Colors.Card,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        FontFace = Library.FontBold,
        Text = default and default.Name or "None",
        TextColor3 = Colors.Accent,
        TextSize = 10,
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = keybind.Button })
    Create("UIStroke", { Color = Colors.Border, Thickness = 1, Parent = keybind.Button })
    
    keybind.Button.MouseButton1Click:Connect(function()
        if keybind._waiting then return end
        keybind._waiting = true
        keybind.Button.Text = "..."
        Tween(keybind.Button.UIStroke, {Color = Colors.Accent})
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    keybind.Key = nil
                    keybind.Button.Text = "None"
                else
                    keybind.Key = input.KeyCode
                    keybind.Button.Text = input.KeyCode.Name
                end
                keybind._waiting = false
                Tween(keybind.Button.UIStroke, {Color = Colors.Border})
                conn:Disconnect()
            end
        end)
    end)
    
    -- Активация по клавише
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or keybind._waiting then return end
        if keybind.Key and input.KeyCode == keybind.Key then
            if callback then callback() end
        end
    end)
    
    return keybind
end

return Library
