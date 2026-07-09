local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentSession = os.clock()
_G.ScriptSessionID = currentSession

_G.SurvivorSpeed = _G.SurvivorSpeed or 16
_G.SurvivorSpeedToggle = _G.SurvivorSpeedToggle or false

local defaultSpeed = 16
local isChangingSpeed = false

local function monitorSpeed(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    defaultSpeed = humanoid.WalkSpeed
    
    if _G.SurvivorSpeedConnection then 
        _G.SurvivorSpeedConnection:Disconnect() 
    end
    
    _G.SurvivorSpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if _G.ScriptSessionID ~= currentSession then return end
        if isChangingSpeed then return end
        
        if _G.SurvivorSpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
            if humanoid.WalkSpeed ~= _G.SurvivorSpeed then
                defaultSpeed = humanoid.WalkSpeed
                isChangingSpeed = true
                humanoid.WalkSpeed = _G.SurvivorSpeed
                isChangingSpeed = false
            end
        else
            defaultSpeed = humanoid.WalkSpeed
        end
    end)
    
    if _G.SurvivorSpeedToggle and LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then
        isChangingSpeed = true
        humanoid.WalkSpeed = _G.SurvivorSpeed
        isChangingSpeed = false
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

print("✅ Survivor Speed Monitor Loaded Successfully")
