local SCRIPT_TAG = "SurvivorTeleport"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local TeleportBindable = Instance.new("BindableEvent")
TeleportBindable.Name = "SurvivorTeleportSignal"
TeleportBindable.Parent = LocalPlayer:WaitForChild("PlayerGui")

local survivors = {}
local lastTeleportTime = 0
local COOLDOWN = 0.6

local currentKey = Enum.KeyCode.H

local TEAM_NAME = "Survivors"

local function updateSurvivors()
	survivors = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team and plr.Team.Name == TEAM_NAME then
			local character = plr.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if root and humanoid and humanoid.Health > 0 then
					table.insert(survivors, root)
				end
			end
		end
	end
end

local function teleportToRandomSurvivor()
	if tick() - lastTeleportTime < COOLDOWN then return end
	lastTeleportTime = tick()

	updateSurvivors()
	if #survivors == 0 then return end

	local target = survivors[math.random(1, #survivors)]
	if not target then return end

	local character = LocalPlayer.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	root.CFrame = target.CFrame * CFrame.new(0, 6, 0)
end

local keyConnection
keyConnection = UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == currentKey then
		teleportToRandomSurvivor()
	end
end)

TeleportBindable.Event:Connect(teleportToRandomSurvivor)

local function setTeleportKey(keyEnum)
	if typeof(keyEnum) == "EnumItem" then
		currentKey = keyEnum
	end
end

local function cleanup()
	if keyConnection then keyConnection:Disconnect() end
	if TeleportBindable then TeleportBindable:Destroy() end
end

_G[SCRIPT_TAG] = cleanup
_G.SurvivorTeleportSetKey = setTeleportKey
