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

--// Referências Dinâmicas
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
end)

--// Função para validar posição além da linha branca (Eixo Z)
local function estaDepoisDaLinha(itemPos)
    if not originalPos then return true end
    -- Detecta se o campo de jogo expande para Z positivo ou negativo
    local direcaoMapa = (originalPos.Z > 0) and 1 or -1
    if direcaoMapa == 1 then
        return itemPos.Z > (originalPos.Z + 2)
    else
        return itemPos.Z < (originalPos.Z - 2)
    end
end

--// Função para buscar o Brainrot mais próximo
local function getClosestBrainrot()
    local closest = nil
    local shortestDist = math.huge
    
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and not itensPegos[prompt] then
            local part = prompt.Parent
            if part and (part:IsA("BasePart") or part:IsA("Model")) then
                local pPos = part:GetPivot().Position
                if estaDepoisDaLinha(pPos) then
                    local dist = (root.Position - pPos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = prompt
                    end
                end
            end
        end
    end
    return closest
end

--// Função de Movimentação por Velocidade (BodyVelocity)
local function velocityMove(targetPos)
    if not root or not root.Parent then return end
    
    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    
    local bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = root.CFrame

    while autoFarm and root and root.Parent and char.Humanoid.Health > 0 and (root.Position - targetPos).Magnitude > 6 do
        bv.Velocity = (targetPos - root.Position).Unit * flySpeed
        task.wait()
    end
    
    bv:Destroy()
    bg:Destroy()
    if root then root.Velocity = Vector3.new(0,0,0) end
end

--// GUI (Estilo original restaurado)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotVelocityHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,380)
frame.Position = UDim2.new(0.5,-160,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

-- TÍTULO RECOLOCADO
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "BRAINROT VELOCITY HUB"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

local function updateCanvas()
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

-- TextBox de Limite
local limitBox = Instance.new("TextBox", scroll)
limitBox.Size = UDim2.new(1,-8,0,40)
limitBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
limitBox.TextColor3 = Color3.new(1,1,1)
limitBox.Text = "1"
limitBox.PlaceholderText = "Limite de Brainrots"
limitBox.FocusLost:Connect(function() limiteBrainrots = tonumber(limitBox.Text) or 1 end)

local function makeToggle(text, callback)
    local state = false
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text.." OFF"
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text..(state and " ON" or " OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
    updateCanvas()
end

--// Loop Farm Persistente
task.spawn(function()
    while true do
        if autoFarm then
            if root and root.Parent and char.Humanoid.Health > 0 then
                if contadorAtual < limiteBrainrots then
                    local target = getClosestBrainrot()
                    if target then
                        velocityMove(target.Parent:GetPivot().Position + Vector3.new(0, 8, 0))
                        fireproximityprompt(target)
                        itensPegos[target] = true
                        contadorAtual = contadorAtual + 1
                        task.wait(0.3)
                    else
                        if originalPos then velocityMove(originalPos) end
                        task.wait(1)
                    end
                else
                    autoFarm = false
                    if originalPos then velocityMove(originalPos) end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Toggles
makeToggle("Auto Farm (Pos-Linha)", function(state)
    autoFarm = state
    if state then
        originalPos = root.Position
        contadorAtual = 0
        itensPegos = {}
    end
end)

makeToggle("Anti-Tsunami", function(state) antiTsunami = state end)

-- Lógica Anti-Tsunami
RunService.Heartbeat:Connect(function()
    if antiTsunami and root and char.Humanoid.Health > 0 then
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave")) and obj:IsA("BasePart") then
                if (root.Position.Y - obj.Position.Y) < 35 and (root.Position - obj.Position).Magnitude < 180 then
                    root.Velocity = Vector3.new(0, 150, 0)
                end
            end
        end
    end
end)

-- Botão Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
