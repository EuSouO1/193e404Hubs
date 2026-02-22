--// GUI
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingGui_V2"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,340) -- Aumentei um pouco o tamanho para caber o novo botão
frame.Position = UDim2.new(0.5,-150,0.5,-170)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Fling Player Pro"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8,0,0,35)
box.Position = UDim2.new(0.1,0,0.12,0)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)

local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.9,0,0,90)
listFrame.Position = UDim2.new(0.05,0,0.25,0)
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,4)

-- BOTÕES EXISTENTES
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,30)
toggle.Position = UDim2.new(0.1,0,0.55,0)
toggle.Text = "Fling OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

local itemToggle = Instance.new("TextButton", frame)
itemToggle.Size = UDim2.new(0.8,0,0,30)
itemToggle.Position = UDim2.new(0.1,0,0.65,0)
itemToggle.Text = "FlingItem OFF"
itemToggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
itemToggle.TextScaled = true
itemToggle.TextColor3 = Color3.new(1,1,1)

-- NOVO BOTÃO: FLING ALL
local allToggle = Instance.new("TextButton", frame)
allToggle.Size = UDim2.new(0.8,0,0,30)
allToggle.Position = UDim2.new(0.1,0,0.75,0)
allToggle.Text = "Fling All OFF"
allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
allToggle.TextScaled = true
allToggle.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ATUALIZAÇÃO DA LISTA
local function refreshPlayers()
    for _,v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-6,0,24)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Text = p.Name
            btn.Parent = listFrame
            btn.MouseButton1Click:Connect(function() box.Text = p.Name end)
        end
    end
end
refreshPlayers()
game.Players.PlayerAdded:Connect(refreshPlayers)
game.Players.PlayerRemoving:Connect(refreshPlayers)

-- ESTADOS
local running = false
local flingItem = false
local flingAllActive = false
local currentDist = 2
local currentTarget = nil

task.spawn(function()
    while true do
        currentDist = math.random(1, 4)
        task.wait(0.1)
    end
end)

itemToggle.MouseButton1Click:Connect(function()
    flingItem = not flingItem
    itemToggle.Text = flingItem and "FlingItem ON" or "FlingItem OFF"
    itemToggle.BackgroundColor3 = flingItem and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

-- FUNÇÃO CORE DO FLING
local function flingLoop()
    local spin = 0
    while (running or flingAllActive) do
        local char = plr.Character
        local target = currentTarget
        if not char or not target or not target.Character then 
            RunService.Heartbeat:Wait()
            continue 
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not thrp then 
            RunService.Heartbeat:Wait()
            continue 
        end

        -- LÓGICA DE ATAQUE
        if flingItem then
            local tool = plr.Backpack:FindFirstChildOfClass("Tool")
            if tool then char.Humanoid:EquipTool(tool) end
            hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, currentDist)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        else
            spin += 120
            local pos = thrp.Position + Vector3.new(math.cos(spin)*2.5, 0, math.sin(spin)*2.5)
            hrp.CFrame = CFrame.new(pos, thrp.Position)
            hrp.AssemblyLinearVelocity = (thrp.Position - hrp.Position).Unit * 3000
            hrp.AssemblyAngularVelocity = Vector3.new(0, 75000, 0)
        end
        RunService.Heartbeat:Wait()
    end
end

-- LOGICA FLING ALL
allToggle.MouseButton1Click:Connect(function()
    flingAllActive = not flingAllActive
    allToggle.Text = flingAllActive and "Fling All ON" or "Fling All OFF"
    allToggle.BackgroundColor3 = flingAllActive and Color3.fromRGB(0,170,0) or Color3.fromRGB(0, 85, 127)
    
    if flingAllActive then
        running = false -- Desliga o fling individual para não conflitar
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        
        task.spawn(function()
            while flingAllActive do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if not flingAllActive then break end
                    if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        currentTarget = p
                        task.wait(0.5) -- Tempo em cada alvo
                    end
                end
                task.wait(0.1)
            end
            currentTarget = nil
        end)
        task.spawn(flingLoop)
    end
end)

-- LOGICA FLING INDIVIDUAL
toggle.MouseButton1Click:Connect(function()
    running = not running
    if running then
        flingAllActive = false -- Desliga o Fling All
        allToggle.Text = "Fling All OFF"
        allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)

        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(box.Text:lower()) then target = p break end
        end
        
        if target then
            currentTarget = target
            toggle.Text = "Flinging..."
            toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
            task.spawn(flingLoop)
        else
            running = false
            toggle.Text = "Not Found"
            task.wait(1)
            toggle.Text = "Fling OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        end
    else
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        currentTarget = nil
    end
end)
