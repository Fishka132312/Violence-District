local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentSession = os.clock()
_G.ScriptSessionID = currentSession

_G.KillerSpeed = _G.KillerSpeed or 5
local defaultSpeed = 16

local function updateSpeed(character)
	local humanoid = character:WaitForChild("Humanoid")
	
	if humanoid.WalkSpeed ~= _G.KillerSpeed then
		defaultSpeed = humanoid.WalkSpeed
	end

	task.spawn(function()
		while _G.ScriptSessionID == currentSession and character:IsDescendantOf(workspace) and humanoid and humanoid.Health > 0 do
			if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
				humanoid.WalkSpeed = _G.KillerSpeed
			else
				if humanoid.WalkSpeed ~= defaultSpeed then
					humanoid.WalkSpeed = defaultSpeed
				end
			end
			task.wait(0.1)
		end
	end)
end

if LocalPlayer.Character then
	updateSpeed(LocalPlayer.Character)
end

if _G.CharacterAddedConnection then
	_G.CharacterAddedConnection:Disconnect()
end

_G.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
	if _G.ScriptSessionID == currentSession then
		updateSpeed(character)
	end
end)
