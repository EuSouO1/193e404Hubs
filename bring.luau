-- TP Hub
-- baseado no PlayerHub + sistema de teleporte avançado

local plr = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local function getHum()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local hum = getHum()

-- GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "TPHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,420,0,420)
frame.Position = UDim2.new(0.5,-210,0.5,-210)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "TP Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL PLAYER LIST
local playerList = Instance.new("ScrollingFrame", frame)
playerList.Size = UDim2.new(0.4,-5,1,-40)
playerList.Position = UDim2.new(0,5,0,35)
playerList.CanvasSize = UDim2.new(0,0,0,0)
playerList.BackgroundColor3 = Color3.fromRGB(30,30,30)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 6

local listLayout = Instance.new("UIListLayout", playerList)
listLayout.Padding = UDim.new(0,4)

local actions = Instance.new("ScrollingFrame", frame)
actions.Size = UDim2.new(0.6,-10,1,-40)
actions.Position = UDim2.new(0.4,10,0,35)
actions.CanvasSize = UDim2.new(0,0,0,0)
actions.BackgroundColor3 = Color3.fromRGB(35,35,35)
actions.BorderSizePixel = 0
actions.ScrollBarThickness = 6

local actionsLayout = Instance.new("UIListLayout", actions)
actionsLayout.Padding = UDim.new(0,6)

local selectedPlayer = nil
local onlyUnanchored = false

local function updateCanvas(scroller,layout)
    task.wait()
    scroller.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- seleção de player
local function addPlayerButton(p)
    local b = Instance.new("TextButton", playerList)
    b.Size = UDim2.new(1,-6,0,30)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Text = p.Name
    
    b.MouseButton1Click:Connect(function()
        selectedPlayer = p
        for _,v in pairs(playerList:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Color3.fromRGB(60,60,60)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(0,170,255)
    end)
    updateCanvas(playerList,listLayout)
end

for _,p in ipairs(Players:GetPlayers()) do addPlayerButton(p) end
Players.PlayerAdded:Connect(addPlayerButton)

-- botão helper
local function action(name,callback)
    local btn = Instance.new("TextButton", actions)
    btn.Size = UDim2.new(1,-6,0,38)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = name
    btn.MouseButton1Click:Connect(callback)
    updateCanvas(actions,actionsLayout)
end

-- Only unanchored toggle
action("Only UnAnchored: OFF",function(self)
    onlyUnanchored = not onlyUnanchored
end)

local function validPart(part)
    if not part:IsA("BasePart") then return false end
    if onlyUnanchored and part.Anchored then return false end
    return true
end

-- bring tools
action("Bring Tools",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end
    for _,tool in ipairs(workspace:GetDescendants()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            tool.Handle.CFrame = hrp.CFrame
        end
    end
end)

-- tp to tools
action("TP To Tools",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end
    for _,tool in ipairs(workspace:GetDescendants()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            hrp.CFrame = tool.Handle.CFrame
            task.wait()
        end
    end
end)

-- bring parts
action("Bring Parts",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end
    for _,v in ipairs(workspace:GetDescendants()) do
        if validPart(v) then
            v.CFrame = hrp.CFrame
        end
    end
end)

-- tp to player
action("TP To Selected",function()
    if not selectedPlayer then return end
    local hrp = getHRP(plr.Character)
    local target = getHRP(selectedPlayer.Character)
    if hrp and target then hrp.CFrame = target.CFrame end
end)

-- bring selected
action("Bring Selected",function()
    if not selectedPlayer then return end
    local hrp = getHRP(plr.Character)
    local target = getHRP(selectedPlayer.Character)
    if hrp and target then target.CFrame = hrp.CFrame end
end)

-- bring all players
action("Bring All Players",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            local target = getHRP(p.Character)
            if target then target.CFrame = hrp.CFrame end
        end
    end
end)

-- close
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
