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
    if _G.SpeedChangedConnection then
        pcall(function() _G.SpeedChangedConnection:Disconnect() end)
        _G.SpeedChangedConnection = nil
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

    if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
        hum.WalkSpeed = _G.KillerSpeed
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end
end)

local function setupSpeedWatcher(humanoid)
    if _G.SpeedChangedConnection then
        pcall(function() _G.SpeedChangedConnection:Disconnect() end)
    end

    _G.SpeedChangedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if _G.ScriptSessionID ~= currentSession then return end
        if not _G.SpeedToggle then return end
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Killer" then return end

        humanoid.WalkSpeed = _G.KillerSpeed
    end)
end

if _G.CharacterAddedConnection then
    pcall(function() _G.CharacterAddedConnection:Disconnect() end)
end

_G.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.ScriptSessionID ~= currentSession then return end

    task.delay(0.1, function()
        if _G.ScriptSessionID ~= currentSession then return end
        if not _G.SpeedToggle then return end
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Killer" then return end

        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = _G.KillerSpeed
            setupSpeedWatcher(hum)
        end
    end)
end)

if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
            hum.WalkSpeed = _G.KillerSpeed
        end
        setupSpeedWatcher(hum)
    end
end
