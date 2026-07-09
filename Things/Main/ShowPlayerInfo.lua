local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local OrionLib = _G.OrionLib or getgenv().OrionLib

local InfoEvent = Instance.new("BindableEvent")
InfoEvent.Name = "PlayerInfoRequestEvent"

InfoEvent.Event:Connect(function(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then 
        warn("Target not found:", targetName)
        return 
    end

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
        "👤 Player: %s\n\n"..
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
        print("[PlayerInfo] Notification:\n" .. message)
    end
end)

LocalPlayer:GetAttributeChangedSignal("RequestPlayerInfo"):Connect(function()
    local targetName = LocalPlayer:GetAttribute("RequestPlayerInfo")
    
    print("[DEBUG] Attribute changed! Value =", targetName)
    
    if targetName and targetName ~= "" then
        task.spawn(function()
            InfoEvent:Fire(targetName)
        end)
    end
    
    task.delay(0.1, function()
        if LocalPlayer:GetAttribute("RequestPlayerInfo") == targetName then
            LocalPlayer:SetAttribute("RequestPlayerInfo", nil)
        end
    end)
end)

print("Обработчик информации о игроках запущен ✅")
