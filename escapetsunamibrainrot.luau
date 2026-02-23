--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

--// Variáveis Globais (Para persistir entre mortes)
getgenv().AutoCollect = getgenv().AutoCollect or false
getgenv().AntiTsunami = getgenv().AntiTsunami or false
local lastPos = nil

--// Função para atualizar as referências do personagem
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = newChar:WaitForChild("HumanoidRootPart")
    -- Se o AutoCollect estava ligado antes de morrer, ele continua após renascer
end)

--// GUI (Mesmo estilo, configurada para não sumir ao morrer)
if plr.PlayerGui:FindFirstChild("BrainrotHubV3") then
    plr.PlayerGui:FindFirstChild("BrainrotHubV3"):Destroy()
end

local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotHubV3"
gui.ResetOnSpawn = false -- ISSO GARANTE QUE O MENU NÃO SUMA

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "BRAINROT HUB V3 - AUTO RESPAWN"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 15

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,40)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// LÓGICA ANTI-TSUNAMI
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AntiTsunami and root then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("tsunami") or v.Name:lower():find("wave") or v.Name:lower():find("water")) then
                    if (v.Position - root.Position).Magnitude < 150 then
                        root.CFrame = root.CFrame + Vector3.new(0, 500, 0)
                        task.wait(5)
                    end
                end
            end
        end
    end
end)

--// LÓGICA AUTO COLLECT (Aprimorada para novos itens e renascimento)
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoCollect and root then
            -- Salva a posição apenas se não estivermos no meio de um teleporte
            if not lastPos then lastPos = root.CFrame end
            
            local itensEncontrados = 0
            
            for _, v in pairs(workspace:GetDescendants()) do
                if not getgenv().AutoCollect then break end
                
                -- Verifica se é um item coletável (ProximityPrompt ou ClickDetector)
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or (v:IsA("ProximityPrompt") and v)
                local click = v:FindFirstChildOfClass("ClickDetector") or (v:IsA("ClickDetector") and v)
                
                if (prompt or click) and v.Parent:IsA("BasePart") then
                    itensEncontrados = itensEncontrados + 1
                    
                    -- Teleporta e interage
                    root.CFrame = v.Parent.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.3)
                    
                    if prompt then
                        fireproximityprompt(prompt)
                    elseif click then
                        fireclickdetector(click)
                    end
                    task.wait(0.5)
                end
            end
            
            -- Se limpou tudo ou desligou, volta pra base
            if itensEncontrados == 0 and lastPos then
                root.CFrame = lastPos
                lastPos = nil
                -- Opcional: print("Todos os Brainrots coletados!")
            end
        end
    end
end)

--// Função de criar botão (Seu estilo)
local function makeToggle(text, startState, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(0, 280, 0, 45)
    btn.BackgroundColor3 = startState and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Text = text.." ["..(startState and "ON" or "OFF").."]"

    btn.MouseButton1Click:Connect(function()
        local newState = not (btn.BackgroundColor3 == Color3.fromRGB(0,170,0))
        btn.Text = text.." ["..(newState and "ON" or "OFF").."]"
        btn.BackgroundColor3 = newState and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(newState)
    end)
    
    scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10)
end

-- Botões
makeToggle("Auto Collect Brainrots", getgenv().AutoCollect, function(s)
    getgenv().AutoCollect = s
end)

makeToggle("Anti-Tsunami", getgenv().AntiTsunami, function(s)
    getgenv().AntiTsunami = s
end)

-- Botão Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
