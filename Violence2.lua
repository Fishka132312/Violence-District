local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fishka132312/MeowlGui/refs/heads/main/source/library.lua"))()
local CheatName = "Violence District"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
  'Main/ShowPlayerInfo.lua',
  'Main/Fullbright.lua',
  'Visual/PlayersEsp.lua',
  'Visual/GeneratorEsp.lua',
	'Visual/HooksEsp.lua',
  'Visual/WindowsPalletsEsp.lua',
  'Whitelist.lua',
  'Killer/AutoAttack.lua',
	'Killer/AutoCarry.lua',
	'Killer/KillerSpeed.lua',
	'Abilities/TheStalker.lua',
	'Abilities/TheKiller.lua',
	'Abilities/TheVeil.lua',
  'Survivors/BypassGates.lua',
	'Survivors/SelfHeal.lua',
	'Survivors/SurvivorSpeed.lua',
	'Survivors/AutoSkillCheck.lua',
	'Survivors/DisCollision.lua',
	'Survivors/AntiAura.lua',
	'Survivora/PANICTP.lua',
  'Teleport/TpToGate.lua',
	'Teleport/TpToGen.lua',
	'Teleport/TpToHook.lua',
  'Emotes/Emotes.lua',
	'Emotes/AnimationSpeed.lua',
  'Emotes/CustomAnim.lua',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/Violence-District/refs/heads/main/Things/'

for i, scriptName in ipairs(scripts) do
    local fullUrl = baseUrl .. scriptName
    
    local success, err = pcall(function()
        local code = game:HttpGet(fullUrl)
        if code then
            loadstring(code)()
        else
            warn("Не удалось получить код для: " .. scriptName)
        end
    end)
    
    if not success then
        warn("Ошибка при загрузке " .. scriptName .. ": " .. tostring(err))
    end
    
    task.wait(0.5)
end

Library.Folders = {
    Directory = CheatName,
    Configs = CheatName .. "/Configs",
    Assets = CheatName .. "/Assets",
}

local Accent = Color3.fromRGB(255, 65, 85)
local Gradient = Color3.fromRGB(140, 10, 45)

Library.Theme.Accent = Accent
Library.Theme.AccentGradient = Gradient
Library:ChangeTheme("Accent", Accent)
Library:ChangeTheme("AccentGradient", Gradient)
local Window = Library:Window({
    Name = "Violence-District",
    SubName = "Meowl Sploit",
    Logo = "129442179713871"
})

-------------------------Main-----------------------

Window:Category("Main")

local MainPage = Window:Page({Name = "Main", Icon = "7539983773"})

--PlayerInfo--
local MainSection = MainPage:Section({Name = "Show Player Info", Side = 1})

local selectedPlayerName = nil

local function GetPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

local MyDropdown = MainSection:Dropdown({
    Name = "Choose Player",
    Flag = "Player_Drop",
    Items = GetPlayerList(), 
    Default = "",
    Multi = false,
    Callback = function(Value)
        selectedPlayerName = Value
    end
})

local function RefreshPlayerList()
    if MyDropdown and MyDropdown.Refresh then
        MyDropdown:Refresh(GetPlayerList())
        print("[UI] Список игроков обновлён")
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(0.2)
    RefreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.2)
    RefreshPlayerList()
end)

MainSection:Button({
    Name = "Show Info",
    Callback = function()
        if not selectedPlayerName or selectedPlayerName == "" then
            Library:Notification({
                Title = "Error",
                Description = "Choose Player First!",
                Duration = 3,
                Icon = "4483345998"
            })
            return
        end

        local target = Players:FindFirstChild(selectedPlayerName)
        if not target then
            Library:Notification({
                Title = "Error",
                Description = "Player not Found!",
                Duration = 3,
                Icon = "4483345998"
            })
            return
        end

        LocalPlayer:SetAttribute("RequestPlayerInfo", selectedPlayerName)
    end
})

--Lightning--
local LightningSection = MainPage:Section({Name = "Lightning", Side = 2})

