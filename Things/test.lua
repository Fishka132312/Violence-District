local player = game.Players.LocalPlayer

local function applyHeadUp(char)
    char:WaitForChild("Torso", 5)
    local neck = char.Torso:WaitForChild("Neck", 3)
    if not neck then return end

    spawn(function()
        while char.Parent and neck.Parent do
            neck.C0 = CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(-85), 0, 0)
            game:GetService("RunService").Heartbeat:Wait()
        end
    end)
end

if player.Character then applyHeadUp(player.Character) end
player.CharacterAdded:Connect(applyHeadUp)

print("Голова вверх применена")
