--[[
    🐵 KHỈ CAM FARM [DEMO]
    🎨 Unique Animated UI Design
    📦 Advanced Chest Farming System
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local IconID = "rbxassetid://132815391220143"

-- Variables
local FarmingEnabled = false
local FarmConnection = nil
local NoclipConnection = nil
local ChestCount = 0
local StartTime = tick()

-- Original Farm Code Integration
local Locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")

local function getCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    return LocalPlayer.Character
end

local function DistanceFromPlrSort(ObjectList)
    local RootPart = getCharacter():FindFirstChild("LowerTorso") or getCharacter():FindFirstChild("HumanoidRootPart")
    table.sort(ObjectList, function(ChestA, ChestB)
        local RootPos = RootPart.Position
        local DistanceA = (RootPos - ChestA.Position).Magnitude
        local DistanceB = (RootPos - ChestB.Position).Magnitude
        return DistanceA < DistanceB
    end)
end

local UncheckedChests, FirstRun = {}, true
local function getChestsSorted()
    if FirstRun then
        FirstRun = false
        for _, Object in pairs(game:GetDescendants()) do
            if Object.Name:find("Chest") and Object.ClassName == "Part" then
                table.insert(UncheckedChests, Object)
            end
        end
    end
    local Chests = {}
    for _, Chest in pairs(UncheckedChests) do
        if Chest:FindFirstChild("TouchInterest") then
            table.insert(Chests, Chest)
        end
    end
    DistanceFromPlrSort(Chests)
    return Chests
end

local function toggleNoclip(Toggle)
    for _, v in pairs(getCharacter():GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = not Toggle
        end
    end
end

local function Teleport(Goal)
    local RootPart = getCharacter():FindFirstChild("HumanoidRootPart")
    if RootPart then
        toggleNoclip(true)
        RootPart.CFrame = Goal + Vector3.new(0, 3, 0)
        toggleNoclip(false)
    end
end

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KhiCamFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle Button (Always Visible)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Image = IconID
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 10, 0.5, -40)
ToggleButton.Size = UDim2.new(0, 80, 0, 80)
ToggleButton.Parent = ScreenGui

-- Toggle Button Effects
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 200, 0)
ToggleStroke.Thickness = 3
ToggleStroke.Parent = ToggleButton

-- Pulse Animation for Toggle
spawn(function()
    while true do
        TweenService:Create(ToggleButton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 85, 0, 85),
            Rotation = 5
        }):Play()
        wait(1)
        TweenService:Create(ToggleButton, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 80, 0, 80),
            Rotation = -5
        }):Play()
        wait(1)
    end
end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -250)
MainFrame.Size = UDim2.new(0, 500, 0, 500)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Main Frame Design
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 25)
MainCorner.Parent = MainFrame

-- Animated Gradient Background
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 255))
}
MainGradient.Rotation = 0
MainGradient.Parent = MainFrame

-- Animate gradient rotation
spawn(function()
    while true do
        for i = 0, 360, 2 do
            MainGradient.Rotation = i
            wait(0.05)
        end
    end
end)

-- Inner Frame (Content)
local InnerFrame = Instance.new("Frame")
InnerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
InnerFrame.Position = UDim2.new(0, 3, 0, 3)
InnerFrame.Size = UDim2.new(1, -6, 1, -6)
InnerFrame.Parent = MainFrame

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 23)
InnerCorner.Parent = InnerFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.Parent = InnerFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 23)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Icon in Title
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Image = IconID
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 15, 0.5, -25)
TitleIcon.Size = UDim2.new(0, 50, 0, 50)
TitleIcon.Parent = TitleBar

-- Rotate icon animation
spawn(function()
    while true do
        TweenService:Create(TitleIcon, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            Rotation = 360
        }):Play()
        wait(2)
        TitleIcon.Rotation = 0
    end
end)