local MyToggle = LightningSection:Toggle({
    Name = "Fullbright",
    Flag = "Fullbright",
    Default = false,
    Callback = function(Value)
       _G.Fullbridthlol = Value
    end
})

-------------------------Visual-----------------------

Window:Category("Visual")

local VisualPage = Window:Page({Name = "Visual", Icon = "116707863154642"})

--players--
local PlayersSection = VisualPage:Section({Name = "Players", Side = 1})

local MyToggle = PlayersSection:Toggle({
    Name = "Esp Killer",
    Flag = "EspKiller",
    Default = false,
    Callback = function(Value)
       _G.EspKiller = Value
    end
})

local MyToggle = PlayersSection:Toggle({
    Name = "Esp Survivors",
    Flag = "EspSurvivors",
    Default = false,
    Callback = function(Value)
       _G.EspSurvivors = Value
    end
})

local MyToggle = PlayersSection:Toggle({
    Name = "Esp Spectators",
    Flag = "EspSpectators",
    Default = false,
    Callback = function(Value)
       _G.EspSpectator = Value
    end
})

--Things--
local ThingsSection = VisualPage:Section({Name = "Things", Side = 2})

local MyToggle = ThingsSection:Toggle({
    Name = "Esp Generators",
    Flag = "EspGenerators",
    Default = false,
    Callback = function(Value)
       _G.EspGenerators = Value
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Esp Hooks",
    Flag = "EspHooks",
    Default = false,
    Callback = function(Value)
       _G.HooksEsp = Value
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Esp Windows/Pallets",
    Flag = "EspWinPal",
    Default = false,
    Callback = function(Value)
       _G.WinPaletEsp = Value
    end
})

-------------------------Killer-----------------------

Window:Category("Killer")

local KillerPage = Window:Page({Name = "Killer", Icon = "6187718252"})

--Whitelisht--
local WhitelistSection = KillerPage:Section({Name = "Whitelist", Side = 1})

local PlayerDropdown = WhitelistSection:Dropdown({
    Name = "Choose Player",
    Flag = "Player_Drop",
    Items = GetPlayerList(),
    Default = "",
    Multi = false,
    Callback = function(Value)
        _G.SelectedPlayer = Value
        print("Выбран: " .. Value)
    end
})

WhitelistSection:Button({
    Name = "Add / Remove from Whitelist",
    Callback = function()
        local selected = _G.SelectedPlayer

        if not selected or selected == "" then
            Library:Notification({
                Title = "Ошибка",
                Description = "❌ Please select a player first",
                Duration = 3,
                Icon = "73789337996373"
            })
            return
        end

        if not _G.Whitelist then _G.Whitelist = {} end

        local index = table.find(_G.Whitelist, selected)

        if index then
            table.remove(_G.Whitelist, index)
            print("➖ " .. selected .. " removed from whitelist")
            Library:Notification({
                Title = "Whitelist",
                Description = "➖ " .. selected .. " removed from whitelist",
                Duration = 3,
                Icon = "73789337996373"
            })
        else
            table.insert(_G.Whitelist, selected)
            print("✅ " .. selected .. " added to whitelist")
            Library:Notification({
                Title = "Whitelist",
                Description = "✅ " .. selected .. " added to whitelist",
                Duration = 3,
                Icon = "73789337996373"
            })
        end
    end
})

--Main--
local MainSection = KillerPage:Section({Name = "Main", Side = 2})

local MyToggle = MainSection:Toggle({
    Name = "Auto Attack",
    Flag = "AutoAttack",
    Default = false,
    Callback = function(Value)
       _G.AutoAttackKiller = Value
    end
})

local MyToggle = MainSection:Toggle({
    Name = "Auto Carry",
    Flag = "AutoCarry",
    Default = false,
    Callback = function(Value)
       _G.AutoCarry = Value
    end
})

