local SCRIPT_TAG = "GenTeleport"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local Players = game:GetService("Players")
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

if _G.GenCycleIndex == nil then
    _G.GenCycleIndex = 1
end

local function teleportToNextGenerator()
    local generators = findAllGenerators()
    
    if #generators == 0 then
        print("❌ Генераторы не найдены!")
        return
    end
    
    local currentIndex = _G.GenCycleIndex
    local targetGen = generators[currentIndex]
    
    local rootPart = targetGen:IsA("Model") and 
        (targetGen.PrimaryPart or targetGen:FindFirstChildWhichIsA("BasePart")) or 
        targetGen
    
    if not rootPart then
        print("⚠️ Проблема с генератором #" .. currentIndex)
        _G.GenCycleIndex = (_G.GenCycleIndex % #generators) + 1
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        print("⚠️ Персонаж не готов")
        return
    end
    
    local hrp = character.HumanoidRootPart
    hrp.CFrame = rootPart.CFrame * CFrame.new(0, 5, 0)  -- чуть выше
    
    print(string.format("📍 Телепорт %d/%d → Генератор #%d", 
        currentIndex, #generators, currentIndex))
    
    _G.GenCycleIndex = (_G.GenCycleIndex % #generators) + 1
end

local function cleanup()
    print("🧹 Цикличный телепорт к генераторам выгружен")
    _G.GenCycleIndex = nil
end

_G[SCRIPT_TAG] = cleanup

print("🔄 Цикличный телепорт к генераторам загружен!")
print("Напиши в чат `nextgen` или `gen` для телепорта к следующему генератору")

local chatConnection = LocalPlayer.Chatted:Connect(function(msg)
    local text = msg:lower()
    if text == "nextgen" or text == "gen" or text == "next" then
        teleportToNextGenerator()
    end
end)

_G[SCRIPT_TAG .. "_chat"] = chatConnection
