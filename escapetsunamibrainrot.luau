--// Services & Player
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

--// Variáveis de Controle
_G.AutoCollect = false
_G.AntiTsunami = false
local lastPos = nil

--// GUI (Estilo original)
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "BrainrotHubV2"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "BRAINROT HUB V2"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,40)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// LÓGICA ANTI-TSUNAMI (Melhorada)
task.spawn(function()
    while task.wait(0.1) do
        if _G.AntiTsunami then
            -- Procura por partes gigantes ou com nomes de água se movendo
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("tsunami") or v.Name:lower():find("water") or v.Name:lower():find("wave")) then
                    -- Se a onda estiver vindo na sua direção ou perto
                    if (v.Position - root.Position).Magnitude < 150 then
                        root.CFrame = root.CFrame + Vector3.new(0, 500, 0)
                        task.wait(4) -- Tempo para a onda passar
                    end
                end
            end
        end
    end
end)

--// LÓGICA AUTO COLLECT (Loop Infinito enquanto ON)
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoCollect then
            if not lastPos then lastPos = root.CFrame end
            
            local foundItem = false
            for _, v in pairs(workspace:GetDescendants()) do
                if _G.AutoCollect == false then break end
                
                -- Procura por ProximityPrompt ou ClickDetector
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or (v:IsA("ProximityPrompt") and v)
                
                if prompt and v.Parent:IsA("BasePart") then
                    foundItem = true
                    -- Teleporta levemente acima para não bugar no chão
                    root.CFrame = v.Parent.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.2)
                    
                    -- Simula a interação
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        -- Caso o executor não tenha fireproximityprompt
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration)
                        prompt:InputHoldEnd()
                    end
                    task.wait(0.3)
                end
            end
            
            if not foundItem and lastPos then
                root.CFrame = lastPos
                lastPos = nil
                _G.AutoCollect = false -- Desliga sozinho se não achar mais nada
            end
        end
    end
end)

--// Função de criar botão (Seu estilo)
local function makeToggle(text, callback)
    local state = false
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(0, 280, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Text = text.." [OFF]"

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." ["..(state and "ON" or "OFF").."]"
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
    
    scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10)
end

-- Botões
makeToggle("Auto Collect Brainrots", function(s)
    _G.AutoCollect = s
end)

makeToggle("Anti-Tsunami", function(s)
    _G.AntiTsunami = s
end)

-- Botão Fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