local MyToggle = MainSection:Toggle({
    Name = "Auto Hook",
    Flag = "AutoHook",
    Default = false,
    Callback = function(Value)
       _G.AutoHook = Value
    end
})


local MySlider = MainSection:Slider({
    Name = "Killer Speed",
    Flag = "KillerSpeed_Slider",
    Min = 1,
    Max = 25,
    Default = 1,
    Decimals = 1,
    Suffix = " speed",
    Callback = function(Value)
        _G.KillerSpeed = Value
        local char = LocalPlayer.Character
        if char and _G.SpeedToggle 
           and LocalPlayer.Team 
           and LocalPlayer.Team.Name == "Killer" then
            char:SetAttribute("speedboost", Value)
        end
    end
})

local MyToggle = MainSection:Toggle({
    Name = "Apply Killer Speed",
    Flag = "ApplyKillerSpeed_Toggle",
    Default = false,
    Callback = function(Value)
        _G.SpeedToggle = Value
        local char = LocalPlayer.Character
        if not char then return end
        
        if Value then
            if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
                char:SetAttribute("speedboost", _G.KillerSpeed or 1)
            end
        else
            if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
                char:SetAttribute("speedboost", 1)
            end
        end
    end
})

--------------------Abilities-----------------------

local AbilitiesPage = Window:Page({Name = "Abilities", Icon = "6723742952"})

--Killers--
local KillersSection = AbilitiesPage:Section({Name = "Killers", Side = 1})

local MyToggle = KillersSection:Toggle({
    Name = "Inf Abilities (The Slasher SOON)",
    Flag = "InfAbilitiesSlasher",
    Default = false,
    Callback = function(Value)
       _G.Slasher1 = Value
    end
})

local MyToggle = KillersSection:Toggle({
    Name = "Auto Stalking (The Stalker)",
    Flag = "AutoStalkingStalker",
    Default = false,
    Callback = function(Value)
       _G.Stalker = Value
    end
})

local MyDropdown = KillersSection:Dropdown({
    Name = "Select Sound (The Killer)",
    Flag = "SoundTheKiller",
    Items = _G.SoundOptionsKiller or {"Music 1", "Music 2", "Music 3", "Custom"},
    Default = _G.SelectedSoundKiller or (_G.SoundOptionsKiller and _G.SoundOptionsKiller[1]) or "Music 1",
    Multi = false,
    Callback = function(Value)
        _G.SelectedSoundKiller = Value
        print("[Sound] Выбрано:", Value)
    end
})

KillersSection:Button({
    Name = "▶ Play Sound",
    Callback = function()
        if _G.PlaySoundKiller then
            _G.PlaySoundKiller()
            Library:Notification({
                Title = "Sound Killer",
                Description = "Играем: " .. (_G.SelectedSoundKiller or "Unknown"),
                Duration = 3,
                Icon = "73789337996373"
            })
        else
            Library:Notification({
                Title = "Error",
                Description = "Функция PlaySoundKiller не найдена!",
                Duration = 4,
                Icon = "73789337996373"
            })
        end
    end
})

local MyDropdown = KillersSection:Dropdown({
    Name = "Select Sound (The Veil)",
    Flag = "SoundTheVeil",
    Items = _G.SoundOptionsVeil or {"Music 1", "Music 2", "Music 3", "Custom"},
    Default = _G.SelectedSoundVeil or (_G.SoundOptionsVeil and _G.SoundOptionsVeil[1]) or "Music 1",
    Multi = false,
    Callback = function(Value)
        _G.SelectedSoundVeil = Value
        print("[Veil Sound] Выбрано:", Value)
    end
})

KillersSection:Button({
    Name = "▶ Play Sound",
    Callback = function()
        if _G.PlaySoundVeil then
            _G.PlaySoundVeil()
            Library:Notification({
                Title = "Sound Veil",
                Description = "Играем: " .. (_G.SelectedSoundVeil or "Unknown"),
                Duration = 3,
                Icon = "73789337996373"
            })
        else
            Library:Notification({
                Title = "Error",
                Description = "Функция PlaySoundVeil не найдена!",
                Duration = 4,
                Icon = "73789337996373"
            })
        end
    end
})


