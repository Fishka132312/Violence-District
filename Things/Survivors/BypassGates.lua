local scriptId = "BypassGates"

if getgenv()[scriptId] then
    getgenv()[scriptId]:Disconnect()
end

local RunService = game:GetService("RunService")

local originalStates = {}
local lastState = nil

local function getAllGates()
    local gates = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            if obj.Name:lower():find("gate") or obj:FindFirstChild("ExitLever") then
                table.insert(gates, obj)
            end
        end
    end
    return gates
end

local function updateGates(enable)
    local gates = getAllGates()
    for _, gate in ipairs(gates) do
        for _, descendant in ipairs(gate:GetDescendants()) do
            if descendant:IsA("BasePart") then
                local lever = gate:FindFirstChild("ExitLever")
                if lever and descendant:IsDescendantOf(lever) then
                    continue
                end

                if enable then
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
                    end
                end
            end
        end
    end
end

if _G.BypassGates == nil then
    _G.BypassGates = false
end

local connection = RunService.Heartbeat:Connect(function()
    local current = _G.BypassGates

    if current ~= lastState then
        lastState = current
        updateGates(current)
    end
end)

getgenv()[scriptId] = connection
