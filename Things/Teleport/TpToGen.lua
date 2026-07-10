local SCRIPT_TAG = "GenTeleport"
if _G[SCRIPT_TAG] then _G[SCRIPT_TAG]() end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local TeleportBindable = Instance.new("BindableEvent")
TeleportBindable.Name = "GenTeleportSignal"
TeleportBindable.Parent = LocalPlayer:WaitForChild("PlayerGui")

local generators = {}
local currentIndex = 0
local lastTeleportTime = 0
local COOLDOWN = 0.6

local currentKey = Enum.KeyCode.G

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function updateGenerators()
    generators = {}
    local mapFolder = getMapFolder()
    if not mapFolder then return end
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local rootPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if rootPart then
                table.insert(generators, rootPart)
            end
        end
    end
end

local function teleportToNextGenerator()
    if tick() - lastTeleportTime < COOLDOWN then return end
    lastTeleportTime = tick()
    
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
    
    root.CFrame = target.CFrame * CFrame.new(0, 6, 0)
end

local keyConnection
keyConnection = UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == currentKey then
        teleportToNextGenerator()
    end
end)

TeleportBindable.Event:Connect(teleportToNextGenerator)

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
_G.GenTeleportSetKey = setTeleportKey
