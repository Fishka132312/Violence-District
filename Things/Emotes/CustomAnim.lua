local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local currentTrack = nil

local function PlayAnimation(animId)
	if currentTrack then
		currentTrack:Stop()
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(animId)
	currentTrack = humanoid:LoadAnimation(anim)
	currentTrack:Play()
end

_G.PlayAnimation = PlayAnimation
