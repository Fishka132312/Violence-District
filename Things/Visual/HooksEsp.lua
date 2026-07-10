local SCRIPT_TAG = "EspHooks"
if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HOOK_COLOR = Color3.fromRGB(180, 0, 255)
if _G.HooksEsp == nil then
    _G.HooksEsp = false
end
local activeHookVisuals = {}
local function getMapFolder()
    return workspace:FindFirstChild("Map")
end
local function removeHookESP(hookTarget)
    if activeHookVisuals[hookTarget] then
        if activeHookVisuals[hookTarget].Highlight then
            activeHookVisuals[hookTarget].Highlight:Destroy()
        end
        activeHookVisuals[hookTarget] = nil
    end
end
local function createHookESP(hookTarget)
    if not _G.HooksEsp then
        removeHookESP(hookTarget)
        return
    end
    local rootPart = hookTarget:IsA("Model") and (hookTarget.PrimaryPart or hookTarget:FindFirstChildWhichIsA("BasePart")) or hookTarget
    if not rootPart then return end
    if not activeHookVisuals[hookTarget] then
        activeHookVisuals[hookTarget] = {}
    end
    local highlight = activeHookVisuals[hookTarget].Highlight
    if not highlight or highlight.Parent ~= hookTarget then
        if highlight then highlight:Destroy() end
       
        highlight = Instance.new("Highlight")
        highlight.Name = "HookHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = HOOK_COLOR
        highlight.OutlineColor = HOOK_COLOR
        highlight.Parent = hookTarget
        activeHookVisuals[hookTarget].Highlight = highlight
    end
end
local connection
connection = RunService.RenderStepped:Connect(function()
    local mapFolder = getMapFolder()
   
    if mapFolder and _G.HooksEsp then
        for _, obj in ipairs(mapFolder:GetDescendants()) do
            if obj.Name == "Hook" and (obj:IsA("Model") or obj:IsA("BasePart")) then
                createHookESP(obj)
            end
        end
       
        for hookTarget, _ in pairs(activeHookVisuals) do
            if not hookTarget or not hookTarget:IsDescendantOf(mapFolder) then
                removeHookESP(hookTarget)
            end
        end
    else
        for hookTarget, _ in pairs(activeHookVisuals) do
            removeHookESP(hookTarget)
        end
    end
end)
local function cleanup()
    if connection then connection:Disconnect() end
    for hookTarget, _ in pairs(activeHookVisuals) do
        removeHookESP(hookTarget)
    end
end
_G[SCRIPT_TAG] = cleanup
