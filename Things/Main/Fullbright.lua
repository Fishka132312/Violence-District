local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local removed = {}
local connection = nil
local lastState = false

local function clearEffects()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or v:IsA("Sky") then
            table.insert(removed, v)
            v.Parent = nil
        end
    end
end

local function restoreEffects()
    for _, v in ipairs(removed) do
        if v and v.Parent == nil then
            v.Parent = Lighting
        end
    end
    removed = {}
end

local function onChildAdded(child)
    if _G.Fullbridthlol then
        if child:IsA("Atmosphere") or child:IsA("BloomEffect") or child:IsA("DepthOfFieldEffect") or child:IsA("SunRaysEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("BlurEffect") or child:IsA("Sky") then
            table.insert(removed, child)
            child.Parent = nil
        end
    end
end

RunService.Heartbeat:Connect(function()
    if _G.Fullbridthlol ~= lastState then
        lastState = _G.Fullbridthlol
        if _G.Fullbridthlol then
            clearEffects()
            if not connection then
                connection = Lighting.ChildAdded:Connect(onChildAdded)
            end
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
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
end)
