local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

_G.Autoheal = false

spawn(function()
    while true do
        if _G.Autoheal and humanoid.Health < humanoid.MaxHealth * 0.95 then
            local healTarget = character.HumanoidRootPart
            
            local healRemote = game:GetService("ReplicatedStorage").Remotes.Healing.HealEvent
            if healRemote then
                healRemote:FireServer(healTarget, true)
            end
        end
        wait(0.35)
    end
end)

print("Auto Heal скрипт загружен!")
print("Используй _G.Autoheal = true  -- чтобы включить")
print("Используй _G.Autoheal = false -- чтобы выключить")
