local SCRIPT_TAG = "EspWinPallet"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WIN_PALLET_COLOR = Color3.fromRGB(255, 165, 0)

if _G.WinPaletEsp == nil then
    _G.WinPaletEsp = false
end

local activeVisuals = {}

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function removeESP(target)
    if activeVisuals[target] then
        if activeVisuals[target].Highlight then
            activeVisuals[target].Highlight:Destroy()
        end
        activeVisuals[target] = nil
    end
end

local function createESP(target)
    if not _G.WinPaletEsp then
        removeESP(target)
        return
    end

    local rootPart = target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")) or target
    if not rootPart then return end

    if not activeVisuals[target] then
        activeVisuals[target] = {}
    end

    local highlight = activeVisuals[target].Highlight
    if not highlight or highlight.Parent ~= target then
        if highlight then highlight:Destroy() end
        
        highlight = Instance.new("Highlight")
        highlight.Name = "WinPalletHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = WIN_PALLET_COLOR
        highlight.OutlineColor = WIN_PALLET_COLOR
        highlight.Parent = target
        activeVisuals[target].Highlight = highlight
    end
end

local connection
connection = RunService.RenderStepped:Connect(function()
    local mapFolder = getMapFolder()
    
    if mapFolder and _G.WinPaletEsp then
        for _, obj in ipairs(mapFolder:GetDescendants()) do
            if (obj.Name == "Window" or obj.Name == "PalletWrong") 
               and (obj:IsA("Model") or obj:IsA("BasePart")) then
                
                createESP(obj)
            end
        end
        
        for target, _ in pairs(activeVisuals) do
            if not target or not target:IsDescendantOf(mapFolder) then
                removeESP(target)
            end
        end
    else
        for target, _ in pairs(activeVisuals) do
            removeESP(target)
        end
    end
end)

local function cleanup()
    if connection then 
        connection:Disconnect() 
    end
    for target, _ in pairs(activeVisuals) do
        removeESP(target)
    end
end

_G[SCRIPT_TAG] = cleanup
