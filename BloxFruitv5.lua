--[[
    🐵 KHỈ CAM FARM [DEMO] - ULTRA FAST ATTACK
    ⚡ SIÊU TỐC ĐỘ ĐÁNH - PHẠM VI CỰC XA
    🎨 Full UI Integration
]]

-- Protect entire script
local success, err = pcall(function()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")

-- Safe get LocalPlayer
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("LocalPlayer not found!")
    return
end

local IconID = "rbxassetid://132815391220143"

-- Variables
local FarmingEnabled = false
local FarmConnection = nil
local ChestCount = 0
local StartTime = tick()

-- FAST ATTACK SETTINGS - CỰC NHANH & CỰC XA
_G.FastAttack = true
_G.FastAttackSpeed = 0 -- 0 = Siêu nhanh
_G.FastAttackRange = 500 -- 500 studs - Cực xa
_G.AttackCooldown = 0 -- No cooldown

-- Initialize Fast Attack System
if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)()
    
    -- Safe wrapper functions
    local function SafeWaitForChild(parent, childName)
        local success, result = pcall(function()
            return parent:WaitForChild(childName, 5)
        end)
        return success and result or nil
    end
    
    -- Get game remotes
    local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
    local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
    local Net = Modules and SafeWaitForChild(Modules, "Net")
    
    -- Ultra Fast Attack Configuration
    local UltraFastAttack = {
        Distance = _G.FastAttackRange or 500, -- SIÊU XA
        AttackSpeed = _G.FastAttackSpeed or 0, -- SIÊU NHANH
        attackMobs = true,
        attackPlayers = true,
        NoClip = true,
        MultiHit = true, -- Đánh nhiều mục tiêu cùng lúc
        MaxTargets = 50 -- Đánh tối đa 50 mục tiêu
    }
    
    -- Enhanced Attack Function
    local function SuperFastAttack()
        spawn(function()
            while _G.FastAttack do
                pcall(function()
                    local Character = LocalPlayer.Character
                    if not Character then return end
                    
                    local Tool = Character:FindFirstChildOfClass("Tool")
                    if not Tool then return end
                    
                    -- Collect all enemies in range
                    local AllTargets = {}
                    
                    -- Check Enemies folder
                    if workspace:FindFirstChild("Enemies") then
                        for _, Enemy in pairs(workspace.Enemies:GetChildren()) do
                            if Enemy:FindFirstChild("Humanoid") and Enemy:FindFirstChild("HumanoidRootPart") then
                                local Distance = (Enemy.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                                if Distance <= UltraFastAttack.Distance and Enemy.Humanoid.Health > 0 then
                                    table.insert(AllTargets, Enemy)
                                end
                            end
                        end
                    end
                    
                    -- Check Characters folder (PvP)
                    if workspace:FindFirstChild("Characters") and UltraFastAttack.attackPlayers then
                        for _, Player in pairs(workspace.Characters:GetChildren()) do
                            if Player ~= Character and Player:FindFirstChild("Humanoid") and Player:FindFirstChild("HumanoidRootPart") then
                                local Distance = (Player.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                                if Distance <= UltraFastAttack.Distance and Player.Humanoid.Health > 0 then
                                    table.insert(AllTargets, Player)
                                end
                            end
                        end
                    end
                    
                    -- ULTRA FAST MULTI-HIT ATTACK
                    if #AllTargets > 0 then
                        -- Fire multiple attacks simultaneously
                        for i = 1, math.min(#AllTargets, UltraFastAttack.MaxTargets) do
                            local Target = AllTargets[i]
                            
                            -- Method 1: Direct attack
                            if Net then
                                local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
                                local RegisterHit = Net:FindFirstChild("RE/RegisterHit")
                                
                                if RegisterAttack and RegisterHit then
                                    RegisterAttack:FireServer(0)
                                    RegisterHit:FireServer(Target.Head or Target.HumanoidRootPart, {{Target, Target.HumanoidRootPart}})
                                end
                            end
                            
                            -- Method 2: Tool remote
                            if Tool:FindFirstChild("RemoteFunctionShoot") then
                                Tool.RemoteFunctionShoot:InvokeServer(Target.HumanoidRootPart.Position, Target.HumanoidRootPart)
                            end
                            
                            -- Method 3: Click remote
                            if Tool:FindFirstChild("LeftClickRemote") then
                                local Direction = (Target.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Unit
                                Tool.LeftClickRemote:FireServer(Direction, 1)
                            end
                            
                            -- Method 4: CommF attack
                            if Remotes and Remotes:FindFirstChild("CommF_") then
                                Remotes.CommF_:InvokeServer("AttackNoCD", Target)
                            end
                        end
                    end
                end)
                
                wait(UltraFastAttack.AttackSpeed) -- Siêu nhanh
            end
        end)
    end
    
    -- Start Ultra Fast Attack
    SuperFastAttack()
    
    -- Alternative fast attack method
    spawn(function()
        local remote, idremote
        for _, v in pairs({ReplicatedStorage.Util, ReplicatedStorage.Common, ReplicatedStorage.Remotes, ReplicatedStorage.Assets, ReplicatedStorage.FX}) do
            pcall(function()
                for _, n in pairs(v:GetChildren()) do
                    if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
                        remote, idremote = n, n:GetAttribute("Id")
                    end
                end
            end)
        end
        
        while _G.FastAttack do
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local parts = {}
                
                for _, x in ipairs({workspace.Enemies, workspace.Characters}) do
                    for _, v in ipairs(x and x:GetChildren() or {}) do
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        local hum = v:FindFirstChild("Humanoid")
                        if v ~= char and hrp and hum and hum.Health > 0 and (hrp.Position - root.Position).Magnitude <= _G.FastAttackRange then
                            for _, _v in ipairs(v:GetChildren()) do
                                if _v:IsA("BasePart") then
                                    parts[#parts+1] = {v, _v}
                                end
                            end
                        end
                    end
                end
                
                local tool = char:FindFirstChildOfClass("Tool")
                if #parts > 0 and tool then
                    -- Super fast multi-hit
                    for i = 1, 10 do -- Hit 10 times per frame
                        pcall(function()
                            if Modules and Net then
                                require(Modules.Net):RemoteEvent("RegisterHit", true)
                                game.ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()
                                local head = parts[1][1]:FindFirstChild("Head")
                                if head then
                                    game.ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(head, parts)
                                end
                            end
                        end)
                    end
                end
            end)
            wait(_G.FastAttackSpeed)
        end
    end)
end

-- Safe functions from original
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

local function getChestsSorted()
    local Chests = {}
    pcall(function()
        for _, Object in pairs(workspace:GetDescendants()) do
            if Object:IsA("Part") and Object.Name:find("Chest") then
                if Object:FindFirstChild("TouchInterest") then
                    table.insert(Chests, Object)
                end
            end
        end
    end)
    return Chests
end

local function Teleport(Goal)
    local char = getCharacter()
    if not char then return end
    
    local RootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not RootPart then return end
    
    pcall(function()
        RootPart.CFrame = Goal + Vector3.new(0, 3, 0)
    end)
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KhiCamFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Image = IconID
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -40)
ToggleButton.Size = UDim2.new(0, 80, 0, 80)
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 25)
MainCorner.Parent = MainFrame

-- Gradient
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 140, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
}
MainGradient.Rotation = 0
MainGradient.Parent = MainFrame

-- Animate gradient
spawn(function()
    while true do
        for i = 0, 360, 5 do
            MainGradient.Rotation = i
            wait(0.05)
        end
    end
end)

-- Inner Frame
local InnerFrame = Instance.new("Frame")
InnerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
InnerFrame.Position = UDim2.new(0, 3, 0, 3)
InnerFrame.Size = UDim2.new(1, -6, 1, -6)
InnerFrame.Parent = MainFrame

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 23)
InnerCorner.Parent = InnerFrame

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleText.Size = UDim2.new(1, 0, 0, 60)
TitleText.Font = Enum.Font.GothamBold
TitleText.RichText = true
TitleText.Text = '🐵 KHỈ CAM FARM <font color="rgb(255,0,0)">[ULTRA FAST]</font>'
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 22
TitleText.Parent = InnerFrame

