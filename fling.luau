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

-- TOGGLE NORMAL
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,30)
toggle.Position = UDim2.new(0.1,0,0.75,0)
toggle.Text = "Fling OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

-- NOVO TOGGLE
local itemToggle = Instance.new("TextButton", frame)
itemToggle.Size = UDim2.new(0.8,0,0,30)
itemToggle.Position = UDim2.new(0.1,0,0.87,0)
itemToggle.Text = "FlingItem OFF"
itemToggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
itemToggle.TextScaled = true
itemToggle.TextColor3 = Color3.new(1,1,1)

-- FECHAR
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

-- procurar player
local function findPlayer(str)
    str = str:lower()
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr and p.Name:lower():find(str,1,true) then
            return p
        end
    end
end

-- estados
local running = false
local flingItem = false

itemToggle.MouseButton1Click:Connect(function()
    flingItem = not flingItem
    itemToggle.Text = flingItem and "FlingItem ON" or "FlingItem OFF"
    itemToggle.BackgroundColor3 = flingItem and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)
-- fling
local function flingLoop(target)
    local spin = 0

    while running and target and target.Character do
        local char = plr.Character
        if not char then break end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        local thum = target.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not thrp or not thum then break end

        -- ===== VERIFICA SENTAR =====
        if flingItem and thum.Sit then
            -- joga você no void
            hrp.CFrame = hrp.CFrame - Vector3.new(0,2048,0)

            -- para completamente
            running = false
            toggle.Text = "Fling OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
            break
        end

        -- ===== FLING ITEM =====
        if flingItem then
            -- fica sempre olhando pro alvo
            local pos = thrp.Position - (thrp.CFrame.LookVector * 2.5)
            hrp.CFrame = CFrame.new(pos, thrp.Position)

            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

        else
            -- ===== FLING NORMAL =====
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
        end

        RunService.Heartbeat:Wait()
    end
end
-- toggle principal
toggle.MouseButton1Click:Connect(function()
    running = not running

    if running then
        toggle.Text = "Fling ON"
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
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
