local SCRIPT_TAG = "GateTeleport"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportBindable = Instance.new("BindableEvent")
TeleportBindable.Name = "GateTeleportSignal"

local gates = {}
local currentIndex = 0
local lastTeleportTime = 0
local COOLDOWN = 0.5

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function updateGates()
    gates = {}
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    for _, obj in ipairs(mapFolder:GetChildren()) do
        if obj.Name == "Gate" and obj:IsA("Model") then
            local rootPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if rootPart then
                table.insert(gates, rootPart)
            end
        end
    end
end

local function teleportToNextGate()
    if tick() - lastTeleportTime < COOLDOWN then return end
    lastTeleportTime = tick()
    
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    updateGates()
    if #gates == 0 then return end
    
    currentIndex = currentIndex + 1
    if currentIndex > #gates then currentIndex = 1 end
    
    local target = gates[currentIndex]
    if not target then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
end

TeleportBindable.Event:Connect(teleportToNextGate)

local function cleanup()
    if TeleportBindable then
        TeleportBindable:Destroy()
    end
end

_G[SCRIPT_TAG] = cleanup
