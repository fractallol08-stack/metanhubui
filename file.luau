--[[
    Simple UI Library
    Простая UI библиотека для Roblox эксплойтов
    Морская тема с прозрачностью
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}
Library.__index = Library
Library.ToggleKey = Enum.KeyCode.RightControl -- Клавиша для скрытия/показа UI

-- Доступные шрифты
Library.Fonts = {
    Default = Enum.Font.Gotham,
    Bold = Enum.Font.GothamBold,
    Light = Enum.Font.GothamLight,           -- Легкий
    Medium = Enum.Font.GothamMedium,         -- Средний
    Black = Enum.Font.GothamBlack,           -- Жирный
    Roboto = Enum.Font.Roboto,               -- Roboto
    RobotoBold = Enum.Font.RobotoMono,       -- Roboto Mono
    SourceSans = Enum.Font.SourceSans,       -- Source Sans
    SourceSansBold = Enum.Font.SourceSansBold,
    Ubuntu = Enum.Font.Ubuntu,               -- Ubuntu
    Nunito = Enum.Font.Nunito,               -- Nunito
    FredokaOne = Enum.Font.FredokaOne,       -- FredokaOne (мультяшный)
    Bangers = Enum.Font.Bangers,             -- Bangers (комикс)
    Oswald = Enum.Font.Oswald,               -- Oswald
    Michroma = Enum.Font.Michroma,           -- Michroma (футуристичный)
    BuilderSans = Enum.Font.BuilderSans,     -- Builder Sans
}

-- Текущий шрифт (можно менять)
Library.CurrentFont = Enum.Font.GothamMedium
Library.CurrentFontBold = Enum.Font.GothamBold

-- Морские цвета (бело-голубые светящиеся)
local Colors = {
    Background = Color3.fromRGB(15, 25, 45),      -- Темно-синий
    Secondary = Color3.fromRGB(25, 40, 70),       -- Синий
    Accent = Color3.fromRGB(100, 200, 255),       -- Голубой светящийся
    AccentGlow = Color3.fromRGB(150, 220, 255),   -- Светло-голубой
    Text = Color3.fromRGB(255, 255, 255),         -- Белый
    TextDark = Color3.fromRGB(180, 200, 220),     -- Светло-серый с голубым
    Success = Color3.fromRGB(100, 255, 200),      -- Бирюзовый
    Error = Color3.fromRGB(255, 120, 150),        -- Розовый
    Glow = Color3.fromRGB(80, 180, 255)           -- Свечение
}

-- Прозрачность (увеличена для фонов)
local Transparency = {
    Background = 0.35,      -- Главный фон (более прозрачный)
    Secondary = 0.45,       -- Вторичный фон (более прозрачный)
    TitleBar = 0.3,         -- Заголовок
    TabContainer = 0.4,     -- Контейнер табов
    Section = 0.5,          -- Секции
    Elements = 0.1          -- Элементы (кнопки, toggle) - менее прозрачные
}

-- Функция установки шрифта
function Library:SetFont(fontName)
    if Library.Fonts[fontName] then
        Library.CurrentFont = Library.Fonts[fontName]
        if fontName == "Roboto" then
            Library.CurrentFontBold = Enum.Font.RobotoMono
        elseif fontName == "SourceSans" then
            Library.CurrentFontBold = Enum.Font.SourceSansBold
        elseif fontName == "Default" or fontName == "Light" or fontName == "Medium" then
            Library.CurrentFontBold = Enum.Font.GothamBold
        else
            Library.CurrentFontBold = Library.Fonts[fontName]
        end
    end
end

-- Утилиты
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.2), properties)
    tween:Play()
    return tween
end

-- Создание библиотеки
function Library.new(title)
    local self = setmetatable({}, Library)
    
    -- Удаляем старый UI если есть
    if CoreGui:FindFirstChild("SimpleUI") then
        CoreGui:FindFirstChild("SimpleUI"):Destroy()
    end
    
    -- ScreenGui
    self.ScreenGui = CreateInstance("ScreenGui", {
        Name = "SimpleUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Главное окно
    self.MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = Transparency.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true
    })

    -- Скругление
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = self.MainFrame
    })
    
    -- Свечение (UIStroke с голубым цветом)
    CreateInstance("UIStroke", {
        Color = Colors.Glow,
        Thickness = 1.5,
        Transparency = 0.3,
        Parent = self.MainFrame
    })
    
    self.Visible = true
    
    -- Заголовок
    self.TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = Transparency.TitleBar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.TitleBar
    })
    
    -- Название
    self.TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Library.CurrentFontBold,
        Text = title or "Simple UI",
        TextColor3 = Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Кнопка закрытия
    local CloseBtn = CreateInstance("TextButton", {
        Name = "Close",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Library.CurrentFontBold,
        Text = "X",
        TextColor3 = Colors.Error,
        TextSize = 16
    })
    
    CloseBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)

    -- Контейнер для табов
    self.TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Parent = self.MainFrame,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = Transparency.TabContainer,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 120, 1, -35)
    })
    
    CreateInstance("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    CreateInstance("UIPadding", {
        Parent = self.TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })
    
    -- Контейнер для контента
    self.ContentContainer = CreateInstance("Frame", {
        Name = "ContentContainer",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 125, 0, 40),
        Size = UDim2.new(1, -130, 1, -45)
    })
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Drag функционал
    local dragging, dragInput, dragStart, startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Toggle UI visibility (ClickGUI)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Library.ToggleKey then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
        end
    end)
    
    return self
