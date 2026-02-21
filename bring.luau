--// Player
local plr = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local function getHum()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "PlayerHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,340,0,440)
frame.Position = UDim2.new(0.5,-170,0.5,-220)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,32)
title.BackgroundTransparency = 1
title.Text = "Player Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- scroll
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,40)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,0,0)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

local function updateCanvas()
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

-- sections
local function section(text)
    local lbl = Instance.new("TextLabel",scroll)
    lbl.Size = UDim2.new(1,-8,0,26)
    lbl.BackgroundColor3 = Color3.fromRGB(20,20,20)
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.Text = text
    updateCanvas()
end

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1,-8,0,24)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.fromRGB(200,200,200)
targetLabel.TextScaled = true
targetLabel.Text = "Alvo: Nenhum"
targetLabel.Parent = scroll

local selectedPlayer=nil
local onlyUnanchored=false

-- PLAYERS SECTION
section("Players")
targetLabel.Parent = scroll

local function playerButton(p)
    local btn = Instance.new("TextButton",scroll)
    btn.Size = UDim2.new(1,-8,0,26)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = p.Name

    btn.MouseButton1Click:Connect(function()
        selectedPlayer=p
        targetLabel.Text="Alvo: "..p.Name
    end)
    updateCanvas()
end

local function refreshPlayers()
    for _,v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") and v~=targetLabel then
            if v:GetAttribute("player") then v:Destroy() end
        end
    end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=plr then
            local b=Instance.new("TextButton")
            b:SetAttribute("player",true)
            b.Parent=scroll
            b.Size=UDim2.new(1,-8,0,26)
            b.BackgroundColor3=Color3.fromRGB(45,45,45)
            b.TextColor3=Color3.new(1,1,1)
            b.TextScaled=true
            b.Text=p.Name
            b.MouseButton1Click:Connect(function()
                selectedPlayer=p
                targetLabel.Text="Alvo: "..p.Name
            end)
        end
    end
    updateCanvas()
end
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

-- OPTIONS SECTION
section("Opções")

local function action(name,func)
    local b=Instance.new("TextButton",scroll)
    b.Size=UDim2.new(1,-8,0,36)
    b.BackgroundColor3=Color3.fromRGB(70,70,70)
    b.TextColor3=Color3.new(1,1,1)
    b.TextScaled=true
    b.Text=name
    b.MouseButton1Click:Connect(func)
    updateCanvas()
end

local function validPart(p)
    if not p:IsA("BasePart") then return false end
    if onlyUnanchored and p.Anchored then return false end
    return true
end

-- bring tools
action("Bring Tools",function()
    local hrp=getHRP(plr.Character)
    if not hrp then return end
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            v.Handle.CFrame=hrp.CFrame
        end
    end
end)

-- tp to tools
action("TP to Tools",function()
    local hrp=getHRP(plr.Character)
    if not hrp then return end
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            hrp.CFrame=v.Handle.CFrame
            task.wait(0.1)
        end
    end
end)

-- bring parts
action("Bring Parts",function()
    local hrp=getHRP(plr.Character)
    if not hrp then return end
    for _,v in pairs(workspace:GetDescendants()) do
        if validPart(v) then v.CFrame=hrp.CFrame end
    end
end)

-- goto player
action("Goto Player",function()
    if not selectedPlayer then return end
    local hrp=getHRP(plr.Character)
    local target=getHRP(selectedPlayer.Character)
    if hrp and target then hrp.CFrame=target.CFrame end
end)

-- bring player
action("Bring Player",function()
    if not selectedPlayer then return end
    local hrp=getHRP(plr.Character)
    local target=getHRP(selectedPlayer.Character)
    if hrp and target then target.CFrame=hrp.CFrame end
end)

-- bring all players
action("Bring All Players",function()
    local hrp=getHRP(plr.Character)
    if not hrp then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=plr then
            local t=getHRP(p.Character)
            if t then t.CFrame=hrp.CFrame end
        end
    end
end)

-- only unanchored toggle
local toggle
toggle=action("Only UnAnchored: OFF",function()
    onlyUnanchored=not onlyUnanchored
    toggle.Text="Only UnAnchored: "..(onlyUnanchored and "ON" or "OFF")
end)
