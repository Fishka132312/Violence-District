-- === PLAYER LIST UPDATER (отдельный LocalScript) ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

_G.PlayerList = _G.PlayerList or {}
_G.Whitelist = _G.Whitelist or {}
_G.SelectedPlayer = _G.SelectedPlayer or nil

local lastUpdate = 0

local function updatePlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    table.sort(list)
    _G.PlayerList = list
    print("[PlayerUpdater] Список обновлён: " .. #list .. " игроков")
end

updatePlayerList()

RunService.Heartbeat:Connect(function()
    if tick() - lastUpdate >= 5 then
        updatePlayerList()
        lastUpdate = tick()
    end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

print("=== Player List Updater запущен ===")
