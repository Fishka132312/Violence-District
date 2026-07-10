local LocalPlayer = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Camera = workspace.Camera

if _G.Slasher1Loaded then return end
_G.Slasher1Loaded = true
_G.Slasher1 = _G.Slasher1 or false

local LakeMist = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Jason"):WaitForChild("LakeMist")
local Pursuit = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Jason"):WaitForChild("Pursuit")

local v1 = 0
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local CheckInterractable = v11:WaitForChild("CheckInterractable")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local v12 = nil

if LocalPlayer:GetAttribute("platform") == "PC" then
    v12 = PlayerGui:WaitForChild("Slasher")
elseif LocalPlayer:GetAttribute("platform") == "Mobile" then
    v12 = PlayerGui:WaitForChild("Slasher-mob")
elseif LocalPlayer:GetAttribute("platform") == "Console" then
    v12 = PlayerGui:WaitForChild("Slasher-con")
end

local Uncloak = v12.Uncloak
local Gen = v12:WaitForChild("Gen")
local Move1 = Gen:WaitForChild("Move1")
local UIGradient = Move1:WaitForChild("Bar"):WaitForChild("UIGradient")
local Icon = Move1:WaitForChild("Icon")
local Move2 = Gen:WaitForChild("Move2")
local UIGradient2 = Move2:WaitForChild("Bar"):WaitForChild("UIGradient")
local Icon2 = Move2:WaitForChild("Icon")

if Camera:FindFirstChild("PursuitTint") then
    v9 = Camera:FindFirstChild("PursuitTint")
else
    v9 = Instance.new("ColorCorrectionEffect")
    v9.Name = "PursuitTint"
    v9.Parent = Camera
    v9.TintColor = Color3.fromRGB(255, 255, 255)
end

if Camera:FindFirstChild("InvisibilityTint") then
    v10 = Camera:FindFirstChild("InvisibilityTint")
else
    v10 = Instance.new("ColorCorrectionEffect")
    v10.Name = "InvisibilityTint"
    v10.Parent = Camera
    v10.TintColor = Color3.fromRGB(255, 255, 255)
end

local function setGreyTint(p1)
    if not v10 then return end
    local v3 = TweenService:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TintColor = p1 and Color3.fromRGB(191, 191, 191) or Color3.fromRGB(255, 255, 255)
    })
    Uncloak.Visible = p1
    v3:Play()
end

local function setPursuitTint(p1)
    if not v9 then return end
    local v1 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(v9, v1, {
        TintColor = p1 and Color3.fromRGB(255, 193, 193) or Color3.fromRGB(255, 255, 255)
    }):Play()
end

local function loadPursuitAnimation()
    local Humanoid = v11:WaitForChild("Humanoid")
    local Animation = Instance.new("Animation")
    Animation.AnimationId = "rbxassetid://125224839697689"
    v7 = Humanoid:LoadAnimation(Animation)
    
    local Animator = Camera:WaitForChild("VM"):FindFirstChild("Humanoid"):WaitForChild("Animator")
    local Animation2 = Instance.new("Animation")
    Animation2.AnimationId = "rbxassetid://117375515202922"
    v8 = Animator:LoadAnimation(Animation2)
end

local function playPursuitAnimation()
    if v4 or v6 then
        CheckInterractable:SetAttribute("action", false)
    else
        v4 = true
        task.delay(2, function() v4 = false end)
        Pursuit:FireServer(true)
    end
end

Pursuit.OnClientEvent:Connect(function(p1)
    if p1 == "confirmed" then
        v11:SetAttribute("Pursuit", true)
        CheckInterractable:SetAttribute("action", true)
        v2 = true
        if v7 then
            Icon2.ImageColor3 = Color3.fromRGB(51, 51, 51)
            UIGradient2.Offset = Vector2.new(0, 0)
            TweenService:Create(UIGradient2, TweenInfo.new(20, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, 1)}):Play()
            v7:Play()
            v8:Play()
            task.delay(0.4, function() setPursuitTint(true) end)
            task.delay(20, function()
                v2 = false
                CheckInterractable:SetAttribute("action", false)
                Pursuit:FireServer(false)
                setPursuitTint(false)
                v6 = true
                UIGradient2.Offset = Vector2.new(0, 1)
                TweenService:Create(UIGradient2, TweenInfo.new(80, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, 0)}):Play()
                task.delay(80, function() v6 = false; Icon2.ImageColor3 = Color3.fromRGB(255, 255, 255) end)
            end)
        end
    elseif p1 == "rejected" then
        CheckInterractable:SetAttribute("action", false)
    end
end)

local function RaycastIgnoringTransparentParts(p1, p2, p3)
    local v1 = RaycastParams.new()
    v1.FilterDescendantsInstances = p3
    v1.FilterType = Enum.RaycastFilterType.Exclude
    local sum, v2 = p2.Magnitude, p1
    while sum > 0 do
        local v3 = workspace:Raycast(v2, p2.Unit * sum, v1)
        if not v3 then break end
        local v4 = v3.Instance
        if v4.Transparency < 0.5 then return v3 end
        sum = sum - (v3.Position - v2).Magnitude
        v2 = v3.Position + p2.Unit * 0.01
        table.insert(p3, v4)
    end
    return nil
