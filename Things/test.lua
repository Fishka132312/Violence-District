-- // Enhanced Corrupt - LocalScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()

local humanoid = character:WaitForChild("Humanoid")

local v1 = ReplicatedStorage

local KillerController = require(v1.Modules.Killers.KillerActionController).start

local config = {

    killerName = "abysswalker",

    animations = {

        corrupt = "rbxassetid://117886494230451",  -- твоя анимация

        corruptBoost = "rbxassetid://78432063483146", -- можно другую для буста

    }

}

local controller = KillerController(config)

local corruptCooldown = 0  -- было 30, теперь меньше

local isCorruptReady = true

-- Улучшенная функция Corrupt

local function EnhancedCorruptHandler(inputState)

    if inputState ~= Enum.UserInputState.Begin then return end

    if not isCorruptReady then return end

    if controller.state.isStunned or controller.state.isAttacking then return end

    isCorruptReady = false

    controller.state.isLunging = true

    character:SetAttribute("Immobile", true)

    controller:SetAttribute("action", true)

    -- === ОСНОВНАЯ АНИМАЦИЯ ===

    local track = controller.playAnimationNoStop("corrupt")

    -- Звук

    ReplicatedStorage.Remotes.SoundPlayer:FireServer("70398808450410", 

        character:FindFirstChild("HumanoidRootPart"), 0.5, 70)

    -- === МОЩНЫЕ ЭФФЕКТЫ ===

    

    -- 1. Временное ускорение

    humanoid.WalkSpeed = 28

    

    -- 2. Визуальный твик (тёмная аура)

    local root = character:FindFirstChild("HumanoidRootPart")

    if root then

        local aura = Instance.new("PointLight")

        aura.Color = Color3.fromRGB(80, 0, 255)

        aura.Brightness = 2

        aura.Range = 15

        aura.Parent = root

        

        TweenService:Create(aura, TweenInfo.new(4), {Brightness = 0.2}):Play()

        game.Debris:AddItem(aura, 5)

    end

    -- 3. Marker для активации эффекта (как в оригинале)

    if track then

        track:GetMarkerReachedSignal("fire"):Connect(function()

            if not character:GetAttribute("IsStunned") then

                ReplicatedStorage.Remotes.Killers.Abysswalker.corrupt:FireServer()

                

                -- Дополнительный AOE страх/замедление (сервер должен обработать)

                print("CORRUPT ACTIVATED - POWER MODE")

            end

        end)

        track.Stopped:Connect(function()

            humanoid.WalkSpeed = (character:GetAttribute("Speed") or 16) * (character:GetAttribute("speedboost") or 1) * 0.1535

            character:SetAttribute("Immobile", false)

            controller.state.isLunging = false

            controller:SetAttribute("action", false)

            

            -- Кулдаун

            controller.makeMoveCooldown(

                controller.getMoveGui("Move2").Bar.UIGradient, 

                controller.getMoveGui("Move2").Icon, 

                corruptCooldown

            )

            

            task.delay(corruptCooldown, function()

                isCorruptReady = true

            end)

        end)

    end

end

-- Привязка способности (Q + L1)

controller.bindPressInput(EnhancedCorruptHandler, "Slasher-mob", "move2", Enum.KeyCode.Q, nil, Enum.KeyCode.ButtonL1)

print("✅ Enhanced Corrupt загружен! Кулдаун: " .. corruptCooldown .. " сек")
