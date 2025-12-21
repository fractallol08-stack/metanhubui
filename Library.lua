-- March UI Library - Complete Rewrite
-- Modern UI library for Roblox with settings panel system

getgenv().GG = {
    Language = {
        CheckboxEnabled = "Enabled",
        CheckboxDisabled = "Disabled",
        SliderValue = "Value",
        DropdownSelect = "Select",
        DropdownNone = "None",
        DropdownSelected = "Selected",
        ButtonClick = "Click",
        TextboxEnter = "Enter",
        ModuleEnabled = "Enabled",
        ModuleDisabled = "Disabled",
        TabGeneral = "General",
        TabSettings = "Settings",
        Loading = "Loading...",
        Error = "Error",
        Success = "Success"
    }
}

local SelectedLanguage = GG.Language

-- Utility Functions
function convertStringToTable(inputString)
    local result = {}
    if not inputString or inputString == "" then
        return result
    end
    for value in string.gmatch(inputString, "([^,]+)") do
        local trimmedValue = value:match("^%s*(.-)%s*$")
        table.insert(result, trimmedValue)
    end
    return result
end

function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end

-- HSV to RGB conversion
function HSVtoRGB(h, s, v)
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
    
    return Color3.fromRGB(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

-- RGB to HSV conversion
function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    
    local d = max - min
    if max == 0 then s = 0 else s = d / max end
    
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

-- Services
local UserInputService = cloneref(game:GetService('UserInputService'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))

local mouse = Players.LocalPlayer:GetMouse()

-- Clean up old UI
local old_March = CoreGui:FindFirstChild('March')
if old_March then
    Debris:AddItem(old_March, 0)
end

if not isfolder("March") then
    makefolder("March")
end

-- Connections Manager
local Connections = setmetatable({
    disconnect = function(self, connection)
        if not self[connection] then return end
        self[connection]:Disconnect()
        self[connection] = nil
    end,
    disconnect_all = function(self)
        for _, value in self do
            if typeof(value) == 'function' then continue end
            value:Disconnect()
        end
    end
}, Connections)

-- Config Manager
local Config = setmetatable({
    save = function(self, file_name, config)
        local success_save, result = pcall(function()
            local flags = HttpService:JSONEncode(config)
            writefile('March/'..file_name..'.json', flags)
        end)
        if not success_save then
            warn('failed to save config', result)
        end
    end,
    load = function(self, file_name, config)
        local success_load, result = pcall(function()
            if not isfile('March/'..file_name..'.json') then
                self:save(file_name, config)
                return
            end
            local flags = readfile('March/'..file_name..'.json')
            if not flags then
                self:save(file_name, config)
                return
            end
            return HttpService:JSONDecode(flags)
        end)
        if not success_load then
            warn('failed to load config', result)
        end
        if not result then
            result = {
                _flags = {},
                _keybinds = {},
                _library = {}
            }
        end
        return result
    end
}, Config)

-- Library Main Class
local Library = {
    _config = Config:load(game.GameId),
    _choosing_keybind = false,
    _ui_open = true,
    _ui = nil,
    _settings_panel = nil,
    _current_settings_module = nil,
    _current_options_frame = nil,
    _current_options_parent = nil,
    _active_color_picker = nil,
    
    _keybind_abbreviations = {
        ["LeftControl"] = "LCtrl",
        ["RightControl"] = "RCtrl",
        ["LeftShift"] = "LShft",
        ["RightShift"] = "RShft",
        ["LeftAlt"] = "LAlt",
        ["RightAlt"] = "RAlt",
        ["Backquote"] = "`",
        ["Semicolon"] = ";",
        ["Apostrophe"] = "'",
        ["LeftBracket"] = "[",
        ["RightBracket"] = "]",
        ["BackSlash"] = "\\",
        ["Comma"] = ",",
        ["Period"] = ".",
        ["Slash"] = "/",
        ["Minus"] = "-",
        ["Equals"] = "=",
        ["CapsLock"] = "Caps",
        ["Backspace"] = "Back",
        ["Delete"] = "Del",
        ["Insert"] = "Ins",
        ["PageUp"] = "PgUp",
        ["PageDown"] = "PgDn",
        ["NumLock"] = "NLck",
        ["ScrollLock"] = "SLck",
        ["PrintScreen"] = "PrtSc",
    },
    _max_keybind_width = 45
}
Library.__index = Library

-- Truncate keybind text
function Library:truncate_keybind_text(text)
    if not text then return "None" end
    if self._keybind_abbreviations[text] then
        return self._keybind_abbreviations[text]
    end
    if #text > 5 then
        return text:sub(1, 4) .. "."
    end
    return text
end

-- Show settings panel
function Library:show_settings_panel(module_name, options_frame)
    if not self._settings_panel then return end
    
    local panel = self._settings_panel
    local content = panel:FindFirstChild('Content')
    local title = panel.Header:FindFirstChild('Title')
    
    if title then
        title.Text = module_name .. ' Settings'
    end
    
    -- Return previous options to their module
    if self._current_options_frame and self._current_options_parent then
        self._current_options_frame.Parent = self._current_options_parent
        self._current_options_frame.Visible = false
    end
    
    -- Move options to panel
    if options_frame then
        self._current_options_parent = options_frame.Parent
        self._current_options_frame = options_frame
        options_frame.Visible = true
        options_frame.Parent = content
    end
    
    -- Show panel with animation
    panel.Visible = true
    panel.Position = UDim2.new(1, 20, 0, 0)
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, 10, 0, 0)
    }):Play()
    
    self._current_settings_module = module_name
end

-- Hide settings panel
function Library:hide_settings_panel()
    if not self._settings_panel then return end
    
    local panel = self._settings_panel
    
    -- Return options to their module
    if self._current_options_frame and self._current_options_parent then
        self._current_options_frame.Parent = self._current_options_parent
        self._current_options_frame.Visible = false
        self._current_options_frame = nil
        self._current_options_parent = nil
    end
    
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 20, 0, 0)
    }):Play()
    
    task.delay(0.3, function()
        panel.Visible = false
    end)
    
    self._current_settings_module = nil
