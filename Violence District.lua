local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))() ---вфафывфвфвфв
local Window = OrionLib:MakeWindow({Name = "Violence District", HidePremium = false, SaveConfig = true, ConfigFolder = "Violence District meowl"})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
    'Emotes/Emotes.lua',
	'Emotes/AnimationSpeed.lua',
	'Emotes/CustomAnim.lua',
	'Killer/AutoAttack.lua',
	'Killer/AutoCarry.lua',
	'Killer/KillerSpeed.lua',
	'Visual/PlayersEsp.lua',
	'Visual/GeneratorEsp.lua',
	'Visual/HooksEsp.lua',
	'Visual/WindowsPalletsEsp.lua',
	'Survivors/BypassGates.lua',
	'Survivors/SelfHeal.lua',
	'Survivors/SurvivorSpeed.lua',
	'Survivors/AutoSkillCheck.lua',
	'Survivors/DisCollision.lua',
	'Survivors/AntiAura.lua',
	'Whitelist.lua',
	'Main/ShowPlayerInfo.lua',
	'Main/Fullbright.lua',
	'Teleport/TpToGate.lua',
	'Teleport/TpToGen.lua',
	'Teleport/TpToHook.lua',
	'Abilities/TheSlasher.lua',
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

-------------------------Main---------------------------

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = Tab:AddSection({
    Name = "Show Player Info"
})

local selectedPlayerName = nil

local PlayerInfoDropdown = Tab:AddDropdown({
    Name = "Choose Player",
    Default = "",
    Options = {},
    Callback = function(Value)
        selectedPlayerName = Value
    end
})

Tab:AddButton({
    Name = "Show Info",
    Callback = function()
        if not selectedPlayerName or selectedPlayerName == "" then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Choose Player First!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end

        local target = Players:FindFirstChild(selectedPlayerName)
        if not target then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Player not Found!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end

        LocalPlayer:SetAttribute("RequestPlayerInfo", selectedPlayerName)
        
        print("✅ Запрос на информацию об игроке отправлен: " .. selectedPlayerName)
    end
})

Tab:AddButton({
    Name = "🔄 Refresh List",
    Callback = function()
        local options = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(options, plr.Name)
            end
        end
        table.sort(options)
        if #options == 0 then options = {"No Players"} end
        PlayerInfoDropdown:Refresh(options)
    end
})

task.spawn(function()
    task.wait(1)
    local options = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then 
            table.insert(options, plr.Name) 
        end
    end
    table.sort(options)
    PlayerInfoDropdown:Refresh(options)
end)

local Section = Tab:AddSection({
    Name = "Lightning"
})

Tab:AddToggle({
	Name = "Fullbright",
	Default = false,
	Callback = function(Value)
		_G.Fullbridthlol = Value
	end    
})

-------------------------Visual---------------------------

local Tab = Window:MakeTab({
	Name = "Visual",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Players"
})

Tab:AddToggle({
	Name = "Esp Killer",
	Default = false,
	Callback = function(Value)
		_G.EspKiller = Value
	end    
})

Tab:AddToggle({
	Name = "Esp Survivors",
	Default = false,
	Callback = function(Value)
		_G.EspSurvivors = Value
	end    
})

Tab:AddToggle({
	Name = "Esp Spectator",
	Default = false,
	Callback = function(Value)
		_G.EspSpectator = Value
	end    
})

local Section = Tab:AddSection({
	Name = "Things"
})

Tab:AddToggle({
	Name = "Esp Generators",
	Default = false,
	Callback = function(Value)
		_G.EspGenerators = Value
	end    
})

Tab:AddToggle({
	Name = "Esp Hooks",
	Default = false,
	Callback = function(Value)
		_G.HooksEsp = Value
	end    
})

Tab:AddToggle({
	Name = "Esp Windows/Pallets",
	Default = false,
	Callback = function(Value)
		_G.WinPaletEsp = Value
	end    
})

-------------------------Killer---------------------------

local Tab = Window:MakeTab({
	Name = "Killer",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "WhiteList"
})

local PlayerDropdown = Tab:AddDropdown({
    Name = "Choose Player",
    Default = "",
    Options = {},
    Callback = function(Value)
        _G.SelectedPlayer = Value
        print("Выбран: " .. Value)
    end
})

Tab:AddButton({
    Name = "Add / Remove from Whitelist",
    Callback = function()
        local selected = _G.SelectedPlayer
        
        if not selected or selected == "" then
            print("❌ Please select a player first")
            return
        end

        local index = table.find(_G.Whitelist, selected)
        
        if index then
            table.remove(_G.Whitelist, index)
            print("➖ " .. selected .. " removed from whitelist")
        else
            table.insert(_G.Whitelist, selected)
            print("✅ " .. selected .. " added to whitelist")
        end
    end
})

