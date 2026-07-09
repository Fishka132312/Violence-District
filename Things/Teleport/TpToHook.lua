local SCRIPT_TAG = "HookTeleport"

if _G[SCRIPT_TAG] then
    _G[SCRIPT_TAG]()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getMapFolder()
    return workspace:FindFirstChild("Map")
end

local function findAllHooks()
    local mapFolder = getMapFolder()
    if not mapFolder then return {} end
    
    local hooks = {}
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj.Name == "Hook" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            table.insert(hooks, obj)
        end
    end
    
    return hooks
end

if _G.HookCycleIndex == nil then
    _G.HookCycleIndex = 1
end

local function teleportToNextHook()
    local hooks = findAllHooks()
    
    if #hooks == 0 then
        print("❌ Хуки не найдены!")
        return
    end
    
    local currentIndex = _G.HookCycleIndex
    local targetHook = hooks[currentIndex]
    
    local rootPart = targetHook:IsA("Model") and 
        (targetHook.PrimaryPart or targetHook:FindFirstChildWhichIsA("BasePart")) or 
        targetHook
    
    if not rootPart then
        _G.HookCycleIndex = (_G.HookCycleIndex % #hooks) + 1
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local hrp = character.HumanoidRootPart
    hrp.CFrame = rootPart.CFrame * CFrame.new(0, 5, 0)
    
    print(string.format("📍 Хук %d/%d", currentIndex, #hooks))
    
    _G.HookCycleIndex = (_G.HookCycleIndex % #hooks) + 1
end

local function cleanup()
    print("HookCycleTP cleared")
    _G.HookCycleIndex = nil
end

_G[SCRIPT_TAG] = cleanup

print("[HOOK CYCLE TP] Загружен! Пиши в чат: hook")

local chatConnection = LocalPlayer.Chatted:Connect(function(msg)
    local text = msg:lower()
    if text == "hook" or text == "nexthook" then
        teleportToNextHook()
    end
end)

_G[SCRIPT_TAG .. "_chat"] = chatConnection
