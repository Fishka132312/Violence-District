if _G.SoundPlayerVeilLoaded then return end
_G.SoundPlayerVeilLoaded = true

_G.SoundOptionsVeil = {"Music 1", "Music 2"}
_G.SoundIDsVeil = {
    ["Music 1"] = "70576975385144",
    ["Music 2"] = "83811853473249"
}

_G.SelectedSoundVeil = _G.SoundOptionsVeil[1]
_G.VolumeVeil = "0.5"
_G.DistanceVeil = "50"

_G.PlaySoundVeil = function()
    local plr = game:GetService("Players").LocalPlayer
    if not plr then return end

    local team = plr.Team
    if not (team and team.Name == "Killer" and plr:GetAttribute("SelectedKiller") == "Veil") then
        return
    end

    local char = plr.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hrp = char:WaitForChild("HumanoidRootPart", 3)
        if not hrp then return end
    end

    local soundName = _G.SelectedSoundVeil
    local soundId = _G.SoundIDsVeil[soundName]
    if not soundId then return end

    local vol = tonumber(_G.VolumeVeil) or 0.5
    local dist = tonumber(_G.DistanceVeil) or 50

    local args = {
        tostring(soundId),
        hrp,
        vol,
        dist
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
