local SCRIPT_TAG = "GenTeleport"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportBindable = Instance.new("BindableEvent")
TeleportBindable.Name = "GenTeleportSignal"

local generators = {}
local currentIndex = 0
local lastTeleportTime = 0
local COOLDOWN = 0.2

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function updateGenerators()
    generators = {}
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local rootPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if rootPart then
                table.insert(generators, rootPart)
            end
        end
    end
end

local function teleportToNext()
    if tick() - lastTeleportTime < COOLDOWN then return end
    lastTeleportTime = tick()
    
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    updateGenerators()
    if #generators == 0 then return end
    
    currentIndex = currentIndex + 1
    if currentIndex > #generators then currentIndex = 1 end
    
    local target = generators[currentIndex]
    if not target then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
end

TeleportBindable.Event:Connect(teleportToNext)

local function cleanup()
    if TeleportBindable then
        TeleportBindable:Destroy()
    end
end

_G[SCRIPT_TAG] = cleanup
