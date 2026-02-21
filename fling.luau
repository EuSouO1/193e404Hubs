--// GUI
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,300)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
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

-- LISTA
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

-- BOTÃO NORMAL
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.75,0)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

-- BOTÃO MULTI
local multi = Instance.new("TextButton", frame)
multi.Size = UDim2.new(0.8,0,0,30)
multi.Position = UDim2.new(0.1,0,0.62,0)
multi.Text = "MULTI: OFF"
multi.BackgroundColor3 = Color3.fromRGB(80,80,80)
multi.TextScaled = true
multi.TextColor3 = Color3.new(1,1,1)

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
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr and p.Name:lower():find(str,1,true) then
            return p
        end
    end
end

-- fling base
local running = false
local multiMode = false

local function flingTarget(target, duration)
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local start = tick()
    local spin = 0

    while running and target and target.Character and tick()-start < duration do
        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not thrp then break end

        spin += 60

        local radius = 2.5
        local pos = thrp.Position + Vector3.new(
            math.cos(math.rad(spin))*radius,
            1.5,
            math.sin(math.rad(spin))*radius
        )

        hrp.CFrame = CFrame.new(pos, thrp.Position)
        hrp.AssemblyLinearVelocity = (thrp.Position - pos).Unit * -400
        hrp.AssemblyAngularVelocity = Vector3.new(0,9999,0)

        RunService.Heartbeat:Wait()
    end
end

-- LOOP MULTI
local function multiFlingLoop()
    while running do
        for _,p in ipairs(game.Players:GetPlayers()) do
            if not running then break end
            if p ~= plr then
                flingTarget(p,1.2)
                task.wait(0.15)
            end
        end
        task.wait(0.2)
    end
end

-- botão multi
multi.MouseButton1Click:Connect(function()
    multiMode = not multiMode
    multi.Text = multiMode and "MULTI: ON" or "MULTI: OFF"
    multi.BackgroundColor3 = multiMode and Color3.fromRGB(0,120,255) or Color3.fromRGB(80,80,80)
end)

-- botão principal
toggle.MouseButton1Click:Connect(function()
    running = not running

    if running then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)

        if multiMode then
            task.spawn(multiFlingLoop)
        else
            local target = findPlayer(box.Text)
            if target then
                task.spawn(function()
                    flingTarget(target,999)
                end)
            else
                toggle.Text = "NOT FOUND"
                running = false
            end
        end
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
