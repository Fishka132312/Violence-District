-- // ENHANCED INSTINCT - LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local InstinctRemote = ReplicatedStorage.Remotes.Killers:WaitForChild("Instinct")

local isActive = false

InstinctRemote.OnClientEvent:Connect(function(position, isStrong)
    if isActive then return end
    isActive = true

    local character = LocalPlayer.Character
    if not character then 
        isActive = false 
        return 
    end
    
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Сильное замедление (можно сделать и полный стоп)
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = isStrong and 4 or 8

    -- === ЗВУК ===
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://108241386481208"
    sound.Volume = isStrong and 0.85 or 0.6
    sound.PlaybackSpeed = math.random(85, 115) / 100
    sound.Parent = root
    sound:Play()
    Debris:AddItem(sound, 6)

    -- === ВИЗУАЛЬНЫЙ ЭФФЕКТ ===
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = position  -- или root, если хочешь на себя
    billboard.Size = UDim2.new(0, 300, 0, 300)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.MaxDistance = 500

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(1, 0, 1, 0)
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://123603265259152"
    image.ImageTransparency = 1
    image.Parent = billboard

    billboard.Parent = Workspace

    -- Анимация появления
    TweenService:Create(image, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {ImageTransparency = 0.3}):Play()
    
    -- Пульсация
    task.spawn(function()
        for i = 1, 6 do
            TweenService:Create(image, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.6
            }):Play()
            wait(0.6)
            TweenService:Create(image, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.25
            }):Play()
            wait(0.6)
        end
    end)

    -- Исчезновение
    task.delay(5.5, function()
        TweenService:Create(image, TweenInfo.new(0.8), {ImageTransparency = 1}):Play()
        task.wait(0.8)
        billboard:Destroy()
        humanoid.WalkSpeed = originalSpeed
        isActive = false
    end)
end)