-- Animated Title Text
local TitleText = Instance.new("TextLabel")
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 75, 0, 0)
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.RichText = true
TitleText.Text = ""
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 22
TitleText.Parent = TitleBar

-- Animated title typing effect
spawn(function()
    while true do
        local text = "🐵 KHỈ CAM FARM "
        local demo = "[DEMO]"
        
        -- Type main text
        for i = 1, #text do
            TitleText.Text = string.sub(text, 1, i)
            TitleText.TextColor3 = Color3.fromHSV((i * 20) % 360 / 360, 1, 1)
            wait(0.05)
        end
        
        -- Add demo with orange color
        TitleText.Text = text .. '<font color="rgb(255,140,0)">' .. demo .. '</font>'
        
        -- Rainbow effect
        for i = 0, 360, 10 do
            TitleText.TextColor3 = Color3.fromHSV(i/360, 1, 1)
            wait(0.05)
        end
        
        -- Fade out
        for i = 1, 10 do
            TitleText.TextTransparency = i/10
            wait(0.05)
        end
        
        TitleText.TextTransparency = 0
        TitleText.Text = ""
        wait(0.5)
    end
end)

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Position = UDim2.new(1, -45, 0.5, -15)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✖"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 15, 0, 70)
TabContainer.Size = UDim2.new(1, -30, 0, 45)
TabContainer.Parent = InnerFrame

-- Create tabs
local tabs = {
    {name = "Farm", icon = "📦", color = Color3.fromRGB(255, 100, 50)},
    {name = "Stats", icon = "📊", color = Color3.fromRGB(50, 200, 255)},
    {name = "Settings", icon = "⚙️", color = Color3.fromRGB(150, 100, 255)}
}

local CurrentTab = "Farm"
local tabButtons = {}
local tabFrames = {}

for i, tab in ipairs(tabs) do
    -- Tab button
    local TabButton = Instance.new("TextButton")
    TabButton.BackgroundColor3 = i == 1 and tab.color or Color3.fromRGB(40, 40, 45)
    TabButton.Position = UDim2.new((i-1) * 0.33, i > 1 and 5 or 0, 0, 0)
    TabButton.Size = UDim2.new(0.33, i == 2 and -10 or -5, 1, 0)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = tab.icon .. " " .. tab.name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextSize = 16
    TabButton.Parent = TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 12)
    TabCorner.Parent = TabButton
    
    tabButtons[tab.name] = TabButton
    
    -- Tab frame
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabFrame.BorderSizePixel = 0
    TabFrame.Position = UDim2.new(0, 15, 0, 125)
    TabFrame.Size = UDim2.new(1, -30, 1, -140)
    TabFrame.ScrollBarThickness = 8
    TabFrame.ScrollBarImageColor3 = tab.color
    TabFrame.Visible = i == 1
    TabFrame.Parent = InnerFrame
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 20)
    FrameCorner.Parent = TabFrame
    
    tabFrames[tab.name] = TabFrame
    
    -- Tab click animation
    TabButton.MouseButton1Click:Connect(function()
        CurrentTab = tab.name
        
        -- Update colors
        for name, btn in pairs(tabButtons) do
            local tabData = tabs[name == "Farm" and 1 or name == "Stats" and 2 or 3]
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundColor3 = name == CurrentTab and tabData.color or Color3.fromRGB(40, 40, 45)
            }):Play()
        end
        
        -- Update visibility with animation
        for name, frame in pairs(tabFrames) do
            if name == CurrentTab then
                frame.Visible = true
                frame.Size = UDim2.new(0, 0, 1, -140)
                TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -30, 1, -140)
                }):Play()
            else
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 0, 1, -140)
                }):Play()
                spawn(function()
                    wait(0.2)
                    frame.Visible = false
                end)
            end
        end
    end)
end

-- FARM TAB CONTENT
local FarmFrame = tabFrames["Farm"]