-------------------------Survivors-----------------------

Window:Category("Survivors")

local SurvivorPage = Window:Page({Name = "Survivor", Icon = "90807912793699"})

--AutoFarm--
local AutoFarmSection = SurvivorPage:Section({Name = "AutoFarm", Side = 1})

--Things--
local ThingsSection = SurvivorPage:Section({Name = "Things", Side = 2})

local MyToggle = ThingsSection:Toggle({
    Name = "Self Heal",
    Flag = "SelfHeal",
    Default = false,
    Callback = function(Value)
       _G.Autoheal = Value
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Bypass Gates",
    Flag = "BypassGates",
    Default = false,
    Callback = function(Value)
       _G.BypassGates = Value
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Auto Skill Check",
    Flag = "AutoSkillCheck",
    Default = false,
    Callback = function(Value)
       _G.AutoSkillCheck = Value
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Hide Aura",
    Flag = "HideAura",
    Default = false,
    Callback = function(Value)
       _G.AntiAura = Value
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Panic Tp",
    Flag = "PanicTp",
    Default = false,
    Callback = function(Value)
       _G.PANICTP = Value
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Disable Collision",
    Flag = "DisableCollision ",
    Default = false,
    Callback = function(Value)
       _G.DisableCollision  = Value
    end
})

local MySlider = ThingsSection:Slider({
    Name = "Survivor Speed",
    Flag = "SurvivorSpeed_Slider",
    Min = 1,
    Max = 25,
    Default = 1,
    Decimals = 1,
    Suffix = " speed",
    Callback = function(Value)
        _G.SurvivorSpeed = Value
        local char = LocalPlayer.Character
        if char and _G.SurvivorSpeedToggle
           and LocalPlayer.Team
           and LocalPlayer.Team.Name == "Survivors" then
            char:SetAttribute("speedboost", Value)
        end
    end
})

local MyToggle = ThingsSection:Toggle({
    Name = "Apply Survivor Speed",
    Flag = "ApplySurvivorSpeed_Toggle",
    Default = false,
    Callback = function(Value)
        _G.SurvivorSpeedToggle = Value
        local char = LocalPlayer.Character
        if not char then return end
        if Value then
            if LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
                char:SetAttribute("speedboost", _G.SurvivorSpeed or 1)
            end
        else
            if LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
                char:SetAttribute("speedboost", 1)
            end
        end
    end
})

Window:Category("Teleport")

local TeleportPage = Window:Page({Name = "Teleport", Icon = "5160482784"})

--Players--
local PlayersSection = TeleportPage:Section({Name = "Players", Side = 1})

--Things--
local ThingsSection = TeleportPage:Section({Name = "Things", Side = 2})

ThingsSection:Button({
    Name = "Tp To Generator",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        local signal = LocalPlayer.PlayerGui:FindFirstChild("GenTeleportSignal")
        
        if signal then
            signal:Fire()
            
            Library:Notification({
                Title = "TP",
                Description = "Телепортирован к генератору!",
                Duration = 3,
                Icon = "73789337996373"
            })
        else
            Library:Notification({
                Title = "Ошибка",
                Description = "Сигнал GenTeleportSignal не найден!",
                Duration = 4,
                Icon = "73789337996373"
            })
        end
    end
})

ThingsSection:Keybind({
    Name = "Gen Keybind",
    Flag = "Gen_Teleport_Bind",
    Default = Enum.KeyCode.G,
    Mode = "Toggle",
    Callback = function(State)
        if State then
            local signal = LocalPlayer.PlayerGui:FindFirstChild("GenTeleportSignal")
            if signal then
                signal:Fire()
                
                Library:Notification({
                    Title = "TP",
                    Description = "Телепортирован к генератору!",
                    Duration = 2,
                    Icon = "73789337996373"
                })
            end
        end
    end
})

