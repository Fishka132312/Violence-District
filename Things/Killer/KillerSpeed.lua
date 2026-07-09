local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentSession = os.clock()
_G.ScriptSessionID = currentSession

_G.KillerSpeed = _G.KillerSpeed or 5
_G.SpeedToggle = _G.SpeedToggle or false
local defaultSpeed = 16

local isChangingSpeed = false 

local function monitorSpeed(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end
	
	defaultSpeed = humanoid.WalkSpeed

	if _G.SpeedConnection then _G.SpeedConnection:Disconnect() end
	
	_G.SpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if _G.ScriptSessionID ~= currentSession then return end
		if isChangingSpeed then return end
		
		if _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
			if humanoid.WalkSpeed ~= _G.KillerSpeed then
				defaultSpeed = humanoid.WalkSpeed
				
				isChangingSpeed = true
				humanoid.WalkSpeed = _G.KillerSpeed
				isChangingSpeed = false
			end
		else
			defaultSpeed = humanoid.WalkSpeed
		end
	end)

	if _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
		isChangingSpeed = true
		humanoid.WalkSpeed = _G.KillerSpeed
		isChangingSpeed = false
	end
end

if LocalPlayer.Character then
	task.spawn(monitorSpeed, LocalPlayer.Character)
end

if _G.CharacterAddedConnection then _G.CharacterAddedConnection:Disconnect() end
_G.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
	if _G.ScriptSessionID == currentSession then
		monitorSpeed(character)
	end
end)
