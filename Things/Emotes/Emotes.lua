local ReplicatedStorage = game:GetService("ReplicatedStorage") --5434234234
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local emotesFolder = ReplicatedStorage:WaitForChild("Emotes")

local currentTrack = nil
local currentEmoteName = nil

local function playEmote(emoteName)
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
    end

    local emoteFolder = emotesFolder:FindFirstChild(emoteName)
    if not emoteFolder then
        warn("Emote not found:", emoteName)
        return false
    end

    local animId = emoteFolder:GetAttribute("animationid")
    
    if not animId then
        warn("Attribute 'animationid' not found in emote:", emoteName)
        return false
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animId

    currentTrack = humanoid:LoadAnimation(animation)
    currentTrack.Priority = Enum.AnimationPriority.Action
    currentTrack:Play()

    currentEmoteName = emoteName
    print("✅ Playing emote:", emoteName, "| ID:", animId)
    return true
end

local function stopEmote()
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
        currentEmoteName = nil
        print("⛔ Emote stopped")
    end
end

getgenv().PlayEmoteByName = playEmote
getgenv().StopCurrentEmote = stopEmote
getgenv().GetAllEmotes = function()
    local list = {}
    for _, folder in ipairs(emotesFolder:GetChildren()) do
        if folder:IsA("Folder") then
            table.insert(list, folder.Name)
        end
    end
    table.sort(list)
    return list
end
