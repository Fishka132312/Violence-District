local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local SCRIPT_TAG = "EspWinPallet"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

_G.WinPaletEsp = false
local WIN_PALLET_COLOR = Color3.fromRGB(255, 165, 0)

local activeVisuals = {}

local function isWindowOrPallet(obj)
    if not obj then return false end
    
    local name = obj.Name
    
    if name == "Window" or name == "Pallet" or name == "PalletWrong" or name == "Palletwrong" then
        return true
    end
    
    if CollectionService:HasTag(obj, "VaultPoint") or CollectionService:HasTag(obj, "PalletPoint") or 
       CollectionService:HasTag(obj, "Window") or CollectionService:HasTag(obj, "Pallet") then
        return true
    end
    
    if name:find("Vault") or name:find("Pallet") or name:find("Window") then
        return true
    end
    
    if obj:FindFirstChild("VaultPoint") or obj:FindFirstChild("PalletPoint") or 
       obj:FindFirstChild("WindowFrame") then
        return true
    end
    
    return false
end

local function createESP(target)
    if not _G.WinPaletEsp then return end
    
    local rootPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end
    
    if activeVisuals[target] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WinPalletHighlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.FillColor = WIN_PALLET_COLOR
    highlight.OutlineColor = WIN_PALLET_COLOR
    highlight.Parent = target
    
    activeVisuals[target] = highlight
end

local function removeESP(target)
    if activeVisuals[target] then
        activeVisuals[target]:Destroy()
        activeVisuals[target] = nil
    end
end

local connection = RunService.RenderStepped:Connect(function()
    if not _G.WinPaletEsp then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isWindowOrPallet(obj) then
            createESP(obj)
        end
    end
    
    for target, _ in pairs(activeVisuals) do
        if not target or not target.Parent then
            removeESP(target)
        end
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    for target, _ in pairs(activeVisuals) do
        removeESP(target)
    end
    activeVisuals = {}
end

_G[SCRIPT_TAG] = cleanup
