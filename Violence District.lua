local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))() ---вфафывфвфвфв
local Window = OrionLib:MakeWindow({Name = "Violence District", HidePremium = false, SaveConfig = true, ConfigFolder = "Violence District meowl"})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
    'Emotes/Emotes.lua',
	'Emotes/AnimationSpeed.lua',
	'Killer/AutoAttack.lua',
	'Killer/AutoCarry.lua',
	'Killer/KillerSpeed.lua',
	'Visual/PlayersEsp.lua',
	'Visual/GeneratorEsp.lua',
	'Visual/HooksEsp.lua',
	'Survivors/BypassGates.lua',
	'Survivors/SelfHeal.lua',
	'Survivors/SurvivorSpeed.lua',
	'Survivors/AutoSkillCheck.lua',
	'Whitelist.lua',
	'Main/ShowPlayerInfo.lua',
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

        OrionLib:MakeNotification({
            Name = "Send request",
            Content = "Information " .. selectedPlayerName .. " send...",
            Image = "rbxassetid://4483345998",
            Time = 4
        })
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
        if plr ~= LocalPlayer then table.insert(options, plr.Name) end
    end
    table.sort(options)
    PlayerInfoDropdown:Refresh(options)
end)


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

-------------------------Survivors---------------------------

local Tab = Window:MakeTab({
	Name = "Survivors",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "da"
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

local Section = Tab:AddSection({
Name = "Speed"
})

Tab:AddSlider({
    Name = "Survivor Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "speed",
    Callback = function(Value)
        _G.SurvivorSpeed = Value
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and _G.SurvivorSpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
                humanoid.WalkSpeed = Value
            end
        end
    end
})

Tab:AddToggle({
    Name = "Apply Survivor Speed",
    Default = false,
    Callback = function(Value)
        _G.SurvivorSpeedToggle = Value
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if Value and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
                    humanoid.WalkSpeed = _G.SurvivorSpeed
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end
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
	Min = 0,
	Max = 100,
	Default = 5,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "speed",
	Callback = function(Value)
		_G.KillerSpeed = Value
		
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
				humanoid.WalkSpeed = Value
			end
		end
	end    
})

Tab:AddToggle({
	Name = "Apply speed",
	Default = false,
	Callback = function(Value)
		_G.SpeedToggle = Value
		
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				if Value and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
					humanoid.WalkSpeed = _G.KillerSpeed
				else
					humanoid.WalkSpeed = 16
				end
			end
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
			loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/Violence-District/refs/heads/main/Things/Teleport/TpToGen.lua'))()
  	end    
})

Tab:AddButton({
	Name = "Tp To Hook",
	Callback = function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/Violence-District/refs/heads/main/Things/Teleport/TpToHook.lua'))()
  	end    
})

Tab:AddButton({
	Name = "Tp To Exit",
	Callback = function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/Violence-District/refs/heads/main/Things/Teleport/TpToGate.lua'))()
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
