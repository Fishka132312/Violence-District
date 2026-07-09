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

local function getHooksFolder()
    local map = workspace:FindFirstChild("Map")
    if map then
        return map:FindFirstChild("Hooks")
    end
    return nil
end

local function removeHookESP(hookModel)
    if activeHookVisuals[hookModel] then
        if activeHookVisuals[hookModel].Highlight then activeHookVisuals[hookModel].Highlight:Destroy() end
        if activeHookVisuals[hookModel].Billboard then activeHookVisuals[hookModel].Billboard:Destroy() end
        activeHookVisuals[hookModel] = nil
    end
end

local function createHookESP(hookModel)
    if not _G.HooksEsp then
        removeHookESP(hookModel)
        return
    end

    local rootPart = hookModel.PrimaryPart or hookModel:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end

    if not activeHookVisuals[hookModel] then
        activeHookVisuals[hookModel] = {}
    end

    local highlight = activeHookVisuals[hookModel].Highlight
    if not highlight or highlight.Parent ~= hookModel then
        if highlight then highlight:Destroy() end
        highlight = Instance.new("Highlight")
        highlight.Name = "HookHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = HOOK_COLOR
        highlight.OutlineColor = HOOK_COLOR
        highlight.Parent = hookModel
        activeHookVisuals[hookModel].Highlight = highlight
    end

    local billboard = activeHookVisuals[hookModel].Billboard
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
        activeHookVisuals[hookModel].Billboard = billboard
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
    local hookFolder = getHooksFolder()
    
    if hookFolder and _G.HooksEsp then
        for _, hook in ipairs(hookFolder:GetChildren()) do
            if hook:IsA("Model") then
                createHookESP(hook)
            end
        end
    else
        for hookModel, _ in pairs(activeHookVisuals) do
            removeHookESP(hookModel)
        end
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    for hookModel, _ in pairs(activeHookVisuals) do
        removeHookESP(hookModel)
    end
    print("Hook ESP cleared")
end

_G[SCRIPT_TAG] = cleanup
print("[HOOK ESP INITIALIZED] Скрипт крюков запущен!")
