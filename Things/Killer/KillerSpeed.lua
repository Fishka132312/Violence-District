local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local currentSession = os.clock()
_G.ScriptSessionID = currentSession
_G.KillerSpeed = _G.KillerSpeed or 25
_G.SpeedToggle = _G.SpeedToggle or false

local SCRIPT_TAG = "KillerSpeedMonitor"

if _G[SCRIPT_TAG] then 
    _G[SCRIPT_TAG]() 
end

local function cleanup()
    if _G.SpeedEnforcer then 
        pcall(function() _G.SpeedEnforcer:Disconnect() end)
        _G.SpeedEnforcer = nil
    end
    if _G.CharacterAddedConnection then 
        pcall(function() _G.CharacterAddedConnection:Disconnect() end)
        _G.CharacterAddedConnection = nil
    end
    _G.ScriptSessionID = nil
end

_G[SCRIPT_TAG] = cleanup

if _G.SpeedEnforcer then
    pcall(function() _G.SpeedEnforcer:Disconnect() end)
end

_G.SpeedEnforcer = RunService.Heartbeat:Connect(function()
    if _G.ScriptSessionID ~= currentSession then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if not _G.SpeedToggle then
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
        return
    end
    
    local isKiller = LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
    
    if isKiller then
        if hum.WalkSpeed ~= _G.KillerSpeed then
            hum.WalkSpeed = _G.KillerSpeed
        end
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end
end)

if _G.CharacterAddedConnection then
    pcall(function() _G.CharacterAddedConnection:Disconnect() end)
end

_G.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.ScriptSessionID ~= currentSession then return end
    
    task.delay(0.12, function()
        if _G.ScriptSessionID ~= currentSession then return end
        if not _G.SpeedToggle then return end
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Killer" then return end
        
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = _G.KillerSpeed
        end
    end)
end)

if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
        hum.WalkSpeed = _G.KillerSpeed
    end
end

