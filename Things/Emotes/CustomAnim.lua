local Players = game:GetService("Players")
local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local currentTrack = nil
local currentAnimType = nil
local animConnection = nil

local function stopCurrentAnimation()
	if currentTrack then
		pcall(function() currentTrack:Stop() end)
		currentTrack = nil
	end
	currentAnimType = nil
	if animConnection then
		animConnection:Disconnect()
		animConnection = nil
	end
end

local function PlayAnimation(animId, animType)
	stopCurrentAnimation()
	if not animId then return end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(animId)
	currentTrack = humanoid:LoadAnimation(anim)
	currentAnimType = animType

	if currentAnimType == "standing" or currentAnimType == "walking" then
		currentTrack.Looped = true
	end

	if currentAnimType == "standing" then
		if humanoid.MoveDirection.Magnitude < 0.1 then
			currentTrack:Play()
		end
	elseif currentAnimType == "walking" then
		if humanoid.MoveDirection.Magnitude > 0.1 then
			currentTrack:Play()
		end
	else
		currentTrack:Play()
		currentAnimType = nil
		return
	end

	animConnection = humanoid.Running:Connect(function(speed)
		if not currentTrack or not currentAnimType then return end

		local isMoving = speed > 0.1

		if currentAnimType == "standing" then
			if isMoving and currentTrack.IsPlaying then
				stopCurrentAnimation()
			end

		elseif currentAnimType == "walking" then
			if isMoving then
				if not currentTrack.IsPlaying then
					currentTrack:Play()
				end
			else
				if currentTrack.IsPlaying then
					currentTrack:Stop()
				end
			end
		end
	end)
end

_G.PlayAnimation = PlayAnimation

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	stopCurrentAnimation()
end)