end

function Library:flag_type(flag, flag_type)
    if not Library._config._flags[flag] then
        return
    end
    return typeof(Library._config._flags[flag]) == flag_type
end

function Library:change_visiblity(state)
    self._ui.Container.Visible = state
end

function Library.new()
    local self = setmetatable({
        _loaded = false,
        _tab = 0,
    }, Library)
    
    self:create_ui()
    return self
end

-- Notification System
function Library.SendNotification(settings)
    -- Create notification (simplified version)
    print("[March Notification]", settings.title, "-", settings.text)
end

function Library:create_ui()
    local March = Instance.new('ScreenGui')
    March.ResetOnSpawn = false
    March.Name = 'March'
    March.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    March.Parent = CoreGui
    
    local Container = Instance.new('Frame')
    Container.ClipsDescendants = true
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = 'Container'
    Container.BackgroundTransparency = 0.05
    Container.BackgroundColor3 = Color3.fromRGB(12, 13, 15)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 698, 0, 479)
    Container.Active = true
    Container.BorderSizePixel = 0
    Container.Parent = March
    
    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Container
    
    local UIStroke = Instance.new('UIStroke')
    UIStroke.Color = Color3.fromRGB(52, 66, 89)
    UIStroke.Transparency = 0.5
    UIStroke.Parent = Container
    
    local Handler = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.Size = UDim2.new(0, 698, 0, 479)
    Handler.Parent = Container
    
    local Tabs = Instance.new('ScrollingFrame')
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.new(0, 129, 0, 401)
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.new(0.026, 0, 0.111, 0)
    Tabs.Parent = Handler
    
    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Tabs
    
    local ClientName = Instance.new('TextLabel')
    ClientName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ClientName.TextColor3 = Color3.fromRGB(152, 181, 255)
    ClientName.TextTransparency = 0.2
    ClientName.Text = 'March'
    ClientName.Name = 'ClientName'
    ClientName.Size = UDim2.new(0, 31, 0, 13)
    ClientName.AnchorPoint = Vector2.new(0, 0.5)
    ClientName.Position = UDim2.new(0.056, 0, 0.055, 0)
    ClientName.BackgroundTransparency = 1
    ClientName.TextXAlignment = Enum.TextXAlignment.Left
    ClientName.TextSize = 13
    ClientName.Parent = Handler
    
    local Icon = Instance.new('ImageLabel')
    Icon.ImageColor3 = Color3.fromRGB(152, 181, 255)
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.Image = 'rbxassetid://107819132007001'
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0.025, 0, 0.055, 0)
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.Name = 'Icon'
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Parent = Handler
    
    local Divider = Instance.new('Frame')
    Divider.Name = 'Divider'
    Divider.BackgroundTransparency = 0.5
    Divider.Position = UDim2.new(0.235, 0, 0, 0)
    Divider.Size = UDim2.new(0, 1, 0, 479)
    Divider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    Divider.BorderSizePixel = 0
    Divider.Parent = Handler
    
    local Sections = Instance.new('Folder')
    Sections.Name = 'Sections'
    Sections.Parent = Handler
    
    -- Settings Panel (right side)
    local SettingsPanel = Instance.new('Frame')
    SettingsPanel.Name = 'SettingsPanel'
    SettingsPanel.Size = UDim2.new(0, 250, 0, 479)
    SettingsPanel.Position = UDim2.new(1, 10, 0, 0)
    SettingsPanel.BackgroundColor3 = Color3.fromRGB(12, 13, 15)
    SettingsPanel.BackgroundTransparency = 0.05
    SettingsPanel.BorderSizePixel = 0
    SettingsPanel.Visible = false
    SettingsPanel.ClipsDescendants = true
    SettingsPanel.Parent = Container
    
    local SettingsPanelCorner = Instance.new('UICorner')
    SettingsPanelCorner.CornerRadius = UDim.new(0, 10)
    SettingsPanelCorner.Parent = SettingsPanel
    
    local SettingsPanelStroke = Instance.new('UIStroke')
    SettingsPanelStroke.Color = Color3.fromRGB(52, 66, 89)
    SettingsPanelStroke.Transparency = 0.5
    SettingsPanelStroke.Parent = SettingsPanel
    
    local SettingsPanelHeader = Instance.new('Frame')
    SettingsPanelHeader.Name = 'Header'
    SettingsPanelHeader.Size = UDim2.new(1, 0, 0, 50)
    SettingsPanelHeader.BackgroundTransparency = 1
    SettingsPanelHeader.Parent = SettingsPanel
    
    local SettingsPanelTitle = Instance.new('TextLabel')
    SettingsPanelTitle.Name = 'Title'
    SettingsPanelTitle.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    SettingsPanelTitle.TextColor3 = Color3.fromRGB(152, 181, 255)
    SettingsPanelTitle.TextTransparency = 0.2
    SettingsPanelTitle.Text = 'Settings'
    SettingsPanelTitle.Size = UDim2.new(1, -50, 0, 20)
    SettingsPanelTitle.Position = UDim2.new(0, 15, 0.5, 0)
    SettingsPanelTitle.AnchorPoint = Vector2.new(0, 0.5)
    SettingsPanelTitle.BackgroundTransparency = 1
    SettingsPanelTitle.TextXAlignment = Enum.TextXAlignment.Left
    SettingsPanelTitle.TextSize = 14
    SettingsPanelTitle.Parent = SettingsPanelHeader
    
    local SettingsPanelClose = Instance.new('TextButton')
    SettingsPanelClose.Name = 'Close'
    SettingsPanelClose.Text = '×'
    SettingsPanelClose.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    SettingsPanelClose.TextColor3 = Color3.fromRGB(152, 181, 255)
    SettingsPanelClose.TextSize = 20
    SettingsPanelClose.Size = UDim2.new(0, 30, 0, 30)
    SettingsPanelClose.Position = UDim2.new(1, -40, 0.5, 0)
    SettingsPanelClose.AnchorPoint = Vector2.new(0, 0.5)
    SettingsPanelClose.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    SettingsPanelClose.BackgroundTransparency = 0.5
    SettingsPanelClose.AutoButtonColor = false
    SettingsPanelClose.Parent = SettingsPanelHeader
    
    local SettingsPanelCloseCorner = Instance.new('UICorner')
    SettingsPanelCloseCorner.CornerRadius = UDim.new(0, 6)
    SettingsPanelCloseCorner.Parent = SettingsPanelClose
    
    local SettingsPanelContent = Instance.new('ScrollingFrame')
    SettingsPanelContent.Name = 'Content'
    SettingsPanelContent.Size = UDim2.new(1, 0, 1, -60)
    SettingsPanelContent.Position = UDim2.new(0, 0, 0, 55)
    SettingsPanelContent.BackgroundTransparency = 1
    SettingsPanelContent.ScrollBarThickness = 4
    SettingsPanelContent.ScrollBarImageColor3 = Color3.fromRGB(152, 181, 255)
    SettingsPanelContent.ScrollBarImageTransparency = 0.5
    SettingsPanelContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SettingsPanelContent.BorderSizePixel = 0
    SettingsPanelContent.Parent = SettingsPanel
    
    local SettingsPanelContentLayout = Instance.new('UIListLayout')
    SettingsPanelContentLayout.Padding = UDim.new(0, 8)
    SettingsPanelContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SettingsPanelContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsPanelContentLayout.Parent = SettingsPanelContent
    
    local SettingsPanelContentPadding = Instance.new('UIPadding')
    SettingsPanelContentPadding.PaddingTop = UDim.new(0, 5)
    SettingsPanelContentPadding.PaddingBottom = UDim.new(0, 10)
    SettingsPanelContentPadding.Parent = SettingsPanelContent
    
    Library._settings_panel = SettingsPanel
    
    SettingsPanelClose.MouseButton1Click:Connect(function()
        Library:hide_settings_panel()
    end)
    
    SettingsPanelClose.MouseEnter:Connect(function()
        TweenService:Create(SettingsPanelClose, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    SettingsPanelClose.MouseLeave:Connect(function()
        TweenService:Create(SettingsPanelClose, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.5
        }):Play()
    end)
    
    self._ui = March
    
    -- Toggle visibility with Insert key
    Connections['library_visiblity'] = UserInputService.InputBegan:Connect(function(input, process)
        if input.KeyCode ~= Enum.KeyCode.Insert then return end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)
    
    return self
end

function Library:create_tab(title, icon)
    local TabManager = {}
    
    self._tab += 1
    local is_first = self._tab == 1
    
    local Tab = Instance.new('TextButton')
    Tab.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Tab.TextColor3 = Color3.fromRGB(152, 181, 255)
    Tab.TextTransparency = is_first and 0.2 or 0.7
    Tab.Text = '  ' .. title
    Tab.Name = title
    Tab.Size = UDim2.new(0, 129, 0, 28)
    Tab.BackgroundTransparency = is_first and 0.9 or 1
    Tab.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Tab.TextXAlignment = Enum.TextXAlignment.Left
    Tab.TextSize = 11
    Tab.AutoButtonColor = false
    Tab.Parent = self._ui.Container.Handler.Tabs
    
    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Tab
    
    local TabIcon = Instance.new('ImageLabel')
    TabIcon.ImageColor3 = Color3.fromRGB(152, 181, 255)
    TabIcon.ImageTransparency = is_first and 0.2 or 0.7
    TabIcon.ScaleType = Enum.ScaleType.Fit
    TabIcon.Image = icon or ''
    TabIcon.BackgroundTransparency = 1
    TabIcon.Position = UDim2.new(0, 8, 0.5, 0)
    TabIcon.AnchorPoint = Vector2.new(0, 0.5)
    TabIcon.Size = UDim2.new(0, 14, 0, 14)
    TabIcon.Parent = Tab
    
    -- Create sections
    local LeftSection = Instance.new('ScrollingFrame')
    LeftSection.Name = 'LeftSection'
    LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LeftSection.ScrollBarThickness = 0
    LeftSection.Size = UDim2.new(0, 243, 0, 445)
    LeftSection.BackgroundTransparency = 1
    LeftSection.Position = UDim2.new(0.259, 0, 0.5, 0)
    LeftSection.AnchorPoint = Vector2.new(0, 0.5)
    LeftSection.Visible = is_first
    LeftSection.Parent = self._ui.Container.Handler.Sections
    
    local LeftLayout = Instance.new('UIListLayout')
    LeftLayout.Padding = UDim.new(0, 11)
    LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Parent = LeftSection
    
    local RightSection = Instance.new('ScrollingFrame')
    RightSection.Name = 'RightSection'
    RightSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightSection.ScrollBarThickness = 0
    RightSection.Size = UDim2.new(0, 243, 0, 445)
    RightSection.BackgroundTransparency = 1
    RightSection.Position = UDim2.new(0.629, 0, 0.5, 0)
    RightSection.AnchorPoint = Vector2.new(0, 0.5)
    RightSection.Visible = is_first
    RightSection.Parent = self._ui.Container.Handler.Sections
    
    local RightLayout = Instance.new('UIListLayout')
    RightLayout.Padding = UDim.new(0, 11)
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Parent = RightSection
    
    Tab.MouseButton1Click:Connect(function()
        -- Hide all sections
        for _, section in self._ui.Container.Handler.Sections:GetChildren() do
            section.Visible = false
        end
        -- Show this tab's sections
        LeftSection.Visible = true
        RightSection.Visible = true
        
        -- Update tab appearances
        for _, tab in self._ui.Container.Handler.Tabs:GetChildren() do
            if tab:IsA('TextButton') then
                tab.TextTransparency = 0.7
                tab.BackgroundTransparency = 1
                local icon = tab:FindFirstChildOfClass('ImageLabel')
                if icon then icon.ImageTransparency = 0.7 end
            end
        end
        Tab.TextTransparency = 0.2
        Tab.BackgroundTransparency = 0.9
        TabIcon.ImageTransparency = 0.2
    end)
    
    function TabManager:create_module(settings)
        local section = settings.section == 'right' and RightSection or LeftSection
        
        return self:_create_module_internal(settings, section)
    end
    
    function TabManager:_create_module_internal(settings, section)
        local ModuleManager = {}
        
        local Module = Instance.new('Frame')
        Module.Name = 'Module'
        Module.Size = UDim2.new(0, 241, 0, 93)
        Module.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        Module.BackgroundTransparency = 0.5
        Module.BorderSizePixel = 0
        Module.Parent = section
        
        local UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = Module
        
        local UIStroke = Instance.new('UIStroke')
        UIStroke.Color = Color3.fromRGB(52, 66, 89)
        UIStroke.Transparency = 0.5
        UIStroke.Parent = Module
        
        local Header = Instance.new('TextButton')
        Header.Name = 'Header'
        Header.Text = ''
        Header.Size = UDim2.new(0, 241, 0, 93)
        Header.BackgroundTransparency = 1
        Header.AutoButtonColor = false
        Header.Parent = Module
        
        local ModuleName = Instance.new('TextLabel')
        ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        ModuleName.TextColor3 = Color3.fromRGB(152, 181, 255)
        ModuleName.TextTransparency = 0.2
        ModuleName.Text = settings.title or "Module"
        ModuleName.Name = 'ModuleName'
        ModuleName.Size = UDim2.new(0, 205, 0, 13)
        ModuleName.AnchorPoint = Vector2.new(0, 0.5)
        ModuleName.Position = UDim2.new(0.073, 0, 0.24, 0)
        ModuleName.BackgroundTransparency = 1
        ModuleName.TextXAlignment = Enum.TextXAlignment.Left
        ModuleName.TextSize = 13
        ModuleName.Parent = Header
        
        local Description = Instance.new('TextLabel')
        Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        Description.TextColor3 = Color3.fromRGB(152, 181, 255)
        Description.TextTransparency = 0.7
        Description.Text = settings.description or ""
        Description.Name = 'Description'
        Description.Size = UDim2.new(0, 205, 0, 13)
        Description.AnchorPoint = Vector2.new(0, 0.5)
        Description.Position = UDim2.new(0.073, 0, 0.42, 0)
        Description.BackgroundTransparency = 1
        Description.TextXAlignment = Enum.TextXAlignment.Left
        Description.TextSize = 10
        Description.Parent = Header
        
        -- Options container (hidden, shown in settings panel)
        local Options = Instance.new('Frame')
        Options.Name = 'Options'
        Options.BackgroundTransparency = 1
        Options.Size = UDim2.new(0, 241, 0, 8)
        Options.Visible = false
        Options.Parent = Module
        
        local OptionsLayout = Instance.new('UIListLayout')
        OptionsLayout.Padding = UDim.new(0, 5)
        OptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Parent = Options
        
        local OptionsPadding = Instance.new('UIPadding')
        OptionsPadding.PaddingTop = UDim.new(0, 8)
        OptionsPadding.Parent = Options
        
        -- Click to open/close settings panel
        Header.MouseButton1Click:Connect(function()
            local module_title = settings.title or "Module"
            
            if Library._current_settings_module == module_title then
                Library:hide_settings_panel()
            else
                Library:show_settings_panel(module_title, Options)
            end
        end)
        
        -- Create component functions
        ModuleManager.create_slider = function(self, slider_settings)
            return create_slider(Options, slider_settings)
        end
        
        ModuleManager.create_checkbox = function(self, checkbox_settings)
            return create_checkbox(Options, checkbox_settings)
        end
        
        ModuleManager.create_dropdown = function(self, dropdown_settings)
            return create_dropdown(Options, dropdown_settings)
        end
        
        ModuleManager.create_colorpicker = function(self, colorpicker_settings)
            return create_colorpicker(Options, colorpicker_settings, March)
        end
        
        ModuleManager.create_textbox = function(self, textbox_settings)
            return create_textbox(Options, textbox_settings)
        end
        
        ModuleManager.create_paragraph = function(self, paragraph_settings)
            return create_paragraph(Options, paragraph_settings)
        end
        
        ModuleManager.create_divider = function(self, divider_settings)
            return create_divider(Options, divider_settings)
        end
        
        return ModuleManager
    end
    
    return TabManager
end

function Library:load()
    self._loaded = true
end

return Library

-- Component Creation Functions

function create_slider(parent, settings)
    local SliderManager = {}
    
    local Slider = Instance.new('TextButton')
    Slider.Name = 'Slider'
    Slider.Text = ''
    Slider.Size = UDim2.new(0, 207, 0, 22)
    Slider.BackgroundTransparency = 1
    Slider.AutoButtonColor = false
    Slider.Parent = parent
    
    local Title = Instance.new('TextLabel')
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextTransparency = 0.2
    Title.Text = settings.title or "Slider"
    Title.Size = UDim2.new(0, 153, 0, 13)
    Title.Position = UDim2.new(0, 0, 0.05, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 11
    Title.Parent = Slider
    
    local Value = Instance.new('TextLabel')
    Value.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Value.TextColor3 = Color3.fromRGB(255, 255, 255)
    Value.TextTransparency = 0.2
    Value.Text = tostring(settings.value or 50)
    Value.Name = 'Value'
    Value.Size = UDim2.new(0, 42, 0, 13)
    Value.AnchorPoint = Vector2.new(1, 0)
    Value.Position = UDim2.new(1, 0, 0, 0)
    Value.BackgroundTransparency = 1
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.TextSize = 10
    Value.Parent = Slider
    
    local Drag = Instance.new('Frame')
    Drag.Name = 'Drag'
    Drag.AnchorPoint = Vector2.new(0.5, 1)
    Drag.BackgroundTransparency = 0.9
    Drag.Position = UDim2.new(0.5, 0, 0.95, 0)
    Drag.Size = UDim2.new(0, 207, 0, 4)
    Drag.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Drag.BorderSizePixel = 0
    Drag.Parent = Slider
    
    local DragCorner = Instance.new('UICorner')
    DragCorner.CornerRadius = UDim.new(1, 0)
    DragCorner.Parent = Drag
    
    local Fill = Instance.new('Frame')
    Fill.Name = 'Fill'
    Fill.AnchorPoint = Vector2.new(0, 0.5)
    Fill.BackgroundTransparency = 0.5
    Fill.Position = UDim2.new(0, 0, 0.5, 0)
    Fill.Size = UDim2.new(0.5, 0, 0, 4)
    Fill.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Drag
    
    local FillCorner = Instance.new('UICorner')
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill
    
    local Circle = Instance.new('Frame')
    Circle.Name = 'Circle'
    Circle.AnchorPoint = Vector2.new(1, 0.5)
    Circle.Position = UDim2.new(1, 0, 0.5, 0)
    Circle.Size = UDim2.new(0, 6, 0, 6)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = Fill
    
    local CircleCorner = Instance.new('UICorner')
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    function SliderManager:set_value(value)
        local percentage = (value - settings.minimum_value) / (settings.maximum_value - settings.minimum_value)
        percentage = math.clamp(percentage, 0, 1)
        
        local rounded = settings.round_number and math.floor(value) or (math.floor(value * 10) / 10)
        rounded = math.clamp(rounded, settings.minimum_value, settings.maximum_value)
        
        Library._config._flags[settings.flag] = rounded
        Value.Text = tostring(rounded)
        
        Fill.Size = UDim2.new(percentage, 0, 0, 4)
        
        if settings.callback then
            settings.callback(rounded)
        end
        
        Config:save(game.GameId, Library._config)
    end
    
    local dragging = false
    
    Slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    Connections['slider_'..settings.flag..'_end'] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Connections['slider_'..settings.flag..'_move'] = RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relativeX = math.clamp((mousePos.X - Drag.AbsolutePosition.X) / Drag.AbsoluteSize.X, 0, 1)
            local value = settings.minimum_value + (relativeX * (settings.maximum_value - settings.minimum_value))
            SliderManager:set_value(value)
        end
    end)
    
    if Library:flag_type(settings.flag, 'number') then
        SliderManager:set_value(Library._config._flags[settings.flag])
    else
        SliderManager:set_value(settings.value or 50)
    end
    
    return SliderManager
end

function create_checkbox(parent, settings)
    local CheckboxManager = { _state = false }
    
    local Checkbox = Instance.new('TextButton')
    Checkbox.Name = 'Checkbox'
    Checkbox.Text = ''
    Checkbox.Size = UDim2.new(0, 207, 0, 15)
    Checkbox.BackgroundTransparency = 1
    Checkbox.AutoButtonColor = false
    Checkbox.Parent = parent
    
    local Title = Instance.new('TextLabel')
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextTransparency = 0.2
    Title.Text = settings.title or "Checkbox"
    Title.Size = UDim2.new(0, 142, 0, 13)
    Title.AnchorPoint = Vector2.new(0, 0.5)
    Title.Position = UDim2.new(0, 0, 0.5, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 11
    Title.Parent = Checkbox
    
    local Box = Instance.new('Frame')
    Box.Name = 'Box'
    Box.AnchorPoint = Vector2.new(1, 0.5)
    Box.BackgroundTransparency = 0.9
    Box.Position = UDim2.new(1, 0, 0.5, 0)
    Box.Size = UDim2.new(0, 15, 0, 15)
    Box.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Box.BorderSizePixel = 0
    Box.Parent = Checkbox
    
    local BoxCorner = Instance.new('UICorner')
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box
    
    local Fill = Instance.new('Frame')
    Fill.Name = 'Fill'
    Fill.AnchorPoint = Vector2.new(0.5, 0.5)
    Fill.BackgroundTransparency = 0.2
    Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
    Fill.Size = UDim2.new(0, 0, 0, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Box
    
    local FillCorner = Instance.new('UICorner')
    FillCorner.CornerRadius = UDim.new(0, 3)
    FillCorner.Parent = Fill
    
    function CheckboxManager:change_state(state)
        self._state = state
        
        if self._state then
            TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 0.7
            }):Play()
            TweenService:Create(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                Size = UDim2.fromOffset(9, 9)
            }):Play()
        else
            TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 0.9
            }):Play()
            TweenService:Create(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                Size = UDim2.fromOffset(0, 0)
            }):Play()
        end
        
        Library._config._flags[settings.flag] = self._state
        Config:save(game.GameId, Library._config)
        
        if settings.callback then
            settings.callback(self._state)
        end
    end
    
    Checkbox.MouseButton1Click:Connect(function()
        CheckboxManager:change_state(not CheckboxManager._state)
    end)
    
    if Library:flag_type(settings.flag, 'boolean') then
        CheckboxManager:change_state(Library._config._flags[settings.flag])
    end
    
    return CheckboxManager