-- Content
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentFrame.Position = UDim2.new(0, 15, 0, 70)
ContentFrame.Size = UDim2.new(1, -30, 1, -85)
ContentFrame.ScrollBarThickness = 8
ContentFrame.Parent = InnerFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 20)
ContentCorner.Parent = ContentFrame

-- FAST ATTACK SECTION
local FastAttackTitle = Instance.new("TextLabel")
FastAttackTitle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
FastAttackTitle.Position = UDim2.new(0, 10, 0, 10)
FastAttackTitle.Size = UDim2.new(1, -20, 0, 40)
FastAttackTitle.Font = Enum.Font.GothamBold
FastAttackTitle.Text = "⚡ ULTRA FAST ATTACK ⚡"
FastAttackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FastAttackTitle.TextSize = 18
FastAttackTitle.Parent = ContentFrame

local AttackCorner = Instance.new("UICorner")
AttackCorner.CornerRadius = UDim.new(0, 10)
AttackCorner.Parent = FastAttackTitle

-- Fast Attack Toggle
local FastAttackButton = Instance.new("TextButton")
FastAttackButton.BackgroundColor3 = _G.FastAttack and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
FastAttackButton.Position = UDim2.new(0.5, -100, 0, 60)
FastAttackButton.Size = UDim2.new(0, 200, 0, 50)
FastAttackButton.Font = Enum.Font.GothamBold
FastAttackButton.Text = _G.FastAttack and "🔥 FAST ATTACK: ON" or "❌ FAST ATTACK: OFF"
FastAttackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FastAttackButton.TextSize = 16
FastAttackButton.Parent = ContentFrame

