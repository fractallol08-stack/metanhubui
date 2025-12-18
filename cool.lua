if not isfile("HsBAssets/hsb_ui_loader.lua") then
    writefile("HsBAssets/hsb_ui_loader.lua", game:HttpGet("https://gitlab.com/sens3/assets/-/raw/main/hsb_ui.lua?ref_type=heads"))
end
local vu1 = "https://discord.gg/9xyS35PbSd"
local vu2 = loadfile("HsBAssets/hsb_ui_loader.lua")()
if identifyexecutor():lower():find("solara") or identifyexecutor():lower():find("xeno") then
    local vu3 = vu2.new()
    vu3.discord_invite_label.Text = vu1
    vu3.main_message.Text = "Your executor is not supported. Externals are not supported."
    task.delay(10, function()
        vu3:destroy()
    end)
    return
end
local vu4 = nil
vu4 = hookfunction(print, function(...)
    if checkcaller() then
        return vu4(...)
    end
end)
local vu5 = game:FindService("TeleportService")
game.CoreGui.DescendantAdded:Connect(function(p6)
    if p6.Name == "ErrorPrompt" then
        local v7 = p6:FindFirstChild("ErrorMessage", true)
        repeat
            task.wait()
        until v7.Text ~= "Label"
        if v7.Text:find("No exploiting") or v7.Text:find("rejoin") then
            task.wait(0.1)
            vu5:Teleport(game.PlaceId)
        end
    end
end)
local vu8 = vu5
repeat
    task.wait()
    warn("waiting for game to load")
until game:IsLoaded()
workspace:WaitForChild("Living")
getgenv().backpack_conn_1 = ""
getgenv().backpack_conn_2 = ""
local vu9 = game:FindService("ReplicatedStorage")
local vu10 = game:FindService("HttpService")
local vu11 = game:FindService("RunService")
local v12 = game:FindService("MarketplaceService")
local v13 = vu9
local vu14 = vu9.WaitForChild(v13, "ClientFX")
local vu15 = workspace.Dialogues
local vu16 = "Rib Cage of The Saint\'s Corpse"
local vu17 = require(vu9.Modules.FunctionLibrary)
local vu18 = {
    local_player = game.Players.LocalPlayer,
    lp_gui = game.Players.LocalPlayer.PlayerGui,
    player_level = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("Level"),
    player_pity = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("PityCount"),
    player_stand = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("Stand"),
    player_prestige = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("Prestige"),
    player_spec = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("Spec"),
    player_money = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("Money"),
    player_owns_2xinv = v12:UserOwnsGamePassAsync(game.Players.LocalPlayer.UserId, 14597778),
    m_arrows_count = 0,
    rokaka_count = 0,
    ribs_count = 0
}
local vu19 = vu18.local_player
local vu20 = vu18.lp_gui
local vu21 = vu18.player_level
local vu22 = vu18.player_pity
local vu23 = vu18.player_stand
local vu24 = vu18.player_prestige
local vu25 = vu18.player_spec
local vu26 = vu18.player_money
local vu27 = vu19.Backpack
local vu28 = nil
local vu29 = nil
local vu30 = nil
local vu31 = nil
local vu32 = nil
local function vu34(p33)
    return p33:WaitForChild("ProximityPrompt").ObjectText
end
local function v43()
    local v35 = vu27
    local v36, v37, v38 = pairs(v35:GetChildren())
    local v39 = 0
    local v40 = 0
    local v41 = 0
    while true do
        local v42
        v38, v42 = v36(v37, v38)
        if v38 == nil then
            break
        end
        if v42.Name ~= "Mysterious Arrow" then
            if v42.Name ~= "Rokakaka" then
                if v42.Name == vu16 then
                    v39 = v39 + 1
                end
            else
                v40 = v40 + 1
            end
        else
            v41 = v41 + 1
        end
    end
    vu18.m_arrows_count = v41
    vu18.rokaka_count = v40
    vu18.ribs_count = v39
end
local function vu45(p44)
    if p44.Name ~= "Mysterious Arrow" then
        if p44.Name == "Rokakaka" then
            vu18.rokaka_count = vu18.rokaka_count + 1
        end
    else
        vu18.m_arrows_count = vu18.m_arrows_count + 1
    end
end
local function vu47(p46)
    if p46.Name ~= "Mysterious Arrow" then
        if p46.Name == "Rokakaka" then
            vu18.rokaka_count = vu18.rokaka_count + 1
        end
    else
        vu18.m_arrows_count = vu18.m_arrows_count + 1
    end
end
local vu48 = false
function vu18.get_character(_)
    return vu19.Character:WaitForChild("HumanoidRootPart", 5) and vu19.Character or vu19.CharacterAdded:Wait()
end
function vu18.get_rootpart(p49)
    return p49:get_character():WaitForChild("HumanoidRootPart")
end
function vu18.set_cam_invis(_)
    vu19.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
end
function vu18.set_cam_up(_)
    workspace.CurrentCamera.CFrame = CFrame.new(575.204529, 442.275787, 6164.3335, - 0.934205353, 0.3513138, - 0.0619604401, - 3.72529074e-9, 0.173687175, 0.984800875, 0.356735885, 0.920006275, - 0.162259459)
end
function vu18.learn_skill(p50, p51, p52)
    return p50:get_character():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {
        Skill = p51,
        SkillTreeType = p52
    })
end
function vu18.has_spec_skill(_, p53)
    if vu19.SpecSkillTree:FindFirstChild(p53) then
        return vu19.SpecSkillTree[p53].Value
    else
        return nil
    end
end
function vu18.has_stand_skill(_, p54)
    if vu19.StandSkillTree:FindFirstChild(p54) then
        return vu19.StandSkillTree[p54].Value
    else
        return false
    end
end
function vu18.get_quests(_)
    local v55, v56, v57 = pairs(vu20:WaitForChild("HUD"):WaitForChild("Main"):WaitForChild("Frames"):WaitForChild("Quest"):WaitForChild("Quests"):GetChildren())
    local v58 = {}
    while true do
        local v59
        v57, v59 = v55(v56, v57)
        if v57 == nil then
            break
        end
        if v59.Name ~= "Sample" then
            v58[v59.Name] = true
        end
    end
    return v58
end
function vu18.get_ping(_)
    return game:FindService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 100
end
function vu18.wait_until_new_char(p60)
    vu19.CharacterAdded:Wait()
    p60:get_rootpart()
end
function vu18.sell_items(p61, p62)
    local v63, v64, v65 = pairs(p62)
    while true do
        local v66
        v65, v66 = v63(v64, v65)
        if v65 == nil then
            break
        end
        local v67 = vu27
        local v68, v69, v70 = pairs(v67:GetChildren())
        local v71 = v65
        while true do
            local v72
            v70, v72 = v68(v69, v70)
            if v70 == nil then
                break
            end
            if v71:lower():find("candy") and v72.Name:lower():find("candy") then
                local v73 = vu9.NewDialogue["Halloween Event"]
                vu18:get_character().RemoteEvent:FireServer("PromptTriggered", v73)
            end
            if v72.Name == v71 then
                local v74 = p61:get_bp_item(v71)
                if v74 then
                    v74.Parent = p61:get_character()
                    task.wait()
                    vu30("Merchant", "Dialogue5", "Option2")
                    task.wait()
                end
            end
        end
    end
end
function vu18.sell_item(p75, p76, p77)
    p75:get_bp_item(p76).Parent = p75:get_character()
    task.wait()
    if p77 then
        vu30("Merchant", "Dialogue5", "Option2")
    else
        vu30("Merchant", "Dialogue5", "Option1")
    end
end
function vu18.buy_items(p78, p79)
    local v80, v81, v82 = pairs(p79)
    while true do
        local v83
        v82, v83 = v80(v81, v82)
        if v82 == nil then
            break
        end
        p78:get_character().RemoteEvent:FireServer("PurchaseShopItem", {
            ItemName = v82
        })
    end
end
function vu18.get_bp_item(_, p84)
    vu27:WaitForChild(p84, 1)
    return vu27:FindFirstChild(p84)
end
function vu18.get_bp_items(_, p85)
    vu27:WaitForChild(p85, 1)
    local v86 = vu27
    local v87, v88, v89 = pairs(v86:GetChildren())
    local v90 = {}
    while true do
        local v91
        v89, v91 = v87(v88, v89)
        if v89 == nil then
            break
        end
        if v91.Name == p85 then
            table.insert(v90, v91)
        end
    end
    return v90
end
function vu18.is_full_of_item(_, p92)
    vu27:WaitForChild(p92, 1)
    local v93 = vu27
    local v94, v95, v96 = pairs(v93:GetChildren())
    local v97 = 0
    while true do
        local v98
        v96, v98 = v94(v95, v96)
        if v96 == nil then
            break
        end
        if v98.Name == p92 then
            v97 = v97 + 1
        end
    end
    return vu18.player_owns_2xinv and v97 == vu17.DroppableItems[p92].Max * 2 and true or (not vu18.player_owns_2xinv and v97 == vu17.DroppableItems[p92].Max and true or false)
end
function vu18.has_item(p99, p100, p101)
    if p101 then
        return # p99:get_bp_items(p100) == p101 and true or false
    else
        return p99:get_bp_item(p100) and true or false
    end
end
function vu18.get_item_shop(_)
    local v102 = vu20:WaitForChild("HUD"):WaitForChild("Main"):WaitForChild("Frames"):WaitForChild("Store"):WaitForChild("List"):WaitForChild("ItemShop"):WaitForChild("List"):GetChildren()
    local v103, v104, v105 = pairs(v102)
    local v106 = {}
    local v107 = {}
    local v108 = 1
    while true do
        local v109
        v105, v109 = v103(v104, v105)
        if v105 == nil then
            break
        end
        print(v105, v109, v109.ClassName)
        if v109.ClassName == "TextButton" and v109.Name ~= "Template" then
            v106[v109.Name] = true
            v107[v108] = v109.Name
            v108 = v108 + 1
        end
    end
    return v106, v107
end
function vu18.get_spawnable_items(_)
    local v110, v111, v112 = pairs(vu17.SpawnableItems)
    local v113 = {}
    while true do
        local v114
        v112, v114 = v110(v111, v112)
        if v112 == nil then
            break
        end
        table.insert(v113, v114.Name)
    end
    return v113
end
function vu18.get_sellable_items(_)
    local v115, v116, v117 = pairs(vu17.SellableItems)
    local v118 = {}
    while true do
        local v119
        v117, v119 = v115(v116, v117)
        if v117 == nil then
            break
        end
        table.insert(v118, v117)
    end
    table.insert(v118, "Candy")
    return v118
end
function vu18.notify_shiny(_)
    if vu31.Value then
        vu29("You got the Shiny: " .. vu18:get_character().StandMorph.StandSkin.Value .. " on " .. vu23.Value, true)
    end
    vu28("You got the Shiny: " .. vu18:get_character().StandMorph.StandSkin.Value .. " on ", vu23.Value, 7)
end
function vu18.notify_stand(_)
    if vu31.Value then
        vu29("You got the Stand you wanted: " .. {
            vu23.Value
        }, false)
    end
    vu28("You got the Stand you wanted: ", vu23.Value, 7)
end
vu19.ChildAdded:Connect(function(p120)
    if p120.Name == "Backpack" then
        vu48 = true
        vu18.m_arrows_count = 0
        vu18.rokaka_count = 0
        vu27 = p120
        getgenv().backpack_conn_1:Disconnect()
        getgenv().backpack_conn_2:Disconnect()
        getgenv().backpack_conn_1 = vu27.ChildAdded:Connect(vu47)
        getgenv().backpack_conn_2 = vu27.ChildRemoved:Connect(vu45)
        vu48 = false
    end
end)
v43()
getgenv().backpack_conn_1 = vu27.ChildAdded:Connect(vu47)
getgenv().backpack_conn_2 = vu27.ChildRemoved:Connect(vu45)
local vu121 = vu9
local vu122 = vu27
local vu123 = vu16
local vu124 = vu23
local vu125 = vu18
repeat
    task.wait()