ThingsSection:Button({
    Name = "Tp To Hook",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        local signal = LocalPlayer.PlayerGui:FindFirstChild("HookTeleportSignal")
        
        if signal then
            signal:Fire()
            
            Library:Notification({
                Title = "TP",
                Description = "Телепортирован к хуку!",
                Duration = 3,
                Icon = "73789337996373"
            })
        else
            Library:Notification({
                Title = "Ошибка",
                Description = "Сигнал HookTeleportSignal не найден!",
                Duration = 4,
                Icon = "73789337996373"
            })
        end
    end
})

ThingsSection:Keybind({
    Name = "Hook Keybind",
    Flag = "Hook_Teleport_Bind",
    Default = Enum.KeyCode.V,
    Mode = "Toggle",
    Callback = function(State)
        if State then
            local signal = LocalPlayer.PlayerGui:FindFirstChild("HookTeleportSignal")
            if signal then
                signal:Fire()
                
                Library:Notification({
                    Title = "TP",
                    Description = "Телепортирован к хуку!",
                    Duration = 2,
                    Icon = "73789337996373"
                })
            end
        end
    end
})

ThingsSection:Button({
    Name = "Tp To Exit",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        local signal = LocalPlayer.PlayerGui:FindFirstChild("GateTeleportSignal")
        
        if signal then
            signal:Fire()
            
            Library:Notification({
                Title = "TP",
                Description = "Телепортирован к выходу!",
                Duration = 3,
                Icon = "73789337996373"
            })
        else
            Library:Notification({
                Title = "Ошибка",
                Description = "Сигнал GateTeleportSignal не найден!",
                Duration = 4,
                Icon = "73789337996373"
            })
        end
    end
})

ThingsSection:Keybind({
    Name = "Gate Keybind",
    Flag = "Gate_Teleport_Bind",
    Default = Enum.KeyCode.H,
    Mode = "Toggle",
    Callback = function(State)
        if State then
            local signal = LocalPlayer.PlayerGui:FindFirstChild("GateTeleportSignal")
            if signal then
                signal:Fire()
                
                Library:Notification({
                    Title = "TP",
                    Description = "Телепортирован к выходу!",
                    Duration = 2,
                    Icon = "73789337996373"
                })
            end
        end
    end
})

------------------------Emotes-------------------------

Window:Category("Emotes/Animations")

local EmotesPage = Window:Page({Name = "Emotes", Icon = "110748588642372"})

--Game Emotes--
local GameEmotesSection = EmotesPage:Section({Name = "Game Emotes", Side = 1})

local allEmotes = getgenv().GetAllEmotes and getgenv().GetAllEmotes() or {"No Emotes Found"}
local selectedEmote = allEmotes[1] or "No Emotes Found"

local MyDropdown = GameEmotesSection:Dropdown({
    Name = "Select Emote",
    Flag = "GameEmotes",        
    Items = allEmotes,
    Default = selectedEmote,
    Multi = false,
    Callback = function(Value)
        if Value and Value ~= "No Emotes Found" then
            selectedEmote = Value
            getgenv().PlayEmoteByName(Value)
        end
    end
})

local MyToggle = GameEmotesSection:Toggle({
    Name = "Start / Stop Emote",
    Flag = "GameEmoteToggle",
    Default = false,
    Callback = function(Value)
        if Value then
            if selectedEmote and selectedEmote ~= "No Emotes Found" then
                getgenv().PlayEmoteByName(selectedEmote)
            end
        else
            getgenv().StopCurrentEmote()
        end
    end
})

local MySlider = GameEmotesSection:Slider({
    Name = "Emote Speed",
    Flag = "Emote_Speed",
    Min = 1,
    Max = 20,
    Default = 5,
    Increment = 0.1,
    ValueName = "x",
    Color = Color3.fromRGB(255, 100, 100),
    Callback = function(Value)
        if getgenv().SetAnimationSpeed then
            getgenv().SetAnimationSpeed(Value)
        end
    end
})

