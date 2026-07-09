local Players = game:GetService("Players") --66534535
local LocalPlayer = Players.LocalPlayer

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

LocalPlayer:GetAttributeChangedSignal("RequestPlayerInfo"):Connect(function()
    local targetName = LocalPlayer:GetAttribute("RequestPlayerInfo")
    if not targetName then return end
    
    local target = Players:FindFirstChild(targetName)
    if not target then
        LocalPlayer:SetAttribute("RequestPlayerInfo", nil)
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

    OrionLib:MakeNotification({
        Name = "Информация об игроке",
        Content = message,
        Image = "rbxassetid://4483345998",
        Time = 8
    })

    LocalPlayer:SetAttribute("RequestPlayerInfo", nil)
end)
