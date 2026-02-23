--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

--// Variáveis de Controle
local autoFarm = false
local antiTsunami = false
local originalPos = nil
local itensPegos = {}

--// Referências Dinâmicas
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
end)

--// Função de Teleporte Suave (Bypass Anti-TP)
local function smoothTeleport(targetCFrame)
    if not root then return end
    local distance = (targetCFrame.Position - root.Position).Magnitude
    local speed = 5 -- Quantos studs por salto (5 como pedido)
    
    -- Calcula quantos passos serão necessários
    local steps = math.floor(distance / speed)
    
    for i = 1, steps do
        if not autoFarm or not root then break end
        -- Move o player 5 studs na direção do alvo
        root.CFrame = root.CFrame:Lerp(targetCFrame, i/steps)
        RunService.Heartbeat:Wait() -- Espera um frame do jogo (muito rápido)
    end
    -- Garante que chegou exatamente no local
    if autoFarm and root then root.CFrame = targetCFrame end
end

--// GUI (Estilo original mantido)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotBypassHub"
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
title.Text = "Brainrot Bypass Hub"
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

--// Lógica Anti-Tsunami
RunService.Heartbeat:Connect(function()
    if antiTsunami and root and root.Parent then
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave")) and obj:IsA("BasePart") then
                local dist = (root.Position.Y - obj.Position.Y)
                if dist < 25 and (root.Position - obj.Position).Magnitude < 250 then
                    root.CFrame = root.CFrame + Vector3.new(0, 50, 0) -- Pulo menor para evitar kick
                end
            end
        end
    end
end)

--// Lógica Auto-Farm
local function startFarm()
    if root then originalPos = root.CFrame end
    
    while autoFarm do
        local alvoEncontrado = false
        
        if root and root.Parent then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if not autoFarm then break end
                
                if prompt:IsA("ProximityPrompt") and not itensPegos[prompt] then
                    local itemPart = prompt.Parent
                    if itemPart and (itemPart:IsA("BasePart") or itemPart:IsA("Model")) then
                        alvoEncontrado = true
                        
                        -- Posição alvo (com offset de altura)
                        local targetCF = CFrame.new(itemPart:GetPivot().Position + Vector3.new(0, 7, 0))
                        
                        -- TELEPORTE SUAVE DE 5 EM 5
                        smoothTeleport(targetCF)
                        
                        task.wait(0.2)
                        fireproximityprompt(prompt)
                        
                        itensPegos[prompt] = true
                        task.wait(0.3)
                    end
                end
            end
        end
        
        if not alvoEncontrado and autoFarm then
            if originalPos and root then
                smoothTeleport(originalPos)
            end
            task.wait(2)
        end
        task.wait(0.1)
    end
end

--// Controles
makeToggle("Auto Bypass Farm", false, function(state)
    autoFarm = state
    if state then
        itensPegos = {}
        task.spawn(startFarm)
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
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
