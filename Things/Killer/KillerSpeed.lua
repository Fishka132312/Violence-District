local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentSession = os.clock()
_G.ScriptSessionID = currentSession

_G.KillerSpeed = _G.KillerSpeed or 25
_G.SpeedToggle = _G.SpeedToggle or false

local SCRIPT_TAG = "KillerSpeedMonitor"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local isChangingSpeed = false

local function monitorSpeed(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    local function applySpeed()
        if not _G.SpeedToggle then 
            humanoid.WalkSpeed = 16
            return 
        end
        if LocalPlayer.Team and LocalPlayer.Team.Name ~= "Killer" then 
            humanoid.WalkSpeed = 16
            return 
        end
        
        isChangingSpeed = true
        humanoid.WalkSpeed = _G.KillerSpeed
        isChangingSpeed = false
    end

    if _G.SpeedConnection then
        _G.SpeedConnection:Disconnect()
    end

    _G.SpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if _G.ScriptSessionID ~= currentSession then return end
        if isChangingSpeed then return end
        if _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
            applySpeed()
        end
    end)

    if _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
        applySpeed()
    end
end

if LocalPlayer.Character then
    task.spawn(monitorSpeed, LocalPlayer.Character)
end

if _G.CharacterAddedConnection then
    _G.CharacterAddedConnection:Disconnect()
end
_G.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.ScriptSessionID == currentSession then
        task.spawn(monitorSpeed, character)
    end
end)

_G[SCRIPT_TAG] = function()
    if _G.SpeedConnection then _G.SpeedConnection:Disconnect() end
    if _G.CharacterAddedConnection then _G.CharacterAddedConnection:Disconnect() end
    _G.ScriptSessionID = nil
end