end

function create_dropdown(parent, settings)
    local DropdownManager = { _state = false }
    
    local Dropdown = Instance.new('TextButton')
    Dropdown.Name = 'Dropdown'
    Dropdown.Text = ''
    Dropdown.Size = UDim2.new(0, 207, 0, 39)
    Dropdown.BackgroundTransparency = 1
    Dropdown.AutoButtonColor = false
    Dropdown.Parent = parent
    
    local Title = Instance.new('TextLabel')
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextTransparency = 0.2
    Title.Text = settings.title or "Dropdown"
    Title.Size = UDim2.new(0, 207, 0, 13)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 11
    Title.Parent = Dropdown
    
    local Box = Instance.new('Frame')
    Box.Name = 'Box'
    Box.ClipsDescendants = true
    Box.AnchorPoint = Vector2.new(0.5, 0)
    Box.BackgroundTransparency = 0.9
    Box.Position = UDim2.new(0.5, 0, 1.2, 0)
    Box.Size = UDim2.new(0, 207, 0, 22)
    Box.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    Box.BorderSizePixel = 0
    Box.Parent = Title
    
    local BoxCorner = Instance.new('UICorner')
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box
    
    local CurrentOption = Instance.new('TextLabel')
    CurrentOption.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    CurrentOption.TextColor3 = Color3.fromRGB(255, 255, 255)
    CurrentOption.TextTransparency = 0.2
    CurrentOption.Text = settings.options[1] or "None"
    CurrentOption.Name = 'CurrentOption'
    CurrentOption.Size = UDim2.new(0, 161, 0, 13)
    CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
    CurrentOption.Position = UDim2.new(0.05, 0, 0.5, 0)
    CurrentOption.BackgroundTransparency = 1
    CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
    CurrentOption.TextSize = 10
    CurrentOption.Parent = Box
    
    local Options = Instance.new('ScrollingFrame')
    Options.Name = 'Options'
    Options.ScrollBarThickness = 0
    Options.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Options.Size = UDim2.new(0, 207, 0, 0)
    Options.Position = UDim2.new(0, 0, 1, 0)
    Options.BackgroundTransparency = 1
    Options.BorderSizePixel = 0
    Options.Parent = Box
    
    local OptionsLayout = Instance.new('UIListLayout')
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Parent = Options
    
    for _, option in ipairs(settings.options) do
        local OptionButton = Instance.new('TextButton')
        OptionButton.Name = option
        OptionButton.Text = '  ' .. option
        OptionButton.Size = UDim2.new(0, 207, 0, 16)
        OptionButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        OptionButton.BackgroundTransparency = 0.5
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.TextTransparency = 0.3
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.TextSize = 10
        OptionButton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        OptionButton.AutoButtonColor = false
        OptionButton.Parent = Options
        
        OptionButton.MouseButton1Click:Connect(function()
            CurrentOption.Text = option
            Library._config._flags[settings.flag] = option
            Config:save(game.GameId, Library._config)
            
            if settings.callback then
                settings.callback(option)
            end
            
            DropdownManager:toggle()
        end)
    end
    
    function DropdownManager:toggle()
        self._state = not self._state
        
        if self._state then
            TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 207, 0, math.min(#settings.options * 16 + 22, 100))
            }):Play()
        else
            TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 207, 0, 22)
            }):Play()
        end
    end
    
    Dropdown.MouseButton1Click:Connect(function()
        DropdownManager:toggle()
    end)
    
    if Library:flag_type(settings.flag, 'string') then
        CurrentOption.Text = Library._config._flags[settings.flag]
    end
    
    return DropdownManager
