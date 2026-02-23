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
local flySpeed = 100 

--// Função para atualizar referências de forma segura
local function getCharData()
    local c = plr.Character
    if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
        return c, c.HumanoidRootPart
    end
    return nil, nil
end

--// Função para validar posição além da linha branca
local function estaDepoisDaLinha(itemPos)
    if not originalPos then return true end
    local direcaoMapa = (originalPos.Z > 0) and 1 or -1
    if direcaoMapa == 1 then
        return itemPos.Z > (originalPos.Z + 2)
    else
        return itemPos.Z < (originalPos.Z - 2)
    end
end

--// Função para buscar o Brainrot mais próximo
local function getClosestBrainrot()
    local _, characterRoot = getCharData()
    if not characterRoot then return nil end
    
    local closest = nil
    local shortestDist = math.huge
    
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and not itensPegos[prompt] then
            local part = prompt.Parent
            if part and (part:IsA("BasePart") or part:IsA("Model")) then
                local pPos = part:GetPivot().Position
                if estaDepoisDaLinha(pPos) then
                    local dist = (characterRoot.Position - pPos).Magnitude
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

--// Função de Movimentação por Velocidade (Persistente)
local function velocityMove(targetPos)
    local c, r = getCharData()
    if not r then return end
    
    local bv = Instance.new("BodyVelocity", r)
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    local bg = Instance.new("BodyGyro", r)
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.CFrame = r.CFrame

    -- Loop de movimento checando vida a cada passo
    while autoFarm and r and r.Parent and c.Humanoid.Health > 0 and (r.Position - targetPos).Magnitude > 6 do
        bv.Velocity = (targetPos - r.Position).Unit * flySpeed
        task.wait()
        c, r = getCharData() -- Revalida o personagem durante o voo
        if not r then break end
    end
    
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotFixedHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,380)
frame.Position = UDim2.new(0.5,-160,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "BRAINROT PERSISTENTE"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

local limitBox = Instance.new("TextBox", scroll)
limitBox.Size = UDim2.new(1,-8,0,40)
limitBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
limitBox.TextColor3 = Color3.new(1,1,1)
limitBox.Text = "1"
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
    task.wait()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

--// LOOP PRINCIPAL (Não morre com o Player)
task.spawn(function()
    while true do
        if autoFarm then
            local c, r = getCharData()
            if r then
                if contadorAtual < limiteBrainrots then
                    local target = getClosestBrainrot()
                    if target then
                        velocityMove(target.Parent:GetPivot().Position + Vector3.new(0, 8, 0))
                        fireproximityprompt(target)
                        itensPegos[target] = true
                        contadorAtual = contadorAtual + 1
                    else
                        if originalPos then velocityMove(originalPos) end
                    end
                else
                    autoFarm = false
                end
            end
        end
        task.wait(1) -- Intervalo de segurança
    end
end)

-- Toggles
makeToggle("Auto Farm", function(state)
    autoFarm = state
    if state then
        local _, r = getCharData()
        if r then originalPos = r.Position end
        contadorAtual = 0
        itensPegos = {}
    end
end)

makeToggle("Anti-Tsunami", function(state) antiTsunami = state end)

-- Lógica Anti-Tsunami (Independente)
RunService.Heartbeat:Connect(function()
    if antiTsunami then
        local c, r = getCharData()
        if r then
            for _, obj in pairs(workspace:GetChildren()) do
                if (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave")) and obj:IsA("BasePart") then
                    if (r.Position.Y - obj.Position.Y) < 35 and (r.Position - obj.Position).Magnitude < 180 then
                        r.Velocity = Vector3.new(0, 150, 0)
                    end
                end
            end
        end
    end
end)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
