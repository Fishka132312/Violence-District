local player = game.Players.LocalPlayer
local currentSpeed = 1
local isEnabled = false

local function applySpeed(character)
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(isEnabled and currentSpeed or 1)
    end
end

local function setupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    humanoid.AnimationPlayed:Connect(function(track)
        task.wait(0.05)
        track:AdjustSpeed(isEnabled and currentSpeed or 1)
    end)
    
    applySpeed(char)
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    setupCharacter(player.Character)
end

getgenv().SetAnimationSpeed = function(speed)
    currentSpeed = math.clamp(speed, 0.1, 20)
    if isEnabled then
        applySpeed(player.Character)
    end
end

getgenv().ToggleAnimationSpeed = function(enabled)
    isEnabled = enabled
    applySpeed(player.Character)
end
