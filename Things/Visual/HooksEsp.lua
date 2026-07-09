local SCRIPT_TAG = "EspHooks"
if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HOOK_COLOR = Color3.fromRGB(180, 0, 255) 

if _G.HooksEsp == nil then _G.HooksEsp = false end

local activeHookVisuals = {}

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function removeHookESP(hookTarget)
    if activeHookVisuals[hookTarget] then
        if activeHookVisuals[hookTarget].Highlight then activeHookVisuals[hookTarget].Highlight:Destroy() end
        if activeHookVisuals[hookTarget].Billboard then activeHookVisuals[hookTarget].Billboard:Destroy() end
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

    local billboard = activeHookVisuals[hookTarget].Billboard
    if not billboard or billboard.Parent ~= rootPart then
        if billboard then billboard:Destroy() end
        billboard = Instance.new("BillboardGui")
        billboard.Name = "HookBillboard"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        
        local label = Instance.new("TextLabel")
        label.Name = "HookLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeTransparency = 0
        label.TextColor3 = HOOK_COLOR
        label.Parent = billboard
        
        billboard.Parent = rootPart
        activeHookVisuals[hookTarget].Billboard = billboard
    end

    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = 0
    if localRoot then
        distance = math.floor((localRoot.Position - rootPart.Position).Magnitude)
    end
    
    local label = billboard:FindFirstChild("HookLabel")
    if label then
        label.Text = string.format("Hook\n[%d Studs]", distance)
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
    print("Hook ESP cleared")
end

_G[SCRIPT_TAG] = cleanup
print("[HOOK ESP INITIALIZED] Скрипт крюков (поиск в Map) запущен!")
