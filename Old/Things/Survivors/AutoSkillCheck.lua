-- // Auto Skill Check - Идеальное попадание
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local SkillCheckEvent = ReplicatedStorage.Remotes.Generator:WaitForChild("SkillCheckEvent")
local SkillCheckResult = ReplicatedStorage.Remotes.Generator:WaitForChild("SkillCheckResultEvent")

local KingStart = ReplicatedStorage.Remotes.KillerPerks.kingscourge:WaitForChild("KingScourgeStart")
local KingEnd = ReplicatedStorage.Remotes.KillerPerks.kingscourge:WaitForChild("KingScourgeEnd")

_G.AutoSkillCheck = true          -- ← Включи/выключи здесь
_G.AutoSkillCheckDelay = 0.03     -- Задержка (меньше = быстрее)

local inSkillCheck = false
local currentId = nil
local currentPart = nil

local function perfectSkillCheck()
    if not _G.AutoSkillCheck or not inSkillCheck then return end
    
    task.wait(_G.AutoSkillCheckDelay)
    
    -- Всегда попадаем в идеальную зону (Great)
    SkillCheckResult:FireServer("success", 1, currentId, currentPart)
    
    -- Опционально: звук Great
    local greatSound = player.PlayerGui:FindFirstChild("SkillCheckPromptGui", true)
    if greatSound then
        local sound = greatSound:FindFirstChild("Great") or greatSound:FindFirstChildOfClass("Sound")
        if sound then sound:Play() end
    end
end

-- Обычный Skill Check
SkillCheckEvent.OnClientEvent:Connect(function(id, part)
    if not _G.AutoSkillCheck then return end
    
    currentId = id
    currentPart = part
    inSkillCheck = true
    
    -- Автоматически делаем идеально
    perfectSkillCheck()
end)

-- King Scourge (много skill check'ов подряд)
KingStart.OnClientEvent:Connect(function(id, part, count)
    if not _G.AutoSkillCheck then return end
    
    currentId = id
    currentPart = part
    inSkillCheck = true
    
    perfectSkillCheck()
end)

KingEnd.OnClientEvent:Connect(function()
    inSkillCheck = false
end)

-- Очистка
player.CharacterRemoving:Connect(function()
    inSkillCheck = false
end)

print("🚀 Auto Skill Check загружен!")
print("   Идеальное попадание | Auto =", _G.AutoSkillCheck)
print("   Напиши: _G.AutoSkillCheck = false  — чтобы выключить")
print("   Напиши: _G.AutoSkillCheck = true   — чтобы включить")
