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
    if _G.SpeedBoostConnection then
        pcall(function() _G.SpeedBoostConnection:Disconnect() end)
        _G.SpeedBoostConnection = nil
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
    
    if not _G.SpeedToggle then
        if char:GetAttribute("speedboost") ~= 0 then
            char:SetAttribute("speedboost", 0)
        end
        return
    end
    
    if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
        char:SetAttribute("speedboost", _G.KillerSpeed)
    else
        if char:GetAttribute("speedboost") ~= 0 then
            char:SetAttribute("speedboost", 0)
        end
    end
end)

local function setupBoostWatcher(character)
    if _G.SpeedBoostConnection then
        pcall(function() _G.SpeedBoostConnection:Disconnect() end)
    end
    
    _G.SpeedBoostConnection = character:GetAttributeChangedSignal("speedboost"):Connect(function()
        if _G.ScriptSessionID ~= currentSession then return end
        if not _G.SpeedToggle then return end
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Killer" then return end
        
        if character:GetAttribute("speedboost") ~= _G.KillerSpeed then
            character:SetAttribute("speedboost", _G.KillerSpeed)
        end
    end)
end

if _G.CharacterAddedConnection then
    pcall(function() _G.CharacterAddedConnection:Disconnect() end)
end

_G.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.ScriptSessionID ~= currentSession then return end
    
    task.delay(0.15, function()
        if _G.ScriptSessionID ~= currentSession then return end
        if not _G.SpeedToggle then return end
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Killer" then return end
        
        if character then
            character:SetAttribute("speedboost", _G.KillerSpeed)
            setupBoostWatcher(character)
        end
    end)
end)

if LocalPlayer.Character then
    local char = LocalPlayer.Character
    if _G.SpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
        char:SetAttribute("speedboost", _G.KillerSpeed)
    end
    setupBoostWatcher(char)
end
