local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

if _G.AntiAuraConnection then
    _G.AntiAuraConnection:Disconnect()
end
if _G.AntiAuraCharConn then
    _G.AntiAuraCharConn:Disconnect()
end

if _G.AntiAura == nil then
    _G.AntiAura = false
end

local function disableSprint(char)
    if not char or not _G.AntiAura then return end
    if char:GetAttribute("Sprint") == true then
        char:SetAttribute("Sprint", false)
    end
end

_G.AntiAuraConnection = RunService.Heartbeat:Connect(function()
    if not _G.AntiAura then return end
    local char = player.Character
    if char then
        disableSprint(char)
    end
end)

_G.AntiAuraCharConn = player.CharacterAdded:Connect(function(char)
    if not _G.AntiAura then return end
    
    task.wait(0.1)
    disableSprint(char)
    
    char.AttributeChanged:Connect(function(attr)
        if attr == "Sprint" and _G.AntiAura and char:GetAttribute("Sprint") == true then
            char:SetAttribute("Sprint", false)
        end
    end)
end)

if player.Character then
    local char = player.Character
    disableSprint(char)
    
    char.AttributeChanged:Connect(function(attr)
        if attr == "Sprint" and _G.AntiAura and char:GetAttribute("Sprint") == true then
            char:SetAttribute("Sprint", false)
        end
    end)
end
