local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))() ---вфвыфвф
local Window = OrionLib:MakeWindow({Name = "Violence District", HidePremium = false, SaveConfig = true, ConfigFolder = "Violence District meowl"})

local scripts = {
    'Emotes.lua',
	'Killer/AutoAttack.lua',
	'Killer/AutoCarry.lua',
	'Killer/KillerSpeed.lua',
	'Visual/PlayersEsp.lua',
	'Visual/GeneratorEsp.lua',
	'Visual/HooksEsp.lua',
	'Survivors/BypassGates.lua',
	'Whitelist.lua',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/Violence-District/refs/heads/main/Things/'

_G.EmoteList = _G.EmoteList or {}
_G.SelectedEmote = _G.SelectedEmote or nil
_G.EmoteLoopActive = _G.EmoteLoopActive or false

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

if #_G.EmoteList == 0 then
    _G.EmoteList = {"Эмоции не найдены"}
end

-------------------------Survivors---------------------------

local Tab = Window:MakeTab({
	Name = "Survivors",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddToggle({
	Name = "Bypass Gates",
	Default = false,
	Callback = function(Value)
		_G.BypassGates = Value
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

-------------------------Killer---------------------------

local Tab = Window:MakeTab({
	Name = "Killer",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
    Name = "Whitelist Manager"
})

local PlayerDropdown = Tab:AddDropdown({
    Name = "Choose Player",
    Default = "Загрузка игроков...",
    Options = _G.PlayerList or {"Загрузка..."},
    Callback = function(Value)
        _G.SelectedPlayer = Value
        print("Choosed: " .. Value)
    end
})

Tab:AddButton({
    Name = "Add / Remove Whitelist",
    Callback = function()
        local selected = _G.SelectedPlayer
        
        if not selected or selected == "Загрузка игроков..." or selected == "Нет игроков" then
            print("❌ Choose Player")
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

task.spawn(function()
    while task.wait(5) do
        if PlayerDropdown and typeof(PlayerDropdown.Refresh) == "function" then
            local options = _G.PlayerList or {}
            if #options == 0 then
                options = {"Нет игроков"}
            end
            PlayerDropdown:Refresh(options)
        end
    end
end)

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

-------------------------Emotes---------------------------

local Tab = Window:MakeTab({
	Name = "Emotes",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddDropdown({
	Name = "Choose Emote",
	Default = _G.EmoteList[1], 
	Options = _G.EmoteList, 
	Callback = function(Value)
		if Value ~= "Эмоции не найдены" then
			_G.SelectedEmote = Value
			print("Выбрана эмоция: " .. tostring(_G.SelectedEmote))
		end
	end    
})

Tab:AddToggle({
	Name = "Start Emote",
	Default = false,
	Callback = function(Value)
		_G.EmoteLoopActive = Value
		if Value then
			print("Цикл эмоции запущен для: " .. tostring(_G.SelectedEmote))
		else
			print("Цикл эмоции остановлен.")
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
