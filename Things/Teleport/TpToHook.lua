local SCRIPT_TAG = "HookTeleport"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportBindable = Instance.new("BindableEvent")
TeleportBindable.Name = "HookTeleportSignal"

local hooks = {}
local currentIndex = 0
local lastTeleportTime = 0
local COOLDOWN = 0.5

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function updateHooks()
    hooks = {}
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "Hook" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local rootPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if rootPart then
                table.insert(hooks, rootPart)
            end
        end
    end
end

local function teleportToNextHook()
    if tick() - lastTeleportTime < COOLDOWN then return end
    lastTeleportTime = tick()
    
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    updateHooks()
    if #hooks == 0 then return end
    
    currentIndex = currentIndex + 1
    if currentIndex > #hooks then currentIndex = 1 end
    
    local target = hooks[currentIndex]
    if not target then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
end

TeleportBindable.Event:Connect(teleportToNextHook)

local function cleanup()
    if TeleportBindable then
        TeleportBindable:Destroy()
    end
end

_G[SCRIPT_TAG] = cleanup