local FastCorner = Instance.new("UICorner")
FastCorner.CornerRadius = UDim.new(0, 15)
FastCorner.Parent = FastAttackButton

-- Speed Slider
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 10, 0, 120)
SpeedLabel.Size = UDim2.new(1, -20, 0, 30)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Text = "⚡ Attack Speed: ULTRA FAST (0ms)"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
SpeedLabel.TextSize = 14
SpeedLabel.Parent = ContentFrame

-- Range Slider
local RangeLabel = Instance.new("TextLabel")
RangeLabel.BackgroundTransparency = 1
RangeLabel.Position = UDim2.new(0, 10, 0, 150)
RangeLabel.Size = UDim2.new(1, -20, 0, 30)
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.Text = "📏 Attack Range: " .. _G.FastAttackRange .. " studs"
RangeLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
RangeLabel.TextSize = 14
RangeLabel.Parent = ContentFrame

-- Range Input
local RangeInput = Instance.new("TextBox")
RangeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
RangeInput.Position = UDim2.new(0, 10, 0, 180)
RangeInput.Size = UDim2.new(1, -20, 0, 35)
RangeInput.Font = Enum.Font.Gotham
RangeInput.PlaceholderText = "Enter attack range (50-1000)"
RangeInput.Text = tostring(_G.FastAttackRange)
RangeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeInput.TextSize = 14
RangeInput.Parent = ContentFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = RangeInput

RangeInput.FocusLost:Connect(function()
    local newRange = tonumber(RangeInput.Text)
    if newRange and newRange >= 50 and newRange <= 1000 then
        _G.FastAttackRange = newRange
        RangeLabel.Text = "📏 Attack Range: " .. _G.FastAttackRange .. " studs"
    end
end)

