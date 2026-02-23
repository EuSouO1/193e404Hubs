--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

--// Variáveis de Controle
local autoFarm = false
local antiTsunami = false
local originalPos = nil
local itensPegos = {}

--// Referências Dinâmicas (Atualizam ao morrer)
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    
    -- Se o farm estava ligado, ele retoma o loop automaticamente após renascer
    if autoFarm then
        task.wait(1) -- Espera o spawn estabilizar
        task.spawn(function()
            -- O loop de startFarm já vai detectar o novo 'root'
        end)
    end
end)

--// GUI (Mesmo Estilo)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotFixV3"
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
title.Text = "Brainrot Hub (Auto-Respawn)"
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

--// Lógica Anti-Tsunami (Usa 'root' atualizado)
RunService.Heartbeat:Connect(function()
    if antiTsunami and root and root.Parent then
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:lower():find("tsunami") or obj.Name:lower():find("wave")) and obj:IsA("BasePart") then
                local dist = (root.Position.Y - obj.Position.Y)
                if dist < 25 and (root.Position - obj.Position).Magnitude < 250 then
                    root.CFrame = root.CFrame + Vector3.new(0, 500, 0)
                end
            end
        end
    end
end)

--// Lógica Auto-Farm (Usa 'root' atualizado)
local function startFarm()
    if root then originalPos = root.CFrame end
    
    while autoFarm do
        local alvoEncontrado = false
        
        -- Garante que o personagem existe antes de tentar mover
        if root and root.Parent then
            for _, prompt in pairs(workspace:GetDescendants()) do
                if not autoFarm then break end
                
                if prompt:IsA("ProximityPrompt") and not itensPegos[prompt] then
                    local itemPart = prompt.Parent
                    if itemPart and (itemPart:IsA("BasePart") or itemPart:IsA("Model")) then
                        alvoEncontrado = true
                        
                        -- Teleporte com offset para não cair do mapa
                        local targetPos = itemPart:GetPivot().Position + Vector3.new(0, 7, 0)
                        root.CFrame = CFrame.new(targetPos)
                        
                        task.wait(0.3)
                        fireproximityprompt(prompt)
                        
                        itensPegos[prompt] = true
                        task.wait(0.2)
                    end
                end
            end
        end
        
        -- Se não tiver mais nada, volta pra posição salva ou fica no spawn
        if not alvoEncontrado and autoFarm then
            if originalPos and root then
                root.CFrame = originalPos
            end
            task.wait(2) 
        end
        task.wait(0.1)
    end
end

--// Controles
makeToggle("Auto Farm Brainrots", false, function(state)
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
