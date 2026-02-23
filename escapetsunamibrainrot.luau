--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

--// Variáveis de Controle
local autoCollect = false
local antiTsunami = false
local lastPos = nil

--// GUI (Estilo solicitado)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.4,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "BRAINROT ESCAPE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- SCROLL CONTAINER
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,40)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

---// Funções de Lógica

-- Função para detectar Tsunami (Geralmente são partes grandes com "Water" ou "Tsunami" no nome)
task.spawn(function()
    while task.wait(0.1) do
        if antiTsunami then
            for _, v in pairs(workspace:GetDescendants()) do
                if (v.Name:find("Tsunami") or v.Name:find("Wave") or v.Name:find("Water")) and v:IsA("BasePart") then
                    -- Se a onda estiver perto (ajuste a distância se necessário)
                    if (v.Position - root.Position).Magnitude < 100 then
                        root.CFrame = root.CFrame * CFrame.new(0, 500, 0)
                        task.wait(5) -- Espera a onda passar
                    end
                end
            end
        end
    end
end)

-- Função Auto Collect
local function startAutoCollect()
    lastPos = root.CFrame
    
    -- Procura por itens (Ajuste o nome "Brainrot" conforme o real do jogo)
    local items = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") or v:IsA("ProximityPrompt") then
            table.insert(items, v.Parent)
        end
    end

    for _, item in pairs(items) do
        if not autoCollect then break end
        if item:IsA("BasePart") or item:FindFirstChildWhichIsA("BasePart") then
            local target = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            
            -- Teleporta
            root.CFrame = target.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.5)
            
            -- Interage (ProximityPrompt)
            local prompt = item:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
            task.wait(0.5)
        end
    end
    
    -- Volta para a posição original
    root.CFrame = lastPos
    autoCollect = false
end

---// Criação dos Botões (Mesma função do seu modelo)
local function makeToggle(text, initialState, callback)
    local state = initialState
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(0, 280, 0, 45)
    btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Font = Enum.Font.Gotham
    btn.Text = text.." ["..(state and "ON" or "OFF").."]"

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." ["..(state and "ON" or "OFF").."]"
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
    
    scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
    return btn
end

-- Botões do Hub
makeToggle("Auto Collect Brainrots", false, function(s)
    autoCollect = s
    if s then startAutoCollect() end
end)

makeToggle("Anti-Tsunami (TP UP)", false, function(s)
    antiTsunami = s
end)

-- Botão Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
