--// Disaster Hub - Fixed & Optimized
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local char = plr.Character or plr.CharacterAdded:Wait()

-- Limpar GUIs antigas
local oldGui = plr.PlayerGui:FindFirstChild("DisasterHub_V1")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "DisasterHub_V1"
gui.ResetOnSpawn = false

--// GUI
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,320)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Selectable = true
frame.Draggable = true -- Nota: Alguns executores exigem script de drag manual, mas mantive por padrão

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Disaster Hub - Object Thrower"
title.TextColor3 = Color3.fromRGB(255, 120, 0)
title.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8,0,0,35)
box.Position = UDim2.new(0.1,0,0.12,0)
box.PlaceholderText = "Nome do alvo"
box.Text = ""
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

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.60,0)
toggle.Text = "Target Thrower: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)

local allToggle = Instance.new("TextButton", frame)
allToggle.Size = UDim2.new(0.8,0,0,35)
allToggle.Position = UDim2.new(0.1,0,0.75,0)
allToggle.Text = "Chaos Mode: OFF"
allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
allToggle.TextScaled = true
allToggle.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ESTADOS
local active = false
local chaosMode = false

-- ATUALIZAÇÃO DE JOGADORES
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

--// FUNÇÃO DE LANÇAMENTO (CORRIGIDA)
local function ThrowObjectsAt(target)
    if not target or not target.Character then return end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end

    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(char) then
            -- Força a posse física (Network Ownership)
            if settings().Physics.AllowSleep then
                part.Velocity = Vector3.new(0, 25, 0) -- "Acorda" a peça
            end
            
            -- Lógica de direção e força
            local direction = (tRoot.Position - part.Position).Unit
            part.Velocity = direction * 300 -- Força do tiro
            part.RotVelocity = Vector3.new(50, 50, 50) -- Faz girar no ar
        end
    end
end

-- TARGET THROWER LOOP
task.spawn(function()
    while task.wait(0.2) do
        if active then
            local target = nil
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Name:lower():find(box.Text:lower()) then
                    target = p
                    break
                end
            end
            if target then ThrowObjectsAt(target) end
        end
    end
end)

-- CHAOS MODE LOOP
task.spawn(function()
    while task.wait(0.3) do
        if chaosMode then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= plr then ThrowObjectsAt(p) end
            end
        end
    end
end)

-- BOTÕES (LOGICA)
toggle.MouseButton1Click:Connect(function()
    active = not active
    chaosMode = false
    allToggle.Text = "Chaos Mode: OFF"
    allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
    toggle.Text = active and "Arremessando..." or "Target Thrower: OFF"
    toggle.BackgroundColor3 = active and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

allToggle.MouseButton1Click:Connect(function()
    chaosMode = not chaosMode
    active = false
    toggle.Text = "Target Thrower: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    allToggle.Text = chaosMode and "Chaos Mode: ON" or "Chaos Mode: OFF"
    allToggle.BackgroundColor3 = chaosMode and Color3.fromRGB(0,170,0) or Color3.fromRGB(0, 85, 127)
end)
