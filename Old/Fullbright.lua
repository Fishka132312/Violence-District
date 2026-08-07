local Lighting = game:GetService("Lighting") ---вфвфвфвфвфв
local RunService = game:GetService("RunService")

if _G.FullBrightHandler then
    _G.FullBrightHandler:Destroy()
end

local storage = Instance.new("Folder")
storage.Name = "FullBrightStorage"
storage.Parent = nil

_G.Fullbridthlol = _G.Fullbridthlol or false

local removed = {}
local connection = nil
local lastState = false
local handler = Instance.new("BindableEvent")

_G.FullBrightHandler = handler

local function moveToStorage(child)
    if child and child.Parent == Lighting then
        child.Parent = storage
        table.insert(removed, child)
    end
end

local function clearEffects()
    removed = {}
    for _, v in ipairs(Lighting:GetChildren()) do
        if not v:IsA("Terrain") and not v:IsA("Camera") then
            moveToStorage(v)
        end
    end
end

local function restoreEffects()
    for _, v in ipairs(removed) do
        if v and v.Parent == storage then
            v.Parent = Lighting
        end
    end
    removed = {}
end

local function onChildAdded(child)
    if _G.Fullbridthlol and child.Parent == Lighting then
        if not child:IsA("Terrain") and not child:IsA("Camera") then
            moveToStorage(child)
        end
    end
end

local function updateState()
    if _G.Fullbridthlol then
        if not connection then
            connection = Lighting.ChildAdded:Connect(onChildAdded)
        end
        clearEffects()
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
        restoreEffects()
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

local heartbeatConn = RunService.Heartbeat:Connect(function()
    if _G.Fullbridthlol ~= lastState then
        lastState = _G.Fullbridthlol
        updateState()
    end
end)

handler.Event:Connect(function()
    heartbeatConn:Disconnect()
    if connection then
        connection:Disconnect()
    end
    restoreEffects()
    storage:Destroy()
end)
