if _G.AutoAttackScriptRunning then
	_G.AutoAttackScriptRunning = false
	task.wait(0.3)
end

_G.AutoAttackScriptRunning = true
local currentScriptId = os.clock()
_G.CurrentAutoAttackId = currentScriptId

local MAX_DISTANCE = 5
local ATTACK_COOLDOWN = 1
local TARGET_TEAM_NAME = "Killer"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
local args = { false }

-- Обновленная функция под кастомное Property модели персонажа
local function isCarryingSomething(character)
	if not character then return false end
	
	-- Безопасно проверяем существование свойства в модели (в Workspace)
	local success, result = pcall(function() 
		return character.IsCarrying 
	end)
	
	-- Если свойство прочиталось и оно равно true, возвращаем true
	if success and result == true then
		return true
	end

	return false
end

local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = MAX_DISTANCE

	local localCharacter = LocalPlayer.Character
	if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then 
		return nil 
	end
	
	local localHRP = localCharacter.HumanoidRootPart

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local humanoid = char and char:FindFirstChild("Humanoid")

			if hrp and humanoid and humanoid.Health > 0 then
				local distance = (localHRP.Position - hrp.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

task.spawn(function()
	while _G.AutoAttackScriptRunning and _G.CurrentAutoAttackId == currentScriptId do
		local onCorrectTeam = LocalPlayer.Team and LocalPlayer.Team.Name == TARGET_TEAM_NAME
		local carrying = isCarryingSomething(LocalPlayer.Character)

		if _G.AutoAttackKiller == true and onCorrectTeam and not carrying then
			local target = getClosestPlayer()
			if target then
				AttackRemote:FireServer(unpack(args))
			end
			task.wait(ATTACK_COOLDOWN)
		else
			task.wait(0.1)
		end
	end
end)