-- Farm Section
local FarmTitle = Instance.new("TextLabel")
FarmTitle.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
FarmTitle.Position = UDim2.new(0, 10, 0, 230)
FarmTitle.Size = UDim2.new(1, -20, 0, 40)
FarmTitle.Font = Enum.Font.GothamBold
FarmTitle.Text = "📦 CHEST FARM"
FarmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmTitle.TextSize = 18
FarmTitle.Parent = ContentFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 10)
FarmCorner.Parent = FarmTitle

-- Farm Button
local FarmButton = Instance.new("TextButton")
FarmButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
FarmButton.Position = UDim2.new(0.5, -100, 0, 280)
FarmButton.Size = UDim2.new(0, 200, 0, 50)
FarmButton.Font = Enum.Font.GothamBold
FarmButton.Text = "🚀 START FARM"
FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmButton.TextSize = 16
FarmButton.Parent = ContentFrame

local FarmButtonCorner = Instance.new("UICorner")
FarmButtonCorner.CornerRadius = UDim.new(0, 15)
FarmButtonCorner.Parent = FarmButton

-- Stats
local StatsLabel = Instance.new("TextLabel")
StatsLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
StatsLabel.Position = UDim2.new(0, 10, 0, 340)
StatsLabel.Size = UDim2.new(1, -20, 0, 100)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "📊 STATISTICS\n\n📦 Chests: 0\n⚔️ Enemies Killed: 0\n⏰ Time: 00:00:00"
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextSize = 14
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.Parent = ContentFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 10)
StatsCorner.Parent = StatsLabel

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)

-- Toggle functions
FastAttackButton.MouseButton1Click:Connect(function()
    _G.FastAttack = not _G.FastAttack
    FastAttackButton.Text = _G.FastAttack and "🔥 FAST ATTACK: ON" or "❌ FAST ATTACK: OFF"
    FastAttackButton.BackgroundColor3 = _G.FastAttack and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

local function toggleFarm()
    FarmingEnabled = not FarmingEnabled
    
    if FarmingEnabled then
        FarmButton.Text = "⏹️ STOP FARM"
        StartTime = tick()
        
        FarmConnection = spawn(function()
            while FarmingEnabled do
                pcall(function()
                    local Chests = getChestsSorted()
                    if #Chests > 0 then
                        Teleport(Chests[1].CFrame)
                        ChestCount = ChestCount + 1
                    end
                end)
                wait(0.1)
            end
        end)
    else
        FarmButton.Text = "🚀 START FARM"
        if FarmConnection then
            FarmConnection = nil
        end
    end
end

FarmButton.MouseButton1Click:Connect(toggleFarm)

-- Update stats
local enemiesKilled = 0
spawn(function()
    while true do
        if FarmingEnabled then
            local runtime = tick() - StartTime
            local hours = math.floor(runtime / 3600)
            local minutes = math.floor((runtime % 3600) / 60)
            local seconds = math.floor(runtime % 60)
            
            StatsLabel.Text = string.format("📊 STATISTICS\n\n📦 Chests: %d\n⚔️ Enemies Killed: %d\n⏰ Time: %02d:%02d:%02d",
                ChestCount, enemiesKilled, hours, minutes, seconds)
        end
        wait(1)
    end
end)

-- Toggle UI
local UIVisible = false
ToggleButton.MouseButton1Click:Connect(function()
    UIVisible = not UIVisible
    MainFrame.Visible = UIVisible
    
    if UIVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 500, 0, 600)
        }):Play()
    end
end)

-- Initial notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🐵 KHỈ CAM ULTRA FAST",
        Text = "Loaded! Fast Attack is " .. (_G.FastAttack and "ON" or "OFF"),
        Icon = IconID,
        Duration = 5
    })
end)

print("🐵 Khỉ Cam Farm [ULTRA FAST ATTACK] - Loaded!")

end) -- End of main pcall

if not success then
    warn("Script error: " .. tostring(err))
end
