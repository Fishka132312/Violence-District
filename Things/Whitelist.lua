local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if _G.PlayerListUpdaterRunning then
    warn("PlayerListUpdater уже работает!")
    return
end
_G.PlayerListUpdaterRunning = true

_G.PlayerList = {}
_G.Whitelist = _G.Whitelist or {}
_G.SelectedPlayer = _G.SelectedPlayer or nil

local function updatePlayerList()
    local newList = {}
   
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            table.insert(newList, plr.Name)
        end
    end
   
    table.sort(newList)
    _G.PlayerList = newList
   
    print("[PlayerUpdater] Обновлено: " .. #newList .. " игроков")
end

updatePlayerList()

RunService.Heartbeat:Connect(function()
    if tick() % 5 < 0.05 then
        updatePlayerList()
    end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

print("=== Player List Updater (без дубликатов) загружен ===")
