local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SkillCheckEvent = ReplicatedStorage.Remotes.Generator:WaitForChild("SkillCheckEvent")
local SkillCheckResultEvent = ReplicatedStorage.Remotes.Generator:WaitForChild("SkillCheckResultEvent")

local KingScourgeStart = ReplicatedStorage.Remotes.KillerPerks.kingscourge:WaitForChild("KingScourgeStart")
local KingScourgeHit = ReplicatedStorage.Remotes.KillerPerks.kingscourge:WaitForChild("KingScourgeHit")
local KingScourgeEnd = ReplicatedStorage.Remotes.KillerPerks.kingscourge:WaitForChild("KingScourgeEnd")

local ProgressPrompt = playerGui:WaitForChild("ProgressPromptGui").Frame
local SkillCheckGui = playerGui:WaitForChild("SkillCheckPromptGui").Check
local Line = SkillCheckGui:WaitForChild("Line")
local Goal = SkillCheckGui:WaitForChild("Goal")

local Sounds = {
    Confirm = script:WaitForChild("Confirm"),
    Great = script:WaitForChild("Great"),
    Sound = script:WaitForChild("Sound")
}

_G.AutoSkillCheck = _G.AutoSkillCheck or true   -- ← Включи/выключи авто здесь
_G.AutoDelay = 0.05  -- задержка перед автокликом (чем меньше — тем быстрее)

local isInSkillCheck = false
local isScourgeMode = false
local currentTarget = nil
local connections = {}

local function autoCompleteSkillCheck()
    if not _G.AutoSkillCheck or not isInSkillCheck then return end
    
    task.wait(_G.AutoDelay)
    
    local rotation = Line.Rotation
    local goalRot = Goal.Rotation
    
    local zone1 = 102 + goalRot
    local zone2 = 116 + goalRot
    local zone3 = 159 + goalRot
    
    if zone1 <= rotation and rotation <= zone2 then
        SkillCheckResultEvent:FireServer("success", 1, currentTarget, nil)
        Sounds.Great:Play()
    elseif zone2 < rotation and rotation <= zone3 then
        SkillCheckResultEvent:FireServer("neutral", 0, currentTarget, nil)
        Sounds.Confirm:Play()
    else
        SkillCheckResultEvent:FireServer("fail", -10, currentTarget, nil)
    end
end

-- Основной обработчик обычного skill check
SkillCheckEvent.OnClientEvent:Connect(function(generatorId, part)
    currentTarget = generatorId
    isInSkillCheck = true
    isScourgeMode = false
    
    SkillCheckGui.Visible = true
    Line.Rotation = 0
    Goal.Rotation = math.random(0, 200)
    Sounds.Sound:Play()
    
    -- Авто-клик
    task.delay(0.5, function()
        if isInSkillCheck and _G.AutoSkillCheck then
            autoCompleteSkillCheck()
        end
    end)
end)

-- King Scourge Mode
KingScourgeStart.OnClientEvent:Connect(function(p66, p67, count)
    isScourgeMode = true
    isInSkillCheck = true
    currentTarget = p66
    
    SkillCheckGui.Visible = true
    Line.Rotation = 0
    Goal.Rotation = math.random(0, 200)
    Sounds.Sound:Play()
    
    task.delay(0.5, function()
        if isInSkillCheck and _G.AutoSkillCheck then
            autoCompleteSkillCheck()
        end
    end)
end)

KingScourgeEnd.OnClientEvent:Connect(function()
    isScourgeMode = false
    isInSkillCheck = false
    SkillCheckGui.Visible = false
end)

-- Очистка при смерти/выходе
player.CharacterRemoving:Connect(function()
    isInSkillCheck = false
    isScourgeMode = false
    SkillCheckGui.Visible = false
end)

print("✅ Auto Skill Check загружен! (Auto = " .. tostring(_G.AutoSkillCheck) .. ")")
print("Напиши _G.AutoSkillCheck = false чтобы выключить")
