--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

--// Variáveis de Controle
local autoFarm = false
local antiTsunami = false
local originalPos = nil
local itensPegos = {}
local flySpeed = 100 -- Velocidade do deslocamento

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
    
    -- Cria a força de velocidade
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6) -- Força máxima para não cair
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    -- Cria um alinhamento para o corpo não tombar
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = root.CFrame
    bg.Parent = root

    while autoFarm and root and (root.Position - targetPos).Magnitude > 5 do
        local direction = (targetPos - root.Position).Unit
        bv.Velocity = direction * flySpeed
        task.wait()
    end
    
    bv:Destroy()
    bg:Destroy()
    if root then root.Velocity = Vector3.new(0,0,0) end
end

--// GUI (Estilo original mantido)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "VelocityHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Velocity Brainrot Hub"
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

--// Lógica Anti-Tsunami (Fuga por Velocidade)
RunService.Heartbeat:Connect(function()
    if antiTsunami and root and root.Parent then
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave")) and obj:IsA("BasePart") then
                local distY = (root.Position.Y - obj.Position.Y)
                local distXZ = Vector2.new(root.Position.X - obj.Position.X, root.Position.Z - obj.Position.Z).Magnitude
                
                if distY < 30 and distXZ < 150 then
                    -- Aplica um impulso vertical usando Velocity
                    root.Velocity = Vector3.new(0, 150, 0)
                end
            end
        end
    end
end)

--// Lógica Auto-Farm
local function startFarm()
    if root then originalPos = root.Position end
    
    while autoFarm do
        local alvoEncontrado = false
        
        if root and root.Parent then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if not autoFarm then break end
                
                if prompt:IsA("ProximityPrompt") and not itensPegos[prompt] then
                    local itemPart = prompt.Parent
                    if itemPart and (itemPart:IsA("BasePart") or itemPart:IsA("Model")) then
                        alvoEncontrado = true
                        
                        -- Move usando BodyVelocity
                        local targetPos = itemPart:GetPivot().Position + Vector3.new(0, 8, 0)
                        velocityMove(targetPos)
                        
                        task.wait(0.2)
                        fireproximityprompt(prompt)
                        
                        itensPegos[prompt] = true
                        task.wait(0.5)
                    end
                end
            end
        end
        
        if not alvoEncontrado and autoFarm then
            if originalPos and root then
                velocityMove(originalPos)
            end
            task.wait(2)
        end
        task.wait(0.1)
    end
end

--// Controles
makeToggle("Velocity Auto Farm", false, function(state)
    autoFarm = state
    if state then
        itensPegos = {}
        task.spawn(startFarm)
    end
end)

makeToggle("Anti-Tsunami (Impulse)", false, function(state)
    antiTsunami = state
end)

-- Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
