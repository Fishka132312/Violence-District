local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local currentTrack = nil
local currentAnimType = nil
local currentPersist = false
local animationStarted = false
local animConnection = nil
local stoppedConnection = nil
local ignoreNextStopped = false

local function stopCurrentAnimation()
    if currentTrack then
        pcall(function()
            if currentTrack.IsPlaying then
                currentTrack:Stop()
            end
        end)
        currentTrack = nil
    end

    currentAnimType = nil
    currentPersist = false
    animationStarted = false
    ignoreNextStopped = false

    if animConnection then
        pcall(function() animConnection:Disconnect() end)
        animConnection = nil
    end

    if stoppedConnection then
        pcall(function() stoppedConnection:Disconnect() end)
        stoppedConnection = nil
    end
end

local function PlayAnimation(animId, animType, persist)
    stopCurrentAnimation()

    if not animId then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)
    currentTrack = humanoid:LoadAnimation(anim)
    currentAnimType = animType
    currentPersist = persist or false
    animationStarted = false
    ignoreNextStopped = false

    if currentAnimType == "standing" or currentAnimType == "walking" then
        currentTrack.Looped = false
    end

    local isCorrectStateNow = false
    if currentAnimType == "standing" then
        isCorrectStateNow = humanoid.MoveDirection.Magnitude < 0.1
    elseif currentAnimType == "walking" then
        isCorrectStateNow = humanoid.MoveDirection.Magnitude > 0.1
    end

    if isCorrectStateNow then
        currentTrack:Play()
        animationStarted = true
    end

    if currentAnimType ~= "standing" and currentAnimType ~= "walking" then
        currentTrack:Play()
        currentAnimType = nil
        currentPersist = false
        return
    end

    animConnection = humanoid.Running:Connect(function(speed)
        if not currentTrack or not currentAnimType then return end

        local isMoving = speed > 0.1
        local stateIsCorrect = false

        if currentAnimType == "standing" then
            stateIsCorrect = not isMoving
        elseif currentAnimType == "walking" then
            stateIsCorrect = isMoving
        end

        if stateIsCorrect then
            if not currentTrack.IsPlaying then
                if currentPersist or animationStarted then
                    currentTrack:Play()
                    animationStarted = true
                end
            end
        else
            if currentTrack.IsPlaying then
                if currentPersist then
                    ignoreNextStopped = true
                    currentTrack:Stop()
                else
                    stopCurrentAnimation()
                end
            end
        end
    end)

    stoppedConnection = currentTrack.Stopped:Connect(function()
        if ignoreNextStopped then
            ignoreNextStopped = false
            return
        end
        stopCurrentAnimation()
    end)
end

local function StopAnimation()
    stopCurrentAnimation()
end

_G.PlayAnimation = PlayAnimation
_G.StopAnimation = StopAnimation

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    stopCurrentAnimation()
end)