Tab:AddButton({
    Name = "🔄 Refresh list",
    Callback = function()
        local options = _G.PlayerList or {}
        if #options == 0 then
            options = {"Нет игроков"}
        else
            table.sort(options)
        end
        PlayerDropdown:Refresh(options)
        print("Список обновлён")
    end
})

local Section = Tab:AddSection({
	Name = "Auto"
})

Tab:AddToggle({
	Name = "Auto Attack",
	Default = false,
	Callback = function(Value)
		_G.AutoAttackKiller = Value
	end    
})

Tab:AddToggle({
	Name = "Auto Carry",
	Default = false,
	Callback = function(Value)
		_G.AutoCarry = Value
	end    
})

Tab:AddToggle({
	Name = "Auto Hook",
	Default = false,
	Callback = function(Value)
		_G.AutoHook = Value
	end    
})

local Section = Tab:AddSection({
	Name = "Misc"
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Tab:AddSlider({
    Name = "Killer Speed",
    Min = 1,
    Max = 25,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "speed",
    Callback = function(Value)
        _G.KillerSpeed = Value
        
        local char = LocalPlayer.Character
        if char and _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
            char:SetAttribute("speedboost", Value)
        end
    end
})

Tab:AddToggle({
    Name = "Apply speed",
    Default = false,
    Callback = function(Value)
        _G.SpeedToggle = Value
        
        local char = LocalPlayer.Character
        if not char then return end
        
        if Value and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
            char:SetAttribute("speedboost", _G.KillerSpeed)
        else
            char:SetAttribute("speedboost", 0)
        end
    end
})

local Tab = Window:MakeTab({
	Name = "Abilities",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "The Slasher"
})

Tab:AddToggle({
	Name = "Inf Abilities",
	Default = false,
	Callback = function(Value)
		_G.Slasher1 = Value
	end    
})

local Section = Tab:AddSection({
	Name = "The Slasher"
})

Tab:AddToggle({
	Name = "Inf Abilities",
	Default = false,
	Callback = function(Value)
		_G.Slasher1 = Value
	end    
})

local Section = Tab:AddSection({
	Name = "The Stalker"
})

Tab:AddToggle({
	Name = "Auto Stalking",
	Default = false,
	Callback = function(Value)
		_G.Stalker = Value
	end    
})
-------------------------Survivors---------------------------

local Tab = Window:MakeTab({
	Name = "Survivors",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Survivors"
})

Tab:AddToggle({
	Name = "SelfHeal",
	Default = false,
	Callback = function(Value)
		_G.Autoheal = Value
	end    
})

Tab:AddToggle({
	Name = "Bypass Gates",
	Default = false,
	Callback = function(Value)
		_G.BypassGates = Value
	end    
})

Tab:AddToggle({
	Name = "Auto Skill Check",
	Default = false,
	Callback = function(Value)
		_G.AutoSkillCheck = Value
	end    
})

Tab:AddToggle({
	Name = "Hide Aura",
	Default = false,
	Callback = function(Value)
		_G.AntiAura = Value
	end    
})

Tab:AddToggle({
	Name = "Disable Collision",
	Default = false,
	Callback = function(Value)
		_G.DisableCollision = Value
	end    
})

local Section = Tab:AddSection({
Name = "Speed"
})

Tab:AddSlider({
    Name = "Survivor Speed",
    Min = 1,
    Max = 25,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "speed",
    Callback = function(Value)
        _G.SurvivorSpeed = Value
        
        local character = LocalPlayer.Character
        if character and _G.SurvivorSpeedToggle 
           and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
            
            character:SetAttribute("speedboost", Value)
        end
    end
})

Tab:AddToggle({
    Name = "Apply Survivor Speed",
    Default = false,
    Callback = function(Value)
        _G.SurvivorSpeedToggle = Value
        
        local character = LocalPlayer.Character
        if not character then return end
        
        if Value and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
            character:SetAttribute("speedboost", _G.SurvivorSpeed)
        else
            character:SetAttribute("speedboost", 0)
        end
    end
})

-------------------------Teleport---------------------------

local Tab = Window:MakeTab({
	Name = "Teleport",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Teleport"
})

Tab:AddButton({
	Name = "Tp To Generator",
	Callback = function()
			local signal = LocalPlayer.PlayerGui:FindFirstChild("GenTeleportSignal")
if signal then signal:Fire() end
		end    
})

Tab:AddTextbox({
    Name = "Generator Keybing",
    Default = "G",
    TextDisappear = true,
    Callback = function(Value)
        local success, key = pcall(function()
            return Enum.KeyCode[Value]
        end)
        if success and key then
            _G.GenTeleportSetKey(key)
        end
    end
})

Tab:AddButton({
	Name = "Tp To Hook",
	Callback = function()
			local signal = LocalPlayer.PlayerGui:FindFirstChild("HookTeleportSignal")
if signal then signal:Fire() end
		end    
})

Tab:AddTextbox({
    Name = "Hook Keybind",
    Default = "V",
    TextDisappear = true,
    Callback = function(Value)
        local success, key = pcall(function()
            return Enum.KeyCode[Value]
        end)
        if success and key then
            _G.HookTeleportSetKey(key)
        end
    end
})

Tab:AddButton({
	Name = "Tp To Exit",
	Callback = function()
			local signal = LocalPlayer.PlayerGui:FindFirstChild("GateTeleportSignal")
if signal then signal:Fire() end
  	end    
})

Tab:AddTextbox({
    Name = "Gate Keybing",
    Default = "H",
    TextDisappear = true,
    Callback = function(Value)
        local success, key = pcall(function()
            return Enum.KeyCode[Value]
        end)
        if success and key then
            _G.GateTeleportSetKey(key)
        end
    end
})



-------------------------Emotes---------------------------

local Tab = Window:MakeTab({
	Name = "Emotes",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Emotes"
})

task.wait(1.5)

local allEmotes = getgenv().GetAllEmotes and getgenv().GetAllEmotes() or {"No Emotes Found"}

local selectedEmote = allEmotes[1] or "No Emotes Found"

Tab:AddDropdown({
    Name = "Select Emote",
    Default = selectedEmote,
    Options = allEmotes,
    Callback = function(Value)
        if Value and Value ~= "No Emotes Found" then
            selectedEmote = Value
            getgenv().PlayEmoteByName(Value)
        end
    end
})

Tab:AddToggle({
    Name = "Start / Stop Emote",
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

Tab:AddSlider({
    Name = "Emote Speed",
    Min = 1,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255, 100, 100),
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        currentSliderValue = Value
        if getgenv().SetAnimationSpeed then
            getgenv().SetAnimationSpeed(Value)
        end
    end
})

Tab:AddToggle({
    Name = "Sped Up Emote",
    Default = false,
    Callback = function(Value)
        if getgenv().ToggleAnimationSpeed then
            getgenv().ToggleAnimationSpeed(Value)
        end
    end
})

local Section = Tab:AddSection({
	Name = "Custom Emote"
})

--_G.PlayAnimation(135084204086504, false, "standing")
--_G.PlayAnimation(135181748009911, true, "walking")

Tab:AddButton({
	Name = "Stop Emote",
	Callback = function()
			_G.StopAnimation()
  	end    
})

Tab:AddButton({
	Name = "Arm Up",
	Callback = function()
			_G.PlayAnimation(117042998468241, "standing", false, "nonlooped")
  	end    
})

Tab:AddButton({
	Name = "Attack",
	Callback = function()
			_G.PlayAnimation(133963973694098, "nonlooped")
  	end    
})

Tab:AddButton({
	Name = "LOL",
	Callback = function()
			_G.PlayAnimation(129967390, "standing", false, "nonlooped")
  	end    
})

Tab:AddButton({
	Name = "Goida",
	Callback = function()
			_G.PlayAnimation(84440437648153, "nonlooped")
  	end    
})

Tab:AddButton({
	Name = "Kick Generator",
	Callback = function()
			_G.PlayAnimation(135181748009911, "standing", false, "nonlooped")
  	end    
})

Tab:AddButton({
	Name = "Cracking",
	Callback = function()
			_G.PlayAnimation(91619171958082, "standing", true, "looped")
  	end    
})


local Section = Tab:AddSection({
	Name = "Animation Packs"
})

Tab:AddButton({
	Name = "Ползать",
	Callback = function()
			_G.PlayAnimation(78719043959654, "walking", true, "looped")
			wait(0.1)
			_G.PlayAnimation(126526181422628, "standing", true, "looped")
  	end    
})

Tab:AddButton({
	Name = "Injured",
	Callback = function()
			_G.PlayAnimation(135084204086504, "walking", true, "looped")
			wait(0.1)
			_G.PlayAnimation(72208365305487, "standing", true, "looped")
  	end    
})
-------------------------Shader---------------------------

local Tab = Window:MakeTab({
	Name = "Shaders",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Shaders"
})

Tab:AddButton({
	Name = "Meowl Shaders",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/Shaders/MeowlShaders.lua'))()  
  	end    
})

--------------------------------MISC-----------------------------

local Tab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Tools"
})

Tab:AddButton({
	Name = "Infinite Yield",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/ignore-it/refs/heads/main/infiniteyield'))()
  	end    
})

Tab:AddButton({
	Name = "Destroy Gui",
	Callback = function()
    OrionLib:Destroy()
    end    
})

OrionLib:Init()
