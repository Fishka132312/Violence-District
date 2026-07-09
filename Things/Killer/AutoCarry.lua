local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local CarryEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent")

_G.AutoCarry = false

local KILLER_TEAM_NAME = "Killer"

local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = 5

	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return nil
	end

	local myPos = LocalPlayer.Character.HumanoidRootPart.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local targetPos = player.Character.HumanoidRootPart.Position
			local distance = (myPos - targetPos).Magnitude

			if distance <= shortestDistance then
				shortestDistance = distance
				closestPlayer = player
			end
		end
	end

	return closestPlayer
end

if _G.AutoCarryConnection then
	_G.AutoCarryConnection:Disconnect()
	_G.AutoCarryConnection = nil
end

_G.AutoCarryConnection = RunService.Heartbeat:Connect(function()
	if not _G.AutoCarry then return end
	
	if not LocalPlayer.Team or LocalPlayer.Team.Name ~= KILLER_TEAM_NAME then 
		return 
	end

	local character = LocalPlayer.Character
	if character and character:GetAttribute("IsCarrying") == true then
		return
	end

	local targetPlayer = getClosestPlayer()
	if targetPlayer and targetPlayer.Character then
		local args = {
			[1] = targetPlayer.Character
		}
		CarryEvent:FireServer(unpack(args))
	end
end)
