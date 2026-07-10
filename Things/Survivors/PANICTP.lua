local SCRIPT_TAG = "PanicTP"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PANIC_DISTANCE = 50
local COOLDOWN = 1
local KILLER_TEAM_NAME = "Killer"

local gates = {}
local lastTeleportTime = 0
local heartbeatConnection = nil

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function updateGates()
    gates = {}
    local mapFolder = getMapFolder()
    if not mapFolder then return end

    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "Gate" and obj:IsA("Model") then
            local rootPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if rootPart then
                table.insert(gates, rootPart)
            end
        end
    end
end

local function teleportToRandomGate()
    if tick() - lastTeleportTime < COOLDOWN then return end
    lastTeleportTime = tick()

    updateGates()
    if #gates == 0 then 
        warn("[PanicTP] Гейты не найдены!")
        return 
    end

    local target = gates[math.random(1, #gates)]
    if not target then return end

    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    root.CFrame = target.CFrame * CFrame.new(0, 6, 0)
    print("[PanicTP] Телепорт на гейт сработал!")
end

local function isKiller(player)
    if not player or player == LocalPlayer then return false end
    if not player.Team then return false end
    
    return player.Team.Name == KILLER_TEAM_NAME
end

local function checkForKillers()
    if not _G.PANICTP then return end

    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end

        local otherRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if not otherRoot then continue end

        if isKiller(player) then
            local dist = (root.Position - otherRoot.Position).Magnitude
            if dist <= PANIC_DISTANCE then
                teleportToRandomGate()
                return
            end
        end
    end
end

heartbeatConnection = RunService.Heartbeat:Connect(function()
    checkForKillers()
end)

local function cleanup()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    print("[PanicTP] Скрипт остановлен и очищен.")
end

_G[SCRIPT_TAG] = cleanup

if _G.PANICTP == nil then
    _G.PANICTP = false
end

_G.PanicTP_SetDistance = function(distance)
    if type(distance) == "number" then
        PANIC_DISTANCE = distance
        print("[PanicTP] Новая дистанция: " .. distance .. " studs")
    end
end

_G.PanicTP_SetCooldown = function(cooldown)
    if type(cooldown) == "number" then
        COOLDOWN = cooldown
        print("[PanicTP] Новый кулдаун: " .. cooldown .. " сек")
    end
end

_G.PanicTP_SetTeamName = function(teamName)
    if type(teamName) == "string" then
        KILLER_TEAM_NAME = teamName
        print("[PanicTP] Новое название команды: " .. teamName)
    end
end

_G.PanicTP_ForceTeleport = teleportToRandomGate  -- принудительный телепорт

print("[PanicTP] Скрипт загружен. Используй _G.PANICTP = true/false для управления.")
print("[PanicTP] Доступные команды: _G.PanicTP_SetDistance(), _G.PanicTP_SetCooldown(), _G.PanicTP_SetTeamName()")
