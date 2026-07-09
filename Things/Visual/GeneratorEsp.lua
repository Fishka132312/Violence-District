local SCRIPT_TAG = "EspGen"
if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GEN_COLOR = Color3.fromRGB(255, 0, 0)
if _G.EspGenerators == nil then _G.EspGenerators = false end

local activeGenVisuals = {}

local function getGeneratorsFolder()
    local map = workspace:FindFirstChild("Map")
    if map then
        return map:FindFirstChild("Generators")
    end
    return nil
end

local function removeGenESP(genModel)
    if activeGenVisuals[genModel] then
        if activeGenVisuals[genModel].Highlight then activeGenVisuals[genModel].Highlight:Destroy() end
        if activeGenVisuals[genModel].Billboard then activeGenVisuals[genModel].Billboard:Destroy() end
        activeGenVisuals[genModel] = nil
    end
end

local function createGenESP(genModel)
    if not _G.EspGenerators then
        removeGenESP(genModel)
        return
    end

    local rootPart = genModel.PrimaryPart or genModel:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end

    if not activeGenVisuals[genModel] then
        activeGenVisuals[genModel] = {}
    end

    local highlight = activeGenVisuals[genModel].Highlight
    if not highlight or highlight.Parent ~= genModel then
        if highlight then highlight:Destroy() end
        highlight = Instance.new("Highlight")
        highlight.Name = "GenHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = GEN_COLOR
        highlight.OutlineColor = GEN_COLOR
        highlight.Parent = genModel
        activeGenVisuals[genModel].Highlight = highlight
    end

    local billboard = activeGenVisuals[genModel].Billboard
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
        activeGenVisuals[genModel].Billboard = billboard
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
    local genFolder = getGeneratorsFolder()
    
    if genFolder and _G.EspGenerators then
        for _, gen in ipairs(genFolder:GetChildren()) do
            if gen:IsA("Model") then
                createGenESP(gen)
            end
        end
    else
        for genModel, _ in pairs(activeGenVisuals) do
            removeGenESP(genModel)
        end
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    for genModel, _ in pairs(activeGenVisuals) do
        removeGenESP(genModel)
    end
    print("Generator ESP cleared")
end

_G[SCRIPT_TAG] = cleanup
print("[GEN ESP INITIALIZED] Скрипт генераторов запущен!")
