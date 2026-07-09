local SCRIPT_TAG = "GateTeleport"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function findAllGates()
    local mapFolder = getMapFolder()
    if not mapFolder then return {} end
    
    local gates = {}
    
    for _, obj in ipairs(mapFolder:GetChildren()) do
        if obj.Name == "Gate" and obj:IsA("Model") then
            table.insert(gates, obj)
        end
    end
    
    return gates
end

if _G.GateCycleIndex == nil then
    _G.GateCycleIndex = 1
end

local function teleportToNextGate()
    local gates = findAllGates()
    
    if #gates == 0 then
        print("❌ Ворота не найдены!")
        return
    end
    
    local currentIndex = _G.GateCycleIndex
    local targetGate = gates[currentIndex]
    
    local rootPart = targetGate.PrimaryPart or targetGate:FindFirstChildWhichIsA("BasePart")
    
    if not rootPart then
        _G.GateCycleIndex = (_G.GateCycleIndex % #gates) + 1
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local hrp = character.HumanoidRootPart
    hrp.CFrame = rootPart.CFrame * CFrame.new(0, 5, 0)
    
    print(string.format("📍 Ворота %d/%d", currentIndex, #gates))
    
    _G.GateCycleIndex = (_G.GateCycleIndex % #gates) + 1
end

local function cleanup()
    print("GateCycleTP cleared")
    _G.GateCycleIndex = nil
end

_G[SCRIPT_TAG] = cleanup

print("[GATE CYCLE TP] Загружен! Пиши в чат: gate")

local chatConnection = LocalPlayer.Chatted:Connect(function(msg)
    local text = msg:lower()
    if text == "gate" or text == "nextgate" then
        teleportToNextGate()
    end
end)

_G[SCRIPT_TAG .. "_chat"] = chatConnection
