--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

--// Variáveis de Controle
local autoFarm = false
local antiTsunami = false
local originalPos = nil
local itensPegos = {}
local limiteBrainrots = 1 -- Valor padrão
local contadorAtual = 0
local flySpeed = 200 -- Velocidade aumentada para 200

--// Referências Dinâmicas
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
end)

--// Função de Movimentação por Velocidade
local function velocityMove(targetPos)
    if not root then return end
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = root.CFrame
    bg.Parent = root

    -- Loop de movimento rápido
    while autoFarm and root and (root.Position - targetPos).Magnitude > 7 do
        local direction = (targetPos - root.Position).Unit
        bv.Velocity = direction * flySpeed
        task.wait()
    end
    
    bv:Destroy()
    bg:Destroy()
    if root then root.Velocity = Vector3.new(0,0,0) end
end

--// GUI (Estilo original com TextBox)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "VelocityLimitHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,380) -- Aumentado um pouco para caber a box
frame.Position = UDim2.new(0.5,-160,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Brainrot Velocity (Speed 200)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,35)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

--// CRIAR TEXTBOX PARA LIMITE
local limitLabel = Instance.new("TextLabel", scroll)
limitLabel.Size = UDim2.new(1,-8,0,25)
limitLabel.BackgroundTransparency = 1
limitLabel.Text = "Limite de Brainrots:"
limitLabel.TextColor3 = Color3.new(1,1,1)
limitLabel.TextSize = 18

local limitBox = Instance.new("TextBox", scroll)
limitBox.Size = UDim2.new(1,-8,0,40)
limitBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
limitBox.TextColor3 = Color3.new(1,1,1)
limitBox.Text = "1"
limitBox.TextSize = 20
limitBox.PlaceholderText = "Digite a quantidade..."

limitBox.FocusLost:Connect(function()
    local val = tonumber(limitBox.Text)
    if val then
        limiteBrainrots = val
    else
        limitBox.Text = "1"
        limiteBrainrots = 1
    end
end)

local function updateCanvas()
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

local function makeToggle(text, initialState, callback)
    local state = initialState
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." "..(state and "ON" or "OFF")

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
    updateCanvas()
    return btn
end

--// Lógica Anti-Tsunami
RunService.Heartbeat:Connect(function()
    if antiTsunami and root and root.Parent then
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave")) and obj:IsA("BasePart") then
                local distY = (root.Position.Y - obj.Position.Y)
                if distY < 35 and (root.Position - obj.Position).Magnitude < 200 then
                    root.Velocity = Vector3.new(0, 200, 0)
                end
            end
        end
    end
end)

--// Lógica Auto-Farm com Contador
local function startFarm()
    if root then originalPos = root.Position end
    contadorAtual = 0
    
    while autoFarm do
        -- Verifica se já bateu o limite
        if contadorAtual >= limiteBrainrots then
            autoFarm = false
            print("Limite atingido! Voltando...")
            if originalPos then velocityMove(originalPos) end
            break 
        end

        local alvoEncontrado = false
        
        if root and root.Parent then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if not autoFarm or contadorAtual >= limiteBrainrots then break end
                
                if prompt:IsA("ProximityPrompt") and not itensPegos[prompt] then
                    local itemPart = prompt.Parent
                    if itemPart and (itemPart:IsA("BasePart") or itemPart:IsA("Model")) then
                        alvoEncontrado = true
                        
                        local targetPos = itemPart:GetPivot().Position + Vector3.new(0, 8, 0)
                        velocityMove(targetPos)
                        
                        task.wait(0.1)
                        fireproximityprompt(prompt)
                        
                        itensPegos[prompt] = true
                        contadorAtual = contadorAtual + 1
                        task.wait(0.3)
                    end
                end
            end
        end
        
        if not alvoEncontrado and autoFarm then
            if originalPos and root then velocityMove(originalPos) end
            task.wait(2)
        end
        task.wait(0.1)
    end
end

--// Controles
makeToggle("Start Velocity Farm", false, function(state)
    autoFarm = state
    if state then
        itensPegos = {}
        task.spawn(startFarm)
    end
end)

makeToggle("Anti-Tsunami", false, function(state)
    antiTsunami = state
end)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