end

function create_textbox(parent, settings)
    local TextboxManager = {}
    
    local Container = Instance.new('Frame')
    Container.Name = 'Textbox'
    Container.Size = UDim2.new(0, 207, 0, 27)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Title = Instance.new('TextLabel')
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextTransparency = 0.2
    Title.Text = settings.title or "Textbox"
    Title.Size = UDim2.new(0, 207, 0, 13)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 11
    Title.Parent = Container
    
    local Textbox = Instance.new('TextBox')
    Textbox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Textbox.PlaceholderText = settings.placeholder or "Enter text..."
    Textbox.Text = ""
    Textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Textbox.TextSize = 10
    Textbox.Size = UDim2.new(0, 207, 0, 18)
    Textbox.Position = UDim2.new(0, 0, 1, -18)
    Textbox.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    Textbox.BackgroundTransparency = 0.5
    Textbox.BorderSizePixel = 0
    Textbox.ClearTextOnFocus = false
    Textbox.Parent = Container
    
    local TextboxCorner = Instance.new('UICorner')
    TextboxCorner.CornerRadius = UDim.new(0, 4)
    TextboxCorner.Parent = Textbox
    
    Textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            Library._config._flags[settings.flag] = Textbox.Text
            Config:save(game.GameId, Library._config)
            
            if settings.callback then
                settings.callback(Textbox.Text)
            end
        end
    end)
    
    if Library:flag_type(settings.flag, 'string') then
        Textbox.Text = Library._config._flags[settings.flag]
    end
    
    return TextboxManager