-- Farm Status Card
local StatusCard = Instance.new("Frame")
StatusCard.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
StatusCard.Position = UDim2.new(0, 10, 0, 10)
StatusCard.Size = UDim2.new(1, -20, 0, 100)
StatusCard.Parent = FarmFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 15)
StatusCorner.Parent = StatusCard

local StatusGradient = Instance.new("UIGradient")
StatusGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
}
StatusGradient.Rotation = 90
StatusGradient.Parent = StatusCard

local StatusLabel = Instance.new("TextLabel")
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 15, 0, 10)
StatusLabel.Size = UDim2.new(1, -30, 0, 30)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Text = "FARM STATUS: INACTIVE"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 18
StatusLabel.Parent = StatusCard

local ChestLabel = Instance.new("TextLabel")
ChestLabel.BackgroundTransparency = 1
ChestLabel.Position = UDim2.new(0, 15, 0, 40)
ChestLabel.Size = UDim2.new(1, -30, 0, 25)
ChestLabel.Font = Enum.Font.Gotham
ChestLabel.Text = "📦 Chests Collected: 0"
ChestLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ChestLabel.TextSize = 14
ChestLabel.Parent = StatusCard

local TimeLabel = Instance.new("TextLabel")
TimeLabel.BackgroundTransparency = 1
TimeLabel.Position = UDim2.new(0, 15, 0, 65)
TimeLabel.Size = UDim2.new(1, -30, 0, 25)
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.Text = "⏰ Farm Time: 00:00:00"
TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeLabel.TextSize = 14
TimeLabel.Parent = StatusCard

-- Farm Toggle Button
local FarmButton = Instance.new("TextButton")
FarmButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
FarmButton.Position = UDim2.new(0.5, -100, 0, 120)
FarmButton.Size = UDim2.new(0, 200, 0, 60)
FarmButton.Font = Enum.Font.GothamBold
FarmButton.Text = "🚀 START FARMING"
FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmButton.TextSize = 18
FarmButton.Parent = FarmFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 15)
FarmCorner.Parent = FarmButton

-- Animated button effect
spawn(function()
    while true do
        if FarmingEnabled then
            for i = 0, 360, 10 do
                FarmButton.BackgroundColor3 = Color3.fromHSV(i/360, 0.8, 0.8)
                wait(0.05)
            end
        else
            wait(1)
        end
    end
end)

-- Features List
local FeaturesTitle = Instance.new("TextLabel")
FeaturesTitle.BackgroundTransparency = 1
FeaturesTitle.Position = UDim2.new(0, 10, 0, 190)
FeaturesTitle.Size = UDim2.new(1, -20, 0, 30)
FeaturesTitle.Font = Enum.Font.GothamBold
FeaturesTitle.Text = "✨ FEATURES"
FeaturesTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
FeaturesTitle.TextSize = 16
FeaturesTitle.Parent = FarmFrame

local features = {
    "✅ Auto Collect Chests",
    "✅ Auto Noclip",
    "✅ Distance Sort",
    "✅ Auto Team Set",
    "✅ Anti-Kick"
}

for i, feature in ipairs(features) do
    local FeatureLabel = Instance.new("TextLabel")
    FeatureLabel.BackgroundTransparency = 1
    FeatureLabel.Position = UDim2.new(0, 20, 0, 220 + (i-1) * 25)
    FeatureLabel.Size = UDim2.new(1, -40, 0, 20)
    FeatureLabel.Font = Enum.Font.Gotham
    FeatureLabel.Text = feature
    FeatureLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    FeatureLabel.TextSize = 14
    FeatureLabel.TextXAlignment = Enum.TextXAlignment.Left
    FeatureLabel.Parent = FarmFrame
    
    -- Fade in animation
    FeatureLabel.TextTransparency = 1
    spawn(function()
        wait(i * 0.1)
        TweenService:Create(FeatureLabel, TweenInfo.new(0.5), {
            TextTransparency = 0
        }):Play()
    end)
end

FarmFrame.CanvasSize = UDim2.new(0, 0, 0, 400)