end

local function isPlayerNearby()
    for i, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position - v11.HumanoidRootPart.Position).Magnitude < 3 then
            return true
        end
    end
    return false
end

local function v15()
    if v3 then
        if os.clock() - v1 < 2 then
            CheckInterractable:SetAttribute("action", false)
        else
            v3 = false
            LakeMist:FireServer(false)
            setGreyTint(false)
            v5 = true
            UIGradient.Offset = Vector2.new(0, 1)
            TweenService:Create(UIGradient, TweenInfo.new(60, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, 0)}):Play()
            CheckInterractable:SetAttribute("action", false)
            task.delay(60, function() v5 = false; Icon.ImageColor3 = Color3.fromRGB(255, 255, 255) end)
        end
    else
        if v4 or v5 then
            CheckInterractable:SetAttribute("action", false)
            return
        end
        v4 = true
        task.delay(2, function() v4 = false end)
        if isPlayerNearby() then
            CheckInterractable:SetAttribute("action", false)
            return
        end
        if v11:GetAttribute("Pursuit") or v11:GetAttribute("IsCarrying") then
            CheckInterractable:SetAttribute("action", false)
        else
            v3 = true
            v1 = os.clock()
            LakeMist:FireServer(true)
            setGreyTint(true)
            Icon.ImageColor3 = Color3.fromRGB(51, 51, 51)
            TweenService:Create(UIGradient, TweenInfo.new(13, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, 1)}):Play()
            task.delay(0.1, function()
                if not (v11 and v11.Parent and v11:GetAttribute("LakeMist")) then return end
                CheckInterractable:SetAttribute("action", false)
            end)
            task.delay(13, function() if v3 then v15() end end)
        end
    end
end

local function pursuitActionHandler(p1, p2, p3)
    if p2 ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    if CheckInterractable:GetAttribute("action") or (v11:GetAttribute("IsCarrying") or (CheckInterractable:GetAttribute("isVaulting") or (v2 or (v3 or v11:GetAttribute("LakeMist"))))) then
        return Enum.ContextActionResult.Pass
    end
    CheckInterractable:SetAttribute("action", true)
    playPursuitAnimation()
    return Enum.ContextActionResult.Pass
end

local function toggleInvisibilityHandler(p1, p2, p3)
    if p2 ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    if CheckInterractable:GetAttribute("action") or (v11:GetAttribute("Pursuit") or (v11:GetAttribute("IsCarrying") or CheckInterractable:GetAttribute("isVaulting"))) then
        return Enum.ContextActionResult.Pass
    end
    CheckInterractable:SetAttribute("action", true)
    v15()
    return Enum.ContextActionResult.Pass
end

local function endCurrentAbility()
    if v3 then
        v3 = false
        LakeMist:FireServer(false)
        setGreyTint(false)
        CheckInterractable:SetAttribute("action", false)
        Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        UIGradient.Offset = Vector2.new(0, 0)
    end
    if v2 then
        v2 = false
        Pursuit:FireServer(false)
        setPursuitTint(false)
        CheckInterractable:SetAttribute("action", false)
        Icon2.ImageColor3 = Color3.fromRGB(255, 255, 255)
        UIGradient2.Offset = Vector2.new(0, 0)
    end
end

if LocalPlayer:GetAttribute("platform") == "Mobile" then
    local Controls = PlayerGui:WaitForChild("Slasher-mob").Controls
    local move2 = Controls:FindFirstChild("move2")
    if move2 then move2.MouseButton1Click:Connect(function() pursuitActionHandler("PursuitAction", Enum.UserInputState.Begin, {}) end) end
    local move1 = Controls:FindFirstChild("move1")
    if move1 then move1.MouseButton1Click:Connect(function() toggleInvisibilityHandler("ToggleInvisibility", Enum.UserInputState.Begin, {}) end) end
else
    UserInputService.InputBegan:Connect(function(p1, p2)
        if p2 then return end
        if p1.UserInputType == Enum.UserInputType.MouseButton2 then pursuitActionHandler("PursuitAction", Enum.UserInputState.Begin, p1) end
        if p1.UserInputType == Enum.UserInputType.Keyboard and p1.KeyCode == Enum.KeyCode.Q then toggleInvisibilityHandler("ToggleInvisibility", Enum.UserInputState.Begin, p1) end
        if p1.UserInputType == Enum.UserInputType.MouseButton1 then endCurrentAbility() end
    end)
end

loadPursuitAnimation()

local function removeCooldowns()
    v1 = 0
    v2 = false
    v3 = false
    v4 = false
    v5 = false
    v6 = false
    if CheckInterractable then
        CheckInterractable:SetAttribute("action", false)
    end
end

local function isLocalPlayerKillerSlasher()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then
            local team = plr.Team
            if team and team.Name == "Killer" and plr:GetAttribute("SelectedKiller") == "Slasher" then
                return true
            end
            return false
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if _G.Slasher1 and isLocalPlayerKillerSlasher() then
            removeCooldowns()
        end
    end
end)
