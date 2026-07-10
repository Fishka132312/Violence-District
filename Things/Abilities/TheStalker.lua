if _G.StalkerActive then return end
_G.StalkerActive = true
if _G.Stalker == nil then _G.Stalker = false end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Stalker"):WaitForChild("StartStalking")

while true do
	task.wait(0.2)
	if not _G.Stalker then continue end
	if not lp.Team or lp.Team.Name ~= "Killer" then continue end
	if lp:GetAttribute("SelectedKiller") ~= "Stalker" then continue end
	local char = lp.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
	local myPos = char.HumanoidRootPart.Position
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			local pchar = plr.Character
			if pchar and pchar:FindFirstChild("HumanoidRootPart") then
				if (myPos - pchar.HumanoidRootPart.Position).Magnitude <= 100 then
					remote:FireServer(plr)
				end
			end
		end
	end
end