until game.Players.LocalPlayer.Character
while true do
    local v126 = vu20
    if not vu20.FindFirstChild(v126, "LoadingScreen1") then
        local v127 = vu20
        if not vu20.FindFirstChild(v127, "LoadingScreen") then
            repeat
                task.wait()
            until vu19.LoadedData.Value
            local v128 = filtergc("function", {
                Constants = {
                    "TextFrame",
                    "Text",
                    "AnimateStepTime",
                    "TextXAlignment",
                    "StarterGui"
                }
            }, true)
            if v128 then
                local vu129 = nil
                vu129 = hookfunction(v128, newcclosure(function(p130)
                    vu125:get_rootpart().Anchored = false
                    if not p130.AutoContinue then
                        local v131 = p130.Text
                        if v131 then
                            v131 = p130.Text:lower()
                        end
                        if v131:find("eating this") or p130.Text:lower():find("senses a bit of") then
                            return {
                                Option = "Option1"
                            }
                        end
                        if v131:find("hello there, heheheh") and vu32.Value then
                            return {
                                Option = "Option2"
                            }
                        end
                        if not (v131:find("you now have") and (v131:find("points") and vu32.Value)) then
                            return vu129(p130)
                        end
                        p130.Gui:Destroy()
                    end
                end))
                local vu132 = {}
                local vu133 = {}
                local vu134 = {}
                local function vu138(p135)
                    local v136 = vu133[p135]
                    if v136 then
                        print("unregistered item", v136, p135.Parent)
                        if vu134[p135] then
                            vu134[p135]:Disconnect()
                            vu134[p135] = nil
                        end
                        vu133[p135] = nil
                        if vu132[v136] then
                            local v137 = table.find(vu132[v136], p135)
                            if v137 then
                                table.remove(vu132[v136], v137)
                            end
                            if # vu132[v136] == 0 then
                                vu132[v136] = nil
                            end
                        end
                    end
                end
                local function v140(pu139)
                    if pu139.ClassName == "ProximityPrompt" then
                        if pu139.Enabled then
                            return
                        elseif pu139.Parent:FindFirstChild("PointLight", true) then
                            print("registered item", pu139.ObjectText, pu139.Parent)
                            if not vu132[pu139.ObjectText] then
                                vu132[pu139.ObjectText] = {}
                            end
                            table.insert(vu132[pu139.ObjectText], pu139)
                            vu133[pu139] = pu139.ObjectText
                            vu134[pu139] = pu139.AncestryChanged:Connect(function()
                                if not pu139:IsDescendantOf(workspace) then
                                    warn("[REGISTER_GAME_ITEM] NO LONGER IN WORKSPACE", pu139.ObjectText)
                                    vu138(pu139)
                                end
                            end)
                        end
                    else
                        return
                    end
                end
                pcall(function()
                    getgenv().item_added_register_conn:Disconnect()
                    getgenv().item_unadded_register_conn:Disconnect()
                end)
                getgenv().item_added_register_conn = workspace.Item_Spawns.Items.DescendantAdded:Connect(v140)
                getgenv().item_unadded_register_conn = workspace.Item_Spawns.Items.DescendantRemoving:Connect(vu138)
                print("OVer")
                local vu141 = nil
                local vu142 = nil
                local vu143 = nil
                pcall(function()
                    vu141 = loadstring(game:HttpGet("https://gitlab.com/sens3/nebunu/-/raw/main/sillybaka/modified_fluent.lua?ref_type=heads"))()
                    vu142 = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
                    vu143 = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
                end)
                local vu144 = nil
                local vu145 = nil
                getgenv().completed_farm_half_pity = false
                pcall(function()
                    getgenv().walkspeed_modifier_connection:Disconnect()
                end)
                local function vu146()
                    return vu125:get_character():FindFirstChild("StandMorph")
                end
                print("A")
                local v147 = vu141
                local vu148 = vu141.CreateWindow(v147, {
                    Title = "YBA HsB",
                    SubTitle = "by senS",
                    TabWidth = 160,
                    Size = getgenv().start_with_smaller_ui_size == true and UDim2.fromOffset(450, 320) or UDim2.fromOffset(940, 640),
                    Acrylic = true,
                    Theme = "Dark",
                    MinimizeKey = Enum.KeyCode.LeftControl
                })
                local vu149 = {}
                local v150 = vu148
                vu149.Main = vu148.AddTab(v150, {
                    Title = "Main",
                    Icon = "box"
                })
                local v151 = vu148
                vu149.localplayer = vu148.AddTab(v151, {
                    Title = "LocalPlayer",
                    Icon = "user"
                })
                local v152 = vu148
                vu149.miscellaneous = vu148.AddTab(v152, {
                    Title = "Miscellaneous",
                    Icon = "menu"
                })
                local v153 = vu148
                vu149.anti_stands = vu148.AddTab(v153, {
                    Title = "Anti-Stands",
                    Icon = "shield"
                })
                local v154 = vu148
                vu149.settings = vu148.AddTab(v154, {
                    Title = "Settings",
                    Icon = "cog"
                })
                local vu155 = vu149.anti_stands:AddToggle("AntiTS", {
                    Title = "Anti Timestop",
                    Default = false
                })
                vu149.anti_stands:AddToggle("AntiCW", {
                    Title = "Anti CW",
                    Default = false
                }):OnChanged(function(p156)
                    if p156 then
                        local vu157 = false
                        local function vu159()
                            local v158 = Instance.new("Part")
                            v158.Name = tostring(math.random(1, 100))
                            v158.Anchored = true
                            v158.Size = Vector3.new(999, 1, 999)
                            v158.Parent = workspace
                            v158.Transparency = 1
                            v158.CFrame = vu125:get_rootpart().CFrame * CFrame.new(0, 210, 0)
                            vu125:get_rootpart().CFrame = v158.CFrame * CFrame.new(0, 2, 0)
                        end
                        local function vu161()
                            local v160 = vu125:get_rootpart().CFrame
                            vu159()
                            task.wait(1.7)
                            print("Tp back")
                            vu125:get_rootpart().CFrame = v160
                            return true
                        end
                        vu14.OnClientEvent:Connect(function(...)
                            local v162 = {
                                ...
                            }
                            if v162[2].Sound and (v162[2].Origin and (v162[2].Sound == "Rage Mode" and not string.find(tostring(v162[2].Origin), tostring(vu19.Name)))) then
                                local v163 = vu125
                                if (v162[2].Origin.Position - v163:get_rootpart().Position).Magnitude <= 100 and v162[2].Origin.Parent["Stand Name"].Value == "Chariot Requiem" then
                                    print("Got call from event")
                                    if vu157 == false then
                                        vu157 = true
                                        print("Doing something")
                                        repeat
                                            task.wait()
                                        until vu161()
                                        vu157 = false
                                    end
                                end
                            end
                        end)
                    end
                end)
                local v164 = vu155
                vu155.OnChanged(v164, function(p165)
                    if p165 then
                        local vu166 = nil
                        local v167 = false
                        local vu168 = false
                        local function vu170()
                            local v169 = Instance.new("Part")
                            v169.Name = tostring(math.random(1, 100))
                            v169.Anchored = true
                            v169.Size = Vector3.new(999, 1, 999)
                            v169.Parent = workspace
                            v169.Transparency = 1
                            v169.CFrame = vu125:get_rootpart().CFrame * CFrame.new(0, 210, 0)
                            vu125:get_rootpart().CFrame = v169.CFrame * CFrame.new(0, 2, 0)
                        end
                        local function v171()
                            vu166 = vu125:get_rootpart().CFrame
                            vu170()
                            task.wait(1.7)
                            print("Tp back")
                            vu125:get_rootpart().CFrame = vu166
                            vu168 = false
                            return true
                        end
                        local vu172 = {}
                        task.spawn(function()
                            while vu155.Value do
                                task.wait()
                                pcall(function()
                                    local v173, v174, v175 = pairs(game.Players:GetPlayers())
                                    while true do
                                        local v176
                                        v175, v176 = v173(v174, v175)
                                        if v175 == nil then
                                            break
                                        end
                                        if v176 ~= vu19 and vu125:get_rootpart() then
                                            local v177 = v176.Character:FindFirstChild("HumanoidRootPart")
                                            if v177 then
                                                local v178 = vu125
                                                if (v177.Position - v178:get_rootpart().Position).Magnitude > 240 then
                                                    vu172[v176.Character] = nil
                                                else
                                                    vu172[v176.Character] = true
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                        end)
                        task.spawn(function()
                            while vu155.Value do
                                task.wait()
                                pcall(function()
                                    local v179, v180, v181 = pairs(vu172)
                                    while true do
                                        local v182
                                        v181, v182 = v179(v180, v181)
                                        if v181 == nil then
                                            break
                                        end
                                        if v181 and v181:FindFirstChild("StandMorph") then
                                            print(v181)
                                            local v183 = v181.StandMorph.AnimationController:GetPlayingAnimationTracks()
                                            local v184, v185, v186 = pairs(v183)
                                            while true do
                                                local v187
                                                v186, v187 = v184(v185, v186)
                                                if v186 == nil then
                                                    break
                                                end
                                                if v187.Animation.AnimationId == "rbxassetid://4139325504" then
                                                    v187.Animation.AnimationId = ""
                                                    vu168 = true
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                        end)
                        local v188 = vu168
                        while vu155.Value and task.wait() do
                            if v188 then
                                print("Got call of time")
                                if v167 == false then
                                    print("Doing something")
                                    repeat
                                        task.wait()
                                    until v171()
                                    v167 = false
                                end
                            end
                        end
                    end
                end)
                vu149.localplayer:AddSection("LocalPlayer", {})
                vu149.localplayer:AddSlider("HamonStart", {
                    Title = "Min Players",
                    Description = "Threshold start of player check on server hop",
                    Default = 2,
                    Min = 1,
                    Max = 20,
                    Rounding = 0
                })
                vu149.localplayer:AddSlider("MaxPlayers", {
                    Title = "Max Players",
                    Description = "Threshold end of player check on server hop",
                    Default = 12,
                    Min = 1,
                    Max = 20,
                    Rounding = 0
                })
                vu149.settings:AddSection("Prestige farm settings", {})
                local vu189 = vu149.settings:AddSlider("HamonStart", {
                    Title = "Hamon Charge Start",
                    Description = "Threshold start of the hamon charging",
                    Default = 0,
                    Min = 0,
                    Max = 100,
                    Rounding = 1
                })
                local vu190 = vu149.settings:AddSlider("HamonEnd", {
                    Title = "Hamon Charge End",
                    Description = "Threshold end of the hamon charging",
                    Default = 100,
                    Min = 0,
                    Max = 100,
                    Rounding = 1
                })
                local vu191 = vu149.settings:AddToggle("FarmUnder", {
                    Title = "Farm Under",
                    Default = false
                })
                vu149.settings:AddToggle("UseHamonTogg", {
                    Title = "Use Hamon",
                    Default = true,
                    Description = "It\'s recommended to not turn this off due to efficiency issues"
                })
                local vu192 = vu149.settings:AddToggle("UseBarrage", {
                    Title = "Use Barrage",
                    Default = true,
                    Description = "It\'s recommended to not turn this off due to efficiency issues"
                })
                local vu193 = vu149.settings:AddToggle("UseTKey", {
                    Title = "Use T Key",
                    Default = true,
                    Description = "It\'s recommended to not turn this off due to efficiency issues"
                })
                local vu194 = vu149.settings:AddToggle("UseYKey", {
                    Title = "Use Y Key",
                    Default = false
                })
                vu149.settings:AddToggle("UseGKey", {
                    Title = "Use G Key",
                    Default = false
                })
                local vu195 = vu149.settings:AddToggle("UseXKey", {
                    Title = "Use X Key",
                    Default = false
                })
                local vu196 = vu149.settings:AddToggle("UseHKey", {
                    Title = "Use H Key",
                    Default = true,
                    Description = "It\'s recommended to not turn this off, due to efficiency issues"
                })
                task.spawn(function()
                    vu142:SetLibrary(vu141)
                    vu143:SetLibrary(vu141)
                    vu142:IgnoreThemeSettings()
                    vu142:SetIgnoreIndexes({})
                    vu143:SetFolder("FluentScriptHub")
                    vu142:SetFolder("FluentScriptHub/specific-game")
                    vu143:BuildInterfaceSection(vu149.settings)
                    vu148:SelectTab(1)
                    vu142:BuildConfigSection(vu149.settings)
                end)
                getgenv().ping = ""
                getgenv().webhooklink = ""
                vu29 = function(p197, p198)
                    local v199 = nil
                    if getgenv().ping ~= "" then
                        if getgenv().ping ~= "" and p198 == true then
                            v199 = "<@" .. getgenv().ping .. ">"
                        end
                    else
                        v199 = ""
                    end
                    local v200 = {
                        content = v199,
                        username = "HsB CatHook",
                        embeds = {
                            {
                                title = "Your Bizarre Adventure",
                                color = tonumber(16744258),
                                footer = {
                                    text = "HsB Hub (" .. os.date("%H:%M") .. ")",
                                    icon_url = "https://cdn.discordapp.com/attachments/875211210486870076/1067422518413103134/hsb222.png"
                                },
                                fields = {
                                    {
                                        name = "Account Name",
                                        value = "||" .. vu19.Name .. "||"
                                    },
                                    {
                                        name = "InfoHook",
                                        value = p197
                                    }
                                }
                            }
                        }
                    }
                    local v201 = {
                        Url = getgenv().webhooklink,
                        Body = game:GetService("HttpService"):JSONEncode(v200),
                        Method = "POST",
                        Headers = {
                            ["content-type"] = "application/json"
                        }
                    }
                    request(v201)
                end
                vu149.settings:AddSection("Webhook", {})
                vu31 = vu149.settings:AddToggle("WebHookTogg", {
                    Title = "Enable Webhook Alerts",
                    Default = false
                })
                local v202, v203, v204 = pairs(game.CoreGui:GetChildren())
                local vu205 = vu141
                local v206 = vu142
                local vu207 = vu132
                local v208 = vu149
                local vu209 = nil
                while true do
                    local v210, v211 = v202(v203, v204)
                    if v210 == nil then
                        break
                    end
                    v204 = v210
                    if v211.Name == "ScreenGui" and v211.DisplayOrder == 0 then
                        vu209 = v211
                    end
                end
                print("\n\n")
                vu209:GetChildren()[1].ChildAdded:Connect(function(p212)
                    if p212.Name == "Frame" then
                        local v213 = Instance.new("TextButton", p212)
                        v213.Name = "SONS"
                        v213.Size = UDim2.new(1, 0, 1, 0)
                        v213.BackgroundTransparency = 1
                        v213.TextTransparency = 1
                    end
                end)
                if not isfolder("HsBAssets") then
                    makefolder("HsBAssets")
                end
                pcall(function()
                    if not isfile("HsBAssets/Notify.mp3") then
                        local v214 = game:HttpGet("https://raw.githubusercontent.com/HummingBird8/Assets/refs/heads/main/Notify")
                        writefile("HsBAssets/Notify.mp3", crypt.base64decode(v214))
                    end
                end)
                vu28 = function(p215, p216, p217, pu218)
                    local vu219 = Instance.new("Sound")
                    local v220, v221 = pcall(getcustomasset, "HsBAssets/Notify.mp3")
                    vu219.SoundId = v220 and v221 and v221 or 0
                    vu219.Parent = workspace
                    vu219.PlaybackSpeed = 1
                    vu219.Volume = 2
                    vu219:Play()
                    task.delay(0.5, function()
                        vu219:Stop()
                        vu219:Destroy()
                    end)
                    vu205:Notify({
                        Title = p215,
                        Content = p216,
                        SubContent = "",
                        Duration = p217
                    })
                    if pu218 then
                        local v222 = vu209
                        local v223, v224, v225 = pairs(v222:GetDescendants())
                        while true do
                            local v226
                            v225, v226 = v223(v224, v225)
                            if v225 == nil then
                                break
                            end
                            if v226.Name == "SONS" and v226:FindFirstChild("Connected") == nil then
                                Instance.new("NumberValue", v226).Name = "Connected"
                                v226.Activated:Connect(function()
                                    pu218()
                                end)
                            end
                        end
                    end
                end
                local function vu228()
                    vu125:get_rootpart().Anchored = true
                    vu125:get_rootpart().Velocity = Vector3.zero
                    vu125:get_rootpart().AssemblyLinearVelocity = Vector3.zero
                    vu125:get_rootpart().AssemblyAngularVelocity = Vector3.zero
                    local vu227 = Instance.new("Part")
                    vu227.Name = tostring(math.random(1, 6764))
                    vu227.Anchored = true
                    vu227.Size = Vector3.new(150, 1, 150)
                    vu227.Parent = workspace
                    vu227.Transparency = 1
                    vu227.CFrame = vu125:get_rootpart().CFrame * CFrame.new(0, 200, 0)
                    vu125:get_rootpart().CFrame = vu227.CFrame * CFrame.new(0, 6, 0)
                    vu125:get_rootpart().Anchored = false
                    task.delay(15, function()
                        vu227:Destroy()
                    end)
                end
                local function vu229()
                    if vu125:get_character():FindFirstChild("StandMorph") then
                        vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                    end
                end
                local function vu230()
                    if not vu125:get_character():FindFirstChild("StandMorph") then
                        vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                    end
                end
                local function vu231()
                    vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                end
                local function vu232()
                    return vu22.Value <= 0 and 1 or math.clamp(1 + vu22.Value / 25, 0, 10)
                end
                vu30 = function(p233, p234, p235)
                    vu125:get_character():WaitForChild("RemoteEvent"):FireServer("EndDialogue", {
                        NPC = p233,
                        Dialogue = p234,
                        Option = p235
                    })
                end
                local function vu236()
                    if vu124.Value == "Whitesnake" and vu122:FindFirstChild("Green Baby") == nil then
                        vu30("Pucci", "Thugs", "Option1")
                        vu30("Pucci", "Alpha Thugs", "Option1")
                        vu30("Pucci", "Corrupt Police", "Option1")
                        vu30("Pucci", "Zombie Henchman", "Option1")
                        vu30("Pucci", "Vampire", "Option1")
                        vu30("Pucci", "Green Baby", "Option1")
                    end
                end
                local function vu237()
                    vu30("Green Baby", "Dialogue2", "Option1")
                    vu30("Pucci", "MIH12", "Option1")
                    vu30("Pucci", "MIH6", "Option1")
                    if vu124.Value == "C-Moon" and vu122:FindFirstChild("Dio\'s Bone") == nil then
                        vu30("Path to Heaven", "Dialogue8", "Option1")
                    end
                    vu30("Heaven Ascension DEO Quest", "Dialogue5", "Option1")
                    vu30("Pucci", "MIH9", "Option1")
                end
                local function vu241(p238)
                    local v239 = vu125:get_bp_item(p238)
                    if not v239 then
                        warn("no item in useitem")
                        vu28("Not enough items!", "You don\'t have enough " .. p238 .. "s", 4, nil)
                        return false
                    end
                    vu125:get_character().Humanoid:EquipTool(v239)
                    local v240 = vu125:get_character():WaitForChild(p238)
                    repeat
                        v240:Activate()
                        task.wait()
                    until vu20:FindFirstChild("DialogueGui")
                    return true
                end
                local vu242 = nil
                local vu243 = isfile("HsBAssets/servers_cached.txt")
                if vu243 then
                    if readfile("HsBAssets/servers_cached.txt") == "" then
                        vu243 = false
                    else
                        vu243 = readfile("HsBAssets/servers_cached.txt")
                    end
                end
                local vu244 = "Attempting to server hop, don\'t close this."
                local vu245 = nil
                local vu246 = false
                local function vu273()
                    if not vu245 then
                        vu245 = vu2.new()
                    end
                    vu245.discord_invite_label.Text = vu1
                    vu245.main_message.Text = vu244 .. " [...]"
                    local v247 = nil
                    local vu248 = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
                    local function v258(_)
                        if vu243 then
                            print("Servers cached")
                            return vu10:JSONDecode(vu243), true
                        end
                        print("No cache")
                        local v249 = {}
                        while true do
                            while true do
                                local _, vu250 = pcall(function()
                                    return request({
                                        Url = vu248 .. (vu242 and "&cursor=" .. vu242 or ""),
                                        Method = "GET"
                                    })
                                end)
                                if not vu250.Body:find("Too many requests") then
                                    break
                                end
                                print(vu250.Headers["retry-after"])
                                task.wait(vu250.Headers["retry-after"])
                            end
                            vu245.main_message.Text = vu244 .. " [COLLECTING SERVERS...]"
                            print("COLLECTING SERVERS")
                            local v251, v252 = pcall(function()
                                return vu10:JSONDecode(vu250.Body)
                            end)
                            if not v251 then
                                vu245.error_handle_label.Visible = true
                                vu245.main_message.Text = vu244 .. "[ " .. v252 .. " ]"
                                setclipboard(vu250.Body)
                                error(vu250.Body)
                            end
                            if v252.data then
                                local v253, v254, v255 = pairs(v252.data)
                                while true do
                                    local v256
                                    v255, v256 = v253(v254, v255)
                                    if v255 == nil then
                                        break
                                    end
                                    if v256.ping and (v256.ping <= 150 and (v256.playing and v256.playing <= 15)) then
                                        table.insert(v249, v256)
                                    end
                                end
                            end
                            vu242 = v252.nextPageCursor
                            if not vu242 then
                                print("NO CURSOR", # v249)
                                if # v249 <= 0 then
                                    return nil, false
                                end
                                print("collected some servers", # v249)
                                vu245.main_message.Text = vu244 .. " [COLLECTED SERVERS: {#all_servers}]"
                                local v257 = vu10
                                writefile("HsBAssets/servers_cached.txt", v257:JSONEncode({
                                    data = v249
                                }))
                                task.wait(0.09)
                                return {
                                    data = v249
                                }, false
                            end
                            task.wait(0.1)
                        end
                    end
                    while task.wait() do
                        local v259, v260 = v258(v247)
                        if v259 and (v259.data and # v259.data > 0) then
                            if v260 then
                                local v261, v262, v263 = pairs(v259.data)
                                local v264 = false
                                while true do
                                    local v265
                                    v263, v265 = v261(v262, v263)
                                    if v263 == nil then
                                        break
                                    end
                                    if v265 and (v265.playing <= 15 and (v265.id ~= game.JobId and v265.ping < 100)) then
                                        local v266 = v265.id
                                        table.remove(v259.data, v263)
                                        if # v259.data ~= 0 then
                                            local v267 = vu10
                                            writefile("HsBAssets/servers_cached.txt", v267:JSONEncode(v259))
                                            task.wait(0.09)
                                        else
                                            print("Cache exhausted")
                                            vu245.main_message.Text = vu244 .. " [CACHE EXHAUSTED, COLLECTING NEW SERVERS]"
                                            vu28("Servers cache exhausted", "Finished cache", 5)
                                            delfile("HsBAssets/servers_cached.txt")
                                            vu243 = nil
                                        end
                                        if not vu246 then
                                            vu245.main_message.Text = vu244 .. " [FOUND FITTING SERVER, JOINING...]"
                                        end
                                        print("teleporting to new", v265.ping, v265.playing)
                                        vu8:TeleportToPlaceInstance(game.PlaceId, v266, vu19)
                                        return
                                    end
                                end
                                if not v264 then
                                    print("No valid servers found in cache.")
                                    vu245.main_message.Text = vu244 .. " [NO VALID SERVERS FOUND THROUGHOUT THE CACHE, COLLECTING NEW SERVERS]"
                                    delfile("HsBAssets/servers_cached.txt")
                                    vu243 = nil
                                end
                            else
                                local v268, v269, v270 = pairs(v259.data)
                                local v271, v272 = v268(v269, v270)
                                if v271 ~= nil then
                                    local _ = v259.nextPageCursor
                                    vu8:TeleportToPlaceInstance(game.PlaceId, v272.id, vu19)
                                    return
                                end
                            end
                        else
                            pcall(delfile, "HsBAssets/servers_cached.txt")
                            vu243 = nil
                        end
                    end
                end
                local vu274 = 77
                vu8.TeleportInitFailed:Connect(function(_, p275)
                    print("Teleport failed", p275)
                    if vu274 == 0 then
                        vu245.main_message.Text = vu244 .. " [GAVE UP! COLLECTING NEW SERVERS...]"
                        delfile("HsBAssets/servers_cached.txt")
                        vu243 = nil
                    end
                    vu274 = vu274 - 1
                    if p275 == Enum.TeleportResult.GameFull or p275 == Enum.TeleportResult.GameEnded then
                        vu245.main_message.Text = vu244 .. " [FAILED TO HOP BECAUSE SERVER DOES NOT EXIST, RETRYING " .. vu274 .. " TIMES BEFORE GIVING UP!]"
                        vu246 = true
                        local v276 = vu243
                        if v276 then
                            v276 = vu10:JSONDecode(vu243)
                        end
                        if v276 and v276.data then
                            table.remove(v276.data, 1)
                            if # v276.data ~= 0 then
                                local v277 = vu10
                                writefile("HsBAssets/servers_cached.txt", v277:JSONEncode(v276))
                                task.wait(0.09)
                            else
                                delfile("HsBAssets/servers_cached.txt")
                                vu243 = nil
                            end
                        end
                        vu273()
                    elseif p275 == Enum.TeleportResult.Failure then
                        vu245.main_message.Text = vu244 .. " [FAILED TO TELEPORT AT ALL. RETRYING AFTER 5 SECONDS...]"
                        task.wait(5)
                        vu273()
                    end
                end)
                v208.localplayer:AddButton({
                    Title = "Server Hop to another server",
                    Description = "",
                    Callback = function()
                        vu273()
                    end
                })
                local vu278 = v208.localplayer:AddSlider("WSSlider", {
                    Title = "WalkSpeed modifier",
                    Description = "",
                    Default = 24,
                    Min = 1,
                    Max = 200,
                    Rounding = 0
                })
                local v279 = v208.localplayer:AddToggle("WSToggle", {
                    Title = "Enable WalkSpeed",
                    Default = false
                })
                local vu280 = v208.localplayer:AddSlider("JPSlider", {
                    Title = "JumpPower modifier",
                    Description = "",
                    Default = 24,
                    Min = 1,
                    Max = 100,
                    Rounding = 0
                })
                local v281 = v208.localplayer:AddToggle("JPToggle", {
                    Title = "Enable JumpPower",
                    Default = false
                })
                local vu282 = v208.localplayer:AddToggle("AutoSprint", {
                    Title = "Auto-Sprint",
                    Default = false
                })
                local vu283 = v208.localplayer:AddToggle("Name-Hider", {
                    Title = "Name Hider (Client)",
                    Default = false
                })
                v208.miscellaneous:AddButton({
                    Title = "Reset fighting style",
                    Description = "Requirements: 3 Diamonds AND $5000",
                    Callback = function()
                        if vu125:has_item("Diamond", 3) or vu26.Value < 5000 then
                            vu125:get_character().RemoteEvent:FireServer("EndDialogue", {
                                NPC = "Matt",
                                Option = "Option1",
                                Dialogue = "Dialogue5"
                            })
                        else
                            vu28("Requirements not met!", "You need 3 Diamonds and at least $5000", 4)
                        end
                    end
                })
                v208.miscellaneous:AddButton({
                    Title = "Buy Hamon fighting style",
                    Description = "Requirements: Caesar\'s Headband OR Clackers OR Zeppeli\'s Hat equipped AND $10000",
                    Callback = function()
                        if vu26.Value >= 10000 then
                            if vu125:get_character():FindFirstChild("Caesar\'s Headband") or (vu125:get_character():FindFirstChild("Clackers") or vu125:get_character():FindFirstChild("Zeppeli\'s Hat")) then
                                vu125:get_character().RemoteEvent:FireServer("PromptTriggered", vu121.NewDialogue["Lisa Lisa"])
                                repeat
                                    task.wait()
                                    pcall(function()
                                        firesignal(vu19.PlayerGui:FindFirstChild("DialogueGui"):FindFirstChild("Frame"):FindFirstChild("ClickContinue").MouseButton1Click)
                                        task.wait()
                                        firesignal(vu19.PlayerGui:FindFirstChild("DialogueGui"):FindFirstChild("Frame"):FindFirstChild("Options"):FindFirstChild("Option1"):FindFirstChild("TextButton").MouseButton1Click)
                                    end)
                                until vu25.Value ~= "None"
                            end
                        else
                            vu28("Requirements not met!", "You need at least $10000", 4)
                        end
                    end
                })
                v208.miscellaneous:AddButton({
                    Title = "Buy boxing fighting style",
                    Description = "Requirements: Quinton\'s Glove AND $10000",
                    Callback = function()
                        if vu125:has_item("Quinton\'s Glove", 1) and vu26.Value >= 10000 then
                            vu30("Quinton", "Dialogue5", "Option1")
                        else
                            vu28("Requirements not met!", "You need at least $10000 AND Quinton\'s Glove in your inventory", 7)
                        end
                    end
                })
                v208.miscellaneous:AddButton({
                    Title = "Buy boxing gloves",
                    Description = "Requirements: $1000. NOTE: Buying gloves more than 1 time will still lose you money!",
                    Callback = function()
                        if vu26.Value >= 1000 then
                            vu30("Boxing Gloves", "Dialogue1", "Option1")
                        else
                            vu28("Requirements not met!", "You need at least $1000", 4)
                        end
                    end
                })
                v208.miscellaneous:AddButton({
                    Title = "Buy sword fighting style",
                    Description = "Requirements: Ancient Scroll AND $10000",
                    Callback = function()
                        if vu125:has_item("Ancient Scroll", 1) and vu26.Value >= 10000 then
                            vu30("Uzurashi", "Dialogue5", "Option1")
                        else
                            vu28("Requirements not met!", "You need at least $10000 AND an Ancient Scroll in your inventory", 7)
                        end
                    end
                })
                v208.miscellaneous:AddButton({
                    Title = "Buy pluck",
                    Descriptoin = "Requirements: sword fighting style",
                    Callback = function()
                        if vu25.Value == "SwordStyle" then
                            vu30("Pluck", "Dialogue1", "Option1")
                        else
                            vu28("Requirements not met!", "You need the sword fighting style", 4)
                        end
                    end
                })
                v208.miscellaneous:AddButton({
                    Title = "Trigger Jesus dialogue",
                    Description = "",
                    Callback = function()
                        vu125:get_character().RemoteEvent:FireServer("PromptTriggered", vu121.NewDialogue.Jesus)
                    end
                })
                local vu284 = nil
                local v285 = vu283
                vu283.OnChanged(v285, function(p286)
                    if p286 then
                        while vu283.Value do
                            task.wait()
                            local v287, _ = pcall(function()
                                return vu20.HUD.Playerlist[vu19.Name].PlayerName.Text
                            end)
                            if v287 then
                                vu284 = vu20.HUD.Playerlist[vu19.Name].PlayerName
                                vu284.Text = "ProSigmaMoment\239\191\189\239\191\189\239\191\189\239\191\189\239\191\189\239\191\189"
                            end
                        end
                    elseif vu284 ~= nil then
                        vu284.Text = vu19.Name
                    end
                end)
                local v288 = vu282
                vu282.OnChanged(v288, function(p289)
                    if p289 then
                        while vu282.Value do
                            if not vu125:get_character():GetAttribute("Sprinting") then
                                task.spawn(function()
                                    vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleSprinting")
                                end)
                            end
                            task.wait()
                        end
                    end
                end)
                v279:OnChanged(function(p290)
                    if p290 then
                        getgenv().walkspeed_modifier_connection = vu11.RenderStepped:Connect(function()
                            vu125:get_character().Humanoid.WalkSpeed = vu278.Value
                        end)
                    else
                        pcall(function()
                            getgenv().walkspeed_modifier_connection:Disconnect()
                        end)
                    end
                end)
                v281:OnChanged(function(p291)
                    if p291 then
                        getgenv().jumppower_modifier_connection = vu11.RenderStepped:Connect(function()
                            vu125:get_character().Humanoid.JumpPower = vu280.Value
                        end)
                    else
                        pcall(function()
                            getgenv().jumppower_modifier_connection:Disconnect()
                        end)
                    end
                end)
                if game.CoreGui:FindFirstChild("PityShower") then
                    game.CoreGui.PityShower:Destroy()
                end
                local v292 = Instance.new("ScreenGui")
                local vu293 = Instance.new("Frame")
                local vu294 = Instance.new("Frame")
                local vu295 = Instance.new("Frame")
                local v296 = Instance.new("TextLabel")
                local v297 = Instance.new("Frame")
                local v298 = Instance.new("Frame")
                local v299 = Instance.new("Frame")
                local v300 = Instance.new("Frame")
                local v301 = Instance.new("Frame")
                local vu302 = Instance.new("TextLabel")
                local vu303 = Instance.new("TextLabel")
                local vu304 = Instance.new("TextLabel")
                local vu305 = Instance.new("TextLabel")
                local vu306 = Instance.new("TextLabel")
                local v307 = Instance.new("UIAspectRatioConstraint")
                v292.Parent = game.CoreGui
                v292.Name = "PityShower"
                vu293.Parent = v292
                vu293.AnchorPoint = Vector2.new(0.5, 0.5)
                vu293.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                vu293.Position = UDim2.new(0.5, 0, - 0.4, 0)
                vu293.Size = UDim2.new(0.06, 0, 0.241975307, 0)
                vu293.BorderSizePixel = 0
                vu294.Name = "BotBar"
                vu294.Parent = vu293
                vu294.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                vu294.Position = UDim2.new(0.495, 0, 0.1, 0)
                vu294.Size = UDim2.new(0, 0, 0, 0)
                vu294.BackgroundTransparency = 1
                vu295.Name = "TopBar"
                vu295.Parent = vu293
                vu295.BackgroundColor3 = Color3.fromRGB(229, 231, 229)
                vu295.Position = UDim2.new(0, 0, 0.15, 0)
                vu295.Size = UDim2.new(0, 0, 0, 0)
                v296.Name = "Title"
                v296.Parent = vu293
                v296.Position = UDim2.new(0, 0, 0.01, 0)
                v296.Size = UDim2.new(1, 0, 0.15, 0)
                v296.Font = Enum.Font.SourceSansBold
                v296.Text = "HsB Pity Info"
                v296.TextColor3 = Color3.fromRGB(255, 140, 0)
                v296.TextScaled = true
                v296.TextTransparency = 1
                v296.BackgroundTransparency = 1
                v296.BackgroundColor3 = Color3.fromRGB(93, 92, 94)
                v297.Parent = vu293
                v297.Position = UDim2.new(0.05, 0, 0.2, 0)
                v297.Size = UDim2.new(0.9, 0, 0.15, 0)
                v297.BackgroundTransparency = 1
                vu302.Parent = v297
                vu302.Size = UDim2.new(1, 0, 1, 0)
                vu302.Font = Enum.Font.ArialBold
                vu302.Text = "Pity Wanted:"
                vu302.TextColor3 = Color3.fromRGB(255, 140, 0)
                vu302.TextScaled = true
                vu302.TextTransparency = 1
                vu302.BackgroundTransparency = 1
                v298.Parent = vu293
                v298.Position = UDim2.new(0.05, 0, 0.35, 0)
                v298.Size = UDim2.new(0.9, 0, 0.15, 0)
                v298.BackgroundTransparency = 1
                vu303.Parent = v298
                vu303.Size = UDim2.new(1, 0, 1, 0)
                vu303.Font = Enum.Font.ArialBold
                vu303.Text = "Current Pity:"
                vu303.TextColor3 = Color3.fromRGB(255, 140, 0)
                vu303.TextScaled = true
                vu303.TextTransparency = 1
                vu303.BackgroundTransparency = 1
                v299.Parent = vu293
                v299.Position = UDim2.new(0.05, 0, 0.5, 0)
                v299.Size = UDim2.new(0.9, 0, 0.15, 0)
                v299.BackgroundTransparency = 1
                vu304.Parent = v299
                vu304.Size = UDim2.new(1, 0, 1, 0)
                vu304.Font = Enum.Font.ArialBold
                vu304.Text = "HP Wanted:"
                vu304.TextColor3 = Color3.fromRGB(255, 140, 0)
                vu304.TextScaled = true
                vu304.TextTransparency = 1
                vu304.BackgroundTransparency = 1
                v300.Parent = vu293
                v300.Position = UDim2.new(0.05, 0, 0.65, 0)
                v300.Size = UDim2.new(0.9, 0, 0.15, 0)
                v300.BackgroundTransparency = 1
                vu305.Parent = v300
                vu305.Size = UDim2.new(1, 0, 1, 0)
                vu305.Font = Enum.Font.ArialBold
                vu305.Text = "Pity Farm: False"
                vu305.TextColor3 = Color3.fromRGB(255, 140, 0)
                vu305.TextScaled = true
                vu305.TextTransparency = 1
                vu305.BackgroundTransparency = 1
                v301.Parent = vu293
                v301.Position = UDim2.new(0.05, 0, 0.8, 0)
                v301.Size = UDim2.new(0.9, 0, 0.15, 0)
                v301.BackgroundTransparency = 1
                vu306.Parent = v301
                vu306.Size = UDim2.new(1, 0, 1, 0)
                vu306.Font = Enum.Font.ArialBold
                vu306.Text = "DTrouble: False"
                vu306.TextColor3 = Color3.fromRGB(255, 140, 0)
                vu306.TextScaled = true
                vu306.TextTransparency = 1
                vu306.BackgroundTransparency = 1
                v307.Parent = vu293
                v307.AspectRatio = 1.4
                local vu308 = game:GetService("TweenService")
                local vu309 = TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local vu310 = TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
                local v311 = TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
                local vu312 = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local vu313 = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local v314 = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local v315 = TweenInfo.new(0.65, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local v316 = {
                    TextTransparency = 0,
                    BackgroundTransparency = 1
                }
                local v317 = vu308
                local vu318 = vu308.Create(v317, v296, v314, {
                    TextTransparency = 0,
                    BackgroundTransparency = 0
                })
                local v319 = vu308
                local vu320 = vu308.Create(v319, vu302, v314, v316)
                local v321 = vu308
                local vu322 = vu308.Create(v321, vu303, v314, v316)
                local v323 = vu308
                local vu324 = vu308.Create(v323, vu304, v314, v316)
                local v325 = vu308
                local vu326 = vu308.Create(v325, vu305, v314, v316)
                local v327 = vu308
                local vu328 = vu308.Create(v327, vu306, v314, v316)
                vu295.Size = UDim2.new(0, 0, 0, 0)
                vu294.Size = UDim2.new(0, 0, 0, 0)
                local vu329 = {
                    Size = UDim2.new(1, 0, 0.00803212821, 0)
                }
                local vu330 = {
                    Size = UDim2.new(0.007, 0, 0.84, 0)
                }
                local vu331 = {
                    Position = UDim2.new(0.5, 0, 0.11, 0)
                }
                local vu332 = {
                    Size = UDim2.new(0.254689723, 0, 0.30864197, 0)
                }
                local v333 = {
                    Position = UDim2.new(0.5, 0, - 0.4, 0)
                }
                local v334 = {
                    Size = UDim2.new(0.06, 0, 0.241975307, 0)
                }
                local v335 = {
                    TextTransparency = 1,
                    BackgroundTransparency = 1
                }
                local v336 = vu308
                local vu337 = vu308.Create(v336, v296, v315, {
                    TextTransparency = 1,
                    BackgroundTransparency = 1
                })
                local v338 = vu308
                local vu339 = vu308.Create(v338, vu302, v315, v335)
                local v340 = vu308
                local vu341 = vu308.Create(v340, vu303, v315, v335)
                local v342 = vu308
                local vu343 = vu308.Create(v342, vu304, v315, v335)
                local v344 = vu308
                local vu345 = vu308.Create(v344, vu305, v315, v335)
                local v346 = vu308
                local vu347 = vu308.Create(v346, vu306, v315, v335)
                local v348 = {
                    Size = UDim2.new(0, 0, 0, 0)
                }
                local v349 = {
                    Size = UDim2.new(0, 0, 0, 0)
                }
                local v350 = vu308
                local vu351 = vu308.Create(v350, vu293, vu309, v333)
                local v352 = vu308
                local vu353 = vu308.Create(v352, vu293, v311, v334)
                local v354 = vu308
                local vu355 = vu308.Create(v354, vu295, vu312, v348)
                local v356 = vu308
                local vu357 = vu308.Create(v356, vu294, vu313, v349)
                local vu358 = false
                local function vu363()
                    if vu358 == false then
                        local v359 = vu308:Create(vu293, vu309, vu331)
                        local vu360 = vu308:Create(vu293, vu310, vu332)
                        local vu361 = vu308:Create(vu295, vu312, vu329)
                        local vu362 = vu308:Create(vu294, vu313, vu330)
                        v359:Play()
                        v359.Completed:Connect(function()
                            vu360:Play()
                        end)
                        vu360.Completed:Connect(function()
                            vu362:Play()
                            vu361:Play()
                            task.wait(0.15)
                        end)
                        vu361.Completed:Connect(function()
                            vu318:Play()
                            vu320:Play()
                            vu322:Play()
                            vu324:Play()
                            vu326:Play()
                            vu328:Play()
                        end)
                        vu328.Completed:Connect(function()
                            vu358 = true
                        end)
                    end
                end
                local function vu364()
                    if vu358 == true then
                        vu337:Play()
                        vu339:Play()
                        vu341:Play()
                        vu343:Play()
                        vu345:Play()
                        vu347:Play()
                        vu343.Completed:Connect(function()
                            vu355:Play()
                            vu357:Play()
                        end)
                        vu357.Completed:Connect(function()
                            vu353:Play()
                        end)
                        vu353.Completed:Connect(function()
                            vu351:Play()
                        end)
                        vu351.Completed:Connect(function()
                            vu358 = false
                        end)
                    end
                end
                local v365 = Instance.new("ScreenGui")
                v365.Name = "NPCinfoGUI"
                v365.Parent = vu20
                v365.ResetOnSpawn = false
                local v366 = Instance.new("Frame")
                v366.Size = UDim2.new(0, 300, 0, 80)
                v366.Position = UDim2.new(0.5, 0, - 0.01, 0)
                v366.AnchorPoint = Vector2.new(0.5, 0)
                v366.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                v366.BorderSizePixel = 0
                v366.Parent = v365
                v366.BackgroundTransparency = 0
                local v367 = Instance.new("UICorner")
                v367.CornerRadius = UDim.new(0, 12)
                v367.Parent = v366
                local vu368 = Instance.new("TextLabel")
                vu368.Size = UDim2.new(1, - 20, 1, - 20)
                vu368.Position = UDim2.new(0, 10, 0, 10)
                vu368.BackgroundTransparency = 1
                vu368.Text = "NPC Health: 100%"
                vu368.TextColor3 = Color3.fromRGB(230, 230, 230)
                vu368.Font = Enum.Font.GothamBold
                vu368.TextSize = 22
                vu368.TextWrapped = true
                vu368.TextXAlignment = Enum.TextXAlignment.Center
                vu368.TextYAlignment = Enum.TextYAlignment.Center
                vu368.Parent = v366
                local function vu370(p369)
                    return math.floor(p369 * 100) / 100
                end
                v208.Main:AddSection("Item farm", {})
                local vu371 = v208.Main:AddDropdown("ItemSelectedDropDown", {
                    Title = "Choose item(s) to farm",
                    Values = vu125:get_spawnable_items(),
                    Multi = true,
                    Default = {}
                })
                local vu372 = v208.Main:AddDropdown("ItemsToSellDropdown", {
                    Title = "Choose item(s) to sell",
                    Values = vu125:get_sellable_items(),
                    Description = "Selected items will be sold from your inventory while farming.",
                    Multi = true,
                    Default = {}
                })
                local vu373 = v208.Main:AddDropdown("ItemsToBuyDropdown", {
                    Title = "Choose item(s) to buy",
                    Values = select(2, vu125:get_item_shop()),
                    Description = "Selected items will be bought from the shop while farming.",
                    Multi = true,
                    Default = {}
                })
                local v374 = v208.Main:AddToggle("ItemFarmTogg", {
                    Title = "Toggle Item Farm",
                    Default = false
                })
                v208.Main:AddParagraph({
                    Title = "",
                    Content = ""
                })
                local vu375 = v208.Main:AddDropdown("SellItemsWhen", {
                    Title = "When to sell the items?",
                    Values = {
                        "Selected item is full in inventory. Sell all",
                        "Selected item is full in inventory. Sell one",
                        "Whenever",
                        "Never"
                    },
                    Description = "Controls on how to sell the wanted items (from \"items to sell\" dropdown) while farming.",
                    Multi = false,
                    Default = "Never"
                })
                local vu376 = v208.Main:AddToggle("BuyItemsToggle", {
                    Title = "Buy items",
                    Default = false,
                    Description = "Controls whether to buy the wanted items (from \"items to buy\" dropdown) while farming."
                })
                v208.Main:AddParagraph({
                    Title = "",
                    Content = ""
                })
                local vu377 = v208.Main:AddToggle("ItemSpawnNotifTogg", {
                    Title = "Item-Spawn Notifier",
                    Default = false
                })
                local vu378 = v208.Main:AddToggle("NotifOnlySelectedTogg", {
                    Title = "Notify only selected",
                    Description = "Notifications will only trigger for items selected in the \"item(s) to farm\" dropdown.",
                    Default = false
                })
                local vu379 = v208.Main:AddToggle("HopOnEmpty", {
                    Title = "Server hop on empty",
                    Description = "Switches servers if the item(s) selected were not found.",
                    Default = false
                })
                v208.Main:AddSection("Stand Farm", {})
                local vu380 = v208.Main:AddDropdown("StandSelectDropDowns", {
                    Title = "Choose a stand",
                    Values = {
                        "Whitesnake",
                        "White Album",
                        "King Crimson",
                        "The World",
                        "Star Platinum",
                        "Crazy Diamond",
                        "Gold Experience",
                        "Killer Queen",
                        "Magician\'s Red",
                        "Purple Haze",
                        "Sticky Fingers",
                        "Mr. President",
                        "Aerosmith",
                        "Cream",
                        "Beach Boy",
                        "Red Hot Chili Pepper",
                        "The Hand",
                        "Anubis",
                        "Stone Free",
                        "Six Pistols",
                        "Hermit Purple",
                        "Hierophant Green",
                        "Silver Chariot",
                        "Soft & Wet",
                        "The World Alternate Universe",
                        "Scary Monsters",
                        "Tusk ACT 1",
                        "D4C"
                    },
                    Multi = true,
                    Default = {}
                })
                local vu381 = v208.Main:AddToggle("StopOnShiny", {
                    Title = "Stop on any shiny",
                    Default = false
                })
                local vu382 = v208.Main:AddToggle("StandFarmTogg", {
                    Title = "Stand Farm",
                    Default = false
                })
                v208.Main:AddParagraph({
                    Title = "",
                    Content = ""
                })
                local vu383 = v208.Main:AddToggle("AutoMIH", {
                    Title = "Auto MIH",
                    Default = false
                })
                v208.Main:AddParagraph({
                    Title = "Requirements",
                    Content = "You need Whitesnake and Dio\'s Diary for Auto MIH"
                })
                v208.Main:AddSection("Pity Farm", {})
                local v385 = v208.Main:AddInput("Pity Wanted", {
                    Title = "Pity Wanted",
                    Description = "Insert the amount of pity you want",
                    Default = "",
                    Placeholder = "Input",
                    Numeric = false,
                    Finished = true,
                    Callback = function(p384)
                        if p384 or not tonumber(p384) then
                            if tonumber(p384) < 0 or tonumber(p384) > 10 then
                                vu28("Wrong input!", "The number has to be 1-10")
                            else
                                writefile("PityWanted.txt", tostring(p384))
                                vu144 = tonumber(p384)
                            end
                        else
                            vu28("Wrong input!", "Please insert a number 1-10")
                            return
                        end
                    end
                })
                if isfile("PityWanted.txt") then
                    v385:SetValue(tonumber(readfile("PityWanted.txt")))
                end
                local vu386 = v208.Main:AddToggle("PityFarmTogg", {
                    Title = "Pity Farm",
                    Default = false
                })
                local vu387 = v208.Main:AddToggle("DoubleTroubleTogg", {
                    Title = "Double Trouble",
                    Default = false
                })
                local vu388 = v208.Main:AddToggle("PityShowerTogg", {
                    Title = "Display pity info",
                    Default = false
                })
                local vu389 = v208.Main:AddToggle("HopModePity", {
                    Title = "Hop mode",
                    Default = false
                })
                v208.Main:AddSection("Level Farm", {})
                local vu390 = v208.Main:AddToggle("PrestigeFarmTogg", {
                    Title = "Prestige farm",
                    Default = false
                })
                local v391 = getrawmetatable(Vector3.new())
                local vu392 = v391.__index
                setreadonly(v391, false)
                function v391.__index(p393, p394)
                    return p394:lower() == "magnitude" and (getcallingscript() and getcallingscript().Name == "ItemSpawn") and 0 or vu392(p393, p394)
                end
                setreadonly(v391, true)
                local vu395 = nil
                vu395 = hookmetamethod(game, "__namecall", function(p396, ...)
                    return tostring(p396) == "Returner" and "  ___XP DE KEY" or vu395(p396, ...)
                end)
                local vu397 = vu273
                local vu398 = vu30
                local vu399 = vu28
                local vu400 = v374
                repeat
                    task.wait()
                    warn("WAITING FOR ALL ITEMS TO SPAWN")
                until workspace:FindFirstChild("ProximityPrompt")
                local v401, v402, v403 = pairs(workspace.Item_Spawns.Items:GetDescendants())
                while true do
                    local v404
                    v403, v404 = v401(v402, v403)
                    if v403 == nil then
                        break
                    end
                    v140(v404)
                end
                local v405 = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FunctionLibrary"))
                local vu406 = v405.pcall
                function v405.pcall(...)
                    if type(...) ~= "function" or # getupvalues(...) ~= 11 then
                        return vu406(...)
                    end
                end
                local function vu437(pu407, pu408, pu409, p410)
                    repeat
                        task.wait()
                    until not workspace:FindFirstChild("ProximityPrompt")
                    vu229()
                    local vu411 = {}
                    local function v421(p412)
                        local v413, v414, v415 = pairs(p412)
                        while true do
                            local v416
                            v415, v416 = v413(v414, v415)
                            if v415 == nil then
                                break
                            end
                            local v417 = vu207[v415]
                            local v418 = vu375.Value:find("Sell one")
                            local v419 = vu375.Value:find("Sell all")
                            local v420 = vu375.Value == "Whenever"
                            if v417 and # v417 > 0 then
                                if not vu125:is_full_of_item(v415) then
                                    return true
                                end
                                if vu125:is_full_of_item(v415) and (vu372.Value[v415] and (v418 or (v419 or v420))) then
                                    return true
                                end
                            end
                        end
                        return false
                    end
                    task.spawn(function()
                        while pu407 and vu400.Value or not pu407 and (pu408 and pu408() == false) do
                            task.wait()
                            vu411 = vu400.Value and table.clone(vu371.Value) or pu409
                        end
                    end)
                    local v422 = vu411
                    while pu407 and vu400.Value or not pu407 and (pu408 and pu408() == false) do
                        task.wait()
                        if not (pu407 and vu400.Value) and (pu407 or (not pu408 or pu408() == true)) then
                            return
                        end
                        if vu375.Value == "Whenever" then
                            vu125:sell_items(vu372.Value)
                        end
                        if vu376.Value then
                            vu125:buy_items(vu373.Value)
                        end
                        local v423, v424, v425 = pairs(v422)
                        while true do
                            local v426, _ = v423(v424, v425)
                            if v426 == nil then
                                break
                            end
                            local v427 = vu207[v426]
                            if v427 and # v427 ~= 0 then
                                local vu428 = v427[1]
                                local v429 = vu428.Parent
                                if v422[v426] and v429 then
                                    local v430
                                    if vu125:is_full_of_item(v426) then
                                        local v431 = vu375.Value:find("Sell one")
                                        local v432 = vu375.Value:find("Sell all")
                                        local v433 = vu372.Value[v426]
                                        if v431 and v433 then
                                            vu125:sell_item(v426, false)
                                            v430 = true
                                        elseif v432 and v433 then
                                            vu125:sell_item(v426, true)
                                            v430 = true
                                        else
                                            v430 = false
                                        end
                                    else
                                        v430 = true
                                    end
                                    if v430 then
                                        v425 = v426
                                        repeat
                                            local v434 = (vu125:get_rootpart().CFrame.p - v429:GetModelCFrame().p).Magnitude
                                            vu125:get_rootpart().CFrame = v429:GetModelCFrame()
                                            task.wait()
                                        until v434 <= 40 or not (pu407 and vu400.Value) and (pu407 or (not pu408 or pu408() == true))
                                        local v435 = vu125:get_ping()
                                        local v436 = math.clamp(v435 / 220, 0, 0.1)
                                        task.wait(0.181 + v436)
                                        if not (pu407 and vu400.Value) and (pu407 or (not pu408 or pu408() == true)) then
                                            return
                                        end
                                        if vu375.Value == "Whenever" then
                                            vu125:sell_items(vu372.Value)
                                        end
                                        if vu376.Value then
                                            vu125:buy_items(vu373.Value)
                                        end
                                        repeat
                                            pcall(function()
                                                vu428.RemoteEvent:FireServer()
                                            end)
                                            task.wait()
                                        until not (pu407 and vu400.Value) and (pu407 or (not pu408 or pu408() == true)) or not (v429:FindFirstChild("ProximityPrompt") and v422[v426])
                                    else
                                        v425 = v426
                                    end
                                    if not (pu407 and vu400.Value) and (pu407 or (not pu408 or pu408() == true)) then
                                        return
                                    end
                                    if vu375.Value == "Whenever" then
                                        vu125:sell_items(vu372.Value)
                                    end
                                    if vu376.Value then
                                        vu125:buy_items(vu373.Value)
                                    end
                                else
                                    v425 = v426
                                end
                            else
                                v425 = v426
                            end
                        end
                        if not v421(v422) and (vu379.Value or p410) then
                            task.wait(0.3)
                            vu397()
                            return
                        end
                    end
                end
                vu400:OnChanged(function(p438)
                    if p438 then
                        vu437(true)
                    end
                end)
                vu377:OnChanged(function(p439)
                    if p439 then
                        print("Not true")
                        getgenv().item_spawn_notify_connection = workspace.Item_Spawns.Items.ChildAdded:Connect(function(pu440)
                            if vu377.Value and not vu378.Value then
                                if pu440:IsA("Model") then
                                    vu399("Anitem has spawned!", pu440:WaitForChild("ProximityPrompt").ObjectText, 6, function()
                                        local v441 = pu440
                                        vu125:get_rootpart().CFrame = v441:GetModelCFrame()
                                    end)
                                end
                            elseif vu377.Value and (vu378.Value and (vu371.Value[vu34(pu440)] and pu440:IsA("Model"))) then
                                vu399("An item you wanted has spawned!", pu440:WaitForChild("ProximityPrompt").ObjectText, 6, function()
                                    local v442 = pu440
                                    vu125:get_rootpart().CFrame = v442:GetModelCFrame()
                                end)
                            end
                        end)
                    else
                        print("Disconnecty")
                        if getgenv().item_spawn_notify_connection and getgenv().item_spawn_notify_connection ~= "" then
                            getgenv().item_spawn_notify_connection:Disconnect()
                            getgenv().item_spawn_notify_connection = ""
                        end
                    end
                end)
                local vu443 = 60
                local vu444 = false
                vu382:OnChanged(function(_)
                    if vu382.Value then
                        if vu444 then
                            vu399("Already running. Please wait a bit", "", 5)
                            return
                        end
                        vu444 = true
                        if vu21.Value < 3 then
                            vu399("Not enough Levels", "At least 3 levels are needed in order to get stands.", 5)
                            vu444 = false
                            return
                        end
                        vu228()
                        local v445 = vu380.Value
                        if not next(v445) then
                            vu399("Empty", "Please select a stand from the list in order to start.", 6)
                            vu444 = false
                            return
                        end
                        if v445["Soft & Wet"] or (v445.D4C or (v445["The World Alternate Universe"] or (v445["Scary Monsters"] or v445["Tusk ACT 1"]))) then
                            vu230()
                            if v445[vu124.Value] then
                                vu399("Existing!", "You already have the specified stand!", 7)
                                vu444 = false
                                return
                            end
                            if vu21.Value < 6 then
                                vu399("Not enough Levels", "At least 6 levels are needed in order to get rib stands.", 5)
                                vu444 = false
                                return
                            end
                            while vu382.Value and task.wait() do
                                if not vu382 then
                                    vu444 = false
                                    return
                                end
                                if vu125.ribs_count == 0 then
                                    vu399("No more items!", "You don\'t have enough ribs.", 7)
                                    vu444 = false
                                    return
                                end
                                if vu146() then
                                    vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                                end
                                vu125:learn_skill("Worthiness ", "Character")
                                vu398(vu123, "Dialogue2", "Option1")
                                if vu125:get_character():WaitForChild("StandMorph"):WaitForChild("StandSkin").Value ~= "" and vu381.Value then
                                    vu125:notify_shiny()
                                    vu444 = false
                                    return
                                end
                                if not vu382 then
                                    vu444 = false
                                    return
                                end
                                if v445[vu124.Value] then
                                    vu125:notify_stand()
                                    vu444 = false
                                    return
                                end
                            end
                        else
                            if not vu146() and vu124.Value ~= "None" then
                                repeat
                                    task.wait()
                                    vu231()
                                    vu443 = vu443 - 1
                                    print(vu443)
                                    print("Nal")
                                until vu146() ~= nil or (vu443 <= 0 or not vu382.Value)
                                if not vu382.Value then
                                    vu444 = false
                                    return
                                end
                                if not vu146() then
                                    print("Stand cannot be equipped bug")
                                    vu125:get_character().Humanoid.Health = 0
                                    vu125:wait_until_new_char()
                                    if not vu382.Value then
                                        vu444 = false
                                        return
                                    end
                                    vu228()
                                end
                            end
                            while vu382.Value and task.wait() do
                                if not vu382 then
                                    vu444 = false
                                    return
                                end
                                if vu124.Value == "None" then
                                    vu125:learn_skill("Worthiness", "Character")
                                    if not vu382.Value then
                                        vu444 = false
                                        return
                                    end
                                    if not vu241("Mysterious Arrow") then
                                        vu444 = false
                                        return
                                    end
                                    repeat
                                        task.wait()
                                    until vu124.Value ~= "None"
                                    if not vu382.Value then
                                        vu444 = false
                                        return
                                    end
                                end
                                vu443 = 70
                                if not vu146() then
                                    repeat
                                        task.wait()
                                        vu443 = vu443 - 1
                                        print(vu443)
                                        print("Nal")
                                        vu231()
                                    until vu146() ~= nil or (vu443 <= 0 or not vu382.Value)
                                    if not vu382.Value then
                                        vu444 = false
                                        return
                                    end
                                    if not vu146() then
                                        print("Stand cannot be equipped bug")
                                        vu125:get_character().Humanoid.Health = 0
                                        vu125:wait_until_new_char()
                                        if not vu382.Value then
                                            vu444 = false
                                            return
                                        end
                                        vu228()
                                    end
                                end
                                repeat
                                    task.wait()
                                    vu230()
                                until vu125:get_character():FindFirstChild("StandMorph")
                                if vu125:get_character():WaitForChild("StandMorph"):WaitForChild("StandSkin").Value ~= "" and vu381.Value then
                                    vu125:notify_shiny()
                                    vu444 = false
                                    return
                                end
                                if v445[vu124.Value] then
                                    vu125:notify_stand()
                                    vu444 = false
                                    return
                                end
                                if not vu382.Value then
                                    vu444 = false
                                    return
                                end
                                if not vu241("Rokakaka") then
                                    vu444 = false
                                    return
                                end
                                repeat
                                    task.wait()
                                until vu124.Value == "None"
                                vu125:wait_until_new_char()
                                if not vu382.Value then
                                    vu444 = false
                                    return
                                end
                                vu228()
                            end
                        end
                    end
                end)
                local function vu451(pu446, p447, p448)
                    print("Started to farm")
                    local vu449 = workspace.Living:FindFirstChild(pu446)
                    vu125:get_rootpart().CFrame = vu449.HumanoidRootPart.CFrame
                    task.wait(0.35)
                    local vu450 = true
                    vu20.HUD.Main.DropMoney.Money.ChildAdded:Connect(function()
                        print("Dead npc")
                        vu450 = false
                        if workspace.Living:FindFirstChild(pu446) then
                            pcall(function()
                                if getgenv().DisplayHealth then
                                    print(vu449.Health.Value)
                                end
                                vu125:get_rootpart().CFrame = workspace.Living[pu446].HumanoidRootPart.CFrame
                                if vu449.Name ~= "Heaven Ascension Dio" and vu449.Name ~= "Jotaro Kujo" then
                                    vu449:Destroy()
                                    task.wait(0.35)
                                    vu450 = true
                                end
                                if vu449.Name == "Vampire" and vu449.Health.Value <= 0 then
                                    vu125:get_rootpart().CFrame = vu449.HumanoidRootPart.CFrame
                                    vu449:Destroy()
                                    vu450 = true
                                    wait(0.25)
                                end
                            end)
                        end
                    end)
                    while vu450 and vu383.Value == true do
                        task.wait()
                        if vu450 then
                            if vu125:get_character():FindFirstChild("StandMorph") == nil then
                                repeat
                                    wait()
                                    vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                                until vu125:get_character():FindFirstChild("StandMorph")
                            end
                            vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                Input = Enum.KeyCode.T
                            })
                            vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                Input = Enum.KeyCode.T
                            })
                            vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                Input = Enum.KeyCode.Y
                            })
                            vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                Input = Enum.KeyCode.Y
                            })
                            vu125:get_character().RemoteEvent:FireServer("Attack", "m1")
                            vu125:get_character().StandMorph.HumanoidRootPart.CFrame = CFrame.lookAt(vu449.HumanoidRootPart.Position, vu449.Head.Position)
                            vu125:get_rootpart().CFrame = vu449.HumanoidRootPart.CFrame - vu449.HumanoidRootPart.CFrame.lookVector * 2 + Vector3.new(0, p448, p447)
                        end
                    end
                end
                vu383:OnChanged(function(p452)
                    if p452 == true then
                        while vu383.Value == true do
                            task.wait()
                            local function vu453()
                                if vu124.Value == "Whitesnake" and vu122:FindFirstChild("Green Baby") == nil then
                                    if not vu125:get_character():FindFirstChild("StandMorph") then
                                        repeat
                                            wait()
                                            vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                                        until vu125:get_character():FindFirstChild("StandMorph")
                                    end
                                    print("WEAE")
                                    vu236()
                                    vu237()
                                    vu20:WaitForChild("HUD")
                                    if vu125:get_quests()["Defeat 30 Thugs (Dio\'s Plan)"] then
                                        print("THUG")
                                        repeat
                                            task.wait()
                                            vu451("Thug", 0, 20)
                                        until vu125:get_quests()["Defeat 30 Thugs (Dio\'s Plan)"] == nil or vu383.Value == false
                                        if vu383.Value == false then
                                            return
                                        end
                                        task.wait(0.35)
                                        vu453()
                                    end
                                    if vu125:get_quests()["Defeat 25 Alpha Thugs (Dio\'s Plan)"] then
                                        print("ALPHA THUG")
                                        repeat
                                            task.wait()
                                            vu451("Alpha Thug", 0, 20)
                                        until vu125:get_quests()["Defeat 25 Alpha Thugs (Dio\'s Plan)"] == nil or vu383.Value == false
                                        if vu383.Value == false then
                                            return
                                        end
                                        task.wait(0.35)
                                        vu453()
                                    end
                                    if vu125:get_quests()["Defeat 20 Corrupt Police (Dio\'s Plan)"] then
                                        print("CORRUPT POLICE")
                                        repeat
                                            task.wait()
                                            vu451("Corrupt Police", 0, 20)
                                        until not (vu125:get_quests()["Defeat 20 Corrupt Police (Dio\'s Plan)"] and vu383.Value)
                                        if vu383.Value == false then
                                            return
                                        end
                                        task.wait(0.4)
                                        vu453()
                                    end
                                    if vu125:get_quests()["Defeat 15 Zombie Henchman (Dio\'s Plan)"] then
                                        print("ZOMBIE")
                                        repeat
                                            task.wait()
                                            vu451("Zombie Henchman", 0, 13)
                                        until not (vu125:get_quests()["Defeat 15 Zombie Henchman (Dio\'s Plan)"] and vu383.Value)
                                        if vu383.Value == false then
                                            return
                                        end
                                        task.wait(0.4)
                                        vu453()
                                        task.wait(0.5)
                                        vu125:get_character().Head:Destroy()
                                    end
                                    task.wait(2)
                                    if vu125:get_quests()["Defeat 10 Vampires (Dio\'s Plan)"] then
                                        print("VAMPIRE")
                                        repeat
                                            task.wait()
                                            vu451("Vampire", 0, 14)
                                        until not (vu125:get_quests()["Defeat 10 Vampires (Dio\'s Plan)"] and vu383.Value)
                                        if vu383.Value == false then
                                            return
                                        end
                                        vu228()
                                        task.wait(0.4)
                                        vu228()
                                        task.wait(0.4)
                                        vu453()
                                        task.wait(0.4)
                                    end
                                end
                                if vu122:FindFirstChild("Green Baby") then
                                    workspace.Living:WaitForChild(vu19.Name).RemoteFunction:InvokeServer("LearnSkill", {
                                        Skill = "Worthiness",
                                        SkillTreeType = "Character"
                                    })
                                    vu125:get_character().Humanoid:EquipTool(vu122["Green Baby"])
                                    task.wait(0.5)
                                    vu125:get_character()["Green Baby"]:Activate()
                                    firesignal(vu19.PlayerGui:WaitForChild("DialogueGui"):WaitForChild("Frame"):WaitForChild("ClickContinue").MouseButton1Click)
                                    task.wait(0.25)
                                    firesignal(vu19.PlayerGui:WaitForChild("DialogueGui"):WaitForChild("Frame"):WaitForChild("Options"):WaitForChild("Option1"):WaitForChild("TextButton").MouseButton1Click)
                                    task.wait(0.1)
                                    vu453()
                                    vu236()
                                    vu237()
                                    workspace.Living:WaitForChild(vu19.Name).RemoteFunction:InvokeServer("LearnSkill", {
                                        Skill = "Vitality X",
                                        SkillTreeType = "Character"
                                    })
                                    workspace.Living:WaitForChild(vu19.Name).RemoteFunction:InvokeServer("LearnSkill", {
                                        Skill = "Sturdiness III",
                                        SkillTreeType = "Character"
                                    })
                                    workspace.Living[vu19.Name].RemoteFunction:InvokeServer("LearnSkill", {
                                        Skill = "Uppercut to The Moon",
                                        SkillTreeType = "Stand"
                                    })
                                    workspace.Living[vu19.Name].RemoteFunction:InvokeServer("LearnSkill", {
                                        Skill = "Surface Inversion Punch",
                                        SkillTreeType = "Stand"
                                    })
                                    task.wait(0.4)
                                end
                            end
                            local function vu454()
                                if not vu122:FindFirstChild("Dio\'s Bone") and (vu124.Value == "C-Moon" and vu122:FindFirstChild("Dio\'s Bone") == nil or vu383.Value == false) then
                                    if vu383.Value == false then
                                        return
                                    end
                                    local _ = workspace.Living:FindFirstChild("Heaven Ascension Dio") ~= nil
                                    repeat
                                        wait()
                                    until workspace.Living:FindFirstChild("Heaven Ascension Dio")
                                    repeat
                                        task.wait()
                                        vu451("Heaven Ascension Dio", 2, 45)
                                    until vu122:FindFirstChild("Dio\'s Bone") or workspace.Living["Heaven Ascension Dio"].Health.Value == 0
                                    if workspace.Living["Heaven Ascension Dio"].Health.Value == 0 then
                                        if vu383.Value == false then
                                            return
                                        end
                                        print("bokai")
                                        vu228()
                                        workspace.Living["Heaven Ascension Dio"]:Destroy()
                                        print("Destroyed nig")
                                        vu125:get_character():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                                        workspace.Living:WaitForChild("Heaven Ascension Dio")
                                        vu454()
                                        task.wait(0.4)
                                        if vu122:FindFirstChild("Dio\'s Bone") then
                                            vu237()
                                            vu236()
                                            print(",abe")
                                        end
                                    end
                                end
                            end
                            local function vu456()
                                if vu124.Value == "C-Moon" and (vu122:FindFirstChild("Dio\'s Bone") and vu122:FindFirstChild("Jotaro\'s Disc") == nil) then
                                    vu237()
                                    if workspace.Living:FindFirstChild("Jotaro Kujo") == nil then
                                        print("no jotaro")
                                        if vu383.Value == false then
                                            return
                                        end
                                    end
                                    workspace.Living:WaitForChild("Jotaro Kujo")
                                    workspace.Living["Jotaro Kujo"].HumanoidRootPart.ChildAdded:Connect(function(p455)
                                        if p455.Name == "Sound" and (p455.SoundId == "rbxassetid://6032844827" or p455.SoundId == "rbxassetid://4725629903") then
                                            vu125:get_character():WaitForChild("RemoteEvent"):FireServer("StartBlocking")
                                            wait(1.6)
                                            vu125:get_character():WaitForChild("RemoteEvent"):FireServer("StopBlocking")
                                        end
                                    end)
                                    repeat
                                        task.wait()
                                        vu451("Jotaro Kujo", 2, 45)
                                    until vu122:FindFirstChild("Jotaro\'s Disc") or (workspace.Living["Jotaro Kujo"].Health.Value == 0 or vu383.Value == false)
                                    if vu383.Value == false then
                                        return
                                    end
                                    task.wait(0.4)
                                    if workspace.Living["Jotaro Kujo"].Health.Value ~= 0 or vu122:FindFirstChild("Jotaro\'s Disc") ~= nil then
                                        if vu122:FindFirstChild("Jotaro\'s Disc") then
                                            if vu383.Value == false then
                                                return
                                            end
                                            task.wait(0.5)
                                            game:GetService("ReplicatedStorage").Sounds.HeavenBass:Destroy()
                                            game:GetService("ReplicatedStorage").Sounds.HeavenBass2:Destroy()
                                            task.wait(0.4)
                                            vu236()
                                            vu456()
                                            vu237()
                                            vu454()
                                            task.wait(0.4)
                                            while vu124.Value == "C-Moon" do
                                                task.wait()
                                                if vu383.Value == false then
                                                    return
                                                end
                                                vu125:get_rootpart().CFrame = CFrame.new(- 239.357712, 370.272675, 351.081848, - 1, 0, 0, 0, 1, 0, 0, 0, - 1)
                                                task.wait(0.25)
                                                if vu383.Value == false then
                                                    return
                                                end
                                                game:GetService("ReplicatedStorage").Sounds.HeavenBass3:Play()
                                                game:GetService("ReplicatedStorage").Sounds.HeavenBass3:Play()
                                                game:GetService("ReplicatedStorage").Sounds["Double Accel"]:Play()
                                                wait()
                                                workspace.Living:WaitForChild(vu19.Name).RemoteFunction:InvokeServer("ToggleStand", "Toggle")
                                                if vu124.Value ~= "Made in Heaven" then
                                                    break
                                                end
                                            end
                                        end
                                    else
                                        if vu383.Value == false then
                                            return
                                        end
                                        vu228()
                                        task.wait(0.4)
                                        workspace.Living["Jotaro Kujo"]:Destroy()
                                        print("destroied jotra")
                                        workspace.Living:WaitForChild("Jotaro Kujo")
                                        task.wait(0.4)
                                        vu456()
                                        task.wait(0)
                                    end
                                end
                            end
                            vu453()
                            local v457 = vu454
                            local v458 = vu456
                            repeat
                                task.wait()
                            until vu124.Value == "C-Moon"
                            if vu122:FindFirstChild("Dio\'s Bone") == nil then
                                vu237()
                                v457()
                            end
                            repeat
                                task.wait()
                            until vu122:FindFirstChild("Dio\'s Bone")
                            vu237()
                            v458()
                        end
                    end
                end)
                local vu459 = true
                local vu460 = 680
                local vu461 = false
                local vu462 = false
                local vu463 = false
                local vu464 = false
                vu386:OnChanged(function(p465)
                    if p465 then
                        if not vu459 then
                            vu399("Not finished yet!", "Wait for pity farm to finish current tasks before turning back on.", 10)
                            return
                        end
                        if not vu144 then
                            vu399("Value not found!", "Didn\'t find \"Pity Wanted\". Please insert a valid Pity Number", 5)
                            return
                        end
                        if vu144 <= vu232() then
                            vu399("Invalid pity inserted", "Your wanted pity cannot be smaller than your current pity", 10)
                            vu386:SetValue(false)
                            return
                        end
                        vu228()
                        task.wait(1)
                        vu461 = false
                        vu462 = false
                        vu463 = false
                        vu464 = false
                        local vu466 = false
                        task.spawn(function()
                            while vu386.Value do
                                task.wait()
                                if vu387.Value and not vu464 then
                                    local v467 = false
                                    vu145 = vu144 / 2
                                    if vu145 <= vu232() then
                                        vu387:SetValue(false)
                                        v467 = true
                                    end
                                    if not (v467 or vu125:get_bp_item("Mysterious Arrow")) then
                                        if not vu462 then
                                            warn("no arrows")
                                            vu399("Not enough items!", "You don\'t have enough Mysterious Arrows", 5)
                                        end
                                        vu462 = true
                                        vu459 = true
                                        vu466 = false
                                        v467 = true
                                    end
                                    if not (v467 or vu125:get_bp_item("Rokakaka")) then
                                        if not vu463 then
                                            warn("no rokas")
                                            vu399("Not enough items!", "You don\'t have enough Rokakakas", 5)
                                        end
                                        vu463 = true
                                        vu459 = true
                                        vu466 = false
                                    end
                                    if not (vu462 or vu463) then
                                        repeat
                                            task.wait()
                                            print("[DTROUBLE] waiting for rib pity farm to finish task")
                                        until vu459 or not vu386.Value
                                        if not vu386.Value then
                                            return
                                        end
                                        vu466 = false
                                        print("FARMING DOUBLE TROUBLE")
                                        vu125:learn_skill("Worthiness", "Character")
                                        if vu124.Value ~= "None" then
                                            vu466 = true
                                            vu459 = false
                                            vu241("Rokakaka")
                                            repeat
                                                task.wait()
                                            until vu124.Value == "None" or not vu386.Value
                                            vu466 = false
                                            vu459 = true
                                            task.wait(0.001)
                                            if vu387.Value and vu386.Value then
                                                vu125:wait_until_new_char()
                                                vu228()
                                            end
                                        else
                                            vu466 = true
                                            vu459 = false
                                            vu241("Mysterious Arrow")
                                            repeat
                                                task.wait()
                                            until vu124.Value ~= "None" or not vu386.Value
                                            vu466 = false
                                            vu459 = true
                                            task.wait(0.001)
                                            if vu387.Value and vu386.Value then
                                                if vu232() >= vu145 then
                                                    print("ez completed half")
                                                else
                                                    vu466 = true
                                                    vu459 = false
                                                    vu241("Rokakaka")
                                                    repeat
                                                        task.wait()
                                                    until vu124.Value == "None" or not vu386.Value
                                                    vu466 = false
                                                    vu459 = true
                                                    task.wait(0.001)
                                                    if vu387.Value and vu386.Value then
                                                        vu125:wait_until_new_char()
                                                        vu228()
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        task.spawn(function()
                            while vu386.Value do
                                task.wait()
                                local v468 = (vu387.Value or vu464) and true or false
                                if not (v468 or vu125:get_bp_item(vu123)) then
                                    if not vu461 then
                                        vu399("Not enough items!", "You don\'t have enough ribs.", 5)
                                    end
                                    vu461 = true
                                    vu459 = true
                                    v468 = true
                                end
                                if not v468 and vu466 then
                                    repeat
                                        task.wait()
                                        print("d_trouble_waiting_guard wait")
                                    until not vu466 or (not vu386.Value or vu387.Value)
                                    vu459 = true
                                end
                                local v469 = not v468 and (vu387.Value or not vu386.Value) and true or v468
                                if not v469 then
                                    print("FARMING REGULAR PITY")
                                    vu228()
                                    if not vu125:get_bp_item(vu123) then
                                        if not vu461 then
                                            vu399("Not enough items!", "You don\'t have enough ribs.", 5)
                                        end
                                        vu461 = true
                                        vu459 = true
                                        v469 = true
                                    end
                                end
                                if not v469 then
                                    vu459 = false
                                    repeat
                                        task.wait(0.15)
                                        vu125:learn_skill("Worthiness", "Character")
                                        vu398(vu123, "Dialogue2", "Option1")
                                        vu229()
                                    until not vu146()
                                    if not vu125:get_bp_item(vu123) then
                                        if not vu461 then
                                            vu399("Not enough items!", "You don\'t have enough ribs.", 5)
                                        end
                                        vu461 = true
                                        vu459 = true
                                        v469 = true
                                    end
                                end
                                if not v469 then
                                    repeat
                                        task.wait(0.015)
                                        task.spawn(vu230)
                                        vu460 = vu460 - 1
                                        print(vu460)
                                        print("bug coming?", vu460)
                                    until vu146() ~= nil or (vu460 <= 0 or not vu386.Value)
                                    vu460 = 680
                                    vu459 = true
                                    v469 = (vu387.Value or not vu386.Value) and true or v469
                                end
                                if not (v469 or vu146()) then
                                    print("yeah, the bug came")
                                    vu125:get_character().Humanoid.Health = 0
                                    vu125:wait_until_new_char()
                                    vu228()
                                    vu230()
                                end
                                vu459 = true
                                if (v469 or not vu387.Value and vu386.Value) and not v469 and vu144 <= vu232() then
                                    print("Done")
                                    vu386:SetValue(false)
                                    return
                                end
                                task.wait(0.02)
                            end
                        end)
                        task.spawn(function()
                            local function v470()
                                return vu125:is_full_of_item("Mysterious Arrow")
                            end
                            while task.wait() do
                                local v471 = not vu389.Value
                                local v472 = not (v471 or vu462) and true or v471
                                if (v472 or not vu464) and not v472 then
                                    print("Toggled on to farm for marrows")
                                    vu464 = true
                                    vu437(false, v470, {
                                        Rokakaka = true,
                                        ["Mysterious Arrow"] = true
                                    }, true)
                                end
                            end
                        end)
                        task.spawn(function()
                            local function v473()
                                return vu125:is_full_of_item("Rokakaka")
                            end
                            while task.wait() do
                                local v474 = not vu389.Value
                                local v475 = not (v474 or vu463) and true or v474
                                if (v475 or not vu464) and not v475 then
                                    print("Toggled on to farm for rokas")
                                    vu464 = true
                                    vu437(false, v473, {
                                        Rokakaka = true,
                                        ["Mysterious Arrow"] = true
                                    }, true)
                                end
                            end
                        end)
                        task.spawn(function()
                            local function v476()
                                return vu125:is_full_of_item(vu123)
                            end
                            while task.wait() do
                                local v477 = not vu389.Value
                                local v478 = not (v477 or vu461) and true or v477
                                if (v478 or not vu464) and not v478 then
                                    print("Toggled on to farm for ribs")
                                    vu464 = true
                                    vu437(false, v476, {
                                        [vu123] = true
                                    }, true)
                                end
                            end
                        end)
                    end
                end)
                vu387:OnChanged(function(p479)
                    if p479 == true then
                        if vu145 ~= nil then
                            vu304.Text = "HalfPity Wanted: " .. vu145
                        end
                        vu306.Text = "DTrouble: True"
                    else
                        vu306.Text = "DTrouble: False"
                    end
                end)
                vu388:OnChanged(function(p480)
                    if p480 then
                        vu363()
                        while vu388.Value and task.wait() do
                            vu303.Text = "Current Pity: " .. vu370(vu232())
                            if vu144 then
                                vu302.Text = "Pity Wanted: " .. vu144
                            end
                            if vu387.Value and (vu386.Value and vu145) then
                                vu304.Text = "HalfPity Wanted: " .. vu145
                            end
                            if vu386.Value then
                                vu305.Text = "Pity Farm: True"
                            else
                                vu305.Text = "Pity Farm: False"
                            end
                        end
                    else
                        vu364()
                    end
                end)
                local function vu486()
                    local v481, v482, v483 = pairs(vu19.StandSkillTree:GetChildren())
                    while true do
                        local v484
                        v483, v484 = v481(v482, v483)
                        if v483 == nil then
                            break
                        end
                        if not v484.Value then
                            vu125:learn_skill(v484.Name, "Stand")
                        end
                    end
                    local v485 = vu125:get_character().RemoteFunction:InvokeServer("ReturnSkillInfoInTree", {
                        Type = "Stand",
                        Skills = {
                            [19] = "Inhale"
                        }
                    })
                    if v485 and v485.Inhale.AssignedKey ~= "L" then
                        vu125:get_character().RemoteFunction:InvokeServer("AssignSkillKey", {
                            Type = "Stand",
                            Key = "Enum.KeyCode.L",
                            Skill = "Inhale"
                        })
                    end
                    vu125:learn_skill("Hamon Breathing", "Spec")
                    vu125:learn_skill("Lung Capacity I", "Spec")
                    vu125:learn_skill("Lung Capacity II", "Spec")
                    vu125:learn_skill("Lung Capacity III", "Spec")
                    vu125:learn_skill("Breathing Technique I", "Spec")
                    vu125:learn_skill("Breathing Technique II", "Spec")
                    vu125:learn_skill("Breathing Technique III", "Spec")
                    vu125:learn_skill("Lung Capacity IV", "Spec")
                    vu125:learn_skill("Lung Capacity V", "Spec")
                    vu125:learn_skill("Breathing Technique IV", "Spec")
                    vu125:learn_skill("Breathing Technique V", "Spec")
                end
                local function vu489()
                    local v487 = {
                        Storyline = {
                            "#1",
                            "#1",
                            "#1",
                            "#2",
                            "#3",
                            "#3",
                            "#3",
                            "#4",
                            "#5",
                            "#6",
                            "#7",
                            "#8",
                            "#9",
                            "#10",
                            "#11",
                            "#11",
                            "#12",
                            "#14"
                        },
                        Dialogue = {
                            "Dialogue2",
                            "Dialogue6",
                            "Dialogue6",
                            "Dialogue3",
                            "Dialogue3",
                            "Dialogue3",
                            "Dialogue6",
                            "Dialogue3",
                            "Dialogue5",
                            "Dialogue5",
                            "Dialogue5",
                            "Dialogue4",
                            "Dialogue7",
                            "Dialogue6",
                            "Dialogue8",
                            "Dialogue11",
                            "Dialogue3",
                            "Dialogue2"
                        }
                    }
                    for v488 = 1, 18 do
                        vu398("Storyline " .. v487.Storyline[v488], v487.Dialogue[v488], "Option1")
                    end
                end
                local function vu493()
                    if vu24.Value >= 1 and not vu125:get_character():FindFirstChild("Hamon") then
                        print("[TRY_GET_HAMON] cp1")
                        pcall(function()
                            vu228()
                            vu125:get_rootpart().CFrame = CFrame.new(435, 9, - 285)
                            repeat
                                task.wait(0.05)
                                fireproximityprompt(vu15["Lisa Lisa"]:WaitForChild("ProximityPrompt"))
                            until vu20:FindFirstChild("DialogueGui")
                        end)
                        print("[TRY_GET_HAMON] cp2")
                        vu228()
                        repeat
                            task.wait(0.25)
                            local v491, v492 = pcall(function()
                                if vu122:FindFirstChild("Caesar\'s Headband") and not vu125:get_character():FindFirstChild("Caesar\'s Headband") then
                                    local v490 = vu125
                                    vu122["Caesar\'s Headband"].Parent = v490:get_character()
                                end
                                vu228()
                                firesignal(vu20.DialogueGui.Frame.ClickContinue.MouseButton1Click)
                                firesignal(vu20.DialogueGui.Frame.Options.Option1.TextButton.MouseButton1Click)
                                task.wait()
                                vu228()
                                fireproximityprompt(vu15["Lisa Lisa"]:WaitForChild("ProximityPrompt"))
                                firesignal(vu20.DialogueGui.Frame.ClickContinue.MouseButton1Click)
                                firesignal(vu20.DialogueGui.Frame.Options.Option1.TextButton.MouseButton1Click)
                                vu228()
                                task.wait()
                                fireproximityprompt(vu15["Lisa Lisa"]:WaitForChild("ProximityPrompt"))
                                firesignal(vu20.DialogueGui.Frame.ClickContinue.MouseButton1Click)
                                firesignal(vu20.DialogueGui.Frame.Options.Option1.TextButton.MouseButton1Click)
                                vu228()
                                task.wait()
                                fireproximityprompt(vu15["Lisa Lisa"]:WaitForChild("ProximityPrompt"))
                                firesignal(vu20.DialogueGui.Frame.ClickContinue.MouseButton1Click)
                                firesignal(vu20.DialogueGui.Frame.Options.Option1.TextButton.MouseButton1Click)
                                vu228()
                            end)
                            print(v491, v492)
                        until vu125:get_character():FindFirstChild("Hamon")
                        if vu125:get_character():FindFirstChild("Caesar\'s Headband") then
                            vu125:get_character():FindFirstChild("Caesar\'s Headband").Parent = vu122
                        end
                        vu125:learn_skill("Hamon Breathing", "Spec")
                        task.wait()
                        vu125:get_character().Humanoid.Health = 0.1
                        task.wait()
                        vu125:get_character().Humanoid.Health = 0
                        vu125:wait_until_new_char()
                        task.wait(1)
                        vu228()
                        print("done")
                    end
                end
                local function vu494()
                    if string.find(vu19.PlayerStats.Spec.Value, "Hamon") then
                        pcall(function()
                            if vu125:get_character().Hamon.Value <= tonumber(vu190.Value) and (vu125:get_character().Hamon.Value <= tonumber(vu189.Value) and vu125:has_spec_skill("Hamon Breathing")) then
                                vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                    Input = Enum.KeyCode.G
                                })
                                repeat
                                    task.wait()
                                    vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                        Input = Enum.KeyCode.G
                                    })
                                until vu125:get_character().Hamon.Value >= tonumber(vu190.Value) or not vu390.Value
                                vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                    Input = Enum.KeyCode.G
                                })
                                vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                    Input = Enum.KeyCode.G
                                })
                            end
                        end)
                    end
                end
                local function vu522(pu495, p496, p497)
                    print("NPCKILL called")
                    local vu498 = nil
                    local vu499 = nil
                    local vu500 = false
                    task.spawn(function()
                        vu486()
                        print("[NPCKILL] cp2")
                    end)
                    local v505, v506 = pcall(function()
                        task.wait(0.4)
                        local v501, v502, v503 = pairs(workspace.Living:GetChildren())
                        if v504.Name == pu495 and (v504:FindFirstChild("HumanoidRootPart") and (v504:FindFirstChild("Health") and v504.Health.Value > 0)) then
                            vu498 = v504
                        end
                        local v504
                        v503, v504 = v501(v502, v503)
                        if v503 ~= nil then
                        else
                        end
                        if vu498 then
                            vu499 = vu498.Health.Value
                            return
                        end
                    end)
                    print("[NPCKILL] cp3", vu498, vu499, v505, v506)
                    local vu507 = vu498.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                        vu368.Text = "NPC Health: " .. tostring(vu370(vu498.Humanoid.Health))
                    end)
                    local vu508 = nil
                    vu508 = vu19.PlayerStats.Experience:GetPropertyChangedSignal("Value"):Connect(function()
                        vu368.Text = "N/A"
                        vu507:Disconnect()
                        vu508:Disconnect()
                        vu500 = true
                        print("Dead")
                    end)
                    if vu390.Value then
                        local v509 = vu499
                        local v510 = vu500
                        local vu511 = vu498
                        local v512 = vu508
                        local v513 = vu507
                        while vu390.Value and task.wait() do
                            if not vu511 or (not vu511:FindFirstChild("HumanoidRootPart") or vu511.Health.Value <= 0 and not v510) then
                                vu125:get_rootpart().Anchored = true
                                local v514 = 200
                                repeat
                                    task.wait()
                                    print("Counting down")
                                    v514 = v514 - 1
                                until v514 <= 0 or v510
                                print("got it")
                                v512:Disconnect()
                                v513:Disconnect()
                                vu125:get_rootpart().Anchored = false
                                return true
                            end
                            if v510 then
                                return true
                            end
                            if vu124.Value == "None" then
                                vu125:get_rootpart().CFrame = vu511.HumanoidRootPart.CFrame - vu511.HumanoidRootPart.CFrame.lookVector + Vector3.new(0, 5.2, 0)
                                local v515 = vu125
                                vu125:get_rootpart().CFrame = CFrame.lookAt(v515:get_rootpart().Position, vu511.HumanoidRootPart.Position)
                            else
                                if vu191.Value ~= false then
                                    vu125:get_rootpart().CFrame = vu511.HumanoidRootPart.CFrame - vu511.HumanoidRootPart.CFrame.lookVector * p496 + Vector3.new(0, - 25, 0)
                                    local v516 = vu125
                                    vu125:get_rootpart().CFrame = CFrame.lookAt(v516:get_rootpart().Position, vu511.HumanoidRootPart.Position)
                                else
                                    vu125:get_rootpart().CFrame = vu511.HumanoidRootPart.CFrame - vu511.HumanoidRootPart.CFrame.lookVector * p496 + Vector3.new(0, 16.4, 0)
                                    local v517 = vu125
                                    vu125:get_rootpart().CFrame = CFrame.lookAt(v517:get_rootpart().Position, vu511.HumanoidRootPart.Position)
                                end
                                if vu125:get_character():FindFirstChild("SummonedStand").Value then
                                    pcall(function()
                                        vu125:get_character().StandMorph.HumanoidRootPart.CFrame = CFrame.lookAt(vu511.Head.Position + Vector3.new(0, 1.67, 0), vu511.HumanoidRootPart.Position)
                                    end)
                                else
                                    vu125:get_character().RemoteFunction:InvokeServer("ToggleStand", "Toggle")
                                end
                            end
                            if p497 then
                                if not vu511:FindFirstChild("RagdollParts") and vu124.Value ~= "None" then
                                    if vu196.Value == true then
                                        local v518 = vu125:get_character().StandSkills["Enum.KeyCode.H"].Value
                                        if not vu20:WaitForChild("HUD"):WaitForChild("Cooldowns"):WaitForChild("Frame"):FindFirstChild(v518) and vu19.StandSkillTree[v518].Value and vu125:get_character():FindFirstChild("Stand Barraging") == nil then
                                            vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                                Input = Enum.KeyCode.H
                                            })
                                        end
                                    end
                                    if vu192.Value == true then
                                        if vu20:WaitForChild("HUD"):WaitForChild("Cooldowns"):WaitForChild("Frame"):FindFirstChild("Stand Barrage") ~= nil or (vu511:FindFirstChild("RagdollParts") or vu511:WaitForChild("Health").Value <= v509 * 0.45) then
                                            vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                                Input = Enum.KeyCode.E
                                            })
                                        else
                                            vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                                Input = Enum.KeyCode.E
                                            })
                                        end
                                    end
                                    if vu193.Value == true then
                                        local v519 = vu125:get_character().StandSkills["Enum.KeyCode.T"].Value
                                        if vu20:WaitForChild("HUD"):WaitForChild("Cooldowns"):WaitForChild("Frame"):FindFirstChild(v519) == nil and vu19.StandSkillTree[v519].Value and (not vu125:get_character():FindFirstChild("Stand Barraging") and (vu511:WaitForChild("Health").Value > v509 * 0.4 and not vu511:FindFirstChild("RagdollParts"))) then
                                            vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                                Input = Enum.KeyCode.T
                                            })
                                            vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                                Input = Enum.KeyCode.T
                                            })
                                        end
                                    end
                                    if vu194.Value == true then
                                        local v520 = vu125:get_character().StandSkills["Enum.KeyCode.Y"].Value
                                        if not vu20:WaitForChild("HUD"):WaitForChild("Cooldowns"):WaitForChild("Frame"):FindFirstChild(v520) and vu19.StandSkillTree[v520].Value and (not vu125:get_character():FindFirstChild("Stand Barraging") and vu511:WaitForChild("Health").Value > v509 * 0.4) then
                                            vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                                Input = Enum.KeyCode.Y
                                            })
                                            vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                                Input = Enum.KeyCode.Y
                                            })
                                        end
                                    end
                                    if vu195.Value == true then
                                        local v521 = vu125:get_character().StandSkills["Enum.KeyCode.X"].Value
                                        if not vu20:WaitForChild("HUD"):WaitForChild("Cooldowns"):WaitForChild("Frame"):FindFirstChild(v521) and vu19.StandSkillTree[v521].Value and (not vu125:get_character():FindFirstChild("Stand Barraging") and vu511:WaitForChild("Health").Value > v509 * 0.4) then
                                            vu125:get_character().RemoteEvent:FireServer("InputBegan", {
                                                Input = Enum.KeyCode.X
                                            })
                                            vu125:get_character().RemoteEvent:FireServer("InputEnded", {
                                                Input = Enum.KeyCode.X
                                            })
                                        end
                                    end
                                end
                                vu125:get_character().RemoteEvent:FireServer("Attack", "m1")
                            end
                        end
                        print("AF")
                        vu368.Text = "N/A"
                        v513:Disconnect()
                        v512:Disconnect()
                    end
                    return true
                end
                vu390:OnChanged(function(p523)
                    if p523 then
                        if not string.find(vu19.PlayerStats.Spec.Value, "Hamon") and (not vu122:FindFirstChild("Caesar\'s Headband") and vu125.player_spec ~= "Hamon") then
                            vu399("Not enough Items!", "You will need \"Caesar\'s Headband\" to continue.", 10)
                            return
                        end
                        if vu124.Value ~= "Star Platinum" then
                            vu399("Not the required stand!", "You will need Star Platinum in order to continue.", 10)
                            return
                        end
                        if not string.find(vu19.PlayerStats.Spec.Value, "Hamon") then
                            if tonumber(vu20.HUD.Main.DropMoney.Money.Text) < 5000 and (vu390.Value and task.wait()) then
                                local v524, v525, v526 = pairs(workspace.Item_Spawns.Items:GetChildren())
                                while true do
                                    local vu527
                                    v526, vu527 = v524(v525, v526)
                                    if v526 == nil then
                                        break
                                    end
                                    if vu527:IsA("Model") then
                                        local v528, v529, v530 = pairs(vu527:GetChildren())
                                        while true do
                                            local v531
                                            v530, v531 = v528(v529, v530)
                                            if v530 == nil then
                                                break
                                            end
                                            if v531:IsA("MeshPart") and (vu527:FindFirstChild("ProximityPrompt") and (vu527.ProximityPrompt.ObjectText == "Dio\'s Diary" or (vu527.ProximityPrompt.ObjectText == "Rokakaka" or (vu527.ProximityPrompt.ObjectText == "Rib Cage of The Saint\'s Corpse" or (vu527.ProximityPrompt.ObjectText == "Stone Mask" or (vu527.ProximityPrompt.ObjectText == "Steel Ball" or (vu527.ProximityPrompt.ObjectText == "Diamond" or (vu527.ProximityPrompt.ObjectText == "Gold Coin" or vu527.ProximityPrompt.ObjectText == "Ancient Scroll")))))))) and v531.Transparency ~= 1 then
                                                if not vu390.Value then
                                                    return
                                                end
                                                local _ = (vu125:get_rootpart().Position - vu527:GetModelCFrame().p).magnitude
                                                vu125:get_rootpart().CFrame = vu527:GetModelCFrame()
                                                repeat
                                                    task.wait()
                                                until (vu125:get_rootpart().Position - vu527:GetModelCFrame().p).magnitude <= 10 or not vu390.Value
                                                task.wait(0.19)
                                                if not vu390.Value then
                                                    return
                                                end
                                                local v532 = vu527.ProximityPrompt.ObjectText
                                                repeat
                                                    pcall(function()
                                                        fireproximityprompt(vu527.ProximityPrompt, 1)
                                                        task.wait(0.1)
                                                    end)
                                                    local v533 = vu527
                                                until not (vu527.FindFirstChild(v533, "ProximityPrompt") and vu390.Value)
                                                if not vu390.Value then
                                                    return
                                                end
                                                local v534 = vu125
                                                vu125:get_bp_item(v532).Parent = v534:get_character()
                                                task.wait()
                                                vu398("Merchant", "Dialogue5", "Option1")
                                                local v535 = vu122
                                                local v536, v537, v538 = pairs(v535:GetChildren())
                                                while true do
                                                    local v539
                                                    v538, v539 = v536(v537, v538)
                                                    if v538 == nil then
                                                        break
                                                    end
                                                    if v539.Name == v532 then
                                                        v539.Parent = vu125:get_character()
                                                        task.wait()
                                                        vu398("Merchant", "Dialogue5", "Option1")
                                                    end
                                                end
                                                task.wait(0.25)
                                                if tonumber(vu20.HUD.Main.DropMoney.Money.Text) >= 5000 then
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if tonumber(vu20.HUD.Main.DropMoney.Money.Text) < 5000 then
                                vu399("Failed to collect", "Failed to collect $5.000", 10)
                                return
                            end
                        end
                        if vu124.Value ~= "Star Platinum" and vu21.Value > 1 then
                            vu399("Not the required stand!", "You will need Star Platinum in order to continue", 10)
                            return
                        end
                        local vu540 = tick()
                        print(vu540 .. " StartTime")
                        local function vu544()
                            local v541 = vu125
                            print("Auto story initiated", next(v541:get_quests()))
                            if (vu21.Value < 35 or vu24.Value ~= 0) and ((vu21.Value < 40 or vu24.Value ~= 1) and (vu21.Value < 45 or vu24.Value ~= 2)) then
                                if vu21.Value == 50 then
                                    vu228()
                                    local v542 = tick()
                                    writefile("Result.txt", tostring(math.floor(v542 - vu540)))
                                    return
                                end
                            else
                                vu398("Prestige", "Dialogue2", "Option1")
                                vu399("Prestiged", "You have climbed to a new prestige", 5, nil)
                                vu125:wait_until_new_char()
                                if not vu390.Value then
                                    return
                                end
                                warn(" AFTER PRESTIG#R")
                                vu125:get_character():WaitForChild("Humanoid")
                                vu125:get_character().Humanoid.Health = 0.1
                                vu125:get_character().Humanoid.Health = 0
                                vu125:wait_until_new_char()
                                if not vu390.Value then
                                    return
                                end
                                vu228()
                                repeat
                                    task.wait(1)
                                    vu489()
                                    local v543 = vu125
                                until next(v543:get_quests()) ~= nil
                                if not vu390.Value then
                                    return
                                end
                                task.wait(0.1)
                                vu544()
                            end
                            if vu125:get_quests()["Help Giorno by Defeating Security Guards"] then
                                while true do
                                    task.wait()
                                    vu522("Security Guard", 2, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu399("Killed a story NPC", "Killed Security Guard", 4, nil)
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    vu494()
                                    if not vu390.Value then
                                        return
                                    end
                                    if not (vu125:get_quests()["Help Giorno by Defeating Security Guards"] and vu390.Value) then
                                        if not vu390.Value then
                                            return
                                        end
                                        repeat
                                            task.wait(0.5)
                                            vu489()
                                        until vu125:get_quests()["Defeat Leaky Eye Luca"]
                                        vu544()
                                    end
                                end
                            else
                                if vu125:get_quests()["Defeat Leaky Eye Luca"] then
                                    print("LEAKY EYE LUCA")
                                    vu522("Leaky Eye Luca", 2, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu399("Killed a story NPC", "Killed Luca", 4, nil)
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu493()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    vu494()
                                    if not vu390.Value then
                                        return
                                    end
                                    repeat
                                        task.wait(0.5)
                                        vu489()
                                    until vu125:get_quests()["Defeat Bucciarati"] or not vu390.Value
                                    if not vu390.Value then
                                        return
                                    end
                                    vu544()
                                end
                                if vu125:get_quests()["Defeat Bucciarati"] then
                                    print("BUCCIARATI")
                                    vu522("Bucciarati", 2, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu399("Killed a story NPC", "Killed Bucciarati", 4, nil)
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu493()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    vu494()
                                    if not vu390.Value then
                                        return
                                    end
                                    repeat
                                        task.wait(0.5)
                                        vu489()
                                    until vu125:get_quests()["Defeat Fugo And His Purple Haze"] or not vu390.Value
                                    if not vu390.Value then
                                        return
                                    end
                                    vu544()
                                end
                                if vu125:get_quests()["Defeat Fugo And His Purple Haze"] then
                                    print("FUGO")
                                    vu522("Fugo", 2, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu399("Killed a story NPC", "Killed Fugo", 4, nil)
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu493()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    vu494()
                                    if not vu390.Value then
                                        return
                                    end
                                    repeat
                                        task.wait(0.5)
                                        vu489()
                                    until vu125:get_quests()["Defeat Pesci"] or not vu390.Value
                                    if not vu390.Value then
                                        return
                                    end
                                    vu544()
                                end
                                if vu125:get_quests()["Defeat Pesci"] then
                                    print("PESCI")
                                    vu522("Pesci", 0, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu399("Killed a story NPC", "Killed Pesci", 4, nil)
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu493()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    vu494()
                                    if not vu390.Value then
                                        return
                                    end
                                    repeat
                                        task.wait(0.5)
                                        vu489()
                                    until vu125:get_quests()["Defeat Ghiaccio"] or not vu390.Value
                                    if not vu390.Value then
                                        return
                                    end
                                    vu544()
                                end
                                if vu125:get_quests()["Defeat Ghiaccio"] then
                                    print("GHIACCIO")
                                    vu522("Ghiaccio", 2, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu399("Killed a story NPC", "Killed Ghiaccio", 4, nil)
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu493()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    vu494()
                                    if not vu390.Value then
                                        return
                                    end
                                    repeat
                                        task.wait(0.5)
                                        vu489()
                                    until vu125:get_quests()["Defeat Diavolo"] or not vu390.Value
                                    if not vu390.Value then
                                        return
                                    end
                                    vu544()
                                end
                                if vu125:get_quests()["Defeat Diavolo"] then
                                    print("DIAVOLO")
                                    vu522("Diavolo", 2, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu493()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu489()
                                    task.wait()
                                    vu489()
                                    task.wait()
                                    vu489()
                                    vu228()
                                    task.wait()
                                    repeat
                                        task.wait(0.5)
                                        print("trying to get vampires")
                                        vu489()
                                        vu398("William Zeppeli", "Dialogue4", "Option1")
                                    until vu125:get_quests()["Take down 3 vampires"] or (vu125:get_quests()["Defeat Diavolo"] or not vu390.Value)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu544()
                                end
                                if vu21.Value >= 25 then
                                    task.wait(0.18)
                                    if not vu125:get_quests()["Take down 3 vampires"] then
                                        vu398("William Zeppeli", "Dialogue4", "Option1")
                                        task.wait()
                                        vu398("William Zeppeli", "Dialogue4", "Option1")
                                    end
                                    vu522("Vampire", 2, true)
                                    if not vu390.Value then
                                        return
                                    end
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    if not vu125:get_quests()["Take down 3 vampires"] then
                                        vu398("William Zeppeli", "Dialogue4", "Option1")
                                        task.wait()
                                        vu398("William Zeppeli", "Dialogue4", "Option1")
                                    end
                                    vu493()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu494()
                                    vu228()
                                    if not vu390.Value then
                                        return
                                    end
                                    vu544()
                                end
                                return
                            end
                        end
                        local v545 = vu125
                        print("right here", next(v545:get_quests()))
                        local v546 = vu544
                        repeat
                            task.wait(0.5)
                            vu489()
                            local v547 = vu125
                            table.foreach(v547:get_quests(), print)
                            local v548 = vu125
                        until next(v548:get_quests()) ~= nil or vu21.Value >= 25
                        task.wait(0.4)
                        print("Hi")
                        v546()
                    end
                end)
                v206:LoadAutoloadConfig()
            else
                local vu549 = vu2.new()
                vu549.discord_invite_label = vu1
                vu549.main_message.Text = "Failed to find an important dependency. DM senS about this."
                task.delay(10, function()
                    vu549:destroy()
                end)
            end
        end
    end
    task.wait(0.4)
    pcall(function()
        if vu20:FindFirstChild("LoadingScreen1") then
            task.spawn(function()
                while vu20:FindFirstChild("LoadingScreen1") do
                    task.wait(0.004)
                    game.Players.LocalPlayer:SetAttribute("LOADED", "Skip")
                end
            end)
            firesignal(vu20.LoadingScreen1:FindFirstChild("Frame"):FindFirstChild("LoadingFrame"):FindFirstChild("BarFrame"):FindFirstChild("Skip"):FindFirstChild("TextButton").MouseButton1Click)
        end
        firesignal(vu20:FindFirstChild("LoadingScreen"):FindFirstChild("Frames"):FindFirstChild("Gamemodes"):FindFirstChild("MainGame"):FindFirstChild("Play").MouseButton1Click)
    end)
end
