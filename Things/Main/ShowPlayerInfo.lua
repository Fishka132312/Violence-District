local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local InfoEvent = Instance.new("BindableEvent")
InfoEvent.Name = "PlayerInfoRequestEvent"

InfoEvent.Event:Connect(function(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then return end

    local info = {
        AllowKiller = target:GetAttribute("AllowKiller") or false,
        EXP = target:GetAttribute("EXP") or 0,
        Level = target:GetAttribute("Level") or 1,
        Platform = target:GetAttribute("platform") or "Unknown",
        Screws = target:GetAttribute("Screws") or 0,
        SelectedKiller = target:GetAttribute("SelectedKiller") or "None",
        Gears = target:GetAttribute("Gears") or 0,
    }

    local message = string.format(
        "👤 Игрок: %s\n\n"..
        "AllowKiller: %s\n"..
        "EXP: %d | Level: %d\n"..
        "Platform: %s\n"..
        "Screws: %d | Gears: %d\n"..
        "SelectedKiller: %s",
        target.Name,
        tostring(info.AllowKiller),
        info.EXP, info.Level,
        info.Platform,
        info.Screws, info.Gears,
        info.SelectedKiller
    )

    if OrionLib then
        OrionLib:MakeNotification({
            Name = "Информация об игроке",
            Content = message,
            Image = "rbxassetid://4483345998",
            Time = 8
        })
    else
        warn("OrionLib не найден!")
    end
end)

LocalPlayer:GetAttributeChangedSignal("RequestPlayerInfo"):Connect(function()
    local targetName = LocalPlayer:GetAttribute("RequestPlayerInfo")
    if targetName and targetName ~= "" then
        InfoEvent:Fire(targetName)
    end
    LocalPlayer:SetAttribute("RequestPlayerInfo", nil)
end)

print("Обработчик информации о игроках запущен")