end

function create_paragraph(parent, settings)
    local Paragraph = Instance.new('Frame')
    Paragraph.Name = 'Paragraph'
    Paragraph.Size = UDim2.new(0, 207, 0, 50)
    Paragraph.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    Paragraph.BackgroundTransparency = 0.1
    Paragraph.BorderSizePixel = 0
    Paragraph.AutomaticSize = Enum.AutomaticSize.Y
    Paragraph.Parent = parent
    
    local ParagraphCorner = Instance.new('UICorner')
    ParagraphCorner.CornerRadius = UDim.new(0, 4)
    ParagraphCorner.Parent = Paragraph
    
    local Title = Instance.new('TextLabel')
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextColor3 = Color3.fromRGB(210, 210, 210)
    Title.Text = settings.title or "Title"
    Title.Size = UDim2.new(1, -10, 0, 20)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.TextSize = 12
    Title.Parent = Paragraph
    
    local Body = Instance.new('TextLabel')
    Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Body.TextColor3 = Color3.fromRGB(180, 180, 180)
    Body.Text = settings.text or "Text"
    Body.Size = UDim2.new(1, -10, 1, -25)
    Body.Position = UDim2.new(0, 5, 0, 25)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextSize = 10
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Parent = Paragraph
    
    return {}
end

function create_divider(parent, settings)
    local Divider = Instance.new('Frame')
    Divider.Name = 'Divider'
    Divider.Size = UDim2.new(0, 207, 0, 20)
    Divider.BackgroundTransparency = 1
    Divider.Parent = parent
    
    local Line = Instance.new('Frame')
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 0.5, 0)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BackgroundTransparency = 0.8
    Line.BorderSizePixel = 0
    Line.Parent = Divider
    
    local Gradient = Instance.new('UIGradient')
    Gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    Gradient.Parent = Line
    
    return {}
