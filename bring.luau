--// SERVICES
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BringHub"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,360)
frame.Position = UDim2.new(0.5,-160,0.5,-180)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Bring Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- fechar
local close = Instance.new("TextButton", gui)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(0.5,160,0.5,-180)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.TextScaled = true
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- scroll principal
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,0,160)
scroll.Position = UDim2.new(0,5,0,35)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

-- lista de players
local playerScroll = Instance.new("ScrollingFrame", frame)
playerScroll.Size = UDim2.new(1,-10,0,100)
playerScroll.Position = UDim2.new(0,5,0,200)
playerScroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
playerScroll.ScrollBarThickness = 6
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local playerLayout = Instance.new("UIListLayout", playerScroll)
playerLayout.Padding = UDim.new(0,4)

local selectedPlayer = nil
local unanchoredOnly = false

-- função criar botão
local function makeButton(text,callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-6,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text
    btn.Parent = scroll
    btn.MouseButton1Click:Connect(callback)
end

-- toggle unanchored
makeButton("UnAnchored Only: OFF",function(btn)
    unanchoredOnly = not unanchoredOnly
    btn.Text = "UnAnchored Only: "..(unanchoredOnly and "ON" or "OFF")
end)

-- pegar HRP
local function getHRP(plr)
    local char = plr.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
end

-- teleport
makeButton("Teleport To Player",function()
    if not selectedPlayer then return end
    local my = getHRP(lp)
    local tg = getHRP(selectedPlayer)
    if my and tg then
        my.CFrame = tg.CFrame + tg.CFrame.LookVector * -3
    end
end)

-- bring player
makeButton("Bring Player",function()
    if not selectedPlayer then return end
    local my = getHRP(lp)
    local tg = getHRP(selectedPlayer)
    if my and tg then
        tg.CFrame = my.CFrame + Vector3.new(0,0,-3)
    end
end)

-- bring parts
makeButton("Bring All Parts",function()
    local my = getHRP(lp)
    if not my then return end

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if not unanchoredOnly or not v.Anchored then
                v.CFrame = my.CFrame + Vector3.new(math.random(-5,5),3,math.random(-5,5))
            end
        end
    end
end)

-- bring tools
makeButton("Bring All Tools",function()
    local my = getHRP(lp)
    if not my then return end

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            v.Handle.CFrame = my.CFrame + Vector3.new(math.random(-4,4),2,math.random(-4,4))
        end
    end
end)

-- teleport to tool
makeButton("Teleport To Tool",function()
    local my = getHRP(lp)
    if not my then return end

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            my.CFrame = v.Handle.CFrame + Vector3.new(0,3,0)
            break
        end
    end
end)

-- atualizar lista players
local function refreshPlayers()
    for _,v in ipairs(playerScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-6,0,28)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Text = p.Name
            btn.Parent = playerScroll

            btn.MouseButton1Click:Connect(function()
                selectedPlayer = p
                title.Text = "Bring Hub - "..p.Name
            end)
        end
    end
end

-- atualizar sempre
task.spawn(function()
    while gui.Parent do
        refreshPlayers()
        task.wait(2)
    end
end)
