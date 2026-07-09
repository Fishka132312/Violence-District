local scriptId = "BypassGates"
if getgenv()[scriptId] then
    getgenv()[scriptId]:Disconnect()
end

local originalStates = {}
local map = workspace:WaitForChild("Map")

local function updateGates(bypassActive)
    for _, gate in ipairs(map:GetChildren()) do
        if gate.Name == "Gate" and gate:IsA("Model") then
            
            for _, descendant in ipairs(gate:GetDescendants()) do
                if descendant:IsA("BasePart") and not descendant:IsDescendantOf(gate:FindFirstChild("ExitLever")) then
                    
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
    end
end)

getgenv()[scriptId] = connection