end

-- Установка клавиши для скрытия UI
function Library:SetToggleKey(key)
    Library.ToggleKey = key
end


-- Создание таба с двумя колонками
function Library:CreateTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}
    
    -- Кнопка таба
    tab.Button = CreateInstance("TextButton", {
        Name = name,
        Parent = self.TabContainer,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = Transparency.Section,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Font = Library.CurrentFont,
        Text = name,
        TextColor3 = Colors.TextDark,
        TextSize = 12
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tab.Button
    })
    
    -- Контент таба (контейнер для двух колонок)
    tab.Content = CreateInstance("Frame", {
        Name = name .. "_Content",
        Parent = self.ContentContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    
    -- Левая колонка
    tab.LeftColumn = CreateInstance("ScrollingFrame", {
        Name = "LeftColumn",
        Parent = tab.Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.5, -5, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    CreateInstance("UIListLayout", {
        Parent = tab.LeftColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    CreateInstance("UIPadding", {
        Parent = tab.LeftColumn,
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })
    
    -- Правая колонка
    tab.RightColumn = CreateInstance("ScrollingFrame", {
        Name = "RightColumn",
        Parent = tab.Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 5, 0, 0),
        Size = UDim2.new(0.5, -5, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    CreateInstance("UIListLayout", {
        Parent = tab.RightColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    CreateInstance("UIPadding", {
        Parent = tab.RightColumn,
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })
    
    -- Клик по табу
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Выбираем первый таб
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

-- Выбор таба
function Library:SelectTab(tab)
    for _, t in pairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundColor3 = Colors.Background
        t.Button.TextColor3 = Colors.TextDark
    end
    
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = Colors.Accent
    tab.Button.TextColor3 = Colors.Text
    self.CurrentTab = tab
end


-- Создание секции (column = "left" или "right")
function Library:CreateSection(tab, name, column)
    local section = {}
    section.Name = name
    
    local parent = (column == "right") and tab.RightColumn or tab.LeftColumn
    
    section.Frame = CreateInstance("Frame", {
        Name = name,
        Parent = parent,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = Transparency.Section,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = section.Frame
    })
    
    -- Заголовок секции
    CreateInstance("TextLabel", {
        Name = "Title",
        Parent = section.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Library.CurrentFontBold,
        Text = name,
        TextColor3 = Colors.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Контейнер для элементов
    section.Container = CreateInstance("Frame", {
        Name = "Container",
        Parent = section.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    CreateInstance("UIListLayout", {
        Parent = section.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    CreateInstance("UIPadding", {
        Parent = section.Container,
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    return section
end


-- Создание Toggle (переключатель) с keybind
function Library:CreateToggle(section, name, default, callback, keybind)
    local toggle = {}
    toggle.Value = default or false
    toggle.Keybind = keybind
    toggle.WaitingForKeybind = false
    toggle.KeybindConnection = nil
    
    toggle.Frame = CreateInstance("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25)
    })
    
    local labelText = keybind and (name .. " [" .. keybind.Name .. "]") or name
    
    toggle.Label = CreateInstance("TextLabel", {
        Name = "Label",
        Parent = toggle.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -90, 1, 0),
        Font = Library.CurrentFont,
        Text = labelText,
        TextColor3 = Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Кнопка для установки keybind
    toggle.KeybindBtn = CreateInstance("TextButton", {
        Name = "KeybindBtn",
        Parent = toggle.Frame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -45, 0.5, 0),
        Size = UDim2.new(0, 35, 0, 18),
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Font = Library.CurrentFont,
        Text = keybind and keybind.Name or "...",
        TextColor3 = Colors.Accent,
        TextSize = 9
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = toggle.KeybindBtn
    })
    
    toggle.Button = CreateInstance("TextButton", {
        Name = "Toggle",
        Parent = toggle.Frame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20),
        BackgroundColor3 = toggle.Value and Colors.Accent or Colors.Background,
        BackgroundTransparency = Transparency.Elements,
        BorderSizePixel = 0,
        Text = ""
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggle.Button
    })
    
    CreateInstance("UIStroke", {
        Color = Colors.Glow,
        Thickness = 1,
        Transparency = 0.5,
        Parent = toggle.Button
    })
    
    toggle.Circle = CreateInstance("Frame", {
        Name = "Circle",
        Parent = toggle.Button,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = toggle.Value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggle.Circle
    })
    
    local function toggleFunc()
        toggle.Value = not toggle.Value
        Tween(toggle.Button, {BackgroundColor3 = toggle.Value and Colors.Accent or Colors.Background})
        Tween(toggle.Circle, {Position = toggle.Value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
        if callback then
            callback(toggle.Value)
        end
    end
    
    toggle.Button.MouseButton1Click:Connect(toggleFunc)
    
    -- Клик по кнопке keybind - ждем нажатия клавиши
    toggle.KeybindBtn.MouseButton1Click:Connect(function()
        if toggle.WaitingForKeybind then return end
        toggle.WaitingForKeybind = true
        toggle.KeybindBtn.Text = "..."
        Tween(toggle.KeybindBtn, {BackgroundColor3 = Colors.Accent})
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                -- Отмена по Escape
                if input.KeyCode == Enum.KeyCode.Escape then
                    toggle.Keybind = nil
                    toggle.KeybindBtn.Text = "..."
                    toggle.Label.Text = name
                else
                    toggle.Keybind = input.KeyCode
                    toggle.KeybindBtn.Text = input.KeyCode.Name
                    toggle.Label.Text = name .. " [" .. input.KeyCode.Name .. "]"
                end
                
                toggle.WaitingForKeybind = false
                Tween(toggle.KeybindBtn, {BackgroundColor3 = Colors.Background})
                connection:Disconnect()
            end
        end)
    end)
    
    -- Keybind support (активация по клавише)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if toggle.WaitingForKeybind then return end
        if toggle.Keybind and input.KeyCode == toggle.Keybind then
            toggleFunc()
        end
    end)
    
    -- Функция для установки keybind программно
    function toggle:SetKeybind(key)
        toggle.Keybind = key
        if key then
            toggle.KeybindBtn.Text = key.Name
            toggle.Label.Text = name .. " [" .. key.Name .. "]"
        else
            toggle.KeybindBtn.Text = "..."
            toggle.Label.Text = name
        end
    end
    
    -- Функция для удаления keybind
    function toggle:ClearKeybind()
        toggle.Keybind = nil
        toggle.KeybindBtn.Text = "..."
        toggle.Label.Text = name
    end
    
    return toggle
end


-- Создание Button (кнопка) с keybind (можно ставить самому)
function Library:CreateButton(section, name, callback, keybind)
    local button = {}
    button.Keybind = keybind
    button.WaitingForKeybind = false
    
    button.Frame = CreateInstance("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    button.Button = CreateInstance("TextButton", {
        Name = "Button",
        Parent = button.Frame,
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -45, 1, 0),
        Font = Library.CurrentFontBold,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 12
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button.Button
    })
    
    -- Кнопка для установки keybind
    button.KeybindBtn = CreateInstance("TextButton", {
        Name = "KeybindBtn",
        Parent = button.Frame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 24),
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Font = Library.CurrentFont,
        Text = keybind and keybind.Name or "...",
        TextColor3 = Colors.Accent,
        TextSize = 10
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = button.KeybindBtn
    })
    
    local function clickFunc()
        -- Анимация нажатия
        Tween(button.Button, {BackgroundColor3 = Colors.Success}, 0.1)
        task.wait(0.1)
        Tween(button.Button, {BackgroundColor3 = Colors.Accent}, 0.1)
        
        if callback then
            callback()
        end
    end
    
    button.Button.MouseButton1Click:Connect(clickFunc)
    
    -- Клик по кнопке keybind - ждем нажатия клавиши
    button.KeybindBtn.MouseButton1Click:Connect(function()
        if button.WaitingForKeybind then return end
        button.WaitingForKeybind = true
        button.KeybindBtn.Text = "..."
        Tween(button.KeybindBtn, {BackgroundColor3 = Colors.Accent})
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                -- Отмена по Escape
                if input.KeyCode == Enum.KeyCode.Escape then
                    button.Keybind = nil
                    button.KeybindBtn.Text = "..."
                else
                    button.Keybind = input.KeyCode
                    button.KeybindBtn.Text = input.KeyCode.Name
                end
                
                button.WaitingForKeybind = false
                Tween(button.KeybindBtn, {BackgroundColor3 = Colors.Background})
                connection:Disconnect()
            end
        end)
    end)
    
    -- Keybind support (активация по клавише)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if button.WaitingForKeybind then return end
        if button.Keybind and input.KeyCode == button.Keybind then
            clickFunc()
        end
    end)
    
    -- Функция для установки keybind программно
    function button:SetKeybind(key)
        button.Keybind = key
        if key then
            button.KeybindBtn.Text = key.Name
        else
            button.KeybindBtn.Text = "..."
        end
    end
    
    -- Функция для удаления keybind
    function button:ClearKeybind()
        button.Keybind = nil
        button.KeybindBtn.Text = "..."
    end
    
    return button
end

-- Создание Slider (ползунок)
function Library:CreateSlider(section, name, min, max, default, callback)
    local slider = {}
    slider.Value = default or min
    
    slider.Frame = CreateInstance("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    slider.Label = CreateInstance("TextLabel", {
        Name = "Label",
        Parent = slider.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 15),
        Font = Library.CurrentFont,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    slider.ValueLabel = CreateInstance("TextLabel", {
        Name = "Value",
        Parent = slider.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 50, 0, 15),
        Font = Library.CurrentFontBold,
        Text = tostring(slider.Value),
        TextColor3 = Colors.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    slider.SliderBG = CreateInstance("Frame", {
        Name = "SliderBG",
        Parent = slider.Frame,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 8)
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.SliderBG
    })
    
    slider.SliderFill = CreateInstance("Frame", {
        Name = "Fill",
        Parent = slider.SliderBG,
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0)
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.SliderFill
    })
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - slider.SliderBG.AbsolutePosition.X) / slider.SliderBG.AbsoluteSize.X, 0, 1)
        slider.Value = math.floor(min + (max - min) * pos)
        slider.ValueLabel.Text = tostring(slider.Value)
        Tween(slider.SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
        
        if callback then
            callback(slider.Value)
        end
    end
    
    slider.SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    slider.SliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return slider
end


-- Создание Dropdown (выпадающий список)
function Library:CreateDropdown(section, name, options, default, callback)
    local dropdown = {}
    dropdown.Value = default or options[1]
    dropdown.Open = false
    
    dropdown.Frame = CreateInstance("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        ClipsDescendants = false
    })
    
    dropdown.Label = CreateInstance("TextLabel", {
        Name = "Label",
        Parent = dropdown.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 0, 25),
        Font = Library.CurrentFont,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    dropdown.Button = CreateInstance("TextButton", {
        Name = "Button",
        Parent = dropdown.Frame,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 0, 25),
        Font = Library.CurrentFont,
        Text = dropdown.Value,
        TextColor3 = Colors.Text,
        TextSize = 11
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdown.Button
    })
    
    dropdown.OptionsList = CreateInstance("Frame", {
        Name = "Options",
        Parent = dropdown.Button,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 10,
        ClipsDescendants = true
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdown.OptionsList
    })
    
    CreateInstance("UIListLayout", {
        Parent = dropdown.OptionsList,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- Создаем опции
    for _, option in ipairs(options) do
        local optBtn = CreateInstance("TextButton", {
            Name = option,
            Parent = dropdown.OptionsList,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 22),
            Font = Library.CurrentFont,
            Text = option,
            TextColor3 = Colors.Text,
            TextSize = 11,
            ZIndex = 11
        })
        
        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 0})
        end)
        
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, {BackgroundTransparency = 0.5})
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            dropdown.Value = option
            dropdown.Button.Text = option
            dropdown.Open = false
            dropdown.OptionsList.Visible = false
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, 0)})
            
            if callback then
                callback(option)
            end
        end)
    end
    
    dropdown.Button.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        dropdown.OptionsList.Visible = true
        
        if dropdown.Open then
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, #options * 22)})
        else
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, 0)})
            task.wait(0.2)
            dropdown.OptionsList.Visible = false
        end
    end)
    
    return dropdown