end

function create_colorpicker(parent, settings, screen_gui)
    local ColorPickerManager = {
        _color = settings.default or Color3.fromRGB(255, 255, 255),
        _hue = 0,
        _saturation = 1,
        _value = 1,
        _open = false
    }
    
    -- Load saved color
    if Library._config._flags[settings.flag] then
        local saved = Library._config._flags[settings.flag]
        if typeof(saved) == "table" and saved.r then
            ColorPickerManager._color = Color3.fromRGB(saved.r, saved.g, saved.b)
            ColorPickerManager._hue, ColorPickerManager._saturation, ColorPickerManager._value = RGBtoHSV(ColorPickerManager._color)
        end
    else
        ColorPickerManager._hue, ColorPickerManager._saturation, ColorPickerManager._value = RGBtoHSV(ColorPickerManager._color)
    end
    
    -- Main container
    local ColorPicker = Instance.new('Frame')
    ColorPicker.Name = 'ColorPicker'
    ColorPicker.Size = UDim2.new(0, 207, 0, 22)
    ColorPicker.BackgroundTransparency = 1
    ColorPicker.Parent = parent
    
    local Title = Instance.new('TextLabel')
    Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextTransparency = 0.2
    Title.Text = settings.title or "Color"
    Title.Size = UDim2.new(0, 153, 0, 13)
    Title.Position = UDim2.new(0, 0, 0.5, 0)
    Title.AnchorPoint = Vector2.new(0, 0.5)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 11
    Title.Parent = ColorPicker
    
    local ColorPreview = Instance.new('TextButton')
    ColorPreview.Name = 'ColorPreview'
    ColorPreview.Text = ''
    ColorPreview.AutoButtonColor = false
    ColorPreview.Size = UDim2.new(0, 40, 0, 15)
    ColorPreview.Position = UDim2.new(1, -40, 0.5, 0)
    ColorPreview.AnchorPoint = Vector2.new(0, 0.5)
    ColorPreview.BackgroundColor3 = ColorPickerManager._color
    ColorPreview.BorderSizePixel = 0
    ColorPreview.Parent = ColorPicker
    
    local PreviewCorner = Instance.new('UICorner')
    PreviewCorner.CornerRadius = UDim.new(0, 4)
    PreviewCorner.Parent = ColorPreview
    
    local PreviewStroke = Instance.new('UIStroke')
    PreviewStroke.Color = Color3.fromRGB(52, 66, 89)
    PreviewStroke.Transparency = 0.5
    PreviewStroke.Parent = ColorPreview
    
    -- Color Picker Popup (parented to ScreenGui for top layer)
    local PickerFrame = Instance.new('Frame')
    PickerFrame.Name = 'PickerFrame_' .. settings.flag
    PickerFrame.Size = UDim2.new(0, 200, 0, 170)
    PickerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    PickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    PickerFrame.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    PickerFrame.BorderSizePixel = 0
    PickerFrame.Visible = false
    PickerFrame.ZIndex = 1000
    PickerFrame.Parent = screen_gui
    
    local PickerCorner = Instance.new('UICorner')
    PickerCorner.CornerRadius = UDim.new(0, 8)
    PickerCorner.Parent = PickerFrame
    
    local PickerStroke = Instance.new('UIStroke')
    PickerStroke.Color = Color3.fromRGB(52, 66, 89)
    PickerStroke.Transparency = 0.5
    PickerStroke.Parent = PickerFrame
    
    -- SV Picker
    local SVPicker = Instance.new('ImageButton')
    SVPicker.Name = 'SVPicker'
    SVPicker.Size = UDim2.new(0, 150, 0, 130)
    SVPicker.Position = UDim2.new(0, 10, 0, 10)
    SVPicker.BackgroundColor3 = HSVtoRGB(ColorPickerManager._hue, 1, 1)
    SVPicker.BorderSizePixel = 0
    SVPicker.AutoButtonColor = false
    SVPicker.ZIndex = 1001
    SVPicker.Parent = PickerFrame
    
    local SVCorner = Instance.new('UICorner')
    SVCorner.CornerRadius = UDim.new(0, 4)
    SVCorner.Parent = SVPicker
    
    local WhiteGradient = Instance.new('UIGradient')
    WhiteGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    WhiteGradient.Parent = SVPicker
    
    local BlackOverlay = Instance.new('Frame')
    BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
    BlackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackOverlay.BorderSizePixel = 0
    BlackOverlay.ZIndex = 1002
    BlackOverlay.Parent = SVPicker
    
    local BlackCorner = Instance.new('UICorner')
    BlackCorner.CornerRadius = UDim.new(0, 4)
    BlackCorner.Parent = BlackOverlay
    
    local BlackGradient = Instance.new('UIGradient')
    BlackGradient.Rotation = 90
    BlackGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }
    BlackGradient.Parent = BlackOverlay
    
    local SVCursor = Instance.new('Frame')
    SVCursor.Name = 'SVCursor'
    SVCursor.Size = UDim2.new(0, 10, 0, 10)
    SVCursor.Position = UDim2.new(ColorPickerManager._saturation, 0, 1 - ColorPickerManager._value, 0)
    SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SVCursor.BorderSizePixel = 0
    SVCursor.ZIndex = 1003
    SVCursor.Parent = SVPicker
    
    local SVCursorCorner = Instance.new('UICorner')
    SVCursorCorner.CornerRadius = UDim.new(1, 0)
    SVCursorCorner.Parent = SVCursor
    
    local SVCursorStroke = Instance.new('UIStroke')
    SVCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    SVCursorStroke.Thickness = 2
    SVCursorStroke.Parent = SVCursor
    
    -- Hue Slider
    local HueSlider = Instance.new('ImageButton')
    HueSlider.Name = 'HueSlider'
    HueSlider.Size = UDim2.new(0, 20, 0, 130)
    HueSlider.Position = UDim2.new(0, 170, 0, 10)
    HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueSlider.BorderSizePixel = 0
    HueSlider.AutoButtonColor = false
    HueSlider.ZIndex = 1001
    HueSlider.Parent = PickerFrame
    
    local HueCorner = Instance.new('UICorner')
    HueCorner.CornerRadius = UDim.new(0, 4)
    HueCorner.Parent = HueSlider
    
    local HueGradient = Instance.new('UIGradient')
    HueGradient.Rotation = 90
    HueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    HueGradient.Parent = HueSlider
    
    local HueCursor = Instance.new('Frame')
    HueCursor.Name = 'HueCursor'
    HueCursor.Size = UDim2.new(1, 4, 0, 4)
    HueCursor.Position = UDim2.new(0.5, 0, ColorPickerManager._hue, 0)
    HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueCursor.BorderSizePixel = 0
    HueCursor.ZIndex = 1002
    HueCursor.Parent = HueSlider
    
    local HueCursorCorner = Instance.new('UICorner')
    HueCursorCorner.CornerRadius = UDim.new(0, 2)
    HueCursorCorner.Parent = HueCursor
    
    local HueCursorStroke = Instance.new('UIStroke')
    HueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    HueCursorStroke.Thickness = 1
    HueCursorStroke.Parent = HueCursor
    
    local ColorDisplay = Instance.new('Frame')
    ColorDisplay.Name = 'ColorDisplay'
    ColorDisplay.Size = UDim2.new(0, 180, 0, 15)
    ColorDisplay.Position = UDim2.new(0, 10, 1, -20)
    ColorDisplay.BackgroundColor3 = ColorPickerManager._color
    ColorDisplay.BorderSizePixel = 0
    ColorDisplay.ZIndex = 1001
    ColorDisplay.Parent = PickerFrame
    
    local DisplayCorner = Instance.new('UICorner')
    DisplayCorner.CornerRadius = UDim.new(0, 4)
    DisplayCorner.Parent = ColorDisplay
    
    local function updateColor()
        ColorPickerManager._color = HSVtoRGB(ColorPickerManager._hue, ColorPickerManager._saturation, ColorPickerManager._value)
        ColorPreview.BackgroundColor3 = ColorPickerManager._color
        ColorDisplay.BackgroundColor3 = ColorPickerManager._color
        SVPicker.BackgroundColor3 = HSVtoRGB(ColorPickerManager._hue, 1, 1)
        
        Library._config._flags[settings.flag] = {
            r = math.floor(ColorPickerManager._color.R * 255),
            g = math.floor(ColorPickerManager._color.G * 255),
            b = math.floor(ColorPickerManager._color.B * 255)
        }
        Config:save(game.GameId, Library._config)
        
        if settings.callback then
            settings.callback(ColorPickerManager._color)
        end
    end
    
    local svDragging = false
    SVPicker.MouseButton1Down:Connect(function()
        svDragging = true
    end)
    
    Connections['sv_drag_'..settings.flag] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
        end
    end)
    
    Connections['sv_move_'..settings.flag] = RunService.RenderStepped:Connect(function()
        if svDragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relativeX = math.clamp((mousePos.X - SVPicker.AbsolutePosition.X) / SVPicker.AbsoluteSize.X, 0, 1)
            local relativeY = math.clamp((mousePos.Y - SVPicker.AbsolutePosition.Y) / SVPicker.AbsoluteSize.Y, 0, 1)
            
            ColorPickerManager._saturation = relativeX
            ColorPickerManager._value = 1 - relativeY
            
            SVCursor.Position = UDim2.new(relativeX, 0, relativeY, 0)
            updateColor()
        end
    end)
    
    local hueDragging = false
    HueSlider.MouseButton1Down:Connect(function()
        hueDragging = true
    end)
    
    Connections['hue_drag_'..settings.flag] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    Connections['hue_move_'..settings.flag] = RunService.RenderStepped:Connect(function()
        if hueDragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relativeY = math.clamp((mousePos.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
            
            ColorPickerManager._hue = relativeY
            HueCursor.Position = UDim2.new(0.5, 0, relativeY, 0)
            updateColor()
        end
    end)
    
    function ColorPickerManager:toggle()
        if Library._active_color_picker and Library._active_color_picker ~= self then
            Library._active_color_picker:close()
        end
        
        self._open = not self._open
        PickerFrame.Visible = self._open
        
        if self._open then
            Library._active_color_picker = self
        else
            Library._active_color_picker = nil
        end
    end
    
    function ColorPickerManager:close()
        self._open = false
        PickerFrame.Visible = false
        if Library._active_color_picker == self then
            Library._active_color_picker = nil
        end
    end
    
    ColorPreview.MouseButton1Click:Connect(function()
        ColorPickerManager:toggle()
    end)
    
    Connections['colorpicker_close_'..settings.flag] = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorPickerManager._open then
            local mousePos = UserInputService:GetMouseLocation()
            local pickerPos = PickerFrame.AbsolutePosition
            local pickerSize = PickerFrame.AbsoluteSize
            local previewPos = ColorPreview.AbsolutePosition
            local previewSize = ColorPreview.AbsoluteSize
            
            local outsidePicker = mousePos.X < pickerPos.X or mousePos.X > pickerPos.X + pickerSize.X or
                                 mousePos.Y < pickerPos.Y or mousePos.Y > pickerPos.Y + pickerSize.Y
            local outsidePreview = mousePos.X < previewPos.X or mousePos.X > previewPos.X + previewSize.X or
                                  mousePos.Y < previewPos.Y or mousePos.Y > previewPos.Y + previewSize.Y
            
            if outsidePicker and outsidePreview then
                task.defer(function()
                    ColorPickerManager:close()
                end)
            end
        end
    end)
    
    if settings.callback then
        settings.callback(ColorPickerManager._color)
    end
    
    return ColorPickerManager
end
