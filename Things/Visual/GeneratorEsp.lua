local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local SCRIPT_TAG = "EspGen"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

_G.EspGenerators = true
local GEN_COLOR = Color3.fromRGB(0, 255, 100)

local activeGenVisuals = {}

local function isGenerator(obj)
    if not obj then return false end
    
    if obj.Name == "Generator" then return true end
    
    if obj:FindFirstChild("GeneratorBody") or obj:FindFirstChild("RepairPoint") then 
        return true 
    end
    
    if CollectionService:HasTag(obj, "GeneratorPoint") or CollectionService:HasTag(obj, "Generator") then 
        return true 
    end
    
    if obj.Parent and (obj.Parent.Name:find("Gen") or obj.Parent.Name:find("generator")) then
        return true
    end
    
    if obj:GetAttribute("IsGenerator") or obj:GetAttribute("Generator") then
        return true
    end
    
    return false
end

local function createGenESP(genTarget)
    if not _G.EspGenerators then return end
    
    local rootPart = genTarget.PrimaryPart or genTarget:FindFirstChild("GeneratorBody") or 
                     genTarget:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end
    
    if activeGenVisuals[genTarget] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GenHighlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.FillColor = GEN_COLOR
    highlight.OutlineColor = GEN_COLOR
    highlight.Parent = genTarget
    
    activeGenVisuals[genTarget] = highlight
end

local function removeGenESP(genTarget)
    if activeGenVisuals[genTarget] then
        activeGenVisuals[genTarget]:Destroy()
        activeGenVisuals[genTarget] = nil
    end
end

local connection = RunService.RenderStepped:Connect(function()
    if not _G.EspGenerators then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isGenerator(obj) then
            createGenESP(obj)
        end
    end
    
    for genTarget, _ in pairs(activeGenVisuals) do
        if not genTarget or not genTarget.Parent then
            removeGenESP(genTarget)
        end
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    for genTarget, _ in pairs(activeGenVisuals) do
        removeGenESP(genTarget)
    end
    activeGenVisuals = {}
end

_G[SCRIPT_TAG] = cleanup
