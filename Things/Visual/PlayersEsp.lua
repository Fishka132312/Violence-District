local SCRIPT_TAG = "Esp" -------656546
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
local lastLoggedState = {} -- Для предотвращения спама принтами

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
    
    local team = player.Team
    local teamName = team and team.Name or "NoTeam"
    
    local isEnabled = isEspEnabledForTeam(teamName)
    
    -- ДЕБАГ ПРИНТ 1: Пишет в консоль один раз при смене статуса команды игрока
    local logKey = player.Name .. "_" .. teamName .. "_" .. tostring(isEnabled)
    if lastLoggedState[player.Name] ~= logKey then
        lastLoggedState[player.Name] = logKey
        print(string.format("[ESP DEBUG] Игрок: %s | Команда в игре: '%s' | ESP для неё включен? %s", player.Name, teamName, tostring(isEnabled)))
        print(string.format("[ESP DEBUG] Текущие глобалки: Killer=%s, Survivors=%s, Spectator=%s", tostring(_G.EspKiller), tostring(_G.EspSurvivors), tostring(_G.EspSpectator)))
    end

    if not isEnabled then
        removeESP(player)
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    -- ДЕБАГ ПРИНТ 2: Если ESP включен, но у персонажа нет нужных частей
    if not rootPart or not humanoid then
        if not rootPart then warn("[ESP WARN] У " .. player.Name .. " не найден HumanoidRootPart!") end
        if not humanoid then warn("[ESP WARN] У " .. player.Name .. " не найден Humanoid!") end
        removeESP(player)
        return 
    end
    
    if humanoid.Health <= 0 then
        removeESP(player)
        return
    end

    local teamColor = TEAM_COLORS[teamName] or TEAM_COLORS["Default"]

    if not activeVisuals[player] then
        activeVisuals[player] = {}
        print("[ESP SUCCESS] Создаем подсветку для игрока: " .. player.Name)
    end

    -- Создание/обновление Highlight
    local highlight = activeVisuals[player].Highlight
    if not highlight or highlight.Parent ~= character then
        if highlight then highlight:Destroy() end
        highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillAlpha = 0.25
        highlight.OutlineAlpha = 1
        highlight.Parent = character
        activeVisuals[player].Highlight = highlight
    end
    highlight.FillColor = teamColor
    highlight.OutlineColor = teamColor

    -- Создание/обновление BillboardGui
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
    local distance = 0
    if localRoot then
        distance = math.floor((localRoot.Position - rootPart.Position).Magnitude)
    end
    
    local label = billboard:FindFirstChild("ESPLabel")
    if label then
        label.Text = string.format("%s\n[%d Studs]", player.Name, distance)
        label.TextColor3 = teamColor
    end
end

local connection
connection = RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            -- Убрали pcall, чтобы видеть реальные ошибки в F9, если они возникнут
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
    print("cleared")
end

_G[SCRIPT_TAG] = cleanup
print("[ESP INITIALIZED] Скрипт запущен, ждем переключения тугглов...")