-- STATS TAB CONTENT
local StatsFrame = tabFrames["Stats"]

local StatsDisplay = Instance.new("TextLabel")
StatsDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
StatsDisplay.Position = UDim2.new(0, 10, 0, 10)
StatsDisplay.Size = UDim2.new(1, -20, 1, -20)
StatsDisplay.Font = Enum.Font.Gotham
StatsDisplay.Text = "📊 STATISTICS\n\nLoading..."
StatsDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsDisplay.TextSize = 16
StatsDisplay.TextYAlignment = Enum.TextYAlignment.Top
StatsDisplay.Parent = StatsFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 15)
StatsCorner.Parent = StatsDisplay

-- Update stats
spawn(function()
    while true do
        if FarmingEnabled then
            local runtime = tick() - StartTime
            local hours = math.floor(runtime / 3600)
            local minutes = math.floor((runtime % 3600) / 60)
            local seconds = math.floor(runtime % 60)
            
            StatsDisplay.Text = string.format([[
📊 FARMING STATISTICS

📦 Total Chests: %d
⏱️ Total Time: %02d:%02d:%02d
📈 Chests/Hour: %.1f
🎯 Current Target: %s
🌍 Server Time: %s
👤 Username: %s
]], 
                ChestCount,
                hours, minutes, seconds,
                ChestCount / (runtime / 3600),
                "Searching...",
                os.date("%X"),
                LocalPlayer.Name
            )
        end
        wait(1)
    end
end)

-- SETTINGS TAB CONTENT
local SettingsFrame = tabFrames["Settings"]

local settings = {
    {name = "Auto Rejoin", enabled = false},
    {name = "Low Graphics", enabled = false},
    {name = "Hide Username", enabled = false}
}

for i, setting in ipairs(settings) do
    local SettingFrame = Instance.new("Frame")
    SettingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SettingFrame.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 60)
    SettingFrame.Size = UDim2.new(1, -20, 0, 50)
    SettingFrame.Parent = SettingsFrame
    
    local SettingCorner = Instance.new("UICorner")
    SettingCorner.CornerRadius = UDim.new(0, 12)
    SettingCorner.Parent = SettingFrame
    
    local SettingLabel = Instance.new("TextLabel")
    SettingLabel.BackgroundTransparency = 1
    SettingLabel.Position = UDim2.new(0, 15, 0, 0)
    SettingLabel.Size = UDim2.new(0.6, 0, 1, 0)
    SettingLabel.Font = Enum.Font.Gotham
    SettingLabel.Text = setting.name
    SettingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingLabel.TextSize = 16
    SettingLabel.TextXAlignment = Enum.TextXAlignment.Left
    SettingLabel.Parent = SettingFrame
    
    local ToggleSwitch = Instance.new("TextButton")
    ToggleSwitch.BackgroundColor3 = setting.enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    ToggleSwitch.Position = UDim2.new(1, -70, 0.5, -15)
    ToggleSwitch.Size = UDim2.new(0, 50, 0, 30)
    ToggleSwitch.Font = Enum.Font.GothamBold
    ToggleSwitch.Text = setting.enabled and "ON" or "OFF"
    ToggleSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleSwitch.TextSize = 14
    ToggleSwitch.Parent = SettingFrame
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = ToggleSwitch
    
    ToggleSwitch.MouseButton1Click:Connect(function()
        setting.enabled = not setting.enabled
        ToggleSwitch.Text = setting.enabled and "ON" or "OFF"
        TweenService:Create(ToggleSwitch, TweenInfo.new(0.3), {
            BackgroundColor3 = setting.enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        }):Play()
    end)
end

