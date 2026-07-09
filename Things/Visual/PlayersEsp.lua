local SCRIPT_TAG = "Esp"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local TEAM_COLORS = {
    ["Killer"] = Color3.fromRGB(255, 0, 0),
    ["Survivors"] = Color3.fromRGB(0, 255, 0),
    ["Spectator"] = Color3.fromRGB(255, 255, 255),
    ["Default"] = Color3.fromRGB(255, 255, 255)
}

if _G.EspKiller == nil then _G.EspKiller = false end
if _G.EspSurvivors == nil then _G.EspSurvivors = false end
if _G.EspSpectator == nil then _G.EspSpectator = false end

local activeVisuals = {}

local function isInWhitelist(playerName)
    if not _G.Whitelist then return false end
    return table.find(_G.Whitelist, playerName) ~= nil
end

local function isEspEnabledForTeam(teamName)
    if teamName == "Killer" then return _G.EspKiller end
    if teamName == "Survivors" then return _G.EspSurvivors end
    if teamName == "Spectator" then return _G.EspSpectator end
    return false
end

local function removeESP(player)
    if activeVisuals[player] then
        if activeVisuals[player].Highlight then activeVisuals[player].Highlight:Destroy() end
        if activeVisuals[player].Billboard then activeVisuals[player].Billboard:Destroy() end
        activeVisuals[player] = nil
    end
end

local function createESP(player, character)
    if player == LocalPlayer then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        removeESP(player)
        return
    end

    local isWhitelisted = isInWhitelist(player.Name)

    -- ==================== WHITELIST ESP (НЕОБЫЧНЫЙ) ====================
    if isWhitelisted then
        -- Убираем обычный Highlight
        if activeVisuals[player] and activeVisuals[player].Highlight then
            activeVisuals[player].Highlight:Destroy()
            activeVisuals[player].Highlight = nil
        end

        local billboard = activeVisuals[player] and activeVisuals[player].Billboard
        if not billboard or billboard.Parent ~= rootPart then
            if billboard then billboard:Destroy() end

            billboard = Instance.new("BillboardGui")
            billboard.Name = "WhitelistBillboard"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 250, 0, 80)           -- больше размер
            billboard.StudsOffset = Vector3.new(0, 4, 0)

            local label = Instance.new("TextLabel")
            label.Name = "ESPLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextSize = 18
            label.Font = Enum.Font.Arcade          -- необычный шрифт
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.Parent = billboard

            billboard.Parent = rootPart

            if not activeVisuals[player] then activeVisuals[player] = {} end
            activeVisuals[player].Billboard = billboard
        end

        local label = billboard:FindFirstChild("ESPLabel")
        if label then
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = localRoot and math.floor((localRoot.Position - rootPart.Position).Magnitude) or 0

            label.Text = string.format("★ %s ★\n[WHITELIST]\n%d Studs", player.Name:upper(), distance)
            label.TextColor3 = Color3.fromRGB(0, 255, 255)   -- ярко-голубой
        end
        return
    end

    -- ==================== ОБЫЧНЫЙ ESP ====================
    local team = player.Team
    local teamName = team and team.Name or "NoTeam"
    local isEnabled = isEspEnabledForTeam(teamName)

    if not isEnabled then
        removeESP(player)
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        removeESP(player)
        return
    end

    local teamColor = TEAM_COLORS[teamName] or TEAM_COLORS["Default"]

    if not activeVisuals[player] then
        activeVisuals[player] = {}
    end

    -- Highlight
    local highlight = activeVisuals[player].Highlight
    if not highlight or highlight.Parent ~= character then
        if highlight then highlight:Destroy() end
        highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        activeVisuals[player].Highlight = highlight
    end
    highlight.FillColor = teamColor
    highlight.OutlineColor = teamColor

    -- Billboard
    local billboard = activeVisuals[player].Billboard
    if not billboard or billboard.Parent ~= rootPart then
        if billboard then billboard:Destroy() end
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)

        local label = Instance.new("TextLabel")
        label.Name = "ESPLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        billboard.Parent = rootPart
        activeVisuals[player].Billboard = billboard
    end

    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = localRoot and math.floor((localRoot.Position - rootPart.Position).Magnitude) or 0

    local label = billboard:FindFirstChild("ESPLabel")
    if label then
        label.Text = string.format("%s\n[%d Studs]", player.Name, distance)
        label.TextColor3 = teamColor
    end
end

local connection = RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            createESP(player, character)
        else
            removeESP(player)
        end
    end
end)

local function cleanup()
    if connection then connection:Disconnect() end
    for _, player in ipairs(Players:GetPlayers()) do
        removeESP(player)
    end
    print("ESP cleared")
end

_G[SCRIPT_TAG] = cleanup
print("[ESP + КРАСИВЫЙ WHITELIST] Загружен!")
