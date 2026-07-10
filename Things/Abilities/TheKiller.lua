if _G.SoundPlayerKillerLoaded then return end
_G.SoundPlayerKillerLoaded = true

_G.SoundOptionsKiller = {"Music 1", "Music 2"}
_G.SoundIDsKiller = {
    ["Music 1"] = "70576975385144",
    ["Music 2"] = "83811853473249"
}

_G.SelectedSoundKiller = _G.SoundOptionsKiller[1]
_G.VolumeKiller = "0.5"
_G.DistanceKiller = "50"

_G.PlaySoundKiller = function()
    local plr = game:GetService("Players").LocalPlayer
    if not plr then return end

    local team = plr.Team
    if not (team and team.Name == "Killer" and plr:GetAttribute("SelectedKiller") == "Killer") then 
        return 
    end

    local char = plr.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hrp = char:WaitForChild("HumanoidRootPart", 3)
        if not hrp then return end
    end

    local soundName = _G.SelectedSoundKiller
    local soundId = _G.SoundIDsKiller[soundName]
    if not soundId then return end

    local vol = tonumber(_G.VolumeKiller) or 0.5
    local dist = tonumber(_G.DistanceKiller) or 50

    local args = {
        tostring(soundId),
        hrp,
        vol,
        dist,
        true
    }

    local rs = game:GetService("ReplicatedStorage")
    local remotes = rs:WaitForChild("Remotes", 5)
    if remotes then
        local sp = remotes:FindFirstChild("SoundPlayer") or remotes:WaitForChild("SoundPlayer", 5)
        if sp then 
            sp:FireServer(unpack(args)) 
        end
    end
end
