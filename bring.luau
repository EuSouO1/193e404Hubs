--// SERVICES
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BringHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,380,0,420)
frame.Position = UDim2.new(0.02,0,0.5,-210)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Bring Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

--// PLAYER LIST
local playerScroll = Instance.new("ScrollingFrame", frame)
playerScroll.Size = UDim2.new(1,-10,0,140)
playerScroll.Position = UDim2.new(0,5,0,35)
playerScroll.BackgroundColor3 = Color3.fromRGB(35,35,35)
playerScroll.ScrollBarThickness = 6
playerScroll.BorderSizePixel = 0

local listLayout = Instance.new("UIListLayout", playerScroll)
listLayout.Padding = UDim.new(0,4)

local selectedPlayer = nil

local function refreshPlayers()

    -- apagar apenas botões antigos
    for _,child in pairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= plr then

            local btn = Instance.new("TextButton")
            btn.Parent = playerScroll
            btn.Size = UDim2.new(1,-4,0,28)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true

            btn.MouseButton1Click:Connect(function()
                selectedPlayer = p
                title.Text = "Selected: "..p.Name
            end)

        end
    end

    task.wait()
    playerScroll.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+5)
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

--// OPTIONS
local unanchoredOnly = false

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-10,0,35)
toggle.Position = UDim2.new(0,5,0,185)
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.Text = "UnAnchored Only OFF"
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

toggle.MouseButton1Click:Connect(function()
    unanchoredOnly = not unanchoredOnly
    toggle.Text = "UnAnchored Only "..(unanchoredOnly and "ON" or "OFF")
    toggle.BackgroundColor3 = unanchoredOnly and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

--// FUNCTIONS
local function myRoot()
    local char = plr.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function tpToPlayer()
    if not selectedPlayer then return end
    local targetRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot and myRoot() then
        myRoot().CFrame = targetRoot.CFrame + Vector3.new(0,0,3)
    end
end

local function bringPlayer()
    if not selectedPlayer then return end
    local targetRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot and myRoot() then
        targetRoot.CFrame = myRoot().CFrame + Vector3.new(0,0,3)
    end
end

local function bringParts(class)
    local root = myRoot()
    if not root then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA(class) then
            if (not unanchoredOnly) or (v.Anchored == false) then
                v.CFrame = root.CFrame + Vector3.new(math.random(-5,5),3,math.random(-5,5))
            end
        end
    end
end

local function bringTools()
    local root = myRoot()
    if not root then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            local h = v.Handle
            if (not unanchoredOnly) or (h.Anchored == false) then
                h.CFrame = root.CFrame + Vector3.new(math.random(-4,4),3,math.random(-4,4))
            end
        end
    end
end

--// BUTTON CREATOR
local function makeButton(text, y, func)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-10,0,35)
    b.Position = UDim2.new(0,5,0,y)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Text = text
    b.MouseButton1Click:Connect(func)
end

--// BUTTONS
makeButton("Teleport To Player",230,tpToPlayer)
makeButton("Bring Player",270,bringPlayer)
makeButton("Bring All Parts",310,function() bringParts("Part") end)
makeButton("Bring All MeshParts",350,function() bringParts("MeshPart") end)
makeButton("Bring All Tools",390,bringTools)
