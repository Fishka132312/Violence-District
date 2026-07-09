local SCRIPT_TAG = "GenTeleport" 

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function findAllGenerators()
    local mapFolder = getMapFolder()
    if not mapFolder then return {} end
    
    local generators = {}
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            table.insert(generators, obj)
        end
    end
    
    return generators
end

local function teleportToRandomGenerator()
    local generators = findAllGenerators()
    
    if #generators == 0 then
        print("❌ Генераторы не найдены на карте!")
        return false
    end
    
    local randomGen = generators[math.random(1, #generators)]
    
    local rootPart = randomGen:IsA("Model") and 
        (randomGen.PrimaryPart or randomGen:FindFirstChildWhichIsA("BasePart")) or 
        randomGen
    
    if not rootPart then
        print("⚠️ У выбранного генератора нет PrimaryPart")
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then 
        print("⚠️ Персонаж не загружен")
        return false 
    end
    
    local humanoidRoot = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRoot then 
        print("⚠️ HumanoidRootPart не найден")
        return false 
    end
    
    local targetCFrame = rootPart.CFrame * CFrame.new(0, 4, 0)
    humanoidRoot.CFrame = targetCFrame
    
    print("✅ Телепортирован к генератору! (Всего генераторов: " .. #generators .. ")")
    return true
end

print("[GEN TELEPORT] Ищем генераторы...")
local success = teleportToRandomGenerator()

local function cleanup()
    print("[GEN TELEPORT] Скрипт выгружен")
end

_G[SCRIPT_TAG] = cleanup

print("Напиши `teleportgen` в чат, чтобы телепортироваться снова.")
local connection
connection = LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == "teleportgen" or msg:lower() == "gen" then
        teleportToRandomGenerator()
    end
end)

_G[SCRIPT_TAG .. "_chat"] = connection
