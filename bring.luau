--// Player
local plr = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local function getHum()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local hum = getHum()

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "PlayerHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,420)
frame.Position = UDim2.new(0.5,-160,0.5,-210)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Player Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,35)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

local function updateCanvas()
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

-- =========================
-- PLAYER LIST
-- =========================

local selectedPlayer = nil
local onlyUnanchored = false

local function playerButton(p)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,28)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = p.Name

    btn.MouseButton1Click:Connect(function()
        selectedPlayer = p
        btn.Text = ">> "..p.Name
    end)
    updateCanvas()
end

local function refreshPlayers()
    for _,v in pairs(scroll:GetChildren()) do
        if v.Name == "PLAYERBTN" then v:Destroy() end
    end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= plr then
            playerButton(p)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

-- =========================
-- UTIL FUNCS
-- =========================

local function getHRP(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function validPart(p)
    if not p:IsA("BasePart") then return false end
    if onlyUnanchored and p.Anchored then return false end
    return true
end

-- =========================
-- ACTION BUTTON MAKER
-- =========================

local function makeAction(text,callback)
    local btn = Instance.new("TextButton",scroll)
    btn.Size = UDim2.new(1,-8,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text

    btn.MouseButton1Click:Connect(callback)
    updateCanvas()
end

-- =========================
-- ACTIONS
-- =========================

-- Bring all tools
makeAction("Bring Tools",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            v.Handle.CFrame = hrp.CFrame
        end
    end
end)

-- Player to all tools
makeAction("TP to Tools",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            hrp.CFrame = v.Handle.CFrame
            task.wait(0.1)
        end
    end
end)

-- Bring parts
makeAction("Bring Parts",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if validPart(v) then
            v.CFrame = hrp.CFrame
        end
    end
end)

-- TP to player
makeAction("Goto Player",function()
    if not selectedPlayer then return end
    local target = getHRP(selectedPlayer.Character)
    local hrp = getHRP(plr.Character)
    if target and hrp then
        hrp.CFrame = target.CFrame
    end
end)

-- Bring player
makeAction("Bring Player",function()
    if not selectedPlayer then return end
    local target = getHRP(selectedPlayer.Character)
    local hrp = getHRP(plr.Character)
    if target and hrp then
        target.CFrame = hrp.CFrame
    end
end)

-- Bring all players
makeAction("Bring All Players",function()
    local hrp = getHRP(plr.Character)
    if not hrp then return end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= plr then
            local target = getHRP(p.Character)
            if target then
                target.CFrame = hrp.CFrame
            end
        end
    end
end)

-- Only unanchored toggle
makeAction("Only UnAnchored: OFF",function(btn)
end)

local toggleBtn = scroll:FindFirstChildOfClass("TextButton")
toggleBtn.Text = "Only UnAnchored OFF"
toggleBtn.MouseButton1Click:Connect(function()
    onlyUnanchored = not onlyUnanchored
    toggleBtn.Text = "Only UnAnchored "..(onlyUnanchored and "ON" or "OFF")
end)
