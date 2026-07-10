if _G.SoundPlayerLoaded then return end
_G.SoundPlayerLoaded = true
_G.SoundOptions = {"Music 1", "Music 2"}
_G.SoundIDs = {["Sound 1"] = "70576975385144", ["Sound 2"] = "83811853473249"}
_G.SelectedSound = _G.SoundOptions[1]
_G.Volume = "0.5"
_G.Distance = "50"
_G.PlaySound = function()
    local plr = game:GetService("Players").LocalPlayer
    if not plr then return end
    local team = plr.Team
    if not (team and team.Name == "Killer" and plr:GetAttribute("SelectedKiller") == "Killer") then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hrp = char:WaitForChild("HumanoidRootPart", 3)
        if not hrp then return end
    end
    local soundName = _G.SelectedSound
    local soundId = _G.SoundIDs[soundName]
    if not soundId then return end
    local vol = tonumber(_G.Volume) or 0.5
    local dist = tonumber(_G.Distance) or 50
    local args = {tostring(soundId), hrp, vol, dist, true}
    local rs = game:GetService("ReplicatedStorage")
    local remotes = rs:WaitForChild("Remotes", 5)
    if remotes then
        local sp = remotes:FindFirstChild("SoundPlayer") or remotes:WaitForChild("SoundPlayer", 5)
        if sp then sp:FireServer(unpack(args)) end
    end
end
