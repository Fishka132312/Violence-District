_G.DisableCollision = _G.DisableCollision or false

if _G.CollisionLoop then
    _G.CollisionLoop:Disconnect()
end

_G.CollisionLoop = game:GetService("RunService").Heartbeat:Connect(function()
    if not _G.CollisionLoopActive then
        _G.CollisionLoopActive = true
        spawn(function()
            while _G.CollisionLoop do
                local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Collision")
                if _G.DisableCollision then
                    remotes:WaitForChild("DisableCollision"):FireServer()
                else
                    remotes:WaitForChild("EnableCollision"):FireServer()
                end
                wait(5)
            end
            _G.CollisionLoopActive = nil
        end)
    end
end)
