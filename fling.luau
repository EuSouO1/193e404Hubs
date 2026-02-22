--// GUI CONFIG
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingGui_V2"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 350) -- Aumentado de 300 para 350
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Fling Player Pro"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8, 0, 0, 35)
box.Position = UDim2.new(0.1, 0, 0.12, 0)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.TextColor3 = Color3.new(1, 1, 1)

-- LISTA DE JOGADORES
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.9, 0, 0, 100)
listFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0, 4)

-- BOTÕES (POSIÇÕES AJUSTADAS)
local flingAllBtn = Instance.new("TextButton", frame)
flingAllBtn.Size = UDim2.new(0.8, 0, 0, 30)
flingAllBtn.Position = UDim2.new(0.1, 0, 0.58, 0)
flingAllBtn.Text = "Fling All OFF"
flingAllBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
flingAllBtn.TextScaled = true
flingAllBtn.TextColor3 = Color3.new(1, 1, 1)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8, 0, 0, 30)
toggle.Position = UDim2.new(0.1, 0, 0.68, 0)
toggle.Text = "Fling OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1, 1, 1)

local itemToggle = Instance.new("TextButton", frame)
itemToggle.Size = UDim2.new(0.8, 0, 0, 30)
itemToggle.Position = UDim2.new(0.1, 0, 0.78, 0)
itemToggle.Text = "FlingItem OFF"
itemToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
itemToggle.TextScaled = true
itemToggle.TextColor3 = Color3.new(1, 1, 1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -28, 0, 4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ESTADOS
local running = false
local flingItem = false
local flingAllActive = false
local currentDist = 2

-- FUNÇÃO DE ATAQUE (DEVE VIR ANTES DOS EVENTOS)
local function flingLoop(target)
    local spin = 0
    local isVoiding = false
    
    while (running or flingAllActive) and target and target.Character do
        local char = plr.Character
        local tchar = target.Character
        if not char or not tchar then break end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        local thum = tchar:FindFirstChildOfClass("Humanoid")
        if not hrp or not thrp or not thum then break end

        if thum.Sit or isVoiding then
            isVoiding = true
            hrp.CFrame = CFrame.new(thrp.Position.X, -3000, thrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.new(0, -5000, 0)
        else
            if flingItem then
                local tool = plr.Backpack:FindFirstChildOfClass("Tool")
                if tool then char.Humanoid:EquipTool(tool) end
                hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, currentDist)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            else
                spin += 60
                local pos = thrp.Position + Vector3.new(math.cos(spin)*2.5, 0, math.sin(spin)*2.5)
                hrp.CFrame = CFrame.new(pos, thrp.Position)
                hrp.AssemblyLinearVelocity = (thrp.Position - hrp.Position).Unit * 500
                hrp.AssemblyAngularVelocity = Vector3.new(0, 10000, 0)
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- ATUALIZAÇÃO DA LISTA
local function refreshPlayers()
    for _,v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.new(1, 1, 1)
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

-- EVENTOS DE CLIQUE
flingAllBtn.MouseButton1Click:Connect(function()
    flingAllActive = not flingAllActive
    if flingAllActive then
        flingAllBtn.Text = "Fling All ON"
        flingAllBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        task.spawn(function()
            while flingAllActive do
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if not flingAllActive then break end
                    if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        task.spawn(function() flingLoop(p) end)
                        task.wait(0.5) 
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        flingAllBtn.Text = "Fling All OFF"
        flingAllBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

toggle.MouseButton1Click:Connect(function()
    running = not running
    if running then
        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(box.Text:lower()) then target = p break end
        end
        if target then
            toggle.Text = "Flinging..."
            toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            task.spawn(function() flingLoop(target) end)
        else
            running = false
            toggle.Text = "Not Found"
            task.wait(1)
            toggle.Text = "Fling OFF"
        end
    else
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

itemToggle.MouseButton1Click:Connect(function()
    flingItem = not flingItem
    itemToggle.Text = flingItem and "FlingItem ON" or "FlingItem OFF"
    itemToggle.BackgroundColor3 = flingItem and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

task.spawn(function()
    while true do
        currentDist = math.random(1, 4)
        task.wait(0.1)
    end
end)
