local player = game.Players.LocalPlayer

if getgenv().AnimationSpeedController then
    getgenv().AnimationSpeedController:Destroy()
end

local Controller = {
    currentSpeed = 1,
    isEnabled = false,
    connections = {}
}

function Controller:applySpeed(character)
    if not character or not character:FindFirstChild("Humanoid") then return end
    local humanoid = character.Humanoid
    
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(self.isEnabled and self.currentSpeed or 1)
    end
end

function Controller:setupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    table.insert(self.connections, humanoid.AnimationPlayed:Connect(function(track)
        task.wait(0.05)
        track:AdjustSpeed(self.isEnabled and self.currentSpeed or 1)
    end))
    
    self:applySpeed(char)
end

table.insert(Controller.connections, player.CharacterAdded:Connect(function(char)
    Controller:setupCharacter(char)
end))

if player.Character then
    Controller:setupCharacter(player.Character)
end

getgenv().SetAnimationSpeed = function(speed)
    Controller.currentSpeed = math.clamp(speed, 0.1, 20)
    if Controller.isEnabled then
        Controller:applySpeed(player.Character)
    end
end

getgenv().ToggleAnimationSpeed = function(enabled)
    Controller.isEnabled = enabled
    Controller:applySpeed(player.Character)
end

getgenv().AnimationSpeedController = Controller