end

-- Создание MultiDropdown (множественный выбор)
function Library:CreateMultiDropdown(section, name, options, default, callback)
    local dropdown = {}
    dropdown.Selected = default or {}
    dropdown.Open = false
    
    dropdown.Frame = CreateInstance("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        ClipsDescendants = false
    })
    
    dropdown.Label = CreateInstance("TextLabel", {
        Name = "Label",
        Parent = dropdown.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 0, 25),
        Font = Library.CurrentFont,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    dropdown.Button = CreateInstance("TextButton", {
        Name = "Button",
        Parent = dropdown.Frame,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0.4, 0, 0, 0),
        Size = UDim2.new(0.6, 0, 0, 25),
        Font = Library.CurrentFont,
        Text = #dropdown.Selected > 0 and table.concat(dropdown.Selected, ", ") or "Select...",
        TextColor3 = Colors.Text,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdown.Button
    })
    
    dropdown.OptionsList = CreateInstance("Frame", {
        Name = "Options",
        Parent = dropdown.Button,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 10,
        ClipsDescendants = true
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdown.OptionsList
    })
    
    CreateInstance("UIListLayout", {
        Parent = dropdown.OptionsList,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Создаем опции с чекбоксами
    for _, option in ipairs(options) do
        local optFrame = CreateInstance("Frame", {
            Name = option,
            Parent = dropdown.OptionsList,
            BackgroundColor3 = Colors.Secondary,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 22),
            ZIndex = 11
        })
        
        local checkBox = CreateInstance("Frame", {
            Name = "Check",
            Parent = optFrame,
            BackgroundColor3 = table.find(dropdown.Selected, option) and Colors.Accent or Colors.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 5, 0.5, -7),
            Size = UDim2.new(0, 14, 0, 14),
            ZIndex = 12
        })
        
        CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = checkBox
        })
        
        local optLabel = CreateInstance("TextLabel", {
            Name = "Label",
            Parent = optFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 25, 0, 0),
            Size = UDim2.new(1, -30, 1, 0),
            Font = Enum.Font.Gotham,
            Text = option,
            TextColor3 = Colors.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 12
        })
        
        local optBtn = CreateInstance("TextButton", {
            Name = "Button",
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
            local index = table.find(dropdown.Selected, option)
            if index then
                table.remove(dropdown.Selected, index)
                Tween(checkBox, {BackgroundColor3 = Colors.Background})
            else
                table.insert(dropdown.Selected, option)
                Tween(checkBox, {BackgroundColor3 = Colors.Accent})
            end
            
            dropdown.Button.Text = #dropdown.Selected > 0 and table.concat(dropdown.Selected, ", ") or "Select..."
            
            if callback then
                callback(dropdown.Selected)
            end
        end)
    end
    
    dropdown.Button.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        dropdown.OptionsList.Visible = true
        
        if dropdown.Open then
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, #options * 22)})
        else
            Tween(dropdown.OptionsList, {Size = UDim2.new(1, 0, 0, 0)})
            task.wait(0.2)
            dropdown.OptionsList.Visible = false
        end
    end)
    
    return dropdown
