local SCRIPT_TAG = "EspGen" --545435
if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GEN_COLOR = Color3.fromRGB(255, 0, 0)

if _G.EspGenerators == nil then _G.EspGenerators = false end

local activeGenVisuals = {}

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function removeGenESP(genTarget)
    if activeGenVisuals[genTarget] then
        if activeGenVisuals[genTarget].Highlight then activeGenVisuals[genTarget].Highlight:Destroy() end
        if activeGenVisuals[genTarget].Billboard then activeGenVisuals[genTarget].Billboard:Destroy() end
        activeGenVisuals[genTarget] = nil
    end
end

local function createGenESP(genTarget)
    if not _G.EspGenerators then
        removeGenESP(genTarget)
        return
    end

    local rootPart = genTarget:IsA("Model") and (genTarget.PrimaryPart or genTarget:FindFirstChildWhichIsA("BasePart")) or genTarget
    if not rootPart then return end

    if not activeGenVisuals[genTarget] then
        activeGenVisuals[genTarget] = {}
    end

    local highlight = activeGenVisuals[genTarget].Highlight
    if not highlight or highlight.Parent ~= genTarget then
        if highlight then highlight:Destroy() end
        highlight = Instance.new("Highlight")
        highlight.Name = "GenHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = GEN_COLOR
        highlight.OutlineColor = GEN_COLOR
        highlight.Parent = genTarget
        activeGenVisuals[genTarget].Highlight = highlight
    end

    local billboard = activeGenVisuals[genTarget].Billboard
    if not billboard or billboard.Parent ~= rootPart then
        if billboard then billboard:Destroy() end
        billboard = Instance.new("BillboardGui")
        billboard.Name = "GenBillboard"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        
        local label = Instance.new("TextLabel")
        label.Name = "GenLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeTransparency = 0
        label.TextColor3 = GEN_COLOR
        label.Parent = billboard
        
        billboard.Parent = rootPart
        activeGenVisuals[genTarget].Billboard = billboard
    end

    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = 0
    if localRoot then
        distance = math.floor((localRoot.Position - rootPart.Position).Magnitude)
    end
    
    local label = billboard:FindFirstChild("GenLabel")
    if label then
        label.Text = string.format("Generator\n[%d Studs]", distance)
    end
end

local connection
connection = RunService.RenderStepped:Connect(function()
    local mapFolder = getMapFolder()
    
    if mapFolder and _G.EspGenerators then
        for _, obj in ipairs(mapFolder:GetDescendants()) do
            if obj.Name == "Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
                createGenESP(obj)
            end
        end
        
        for genTarget, _ in pairs(activeGenVisuals) do
            if not genTarget or not genTarget:IsDescendantOf(mapFolder) then
                removeGenESP(genTarget)
            end
        end
    else
        for genTarget, _ in pairs(activeGenVisuals) do
            removeGenESP(genTarget)
        end
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    for genTarget, _ in pairs(activeGenVisuals) do
        removeGenESP(genTarget)
    end
    print("Generator ESP cleared")
end

_G[SCRIPT_TAG] = cleanup
print("[GEN ESP INITIALIZED] Скрипт генераторов (сканирование всей карты Map) запущен!")
