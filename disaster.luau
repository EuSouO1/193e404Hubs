--// Disaster Hub - Object Thrower (Tornado Mode)
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "DisasterHub_V1"
gui.ResetOnSpawn = false

--// GUI (Mesmo Estilo Fling Pro)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,320)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Disaster Hub - Object Thrower"
title.TextColor3 = Color3.new(1,0.5,0) -- Laranja desastre
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

-- BOTÕES
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
game.Players.PlayerRemoving:Connect(refreshPlayers)

--// LOGICA CORE: LANÇAR OBJETOS
local function ThrowObjectsAt(target)
    for _, part in pairs(workspace:GetDescendants()) do
        -- Verifica se é uma parte física que não está presa no chão
        if part:IsA("BasePart") and not part.Anchored and part.Name ~= "Terrain" and not part:IsDescendantOf(plr.Character) then
            
            -- Tenta pegar a posse física da parte
            pcall(function()
                if part.ReceiveAge == 0 then -- Só se puder assumir
                    part.Velocity = Vector3.new(0,0,0) -- Reseta pra não bugar
                end
            end)

            task.spawn(function()
                local tChar = target.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                
                if tRoot and part then
                    -- Calcula a direção do objeto para o alvo
                    local direction = (tRoot.Position - part.Position).Unit
                    -- Aplica velocidade massiva na direção do alvo
                    part.Velocity = direction * 250 -- Velocidade do arremesso
                end
            end)
        end
    end
end

-- LOGICA TARGET THROWER
toggle.MouseButton1Click:Connect(function()
    active = not active
    if active then
        chaosMode = false
        allToggle.Text = "Chaos Mode: OFF"
        allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)

        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(box.Text:lower()) then target = p break end
        end

        if target then
            toggle.Text = "Arremessando..."
            toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
            task.spawn(function()
                while active do
                    ThrowObjectsAt(target)
                    task.wait(0.3) -- Intervalo entre ondas
                end
            end)
        else
            active = false
            toggle.Text = "Alvo não encontrado"
            task.wait(1)
            toggle.Text = "Target Thrower: OFF"
        end
    else
        toggle.Text = "Target Thrower: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)

-- LOGICA CHAOS MODE (TODOS)
allToggle.MouseButton1Click:Connect(function()
    chaosMode = not chaosMode
    allToggle.Text = chaosMode and "Chaos Mode: ON" or "Chaos Mode: OFF"
    allToggle.BackgroundColor3 = chaosMode and Color3.fromRGB(0,170,0) or Color3.fromRGB(0, 85, 127)

    if chaosMode then
        active = false
        toggle.Text = "Target Thrower: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)

        task.spawn(function()
            while chaosMode do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= plr then ThrowObjectsAt(p) end
                end
                task.wait(0.5)
            end
        end)
    end
end)
