local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fishka132312/MeowlGui/refs/heads/main/source/library.lua"))()

local CheatName = "Violence District"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local ICON_OK = "73789337996373"
local ICON_ERR = "4483345998"

local function Notify(Title, Description, Duration, Icon)
    Library:Notification({
        Title = Title,
        Description = Description,
        Duration = Duration or 3,
        Icon = Icon or ICON_OK
    })
end

local function FireSignal(SignalName, OkText)
    local Gui = LocalPlayer:FindFirstChild("PlayerGui")
    local Signal = Gui and Gui:FindFirstChild(SignalName)

    if Signal then
        Signal:Fire()
        Notify("Teleport", OkText, 3)
        return true
    end

    Notify("Ошибка", "Сигнал " .. SignalName .. " не найден", 4, ICON_ERR)
    return false
end

local function GetPlayerList(IncludeSelf)
    local List = { }

    for _, Player in ipairs(Players:GetPlayers()) do
        if IncludeSelf or Player ~= LocalPlayer then
            table.insert(List, Player.Name)
        end
    end

    if #List == 0 then
        table.insert(List, "No players")
    end

    return List
end

local Scripts = {
    "Main/ShowPlayerInfo.lua",
    "Main/Fullbright.lua",
    "Visual/PlayersEsp.lua",
    "Visual/GeneratorEsp.lua",
    "Visual/HooksEsp.lua",
    "Visual/WindowsPalletsEsp.lua",
    "Whitelist.lua",
    "Killer/AutoAttack.lua",
    "Killer/AutoCarry.lua",
    "Killer/KillerSpeed.lua",
    "Abilities/TheStalker.lua",
    "Abilities/TheKiller.lua",
    "Abilities/TheVeil.lua",
    "Survivors/BypassGates.lua",
    "Survivors/SelfHeal.lua",
    "Survivors/SurvivorSpeed.lua",
    "Survivors/AutoSkillCheck.lua",
    "Survivors/DisCollision.lua",
    "Survivors/AntiAura.lua",
    "Survivors/PANICTP.lua",
    "Teleport/TpToGate.lua",
    "Teleport/TpToGen.lua",
    "Teleport/TpToHook.lua",
    "Emotes/Emotes.lua",
    "Emotes/AnimationSpeed.lua",
    "Emotes/CustomAnim.lua",
}

local BaseUrl = "https://raw.githubusercontent.com/Fishka132312/Violence-District/refs/heads/main/Things/"

local Loaded, Failed = 0, { }

for _, ScriptName in ipairs(Scripts) do
    local Success, Err = pcall(function()
        local Code = game:HttpGet(BaseUrl .. ScriptName)

        if Code and #Code > 0 then
            loadstring(Code)()
        else
            error("пустой ответ")
        end
    end)

    if Success then
        Loaded = Loaded + 1
    else
        table.insert(Failed, ScriptName)
        warn("[VD] Ошибка загрузки " .. ScriptName .. ": " .. tostring(Err))
    end

    task.wait(0.05)
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

local KeybindList = Library:KeybindList(CheatName)

local MainCat = Window:Category("Main")

local MainPage = Window:Page({
    Name = "Main",
    Icon = "https://i.postimg.cc/R09KZw72/Bez-imeni-1.png",
    Category = MainCat
})

local PlayerInfoSection = MainPage:Section({
    Name = "Show Player Info",
    Description = "Инфа о выбранном игроке",
    Side = 1
})

local SelectedPlayerName = nil

local PlayerListbox = PlayerInfoSection:Listbox({
    Flag = "InfoPlayerList",
    Items = GetPlayerList(),
    Multi = false,
    Size = 130,
    Callback = function(Value)
        SelectedPlayerName = Value
    end
})

local SelectedLabel = PlayerInfoSection:Label("Selected: —")

PlayerInfoSection:Button({
    Name = "Show Info",
    Tooltip = "Показать информацию о выбранном игроке",
    Callback = function()
        if not SelectedPlayerName or SelectedPlayerName == "" or SelectedPlayerName == "No players" then
            Notify("Error", "Choose Player First!", 3, ICON_ERR)
            return
        end

        local Target = Players:FindFirstChild(SelectedPlayerName)

        if not Target then
            Notify("Error", "Player not Found!", 3, ICON_ERR)
            return
        end

        LocalPlayer:SetAttribute("RequestPlayerInfo", SelectedPlayerName)
    end
})

