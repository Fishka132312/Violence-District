local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local SCRIPT_TAG = "EspHooks"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

_G.HooksEsp = false
local HOOK_COLOR = Color3.fromRGB(180, 0, 255)

local activeHookVisuals = {}

local function isHook(obj)
    if not obj then return false end
    
    if obj.Name == "Hook" or obj.Name == "MeatHook" then return true end
    
    if obj:FindFirstChild("HookPoint") or obj:FindFirstChild("Hook") or obj:FindFirstChild("HangingPoint") then 
        return true 
    end
    
    if CollectionService:HasTag(obj, "Hook") or CollectionService:HasTag(obj, "MeatHook") then 
        return true 
    end
    
    if obj.Parent and (obj.Parent.Name:find("Hook") or obj.Parent.Name:find("MeatHook")) then
        return true
    end
    
    if obj:GetAttribute("IsHook") or obj:GetAttribute("Hook") then
        return true
    end
    
    return false
end

local function createHookESP(hookTarget)
    if not _G.HooksEsp then return end
    
    local rootPart = hookTarget.PrimaryPart or hookTarget:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end
    
    if activeHookVisuals[hookTarget] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "HookHighlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.FillColor = HOOK_COLOR
    highlight.OutlineColor = HOOK_COLOR
    highlight.Parent = hookTarget
    
    activeHookVisuals[hookTarget] = highlight
end

local function removeHookESP(hookTarget)
    if activeHookVisuals[hookTarget] then
        activeHookVisuals[hookTarget]:Destroy()
        activeHookVisuals[hookTarget] = nil
    end
end

local connection = RunService.RenderStepped:Connect(function()
    if not _G.HooksEsp then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isHook(obj) then
            createHookESP(obj)
        end
    end
    
    for hookTarget, _ in pairs(activeHookVisuals) do
        if not hookTarget or not hookTarget.Parent then
            removeHookESP(hookTarget)
        end
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    for hookTarget, _ in pairs(activeHookVisuals) do
        removeHookESP(hookTarget)
    end
    activeHookVisuals = {}
end

_G[SCRIPT_TAG] = cleanup
