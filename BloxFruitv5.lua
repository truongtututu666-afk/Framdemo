--[[
    🐵 KHỈ CAM FARM [DEMO] - FIXED VERSION
    🎨 No errors, fully protected
    📦 Advanced Chest Farming System
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
local NoclipConnection = nil
local ChestCount = 0
local StartTime = tick()

-- Safe check for game
local isBloxFruits = game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 7449423635

-- Safe get workspace locations
local Locations = nil
pcall(function()
    if workspace:FindFirstChild("_WorldOrigin") then
        Locations = workspace._WorldOrigin:FindFirstChild("Locations")
    end
end)

-- Safe character function
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    
    -- Wait for essential parts
    local humanoid = char:WaitForChild("Humanoid", 5)
    local rootPart = char:WaitForChild("HumanoidRootPart", 5) or char:WaitForChild("Torso", 5)
    
    if not humanoid or not rootPart then
        warn("Character parts not found!")
        return nil
    end
    
    return char
end

-- Safe distance sort
local function DistanceFromPlrSort(ObjectList)
    local char = getCharacter()
    if not char then return end
    
    local RootPart = char:FindFirstChild("LowerTorso") or 
                     char:FindFirstChild("HumanoidRootPart") or 
                     char:FindFirstChild("Torso")
    
    if not RootPart then return end
    
    pcall(function()
        table.sort(ObjectList, function(ChestA, ChestB)
            if not ChestA or not ChestB then return false end
            if not ChestA.Parent or not ChestB.Parent then return false end
            
            local RootPos = RootPart.Position
            local DistanceA = (RootPos - ChestA.Position).Magnitude
            local DistanceB = (RootPos - ChestB.Position).Magnitude
            return DistanceA < DistanceB
        end)
    end)
end

-- Safe chest finder
local UncheckedChests, FirstRun = {}, true
local function getChestsSorted()
    local Chests = {}
    
    pcall(function()
        if FirstRun then
            FirstRun = false
            for _, Object in pairs(workspace:GetDescendants()) do
                if Object:IsA("Part") and Object.Name:find("Chest") then
                    table.insert(UncheckedChests, Object)
                end
            end
        end
        
        for i = #UncheckedChests, 1, -1 do
            local Chest = UncheckedChests[i]
            if Chest and Chest.Parent then
                if Chest:FindFirstChild("TouchInterest") then
                    table.insert(Chests, Chest)
                end
            else
                table.remove(UncheckedChests, i)
            end
        end
        
        DistanceFromPlrSort(Chests)
    end)
    
    return Chests
end

-- Safe noclip toggle
local function toggleNoclip(Toggle)
    local char = getCharacter()
    if not char then return end
    
    pcall(function()
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = not Toggle
            end
        end
    end)
end

-- Safe teleport
local function Teleport(Goal)
    local char = getCharacter()
    if not char then return end
    
    local RootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not RootPart then return end
    
    pcall(function()
        toggleNoclip(true)
        RootPart.CFrame = Goal + Vector3.new(0, 3, 0)
        wait(0.1)
        toggleNoclip(false)
    end)
end

-- Safe notification
local function SafeNotify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = IconID,
            Duration = duration or 3
        })
    end)
end

-- Create GUI safely
local ScreenGui = nil
pcall(function()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KhiCamFarmGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if LocalPlayer:FindFirstChild("PlayerGui") then
        ScreenGui.Parent = LocalPlayer.PlayerGui
    else
        warn("PlayerGui not found!")
        return
    end
end)

if not ScreenGui then
    warn("Failed to create GUI!")
    return
end

-- Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Image = IconID
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 10, 0.5, -40)
ToggleButton.Size = UDim2.new(0, 80, 0, 80)
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 200, 0)
ToggleStroke.Thickness = 3
ToggleStroke.Parent = ToggleButton

-- Safe animation
spawn(function()
    pcall(function()
        while ToggleButton.Parent do
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

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 25)
MainCorner.Parent = MainFrame

-- Gradient
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 255))
}
MainGradient.Rotation = 0
MainGradient.Parent = MainFrame

-- Safe gradient animation
spawn(function()
    pcall(function()
        while MainFrame.Parent do
            for i = 0, 360, 2 do
                if not MainGradient.Parent then break end
                MainGradient.Rotation = i
                wait(0.05)
            end
        end
    end)
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

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.Parent = InnerFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 23)
TitleCorner.Parent = TitleBar

-- Title Icon
local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Image = IconID
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 15, 0.5, -25)
TitleIcon.Size = UDim2.new(0, 50, 0, 50)
TitleIcon.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 75, 0, 0)
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.RichText = true
TitleText.Text = '🐵 KHỈ CAM FARM <font color="rgb(255,140,0)">[DEMO]</font>'
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 22
TitleText.Parent = TitleBar

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

-- Content
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 15, 0, 70)
ContentFrame.Size = UDim2.new(1, -30, 1, -85)
ContentFrame.ScrollBarThickness = 8
ContentFrame.Parent = InnerFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 20)
ContentCorner.Parent = ContentFrame

-- Status Display
local StatusLabel = Instance.new("TextLabel")
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 10)
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Text = "FARM STATUS: INACTIVE"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 18
StatusLabel.Parent = ContentFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusLabel

-- Info Labels
local ChestLabel = Instance.new("TextLabel")
ChestLabel.BackgroundTransparency = 1
ChestLabel.Position = UDim2.new(0, 10, 0, 60)
ChestLabel.Size = UDim2.new(1, -20, 0, 30)
ChestLabel.Font = Enum.Font.Gotham
ChestLabel.Text = "📦 Chests Collected: 0"
ChestLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ChestLabel.TextSize = 16
ChestLabel.Parent = ContentFrame

local TimeLabel = Instance.new("TextLabel")
TimeLabel.BackgroundTransparency = 1
TimeLabel.Position = UDim2.new(0, 10, 0, 90)
TimeLabel.Size = UDim2.new(1, -20, 0, 30)
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.Text = "⏰ Farm Time: 00:00:00"
TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeLabel.TextSize = 16
TimeLabel.Parent = ContentFrame

-- Farm Button
local FarmButton = Instance.new("TextButton")
FarmButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
FarmButton.Position = UDim2.new(0.5, -100, 0, 130)
FarmButton.Size = UDim2.new(0, 200, 0, 60)
FarmButton.Font = Enum.Font.GothamBold
FarmButton.Text = "🚀 START FARMING"
FarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmButton.TextSize = 18
FarmButton.Parent = ContentFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 15)
FarmCorner.Parent = FarmButton

-- Warning if not Blox Fruits
if not isBloxFruits then
    local WarningLabel = Instance.new("TextLabel")
    WarningLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    WarningLabel.Position = UDim2.new(0, 10, 0, 200)
    WarningLabel.Size = UDim2.new(1, -20, 0, 60)
    WarningLabel.Font = Enum.Font.GothamBold
    WarningLabel.Text = "⚠️ WARNING: This is not Blox Fruits!\nScript may not work properly!"
    WarningLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WarningLabel.TextSize = 14
    WarningLabel.Parent = ContentFrame
    
    local WarningCorner = Instance.new("UICorner")
    WarningCorner.CornerRadius = UDim.new(0, 10)
    WarningCorner.Parent = WarningLabel
end

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 300)

-- Safe farm toggle
local function toggleFarm()
    FarmingEnabled = not FarmingEnabled
    
    if FarmingEnabled then
        StartTime = tick()
        ChestCount = 0
        
        FarmButton.Text = "⏹️ STOP FARMING"
        StatusLabel.Text = "FARM STATUS: ACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        
        SafeNotify("🐵 KHỈ CAM FARM", "Chest farming started!", 3)
        
        -- Safe farming loop
        FarmConnection = task.spawn(function()
            while FarmingEnabled do
                pcall(function()
                    task.wait()
                    local Chests = getChestsSorted()
                    if Chests and #Chests > 0 then
                        Teleport(Chests[1].CFrame)
                        ChestCount = ChestCount + 1
                        ChestLabel.Text = "📦 Chests Collected: " .. ChestCount
                    end
                end)
            end
        end)
        
        -- Safe team set (only for Blox Fruits)
        if isBloxFruits then
            task.spawn(function()
                while FarmingEnabled do
                    task.wait(5)
                    pcall(function()
                        if ReplicatedStorage:FindFirstChild("Remotes") then
                            local CommF = ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                            if CommF then
                                CommF:InvokeServer("SetTeam", "Marines")
                            end
                        end
                    end)
                end
            end)
        end
        
    else
        FarmButton.Text = "🚀 START FARMING"
        StatusLabel.Text = "FARM STATUS: INACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        if FarmConnection then
            pcall(function() task.cancel(FarmConnection) end)
        end
        
        SafeNotify("🐵 KHỈ CAM FARM", "Chest farming stopped!", 3)
    end
end

-- Safe button connection
pcall(function()
    FarmButton.MouseButton1Click:Connect(toggleFarm)
end)

-- Safe timer update
spawn(function()
    pcall(function()
        while ScreenGui.Parent do
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
end)

-- Safe UI toggle
local UIVisible = false
local function toggleUI()
    UIVisible = not UIVisible
    
    pcall(function()
        if UIVisible then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 500, 0, 500),
                Position = UDim2.new(0.5, -250, 0.5, -250)
            }):Play()
            
            SafeNotify("🐵 KHỈ CAM FARM [DEMO]", "UI Opened!", 2)
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            wait(0.3)
            MainFrame.Visible = false
        end
    end)
end

-- Safe button connections
pcall(function()
    ToggleButton.MouseButton1Click:Connect(toggleUI)
    CloseButton.MouseButton1Click:Connect(toggleUI)
end)

-- Safe rainbow effect
spawn(function()
    pcall(function()
        while ToggleStroke.Parent do
            for i = 0, 360, 5 do
                if not ToggleStroke.Parent then break end
                ToggleStroke.Color = Color3.fromHSV(i/360, 1, 1)
                wait(0.05)
            end
        end
    end)
end)

-- Safe character respawn handler
pcall(function()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if FarmingEnabled then
            toggleFarm() -- Restart
            toggleFarm()
        end
    end)
end)

-- Initial notification
SafeNotify("🐵 KHỈ CAM FARM [DEMO]", "Script loaded successfully!", 5)

print("🐵 Khỉ Cam Farm [DEMO] - Loaded without errors!")

end) -- End of main pcall

-- Error handling
if not success then
    warn("Script error: " .. tostring(err))
    
    -- Try to show error notification
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ SCRIPT ERROR",
            Text = "Failed to load! Check console (F9)",
            Duration = 10
        })
    end)
end
