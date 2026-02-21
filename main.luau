--// GUI
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,260)
frame.Position = UDim2.new(0.5,-150,0.5,-130)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Fling Player"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8,0,0,35)
box.Position = UDim2.new(0.1,0,0.15,0)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)

-- LISTA DE PLAYERS
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.9,0,0,110)
listFrame.Position = UDim2.new(0.05,0,0.32,0)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.78,0)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- atualizar lista
local function refreshPlayers()
    for _,v in ipairs(listFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-6,0,24)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Text = p.Name
            btn.Parent = listFrame

            btn.MouseButton1Click:Connect(function()
                box.Text = p.Name
            end)
        end
    end

    task.wait()
    listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end

refreshPlayers()
game.Players.PlayerAdded:Connect(refreshPlayers)
game.Players.PlayerRemoving:Connect(refreshPlayers)

-- procurar player parecido
local function findPlayer(str)
    str = str:lower()
    local best,score

    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            local name = p.Name:lower()
            local s = 0

            for i=1,#str do
                if name:sub(i,i) == str:sub(i,i) then
                    s = s + 1
                end
            end

            if not score or s > score then
                score = s
                best = p
            end
        end
    end

    return best
end

-- fling
local running = false

local function flingLoop(target)
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local spin = 0

    while running and target and target.Character do
        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not thrp then break end

        spin += 45

        local radius = 2.2
        local pos = thrp.Position + Vector3.new(
            math.cos(math.rad(spin))*radius,
            math.sin(math.rad(spin*2))*1.5,
            math.sin(math.rad(spin))*radius
        )

        hrp.CFrame = CFrame.new(pos, thrp.Position)
        hrp.AssemblyLinearVelocity = (thrp.Position - pos).Unit * -350
        hrp.AssemblyAngularVelocity = Vector3.new(0,9999,0)

        RunService.Heartbeat:Wait()
    end
end

-- toggle
toggle.MouseButton1Click:Connect(function()
    running = not running

    if running then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)

        local target = findPlayer(box.Text)
        if target then
            task.spawn(function()
                flingLoop(target)
            end)
        else
            toggle.Text = "NOT FOUND"
            running = false
        end
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
