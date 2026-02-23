--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

--// Variáveis de Controle
local autoFarm = false
local antiTsunami = false
local originalPos = nil

--// GUI (Estilo solicitado)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotHub"
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
title.Text = "Brainrot Tsunami Hub"
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

--// Função de Criar Botão Toggle
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

--// LÓGICA DO ANTI-TSUNAMI
RunService.Stepped:Connect(function()
    if antiTsunami and char:FindFirstChild("HumanoidRootPart") then
        -- Verifica se existe algo chamado 'Tsunami' ou 'Wave' vindo na Workspace
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:find("Tsunami") or obj.Name:find("Wave") or obj.Name:find("Onda")) and obj:IsA("BasePart") then
                local dist = (char.HumanoidRootPart.Position - obj.Position).Magnitude
                if dist < 100 then -- Se a onda estiver a menos de 100 studs
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 500, 0)
                end
            end
        end
    end
end)

--// LÓGICA DO AUTO-FARM
local function startFarm()
    originalPos = char.HumanoidRootPart.CFrame
    
    -- Tenta encontrar os brainrots (geralmente em pastas como 'Drops' ou 'Items')
    local items = {}
    for _, v in pairs(workspace:GetDescendants()) do
        -- Ajuste o nome "Brainrot" se for diferente no jogo
        if v:IsA("TouchTransmitter") or v:IsA("ProximityPrompt") then
            table.insert(items, v.Parent)
        end
    end

    for _, item in pairs(items) do
        if not autoFarm then break end
        if item and item:IsA("BasePart") or item:IsA("MeshPart") then
            char.HumanoidRootPart.CFrame = item.CFrame
            task.wait(0.5) -- Tempo para o jogo registrar que pegou
        end
    end

    -- Volta para a posição original
    char.HumanoidRootPart.CFrame = originalPos
    autoFarm = false
end

--// Controles do Menu
makeToggle("Auto Get Brainrots", false, function(state)
    autoFarm = state
    if state then
        task.spawn(startFarm)
    end
end)

makeToggle("Anti-Tsunami (Auto Jump)", false, function(state)
    antiTsunami = state
end)

-- Botão Fechar
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