PlayerInfoSection:Button({
    Name = "Refresh List",
    Callback = function()
        PlayerListbox:Refresh(GetPlayerList())
        Notify("Players", "Список обновлён (" .. (#Players:GetPlayers() - 1) .. ")", 2)
    end
})

local LightningSection = MainPage:Section({
    Name = "Lightning",
    Description = "Свет и видимость",
    Side = 2
})

local FullbrightToggle = LightningSection:Toggle({
    Name = "Fullbright",
    Flag = "Fullbright",
    Tooltip = "Убирает темноту на карте",
    Default = false,
    Callback = function(Value)
        _G.Fullbridthlol = Value
    end
})

FullbrightToggle:Keybind({
    Flag = "FullbrightKey",
    Default = Enum.KeyCode.B,
    Mode = "Toggle",
    Callback = function()
        FullbrightToggle:Set(not FullbrightToggle:Get())
    end
})

local SessionSection = MainPage:Section({
    Name = "Session",
    Description = "Статистика текущего матча",
    Side = 2
})

SessionSection:Image({
    Id = "129442179713871",
    Height = 80,
    Rounded = true
})

local StatsLabel = SessionSection:Label("FPS: 0 | Ping: 0 ms")
local RoleLabel = SessionSection:Label("Role: —")

SessionSection:Divider()

local GensProgress = SessionSection:ProgressBar({
    Name = "Generators",
    Min = 0,
    Max = 100,
    Default = 0,
    Suffix = "%"
})

SessionSection:Paragraph({
    Name = "Loader",
    Text = ("Загружено модулей: %d/%d"):format(Loaded, #Scripts)
        .. (#Failed > 0 and ("\nНе загрузились: " .. table.concat(Failed, ", ")) or "\nВсе модули ок")
})

----------------------------------------------------------------
-- VISUAL
----------------------------------------------------------------

local VisualCat = Window:Category("Visual")

local VisualPage = Window:Page({
    Name = "Visual",
    Icon = "116707863154642",
    Category = VisualCat
})

local PlayersEspSection = VisualPage:Section({
    Name = "Players",
    Description = "ESP игроков",
    Side = 1,
    EnableToggle = true
})

local EspKillerToggle = PlayersEspSection:Toggle({
    Name = "Esp Killer",
    Flag = "EspKiller",
    Default = false,
    Callback = function(Value)
        _G.EspKiller = Value
    end
})

EspKillerToggle:Colorpicker({
    Flag = "EspKillerColor",
    Default = Color3.fromRGB(255, 65, 85),
    Callback = function(Color)
        _G.EspKillerColor = Color
    end
})

local EspSurvivorsToggle = PlayersEspSection:Toggle({
    Name = "Esp Survivors",
    Flag = "EspSurvivors",
    Default = false,
    Callback = function(Value)
        _G.EspSurvivors = Value
    end
})

EspSurvivorsToggle:Colorpicker({
    Flag = "EspSurvivorsColor",
    Default = Color3.fromRGB(85, 255, 127),
    Callback = function(Color)
        _G.EspSurvivorsColor = Color
    end
})

local EspSpectatorsToggle = PlayersEspSection:Toggle({
    Name = "Esp Spectators",
    Flag = "EspSpectators",
    Default = false,
    Callback = function(Value)
        _G.EspSpectator = Value
    end
})

EspSpectatorsToggle:Colorpicker({
    Flag = "EspSpectatorsColor",
    Default = Color3.fromRGB(170, 170, 170),
    Callback = function(Color)
        _G.EspSpectatorColor = Color
    end
})

local EspSettingsSection = VisualPage:Section({
    Name = "Esp Settings",
    Description = "Общие настройки отрисовки",
    Side = 1
})

EspSettingsSection:Dropdown({
    Name = "Esp Elements",
    Flag = "EspElements",
    Items = { "Box", "Name", "Distance", "Health", "Tracer" },
    Default = { "Box", "Name" },
    Multi = true,
    Tooltip = "Что рисовать над игроками",
    Callback = function(Value)
        _G.EspElements = { }

        for _, Name in ipairs(Value) do
            _G.EspElements[Name] = true
        end
    end
})

EspSettingsSection:Slider({
    Name = "Max Distance",
    Flag = "EspMaxDistance",
    Min = 50,
    Max = 1000,
    Default = 500,
    Decimals = 1,
    Suffix = " studs",
    Callback = function(Value)
        _G.EspMaxDistance = Value
    end
})

EspSettingsSection:Toggle({
    Name = "Team Check",
    Flag = "EspTeamCheck",
    Default = true,
    Callback = function(Value)
        _G.EspTeamCheck = Value
    end
})

local ThingsEspSection = VisualPage:Section({
    Name = "Things",
    Description = "ESP объектов",
    Side = 2,
    EnableToggle = true
})

local EspGensToggle = ThingsEspSection:Toggle({
    Name = "Esp Generators",
    Flag = "EspGenerators",
    Default = false,
    Callback = function(Value)
        _G.EspGenerators = Value
    end
})

EspGensToggle:Colorpicker({
    Flag = "EspGeneratorsColor",
    Default = Color3.fromRGB(255, 200, 65),
    Callback = function(Color)
        _G.EspGeneratorsColor = Color
    end
})

local EspHooksToggle = ThingsEspSection:Toggle({
    Name = "Esp Hooks",
    Flag = "EspHooks",
    Default = false,
    Callback = function(Value)
        _G.HooksEsp = Value
    end
})

EspHooksToggle:Colorpicker({
    Flag = "EspHooksColor",
    Default = Color3.fromRGB(255, 105, 180),
    Callback = function(Color)
        _G.HooksEspColor = Color
    end
})

local EspWinPalToggle = ThingsEspSection:Toggle({
    Name = "Esp Windows/Pallets",
    Flag = "EspWinPal",
    Default = false,
    Callback = function(Value)
        _G.WinPaletEsp = Value
    end
})

EspWinPalToggle:Colorpicker({
    Flag = "EspWinPalColor",
    Default = Color3.fromRGB(120, 200, 255),
    Callback = function(Color)
        _G.WinPaletEspColor = Color
    end
})

ThingsEspSection:Divider()

ThingsEspSection:Paragraph({
    Name = "Подсказка",
    Text = "Цвета и настройки ESP пишутся в _G (например _G.EspKillerColor). Чтобы они работали, модуль ESP должен читать эти значения."
})

----------------------------------------------------------------
-- KILLER
----------------------------------------------------------------

local KillerCat = Window:Category("Killer")

local KillerPage = Window:Page({
    Name = "Killer",
    Icon = "6187718252",
    Category = KillerCat
})

local WhitelistSection = KillerPage:Section({
    Name = "Whitelist",
    Description = "Кого не трогать",
    Side = 1
})

local WhitelistListbox = WhitelistSection:Listbox({
    Flag = "WhitelistPlayers",
    Items = GetPlayerList(),
    Multi = true,
    Size = 140,
    Callback = function(Value)
        _G.Whitelist = Value or { }
    end
})

local WhitelistLabel = WhitelistSection:Label("In whitelist: 0")

WhitelistSection:Button({
    Name = "Refresh List",
    Callback = function()
        WhitelistListbox:Refresh(GetPlayerList())
        Notify("Whitelist", "Список игроков обновлён", 2)
    end
})

WhitelistSection:Button({
    Name = "Clear Whitelist",
    Callback = function()
        _G.Whitelist = { }
        WhitelistListbox:Set({ })
        Notify("Whitelist", "Вайтлист очищен", 2)
    end
})

local KillerMainSection = KillerPage:Section({
    Name = "Main",
    Description = "Основные функции убийцы",
    Side = 2,
    EnableToggle = true
})

local AutoAttackToggle = KillerMainSection:Toggle({
    Name = "Auto Attack",
    Flag = "AutoAttack",
    Tooltip = "Автоудар по ближайшей цели",
    Default = false,
    Callback = function(Value)
        _G.AutoAttackKiller = Value
    end
})

AutoAttackToggle:Keybind({
    Flag = "AutoAttackKey",
    Default = Enum.KeyCode.X,
    Mode = "Toggle",
    Callback = function()
        AutoAttackToggle:Set(not AutoAttackToggle:Get())
    end
})

local AutoCarryToggle = KillerMainSection:Toggle({
    Name = "Auto Carry",
    Flag = "AutoCarry",
    Default = false,
    Callback = function(Value)
        _G.AutoCarry = Value
    end
})

local AutoHookToggle = KillerMainSection:Toggle({
    Name = "Auto Hook",
    Flag = "AutoHook",
    Default = false,
    Callback = function(Value)
        _G.AutoHook = Value
    end
})

KillerMainSection:Divider()

local KillerSpeedSlider = KillerMainSection:Slider({
    Name = "Killer Speed",
    Flag = "KillerSpeed_Slider",
    Min = 1,
    Max = 25,
    Default = 1,
    Decimals = 1,
    Suffix = " speed",
    Tooltip = "Скорость передвижения",
    Callback = function(Value)
        _G.KillerSpeed = Value

        local Character = LocalPlayer.Character

        if Character and _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
            Character:SetAttribute("speedboost", Value)
        end
    end
})

local KillerSpeedToggle = KillerMainSection:Toggle({
    Name = "Apply Killer Speed",
    Flag = "ApplyKillerSpeed_Toggle",
    Default = false,
    Callback = function(Value)
        _G.SpeedToggle = Value

        local Character = LocalPlayer.Character

        if not Character then
            return
        end

        if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
            Character:SetAttribute("speedboost", Value and (_G.KillerSpeed or 1) or 1)
        end
    end
})

KillerSpeedToggle:Keybind({
    Flag = "KillerSpeedKey",
    Default = Enum.KeyCode.C,
    Mode = "Hold",
    Callback = function(State)
        KillerSpeedToggle:Set(State and true or false)
    end
})

----------------------------------------------------------------
-- ABILITIES
----------------------------------------------------------------

local AbilitiesPage = Window:Page({
    Name = "Abilities",
    Icon = "6723742952",
    Category = KillerCat
})

local KillersSection = AbilitiesPage:Section({
    Name = "Killers",
    Description = "Способности по персонажам",
    Side = 1
})

KillersSection:Toggle({
    Name = "Inf Abilities (The Slasher SOON)",
    Flag = "InfAbilitiesSlasher",
    Default = false,
    Callback = function(Value)
        _G.Slasher1 = Value
    end
})

KillersSection:Toggle({
    Name = "Auto Stalking (The Stalker)",
    Flag = "AutoStalkingStalker",
    Default = false,
    Callback = function(Value)
        _G.Stalker = Value
    end
})

local SoundSection = AbilitiesPage:Section({
    Name = "Sounds",
    Description = "Музыка способностей",
    Side = 2
})

SoundSection:Dropdown({
    Name = "Select Sound (The Killer)",
    Flag = "SoundTheKiller",
    Items = _G.SoundOptionsKiller or { "Music 1", "Music 2", "Music 3", "Custom" },
    Default = _G.SelectedSoundKiller or (_G.SoundOptionsKiller and _G.SoundOptionsKiller[1]) or "Music 1",
    Multi = false,
    Callback = function(Value)
        _G.SelectedSoundKiller = Value
    end
})

SoundSection:Button({
    Name = "▶ Play Sound (Killer)",
    Callback = function()
        if _G.PlaySoundKiller then
            _G.PlaySoundKiller()
            Notify("Sound Killer", "Играем: " .. (_G.SelectedSoundKiller or "Unknown"), 3)
        else
            Notify("Error", "Функция PlaySoundKiller не найдена", 4, ICON_ERR)
        end
    end
})

SoundSection:Divider()

SoundSection:Dropdown({
    Name = "Select Sound (The Veil)",
    Flag = "SoundTheVeil",
    Items = _G.SoundOptionsVeil or { "Music 1", "Music 2", "Music 3", "Custom" },
    Default = _G.SelectedSoundVeil or (_G.SoundOptionsVeil and _G.SoundOptionsVeil[1]) or "Music 1",
    Multi = false,
    Callback = function(Value)
        _G.SelectedSoundVeil = Value
    end
})

SoundSection:Button({
    Name = "▶ Play Sound (Veil)",
    Callback = function()
        if _G.PlaySoundVeil then
            _G.PlaySoundVeil()
            Notify("Sound Veil", "Играем: " .. (_G.SelectedSoundVeil or "Unknown"), 3)
        else
            Notify("Error", "Функция PlaySoundVeil не найдена", 4, ICON_ERR)
        end
    end
})

----------------------------------------------------------------
-- SURVIVORS
----------------------------------------------------------------

local SurvivorsCat = Window:Category("Survivors")

local SurvivorPage = Window:Page({
    Name = "Survivor",
    Icon = "90807912793699",
    Category = SurvivorsCat
})

-- [FIX] раньше эта секция была создана и оставалась пустой
local AutoFarmSection = SurvivorPage:Section({
    Name = "AutoFarm",
    Description = "Автоматические действия",
    Side = 1,
    EnableToggle = true
})

AutoFarmSection:Toggle({
    Name = "Auto Skill Check",
    Flag = "AutoSkillCheck",
    Tooltip = "Автоматическое попадание по скилл-чеку",
    Default = false,
    Callback = function(Value)
        _G.AutoSkillCheck = Value
    end
})

AutoFarmSection:Toggle({
    Name = "Self Heal",
    Flag = "SelfHeal",
    Default = false,
    Callback = function(Value)
        _G.Autoheal = Value
    end
})

AutoFarmSection:Toggle({
    Name = "Bypass Gates",
    Flag = "BypassGates",
    Default = false,
    Callback = function(Value)
        _G.BypassGates = Value
    end
})

local SurvivorThingsSection = SurvivorPage:Section({
    Name = "Things",
    Description = "Защита и передвижение",
    Side = 2,
    EnableToggle = true
})

SurvivorThingsSection:Toggle({
    Name = "Hide Aura",
    Flag = "HideAura",
    Default = false,
    Callback = function(Value)
        _G.AntiAura = Value
    end
})

local PanicTpToggle = SurvivorThingsSection:Toggle({
    Name = "Panic Tp",
    Flag = "PanicTp",
    Tooltip = "Аварийный телепорт",
    Default = false,
    Callback = function(Value)
        _G.PANICTP = Value
    end
})

PanicTpToggle:Keybind({
    Flag = "PanicTpKey",
    Default = Enum.KeyCode.LeftAlt,
    Mode = "Toggle",
    Callback = function()
        PanicTpToggle:Set(not PanicTpToggle:Get())
    end
})

SurvivorThingsSection:Toggle({
    Name = "Disable Collision",
    Flag = "DisableCollision", -- [FIX] был лишний пробел в конце флага
    Default = false,
    Callback = function(Value)
        _G.DisableCollision = Value
    end
})

SurvivorThingsSection:Divider()

local SurvivorSpeedSlider = SurvivorThingsSection:Slider({
    Name = "Survivor Speed",
    Flag = "SurvivorSpeed_Slider",
    Min = 1,
    Max = 25,
    Default = 1,
    Decimals = 1,
    Suffix = " speed",
    Callback = function(Value)
        _G.SurvivorSpeed = Value

        local Character = LocalPlayer.Character

        if Character and _G.SurvivorSpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
            Character:SetAttribute("speedboost", Value)
        end
    end
})

local SurvivorSpeedToggle = SurvivorThingsSection:Toggle({
    Name = "Apply Survivor Speed",
    Flag = "ApplySurvivorSpeed_Toggle",
    Default = false,
    Callback = function(Value)
        _G.SurvivorSpeedToggle = Value

        local Character = LocalPlayer.Character

        if not Character then
            return
        end

        if LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
            Character:SetAttribute("speedboost", Value and (_G.SurvivorSpeed or 1) or 1)
        end
    end
})

SurvivorSpeedToggle:Keybind({
    Flag = "SurvivorSpeedKey",
    Default = Enum.KeyCode.LeftControl,
    Mode = "Hold",
    Callback = function(State)
        SurvivorSpeedToggle:Set(State and true or false)
    end
})

----------------------------------------------------------------
-- TELEPORT
----------------------------------------------------------------

local TeleportCat = Window:Category("Teleport")

local TeleportPage = Window:Page({
    Name = "Teleport",
    Icon = "5160482784",
    Category = TeleportCat
})

-- [FIX] секция была пустой
local TpPlayersSection = TeleportPage:Section({
    Name = "Players",
    Description = "Телепорт к игрокам",
    Side = 1
})

local TpTarget = nil

local TpPlayerListbox = TpPlayersSection:Listbox({
    Flag = "TpPlayerList",
    Items = GetPlayerList(),
    Multi = false,
    Size = 130,
    Callback = function(Value)
        TpTarget = Value
    end
})

TpPlayersSection:Button({
    Name = "Teleport To Player",
    Callback = function()
        if not TpTarget or TpTarget == "No players" then
            Notify("Ошибка", "Сначала выбери игрока", 3, ICON_ERR)
            return
        end

        local Target = Players:FindFirstChild(TpTarget)
        local TargetRoot = Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
        local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not (TargetRoot and MyRoot) then
            Notify("Ошибка", "Персонаж не найден", 3, ICON_ERR)
            return
        end

        MyRoot.CFrame = TargetRoot.CFrame * CFrame.new(0, 0, 3)
        Notify("Teleport", "Переместился к " .. TpTarget, 3)
    end
})

TpPlayersSection:Button({
    Name = "Refresh List",
    Callback = function()
        TpPlayerListbox:Refresh(GetPlayerList())
    end
})

local TpThingsSection = TeleportPage:Section({
    Name = "Things",
    Description = "Точки на карте",
    Side = 2
})

TpThingsSection:Button({
    Name = "Tp To Generator",
    Callback = function()
        FireSignal("GenTeleportSignal", "Телепортирован к генератору!")
    end
})

-- [NEW] нормальный элемент Keybind вместо Textbox, куда надо было руками писать букву.
-- Бинд показывается в Keybind List и сохраняется в конфиг.
TpThingsSection:Keybind({
    Name = "Tp To Generator",
    Flag = "GenKeybind",
    Default = Enum.KeyCode.G,
    Mode = "Toggle",
    Callback = function()
        FireSignal("GenTeleportSignal", "Телепортирован к генератору!")
    end
})

TpThingsSection:Divider()

TpThingsSection:Button({
    Name = "Tp To Hook",
    Callback = function()
        FireSignal("HookTeleportSignal", "Телепортирован к хуку!")
    end
})

TpThingsSection:Keybind({
    Name = "Tp To Hook",
    Flag = "HookKeybind",
    Default = Enum.KeyCode.V,
    Mode = "Toggle",
    Callback = function()
        FireSignal("HookTeleportSignal", "Телепортирован к хуку!")
    end
})

TpThingsSection:Divider()

TpThingsSection:Button({
    Name = "Tp To Exit",
    Callback = function()
        FireSignal("GateTeleportSignal", "Телепортирован к выходу!")
    end
})

TpThingsSection:Keybind({
    Name = "Tp To Exit",
    Flag = "GateKeybind",
    Default = Enum.KeyCode.H,
    Mode = "Toggle",
    Callback = function()
        FireSignal("GateTeleportSignal", "Телепортирован к выходу!")
    end
})

----------------------------------------------------------------
-- EMOTES
----------------------------------------------------------------

local EmotesCat = Window:Category("Emotes/Animations")

local EmotesPage = Window:Page({
    Name = "Emotes",
    Icon = "110748588642372",
    Category = EmotesCat
})

local GameEmotesSection = EmotesPage:Section({
    Name = "Game Emotes",
    Description = "Встроенные эмоции",
    Side = 1
})

local AllEmotes = (getgenv().GetAllEmotes and getgenv().GetAllEmotes()) or { "No Emotes Found" }
local SelectedEmote = AllEmotes[1] or "No Emotes Found"

local EmotesDropdown = GameEmotesSection:Dropdown({
    Name = "Select Emote",
    Flag = "GameEmotes",
    Items = AllEmotes,
    Default = SelectedEmote,
    Multi = false,
    Tooltip = "Список эмоций из игры",
    Callback = function(Value)
        if Value and Value ~= "No Emotes Found" then
            SelectedEmote = Value

            if getgenv().PlayEmoteByName then
                getgenv().PlayEmoteByName(Value)
            end
        end
    end
})

-- [NEW] если эмоции подгрузились позже UI - кнопка подтянет список
GameEmotesSection:Button({
    Name = "Reload Emotes",
    Callback = function()
        local List = (getgenv().GetAllEmotes and getgenv().GetAllEmotes()) or { }

        if #List == 0 then
            Notify("Emotes", "Эмоции не найдены", 3, ICON_ERR)
            return
        end

        EmotesDropdown:Refresh(List)
        Notify("Emotes", "Найдено эмоций: " .. #List, 3)
    end
})

GameEmotesSection:Toggle({
    Name = "Start / Stop Emote",
    Flag = "GameEmoteToggle",
    Default = false,
    Callback = function(Value)
        if Value then
            if SelectedEmote and SelectedEmote ~= "No Emotes Found" and getgenv().PlayEmoteByName then
                getgenv().PlayEmoteByName(SelectedEmote)
            end
        elseif getgenv().StopCurrentEmote then
            getgenv().StopCurrentEmote()
        end
    end
})

GameEmotesSection:Divider()

-- [FIX] у слайдера были поля Increment / ValueName / Color,
-- которых в библиотеке нет (она читает Decimals и Suffix) - шаг не работал
GameEmotesSection:Slider({
    Name = "Emote Speed",
    Flag = "Emote_Speed",
    Min = 1,
    Max = 20,
    Default = 5,
    Decimals = 0.1,
    Suffix = "x",
    Callback = function(Value)
        if getgenv().SetAnimationSpeed then
            getgenv().SetAnimationSpeed(Value)
        end
    end
})

GameEmotesSection:Toggle({
    Name = "Sped Up Emote",
    Flag = "Emote_Speed_Toggle",
    Default = false,
    Callback = function(Value)
        if getgenv().ToggleAnimationSpeed then
            getgenv().ToggleAnimationSpeed(Value)
        end
    end
})

-- [FIX] было Side = 1 вместе с Game Emotes - левая колонка тянулась вниз, правая пустая
local CustomEmotesSection = EmotesPage:Section({
    Name = "Custom Emotes",
    Description = "Анимации по ID",
    Side = 2
})

local CustomEmotes = {
    { Name = "Arm Up", Id = 117042998468241, Type = "standing", Loop = false },
    { Name = "Attack", Id = 133963973694098, Simple = true },
    { Name = "Attack 2", Id = 78935059863801, Type = "standing", Loop = false },
    { Name = "XZ", Id = 80411309607666, Type = "standing", Loop = false },
    { Name = "XZ2", Id = 100092272524635, Type = "standing", Loop = false },
    { Name = "LOL", Id = 129967390, Type = "standing", Loop = false },
    { Name = "Goida", Id = 84440437648153, Simple = true },
    { Name = "Kick", Id = 135181748009911, Type = "standing", Loop = false },
    { Name = "Kick 2", Id = 77210283630654, Type = "standing", Loop = false },
    { Name = "Cracking", Id = 91619171958082, Type = "standing", Loop = true },
}

CustomEmotesSection:Button({
    Name = "Stop Animation",
    Callback = function()
        if _G.StopAnimation then
            _G.StopAnimation()
        end
    end
})

-- [NEW] вместо 10 одинаковых кнопок - один список с поиском и одна кнопка Play
local CustomEmoteNames = { }

for _, Data in ipairs(CustomEmotes) do
    table.insert(CustomEmoteNames, Data.Name)
end

local SelectedCustomEmote = CustomEmoteNames[1]

CustomEmotesSection:Listbox({
    Flag = "CustomEmoteList",
    Items = CustomEmoteNames,
    Multi = false,
    Size = 150,
    Default = SelectedCustomEmote,
    Callback = function(Value)
        SelectedCustomEmote = Value
    end
})

CustomEmotesSection:Button({
    Name = "▶ Play Selected",
    Callback = function()
        if not _G.PlayAnimation then
            Notify("Error", "_G.PlayAnimation не найден", 3, ICON_ERR)
            return
        end

        for _, Data in ipairs(CustomEmotes) do
            if Data.Name == SelectedCustomEmote then
                if Data.Simple then
                    _G.PlayAnimation(Data.Id, "nonlooped")
                else
                    _G.PlayAnimation(Data.Id, Data.Type, Data.Loop, Data.Loop and "looped" or "nonlooped")
                end

                Notify("Animation", "Играем: " .. Data.Name, 2)
                return
            end
        end
    end
})

CustomEmotesSection:Divider()

-- [NEW] свой ID анимации без правки скрипта
local CustomAnimId = ""

CustomEmotesSection:Textbox({
    Flag = "CustomAnimId",
    Default = "",
    Placeholder = "Animation ID", -- [FIX] в старом тексте была опечатка "keyи bind"
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        CustomAnimId = Value
    end
})

local CustomAnimLooped = false

CustomEmotesSection:Toggle({
    Name = "Loop Custom Animation",
    Flag = "CustomAnimLoop",
    Default = false,
    Callback = function(Value)
        CustomAnimLooped = Value
    end
})

CustomEmotesSection:Button({
    Name = "▶ Play Custom ID",
    Callback = function()
        local Id = tonumber(CustomAnimId)

        if not Id then
            Notify("Error", "Введи числовой ID анимации", 3, ICON_ERR)
            return
        end

        if not _G.PlayAnimation then
            Notify("Error", "_G.PlayAnimation не найден", 3, ICON_ERR)
            return
        end

        _G.PlayAnimation(Id, "standing", CustomAnimLooped, CustomAnimLooped and "looped" or "nonlooped")
        Notify("Animation", "Играем ID " .. Id, 2)
    end
})

----------------------------------------------------------------
-- ANIMATIONS
----------------------------------------------------------------

local AnimationsPage = Window:Page({
    Name = "Animations",
    Icon = "110748588642372",
    Category = EmotesCat
})

local CustomAnimationsSection = AnimationsPage:Section({
    Name = "Custom Animations",
    Description = "Замена стандартных анимаций",
    Side = 1
})

-- [NEW] все четыре тумблера были копипастом одного и того же кода -
-- теперь это таблица и один генератор. Добавить новую = одна строка.
local AnimationPresets = {
    { Name = "Crawling", Flag = "CrawlingAnimation", Walk = 78719043959654, Stand = 126526181422628 },
    { Name = "Injured", Flag = "InjuredAnimation", Walk = 135084204086504, Stand = 72208365305487 },
    { Name = "RUNNNN", Flag = "RUNNNNAnimation", Walk = 116093934008204, Stand = 134758728973154 },
    { Name = "BUHOI", Flag = "BUHOIAnimation", Walk = 92098503722633, Stand = 96744338559260 },
}

local AnimationToggles = { }

for _, Preset in ipairs(AnimationPresets) do
    local PresetToggle

    PresetToggle = CustomAnimationsSection:Toggle({
        Name = Preset.Name,
        Flag = Preset.Flag,
        Default = false,
        Callback = function(Value)
            if not Value then
                if _G.StopAnimation then
                    _G.StopAnimation()
                end

                return
            end

            -- [FIX] раньше две анимации могли быть включены одновременно и дрались
            for _, Other in ipairs(AnimationToggles) do
                if Other ~= PresetToggle and Other:Get() then
                    Other:Set(false)
                end
            end

            -- [FIX] было wait(1) в коллбеке — интерфейс вис на 2 секунды при каждом клике
            task.spawn(function()
                if _G.StopAnimation then
                    _G.StopAnimation()
                end

                task.wait(0.35)

                if _G.PlayAnimation then
                    _G.PlayAnimation(Preset.Walk, "walking", true, "looped")
                    task.wait(0.35)
                    _G.PlayAnimation(Preset.Stand, "standing", true, "looped")
                end
            end)
        end
    })

    table.insert(AnimationToggles, PresetToggle)
end

CustomAnimationsSection:Divider()

CustomAnimationsSection:Button({
    Name = "Stop All Animations",
    Callback = function()
        for _, Toggle in ipairs(AnimationToggles) do
            if Toggle:Get() then
                Toggle:Set(false)
            end
        end

        if _G.StopAnimation then
            _G.StopAnimation()
        end
    end
})

local AnimInfoSection = AnimationsPage:Section({
    Name = "Info",
    Description = "Как это работает",
    Side = 2
})

AnimInfoSection:Paragraph({
    Name = "Анимации",
    Text = "Одновременно работает только один пресет: при включении нового старый выключается автоматически."
})

AnimInfoSection:Paragraph({
    Name = "Свой ID",
    Text = "Вкладка Emotes → Custom Emotes → поле Animation ID. Можно запустить любую анимацию без правки скрипта."
})

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------

local SettingsCat = Window:Category("Settings")

local UiPage = Library:CreateUiPage(Window)
table.insert(SettingsCat.Elements, UiPage)

-- [FIX] вторым аргументом раньше шёл nil
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
table.insert(SettingsCat.Elements, SettingsPage)

Window:Init()

----------------------------------------------------------------
-- ЖИВЫЕ ДАННЫЕ (вотермарка, лейблы, прогресс-бар)
----------------------------------------------------------------

-- [NEW] вотермарка. Включается тумблером Settings → Watermark
local FPS = 0
local FrameCount = 0
local FrameTimer = 0

RunService.RenderStepped:Connect(function(Delta)
    FrameCount = FrameCount + 1
    FrameTimer = FrameTimer + Delta

    if FrameTimer >= 1 then
        FPS = FrameCount
        FrameCount = 0
        FrameTimer = 0
    end
end)

local function GetPing()
    local Ok, Value = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)

    return Ok and Value or 0
end

task.spawn(function()
    while task.wait(0.5) do
        if Library.Unloaded then
            break
        end

        local Ping = GetPing()
        local Role = (LocalPlayer.Team and LocalPlayer.Team.Name) or "Lobby"

        Library:Watermark({
            CheatName,
            LocalPlayer.Name,
            Role,
            "FPS: " .. FPS,
            "Ping: " .. Ping .. " ms",
            os.date("%H:%M:%S")
        })

        StatsLabel:SetText("FPS: " .. FPS .. " | Ping: " .. Ping .. " ms")
        RoleLabel:SetText("Role: " .. Role)
        SelectedLabel:SetText("Selected: " .. (SelectedPlayerName or "—"))
        WhitelistLabel:SetText("In whitelist: " .. #(_G.Whitelist or { }))

        local Done = tonumber(_G.GensCompleted)
        local Total = tonumber(_G.GensTotal)

        if Done and Total and Total > 0 then
            GensProgress:Set(math.clamp(math.floor((Done / Total) * 100), 0, 100))
        end
    end
end)

-- [FIX] автообновление всех списков игроков сразу (раньше обновлялся только один)
local function RefreshAllPlayerLists()
    task.wait(0.2)

    local List = GetPlayerList()

    pcall(function() PlayerListbox:Refresh(List) end)
    pcall(function() WhitelistListbox:Refresh(List) end)
    pcall(function() TpPlayerListbox:Refresh(List) end)
end

Players.PlayerAdded:Connect(RefreshAllPlayerLists)
Players.PlayerRemoving:Connect(RefreshAllPlayerLists)

----------------------------------------------------------------

Notify(CheatName, ("UI загружено • модулей %d/%d"):format(Loaded, #Scripts), 5)
