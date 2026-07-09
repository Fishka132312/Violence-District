local scriptId = "BypassGates"

if getgenv()[scriptId] then
    getgenv()[scriptId]:Disconnect()
end

local originalStates = {}
local map = workspace:WaitForChild("Map")

local function getGateState()
    local enabledGates = 0
    local totalGates = 0
    
    for _, gate in ipairs(map:GetChildren()) do
        if gate.Name == "Gate" and gate:IsA("Model") then
            totalGates += 1
            local isBypassed = false
            
            for _, part in ipairs(gate:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsDescendantOf(gate:FindFirstChild("ExitLever") or Instance.new("Folder")) then
                    if part.Transparency == 1 and not part.CanCollide then
                        isBypassed = true
                        break
                    end
                end
            end
            
            if isBypassed then
                enabledGates += 1
            end
        end
    end
    
    if totalGates == 0 then
        return "❌ Гейты не найдены"
    elseif enabledGates == totalGates then
        return "✅ Все гейты **выключены** (bypass активен)"
    elseif enabledGates == 0 then
        return "🔴 Все гейты **включены** (bypass выключен)"
    else
        return string.format("⚠️ Частично: %d/%d гейтов выключено", enabledGates, totalGates)
    end
end

local function updateGates(bypassActive)
    for _, gate in ipairs(map:GetChildren()) do
        if gate.Name == "Gate" and gate:IsA("Model") then
            for _, descendant in ipairs(gate:GetDescendants()) do
                if descendant:IsA("BasePart") and not descendant:IsDescendantOf(gate:FindFirstChild("ExitLever") or Instance.new("Folder")) then
                    
                    if bypassActive then
                        if not originalStates[descendant] then
                            originalStates[descendant] = {
                                Transparency = descendant.Transparency,
                                CanCollide = descendant.CanCollide
                            }
                        end
                        descendant.Transparency = 1
                        descendant.CanCollide = false
                    else
                        if originalStates[descendant] then
                            descendant.Transparency = originalStates[descendant].Transparency
                            descendant.CanCollide = originalStates[descendant].CanCollide
                        else
                            descendant.CanCollide = true
                        end
                    end
                end
            end
        end
    end
end

if _G.BypassGates == nil then
    _G.BypassGates = false
end

local lastState = nil
local connection

connection = game:GetService("RunService").Heartbeat:Connect(function()
    local currentState = _G.BypassGates
    
    if currentState ~= lastState then
        lastState = currentState
        updateGates(currentState)
        
        print("🔄 BypassGates:", currentState and "ON" or "OFF")
        print(getGateState())
    end
end)

getgenv()[scriptId] = connection
