--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

--// Variáveis de Controle
local autoFarm = false
local antiTsunami = false
local originalPos = nil
local itensPegos = {}
local limiteBrainrots = 1
local contadorAtual = 0
local flySpeed = 100 -- Velocidade ajustada para 100

--// Variáveis do Personagem
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- Atualiza referências ao renascer
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
end)

--// Função para pegar o item mais próximo
local function getClosestBrainrot()
    local closest = nil
    local shortestDist = math.huge
    
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and not itensPegos[prompt] then
            local part = prompt.Parent
            if part and (part:IsA("BasePart") or part:IsA("Model")) then
                local dist = (root.Position - part:GetPivot().Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = prompt
                end
            end
        end
    end
    return closest
end

--// Função de Movimentação por Velocidade
local function velocityMove(targetPos)
    if not root or not root.Parent then return end
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = root.CFrame
    bg.Parent = root

    while autoFarm and root and root.Parent and (root.Position - targetPos).Magnitude > 6 do
        local direction = (targetPos - root.Position).Unit
        bv.Velocity = direction * flySpeed
        task.wait()
    end
    
    bv:Destroy()
    bg:Destroy()
    if root then root.Velocity = Vector3.new(0,0,0) end
end

--// GUI (Mesmo Estilo)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FinalBrainrotHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,380)
frame.Position = UDim2.new(0.5,-160,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Brainrot Proximity Hub"
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

-- Texto Limite
local limitLabel = Instance.new("TextLabel", scroll)
limitLabel.Size = UDim2.new(1,-8,0,25)
limitLabel.BackgroundTransparency = 1
limitLabel.Text = "Limite de Coleta:"
limitLabel.TextColor3 = Color3.new(1,1,1)

local limitBox = Instance.new("TextBox", scroll)
limitBox.Size = UDim2.new(1,-8,0,40)
limitBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
limitBox.TextColor3 = Color3.new(1,1,1)
limitBox.Text = "1"

limitBox.FocusLost:Connect(function()
    limiteBrainrots = tonumber(limitBox.Text) or 1
end)

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
    return btn
end

--// LOOP DE AUTO-FARM PERSISTENTE
task.spawn(function()
    while true do
        if autoFarm then
            -- Verifica se o player está vivo
            if root and root.Parent and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                if contadorAtual < limiteBrainrots then
                    local targetPrompt = getClosestBrainrot()
                    
                    if targetPrompt then
                        local targetPos = targetPrompt.Parent:GetPivot().Position + Vector3.new(0, 8, 0)
                        velocityMove(targetPos)
                        
                        task.wait(0.1)
                        fireproximityprompt(targetPrompt)
                        itensPegos[targetPrompt] = true
                        contadorAtual = contadorAtual + 1
                        task.wait(0.3)
                    else
                        -- Se não achar nada, volta pra base e espera spawns
                        if originalPos then velocityMove(originalPos) end
                        task.wait(2)
                    end
                else
                    -- Atingiu o limite, volta e desliga
                    if originalPos then velocityMove(originalPos) end
                    autoFarm = false
                    -- (Opcional: Atualizar cor do botão aqui exigiria refatoração do toggle)
                end
            else
                -- Player morto, espera renascer
                task.wait(1)
            end
        end
        task.wait(0.5)
    end
end)

--// Lógica Anti-Tsunami
RunService.Heartbeat:Connect(function()
    if antiTsunami and root and root.Parent and char.Humanoid.Health > 0 then
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave")) and obj:IsA("BasePart") then
                local distY = (root.Position.Y - obj.Position.Y)
                if distY < 35 and (root.Position - obj.Position).Magnitude < 180 then
                    root.Velocity = Vector3.new(0, 150, 0)
                end
            end
        end
    end
end)

-- Toggles
makeToggle("Auto Farm (Proximity)", false, function(state)
    autoFarm = state
    if state then 
        contadorAtual = 0
        itensPegos = {}
        if root then originalPos = root.Position end
    end
end)

makeToggle("Anti-Tsunami", false, function(state)
    antiTsunami = state
end)

-- Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
