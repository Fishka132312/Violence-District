local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local currentTrack = nil
local currentEmoteName = nil

local humanoid = nil

-- Функция обновления humanoid при респавне
local function updateHumanoid(newCharacter)
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
    end
    
    humanoid = newCharacter:WaitForChild("Humanoid")
    
    print("✅ Humanoid updated for new character")
end

-- Инициализация
if player.Character then
    updateHumanoid(player.Character)
end

player.CharacterAdded:Connect(updateHumanoid)

local emotesFolder = ReplicatedStorage:WaitForChild("Emotes")

local function playEmote(emoteName)
    if not humanoid then
        warn("Humanoid not found!")
        return false
    end

    -- Останавливаем предыдущую анимацию
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

-- Глобальные функции
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

-- Дополнительно: останавливаем анимацию при смерти
player.CharacterRemoving:Connect(function()
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
    end
end)
