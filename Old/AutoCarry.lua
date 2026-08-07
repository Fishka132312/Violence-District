-- === AUTO CARRY с Whitelist (не поднимает своих) ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local CarryEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent")

local KILLER_TEAM_NAME = "Killer"
local MAX_CARRY_DISTANCE = 5

-- Функция проверки whitelist (используем ту же таблицу)
local function isInWhitelist(playerName)
    if not _G.Whitelist then return false end
    return table.find(_G.Whitelist, playerName) ~= nil
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = MAX_CARRY_DISTANCE
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            -- Пропускаем, если игрок в whitelist
            if isInWhitelist(player.Name) then
                continue
            end

            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local targetPos = char.HumanoidRootPart.Position
                local distance = (myPos - targetPos).Magnitude
                
                if distance <= shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Останавливаем старый коннект, если есть
if _G.AutoCarryConnection then
    _G.AutoCarryConnection:Disconnect()
    _G.AutoCarryConnection = nil
end

-- Новый коннект
_G.AutoCarryConnection = RunService.Heartbeat:Connect(function()
    if not _G.AutoCarry then return end
    if not LocalPlayer.Team or LocalPlayer.Team.Name ~= KILLER_TEAM_NAME then
        return
    end

    local character = LocalPlayer.Character
    if character and character:GetAttribute("IsCarrying") == true then
        return
    end

    local targetPlayer = getClosestPlayer()
    if targetPlayer and targetPlayer.Character then
        local args = { [1] = targetPlayer.Character }
        CarryEvent:FireServer(unpack(args))
        print("AutoCarry → " .. targetPlayer.Name)
    end
end)

print("AutoCarry с защитой whitelist загружен")