-- Farm Toggle Function
local function toggleFarm()
    FarmingEnabled = not FarmingEnabled
    
    if FarmingEnabled then
        StartTime = tick()
        ChestCount = 0
        
        FarmButton.Text = "⏹️ STOP FARMING"
        StatusLabel.Text = "FARM STATUS: ACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        
        -- Notification
        StarterGui:SetCore("SendNotification", {
            Title = "🐵 KHỈ CAM FARM",
            Text = "Chest farming started!",
            Icon = IconID,
            Duration = 3
        })
        
        -- Start farming
        FarmConnection = task.spawn(function()
            while FarmingEnabled do
                task.wait()
                local Chests = getChestsSorted()
                if #Chests > 0 then
                    Teleport(Chests[1].CFrame)
                    ChestCount = ChestCount + 1
                    ChestLabel.Text = "📦 Chests Collected: " .. ChestCount
                end
            end
        end)
        
        -- Auto set team
        task.spawn(function()
            while FarmingEnabled do
                task.wait(5)
                pcall(function()
            
            -- Notification
        StarterGui:SetCore("SendNotification", {
            Title = "🐵 KHỈ CAM FARM",
            Text = "Chest farming started!",
            Icon = IconID,
            Duration = 3
        })
        
        -- Start farming
        FarmConnection = task.spawn(function()
            while FarmingEnabled do
                task.wait()
                local Chests = getChestsSorted()
                if #Chests > 0 then
                    Teleport(Chests[1].CFrame)
                    ChestCount = ChestCount + 1
                    ChestLabel.Text = "📦 Chests Collected: " .. ChestCount
                end
            end
        end)
        
        -- Auto set team
        task.spawn(function()
            while FarmingEnabled do
                task.wait(5)
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
                end)
            end
        end)
        
        else
        FarmButton.Text = "🚀 START FARMING"
        StatusLabel.Text = "FARM STATUS: INACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        if FarmConnection then
            task.cancel(FarmConnection)
        end
        
        -- Notification
        StarterGui:SetCore("SendNotification", {
            Title = "🐵 KHỈ CAM FARM",
            Text = "Chest farming stopped!",
            Icon = IconID,
            Duration = 3
        })
    end
end
FarmButton.MouseButton1Click:Connect(toggleFarm)

-- Update timer
spawn(function()
    while true do
        if FarmingEnabled then
            local runtime = tick() - StartTime
            local hours = math.floor(runtime / 3600)
            local minutes = math.floor((runtime % 3600) / 60)
            local seconds = math.floor(runtime % 60)
            TimeLabel.Text = string.format("⏰ Farm Time: %02d:%02d:%02d", hours, minutes, seconds)
        end
        wait(1)
    end
end)

-- Toggle UI
local UIVisible = false
local function toggleUI()
    UIVisible = not UIVisible
    if UIVisible then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 500),
            Position = UDim2.new(0.5, -250, 0.5, -250)
        }):Play()
        
        
       StarterGui:SetCore("SendNotification", {
            Title = "🐵 KHỈ CAM FARM [DEMO]",
            Text = "UI Opened!",
            Icon = IconID,
            Duration = 2
        })
    else
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        wait(0.3)
        MainFrame.Visible = false
    end
end

ToggleButton.MouseButton1Click:Connect(toggleUI)
CloseButton.MouseButton1Click:Connect(toggleUI)

-- Rainbow border effect
spawn(function()
    while true do
        for i = 0, 360, 5 do
            ToggleStroke.Color = Color3.fromHSV(i/360, 1, 1)
            wait(0.05)
        end
    end
end)

-- Rainbow border effect
spawn(function()
    while true do
        for i = 0, 360, 5 do
            ToggleStroke.Color = Color3.fromHSV(i/360, 1, 1)
            wait(0.05)
        end
    end
end)

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if FarmingEnabled then
        toggleFarm() -- Restart farm
        toggleFarm()
    end
end)

-- Initial notification
StarterGui:SetCore("SendNotification", {
    Title = "🐵 KHỈ CAM FARM [DEMO]",
    Text = "Script loaded successfully!",
    Icon = IconID,
    Duration = 5
})

print("🐵 Khỉ Cam Farm [DEMO] - Loaded!")
