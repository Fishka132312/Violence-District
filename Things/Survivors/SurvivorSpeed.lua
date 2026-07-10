local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local currentSession = os.clock()
_G.ScriptSessionID = currentSession
_G.SurvivorSpeed = _G.SurvivorSpeed or 1
_G.SurvivorSpeedToggle = _G.SurvivorSpeedToggle or false

local SCRIPT_TAG = "SurvivorSpeedMonitor"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local function cleanup()
    if _G.SurvivorEnforcer then
        pcall(function() _G.SurvivorEnforcer:Disconnect() end)
        _G.SurvivorEnforcer = nil
    end
    if _G.SurvivorBoostConnection then
        pcall(function() _G.SurvivorBoostConnection:Disconnect() end)
        _G.SurvivorBoostConnection = nil
    end
    if _G.SurvivorCharacterAddedConnection then
        pcall(function() _G.SurvivorCharacterAddedConnection:Disconnect() end)
        _G.SurvivorCharacterAddedConnection = nil
    end
    _G.ScriptSessionID = nil
end

_G[SCRIPT_TAG] = cleanup

if _G.SurvivorEnforcer then
    pcall(function() _G.SurvivorEnforcer:Disconnect() end)
end

_G.SurvivorEnforcer = RunService.Heartbeat:Connect(function()
    if _G.ScriptSessionID ~= currentSession then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if not _G.SurvivorSpeedToggle then
        if char:GetAttribute("speedboost") ~= 0 then
            char:SetAttribute("speedboost", 0)
        end
        return
    end
    
    if LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
        char:SetAttribute("speedboost", _G.SurvivorSpeed)
    else
        if char:GetAttribute("speedboost") ~= 0 then
            char:SetAttribute("speedboost", 0)
        end
    end
end)

local function setupSurvivorWatcher(character)
    if _G.SurvivorBoostConnection then
        pcall(function() _G.SurvivorBoostConnection:Disconnect() end)
    end
    
    _G.SurvivorBoostConnection = character:GetAttributeChangedSignal("speedboost"):Connect(function()
        if _G.ScriptSessionID ~= currentSession then return end
        if not _G.SurvivorSpeedToggle then return end
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Survivors" then return end
        
        if character:GetAttribute("speedboost") ~= _G.SurvivorSpeed then
            character:SetAttribute("speedboost", _G.SurvivorSpeed)
        end
    end)
end

if _G.SurvivorCharacterAddedConnection then
    pcall(function() _G.SurvivorCharacterAddedConnection:Disconnect() end)
end

_G.SurvivorCharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.ScriptSessionID ~= currentSession then return end
    
    task.delay(0.15, function()
        if _G.ScriptSessionID ~= currentSession then return end
        if not _G.SurvivorSpeedToggle then return end
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Survivors" then return end
        
        if character then
            character:SetAttribute("speedboost", _G.SurvivorSpeed)
            setupSurvivorWatcher(character)
        end
    end)
end)

if LocalPlayer.Character then
    local char = LocalPlayer.Character
    if _G.SurvivorSpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
        char:SetAttribute("speedboost", _G.SurvivorSpeed)
    end
    setupSurvivorWatcher(char)
end
