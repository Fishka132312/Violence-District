local SCRIPT_TAG = "HookTeleport"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local TeleportBindable = Instance.new("BindableEvent")
TeleportBindable.Name = "HookTeleportSignal"
TeleportBindable.Parent = LocalPlayer:WaitForChild("PlayerGui")

local hooks = {}
local currentIndex = 0
local lastTeleportTime = 0
local COOLDOWN = 0.6

local currentKey = Enum.KeyCode.V

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function updateHooks()
    hooks = {}
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "Hook" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local rootPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if rootPart then
                table.insert(hooks, rootPart)
            end
        end
    end
end

local function teleportToNextHook()
    if tick() - lastTeleportTime < COOLDOWN then return end
    lastTeleportTime = tick()
    
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
    
    root.CFrame = target.CFrame * CFrame.new(0, 6, 0)
end

local keyConnection
keyConnection = UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == currentKey then
        teleportToNextHook()
    end
end)

TeleportBindable.Event:Connect(teleportToNextHook)

local function setTeleportKey(keyEnum)
    if typeof(keyEnum) == "EnumItem" then
        currentKey = keyEnum
    end
end

local function cleanup()
    if keyConnection then keyConnection:Disconnect() end
    if TeleportBindable then TeleportBindable:Destroy() end
end

_G[SCRIPT_TAG] = cleanup
_G.HookTeleportSetKey = setTeleportKey