local MyToggle = GameEmotesSection:Toggle({
    Name = "Sped Up Emote",
    Flag = "Emote_Speed_Toggle",
    Default = false,
    Callback = function(Value)
        if getgenv().ToggleAnimationSpeed then
            getgenv().ToggleAnimationSpeed(Value)
        end
    end
})

--Custom Emotes--
local CustomEmotesSection = EmotesPage:Section({Name = "Custom Emotes", Side = 1})

CustomEmotesSection:Button({
    Name = "Stop Animation",
    Callback = function()
        if _G.StopAnimation then
            _G.StopAnimation()
        end
    end
})

CustomEmotesSection:Button({
    Name = "Arm Up",
    Callback = function()
      _G.PlayAnimation(117042998468241, "standing", false, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "Attack",
    Callback = function()
            _G.PlayAnimation(133963973694098, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "Attack 2",
    Callback = function()
            _G.PlayAnimation(78935059863801, "standing", false, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "XZ",
    Callback = function()
           _G.PlayAnimation(80411309607666, "standing", false, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "XZ2",
    Callback = function()
            _G.PlayAnimation(100092272524635, "standing", false, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "LOL",
    Callback = function()
            _G.PlayAnimation(129967390, "standing", false, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "Goida",
    Callback = function()
            _G.PlayAnimation(84440437648153, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "Kick",
    Callback = function()
            _G.PlayAnimation(135181748009911, "standing", false, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "Kick 2",
    Callback = function()
            _G.PlayAnimation(77210283630654, "standing", false, "nonlooped")
    end
})

CustomEmotesSection:Button({
    Name = "Cracking",
    Callback = function()
            _G.PlayAnimation(91619171958082, "standing", true, "looped")
    end
})

------------------------Animations-------------------------

local AnimationsPage = Window:Page({Name = "Animations", Icon = "110748588642372"})

--Game Emotes--
local CustomAnimationsSection = AnimationsPage:Section({Name = "Custom Animations", Side = 1})

local MyToggle = CustomAnimationsSection:Toggle({
    Name = "Crawling",      
    Flag = "CrawlingAnimation",   
    Default = false,
    Callback = function(Value)
        if Value then
            if _G.StopAnimation then _G.StopAnimation() end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(78719043959654, "walking", true, "looped")
            end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(126526181422628, "standing", true, "looped")
            end
        else
            if _G.StopAnimation then 
                _G.StopAnimation() 
            end
        end
    end
})

local MyToggle = CustomAnimationsSection:Toggle({
    Name = "Injured",      
    Flag = "InjuredAnimation",   
    Default = false,
    Callback = function(Value)
        if Value then
            if _G.StopAnimation then _G.StopAnimation() end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(135084204086504, "walking", true, "looped")
            end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(72208365305487, "standing", true, "looped")
            end
        else
            if _G.StopAnimation then 
                _G.StopAnimation() 
            end
        end
    end
})

local MyToggle = CustomAnimationsSection:Toggle({
    Name = "RUNNNN",      
    Flag = "RUNNNNAnimation",   
    Default = false,
    Callback = function(Value)
        if Value then
            if _G.StopAnimation then _G.StopAnimation() end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(116093934008204, "walking", true, "looped")
            end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(134758728973154, "standing", true, "looped")
            end
        else
            if _G.StopAnimation then 
                _G.StopAnimation() 
            end
        end
    end
})

local MyToggle = CustomAnimationsSection:Toggle({
    Name = "BUHOI",      
    Flag = "BUHOIAnimation",   
    Default = false,
    Callback = function(Value)
        if Value then
            if _G.StopAnimation then _G.StopAnimation() end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(92098503722633, "walking", true, "looped")
            end
            wait(1)
            if _G.PlayAnimation then 
                _G.PlayAnimation(96744338559260, "standing", true, "looped")
            end
        else
            if _G.StopAnimation then 
                _G.StopAnimation() 
            end
        end
    end
})
Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
Window:Init()