end

-- Создание TextBox (поле ввода)
function Library:CreateTextBox(section, name, placeholder, callback)
    local textbox = {}
    textbox.Value = ""
    
    textbox.Frame = CreateInstance("Frame", {
        Name = name,
        Parent = section.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25)
    })
    
    textbox.Label = CreateInstance("TextLabel", {
        Name = "Label",
        Parent = textbox.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Library.CurrentFont,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    textbox.Input = CreateInstance("TextBox", {
        Name = "Input",
        Parent = textbox.Frame,
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0.4, 5, 0, 0),
        Size = UDim2.new(0.6, -5, 1, 0),
        Font = Library.CurrentFont,
        PlaceholderText = placeholder or "Enter text...",
        Text = "",
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextDark,
        TextSize = 11
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = textbox.Input
    })
    
    textbox.Input.FocusLost:Connect(function(enterPressed)
        textbox.Value = textbox.Input.Text
        if callback then
            callback(textbox.Value, enterPressed)
        end
    end)
    
    return textbox
end

-- Уведомления
function Library:Notify(title, text, duration)
    local notif = CreateInstance("Frame", {
        Name = "Notification",
        Parent = self.ScreenGui,
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = Transparency.Section,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 10, 1, -80),
        Size = UDim2.new(0, 250, 0, 70)
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notif
    })
    
    CreateInstance("UIStroke", {
        Color = Colors.Glow,
        Thickness = 1,
        Transparency = 0.5,
        Parent = notif
    })
    
    CreateInstance("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Library.CurrentFontBold,
        Text = title,
        TextColor3 = Colors.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    CreateInstance("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 25),
        Size = UDim2.new(1, -20, 0, 40),
        Font = Library.CurrentFont,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    Tween(notif, {Position = UDim2.new(1, -260, 1, -80)})
    
    task.delay(duration or 3, function()
        Tween(notif, {Position = UDim2.new(1, 10, 1, -80)})
        task.wait(0.3)
        notif:Destroy()
    end)
end

return Library
