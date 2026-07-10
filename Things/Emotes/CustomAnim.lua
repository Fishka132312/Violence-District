local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local currentTrack = nil
local moveConnection = nil

if _G.PlayAnimation then return end

local function stopCurrent()
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
    end
    if moveConnection then
        moveConnection:Disconnect()
        moveConnection = nil
    end
end

local function PlayAnimation(animId, loop, moveType)
    stopCurrent()

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)

    currentTrack = humanoid:LoadAnimation(anim)
    currentTrack.Priority = Enum.AnimationPriority.Movement

    if loop ~= false then
        currentTrack.Looped = true
    end

    currentTrack:Play()

    if moveType == "standing" or moveType == "walking" then
        moveConnection = RunService.Heartbeat:Connect(function()
            local isMoving = humanoid.MoveDirection.Magnitude > 0.1

            local shouldPlay = false
            if moveType == "standing" then
                shouldPlay = not isMoving
            elseif moveType == "walking" then
                shouldPlay = isMoving
            end

            if shouldPlay then
                if currentTrack and not currentTrack.IsPlaying then
                    currentTrack.TimePosition = 0
                    currentTrack:Play()
                end
            else
                if currentTrack and currentTrack.IsPlaying then
                    currentTrack:Stop()
                end
            end
        end)
    end
end

_G.PlayAnimation = PlayAnimation
_G.StopAnimation = stopCurrent
