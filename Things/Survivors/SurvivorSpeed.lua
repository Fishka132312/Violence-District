local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentSession = os.clock()
_G.ScriptSessionID = currentSession

_G.SurvivorSpeed = _G.SurvivorSpeed or 20
_G.SurvivorSpeedToggle = _G.SurvivorSpeedToggle or false

local SCRIPT_TAG = "SurvivorSpeedMonitor"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local isChangingSpeed = false

local function monitorSpeed(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    local function applySpeed()
        if not _G.SurvivorSpeedToggle then 
            humanoid.WalkSpeed = 16
            return 
        end
        if LocalPlayer.Team and LocalPlayer.Team.Name ~= "Survivors" then 
            humanoid.WalkSpeed = 16
            return 
        end
        
        isChangingSpeed = true
        humanoid.WalkSpeed = _G.SurvivorSpeed
        isChangingSpeed = false
    end

    if _G.SurvivorSpeedConnection then
        _G.SurvivorSpeedConnection:Disconnect()
    end

    _G.SurvivorSpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if _G.ScriptSessionID ~= currentSession then return end
        if isChangingSpeed then return end
        if _G.SurvivorSpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
            applySpeed()
        end
    end)

    if _G.SurvivorSpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
        applySpeed()
    end
end

if LocalPlayer.Character then
    task.spawn(monitorSpeed, LocalPlayer.Character)
end

if _G.SurvivorCharacterAddedConnection then
    _G.SurvivorCharacterAddedConnection:Disconnect()
end
_G.SurvivorCharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.ScriptSessionID == currentSession then
        monitorSpeed(character)
    end
end)

_G[SCRIPT_TAG] = function()
    if _G.SurvivorSpeedConnection then _G.SurvivorSpeedConnection:Disconnect() end
    if _G.SurvivorCharacterAddedConnection then _G.SurvivorCharacterAddedConnection:Disconnect() end
    _G.ScriptSessionID = nil
end
